#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyzotero", "pytest"]
# ///
"""Zotero CLI: look up items, `add` a paper by identifier, or `rm` items.

  zotero.py <citekey|DOI|title> ...          # look up + print metadata/PDF path
  zotero.py add <doi|arXiv|url> ... -c EMIC_ERG  # native Add-by-Identifier + PDF, file into collection
  zotero.py rm <itemKey> ...                 # permanently delete items

`add`/`rm` drive Zotero's native machinery through the debug bridge (see zotero_lib);
Zotero must be running with the debug-bridge password pref set.
"""

import sys
import os
from pyzotero import zotero
from zotero_lib import (lookup, find_attachment, parse_identifier,
                        sqlite_lookup_doi, add_by_identifier, erase_items)

def print_item(zot, match, query):
    d = match["data"]
    creators = d.get("creators", [])
    authors = ", ".join(
        f"{c.get('lastName', '')} {c.get('firstName', '')}".strip()
        for c in creators
        if c.get("creatorType") == "author"
    )

    fields = [
        ("Title",   d.get("title", "")),
        ("Citekey", d.get("citationKey", "")),
        ("Authors", authors),
        ("Journal", d.get("publicationTitle", d.get("bookTitle", ""))),
        ("Date",    d.get("date", "")),
        ("DOI",     d.get("DOI", "")),
        ("URL",     d.get("url", "")),
    ]
    for label, value in fields:
        if value:
            print(f"{label + ':':<8} {value}")

    abstract = d.get("abstractNote", "")
    if abstract:
        abstract = abstract.replace("\n", "\\n")
        print(f"Abstract: {abstract}")

    # Find local attachment
    children = zot.children(match["key"])
    path, filename = find_attachment(children)
    if path:
        print(f"File:    {str(path).replace(os.path.expanduser('~'), '~', 1)}")
    elif filename:
        print(f"File:    (not downloaded; filename: {filename})")


def add(identifier, collection=None, force=False) -> dict:
    """Add by DOI/arXiv id via Zotero's native Add-by-Identifier (+ Find Available PDF)."""
    idtype, value = parse_identifier(identifier)
    if not force and idtype == "DOI" and (existing := sqlite_lookup_doi(value)):
        return {"status": "exists", "key": existing, "identifier": value}
    r = add_by_identifier(idtype, value, collection)
    return {"status": "saved", "idtype": idtype, "identifier": value, **r}


def cmd_add(argv):
    import argparse
    import json
    p = argparse.ArgumentParser(prog="zotero.py add")
    p.add_argument("identifier", nargs="+")
    p.add_argument("-c", "--collection")
    p.add_argument("--force", action="store_true")
    a = p.parse_args(argv)
    results = [add(i, a.collection, a.force) for i in a.identifier]
    print(json.dumps(results if len(results) > 1 else results[0], indent=2))


def cmd_rm(argv):
    import argparse
    p = argparse.ArgumentParser(prog="zotero.py rm", description="Permanently delete items by key.")
    p.add_argument("keys", nargs="+", help="Zotero item keys (8 chars)")
    a = p.parse_args(argv)
    r = erase_items(a.keys)
    print(f"erased {len(r['erased'])}: {', '.join(r['erased']) or '-'}")
    if r["missing"]:
        print(f"not found: {', '.join(r['missing'])}")


def query_item(zot, query, seen, first):
    """Look up + print one query. Returns updated `first` flag; skips dupes via `seen`."""
    match = lookup(zot, query)
    if match is None:
        print(f"No item found for: {query}", file=sys.stderr)
        return first
    key = match["key"]
    if key in seen:
        return first
    seen.add(key)
    if not first:
        print()
    print_item(zot, match, query)
    return False


def cmd_query(argv):
    if not argv:
        print("Usage: zotero.py <citekey|DOI|partial title> [...]", file=sys.stderr)
        sys.exit(1)

    zot = zotero.Zotero(0, "user", local=True)

    seen = set()
    first = True
    for query in argv:
        first = query_item(zot, query, seen, first)


_zot = None

def _get_zot():
    global _zot
    if _zot is None:
        _zot = zotero.Zotero(0, "user", local=True)
    return _zot

def test_citekey():
    m = lookup(_get_zot(), "zhangExploringOuterRadiation2025")
    assert m is not None
    assert m["data"]["citationKey"] == "zhangExploringOuterRadiation2025"

def test_doi():
    m = lookup(_get_zot(), "10.1029/2025GL116966")
    assert m is not None
    assert m["data"]["DOI"] == "10.1029/2025GL116966"

def test_doi_url_prefix():
    m = lookup(_get_zot(), "https://doi.org/10.1029/2025GL116966")
    assert m is not None
    assert m["data"]["DOI"] == "10.1029/2025GL116966"

def test_partial_title():
    m = lookup(_get_zot(), "Outer Radiation Belt")
    assert m is not None
    assert "outer radiation belt" in m["data"]["title"].lower()

def test_dedup():
    m1 = lookup(_get_zot(), "zhangExploringOuterRadiation2025")
    m2 = lookup(_get_zot(), "10.1029/2025GL116966")
    assert m1["key"] == m2["key"]

def test_not_found():
    assert lookup(_get_zot(), "thisDoesNotExist99999") is None


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        import pytest
        sys.exit(pytest.main([__file__, "-v"]))
    elif len(sys.argv) > 1 and sys.argv[1] == "add":
        cmd_add(sys.argv[2:])
    elif len(sys.argv) > 1 and sys.argv[1] == "rm":
        cmd_rm(sys.argv[2:])
    else:
        cmd_query(sys.argv[1:])
