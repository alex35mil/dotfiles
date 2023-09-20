use once_cell::sync::Lazy;

use crate::dir::Dir;

pub(crate) static OPTIONS: Lazy<Options> = Lazy::new(Options::new);

#[derive(Debug)]
pub(crate) struct Options {
    pub root: Dir,
    pub ignore: Vec<String>,
    pub depth: Option<usize>,
    pub layouts: Option<Dir>,
    pub banners: Option<Dir>,
}

impl Options {
    pub fn new() -> Self {
        Self {
            root: Self::root(),
            ignore: Self::ignore(),
            depth: Self::depth(),
            layouts: Self::layouts(),
            banners: Self::banners(),
        }
    }

    fn root() -> Dir {
        let home = Dir::home();
        let root = env::ZELLIJ_RUNNER_ROOT_DIR();

        root.map(|p| home.join(p)).unwrap_or(home)
    }

    fn ignore() -> Vec<String> {
        let dirs = env::ZELLIJ_RUNNER_IGNORE_DIRS();
        match dirs {
            Some(dirs) => dirs.split(',').map(|d| d.trim().to_string()).collect(),
            None => vec![],
        }
    }

    fn depth() -> Option<usize> {
        let dirs = env::ZELLIJ_RUNNER_MAX_DIRS_DEPTH();
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

    fn layouts() -> Option<Dir> {
        let home = Dir::home();
        let dir = env::ZELLIJ_RUNNER_LAYOUTS_DIR();

        dir.map(|p| home.join(p))
    }

    fn banners() -> Option<Dir> {
        let home = Dir::home();
        let dir = env::ZELLIJ_RUNNER_BANNERS_DIR();

        dir.map(|p| home.join(p))
    }
}

mod env {
    use std::env::{self, VarError};

    fn var(name: &str) -> Option<String> {
        match env::var(name) {
            Ok(value) => Some(value),
            Err(VarError::NotPresent) => None,
            Err(VarError::NotUnicode(_)) => {
                panic!("Failed to read {} environment variable. ", name);
            }
        }
    }

    #[allow(non_snake_case)]
    pub(crate) fn ZELLIJ_RUNNER_ROOT_DIR() -> Option<String> {
        var("ZELLIJ_RUNNER_ROOT_DIR")
    }

    #[allow(non_snake_case)]
    pub(crate) fn ZELLIJ_RUNNER_IGNORE_DIRS() -> Option<String> {
        var("ZELLIJ_RUNNER_IGNORE_DIRS")
    }

    #[allow(non_snake_case)]
    pub(crate) fn ZELLIJ_RUNNER_MAX_DIRS_DEPTH() -> Option<String> {
        var("ZELLIJ_RUNNER_MAX_DIRS_DEPTH")
    }

    #[allow(non_snake_case)]
    pub(crate) fn ZELLIJ_RUNNER_LAYOUTS_DIR() -> Option<String> {
        var("ZELLIJ_RUNNER_LAYOUTS_DIR")
    }

    #[allow(non_snake_case)]
    pub(crate) fn ZELLIJ_RUNNER_BANNERS_DIR() -> Option<String> {
        var("ZELLIJ_RUNNER_BANNERS_DIR")
    }
}
