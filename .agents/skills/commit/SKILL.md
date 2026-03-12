---
name: commit
description: Creates a git commit for the current repository using this repo's commit style. Use when the user asks to commit staged changes or wants help writing a commit message.
---

# Commit

When this skill is invoked, do the commit. Do not ask for permission.

## Goals

- Commit only what is already staged unless the user explicitly asks to stage files.
- Match the repository's existing commit style.
- Keep the workflow safe and concise.

## Repository conventions

- Preferred commit format: `<area>: <summary>`
- Examples from recent history:
  - `nvim: add markdown preview plugin`
  - `nvim: improve todo-comments filtering and highlights`
  - `fonts: center patched nerd font glyphs`
  - `nvim+zellij: update tabs keymaps`

## Workflow

1. Inspect staged changes only.
   - Run `git status --short`
   - Run `git diff --cached --stat`
   - If needed, run `git diff --cached -- <file>` for the staged files
2. If nothing is staged, tell the user and do not create a commit.
3. Infer the best commit message from the staged diff.
4. Do not ask for confirmation before commit - commit directly with `git commit -m "<message>"`.
5. Report the resulting short hash and subject.

## Message guidelines

- Use a short lowercase area, like `nvim`, `zellij`, `shell`, `git`, `fonts`, `zed`, or a combined area such as `nvim+zellij` when justified.
- Keep the summary concise and specific.
- Prefer verbs like `add`, `fix`, `update`, `improve`, `adjust`, `handle`, `remove`.
- Avoid trailing punctuation.

## Safety rules

- Do not stage additional files unless the user explicitly asks.
- Do not include unstaged changes in the commit.
- If the staged set mixes unrelated changes, ask whether to split them before committing.
