# Agents

## General Preferences

- Be concise
- Ask for clarification before making broad, multi-file, or potentially destructive changes
- Prefer small, targeted edits over full-file rewrites
- Avoid unrelated cleanup
- Prefer minimal diffs
- Verify changes when practical
- Don’t claim success without verification
- If verification wasn’t possible, say so clearly
- Match the existing style and conventions of the file/project
- Don’t reformat unrelated code
- State assumptions when they matter
- Surface tradeoffs briefly
- Be clear about what changed and where
- If the user's message ends with a question mark, treat it as a request for discussion first. Answer the question directly and do not jump into edits or code until you and the user are aligned and there are no open questions.

## File Reading

Prefer read-only tools when inspecting file contents. For direct file reads, use the `read` tool, especially for partial reads. When using shell to inspect files, prefer focused, read-only commands such as `head`, `tail`, `rg`, `cat`, `wc`, and safe pipelines of those tools. For line ranges in shell, prefer `tail -n +START file | head -n COUNT` over `sed -n`. Try not to use `sed`, `awk`, `perl`, `python`, and similar multi-purpose tools for file inspection unless there is no reasonable read-only alternative. Prefer focused reads over dumping entire files.

## File Editing

Always re-read a file immediately before editing it. Never rely on content from an earlier read — it may be stale.

## Shell Commands

Don't prefix shell commands with `cd` unless the target directory differs from the current working directory.
