"""Shared Zotero utilities used by zotero and extract_figures scripts."""
import re
import sqlite3
from pathlib import Path

_DOI_RE   = re.compile(r'^(https?://doi\.org/|doi:)?10\.\d{4,}/', re.I)
_ZOTERO_DB = Path.home() / "Zotero" / "zotero.sqlite"
ZOTERO_STORAGE = Path.home() / "Zotero" / "storage"


def _sqlite_connect():
    return sqlite3.connect(f"file:{_ZOTERO_DB}?mode=ro&immutable=1", uri=True)


def sqlite_lookup_citekey(citation_key) -> str | None:
    """Return the Zotero item key for *citation_key* via SQLite, or None."""
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
    """Return the Zotero item key for *doi* via SQLite, or None."""
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


DEFAULT_ATTACHMENT_TYPES = ("application/pdf", "application/epub+zip")


def find_attachment(
    children: list,
    content_types = DEFAULT_ATTACHMENT_TYPES,
) -> tuple[Path | None, str | None]:
    """Return (path, filename) for the first matching attachment child.

    Children are scanned in *content_types* order, so earlier types are
    preferred over later ones (e.g. PDF over EPUB by default).

    path     — local Path if the file exists, else None.
    filename — attachment filename if a matching child exists, else None.
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
