use std::{
    cmp::Ordering,
    fs, io,
    process::{Command, ExitStatus},
    slice, vec,
};

use crate::dir::Dir;

const BIN: &str = "zellij";

#[derive(Eq, PartialEq, Clone)]
pub struct Session {
    pub name: String,
    pub is_exited: bool,
}

impl Ord for Session {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self.is_exited, other.is_exited) {
            (true, false) => Ordering::Greater,
            (false, true) => Ordering::Less,
            _ => self.name.cmp(&other.name),
        }
    }
}

impl PartialOrd for Session {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Clone)]
pub struct Sessions(Vec<Session>);

impl IntoIterator for Sessions {
    type Item = Session;
    type IntoIter = vec::IntoIter<Self::Item>;

    fn into_iter(self) -> Self::IntoIter {
        self.0.into_iter()
    }
}

impl FromIterator<Session> for Sessions {
    fn from_iter<I: IntoIterator<Item = Session>>(iter: I) -> Self {
        Sessions(iter.into_iter().collect())
    }
}

impl Sessions {
    pub fn empty() -> Self {
        Self(vec![])
    }

    pub fn from_output(output: Vec<&str>) -> Self {
        let mut sessions = Vec::with_capacity(output.len());

        for line in &output {
            let end = line.find('[').unwrap_or(0) - 1;
            let name = &line[..end];
            let is_exited = line.contains("EXITED");
            let session = Session {
                name: name.to_string(),
                is_exited,
            };
            sessions.push(session);
        }

        sessions.sort();

        Self(sessions)
    }

    pub fn iter(&self) -> slice::Iter<Session> {
        self.0.iter()
    }

    pub fn split(self) -> (Vec<Session>, Vec<Session>) {
        self.0.into_iter().partition(|s| !s.is_exited)
    }

    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    pub fn contains(&self, session: &str) -> bool {
        self.0.iter().any(|s| s.name == session)
    }
}

pub(crate) fn list_sessions() -> io::Result<Sessions> {
    let output = Command::new(BIN)
        .args(["list-sessions", "--no-formatting"])
        .output()?;

    if output.status.success() {
        let stdout = String::from_utf8(output.stdout).unwrap();

        let lines: Vec<&str> = stdout.lines().collect();

        Ok(Sessions::from_output(lines))
    } else {
        let exit_code = match output.status.code() {
            Some(code) => code.to_string(),
            None => "-".to_string(),
        };

        let stderr = String::from_utf8(output.stderr);

        match stderr {
            Ok(err) => {
                if err.contains("No") && err.contains("sessions found") {
                    Ok(Sessions::empty())
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
