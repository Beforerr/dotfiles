#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyzotero", "pytest"]
# ///
"""Lookup a Zotero item by citekey, DOI, or partial title; print metadata + local PDF path."""

import sys
import os
from pyzotero import zotero
from zotero_lib import lookup, find_local_pdf

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
    pdf, filename = find_local_pdf(children)
    if pdf:
        print(f"PDF:     {str(pdf).replace(os.path.expanduser('~'), '~', 1)}")
    elif filename:
        print(f"PDF:     (not downloaded; filename: {filename})")


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
