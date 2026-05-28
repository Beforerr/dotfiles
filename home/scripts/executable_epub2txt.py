#!/usr/bin/env python3
"""
Convert EPUB to structured Markdown, preserving heading hierarchy for progressive disclosure.

Usage:
    epub2txt.py book.epub                         # output next to epub
    epub2txt.py book.epub -o out.md               # custom output
    epub2txt.py book.epub --preset lonelyplanet   # publisher-specific cleaning
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import zipfile
import tempfile
from dataclasses import dataclass, field
from html.parser import HTMLParser
from typing import Callable
from xml.etree import ElementTree as ET


# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

Chunk = tuple[str, str]   # (tag, text) where tag is h1..h4 | p | li | div

HEADING_TAGS  = {"h1": "#", "h2": "##", "h3": "###", "h4": "####"}
HEADING_LEVEL = {"h1": 1, "h2": 2, "h3": 3, "h4": 4}
BLOCK_TAGS    = {"p", "li", "div", "tr", "td", "th"}
# Tags whose entire subtree is always discarded
BASE_SKIP_TAGS = frozenset({"style", "script", "figure", "figcaption", "nav", "head", "title"})


# ---------------------------------------------------------------------------
# Preset: publisher-specific cleaning rules
# ---------------------------------------------------------------------------

@dataclass
class Preset:
    """Cleaning rules that vary per publisher / epub style."""
    # CSS class substrings whose elements (and subtree) are skipped
    skip_classes: frozenset = frozenset()
    # Extra tag names to skip entirely
    skip_tags: frozenset = frozenset()
    # Called on each (tag, text) chunk; return False to discard
    chunk_filters: list[Callable[[Chunk], bool]] = field(default_factory=list)
    # Called on body text before appending; return cleaned string (or "" to discard)
    text_cleaners: list[Callable[[str], str]] = field(default_factory=list)


def _lp_chunk_filters() -> list[Callable]:
    """Chunk-level filters for Lonely Planet epub style."""
    copyright_re = re.compile(r"©")
    icon_artifact_re = re.compile(r"^[a-zA-Z]{1,3}$")  # LP icon-font runs like "zvr"

    def no_copyright(chunk: Chunk) -> bool:
        return not copyright_re.search(chunk[1])

    def no_icon_artifact(chunk: Chunk) -> bool:
        # Drop alpha-only strings ≤3 chars (icon font glyphs)
        _, text = chunk
        return not (len(text) <= 3 and icon_artifact_re.match(text))

    def no_nav_breadcrumb(chunk: Chunk) -> bool:
        tag, text = chunk
        if tag in HEADING_LEVEL:
            return True
        # All-uppercase short text = nav breadcrumb (handles curly apostrophes via .upper())
        return not (any(c.isalpha() for c in text) and text == text.upper() and len(text) <= 80)

    return [no_copyright, no_icon_artifact, no_nav_breadcrumb]


def _lp_text_cleaners() -> list[Callable]:
    """Text-level cleaners for Lonely Planet epub style."""
    inline_junk = re.compile(r"\b(MAP|GOOGLE MAP|GOOGLE MAPS)\b\s*")
    icon_prefix  = re.compile(r"^[a-zA-Z\d](?=[A-Z])")  # "yDon't Miss" → "Don't Miss"

    def strip_inline_junk(text: str) -> str:
        return inline_junk.sub("", text).strip()

    def strip_icon_prefix(text: str) -> str:
        return icon_prefix.sub("", text).strip()

    return [strip_inline_junk, strip_icon_prefix]


PRESETS: dict[str, Preset] = {
    "lonelyplanet": Preset(
        skip_classes=frozenset({
            "highlight",        # chapter-section label inside headings
            "caption", "credit",
            "figure", "photo",
            "great-icons", "best-of-icons", "best-of-heading",  # LP icon font spans
        }),
        chunk_filters=_lp_chunk_filters(),
        text_cleaners=_lp_text_cleaners(),
    ),
}


# ---------------------------------------------------------------------------
# EPUB spine reader (stdlib only — no ebooklib)
# ---------------------------------------------------------------------------

OPF_NS  = "http://www.idpf.org/2007/opf"
CONT_NS = "urn:oasis:names:tc:opendocument:xmlns:container"


def _read_spine(zf: zipfile.ZipFile) -> list[str]:
    """
    Return content file paths in spine (reading) order from the OPF manifest.
    Falls back to sorted name order if OPF parsing fails.
    """
    try:
        container = ET.fromstring(zf.read("META-INF/container.xml"))
        opf_path = container.find(
            f".//{{{CONT_NS}}}rootfile"
        ).get("full-path")
        opf_dir  = os.path.dirname(opf_path)
        opf      = ET.fromstring(zf.read(opf_path))

        # Build id → href map from manifest
        manifest = {}
        for item in opf.findall(f".//{{{OPF_NS}}}item"):
            mid   = item.get("id")
            href  = item.get("href")
            mtype = item.get("media-type", "")
            if "html" in mtype or href.endswith((".xhtml", ".html")):
                full = os.path.normpath(os.path.join(opf_dir, href)) if opf_dir else href
                manifest[mid] = full.replace("\\", "/")

        # Walk spine itemrefs in order
        spine = []
        for itemref in opf.findall(f".//{{{OPF_NS}}}itemref"):
            idref = itemref.get("idref")
            if idref in manifest:
                spine.append(manifest[idref])
        return spine
    except Exception:
        # Fallback: alphabetical order of all xhtml/html files
        return sorted(
            n for n in zf.namelist()
            if n.endswith((".xhtml", ".html"))
        )


# ---------------------------------------------------------------------------
# HTML → chunks extractor
# ---------------------------------------------------------------------------

class HtmlExtractor(HTMLParser):
    """
    Converts an HTML/XHTML document into a flat list of (tag, text) chunks,
    preserving heading levels and list items.
    """

    def __init__(self, preset: Preset):
        super().__init__()
        self.preset = preset
        self._skip_tags  = BASE_SKIP_TAGS | preset.skip_tags
        self._buf: list[str] = []
        self._current_block: str | None = None
        self._inside_heading = False
        self._skip_depth = 0
        self.chunks: list[Chunk] = []

    def _skip_by_class(self, attrs) -> bool:
        css = dict(attrs).get("class", "")
        return any(c in css for c in self.preset.skip_classes)

    def _flush(self):
        raw = re.sub(r"\s+", " ", "".join(self._buf)).strip()
        self._buf = []
        tag = self._current_block or "p"
        self._current_block = None

        if not raw:
            return

        if tag in HEADING_LEVEL:
            # Strip leading digit prefix: "1Honolulu" → "Honolulu"
            text = re.sub(r"^\d+\s*", "", raw).strip()
        else:
            # Apply text cleaners (preset-specific) only to body text
            text = raw
            for cleaner in self.preset.text_cleaners:
                text = cleaner(text)
                if not text:
                    return

        chunk: Chunk = (tag, text)

        # Apply chunk filters (preset-specific + general)
        if not all(f(chunk) for f in self.preset.chunk_filters):
            return

        if text:
            self.chunks.append(chunk)

    def handle_starttag(self, tag, attrs):
        if self._skip_depth > 0:
            self._skip_depth += 1
            return
        if tag in self._skip_tags or self._skip_by_class(attrs):
            self._skip_depth += 1
            return
        if tag in HEADING_LEVEL:
            self._flush()
            self._current_block = tag
            self._inside_heading = True
        elif tag in BLOCK_TAGS:
            self._flush()
            self._current_block = tag
            self._inside_heading = False
        elif tag == "br":
            self._buf.append(" " if self._inside_heading else "\n")

    def handle_endtag(self, tag):
        if self._skip_depth > 0:
            self._skip_depth -= 1
            return
        if tag in HEADING_LEVEL:
            self._flush()
            self._inside_heading = False
        elif tag in BLOCK_TAGS:
            self._flush()

    def handle_data(self, data):
        if self._skip_depth == 0:
            self._buf.append(data)

    def get_chunks(self) -> list[Chunk]:
        self._flush()
        return self.chunks


# ---------------------------------------------------------------------------
# Chunk post-processing
# ---------------------------------------------------------------------------

def remove_empty_headings(chunks: list[Chunk]) -> list[Chunk]:
    """Drop headings whose scope contains no body content before the next same/higher heading."""
    result = []
    for i, (tag, text) in enumerate(chunks):
        if tag not in HEADING_LEVEL:
            result.append((tag, text))
            continue
        level = HEADING_LEVEL[tag]
        has_body = any(
            jtag not in HEADING_LEVEL
            for jtag, _ in chunks[i + 1:]
            if not (jtag in HEADING_LEVEL and HEADING_LEVEL[jtag] <= level)
            # stop at next same/higher heading
            or (jtag in HEADING_LEVEL and HEADING_LEVEL[jtag] <= level and (False,)[0:1] or [True])[0]
        )
        # Simpler inline scan:
        has_body = False
        for jtag, _ in chunks[i + 1:]:
            if jtag in HEADING_LEVEL and HEADING_LEVEL[jtag] <= level:
                break
            if jtag not in HEADING_LEVEL:
                has_body = True
                break
        if has_body:
            result.append((tag, text))
    return result


def dedup_adjacent(chunks: list[Chunk]) -> list[Chunk]:
    result: list[Chunk] = []
    for item in chunks:
        if not result or item != result[-1]:
            result.append(item)
    return result


# ---------------------------------------------------------------------------
# Markdown rendering
# ---------------------------------------------------------------------------

def chunks_to_markdown(chunks: list[Chunk]) -> str:
    lines = []
    for tag, text in chunks:
        if tag in HEADING_TAGS:
            lines.append(f"\n{HEADING_TAGS[tag]} {text}")
        elif tag == "li":
            lines.append(f"- {text}")
        else:
            lines.append(text)
    return "\n\n".join(line.strip() for line in lines if line.strip())


def build_toc(sections: list[tuple[str, list[Chunk]]]) -> str:
    lines = ["# Table of Contents\n"]
    for title, _ in sections:
        slug = re.sub(r"[^\w\s-]", "", title).strip().lower()
        slug = re.sub(r"\s+", "-", slug)
        lines.append(f"- [{title}](#{slug})")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main conversion
# ---------------------------------------------------------------------------

SKIP_STEMS = frozenset({"toc", "nav", "cover", "contents"})


def epub_to_md(epub_path: str, out_path: str | None = None, preset: Preset | None = None) -> str:
    if out_path is None:
        out_path = os.path.splitext(epub_path)[0] + ".md"
    if preset is None:
        preset = Preset()

    sections: list[tuple[str, list[Chunk]]] = []
    seen_titles: set[str] = set()

    with tempfile.TemporaryDirectory() as tmp:
        with zipfile.ZipFile(epub_path) as zf:
            spine_paths = _read_spine(zf)
            zf.extractall(tmp)

        for rel_path in spine_paths:
            # Skip nav/toc/cover files
            stem = os.path.splitext(os.path.basename(rel_path))[0].lower()
            if any(s in stem for s in SKIP_STEMS):
                continue

            abs_path = os.path.join(tmp, rel_path)
            if not os.path.isfile(abs_path):
                continue

            with open(abs_path, encoding="utf-8", errors="ignore") as f:
                html = f.read()

            extractor = HtmlExtractor(preset)
            extractor.feed(html)
            chunks = extractor.get_chunks()
            chunks = remove_empty_headings(chunks)
            chunks = dedup_adjacent(chunks)

            # Skip files with no body content after filtering
            if not any(tag not in HEADING_LEVEL for tag, _ in chunks):
                continue

            # Section title: first unique heading
            title = next((t for tag, t in chunks if tag in HEADING_LEVEL and t not in seen_titles), None)
            if title is None:
                title = re.sub(r"-bo-\w+$", "", stem).replace("-", " ").title()
            seen_titles.add(title)
            sections.append((title, chunks))

    with open(out_path, "w", encoding="utf-8") as out:
        out.write(build_toc(sections))
        out.write("\n\n---\n\n")
        for _, chunks in sections:
            out.write(chunks_to_markdown(chunks))
            out.write("\n\n---\n\n")

    size_kb = os.path.getsize(out_path) / 1024
    n_lines = sum(1 for _ in open(out_path))
    print(f"{out_path}  ({size_kb:.0f} KB, {n_lines} lines, {len(sections)} sections)")
    return out_path


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("epub", help="path to .epub file")
    parser.add_argument("-o", "--output", help="output path (default: same dir as epub, .md)")
    parser.add_argument(
        "--preset",
        choices=list(PRESETS),
        default=None,
        help="publisher-specific cleaning rules (default: none)",
    )
    args = parser.parse_args()

    if not os.path.isfile(args.epub):
        sys.exit(f"File not found: {args.epub}")

    preset = PRESETS[args.preset] if args.preset else Preset()
    epub_to_md(args.epub, args.output, preset)


if __name__ == "__main__":
    main()
