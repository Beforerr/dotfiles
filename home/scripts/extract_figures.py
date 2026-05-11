#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# dependencies = ["pymupdf", "pyzotero", "PyYAML"]
# ///
"""Extract figures from a Zotero PDF by citation key.

Usage:
    uv run extract_figures.py <key> [output_dir] [--figures SPEC] [--overwrite]
    uv run extract_figures.py artemyevIonMotionCurrent2013
    uv run extract_figures.py artemyevIonMotionCurrent2013 --figures "1,3,5-7,A1-A3"

Requires Zotero to be running with Better BibTeX installed.

Output folder:
  README.md  — YAML frontmatter (auto-merged) + Markdown body (user-editable)
  paper.pdf  — symlink to the Zotero-managed PDF
  fig*.png   — extracted figures (raster + vector)

README update policy
  • First run: file is created with full frontmatter + figure sections.
  • Later runs: only EMPTY frontmatter fields are filled in; existing values and
    the entire Markdown body are left untouched.
  • Use --overwrite to fully regenerate the file.
"""

import argparse
import re
import sys
from pathlib import Path
from zotero_lib import lookup, find_local_pdf

CAPTION_RE = re.compile(r"^(Fig\.?\s*[A-Z]?\d|Figure\s*[A-Z]?\d)", re.I)
CAP_NUM_RE = re.compile(r"(?:Fig\.?|Figure)\s*([A-Z]?\d+)", re.I)

MIN_AREA_PT2 = 5000
MIN_SIZE_KB  = 8


# ── Zotero lookup ─────────────────────────────────────────────────────────────

def find_pdf(query: str) -> tuple[Path, dict]:
    """Resolve a query (citekey, DOI, or partial title) to its local PDF path + metadata."""
    from pyzotero import zotero as pyzotero
    zot = pyzotero.Zotero(0, "user", local=True)
    item = lookup(zot, query)
    if item is None:
        sys.exit(f"'{query}' not found in Zotero.")
    children = zot.children(item["key"])
    pdf_path, _ = find_local_pdf(children)
    if pdf_path is None:
        sys.exit(f"No local PDF found for '{query}' (item {item['key']}).")
    return pdf_path, _meta_from_item(item)


def _meta_from_item(item: dict) -> dict:
    d = item["data"]
    creators = d.get("creators", [])
    authors = [f"{c.get('firstName','')} {c.get('lastName','')}".strip()
               for c in creators if c.get("creatorType") == "author"]
    year = d.get("date", "")[:4] if d.get("date") else ""
    return {
        "citation_key": d.get("citationKey", ""),
        "title":        d.get("title", ""),
        "authors":      authors,
        "year":         year,
        "journal":      d.get("publicationTitle", d.get("bookTitle", "")),
        "doi":          d.get("DOI", ""),
        "url":          d.get("url", ""),
        "zotero":       f"zotero://select/library/items/{item['key']}",
        "pdf":          "paper.pdf",
    }




# ── Figure extraction ─────────────────────────────────────────────────────────

def _clean_caption(text):
    """Join soft-hyphenated line breaks, normalize whitespace."""
    # Soft hyphen at line break: "pan-\nels" → "panels", "3-\nD" → "3-D"
    text = re.sub(r"([a-z])-\n([a-z])", r"\1\2", text)   # lowercase-lowercase → join
    text = re.sub(r"-\n(\S)", r"-\1", text)                # other hyphens → keep dash
    text = text.replace("\n", " ")
    return re.sub(r" {2,}", " ", text).strip()


def _text_blocks(page) -> list[tuple]:
    """Return plain (x0,y0,x1,y1,text) tuples using the simple blocks API.

    This gives clean, fully-joined text unlike the dict API which fragments
    it into spans and adds spurious spaces.
    """
    return [
        (b[0], b[1], b[2], b[3], b[4])
        for b in page.get_text("blocks")
        if b[6] == 0   # type 0 = text
    ]


def _find_caption_near(img_rect, text_blocks, fitz, gap: float = 120) -> str:
    """Find and return the full caption text within *gap* pt above or below the image.

    Collects the first matching "Fig. X" block plus any immediately-following
    continuation blocks (within 20 pt, same column, not starting a new caption).
    """
    below_y = (img_rect.y1, img_rect.y1 + gap)
    above_y = (img_rect.y0 - gap, img_rect.y0)
    col_x   = (img_rect.x0 - 20, img_rect.x1 + 20)

    def in_col(b):
        return b[0] <= col_x[1] and b[2] >= col_x[0]

    def in_zone(b, zone):
        return b[1] >= zone[0] and b[1] <= zone[1]

    for zone in (below_y, above_y):
        sorted_blocks = sorted(
            [b for b in text_blocks if in_zone(b, zone) and in_col(b)],
            key=lambda b: b[1]
        )
        for i, b in enumerate(sorted_blocks):
            if not CAPTION_RE.match(b[4].lstrip()):
                continue
            # Found the caption start — collect continuations
            parts = [b[4]]
            last_y1 = b[3]
            for cont in sorted_blocks[i + 1:]:
                if cont[1] - last_y1 > 20:
                    break
                if CAPTION_RE.match(cont[4].lstrip()):
                    break
                parts.append(cont[4])
                last_y1 = cont[3]
            return _clean_caption("".join(parts))
    return ""


def _scan_page_captions(page, fitz) -> list[dict]:
    """All figure captions on a page → [{label, text, rect}].

    Uses the simple blocks API for clean text, but also records the Rect
    (from dict API) for spatial queries.
    """
    # dict API for accurate bboxes
    dict_blocks = page.get_text("dict")["blocks"]
    # simple API for clean text, keyed by rounded y0 for matching
    plain = {round(b[1]): b[4]
             for b in page.get_text("blocks") if b[6] == 0}

    out = []
    for b in dict_blocks:
        if b["type"] != 0:
            continue
        rect = fitz.Rect(b["bbox"])
        # Check first line using dict spans (for bbox accuracy)
        first_line = " ".join(s["text"] for s in b["lines"][0].get("spans", [])).strip() if b["lines"] else ""
        if not CAPTION_RE.match(first_line):
            continue
        # Retrieve clean text from plain-blocks by matching y0
        clean_text = plain.get(round(b["bbox"][1]), "") or ""
        m = CAP_NUM_RE.search(clean_text or first_line)
        out.append({
            "label": m.group(1) if m else "?",
            "text":  _clean_caption(clean_text) if clean_text else _clean_caption(first_line),
            "rect":  rect,
        })
    return out


def _figure_rect_above(page, cap_rect, fitz, margin: float = 10):
    col_x0, col_x1 = cap_rect.x0 - margin, cap_rect.x1 + margin
    tops = [fitz.Rect(b["bbox"]).y1
            for b in page.get_text("dict")["blocks"]
            if b["type"] == 0
            and fitz.Rect(b["bbox"]).y1 < cap_rect.y0
            and fitz.Rect(b["bbox"]).y0 >= 60
            and fitz.Rect(b["bbox"]).x0 <= col_x1
            and fitz.Rect(b["bbox"]).x1 >= col_x0]
    y_top = (max(tops) if tops else 60.0) + 4
    return fitz.Rect(col_x0, y_top, col_x1, cap_rect.y0 - 4)


def extract_figures(
    pdf_path: Path,
    output_dir: Path,
    min_size_kb: int = MIN_SIZE_KB,
    selection: set[str] | None = None,
) -> list[dict]:
    """Extract all figures. Returns [{path, label, caption, page}]."""
    try:
        import fitz
    except ImportError:
        sys.exit("PyMuPDF not found. Install with: uv pip install pymupdf")

    output_dir.mkdir(parents=True, exist_ok=True)
    doc = fitz.open(pdf_path)
    results: list[dict] = []
    saved: set[str] = set()
    raster_n = 0

    def _record(out: Path, page_num, label, caption) -> bool:
        kb = out.stat().st_size / 1024
        if kb < min_size_kb:
            out.unlink()
            return False
        results.append({"path": out, "label": label, "caption": caption, "page": page_num})
        return True

    # Pass 1: raster — render at native DPI via zoom so PDF transforms (including
    # y-flips) are applied correctly. Raw b["image"] bytes skip the transform.
    for page_num, page in enumerate(doc, start=1):
        tblocks   = _text_blocks(page)
        imgblocks = page.get_text("dict", flags=fitz.TEXT_PRESERVE_IMAGES)["blocks"]
        for b in imgblocks:
            if b["type"] != 1:
                continue
            rect = fitz.Rect(b["bbox"])
            if rect.width * rect.height < MIN_AREA_PT2:
                continue
            if b["width"] * b["height"] < 10000:
                continue

            caption = _find_caption_near(rect, tblocks, fitz)
            m = CAP_NUM_RE.search(caption) if caption else None
            label = m.group(1) if m else None
            if label and label in saved:
                continue
            # Drop uncaptioned rasters — decorative elements, logos, formula images
            if not caption:
                continue
            if selection and (label is None or label.upper() not in selection):
                continue

            # Zoom to match native image resolution (applies PDF transform → correct orientation)
            zoom = b["width"] / rect.width
            pix  = page.get_pixmap(matrix=fitz.Matrix(zoom, zoom), clip=rect)

            raster_n += 1
            fname = f"fig{label}_p{page_num}.png"
            out   = output_dir / fname
            pix.save(str(out))

            if not _record(out, page_num, label, caption):
                raster_n -= 1; continue
            saved.add(label)
            preview = (caption[:80] + "…") if len(caption) > 80 else caption
            print(f"  [raster] p{page_num}: {fname} [{pix.width}×{pix.height}px] — {preview}")

    # Pass 2: vector — render at 3× (216 DPI) for sharp output
    for page_num, page in enumerate(doc, start=1):
        for cap in _scan_page_captions(page, fitz):
            label = cap["label"]
            if label in saved:
                continue
            if selection and label.upper() not in selection:
                continue
            fig_rect = _figure_rect_above(page, cap["rect"], fitz)
            if fig_rect.is_empty or fig_rect.height < 20:
                continue
            pix = page.get_pixmap(matrix=fitz.Matrix(3, 3), clip=fig_rect & page.rect)
            if pix.width * pix.height < 10000:
                continue
            fname = f"fig{label}_p{page_num}.png"
            out   = output_dir / fname
            pix.save(str(out))
            kb = out.stat().st_size / 1024
            if kb < min_size_kb:
                out.unlink(); continue
            saved.add(label)
            results.append({"path": out, "label": label, "caption": cap["text"], "page": page_num})
            preview = (cap["text"][:90] + "…") if len(cap["text"]) > 90 else cap["text"]
            print(f"  [vector] p{page_num}: {fname} — {preview}")

    doc.close()
    results.sort(key=lambda r: r["path"].name)
    return results


def _parse_fig_selection(spec: str) -> set[str] | None:
    """Parse a figure selection spec into a set of label strings.

    Syntax (case-insensitive, whitespace-tolerant):
      1          → {"1"}
      1,3,5      → {"1","3","5"}
      5-7        → {"5","6","7"}
      A1-A3      → {"A1","A2","A3"}
      1,3,A1-A3  → {"1","3","A1","A2","A3"}

    Returns None when *spec* is empty (= keep all figures).
    Ranges across different letter prefixes (e.g. A1-B2) are unsupported
    and raise ValueError.
    """
    if not spec:
        return None
    result: set[str] = set()
    for part in re.split(r",\s*", spec.strip()):
        part = part.strip().upper()
        m = re.fullmatch(r"([A-Z]*)(\d+)-([A-Z]*)(\d+)", part)
        if m:
            pfx1, n1, pfx2, n2 = m.group(1), int(m.group(2)), m.group(3), int(m.group(4))
            if pfx1 != pfx2:
                raise ValueError(
                    f"Range '{part}' mixes prefixes '{pfx1}' and '{pfx2}'. "
                    "Use separate entries instead, e.g. A3,B1."
                )
            for n in range(n1, n2 + 1):
                result.add(f"{pfx1}{n}")
        elif re.fullmatch(r"[A-Z]*\d+", part):
            result.add(part)
        else:
            raise ValueError(f"Cannot parse figure spec '{part}'")
    return result


def _sort_key(r: dict) -> tuple:
    m = re.match(r"^([A-Za-z]*)(\d+)$", r["label"])
    return (m.group(1), int(m.group(2))) if m else (r["label"], 0)


# ── YAML frontmatter merge ────────────────────────────────────────────────────

_FM_RE = re.compile(r"^---\n(.*?\n)---\n", re.DOTALL)


def _parse_readme(text: str) -> tuple[dict, str]:
    """Split README into (frontmatter_dict, body). Body includes everything after ---."""
    import yaml
    m = _FM_RE.match(text)
    if m:
        fm = yaml.safe_load(m.group(1)) or {}
        body = text[m.end():]
    else:
        fm, body = {}, text
    return fm, body


def _merge_fm(existing: dict, new: dict) -> dict:
    """Return merged frontmatter: existing non-empty values win; new fills empty/missing fields."""
    merged = dict(existing)
    for key, new_val in new.items():
        old_val = existing.get(key)
        # Empty = None, "", [], {}
        is_empty = old_val is None or old_val == "" or old_val == [] or old_val == {}
        if is_empty:
            merged[key] = new_val
    return merged


def _render_fm(fm: dict) -> str:
    import yaml
    return "---\n" + yaml.dump(fm, allow_unicode=True, sort_keys=False, width=120) + "---\n"


# ── README write / update ─────────────────────────────────────────────────────

def _labeled(figures: list[dict]) -> list[dict]:
    return sorted(
        [r for r in figures if not r["label"].startswith("fig_r")],
        key=_sort_key,
    )


def write_readme(
    output_dir: Path,
    pdf_path: Path,
    figures: list[dict],
    meta: dict,
    overwrite: bool = False,
) -> tuple[Path, str]:
    """Create or update README.md with YAML frontmatter + Markdown body.

    Returns (path, action): 'created' | 'updated' | 'skipped'.
    On update: only empty frontmatter fields are filled; the body is untouched.
    """
    import yaml

    readme = output_dir / "README.md"

    # Refresh PDF symlink
    link = output_dir / "paper.pdf"
    if link.exists() or link.is_symlink():
        link.unlink()
    link.symlink_to(pdf_path)

    # Frontmatter = paper metadata only (no figures list)
    new_fm = {k: v for k, v in meta.items() if v not in ("", [], None)}

    if readme.exists() and not overwrite:
        existing_text = readme.read_text(encoding="utf-8")
        existing_fm, body = _parse_readme(existing_text)
        merged = _merge_fm(existing_fm, new_fm)
        if merged == existing_fm:
            return readme, "skipped"
        readme.write_text(_render_fm(merged) + body, encoding="utf-8")
        return readme, "updated"

    # First run — build full file
    title      = meta.get("title", "Paper")
    zotero_url = meta.get("zotero", "")
    pdf_link    = "[Open PDF](paper.pdf)"
    zotero_link = f"[Open in Zotero]({zotero_url})" if zotero_url else ""
    links       = " | ".join(filter(None, [pdf_link, zotero_link]))

    body_lines = [
        f"\n# {title}\n",
        f"{links}\n",
        "## Figures\n",
    ]
    for r in _labeled(figures):
        caption = r["caption"] or f"Figure {r['label']}"
        body_lines.append(f"![{caption}]({r['path'].name})\n")

    readme.write_text(_render_fm(new_fm) + "\n".join(body_lines), encoding="utf-8")
    return readme, "created"


# ── CLI ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Extract figures from a Zotero PDF by citation key"
    )
    parser.add_argument("citation_key")
    parser.add_argument("output_dir", nargs="?",
                        help="Output directory (default: ./sources/papers/<key>)")
    parser.add_argument("--min-kb", type=int, default=MIN_SIZE_KB)
    parser.add_argument("--overwrite", action="store_true",
                        help="Fully regenerate README.md even if it already exists")
    parser.add_argument("--figures", metavar="SPEC",
                        help="Figures to extract, e.g. '1,3,5-7,A1-A3' (default: all)")
    args = parser.parse_args()

    key     = args.citation_key
    out_dir = Path(args.output_dir) if args.output_dir else Path("sources/papers") / key

    try:
        selection = _parse_fig_selection(args.figures or "")
    except ValueError as e:
        sys.exit(f"Invalid --figures spec: {e}")

    print(f"Citation key: {key}")
    pdf_path, meta = find_pdf(key)
    print(f"PDF: {pdf_path}")
    if meta.get("title"):
        print(f"Title: {meta['title']}")
    if selection:
        print(f"Figures: {', '.join(sorted(selection, key=lambda s: (re.match(r'[A-Z]*', s).group(), int(re.search(r'\d+', s).group()))))}")
    print(f"Output: {out_dir}\n")

    figures  = extract_figures(pdf_path, out_dir, min_size_kb=args.min_kb, selection=selection)
    readme, action = write_readme(out_dir, pdf_path, figures, meta, overwrite=args.overwrite)

    action_msg = {
        "created": "created",
        "updated": "updated (frontmatter merged, body preserved)",
        "skipped": "unchanged (no new fields to fill)",
    }[action]
    print(f"\nREADME: {readme}  [{action_msg}]")
    print(f"Done: {len(figures)} figure(s) → {out_dir}/")


if __name__ == "__main__":
    main()
