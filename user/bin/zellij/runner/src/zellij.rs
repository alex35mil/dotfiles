use std::{
    fs, io,
    process::{Command, ExitStatus},
};

use crate::dir::Dir;

const BIN: &str = "zellij";

pub(crate) fn list_sessions() -> io::Result<Vec<String>> {
    let output = Command::new(BIN).arg("list-sessions").output()?;

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
        Ok(lines)
    } else {
        let exit_code = match output.status.code() {
            Some(code) => code.to_string(),
            None => "-".to_string(),
        };

        let stderr = String::from_utf8(output.stderr);

        match stderr {
            Ok(err) => {
                if err.contains("No") && err.contains("sessions found") {
                    Ok(vec![])
                } else {
                    Err(io::Error::new(
                        io::ErrorKind::Other,
                        format!(
                            "Failed to get Zellij sessions. Exit code: {}. {}",
                            exit_code, err
                        ),
                    ))
                }
            }
            Err(_) => Err(io::Error::new(
                io::ErrorKind::Other,
                format!("Failed to get Zellij sessions. Exit code: {}", exit_code),
            )),
        }
    }
}

pub(crate) fn list_layouts(dir: &Dir) -> io::Result<Vec<String>> {
    let layouts = match fs::read_dir(dir) {
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
                    Err(err) => return Err(err),
                }
            }
            layouts
        }
        Err(err) => return Err(err),
    };

    Ok(layouts)
}

pub(crate) fn create(
    session: &str,
    layout: &Option<String>,
    dir: &Option<Dir>,
) -> Result<ExitStatus, io::Error> {
    let mut args = vec!["--session", session];

    if let Some(layout) = layout {
        args.extend_from_slice(&["--layout", layout]);
    }

    let mut cmd = Command::new(BIN);

    if let Some(dir) = dir {
        cmd.current_dir(dir);
    }

    cmd.args(&args).status()
}

pub(crate) fn attach(session: &str) -> Result<ExitStatus, io::Error> {
    Command::new(BIN).args(["attach", session]).status()
}
