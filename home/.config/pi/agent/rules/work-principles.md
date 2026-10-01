# Work principles

## General preferences

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
- A question is not a request or authorization to make changes. In discussions, reviews, inline notes, and general conversation, answer questions without inferring a decision. Edit only when the user explicitly requests a change or clearly approves a proposed change.
- If the bug cause is already clear and the fix is local/obvious, do not explain, do not pause, do not ask — just patch it.
- Define documentation, instructions, schemas, and tests from the current positive contract. Do not preserve superseded designs as negative wording or assertions unless a realistic compatibility, migration, safety, or ambiguity boundary requires explicit rejection.
- If the user's message starts with `disc:`, treat it as a request for discussion first. Answer the question directly and do not jump into edits or code until you and the user are aligned and there are no open questions.
