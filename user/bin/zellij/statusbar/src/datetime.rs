use chrono::{FixedOffset, Utc};

use zellij_tile::prelude::*;
use zellij_tile_utils::style;

use crate::{
    color::{self, ModeColor},
    view::{Block, Separator, View},
};

#[derive(PartialEq)]
pub struct DateTime {
    pub date: String,
    pub time: String,
}

impl DateTime {
    // NOTE: `time` crate can't get UTC offset in multithreaded binaries on macos:
    // https://github.com/time-rs/time/issues/293
    // so using chrono (which is also broken here) :shrugs:
    pub fn now() -> Self {
        // FIXME: UTC offset is always +00:00. Hardcoding TZ, for now.
        // let now = Local::now();
        let utc = Utc::now();
        let offset = FixedOffset::east_opt(4 * 3600 /* hours */).unwrap();
        let now = utc.with_timezone(&offset);

        let datetime = now.format("%d/%m/%Y %H:%M").to_string();

        let (date, time) = match datetime.split_once(' ') {
            Some(dt) => dt,
            None => return Self::na(),
        };

        Self {
            date: date.to_owned(),
            time: time.to_owned(),
        }
    }

    fn na() -> Self {
        Self {
            date: "-".to_string(),
            time: "-".to_string(),
        }
    }

    pub fn render(&self, mode: InputMode, palette: Palette) -> View {
        use unicode_width::UnicodeWidthStr;

        let mut blocks = vec![];
        let mut total_len = 0;

        let ModeColor {
            fg: mode_fg,
            bg: mode_bg,
        } = ModeColor::new(mode, palette);

        // separator
        {
            let separator = Separator::render(&color::LIGHTER_GRAY, &palette.bg);

            total_len += separator.len;
            blocks.push(separator);
        }

        // date
        {
            let text = format!(" {} ", self.date);
            let len = text.width();
            let body = style!(palette.white, color::LIGHTER_GRAY).paint(text);

            total_len += len;
            blocks.push(Block {
                body: body.to_string(),
                len,
                tab_index: None,
            });
        }

        // separator
        {
            let separator = Separator::render(&mode_bg, &color::LIGHTER_GRAY);

            total_len += separator.len;
            blocks.push(separator);
        }

        // time
        {
            let text = format!(" {} ", self.time);
            let len = text.width();
            let body = style!(mode_fg, mode_bg).bold().paint(text);

            total_len += len;
            blocks.push(Block {
                body: body.to_string(),
                len,
                tab_index: None,
            });
        }

        View {
            blocks,
            len: total_len,
        }
    }
}

impl Default for DateTime {
    fn default() -> Self {
        Self::now()
    }
}
