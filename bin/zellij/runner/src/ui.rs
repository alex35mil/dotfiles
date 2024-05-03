use std::{
    fs,
    io::{self, Read, Stdout},
    vec,
};

use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyModifiers},
    execute,
    terminal::{self, EnterAlternateScreen, LeaveAlternateScreen},
};
use once_cell::sync::Lazy;
use tui::{
    backend::CrosstermBackend,
    layout,
    layout::{Alignment, Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::{Span, Spans, Text},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph},
    Terminal,
};
use unicode_width::UnicodeWidthStr;

use crate::{action::Action, dir::Dir, log, options::OPTIONS, zellij};

pub(crate) fn action_selector(sessions: zellij::Sessions) -> Action {
    let screen = ActionSelectorScreen::new(sessions.clone());
    UI::render(Box::new(screen), sessions)
}

pub(crate) fn new_session_prompt(sessions: zellij::Sessions) -> Action {
    let screen = ChangeCurrentDirPromptScreen;
    UI::render(Box::new(screen), sessions)
}

static LAYOUTS: Lazy<Layouts> = Lazy::new(Layouts::new);
static BANNERS: Lazy<Banners> = Lazy::new(Banners::new);

type Term = tui::Terminal<CrosstermBackend<Stdout>>;
type Frame<'a> = tui::Frame<'a, CrosstermBackend<Stdout>>;

trait Screen {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult>;
}

struct UI<'a> {
    screen: Box<dyn Screen>,
    context: UIContext<'a>,
}

struct UIContext<'a> {
    cwd: Dir,
    sessions: zellij::Sessions,
    banner: Option<Banner<'a>>,
}

enum ScreenResult {
    NextScreen(Box<dyn Screen>),
    Action(Action),
}

impl<'a> UI<'a> {
    pub(crate) fn render(screen: Box<dyn Screen>, sessions: zellij::Sessions) -> Action {
        let mut ui = Self {
            screen,
            context: UIContext {
                cwd: Dir::cwd(),
                sessions,
                banner: BANNERS.random(),
            },
        };

        ui.run().unwrap_or_else(|error| Action::Exit(Err(error)))
    }

    fn run(&mut self) -> io::Result<Action> {
        terminal::enable_raw_mode()?;
        let mut stdout = io::stdout();
        execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
        let backend = CrosstermBackend::new(stdout);
        let mut term = Terminal::new(backend)?;

        let result = loop {
            match self.screen.render(&mut term, &self.context) {
                Ok(ScreenResult::NextScreen(screen)) => {
                    self.screen = screen;
                    continue;
                }
                Ok(ScreenResult::Action(action)) => break Ok(action),
                Err(error) => break Err(error),
            }
        };

        terminal::disable_raw_mode()?;
        execute!(
            term.backend_mut(),
            LeaveAlternateScreen,
            DisableMouseCapture
        )?;
        term.show_cursor()?;

        result
    }

    fn layout(
        frame: &mut Frame,
        constraints: &[Constraint],
        banner: &Option<Banner>,
    ) -> Vec<layout::Rect> {
        let container = Layout::default()
            .direction(Direction::Horizontal)
            .constraints(
                [
                    Constraint::Percentage(25),
                    Constraint::Percentage(50),
                    Constraint::Percentage(25),
                ]
                .as_ref(),
            )
            .split(frame.size());

        match banner {
            Some(banner) => {
                let banner_constraint = Constraint::Length(banner.len() as u16 + 2);
                let constraints = [&[banner_constraint], constraints].concat();

                let mut layout = Self::build_layout(&constraints, container[1]);

                let header_container = layout.remove(0);

                banner.render(frame, header_container);

                layout
            }
            None => Self::build_layout(constraints, container[1]),
        }
    }

    fn build_layout(constraints: &[Constraint], container: layout::Rect) -> Vec<layout::Rect> {
        Layout::default()
            .direction(Direction::Vertical)
            .horizontal_margin(0)
            .vertical_margin(6)
            .constraints(constraints)
            .split(container)
    }
}

struct Layouts(Option<Vec<String>>);

impl Layouts {
    fn new() -> Self {
        match &OPTIONS.layouts {
            None => Self(None),
            Some(dir) => match zellij::list_layouts(dir) {
                Ok(layouts) => Self(Some(layouts)),
                Err(error) => {
                    log::warn(format!("Failed to read layouts. {}", error));
                    Self(None)
                }
            },
        }
    }

    fn get(&self) -> &Option<Vec<String>> {
        &self.0
    }
}

struct Banners(Option<Vec<String>>);

impl Banners {
    fn new() -> Self {
        match &OPTIONS.banners {
            None => Self(None),
            Some(dir) => match Self::read_banners(dir) {
                Ok(banners) => {
                    if banners.is_empty() {
                        log::warn("Directory with banners is empty.");
                        Self(None)
                    } else {
                        Self(Some(banners))
                    }
                }
                Err(error) => {
                    log::warn(format!("Failed to read banners. {}", error));
                    Self(None)
                }
            },
        }
    }

    fn read_banners(dir: &Dir) -> io::Result<Vec<String>> {
        let mut banners = vec![];
        let banner_extension = "banner";

        let files = fs::read_dir(dir)?;

        for file in files.flatten() {
            if let Some(ext) = file.path().extension() {
                if ext == banner_extension {
                    let mut file = fs::File::open(file.path())?;
                    let mut banner = String::new();
                    file.read_to_string(&mut banner)?;
                    banners.push(banner);
                }
            }
        }

        Ok(banners)
    }

    fn random(&self) -> Option<Banner> {
        match &self.0 {
            None => None,
            Some(banners) => {
                let idx = fastrand::usize(..banners.len());
                let banner = &banners[idx];
                let lines = banner
                    .lines()
                    .map(|l| Spans(vec![Span::raw(l)]))
                    .collect::<Vec<Spans>>();

                Some(Banner { lines })
            }
        }
    }
}

struct Banner<'a> {
    lines: Vec<Spans<'a>>,
}

impl<'a> Banner<'a> {
    fn len(&self) -> usize {
        self.lines.len()
    }

    fn render(&self, frame: &mut Frame, container: layout::Rect) {
        let header = Paragraph::new(self.lines.clone()).alignment(Alignment::Center);
        frame.render_widget(header, container)
    }
}

struct Title;

impl Title {
    fn render<'a, T>(text: &'a T, frame: &mut Frame, container: layout::Rect)
    where
        T: Into<Text<'a>> + Clone,
    {
        let title = Paragraph::new(text.clone()).block(Block::default().borders(Borders::BOTTOM));
        frame.render_widget(title, container);
    }
}

struct Input {
    value: String,
    label: String,
}

impl Input {
    fn new(label: impl Into<String>) -> Self {
        Self::with_value(String::new(), label)
    }

    fn with_value(value: String, label: impl Into<String>) -> Self {
        Self {
            value,
            label: label.into(),
        }
    }

    fn is_empty(&self) -> bool {
        self.value.is_empty()
    }

    fn insert(&mut self, char: char) {
        self.value.push(char);
    }

    fn delete(&mut self) {
        self.value.pop();
    }

    fn render(&self, frame: &mut Frame, container: layout::Rect) {
        let input_prefix = "❯ ";

        let input = Paragraph::new(format!("{input_prefix}{input}", input = self.value))
            .style(Style::default().fg(Color::Green))
            .block(
                Block::default()
                    .borders(Borders::BOTTOM)
                    .title(Span::styled(
                        &self.label,
                        Style::default().fg(Color::DarkGray),
                    )),
            );

        frame.render_widget(input, container);
        frame.set_cursor(
            container.x + self.value.width() as u16 + input_prefix.width() as u16,
            container.y + 1,
        );
    }
}

struct Prompt<'a, F: Fn(bool) -> ScreenResult> {
    question: Text<'a>,
    selector: Selector<'a, bool>,
    on_select: F,
}

impl<'a, F> Prompt<'a, F>
where
    F: Fn(bool) -> ScreenResult,
{
    pub fn new(question: impl Into<Text<'a>>, on_select: F) -> Self {
        let items = vec![
            SelectorItem {
                value: SelectorValue::Selectable(true),
                label: Span::raw("Yes").into(),
            },
            SelectorItem {
                value: SelectorValue::Selectable(false),
                label: Span::raw("No").into(),
            },
        ];

        Prompt {
            question: question.into(),
            selector: Selector::with_items(items),
            on_select,
        }
    }

    fn draw(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<()> {
        term.draw(|frame| {
            let layout = UI::layout(
                frame,
                &[Constraint::Length(2), Constraint::Length(2)],
                &ctx.banner,
            );

            let title_container = layout[0];
            let selector_container = layout[1];

            Title::render(&self.question, frame, title_container);
            self.selector.render(frame, selector_container);
        })?;

        Ok(())
    }

    fn listen(&mut self) -> io::Result<EventResult> {
        if let Event::Key(key) = event::read()? {
            match (key.code, key.modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => return Ok(EventResult::Exit),
                (KeyCode::Char('y'), _) => {
                    self.selector.select(true);
                    return Ok(EventResult::Return);
                }
                (KeyCode::Char('n'), _) => {
                    self.selector.select(false);
                    return Ok(EventResult::Return);
                }
                (KeyCode::Down, _) => {
                    self.selector.next();
                }
                (KeyCode::Up, _) => {
                    self.selector.previous();
                }
                (KeyCode::Enter, _) => return Ok(EventResult::Return),
                (KeyCode::Esc, _) => return Ok(EventResult::Cancel),
                _ => (),
            }
        }

        Ok(EventResult::Continue)
    }
}

impl<'a, F> Screen for Prompt<'a, F>
where
    F: Fn(bool) -> ScreenResult,
{
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        loop {
            self.draw(term, ctx)?;
            match self.listen()? {
                EventResult::Continue => (),
                EventResult::Return => {
                    match self.selector.flush() {
                        Err(error) => break Err(io::Error::new(io::ErrorKind::Other, error)),
                        Ok(Some(selection)) => break Ok((self.on_select)(selection)),
                        Ok(None) => continue,
                    };
                }
                EventResult::Cancel => {
                    break Ok(ScreenResult::NextScreen(Box::new(
                        ActionSelectorScreen::new(ctx.sessions.clone()),
                    )))
                }
                EventResult::Exit => break Ok(ScreenResult::Action(Action::Exit(Ok(())))),
            };
        }
    }
}

enum SelectorValue<T> {
    Selectable(T),
    Decortive,
}

struct SelectorItem<'a, T> {
    label: Text<'a>,
    value: SelectorValue<T>,
}

impl<'a, T> SelectorItem<'a, T> {
    pub fn pad() -> Self {
        Self {
            label: " ".into(),
            value: SelectorValue::Decortive,
        }
    }
}

struct Selector<'a, T> {
    state: ListState,
    items: Vec<SelectorItem<'a, T>>,
}

impl<'a, T> Selector<'a, T>
where
    T: PartialEq + Clone,
{
    fn with_items(items: Vec<SelectorItem<'a, T>>) -> Selector<'a, T> {
        let mut state = ListState::default();

        if !items.is_empty() {
            let selection = Self::find_first_selectable(&items, 0, false);
            state.select(selection);
        }

        Self { state, items }
    }

    fn render(&mut self, frame: &mut Frame, container: layout::Rect) {
        let items: Vec<ListItem> = self
            .items
            .iter()
            .map(|i| ListItem::new(i.label.to_owned()))
            .collect();

        let list = List::new(items)
            .block(Block::default().borders(Borders::NONE))
            .highlight_style(
                Style::default()
                    .fg(Color::Blue)
                    .add_modifier(Modifier::BOLD),
            )
            .highlight_symbol("▪ ");

        frame.render_stateful_widget(list, container, &mut self.state);
    }

    fn select(&mut self, value: T) {
        let position = self.items.iter().position(|i| match &i.value {
            SelectorValue::Selectable(v) => v == &value,
            SelectorValue::Decortive => false,
        });
        self.state.select(position);
    }

    fn select_by<F>(&mut self, f: F)
    where
        F: Fn(&T) -> bool,
    {
        let position = self.items.iter().position(|i| match &i.value {
            SelectorValue::Selectable(v) => f(v),
            SelectorValue::Decortive => false,
        });
        self.state.select(position);
    }

    fn next(&mut self) {
        let i = match self.state.selected() {
            Some(i) => Self::find_first_selectable(&self.items, i + 1, false).unwrap_or(i),
            None => 0,
        };
        self.state.select(Some(i));
    }

    fn previous(&mut self) {
        let i = match self.state.selected() {
            Some(0) => 0,
            Some(i) => Self::find_first_selectable(&self.items, i - 1, true).unwrap_or(i),
            None => 0,
        };
        self.state.select(Some(i));
    }

    fn find_first_selectable(
        items: &Vec<SelectorItem<'a, T>>,
        starting_from: usize,
        backwards: bool,
    ) -> Option<usize> {
        let item = items.get(starting_from);

        match item {
            None => None,
            Some(item) => match item.value {
                SelectorValue::Selectable(_) => Some(starting_from),
                SelectorValue::Decortive => {
                    if (starting_from == 0 && backwards)
                        || (starting_from == items.len() - 1 && !backwards)
                    {
                        None
                    } else {
                        let next_idx = if backwards {
                            starting_from - 1
                        } else {
                            starting_from + 1
                        };
                        Self::find_first_selectable(items, next_idx, backwards)
                    }
                }
            },
        }
    }

    fn flush(&self) -> Result<Option<T>, String> {
        let selected = match self.state.selected() {
            Some(x) => x,
            None => return Ok(None),
        };
        let item = &self.items[selected];
        match &item.value {
            SelectorValue::Selectable(value) => Ok(Some(value.to_owned())),
            SelectorValue::Decortive => Err(format!(
                "Decorative item selected. Label: {:#?}",
                item.label
            )),
        }
    }
}

enum EventResult {
    Continue,
    Return,
    Cancel,
    Exit,
}

#[derive(PartialEq, Clone)]
pub enum ActionSelectorItem {
    Session { name: String },
    NewSession { input: Option<String> },
    Exit,
}

pub struct ActionSelectorScreen<'a> {
    input: Input,
    selector: Selector<'a, ActionSelectorItem>,
}

impl<'a> ActionSelectorScreen<'a> {
    pub fn new(sessions: zellij::Sessions) -> Self {
        let items = Self::build_selector_list(sessions);

        Self {
            input: Input::new("Select session"),
            selector: Selector::with_items(items),
        }
    }

    fn build_selector_list(
        sessions: zellij::Sessions,
    ) -> Vec<SelectorItem<'a, ActionSelectorItem>> {
        let no_sessions = sessions.is_empty();

        let (active_sessions, exited_sessions) = sessions.split();

        let mut items = active_sessions
            .iter()
            .map(|session| SelectorItem {
                label: session.name.clone().into(),
                value: SelectorValue::Selectable(ActionSelectorItem::Session {
                    name: session.name.to_owned(),
                }),
            })
            .collect::<Vec<SelectorItem<ActionSelectorItem>>>();

        if !exited_sessions.is_empty() {
            if !active_sessions.is_empty() {
                items.push(SelectorItem::pad());
            }
            items.push(SelectorItem {
                value: SelectorValue::Decortive,
                label: Span::styled("Exited sessions:", Style::default().fg(Color::DarkGray))
                    .into(),
            });
            items.extend(exited_sessions.into_iter().map(|session| SelectorItem {
                label: Span::styled(session.name.clone(), Style::default().fg(Color::Gray)).into(),
                value: SelectorValue::Selectable(ActionSelectorItem::Session {
                    name: session.name.clone(),
                }),
            }));
        }

        if !no_sessions {
            items.push(SelectorItem::pad());
            items.push(SelectorItem {
                value: SelectorValue::Decortive,
                label: Span::styled("---", Style::default().fg(Color::DarkGray)).into(),
            });
        }
        items.push(SelectorItem {
            label: " create (or hit Ctrl-N)".into(),
            value: SelectorValue::Selectable(ActionSelectorItem::NewSession { input: None }),
        });
        items.push(SelectorItem {
            label: " exit (or hit Esc)".into(),
            value: SelectorValue::Selectable(ActionSelectorItem::Exit),
        });

        items
    }

    fn draw(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<()> {
        term.draw(|frame| {
            let layout = UI::layout(
                frame,
                &[Constraint::Length(3), Constraint::Min(3)],
                &ctx.banner,
            );

            let input_container = layout[0];
            let selector_container = layout[1];

            self.input.render(frame, input_container);
            self.selector.render(frame, selector_container);
        })?;

        Ok(())
    }

    fn listen(&mut self, ctx: &UIContext) -> io::Result<EventResult> {
        if let Event::Key(key) = event::read()? {
            match (key.code, key.modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => return Ok(EventResult::Exit),
                (KeyCode::Char('\u{F89C}'), KeyModifiers::NONE) // This is specific to my config, sorry!
                | (KeyCode::Char('n'), KeyModifiers::CONTROL) => {
                    self.selector.select_by(|value| match value {
                        ActionSelectorItem::NewSession { input: _ } => true,
                        ActionSelectorItem::Session { .. } | ActionSelectorItem::Exit => false,
                    });
                    return Ok(EventResult::Return);
                }
                (KeyCode::Char(char), _) => {
                    self.input.insert(char);
                    self.filter(ctx);
                }
                (KeyCode::Backspace, _) => {
                    self.input.delete();
                    self.filter(ctx);
                }
                (KeyCode::Down, _) => {
                    self.selector.next();
                }
                (KeyCode::Up, _) => {
                    self.selector.previous();
                }
                (KeyCode::Enter, _) => return Ok(EventResult::Return),
                (KeyCode::Esc, _) => return Ok(EventResult::Exit),
                _ => (),
            }
        }

        Ok(EventResult::Continue)
    }

    fn filter(&mut self, ctx: &UIContext) {
        let next_sessions = if self.input.is_empty() {
            ctx.sessions.to_owned()
        } else {
            ctx.sessions
                .iter()
                .filter_map(|session| {
                    if session.name.contains(&self.input.value) {
                        Some(session.to_owned())
                    } else {
                        None
                    }
                })
                .collect::<zellij::Sessions>()
        };
        let next_items = Self::build_selector_list(next_sessions);
        self.selector = Selector::with_items(next_items);
    }
}

impl<'a> Screen for ActionSelectorScreen<'a> {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        loop {
            self.draw(term, ctx)?;
            match self.listen(ctx)? {
                EventResult::Continue => (),
                EventResult::Return => {
                    match self.selector.flush() {
                        Ok(None) => continue,
                        Ok(Some(selection)) => {
                            let result = match selection {
                                ActionSelectorItem::Exit => {
                                    ScreenResult::Action(Action::Exit(Ok(())))
                                }
                                ActionSelectorItem::Session { name: session } => {
                                    ScreenResult::Action(Action::AttachToSession(session))
                                }
                                ActionSelectorItem::NewSession { input: _ } => {
                                    ScreenResult::NextScreen(Box::new(ChangeCurrentDirPromptScreen))
                                }
                            };
                            return Ok(result);
                        }
                        Err(error) => return Err(io::Error::new(io::ErrorKind::Other, error)),
                    };
                }
                EventResult::Cancel | EventResult::Exit => {
                    return Ok(ScreenResult::Action(Action::Exit(Ok(()))))
                }
            }
        }
    }
}

struct ChangeCurrentDirPromptScreen;

impl Screen for ChangeCurrentDirPromptScreen {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        let question = Spans(vec![
            Span::raw("Change directory? "),
            Span::styled(
                ctx.cwd.to_string(),
                Style::default().add_modifier(Modifier::DIM),
            ),
        ]);

        let on_select = |should_change_dir| {
            if should_change_dir {
                ScreenResult::NextScreen(Box::new(DirSelectorScreen::new()))
            } else {
                ScreenResult::NextScreen(Box::new(SessionNameScreen::new(
                    SessionNameScreen::default(&ctx.cwd),
                    None,
                )))
            }
        };

        Prompt::new(question, on_select).render(term, ctx)
    }
}

pub struct DirSelectorScreen<'a> {
    input: Input,
    selector: Selector<'a, Dir>,
    dirs: Vec<Dir>,
}

// It would be cool to make this more responsive (debounce the search, move it to bg, etc.)
// It works ok'ish for my use case on my machine,
// but may be slow on less beefy machine with more files/folders
impl<'a> DirSelectorScreen<'a> {
    pub fn new() -> Self {
        use ignore::WalkBuilder;

        let results = WalkBuilder::new(&OPTIONS.root)
            .max_depth(OPTIONS.depth)
            .filter_entry(|e| {
                let path = e.path();

                if !path.is_dir() {
                    return false;
                }

                let dir = path.file_name();

                match dir.and_then(|x| x.to_str()) {
                    None => false,
                    Some(dir) => !OPTIONS.ignore.iter().any(|s| *s == dir),
                }
            })
            .build();

        let mut dirs: Vec<Dir> = match results.size_hint().1 {
            None => vec![],
            Some(n) => Vec::with_capacity(n),
        };

        for entry in results.flatten() {
            let dir: Dir = entry.path().into();
            dirs.push(dir);
        }

        let items = Self::build_selector_list(&dirs);

        Self {
            input: Input::new("Select directory"),
            selector: Selector::with_items(items),
            dirs,
        }
    }

    fn build_selector_list(dirs: &[Dir]) -> Vec<SelectorItem<'a, Dir>> {
        dirs.iter()
            .take(40)
            .map(|dir| SelectorItem {
                label: dir.to_string().into(),
                value: SelectorValue::Selectable(dir.clone()),
            })
            .collect::<Vec<SelectorItem<Dir>>>()
    }

    fn draw(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<()> {
        term.draw(|frame| {
            let layout = UI::layout(
                frame,
                &[Constraint::Length(3), Constraint::Min(3)],
                &ctx.banner,
            );

            let input_container = layout[0];
            let selector_container = layout[1];

            self.input.render(frame, input_container);
            self.selector.render(frame, selector_container);
        })?;

        Ok(())
    }

    fn listen(&mut self) -> io::Result<EventResult> {
        if let Event::Key(key) = event::read()? {
            match (key.code, key.modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => return Ok(EventResult::Exit),
                (KeyCode::Char(char), _) => {
                    self.input.insert(char);
                    self.filter();
                }
                (KeyCode::Backspace, _) => {
                    self.input.delete();
                    self.filter();
                }
                (KeyCode::Down, _) => {
                    self.selector.next();
                }
                (KeyCode::Up, _) => {
                    self.selector.previous();
                }
                (KeyCode::Enter, _) => return Ok(EventResult::Return),
                (KeyCode::Esc, _) => return Ok(EventResult::Cancel),
                _ => (),
            }
        }

        Ok(EventResult::Continue)
    }

    fn filter(&mut self) {
        let next_items = if self.input.is_empty() {
            Self::build_selector_list(&self.dirs)
        } else {
            let dirs = self
                .dirs
                .iter()
                .filter_map(|dir| {
                    if dir
                        .to_string()
                        .to_lowercase()
                        .contains(&self.input.value.to_lowercase())
                    {
                        Some(dir.clone())
                    } else {
                        None
                    }
                })
                .collect::<Vec<Dir>>();
            Self::build_selector_list(&dirs)
        };
        self.selector = Selector::with_items(next_items);
    }
}

impl<'a> Screen for DirSelectorScreen<'a> {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        loop {
            self.draw(term, ctx)?;
            match self.listen()? {
                EventResult::Continue => (),
                EventResult::Return => {
                    match self.selector.flush() {
                        Ok(None) => continue,
                        Ok(Some(dir)) => {
                            let result = ScreenResult::NextScreen(Box::new(
                                SessionNameScreen::new(SessionNameScreen::default(&dir), Some(dir)),
                            ));
                            return Ok(result);
                        }
                        Err(error) => return Err(io::Error::new(io::ErrorKind::Other, error)),
                    };
                }
                EventResult::Cancel => {
                    return Ok(ScreenResult::NextScreen(Box::new(
                        ActionSelectorScreen::new(ctx.sessions.clone()),
                    )))
                }
                EventResult::Exit => return Ok(ScreenResult::Action(Action::Exit(Ok(())))),
            }
        }
    }
}

struct SessionNameScreen {
    input: Input,
    dir: Option<Dir>,
}

impl SessionNameScreen {
    fn new(initial_name: Option<String>, dir: Option<Dir>) -> Self {
        let label = "Give session a name";

        Self {
            input: match initial_name {
                Some(value) => Input::with_value(value, label),
                None => Input::new(label),
            },
            dir,
        }
    }

    fn default(dir: &Dir) -> Option<String> {
        if cfg!(target_os = "windows") {
            dir.filename()
        } else {
            let home = Dir::home();

            if &home == dir {
                Some("~".to_owned())
            } else {
                dir.filename()
            }
        }
    }

    fn draw(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<()> {
        term.draw(|frame| {
            let layout = UI::layout(
                frame,
                &[Constraint::Length(3), Constraint::Min(1)],
                &ctx.banner,
            );

            let input_container = layout[0];

            self.input.render(frame, input_container);
        })?;

        Ok(())
    }

    fn listen(&mut self) -> io::Result<EventResult> {
        if let Event::Key(key) = event::read()? {
            match (key.code, key.modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => return Ok(EventResult::Exit),
                (KeyCode::Char(char), _) => {
                    self.input.insert(char);
                }
                (KeyCode::Backspace, _) => {
                    self.input.delete();
                }
                (KeyCode::Enter, _) => return Ok(EventResult::Return),
                (KeyCode::Esc, _) => return Ok(EventResult::Cancel),
                _ => (),
            }
        }

        Ok(EventResult::Continue)
    }
}

impl Screen for SessionNameScreen {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        loop {
            self.draw(term, ctx)?;
            match self.listen()? {
                EventResult::Continue => (),
                EventResult::Return => {
                    match self.input.value.as_str() {
                        "" => continue,
                        _ => {
                            if ctx.sessions.contains(&self.input.value) {
                                return Ok(ScreenResult::NextScreen(Box::new(
                                    AttachToExistingSessionPromptScreen::new(
                                        &self.input.value,
                                        &self.dir,
                                    ),
                                )));
                            } else {
                                match LAYOUTS.get() {
                                    None => {
                                        return Ok(ScreenResult::Action(Action::CreateNewSession {
                                            session: self.input.value.to_owned(),
                                            layout: None,
                                            dir: self.dir.to_owned(),
                                        }))
                                    }
                                    Some(layouts) => {
                                        if layouts.len() < 2 {
                                            return Ok(ScreenResult::Action(
                                                Action::CreateNewSession {
                                                    session: self.input.value.to_owned(),
                                                    layout: None,
                                                    dir: self.dir.to_owned(),
                                                },
                                            ));
                                        } else {
                                            let next_screen = LayoutSelectorScreen::new(
                                                layouts,
                                                &self.input.value.to_owned(),
                                                &self.dir,
                                            );
                                            return Ok(ScreenResult::NextScreen(Box::new(
                                                next_screen,
                                            )));
                                        }
                                    }
                                }
                            };
                        }
                    };
                }
                EventResult::Cancel => {
                    return Ok(ScreenResult::NextScreen(Box::new(
                        ActionSelectorScreen::new(ctx.sessions.clone()),
                    )))
                }
                EventResult::Exit => {
                    return Ok(ScreenResult::Action(Action::Exit(Ok(()))));
                }
            }
        }
    }
}

struct AttachToExistingSessionPromptScreen {
    session: String,
    dir: Option<Dir>,
}

impl AttachToExistingSessionPromptScreen {
    fn new(session: &str, dir: &Option<Dir>) -> Self {
        Self {
            session: session.to_owned(),
            dir: dir.clone(),
        }
    }
}

impl Screen for AttachToExistingSessionPromptScreen {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        let question = Spans(vec![
            Span::raw("Session with the name "),
            Span::styled(
                format!("`{}`", self.session),
                Style::default().add_modifier(Modifier::BOLD),
            ),
            Span::raw(" exists. Attach to it? "),
        ]);

        let on_select = |should_attach| {
            if should_attach {
                ScreenResult::Action(Action::AttachToSession(self.session.to_owned()))
            } else {
                let dir = self.dir.to_owned();

                ScreenResult::NextScreen(Box::new(SessionNameScreen::new(
                    dir.as_ref().and_then(|d| d.filename()),
                    dir,
                )))
            }
        };

        Prompt::new(question, on_select).render(term, ctx)
    }
}

struct LayoutSelectorScreen<'a> {
    input: Input,
    selector: Selector<'a, Option<String>>,
    layouts: &'a [String],
    session: String,
    dir: Option<Dir>,
}

impl<'a> LayoutSelectorScreen<'a> {
    fn new(layouts: &'a [String], session: &str, dir: &Option<Dir>) -> Self {
        let items = Self::build_selector_list(layouts.to_owned());

        Self {
            input: Input::new("Select layout"),
            selector: Selector::with_items(items),
            layouts,
            session: session.to_owned(),
            dir: dir.clone(),
        }
    }

    fn build_selector_list(layouts: Vec<String>) -> Vec<SelectorItem<'a, Option<String>>> {
        let mut items = layouts
            .iter()
            .map(|layout| SelectorItem {
                label: layout.to_string().into(),
                value: SelectorValue::Selectable(Some(layout.clone())),
            })
            .collect::<Vec<SelectorItem<Option<String>>>>();

        items.insert(
            0,
            SelectorItem {
                label: Span::styled("[default]", Style::default().add_modifier(Modifier::DIM))
                    .into(),
                value: SelectorValue::Selectable(None),
            },
        );

        items
    }

    fn draw(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<()> {
        term.draw(|frame| {
            let layout = UI::layout(
                frame,
                &[Constraint::Length(3), Constraint::Min(3)],
                &ctx.banner,
            );

            let input_container = layout[0];
            let selector_container = layout[1];

            self.input.render(frame, input_container);
            self.selector.render(frame, selector_container);
        })?;

        Ok(())
    }

    fn listen(&mut self) -> io::Result<EventResult> {
        if let Event::Key(key) = event::read()? {
            match (key.code, key.modifiers) {
                (KeyCode::Char('c'), KeyModifiers::CONTROL) => return Ok(EventResult::Exit),
                (KeyCode::Char(char), _) => {
                    self.input.insert(char);
                    self.filter();
                }
                (KeyCode::Backspace, _) => {
                    self.input.delete();
                    self.filter();
                }
                (KeyCode::Down, _) => {
                    self.selector.next();
                }
                (KeyCode::Up, _) => {
                    self.selector.previous();
                }
                (KeyCode::Enter, _) => return Ok(EventResult::Return),
                (KeyCode::Esc, _) => return Ok(EventResult::Exit),
                _ => (),
            }
        }

        Ok(EventResult::Continue)
    }

    fn filter(&mut self) {
        let next_items = if self.input.is_empty() {
            Self::build_selector_list(self.layouts.to_owned())
        } else {
            let layouts = self
                .layouts
                .iter()
                .filter_map(|layout| {
                    if layout.contains(&self.input.value) {
                        Some(layout.clone())
                    } else {
                        None
                    }
                })
                .collect::<Vec<String>>();
            Self::build_selector_list(layouts)
        };
        self.selector = Selector::with_items(next_items);
    }
}

impl<'a> Screen for LayoutSelectorScreen<'a> {
    fn render(&mut self, term: &mut Term, ctx: &UIContext) -> io::Result<ScreenResult> {
        loop {
            self.draw(term, ctx)?;
            match self.listen()? {
                EventResult::Continue => (),
                EventResult::Return => {
                    match self.selector.flush() {
                        Ok(None) => continue,
                        Ok(Some(selection)) => {
                            let result = ScreenResult::Action(Action::CreateNewSession {
                                session: self.session.to_owned(),
                                layout: selection,
                                dir: self.dir.to_owned(),
                            });
                            return Ok(result);
                        }
                        Err(error) => return Err(io::Error::new(io::ErrorKind::Other, error)),
                    };
                }
                EventResult::Cancel => {
                    return Ok(ScreenResult::NextScreen(Box::new(
                        ActionSelectorScreen::new(ctx.sessions.clone()),
                    )))
                }
                EventResult::Exit => {
                    return Ok(ScreenResult::Action(Action::Exit(Ok(()))));
                }
            }
        }
    }
}
