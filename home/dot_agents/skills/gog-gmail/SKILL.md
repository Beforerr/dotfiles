---
name: gog-gmail
description: Gmail via gog CLI — search, read threads, attachments, drafts, send; multiple accounts.
---

Reads go through `gmail_digest.py` (this dir): wraps `gog --readonly`, ~3x smaller output.
Writes go through `gog gmail`. Account: `-a <email>` or `$GOG_ACCOUNT`; omit to get the list.

```sh
D=~/.claude/skills/gog-gmail/gmail_digest.py
$D -a me@x search 'from:acme newer_than:90d' [--max 10] [--page TOK]  # one line/thread, no bodies
$D -a me@x show <threadId>... [--chars 1200] [--files]               # bodies; --files: attachments + indices
$D -a me@x fetch <messageId> <index> [-o path]                       # download under real name
gog -a me@x gmail send|reply|reply-all|forward|drafts {create,update,reply,reply-all,forward,send,delete} \
    --to --subject --body-file - --attach f [--dry-run]
```

Raw `gog gmail <cmd> --json --no-input --readonly --wrap-untrusted [--sanitize-content]` only for what the
digest lacks; `gog gmail <cmd> --help` per command, never the full schema.

- Bad query, or `--select`/`--fields` matching nothing: empty output, exit 0. Parenthesised `OR` unreliable;
  one term, filter locally.
- `get`/`thread get` silently omit some attachments; trust only `show --files` or `gog gmail raw`.
- `drafts send` sends. `--gmail-no-send` unless sending was asked for.
