# Coherent design

Choose the correct, coherent design even when it means a larger diff or a breaking change. Diff size and backward compatibility alone are not reasons to pick a worse design.

## Warning signs

You are likely working around the real problem when:
- a caller bypasses a shared helper, component, or API, or drops to a lower-level primitive, because the shared one doesn't do the job;
- you add a caller-specific special case for something wrong in shared code;
- you add optional fields, boolean flags, fallback values, or adapters to cover a concept the model doesn't represent (model it per `domain-modeling.md`);
- several callers need, or will need, the same workaround;
- you keep an old signature, alias, or shim only so existing callers don't have to change;
- logic is repeated where it should be a type, state machine, or shared operation;
- the fix still allows invalid states or leaves the same defect for other callers.

## What to do

1. Confirm the cause from the code, its usages, and runtime behavior. A failing caller alone doesn't prove the shared code is wrong.
2. Fix it where the concept lives. If the concept is missing from the model, add or reshape it following `domain-modeling.md`.
3. Update every affected caller in the same change. Don't keep shims, deprecated aliases, or dual code paths just to avoid touching callers.
4. Test at the shared boundary, plus callers where integration behavior matters.
5. If the coherent fix is much larger than the request implied, describe the scope and ask. Never quietly downgrade to a workaround.

## Valid exceptions

- **External consumers:** keep backward compatibility when consumers are outside your control (published packages, public APIs, persisted data or file formats, other teams' code). Say so, and plan a migration instead of a permanent shim.
- **Genuinely local problems:** a local fix is fine when evidence shows the problem is local, or an external constraint blocks the proper fix. State that evidence.
