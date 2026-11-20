#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["telethon>=1.36"]
# ///
"""Telegram CLI over the user's own account (MTProto via Telethon). JSON on stdout.

Secrets live in the macOS Keychain, service "telegram-api": api_id and api_hash
(from store-credentials.sh) and session (written by `login`).
"""

import argparse
import asyncio
import json
import logging
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from telethon import TelegramClient, errors, utils
from telethon.sessions import StringSession
from telethon.tl.types import Channel, Chat, User

SVC = "telegram-api"
SAVED = ("me", "saved")


def kc_get(account):
    r = subprocess.run(
        ["security", "find-generic-password", "-s", SVC, "-a", account, "-w"],
        capture_output=True, text=True,
    )
    return r.stdout.strip() if r.returncode == 0 else None


def kc_set(account, value):
    # `security -i` reads the command from stdin, keeping the secret out of argv.
    subprocess.run(
        ["security", "-i"], input=f"add-generic-password -U -s {SVC} -a {account} -w {value}\n",
        text=True, capture_output=True, check=True,
    )
    if kc_get(account) != value:
        sys.exit(f"failed to store {account} in Keychain")


def make_client(session=""):
    api_id, api_hash = kc_get("api_id"), kc_get("api_hash")
    if not (api_id and api_hash):
        sys.exit("api_id/api_hash missing from Keychain; run store-credentials.sh")
    return TelegramClient(
        StringSession(session), int(api_id), api_hash,
        device_model="Agent CLI", system_version="macOS", app_version="1.0",
        flood_sleep_threshold=15,
    )


async def connect():
    session = kc_get("session")
    if not session:
        sys.exit("not logged in; run `tg.py login` in a terminal")
    c = make_client(session)
    await c.connect()
    if not await c.is_user_authorized():
        sys.exit("session expired or revoked; run `tg.py login` in a terminal")
    return c


def emit(obj):
    print(json.dumps(obj, ensure_ascii=False, indent=1))


def kind(e):
    if isinstance(e, User):
        return "bot" if e.bot else "user"
    if isinstance(e, Chat) or (isinstance(e, Channel) and e.megagroup):
        return "group"
    return "channel"


def name(e, chat_arg=None):
    return "Saved Messages" if chat_arg in SAVED else utils.get_display_name(e)


def msg_json(m, preview=False):
    text = m.message or ""
    d = {
        "id": m.id,
        "date": m.date.astimezone().isoformat(timespec="minutes"),
        "from": utils.get_display_name(m.sender) if m.sender else None,
        "out": m.out,
        "text": text[:120] + "…" if preview and len(text) > 120 else text,
        "reply_to": m.reply_to_msg_id,
        "forwarded": bool(m.fwd_from),
    }
    if m.file:
        d["file"] = {"name": m.file.name, "mime": m.file.mime_type, "size": m.file.size}
    return {k: v for k, v in d.items() if v not in (None, "", False)}


async def resolve(c, chat):
    if chat.lower() in SAVED:
        return await c.get_entity("me")
    if chat.startswith(("@", "+")) or "t.me/" in chat:
        return await c.get_entity(chat)
    # StringSession keeps no entity cache, so ids and names are looked up via dialogs.
    want_id = int(chat) if chat.lstrip("-").isdigit() else None
    matches = []
    async for d in c.iter_dialogs():
        if want_id is not None:
            if want_id in (d.id, d.entity.id):
                return d.entity
        elif d.name and chat.lower() in d.name.lower():
            if d.name.lower() == chat.lower():
                return d.entity
            matches.append(d)
    if len(matches) == 1:
        return matches[0].entity
    if matches:
        sys.exit("ambiguous chat; candidates: " + json.dumps(
            [{"id": d.id, "name": d.name} for d in matches[:10]], ensure_ascii=False))
    sys.exit(f"chat not found: {chat}")


async def cmd_login(a):
    c = make_client()
    await c.start()  # prompts for phone, code and 2FA password
    me = await c.get_me()
    kc_set("session", c.session.save())
    print(f"Logged in as {utils.get_display_name(me)}; session stored in Keychain.", file=sys.stderr)
    await c.disconnect()


async def cmd_whoami(c, a):
    me = await c.get_me()
    emit({"id": me.id, "name": utils.get_display_name(me), "username": me.username})


async def cmd_unread(c, a):
    now = datetime.now(timezone.utc)
    out = []
    async for d in c.iter_dialogs(limit=a.scan):
        if not (d.unread_count or d.unread_mentions_count or d.dialog.unread_mark):
            continue
        mute = d.dialog.notify_settings.mute_until
        muted = bool(mute and mute > now)
        if muted and not a.all:
            continue
        out.append({k: v for k, v in {
            "id": d.id, "name": d.name, "type": kind(d.entity),
            "unread": d.unread_count, "mentions": d.unread_mentions_count, "muted": muted,
            "last": msg_json(d.message, preview=True) if d.message else None,
        }.items() if v})
    emit(out)


async def cmd_read(c, a):
    e = await resolve(c, a.chat)
    msgs = [msg_json(m) async for m in c.iter_messages(e, limit=a.n, offset_id=a.before)]
    emit({"chat": name(e, a.chat.lower()), "id": utils.get_peer_id(e), "messages": msgs[::-1]})


async def cmd_search(c, a):
    e = await resolve(c, a.chat) if a.chat else None
    out = []
    async for m in c.iter_messages(e, search=a.query, limit=a.n):
        j = msg_json(m, preview=True)
        if e is None:
            j = {"chat": utils.get_display_name(m.chat) if m.chat else None, "chat_id": m.chat_id, **j}
        out.append(j)
    emit(out)


async def cmd_download(c, a):
    e = await resolve(c, a.chat)
    m = await c.get_messages(e, ids=a.msg_id)
    if not (m and m.file):
        sys.exit("no file in that message")
    dest = Path(a.dir).expanduser() / f"{m.chat_id}-{m.id}"
    dest.mkdir(parents=True, exist_ok=True)
    path = await m.download_media(file=str(dest))
    emit({"path": path, "name": m.file.name, "mime": m.file.mime_type, "size": m.file.size})


async def cmd_send(c, a):
    e = await resolve(c, a.chat)
    m = await c.send_message(e, a.text, file=a.file)
    emit({"sent": m.id, "chat": name(e, a.chat.lower())})


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    chat_help = "me/saved, @username, +phone, numeric id, or unique part of the chat name"

    sub.add_parser("login", help="interactive login; run in a terminal")
    sub.add_parser("whoami")
    s = sub.add_parser("unread", help="chats with unread messages, newest first")
    s.add_argument("--all", action="store_true", help="include muted chats")
    s.add_argument("--scan", type=int, default=300, help="most recent dialogs to scan")
    s = sub.add_parser("read", help="last messages of a chat, oldest first")
    s.add_argument("chat", help=chat_help)
    s.add_argument("-n", type=int, default=20)
    s.add_argument("--before", type=int, default=0, metavar="MSG_ID", help="page back from this message id")
    s = sub.add_parser("search", help="search one chat, or all chats if --chat is omitted")
    s.add_argument("query")
    s.add_argument("--chat", help=chat_help)
    s.add_argument("-n", type=int, default=20)
    s = sub.add_parser("download", help="save a message's file to DIR/<chat_id>-<msg_id>/")
    s.add_argument("chat", help=chat_help)
    s.add_argument("msg_id", type=int)
    s.add_argument("--dir", default="~/Downloads/telegram")
    s = sub.add_parser("send", help="send a message (optionally with a file)")
    s.add_argument("chat", help=chat_help)
    s.add_argument("text")
    s.add_argument("--file")
    a = p.parse_args()

    logging.basicConfig(level=logging.ERROR)

    async def run():
        if a.cmd == "login":
            return await cmd_login(a)
        c = await connect()
        try:
            await globals()[f"cmd_{a.cmd}"](c, a)
        finally:
            await c.disconnect()

    try:
        asyncio.run(run())
    except errors.FloodWaitError as e:
        sys.exit(f"rate-limited by Telegram; retry after {e.seconds}s")
    except errors.RPCError as e:
        sys.exit(f"telegram error: {e}")


if __name__ == "__main__":
    main()
