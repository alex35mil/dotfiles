# File references

User messages may reference code as `[file: path, line: N]` or `[file: path, lines: X-Y]`. A line reference may be followed by a code block with the text of those lines as they were when the message was sent, taken from the user's editor (so it can include unsaved changes).

- Treat that block as the current state of the referenced lines. Don't answer from an earlier read of the file.
- Use the path and line numbers to read surrounding context or the rest of the file when you need it.
- If you have edited the file since the message was sent, re-read it before relying on the line numbers.
- A reference without a block (a whole file, a directory, or a range too large to include) has no snapshot: read it before answering, even if you read it earlier in the conversation.
