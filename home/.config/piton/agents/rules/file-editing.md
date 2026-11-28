# File editing

Use the `edit` and `write` tools for all hand-authored file changes: `edit` for existing files, `write` for new files or full rewrites. Do not modify files with python, sed, awk, perl, heredoc redirection, or other ad-hoc scripts.

- Always re-read a file immediately before editing it, even if you read it earlier in the same turn. Files can change at any time without you being told (formatters, the user's editor, other processes). Copy every `oldText` from that latest read; never reconstruct it from memory, summaries, or search output.
- For multiple changes in one file, use a single `edit` call with multiple `edits[]` entries.
- If `oldText` fails to match, re-read the file and fix `oldText`. Do not fall back to a script.
- Project tooling that writes files (formatters, code generators, `git mv`, build steps) is fine.

Exception: a mechanical change across many files (e.g. renaming one identifier everywhere) may use a script. Before running it, state the exact change: what pattern is replaced with what, and in which files. You do not need to wait for approval. Afterwards, review the full diff yourself, confirm only the intended changes were made, and fix any mistakes before continuing.
