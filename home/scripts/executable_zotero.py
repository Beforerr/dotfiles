#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyzotero"]
# ///
"""Lookup a Zotero item by citekey, DOI, or partial title; print metadata + local PDF path."""

import sys
import os
import sqlite3
from pyzotero import zotero

def main():
    if len(sys.argv) < 2:
        print("Usage: zotero.py <citekey|DOI|partial title>", file=sys.stderr)
        sys.exit(1)

    query = sys.argv[1]

    zot = zotero.Zotero(0, "user", local=True)

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

    if not match:
        print(f"No item found for: {query}", file=sys.stderr)
        sys.exit(1)

    d = match["data"]
    creators = d.get("creators", [])
    authors = ", ".join(
        f"{c.get('lastName', '')} {c.get('firstName', '')}".strip()
        for c in creators
        if c.get("creatorType") == "author"
    )

    print(f"Title:   {d.get('title', '')}")
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
                print(f"PDF:     {pdf_path}")
            else:
                print(f"PDF:     (not downloaded; filename: {filename})")
            break

if __name__ == "__main__":
    main()
