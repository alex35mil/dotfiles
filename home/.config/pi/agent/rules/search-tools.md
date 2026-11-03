# Search tools

Search file contents with `rg` (or the harness's dedicated search tool). Never use `grep`, `egrep`, or `fgrep`: permissions block them, including inside pipelines and substitutions, so those calls fail.

- Search contents: `rg pattern path/`. Filter command output: `cmd | rg pattern`.
- List files: `rg --files` (filter with `-g '*.ts'`).
- Use `git grep` only for what `rg` can't do, such as searching another revision (`git grep foo origin/main`) or the staged versions of files (`--cached`). Never use `--no-index` or `--untracked`.
- Don't route around this with `find … -exec grep` or `xargs grep`.
- `rg` reads the user's ripgrep config, which excludes secret files (`.env*`, `mise.local.toml`, `auth.json`). Don't bypass it with `--no-config` or globs that target those files.
