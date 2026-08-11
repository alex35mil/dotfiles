# Fix Problems at Their Owning Abstraction

When a problem belongs to a shared abstraction or domain model, fix it there. Do not patch around it at one caller merely because that produces a smaller diff.

## Ownership signals

Stop and investigate the owning abstraction when any of these appears:

- a shared component, helper, service, or API does not fulfill its intended contract
- a local caller needs to bypass a shared abstraction or drop to a lower-level primitive
- multiple callers need or are likely to need the same workaround
- local branches, optional fields, booleans, fallback values, or adapters compensate for a limitation in a shared type or API
- a new domain concept does not fit the existing model cleanly
- behavior is being encoded repeatedly instead of represented by a domain type, state machine, policy, or shared operation
- a local fix would preserve invalid states or leave the same underlying defect for other consumers

## Required process

Before editing:

1. Verify the cause from the implementation, usages, and runtime behavior. A failing caller alone does not prove the shared abstraction is defective.
2. Identify where the contract or domain concept belongs.
3. Inspect the abstraction's consumers and state which behavior is valid for each.
4. Fix or extend the owning abstraction. Introduce or reshape the domain model when the concept is genuinely missing.
5. Update affected consumers directly; do not add compatibility shims just to avoid coherent call-site changes.
6. Add verification at the owning boundary, plus consumer coverage where integration behavior matters.

A local fix is valid only when evidence shows the problem is genuinely local or an external constraint prevents an owning-layer fix. State that evidence explicitly.

## Prohibited shortcuts

- Do not bypass a broken shared component/helper with a lower-level implementation at one call site.
- Do not add caller-specific special cases for a shared contract failure.
- Do not widen APIs with optional props/fields, booleans, or fallback variants to hide a missing domain distinction.
- Do not keep an inadequate model solely to minimize the diff.
- Do not claim an abstraction is broken until the failure mechanism is verified.
