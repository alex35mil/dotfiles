# Ambiguity handling

Never guess product rules, domain semantics, status behavior, visibility behavior, data migration intent, deletion behavior, publishing behavior, validation policy, or user-facing UX behavior.

When a requested change reveals ambiguity, conflict, an exception to the understood pattern, or requires a decision not explicitly specified by the user, existing code pattern, or active rule:

- Do not choose a resolution yourself unless the user explicitly authorized that class of decision.
- Do not hide the ambiguity behind a default, fallback, simplification, or “best guess”.
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
