# Agents

## General Preferences

- Be concise. Keep responses as short as possible while still being clear, correct, and complete.
- Ask for clarification before making broad, multi-file, or potentially destructive changes
- Prefer small, targeted edits over full-file rewrites
- Avoid unrelated cleanup
- Prefer smaller diffs to easier review
- Verify changes when practical
- Don’t claim success without verification
- If verification wasn’t possible, say so clearly
- Match the existing style and conventions of the file/project
- Don’t reformat unrelated code
- State assumptions when they matter
- Surface tradeoffs briefly
- Before making code changes, briefly describe what you are going to do. Ask for confirmation only when the requested change has not already been discussed or aligned on. If prior messages already make the requested change clear, proceed without waiting for an extra confirmation.
- If the bug cause is already clear and the fix is local/obvious, do not explain, do not pause, do not ask — just patch it.
- If the user's message starts with `disc:`, treat it as a request for discussion first. Answer the question directly and do not jump into edits or code until you and the user are aligned and there are no open questions.

## File Reading

Prefer read-only tools when inspecting file contents. For direct file reads, use the `read` tool, especially for partial reads. When using shell to inspect files, prefer focused, read-only commands such as `head`, `tail`, `rg`, `cat`, `wc`, and safe pipelines of those tools. For line ranges in shell, prefer `tail -n +START file | head -n COUNT` over `sed -n`. Try not to use `sed`, `awk`, `perl`, `python`, and similar multi-purpose tools for file inspection unless there is no reasonable read-only alternative. Prefer focused reads over dumping entire files.

## File Editing

Always re-read a file immediately before editing it. Never rely on content from an earlier read — it may be stale.

## File and line references

When the user references a file with `[file: ...]` and a specific line or line range, you must re-read that exact reference immediately before answering, even if the file was read earlier in the conversation.

Rules:
- For `line: N`, read that exact line first, then read only the minimum nearby context needed to answer.
- For `lines: X-Y`, read that exact range first, then read only the minimum nearby context needed to answer.
- Do not answer from memory when a file reference is provided.
- If multiple file references are provided, read each referenced location before answering.
- If the question compares or relates multiple referenced locations, answer each reference explicitly and then explain the relationship between them.
- In your reply, make clear what exact line(s) were referenced and what extra context, if any, you used.
- If the exact referenced line(s) are insufficient, say so explicitly before reading more context.

## Shell Commands

Don't prefix shell commands with `cd` unless the target directory differs from the current working directory.
