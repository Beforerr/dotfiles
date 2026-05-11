#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyzotero", "pytest"]
# ///
"""Lookup a Zotero item by citekey, DOI, or partial title; print metadata + local PDF path."""

import sys
import os
import sqlite3
from pyzotero import zotero

def lookup(zot, query):
    match = None

    # 1. Exact citekey
    items = zot.items(q=query, limit=20)
    match = next(
        (i for i in items if i["data"].get("citationKey") == query), None
    )

    # 2. DOI — Zotero API doesn't index DOI fields, query SQLite directly
    if not match:
        doi = query.removeprefix("https://doi.org/").removeprefix("doi:")
        db_path = os.path.expanduser("~/Zotero/zotero.sqlite")
        try:
            con = sqlite3.connect(f"file:{db_path}?mode=ro&immutable=1", uri=True)
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
            if row:
                match = zot.item(row[0])
        except Exception:
            pass

    # 3. Partial title (case-insensitive substring)
    if not match:
        title_items = zot.items(q=query, limit=20)
        ql = query.lower()
        match = next(
            (i for i in title_items if ql in i["data"].get("title", "").lower()),
            None,
        )

    return match


def print_item(zot, match, query):
    d = match["data"]
    creators = d.get("creators", [])
    authors = ", ".join(
        f"{c.get('lastName', '')} {c.get('firstName', '')}".strip()
        for c in creators
        if c.get("creatorType") == "author"
    )

    print(f"Title:   {d.get('title', '')}")
    print(f"Citekey: {d.get('citationKey', '')}")
    print(f"Authors: {authors}")
    print(f"Journal: {d.get('publicationTitle', d.get('bookTitle', ''))}")
    print(f"Date:    {d.get('date', '')}")
    print(f"DOI:     {d.get('DOI', '')}")
    print(f"URL:     {d.get('url', '')}")

    abstract = d.get("abstractNote", "")
    if abstract:
        abstract = abstract.replace("\n", "\\n")
        print(f"Abstract: {abstract}")

    # Find local PDF
    children = zot.children(match["key"])
    storage_base = os.path.expanduser("~/Zotero/storage")
    for child in children:
        cd = child["data"]
        if cd.get("contentType") == "application/pdf":
            att_key = cd["key"]
            filename = cd.get("filename", "")
            pdf_path = os.path.join(storage_base, att_key, filename)
            if os.path.exists(pdf_path):
                print(f"PDF:     {pdf_path.replace(os.path.expanduser('~'), '~', 1)}")
            else:
                print(f"PDF:     (not downloaded; filename: {filename})")
            break


def main():
    if len(sys.argv) < 2:
        print("Usage: zotero.py <citekey|DOI|partial title> [...]", file=sys.stderr)
        sys.exit(1)

    zot = zotero.Zotero(0, "user", local=True)
    queries = sys.argv[1:]

    seen = set()
    first = True
    for query in queries:
        match = lookup(zot, query)
        if match is None:
            print(f"No item found for: {query}", file=sys.stderr)
            continue
        key = match["key"]
        if key in seen:
            continue
        seen.add(key)
        if not first:
            print()
        first = False
        print_item(zot, match, query)


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
    assert "Outer Radiation Belt" in m["data"]["title"]

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
    else:
        main()
