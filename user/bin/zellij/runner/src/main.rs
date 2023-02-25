//! Ad-hoc replacement of Zellij session switcher (which doesn't exist yet).
//!
//! <img width="1329" alt="screen" src="https://user-images.githubusercontent.com/4244251/221364651-2011f53f-eaa4-445d-959e-86584ed1ad38.png">
//!
//! ## Installation
//! ```sh
//! cargo install zellij-runner
//! ```
//!
//! ## Usage
//! ```sh
//! # run switcher in interactive mode
//! zellij-runner
//!
//! # create/connect to specified session
//! zellij-runner my-session
//!
//! # create session with specified layout
//! zellij-runner my-session my-layout
//! ```
//!
//! To exit the runner, hit `Esc` at any point.
//!
//! ## Configuration
//! ### Layouts
//! The runner can include layout selector when creating a new session.
//! To activate it, set an environment variable with a path to the layouts folder:
//!
//! ```sh
//! ZELLIJ_RUNNER_LAYOUTS_DIR=.config/zellij/layouts
//! ```
//!
//! ### Banner
//! To show a banner, provide a path to the directory with ASCII art.
//!
//! ```sh
//! ZELLIJ_RUNNER_BANNERS_DIR=.config/zellij/banners
//! ```
//!
//! Each file with ASCII art must have `.banner` extension.
//!
//! Runner would pick a random banner each time you switch sessions.
//!
//! ### Paths autocompletion
//! To optimize autocompletion when switching working dir, set the following environment variables:
//!
//! ```sh
//! # directory with the projects, relative to the HOME dir
//! ZELLIJ_RUNNER_ROOT_DIR=Projects
//!
//! # switcher already respects gitignore, but it's still useful in case there's no git
//! ZELLIJ_RUNNER_IGNORE_DIRS=node_modules,target
//!
//! # traverse dirs 3 level max from ZELLIJ_RUNNER_ROOT_DIR
//! ZELLIJ_RUNNER_MAX_DIRS_DEPTH=3
//! ```

mod action;
mod dir;
mod log;
mod options;
mod runner;
mod ui;
mod zellij;

fn main() {
    runner::init();

    loop {
        runner::switch();
    }
}
