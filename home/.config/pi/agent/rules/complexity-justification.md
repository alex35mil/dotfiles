# Complexity Must Be Justified by Credible Cases

Do not add implementation complexity or raise review findings for merely theoretical edge cases.

## Mandatory causal-proof gate

Before handling or reporting an edge case, race, or failure mode, explicitly establish every link in the harmful causal chain:

1. **Trigger:** Identify the real supported user action or system event that starts the case.
2. **Overlap:** Identify the exact operations that can overlap and the realistic timescale involved.
3. **Harmful condition:** State the specific ordering, interleaving, or failure required to produce harm.
4. **Natural mechanism:** Show why that harmful condition can occur in production through observed behavior, documented guarantees, or the actual execution path. Do not merely assume it can happen.
5. **Outcome:** State the concrete externally observable failure, data loss, security impact, or invariant violation.
6. **Risk:** Assess likelihood and impact within the product's actual threat and failure model.
7. **Cost:** Compare that risk with the implementation, maintenance, and correctness cost of the proposed handling.

Every link is required. If any link is missing or rests only on an unverified assumption, do not add production complexity and do not raise the case as a review finding. Investigate the uncertain link first.

Causal proof does not require an observed production incident. Static reasoning from the actual code path, documented runtime guarantees, established threat models, or unavoidable failure modes is sufficient when it establishes every link.

If a potentially material security or data-loss risk has a credible trigger but a required link cannot be verified with available access, report only the missing evidence and required investigation. Do not claim a defect or prescribe production handling until the link is verified.

For implementation work, state this assessment before editing. For reviews, include a concise version of the assessment in the finding. A finding without the complete causal chain is invalid.

## Evidence requirements

"This operation is asynchronous" is not evidence of a meaningful race. Operation overlap is not evidence of harmful ordering. Harmful ordering is not evidence of an observable failure. Establish each step separately.

Timing measurements prove only timing. They do not prove reordering, corruption, or user-visible harm.

Synthetic delays or injected faults may make a regression test deterministic only after a credible production mechanism has been established. A case observable only under instrumentation does not justify production complexity.

Do not handle or report scenarios that depend on contrived delays, impossible interaction sequences, synthetic faults with no realistic cause, or behavior outside the supported failure model.

Rare cases remain valid when they have credible causes or material impact, such as process interruption, disk failure, network failure, hostile input, security boundary violations, or concurrency that the real system permits.

Prefer the simplest design that handles credible cases. If defensive complexity costs more than the realistic risk it addresses, reject it.
