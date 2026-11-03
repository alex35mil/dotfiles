# Continuous improvement from user feedback

Trigger when the user:
- expresses frustration or dissatisfaction;
- corrects the same behavior more than once, or asks why you keep doing something;
- says an issue must not recur.

Then:

1. Acknowledge briefly and fix the immediate issue. No extended apologies.
2. Before ending the response, visibly assess whether prevention is warranted. Fixing the immediate issue alone is not enough.
3. Find the actual cause. Check whether an existing rule, skill, extension, test, or tool already covers it. If one does and still failed, determine why (too vague, wrong trigger, buried, contradicted by other instructions) and repair it instead of adding duplicate guidance.
4. For a repeatable failure, propose one fix stating the cause, the change, and its location. Choose:
   - **Scope:** project-local (`AGENTS.md`, project rule or skill) for project-specific behavior; global only when it applies across projects.
   - **Mechanism:** the narrowest reliable one. Prefer enforcement (extension hook, guard, test, code fix) over prose; use prose only when enforcement is impractical.
5. For a one-off issue, say explicitly why no persistent change is justified.
6. Do not apply the fix without approval unless the user already requested it.
