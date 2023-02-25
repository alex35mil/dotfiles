use std::{
    env, fmt,
    ops::{Deref, DerefMut},
    path::{Path, PathBuf},
};

#[derive(PartialEq, Clone, Debug)]
pub(crate) struct Dir(PathBuf);

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

    pub fn filename(&self) -> Option<String> {
        self.file_name()
            .and_then(|x| x.to_str().map(|x| x.to_string()))
    }

    pub fn join<P: AsRef<Path>>(&self, path: P) -> Self {
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
