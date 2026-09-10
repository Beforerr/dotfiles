#!/usr/bin/env python3
"""Literature lookup via OpenAlex (no key). One line per work:
year | cites | DOI | first author | title

  openalex.py search "whistler waves solar wind" [-n 10] [--since 2020] [--sort cites]
  openalex.py get <DOI|W-id>... [--abstract]        # metadata; --abstract prints it
  openalex.py citing <DOI|W-id> [-n 25]             # works citing it, most cited first
  openalex.py refs <DOI|W-id>                       # its reference list

DOIs feed straight into `zotero.py add <DOI> -c Collection`.
Set OPENALEX_EMAIL for the polite (faster) pool.
"""
import argparse
import json
import os
import sys
import urllib.parse
import urllib.request

API = "https://api.openalex.org"
SELECT = "id,doi,title,publication_year,cited_by_count,authorships,referenced_works,abstract_inverted_index"


def call(path, **params):
    if m := os.environ.get("OPENALEX_EMAIL"):
        params["mailto"] = m
    url = f"{API}{path}?{urllib.parse.urlencode(params)}"
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        sys.exit(f"{url}\nHTTP {e.code}: {e.read()[:300].decode()}")


def wid(ref):
    """DOI or W-id -> path segment OpenAlex accepts."""
    ref = ref.strip()
    if ref.upper().startswith("W") and ref[1:].isdigit():
        return ref.upper()
    ref = ref.removeprefix("https://doi.org/").removeprefix("doi:")
    return f"https://doi.org/{ref}"


def line(w):
    a = w.get("authorships") or []
    first = a[0]["author"]["display_name"].split()[-1] if a else "?"
    if len(a) > 1:
        first += "+"
    doi = (w.get("doi") or "").removeprefix("https://doi.org/") or w["id"].rsplit("/", 1)[-1]
    return f"{w.get('publication_year')} | {w.get('cited_by_count', 0):>5} | {doi} | {first} | {(w.get('title') or '')[:110]}"


def abstract(w):
    inv = w.get("abstract_inverted_index") or {}
    words = sorted((p, t) for t, ps in inv.items() for p in ps)
    return " ".join(t for _, t in words)


def works(**params):
    return call("/works", select=SELECT, **params).get("results", [])


def cmd_search(a):
    p = {"search": a.query, "per_page": a.n}
    if a.since:
        p["filter"] = f"from_publication_date:{a.since}-01-01"
    if a.sort == "cites":
        p["sort"] = "cited_by_count:desc"
    for w in works(**p):
        print(line(w))


def cmd_get(a):
    for ref in a.ids:
        w = call(f"/works/{wid(ref)}", select=SELECT)
        print(line(w))
        if a.abstract:
            print("   ", abstract(w)[:2000])


def cmd_citing(a):
    w = call(f"/works/{wid(a.id)}", select="id")
    for x in works(filter=f"cites:{w['id'].rsplit('/', 1)[-1]}", sort="cited_by_count:desc", per_page=a.n):
        print(line(x))


def cmd_refs(a):
    w = call(f"/works/{wid(a.id)}", select="referenced_works")
    ids = [r.rsplit("/", 1)[-1] for r in w.get("referenced_works") or []]
    for i in range(0, len(ids), 50):
        for x in works(filter=f"openalex:{'|'.join(ids[i:i+50])}", per_page=50):
            print(line(x))


p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
sub = p.add_subparsers(required=True)
s = sub.add_parser("search"); s.add_argument("query"); s.add_argument("-n", type=int, default=10)
s.add_argument("--since", type=int); s.add_argument("--sort", choices=["relevance", "cites"], default="relevance")
s.set_defaults(func=cmd_search)
s = sub.add_parser("get"); s.add_argument("ids", nargs="+"); s.add_argument("--abstract", action="store_true")
s.set_defaults(func=cmd_get)
s = sub.add_parser("citing"); s.add_argument("id"); s.add_argument("-n", type=int, default=25)
s.set_defaults(func=cmd_citing)
s = sub.add_parser("refs"); s.add_argument("id"); s.set_defaults(func=cmd_refs)
a = p.parse_args(); a.func(a)
