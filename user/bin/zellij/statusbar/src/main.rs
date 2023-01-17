mod color;
mod datetime;
mod session;
mod tabs;
mod view;

use std::cmp::{max, min};

use view::Error;
use zellij_tile::prelude::*;

use crate::{
    datetime::DateTime,
    session::Session,
    tabs::Tabs,
    view::{Bg, Spacer},
};

#[derive(Default)]
struct State {
    tabs: Vec<TabInfo>,
    active_tab_idx: usize,
    mode_info: ModeInfo,
    mouse_click_pos: usize,
    should_change_tab: bool,
    now: DateTime,
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self) {
        set_selectable(false);
        set_timeout(1.0);
        subscribe(&[
            EventType::TabUpdate,
            EventType::ModeUpdate,
            EventType::Mouse,
            EventType::Timer,
        ]);
    }

    fn update(&mut self, event: Event) -> bool {
        let mut should_render = false;

        match event {
            Event::ModeUpdate(mode_info) => {
                should_render = self.mode_info != mode_info;
                self.mode_info = mode_info;
            }
            Event::TabUpdate(tabs) => {
                if let Some(active_tab_index) = tabs.iter().position(|t| t.active) {
                    // tabs are indexed starting from 1 so we need to add 1
                    let active_tab_idx = active_tab_index + 1;

                    should_render = self.active_tab_idx != active_tab_idx || self.tabs != tabs;
                    self.active_tab_idx = active_tab_idx;
                    self.tabs = tabs;
                } else {
                    eprintln!("Could not find active tab.");
                }
            }
            Event::Mouse(event) => match event {
                Mouse::LeftClick(_, col) => {
                    if self.mouse_click_pos != col {
                        should_render = true;
                        self.should_change_tab = true;
                    }
                    self.mouse_click_pos = col;
                }
                Mouse::ScrollUp(_) => {
                    should_render = true;
                    switch_tab_to(min(self.active_tab_idx + 1, self.tabs.len()) as u32);
                }
                Mouse::ScrollDown(_) => {
                    should_render = true;
                    switch_tab_to(max(self.active_tab_idx.saturating_sub(1), 1) as u32);
                }
                _ => {}
            },
            Event::Timer(_) => {
                let now = DateTime::now();
                should_render = now != self.now;
                self.now = now;
                set_timeout(1.0);
            }
            _ => {
                eprintln!("Unexpected event: {:?}", event);
            }
        };

        should_render
    }

    fn render(&mut self, _rows: usize, cols: usize) {
        if self.tabs.is_empty() {
            return;
        }

        let session_name = &self.mode_info.session_name;
        let mode = self.mode_info.mode;
        let palette = self.mode_info.style.colors;

        let mut session = Session::render(session_name.as_deref(), mode, palette);
        let tabs = Tabs::render(&self.tabs, mode, palette);
        let mut datetime = self.now.render(mode, palette);
        let pad = Bg::render(2, self.mode_info.style.colors);

        let mut blocks = Vec::with_capacity(cols);

        let occupied = session.len + tabs.len + datetime.len + (pad.len * 2);

        blocks.append(&mut session.blocks);
        blocks.push(pad.clone());

        let (mut mid, spacer) = if occupied > cols {
            let error = Error::render(
                "WHOA, YOU LIKE TABS DON'T YOU. IT'S TIME TO HANDLE IT.",
                palette,
            );

            let parts_len = (session.len + pad.len, error.len, datetime.len + pad.len);

            let spacer = Spacer::render(cols, parts_len, palette);

            (vec![error], spacer)
        } else {
            let parts_len = (session.len + pad.len, tabs.len, datetime.len + pad.len);

            let spacer = Spacer::render(cols, parts_len, palette);

            (tabs.blocks, spacer)
        };

        match spacer {
            Spacer {
                left: Some(left),
                right: Some(right),
            } => {
                blocks.push(left);
                blocks.append(&mut mid);
                blocks.push(right);
            }
            Spacer {
                left: Some(left),
                right: None,
            } => {
                blocks.push(left);
                blocks.append(&mut mid);
            }
            Spacer {
                left: None,
                right: Some(right),
            } => {
                blocks.append(&mut mid);
                blocks.push(right);
            }
            Spacer {
                left: None,
                right: None,
            } => {
                // come what may
                blocks.append(&mut mid);
            }
        }

        blocks.push(pad);
        blocks.append(&mut datetime.blocks);

        let mut bar = String::new();
        let mut cursor = 0;

        for block in blocks {
            bar = format!("{}{}", bar, block.body);

            if let Some(idx) = block.tab_index {
                if self.should_change_tab
                    && self.mouse_click_pos >= cursor
                    && self.mouse_click_pos < cursor + block.len
                {
                    // Tabs are indexed starting from 1, therefore we need add 1 to idx
                    let tab_index = idx + 1;
                    switch_tab_to(tab_index as u32);
                }
            }

            cursor += block.len;
        }

        let bg = match palette.theme_hue {
            ThemeHue::Dark => palette.black,
            ThemeHue::Light => palette.white,
        };

        match bg {
            PaletteColor::Rgb((r, g, b)) => {
                print!("{}\u{1b}[48;2;{};{};{}m\u{1b}[0K", bar, r, g, b);
            }
            PaletteColor::EightBit(color) => {
                print!("{}\u{1b}[48;5;{}m\u{1b}[0K", bar, color);
            }
        }

        self.should_change_tab = false;
    }
}
