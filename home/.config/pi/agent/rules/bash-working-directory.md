# Bash working directory

The bash tool already runs every command in the session's working directory (shown in `<cwd>`). Each call starts a fresh shell; nothing persists between calls.

- Do not prefix commands with `cd <cwd> &&`. It is redundant.
- Use paths relative to the cwd: `rg foo src/`, not `cd /abs/repo && rg foo src/`.
- To run in another directory, prefer tool flags (`git -C dir`, `cargo --manifest-path dir/Cargo.toml`, `npm --prefix dir`). Use `cd dir && …` only when no such flag exists.
- Do not expect a `cd` from an earlier call to still apply.
