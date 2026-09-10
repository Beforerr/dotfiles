---
name: gog-gmail
description: Work with Gmail through gog CLI, including multiple accounts, search, threads, attachments, and drafts.
---

Reads go through `gmail_digest.py` (this directory), which wraps `gog --readonly` and cuts output
several-fold. Writes go through `gog` directly. Accounts:
`gog auth list --check --json --no-input`; always pass `-a <email>`.

## Reads

```sh
D=~/.claude/skills/gog-gmail/gmail_digest.py
$D -a you@example.com search 'from:acme newer_than:90d' [--max 10] [--page TOKEN]
$D -a you@example.com show <threadId> [<threadId> ...] [--chars 1200] [--files]
$D -a you@example.com fetch <messageId> <index> [-o path]   # index from `show --files`
```

`search` carries no bodies, so "did anyone ever say X?" needs a `show` — batch every id into one
call. `--files` enumerates attachments from the raw payload, the only reliable source.

Raw `gog gmail search|get|thread get|raw` only for what the digest misses; then pass
`--json --no-input --readonly --wrap-untrusted`, plus `--sanitize-content` on the message-level
commands (`search` has none).

## Writes

`gog gmail send|reply|reply-all|forward`; `gog gmail drafts` takes
`create|update|reply|reply-all|forward|send|delete`. `--body-file` for multiline, `--attach` per
file, `--dry-run` to preview. Pass `--gmail-no-send` unless sending was explicitly requested:
"draft it" authorizes a draft, and `drafts send` is a send.

## Gotchas

- **`--select`/`--fields` fail silently**: a projection matching nothing prints `{}`, exit 0.
- **Bad search syntax returns empty,** not an error. Parenthesised `OR` groups are unreliable —
  prefer one simple term and filter locally.
- **`get`/`thread get` omit attachments on some messages,** no error. Answer "does this have
  attachments?" only from `show --files` (or `gog gmail raw <messageId>`, walking `payload.parts[]`).
- **`gmail attachment` has no output flag**: it writes `<msgId>_<n>_attachment.bin` into gogcli's
  cache whatever the real type, and prints that path. `fetch` restores the real filename.
- **Discovery is expensive**: `gog gmail <command> --help` or `gog schema gmail <command> --json`
  for one command, never the full schema. Bare `gog gmail` prints nothing.

Independent rewrite of the [upstream skill](https://github.com/openclaw/gogcli/blob/main/.agents/skills/gog-gmail/SKILL.md),
which is generated and assumes a companion `gog/SKILL.md` we lack — read it when gog is upgraded
(new subcommands surface in its command table), don't sync it over this file. Verified against
gog v0.39.1.
