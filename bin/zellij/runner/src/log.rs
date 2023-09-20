use std::fmt;

pub(crate) fn warn(msg: impl fmt::Display) {
    eprintln!("{}", console::style(format!("[WARNING] {}", msg)).yellow());
}

pub(crate) fn error(msg: impl fmt::Display) {
    eprintln!("{}", console::style(format!("[ERROR] {}", msg)).red());
}
