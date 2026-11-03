# Skill path conventions

When reading or following instructions from a skill file:

- Plain relative paths like `./scripts/foo.sh` are relative to the skill directory.
- Use `<repo>/path` to mean a path relative to the current repository root.
- When acting on `<repo>/path`, translate it to the actual repo-relative path before calling tools. Example: `<repo>/docs/release.md` → `docs/release.md`.
- Do not interpret `<repo>/...` as relative to the skill directory.

Outside skill files, follow the normal path semantics of the user request/tool call.
