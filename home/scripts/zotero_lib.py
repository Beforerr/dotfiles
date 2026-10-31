"""Zotero utilities"""
from __future__ import annotations

import json
import re
import shutil
import sqlite3
import subprocess
import tempfile
import urllib.error
import urllib.request
import weakref
from pathlib import Path

_DOI_RE   = re.compile(r'^(https?://doi\.org/|doi:)?10\.\d{4,}/', re.I)
_ZOTERO_DB = Path.home() / "Zotero" / "zotero.sqlite"
ZOTERO_STORAGE = Path.home() / "Zotero" / "storage"


class _Connection(sqlite3.Connection):
    """Subclass only to make connections weak-referenceable."""


def _sqlite_connect():
    # Zotero holds an exclusive lock in WAL mode. So query an APFS clone of db+WAL
    d = tempfile.mkdtemp(prefix="zotero-db-")
    copy = f"{d}/{_ZOTERO_DB.name}"
    for suffix in ("", "-wal"):
        if Path(f"{_ZOTERO_DB}{suffix}").exists():
            subprocess.run(["cp", "-c", f"{_ZOTERO_DB}{suffix}", f"{copy}{suffix}"], check=True)
    con = sqlite3.connect(f"file:{copy}?mode=ro", uri=True, factory=_Connection)
    weakref.finalize(con, shutil.rmtree, d, ignore_errors=True)
    return con


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
            "AND LOWER(itemDataValues.value) = LOWER(?) "
            "AND items.itemID NOT IN (SELECT itemID FROM deletedItems)",
            (doi,),
        ).fetchone()
        con.close()
        return row[0] if row else None
    except Exception:
        return None


def fulltext_grep(pattern: str, max_hits=20, snippet=True) -> list[dict]:
    """Search Zotero's own full-text index (`storage/<att>/.zotero-ft-cache`).

    Only PDFs Zotero has indexed are covered, but this never touches the PDFs:
    storage lives on Box files-on-demand, so tools like rga would download the
    whole library. Returns [{citekey, title, key, snippet}] per parent item.
    """
    import subprocess
    rg = ["rg", "-il", "--no-ignore", "--hidden", "-g", ".zotero-ft-cache", pattern, str(ZOTERO_STORAGE)]
    files = subprocess.run(rg, capture_output=True, text=True).stdout.split()
    con = _sqlite_connect()
    out, seen = [], set()
    for f in files:
        att = Path(f).parent.name
        row = con.execute(
            "SELECT p.key, cv.value, tv.value FROM items a "
            "JOIN itemAttachments ia ON ia.itemID = a.itemID "
            "JOIN items p ON p.itemID = ia.parentItemID "
            "LEFT JOIN itemData cd ON cd.itemID = p.itemID AND cd.fieldID = "
            "  (SELECT fieldID FROM fields WHERE fieldName = 'citationKey') "
            "LEFT JOIN itemDataValues cv ON cv.valueID = cd.valueID "
            "LEFT JOIN itemData td ON td.itemID = p.itemID AND td.fieldID = "
            "  (SELECT fieldID FROM fields WHERE fieldName = 'title') "
            "LEFT JOIN itemDataValues tv ON tv.valueID = td.valueID "
            "WHERE a.key = ?", (att,)).fetchone()
        if not row or row[0] in seen:
            continue
        seen.add(row[0])
        snip = ""
        if snippet:
            snip = subprocess.run(["rg", "-io", "-m1", f".{{0,70}}(?:{pattern}).{{0,70}}", f],
                                  capture_output=True, text=True).stdout.strip().replace("\n", " ")
        out.append({"key": row[0], "citekey": row[1], "title": row[2], "snippet": snip})
        if len(out) >= max_hits:
            break
    con.close()
    return out


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


# Debug bridge (plugin debug-bridge@iris-advies.com, installed and configured by
# chezmoi): POST /debug-bridge/execute runs the body as async JS with `Zotero` in
# scope. The only headless route to native Add by Identifier, Find Available PDF and
# item deletion: the connector saves only what you hand it, and the local /api is
# read-only (DELETE → 501).

_DOI_FIND = re.compile(r"10\.\d{4,9}/[^\s\"<>]+")
_ARXIV_RE = re.compile(r"(?:arxiv:)?(\d{4}\.\d{4,5}(?:v\d+)?|[a-z-]+/\d{7})", re.I)
_BRIDGE_URL = "http://127.0.0.1:23119/debug-bridge/execute"
_ZOTERO_USER_JS = Path.home() / "Library/Application Support/Zotero/Profiles/default/user.js"


def parse_identifier(s: str) -> tuple[str, str]:
    """(idType, value) from a DOI / arXiv id / DOI-or-arXiv URL. idType ∈ Zotero's
    Translate.Search keys ('DOI', 'arXiv')."""
    s = s.strip()
    if m := _DOI_FIND.search(s):
        return "DOI", m.group(0).rstrip(").,;").lower()
    if m := _ARXIV_RE.search(s):
        return "arXiv", m.group(1)
    raise ValueError(f"unrecognized identifier: {s!r}")


def _bridge_token() -> str:
    m = re.search(r'user_pref\("extensions\.zotero\.debug-bridge\.token",\s*"([^"]*)"\)',
                  _ZOTERO_USER_JS.read_text())
    if not m:
        raise RuntimeError(f"debug-bridge token pref missing from {_ZOTERO_USER_JS}")
    return m.group(1)


def bridge_exec(body: str, args: dict | None = None, timeout=90):
    """Run async JS *body* inside Zotero with `ARGS` = *args*; return its JSON result."""
    req = urllib.request.Request(
        _BRIDGE_URL,
        data=f"const ARGS = {json.dumps(args or {})};\n{body}".encode(),
        headers={"Content-Type": "text/plain", "Authorization": f"Bearer {_bridge_token()}"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"debug-bridge HTTP {e.code}: {e.read().decode()}") from None


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

_JS_FILE = """
const lib = Zotero.Libraries.userLibraryID;
const col = Zotero.Collections.getByLibrary(lib, true).find(c => c.name === ARGS.collection);
if (!col) return { collection: ARGS.collection, collectionMissing: true, filed: [], missing: ARGS.keys };
const filed = [], missing = [];
for (const k of ARGS.keys) {
  const it = await Zotero.Items.getByLibraryAndKeyAsync(lib, k);
  if (!it) { missing.push(k); continue; }
  it.addToCollection(col.id);
  await it.saveTx();
  filed.push(k);
}
return { collection: col.name, collectionMissing: false, filed, missing };"""

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


def file_into_collection(keys, collection: str) -> dict:
    """File existing items (by key) into *collection* by name, no duplication.

    Returns {collection, collectionMissing, filed, missing}.
    """
    return bridge_exec(_JS_FILE, {"keys": list(keys), "collection": collection})


def erase_items(keys) -> dict:
    """Permanently delete items by key (bypasses trash). Returns {erased, missing}."""
    return bridge_exec(_JS_ERASE, {"keys": list(keys)})
