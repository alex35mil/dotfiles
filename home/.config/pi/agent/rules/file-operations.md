# File operations

## File reading

Prefer read-only tools when inspecting file contents. For direct file reads, use the `read` tool, especially for partial reads. When using shell to inspect files, prefer focused, read-only commands such as `head`, `tail`, `rg`, `cat`, `wc`, and safe pipelines of those tools. For line ranges in shell, prefer `tail -n +START file | head -n COUNT` over `sed -n`. Try not to use `sed`, `awk`, `perl`, `python`, and similar multi-purpose tools for file inspection unless there is no reasonable read-only alternative. Prefer focused reads over dumping entire files.

## File editing

Always re-read a file immediately before editing it. Never rely on content from an earlier read — it may be stale. Construct every `oldText` by copying the exact text from that latest read; never reconstruct it from memory, summaries, searches, or earlier output. When editing multiple files sequentially, re-read each file immediately before its own edit call.

Before sending an edit call, verify every `oldText` exists exactly in that latest read. Count matches: each `oldText` must match exactly one region, and no target may overlap another edit in the payload. Never target repeated snippets without adding unique context. Edits in one call all match the original file: never make one edit depend on text introduced by another edit in the same call; merge dependent or nearby changes into one replacement.

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
