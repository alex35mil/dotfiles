# Domain modeling

Applies when designing or changing data types, state, errors, or the logic that branches on them, in any language.
Use the closest idioms: Rust enums, Swift enums with associated values, TypeScript discriminated unions, etc.

- Model "one of several" as a sum type, not booleans or nullable fields whose validity depends on another field.
  Make invalid states unrepresentable: a field that only makes sense for one variant lives in that variant.
- Decide by matching exhaustively inside the operation that needs the answer. No derived booleans (`isX`) used for
  decisions, no `default`/wildcard branches over domain enums, no partial matches with a fallback. A new variant
  must fail to compile until every decision covers it.
- Model lifecycles as explicit state machines: one state value (sum type) and transition functions that take the
  current state and an event and return the next state. Don't spread a lifecycle across flags, nullable fields, or
  call-order conventions, and don't mutate state fields directly from multiple places. Invalid transitions are typed
  errors or unrepresentable.
- Expected failures are typed values (Result, typed errors) whose variants carry what the caller needs (limits, IDs,
  reasons), not strings or generic errors.
- Absence has one explicit representation (Option/optional), not sentinels or mixed null/undefined.
- Validate at boundaries (parsing, storage, IPC, user input); inside, rely on the types.

Related: `coherent-design.md` covers where to fix a design that doesn't represent a concept; this rule covers how to
model it.
