"""Zotero utilities"""
from __future__ import annotations

import json
import os
import re
import sqlite3
import tempfile
import time
import urllib.parse
from pathlib import Path

_DOI_RE   = re.compile(r'^(https?://doi\.org/|doi:)?10\.\d{4,}/', re.I)
_ZOTERO_DB = Path.home() / "Zotero" / "zotero.sqlite"
ZOTERO_STORAGE = Path.home() / "Zotero" / "storage"


def _sqlite_connect():
    return sqlite3.connect(f"file:{_ZOTERO_DB}?mode=ro&immutable=1", uri=True)


def local_zotero():
    """Return a pyzotero client for the local Zotero API."""
    from pyzotero import zotero

    return zotero.Zotero(0, "user", local=True)


def sqlite_lookup_citekey(citation_key) -> str | None:
    """Return the Zotero item key for *citation_key*"""
    try:
        con = _sqlite_connect()
        row = con.execute(
            "SELECT items.key FROM itemData "
            "JOIN fields ON itemData.fieldID = fields.fieldID "
            "JOIN itemDataValues ON itemData.valueID = itemDataValues.valueID "
            "JOIN items ON itemData.itemID = items.itemID "
            "WHERE fields.fieldName = 'citationKey' AND itemDataValues.value = ?",
            (citation_key,),
        ).fetchone()
        con.close()
        return row[0] if row else None
    except Exception:
        return None


def sqlite_lookup_doi(doi) -> str | None:
    """Return the Zotero item key"""
    doi = doi.removeprefix("https://doi.org/").removeprefix("doi:")
    try:
        con = _sqlite_connect()
        row = con.execute(
            "SELECT items.key FROM itemData "
            "JOIN fields ON itemData.fieldID = fields.fieldID "
            "JOIN itemDataValues ON itemData.valueID = itemDataValues.valueID "
            "JOIN items ON itemData.itemID = items.itemID "
            "WHERE fields.fieldName = 'DOI' "
            "AND LOWER(itemDataValues.value) = LOWER(?)",
            (doi,),
        ).fetchone()
        con.close()
        return row[0] if row else None
    except Exception:
        return None


def lookup(zot, query: str) -> dict | None:
    """Resolve *query* (citekey, DOI, or partial title) to a pyzotero item dict."""
    # DOI — precise pattern, go straight to SQLite
    if _DOI_RE.match(query):
        key = sqlite_lookup_doi(query)
        return zot.item(key) if key else None

    # Citekey — native field in zotero.sqlite since Zotero 7
    key = sqlite_lookup_citekey(query)
    if key:
        return zot.item(key)

    # Partial title via pyzotero
    ql = query.lower()
    return next(
        (i for i in zot.items(q=query, limit=20)
         if ql in i["data"].get("title", "").lower()),
        None,
    )


def item_metadata(item: dict, pdf: str | None = None) -> dict:
    """Return stable paper metadata from a pyzotero item dict."""
    d = item["data"]
    creators = d.get("creators", [])
    authors = [
        f"{c.get('firstName', '')} {c.get('lastName', '')}".strip()
        for c in creators
        if c.get("creatorType") == "author"
    ]
    year = d.get("date", "")[:4] if d.get("date") else ""
    meta = {
        "citation_key": d.get("citationKey", ""),
        "title": d.get("title", ""),
        "authors": authors,
        "year": year,
        "journal": d.get("publicationTitle", d.get("bookTitle", "")),
        "doi": d.get("DOI", ""),
        "url": d.get("url", ""),
        "abstract": d.get("abstractNote", ""),
        "zotero": f"zotero://select/library/items/{item['key']}",
    }
    if pdf:
        meta["pdf"] = pdf
    return meta


DEFAULT_ATTACHMENT_TYPES = ("application/pdf", "application/epub+zip")


def find_attachment(
    children: list,
    content_types = DEFAULT_ATTACHMENT_TYPES,
) -> tuple[Path | None, str | None]:
    """Return (path, filename) for the first matching attachment child.

    Children are scanned in *content_types* order, so earlier types are preferred over later ones.
    """
    for ctype in content_types:
        for child in children:
            d = child["data"]
            if d.get("contentType") != ctype:
                continue
            att_key  = child["key"]
            filename = d.get("filename") or d.get("path", "").removeprefix("storage:")
            path = ZOTERO_STORAGE / att_key / filename
            return (path if path.exists() else None), filename
    return None, None


# Backwards-compatible alias.
find_local_pdf = find_attachment


# ── Debug bridge: run JS inside Zotero ───────────────────────────────────────
# zotero-plugin-toolkit (bundled in Better BibTeX) registers a `zotero://ztoolkit-debug`
# URL handler that runs arbitrary async JS with `Zotero` in scope. This is the ONLY
# headless route to Zotero's native "Add by Identifier" (Zotero.Translate.Search),
# "Find Available PDF" (Zotero.Attachments.addAvailablePDF) and item deletion — the
# connector saves only what you hand it, and the local /api is read-only (DELETE → 501).
#
# Setup (once): set pref `extensions.zotero.debug-bridge.password` (Zotero closed,
# edit prefs.js, or accept the one-time confirm dialog) and export the same value as
# ZOTERO_BRIDGE_PASSWORD. The channel is fire-and-forget (noContent), so results come
# back via a temp file the injected JS writes.

_DOI_FIND = re.compile(r"10\.\d{4,9}/[^\s\"<>]+")
_ARXIV_RE = re.compile(r"(?:arxiv:)?(\d{4}\.\d{4,5}(?:v\d+)?|[a-z-]+/\d{7})", re.I)
_BRIDGE_PW = os.environ.get("ZOTERO_BRIDGE_PASSWORD", "claude-bridge")


def parse_identifier(s: str) -> tuple[str, str]:
    """(idType, value) from a DOI / arXiv id / DOI-or-arXiv URL. idType ∈ Zotero's
    Translate.Search keys ('DOI', 'arXiv')."""
    s = s.strip()
    if m := _DOI_FIND.search(s):
        return "DOI", m.group(0).rstrip(").,;").lower()
    if m := _ARXIV_RE.search(s):
        return "arXiv", m.group(1)
    raise ValueError(f"unrecognized identifier: {s!r}")

# JS template: params arrive as one `ARGS` literal, result/errors go out via a temp
# file. Token-replace (not .format/f-string) so the JS bodies below stay plain — no
# brace-escaping. Each body is ordinary JS that reads `ARGS` and `return`s a value.
_WRAP = """\
const ARGS = __ARGS__;
async function __run(){ __BODY__ }
__run().then(
  r => Zotero.File.putContentsAsync(__OUT__, JSON.stringify(r === undefined ? null : r)),
  e => Zotero.File.putContentsAsync(__OUT__, JSON.stringify({__error: String(e), stack: (e && e.stack) || ""}))
);"""


def bridge_exec(body: str, args: dict | None = None, timeout=90):
    """Run async JS `body` inside Zotero with `ARGS` bound to *args*; return its value.

    `body` reads `ARGS.<key>` and `return`s a JSON-serializable value. Raises
    TimeoutError if Zotero isn't running / the password pref isn't set, RuntimeError
    on a JS exception.
    """
    import subprocess

    fd, out = tempfile.mkstemp(suffix=".json", prefix="zbridge_")
    os.close(fd); os.unlink(out)
    js = (_WRAP.replace("__ARGS__", json.dumps(args or {}))
               .replace("__OUT__", json.dumps(out))
               .replace("__BODY__", body))
    url = "zotero://ztoolkit-debug?password=" + urllib.parse.quote(_BRIDGE_PW) + "&run=" + urllib.parse.quote(js)
    subprocess.run(["open", url], check=True)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if os.path.exists(out):
            r = json.loads(open(out).read()); os.unlink(out)
            if isinstance(r, dict) and "__error" in r:
                raise RuntimeError(f"bridge JS error: {r['__error']}")
            return r
        time.sleep(0.4)
    raise TimeoutError("debug-bridge timed out — Zotero running and password pref set?")


_JS_ADD = """
const lib = Zotero.Libraries.userLibraryID;
let col = null, missing = false;
if (ARGS.collection) {
  col = Zotero.Collections.getByLibrary(lib, true).find(c => c.name === ARGS.collection);
  missing = !col;
}
const t = new Zotero.Translate.Search();
t.setIdentifier({ [ARGS.idtype]: ARGS.value });
const trs = await t.getTranslators();
if (!trs.length) return { items: [], };
const items = await t.translate({ libraryID: lib, collections: col ? [col.id] : [], saveAttachments: false });
for (const it of items) { try { await Zotero.Attachments.addAvailablePDF(it); } catch (e) {} }
return {
  collection: col ? col.name : null, collectionMissing: missing,
  items: items.map(it => ({ key: it.key, title: it.getField("title"),
                            itemType: it.itemType, hasPDF: it.getAttachments().length > 0 })),
};"""

_JS_ERASE = """
const lib = Zotero.Libraries.userLibraryID;
const erased = [], missing = [];
for (const k of ARGS.keys) {
  const it = await Zotero.Items.getByLibraryAndKeyAsync(lib, k);
  if (it) { await it.eraseTx(); erased.push(k); } else missing.push(k);
}
return { erased, missing };"""


def add_by_identifier(idtype: str, value: str, collection: str | None = None) -> dict:
    """Zotero's native Add-by-Identifier + Find Available PDF, filing into *collection*.

    PDF download is awaited, so the returned item already has it (unlike the
    connector). Returns {items:[{key,title,itemType,hasPDF}], collection, collectionMissing}.
    """
    return bridge_exec(_JS_ADD, {"idtype": idtype, "value": value, "collection": collection})


def erase_items(keys) -> dict:
    """Permanently delete items by key (bypasses trash). Returns {erased, missing}."""
    return bridge_exec(_JS_ERASE, {"keys": list(keys)})
