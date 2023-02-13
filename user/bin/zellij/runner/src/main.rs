use std::{
    env::{self, VarError},
    fmt, fs, io,
    ops::{Deref, DerefMut},
    path::{Path, PathBuf},
    process::{self, Command, ExitStatus},
};

use dialoguer::{
    console::{self, Style, StyledObject},
    theme::ColorfulTheme,
    Confirm, FuzzySelect, Input,
};
use once_cell::sync::Lazy;

static OPTIONS: Lazy<Options> = Lazy::new(Options::new);

fn main() {
    Runner::init();

    loop {
        Runner::switch();
    }
}

#[derive(Debug)]
struct Options {
    root: Dir,
    ignore: Vec<String>,
    depth: Option<usize>,
}

impl Options {
    pub fn new() -> Self {
        Self {
            root: Self::root(),
            ignore: Self::ignore(),
            depth: Self::depth(),
        }
    }

    fn root() -> Dir {
        let home = Dir::home();
        let root = Env::ZELLIJ_RUNNER_ROOT_DIR();

        root.map(|p| home.join(p)).unwrap_or(home)
    }

    fn ignore() -> Vec<String> {
        let dirs = Env::ZELLIJ_RUNNER_IGNORE_DIRS();
        match dirs {
            Some(dirs) => dirs.split(',').map(|d| d.trim().to_string()).collect(),
            None => vec![],
        }
    }

    fn depth() -> Option<usize> {
        let dirs = Env::ZELLIJ_RUNNER_MAX_DIRS_DEPTH();
        match dirs {
            Some(n) => match n.parse() {
                Ok(n) => Some(n),
                Err(err) => {
                    panic!("Invalid value of ZELLIJ_RUNNER_MAX_DIR_DEPTH. Must be positive int. Found: {}. {}", n, err)
                }
            },
            None => None,
        }
    }
}

struct Args {
    session: String,
    layout: Option<String>,
}

impl Args {
    fn from_args() -> Option<Self> {
        let mut args = env::args();

        match args.nth(1) {
            None => None,
            Some(session) => match args.nth(2) {
                None => Some(Self {
                    session,
                    layout: None,
                }),
                Some(layout) => Some(Self {
                    session,
                    layout: Some(layout),
                }),
            },
        }
    }
}

struct Env;

impl Env {
    #[allow(non_snake_case)]
    pub fn ZELLIJ_RUNNER_ROOT_DIR() -> Option<String> {
        Self::var("ZELLIJ_RUNNER_ROOT_DIR")
    }

    #[allow(non_snake_case)]
    pub fn ZELLIJ_RUNNER_IGNORE_DIRS() -> Option<String> {
        Self::var("ZELLIJ_RUNNER_IGNORE_DIRS")
    }

    #[allow(non_snake_case)]
    pub fn ZELLIJ_RUNNER_MAX_DIRS_DEPTH() -> Option<String> {
        Self::var("ZELLIJ_RUNNER_MAX_DIRS_DEPTH")
    }

    fn var(name: &str) -> Option<String> {
        match env::var(name) {
            Ok(value) => Some(value),
            Err(VarError::NotPresent) => None,
            Err(VarError::NotUnicode(_)) => {
                panic!("Failed to read {} environment variable. ", name);
            }
        }
    }
}

#[derive(Debug)]
struct Dir(PathBuf);

impl Dir {
    pub fn home() -> Self {
        dirs::home_dir()
            .expect("Failed to get HOME directory.")
            .into()
    }

    pub fn cwd() -> Self {
        env::current_dir()
            .expect("Failed to get current directory of the process")
            .into()
    }

    pub fn layouts() -> Self {
        let mut path = Self::home();
        path.extend([".config", "zellij", "layouts"]);
        path
    }

    fn join<P: AsRef<Path>>(&self, path: P) -> Self {
        Self(self.as_path().join(path))
    }
}

impl AsRef<Path> for Dir {
    fn as_ref(&self) -> &Path {
        &self.0
    }
}

impl From<&Path> for Dir {
    fn from(path: &Path) -> Self {
        Self(path.to_path_buf())
    }
}

impl From<PathBuf> for Dir {
    fn from(path: PathBuf) -> Self {
        Self(path)
    }
}

impl From<String> for Dir {
    fn from(path: String) -> Self {
        Self(PathBuf::from(path))
    }
}

impl Deref for Dir {
    type Target = PathBuf;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl DerefMut for Dir {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.0
    }
}

impl fmt::Display for Dir {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let path = &self.0;
        let display = path.strip_prefix(Dir::home()).unwrap_or(path);
        write!(f, "~/{}", display.to_str().unwrap())
    }
}

struct Runner;

impl Runner {
    pub fn init() {
        let input = Args::from_args();
        let sessions = Zellij::list_sessions();

        let action = match (input, sessions.as_slice()) {
            (Some(Args { session, layout }), &[]) => Action::CreateNewSession {
                session,
                layout,
                dir: None,
            },
            (None, &[]) => Action::new_session_prompt(&sessions),
            (Some(Args { session, layout }), _) => {
                if sessions.contains(&session) {
                    Action::AttachToSession(session)
                } else {
                    Action::CreateNewSession {
                        session,
                        layout,
                        dir: None,
                    }
                }
            }
            (None, _) => Action::select(&sessions),
        };

        Self::handle_action(action);
    }

    pub fn switch() {
        let sessions = Zellij::list_sessions();

        let action = match sessions.as_slice() {
            &[] => Action::new_session_prompt(&sessions),
            _ => Action::select(&sessions),
        };

        Self::handle_action(action);
    }

    fn handle_action(action: Action) {
        let status = match action {
            Action::CreateNewSession {
                session,
                layout,
                dir: wd,
            } => Zellij::create(&session, &layout, &wd),
            Action::AttachToSession(session) => Zellij::attach(&session),
            Action::Exit => process::exit(0),
        };

        match status {
            Ok(status) => {
                if !status.success() {
                    process::exit(status.code().unwrap_or(1));
                }
            }
            Err(err) => Self::exit_with_error(err),
        }
    }

    pub fn exit_with_error(err: impl fmt::Display) -> ! {
        eprintln!("{}", console::style(format!("[ERROR] {}", err)).red());
        process::exit(1);
    }
}

struct Zellij;

impl Zellij {
    const BIN: &str = "zellij";

    fn list_sessions() -> Vec<String> {
        let output = match Command::new(Self::BIN).arg("list-sessions").output() {
            Ok(output) => output,
            Err(err) => {
                Runner::exit_with_error(err);
            }
        };
        if output.status.success() {
            let stdout = String::from_utf8(output.stdout).unwrap();
            let lines: Vec<String> = stdout
                .split('\n')
                .into_iter()
                .filter_map(|s| match s {
                    "" => None,
                    s => Some(s.to_owned()),
                })
                .collect();
            lines
        } else {
            let exit_code = match output.status.code() {
                Some(code) => code.to_string(),
                None => "-".to_string(),
            };

            let stderr = String::from_utf8(output.stderr);

            match stderr {
                Ok(err) => {
                    if err.contains("No") && err.contains("sessions found") {
                        vec![]
                    } else {
                        Runner::exit_with_error(format!(
                            "Failed to get Zellij sessions. Exit code: {}. {}",
                            exit_code, err
                        ));
                    }
                }
                Err(_) => {
                    Runner::exit_with_error(format!(
                        "Failed to get Zellij sessions. Exit code: {}",
                        exit_code
                    ));
                }
            }
        }
    }

    fn list_layouts() -> Vec<String> {
        let layouts = match fs::read_dir(Dir::layouts()) {
            Ok(entries) => {
                let size = entries.size_hint().1;
                let mut layouts = match size {
                    Some(size) => Vec::with_capacity(size),
                    None => vec![],
                };
                for entry in entries {
                    match entry {
                        Ok(entry) => {
                            let path = entry.path();
                            if let Some(ext) = path.extension() {
                                if ext.to_string_lossy() == "kdl" {
                                    let layout =
                                        path.file_stem().unwrap().to_string_lossy().to_string();
                                    layouts.push(layout);
                                }
                            }
                        }
                        Err(err) => Runner::exit_with_error(err),
                    }
                }
                layouts
            }
            Err(err) => Runner::exit_with_error(err),
        };

        layouts
    }

    fn create(
        session: &str,
        layout: &Option<String>,
        dir: &Option<Dir>,
    ) -> Result<ExitStatus, io::Error> {
        let mut args = vec!["--session", session];

        if let Some(layout) = layout {
            args.extend_from_slice(&["--layout", layout]);
        }

        let mut cmd = Command::new(Self::BIN);

        if let Some(dir) = dir {
            cmd.current_dir(dir);
        }

        cmd.args(&args).status()
    }

    fn attach(session: &str) -> Result<ExitStatus, io::Error> {
        Command::new(Self::BIN).args(["attach", session]).status()
    }
}

enum Action {
    AttachToSession(String),
    CreateNewSession {
        session: String,
        layout: Option<String>,
        dir: Option<Dir>,
    },
    Exit,
}

impl Action {
    fn theme() -> ColorfulTheme {
        ColorfulTheme {
            active_item_style: Style::new().for_stderr(),
            ..Default::default()
        }
    }

    pub fn select(sessions: &Vec<String>) -> Action {
        let theme = Self::theme();

        let mut entries = sessions
            .iter()
            .map(|session| console::style(format!(" {}", session)).bold())
            .collect::<Vec<StyledObject<String>>>();

        entries.push(console::style(" create".to_string()).dim());
        entries.push(console::style(" exit (or hit Esc)".to_string()).dim());

        let new_session_idx = sessions.len();
        let exit_idx = new_session_idx + 1;

        let selection = FuzzySelect::with_theme(&theme)
            .with_prompt("Pick session:")
            .items(&entries)
            .default(0)
            .report(false)
            .interact_opt()
            .unwrap();

        match selection {
            None => Action::Exit,
            Some(selection) => {
                if selection == new_session_idx {
                    Self::new_session_prompt(sessions)
                } else if selection == exit_idx {
                    Action::Exit
                } else {
                    Action::AttachToSession(sessions[selection].to_owned())
                }
            }
        }
    }

    fn new_session_prompt(sessions: &Vec<String>) -> Action {
        let theme = Self::theme();

        let cwd = Dir::cwd();

        let dir: Option<Dir> = {
            let prompt = format!(
                "Change directory? {}",
                console::style(format!("[current: {}]", cwd)).dim()
            );
            let should_change_dir = Confirm::with_theme(&theme)
                .with_prompt(&prompt)
                .report(false)
                .interact_opt()
                .unwrap();

            match should_change_dir {
                None => return Action::Exit,
                Some(false) => None,
                Some(true) => {
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
                        let dir = entry.path().into();
                        dirs.push(dir);
                    }

                    let selection = FuzzySelect::with_theme(&theme)
                        .with_prompt("Pick directory:")
                        .items(&dirs)
                        .report(false)
                        .interact_opt()
                        .unwrap();

                    match selection {
                        None => return Action::Exit,
                        Some(selection) => Some(dirs[selection].to_owned().into()),
                    }
                }
            }
        };

        let session = {
            let initial_name = {
                let path = match &dir {
                    Some(path) => Some(path),
                    None => Some(&cwd),
                };
                path.and_then(|p| {
                    p.file_name()
                        .and_then(|x| x.to_str().map(|x| x.to_string()))
                })
            };

            let mut prompt = Input::with_theme(&theme);

            if let Some(name) = initial_name {
                prompt.with_initial_text(name);
            }

            let session: String = prompt
                .with_prompt("Session name:")
                .report(false)
                .interact_text()
                .unwrap();

            session
        };

        if sessions.contains(&session) {
            let should_attach = Confirm::new()
                .with_prompt(&format!("Session `{}` exists. Attach to it?", session))
                .report(false)
                .interact_opt()
                .unwrap();
            match should_attach {
                Some(true) => Action::AttachToSession(session),
                Some(false) => Self::new_session_prompt(sessions),
                None => Action::Exit,
            }
        } else {
            let layout = {
                let mut layouts = Zellij::list_layouts();

                layouts.insert(0, console::style("[default]").dim().to_string());

                let selection = FuzzySelect::with_theme(&theme)
                    .with_prompt("Layout:")
                    .items(&layouts)
                    .default(0)
                    .report(false)
                    .interact_opt()
                    .unwrap();

                match selection {
                    Some(0) => None,
                    Some(n) => Some(layouts[n].to_owned()),
                    None => return Action::Exit,
                }
            };

            Action::CreateNewSession {
                session,
                layout,
                dir,
            }
        }
    }
}
