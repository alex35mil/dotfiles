use std::{io, process};

use crate::{dir::Dir, log, zellij};

pub(crate) enum Action {
    AttachToSession(String),
    CreateNewSession {
        session: String,
        layout: Option<String>,
        dir: Option<Dir>,
    },
    Exit(Result<(), io::Error>),
}

impl Action {
    pub(crate) fn exec(self) {
        let action = self;

        let status = match action {
            Action::CreateNewSession {
                session,
                layout,
                dir: wd,
            } => zellij::create(&session, &layout, &wd),
            Action::AttachToSession(session) => zellij::attach(&session),
            Action::Exit(Ok(())) => process::exit(0),
            Action::Exit(Err(error)) => Self::exit_with_error(error),
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

    fn exit_with_error(error: io::Error) -> ! {
        log::error(error);
        process::exit(1);
    }
}
