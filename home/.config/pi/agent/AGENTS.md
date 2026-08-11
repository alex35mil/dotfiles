# Agents

## General preferences

- BE. FUCKING. CONCISE.
- Ask for clarification before making broad, multi-file, or potentially destructive changes
- Implement the complete, maintainable solution; never trade correctness or coherence for a smaller diff.
- Keep diffs scoped to the requested problem. Make every coherent change required at the owning abstraction; never minimize a diff by patching around that abstraction. Avoid unrelated changes and full-file rewrites when targeted edits can implement the complete solution.
- Avoid unrelated cleanup
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

## Response style

Be terse by default. Use clear, everyday English in user-facing responses.

- State what happens and why it matters before explaining implementation details.
- Prefer plain English followed by the technical term in parentheses:
  "only replace the cache when the version is newer (atomic CAS)."
- Briefly define specialized terms on first use.
- Keep responses as short as possible while still being clear, correct, and complete.
- No background explanations unless asked.
- Prefer a direct recommendation over exhaustive analysis.
- Mention materially beneficial alternatives only when they could change the user’s decision; keep each to one line.
- If more detail may help, end with: “Want details?”
- For reviews: only list issues, severity, and fix.
- Never write long-form explanations by default.

## Ambiguity handling

Never guess product rules, domain semantics, status behavior, visibility behavior, data migration intent, deletion behavior, publishing behavior, validation policy, or user-facing UX behavior.

When a requested change reveals ambiguity, conflict, an exception to the understood pattern, or requires a decision not explicitly specified by the user, existing code pattern, or active rule:

- Do not choose a resolution yourself unless the user explicitly authorized that class of decision.
- Do not hide the ambiguity behind a default, fallback, simplification, or “best guess.”
- Do not implement a fallback, default, or “reasonable” behavior.
- Pause the change at the ambiguous point before editing.
- State:
  1. what does not fit or what case is ambiguous
  2. why the current instructions/code/pattern do not determine the answer
  3. what decision is needed
- Ask for direction before editing that part.

Before editing branching domain logic, first write the decision table. If any row is uncertain, ask before editing.

Words like “probably”, “maybe”, “I’d”, “should”, “likely”, or “assume” are signals to stop and ask instead.

## No unverifiable conditionals

Do not answer with speculative conditionals like “if X…” when X can be checked in the repository.

Before saying “if”, “probably”, “maybe”, “likely”, “should”, or “assume” about code:
1. stop
2. search/read the relevant definition/usages
3. answer from verified code

If verification fails, state exactly what was checked and what could not be found. Do not guess.

## File reading

Prefer read-only tools when inspecting file contents. For direct file reads, use the `read` tool, especially for partial reads. When using shell to inspect files, prefer focused, read-only commands such as `head`, `tail`, `rg`, `cat`, `wc`, and safe pipelines of those tools. For line ranges in shell, prefer `tail -n +START file | head -n COUNT` over `sed -n`. Try not to use `sed`, `awk`, `perl`, `python`, and similar multi-purpose tools for file inspection unless there is no reasonable read-only alternative. Prefer focused reads over dumping entire files.

## File editing

Always re-read a file immediately before editing it. Never rely on content from an earlier read — it may be stale.

Before sending an edit call, verify every `oldText` exists exactly in that latest read. Edits in one call all match the original file: never make one edit depend on text introduced by another edit in the same call; merge dependent or nearby changes into one replacement.

After any edit mismatch, discard the entire failed payload. Re-read the target and retry one verified replacement at a time; never reuse or patch the failed multi-edit payload.

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

## Shell commands

Don't prefix shell commands with `cd` unless the target directory differs from the current working directory.

## Skill path conventions

When reading or following instructions from a skill file:

- Plain relative paths like `./scripts/foo.sh` are relative to the skill directory.
- Use `<repo>/path` to mean a path relative to the current repository root.
- When acting on `<repo>/path`, translate it to the actual repo-relative path before calling tools. Example: `<repo>/docs/release.md` → `docs/release.md`.
- Do not interpret `<repo>/...` as relative to the skill directory.

Outside skill files, follow the normal path semantics of the user request/tool call.

## Tool calls

- Before a meaningful tool call, send one concise sentence describing the immediate action.
- Always do this before edits and verification commands.
- Skip it for routine reads, obvious follow-up searches, and repetitive low-signal tool calls.
- When you preface a tool call, make that tool call in the same turn.
