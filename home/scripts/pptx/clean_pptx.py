#!/usr/bin/env python3
"""Remove hidden slides, comments, and speaker notes from a PPTX file."""

from __future__ import annotations

import argparse
import posixpath
from pathlib import Path, PurePosixPath
from zipfile import ZIP_DEFLATED, ZipFile
from xml.etree import ElementTree as ET


NS_P = "http://schemas.openxmlformats.org/presentationml/2006/main"
NS_R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
NS_CT = "http://schemas.openxmlformats.org/package/2006/content-types"
NS_PKG = "http://schemas.openxmlformats.org/package/2006/relationships"

ET.register_namespace("p", NS_P)
ET.register_namespace("r", NS_R)
ET.register_namespace("", NS_PKG)

RID_ATTR = f"{{{NS_R}}}id"
NS = {"p": NS_P, "ct": NS_CT}


def owner_part_from_rels(rels_path: str) -> str:
    """Return the package part that owns a .rels part."""
    if rels_path == "_rels/.rels":
        return ""
    return rels_path.replace("/_rels/", "/").removesuffix(".rels")


def norm_target(owner_part: str, target: str) -> str:
    return posixpath.normpath(posixpath.join(posixpath.dirname(owner_part), target))


def rels_path_for(part: str) -> str:
    name = PurePosixPath(part).name
    return f"{PurePosixPath(part).parent}/_rels/{name}.rels"


def is_comment_part(path: str) -> bool:
    low = path.lower()
    markers = ("/comments/", "/threadedcomments/", "commentauthors", "/persons/")
    return any(marker in low for marker in markers)


def rel_is_comment(rel) -> bool:
    target = rel.attrib.get("Target", "").lower()
    typ = rel.attrib.get("Type", "").lower()
    markers = ("comments", "threadedcomment", "commentauthors", "person")
    return any(marker in target or marker in typ for marker in markers)


def rel_is_notes(rel) -> bool:
    target = rel.attrib.get("Target", "").lower()
    typ = rel.attrib.get("Type", "").lower()
    return "notesslides" in target or "notesslide" in typ


def strip_relationships(zip_in, names, removed_parts, *, remove_notes):
    updates = {}

    for rels_path in sorted(n for n in names if n.endswith(".rels") and n not in removed_parts):
        root = ET.fromstring(zip_in.read(rels_path))
        owner_part = owner_part_from_rels(rels_path)
        changed = False

        for rel in list(root):
            if rel_is_comment(rel) or (remove_notes and rel_is_notes(rel)):
                target = rel.attrib.get("Target")
                if target:
                    removed_parts.add(norm_target(owner_part, target))
                root.remove(rel)
                changed = True

        if changed:
            updates[rels_path] = ET.tostring(root, encoding="utf-8", xml_declaration=True)

    return updates


def clean_pptx(src: Path, dst: Path, *, remove_hidden: bool, remove_notes: bool) -> dict:
    summary = {
        "hidden_slides_removed": [],
        "parts_removed": 0,
        "slides_remaining": 0,
    }

    with ZipFile(src) as zip_in:
        names = set(zip_in.namelist())
        removed_parts = {n for n in names if is_comment_part(n)}
        if remove_notes:
            removed_parts.update(n for n in names if n.startswith("ppt/notesSlides/"))

        updates = {}
        pres = ET.fromstring(zip_in.read("ppt/presentation.xml"))
        pres_rels = ET.fromstring(zip_in.read("ppt/_rels/presentation.xml.rels"))
        rel_by_id = {rel.attrib["Id"]: rel for rel in list(pres_rels)}

        slide_id_list = pres.find("p:sldIdLst", NS)
        if slide_id_list is None:
            raise ValueError("ppt/presentation.xml has no slide list")

        for index, slide_id in enumerate(list(slide_id_list), 1):
            rid = slide_id.attrib[RID_ATTR]
            rel = rel_by_id[rid]
            slide_path = posixpath.normpath(posixpath.join("ppt", rel.attrib["Target"]))
            slide_root = ET.fromstring(zip_in.read(slide_path))
            hidden = slide_root.attrib.get("show") == "0" or slide_id.attrib.get("show") == "0"

            if remove_hidden and hidden:
                slide_id_list.remove(slide_id)
                pres_rels.remove(rel)
                summary["hidden_slides_removed"].append(index)
                removed_parts.add(slide_path)
                removed_parts.add(rels_path_for(slide_path))

        updates.update(strip_relationships(zip_in, names, removed_parts, remove_notes=remove_notes))

        for part in list(removed_parts):
            if part.startswith("ppt/notesSlides/") and part.endswith(".xml"):
                removed_parts.add(rels_path_for(part))

        content_types = ET.fromstring(zip_in.read("[Content_Types].xml"))
        for override in list(content_types.findall("ct:Override", NS)):
            part = override.attrib.get("PartName", "").lstrip("/")
            content_type = override.attrib.get("ContentType", "").lower()
            if (
                part in removed_parts
                or is_comment_part(part)
                or "comment" in content_type
                or "person" in content_type
                or (remove_notes and "noteslide" in content_type)
            ):
                content_types.remove(override)

        updates["[Content_Types].xml"] = ET.tostring(
            content_types, encoding="utf-8", xml_declaration=True
        )
        updates["ppt/presentation.xml"] = ET.tostring(
            pres, encoding="utf-8", xml_declaration=True
        )
        updates["ppt/_rels/presentation.xml.rels"] = ET.tostring(
            pres_rels, encoding="utf-8", xml_declaration=True
        )

        summary["parts_removed"] = len(removed_parts)
        summary["slides_remaining"] = len(slide_id_list)

        with ZipFile(dst, "w", compression=ZIP_DEFLATED) as zip_out:
            for info in zip_in.infolist():
                if info.filename in removed_parts:
                    continue
                data = updates.get(info.filename, zip_in.read(info.filename))
                info.compress_type = ZIP_DEFLATED
                zip_out.writestr(info, data)

    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a clean PPTX by removing hidden slides, comments, and speaker notes."
    )
    parser.add_argument("pptx", type=Path, help="input .pptx file")
    parser.add_argument("-o", "--output", type=Path, help="output .pptx path")
    parser.add_argument("--keep-hidden", action="store_true", help="keep hidden slides")
    parser.add_argument("--keep-notes", action="store_true", help="keep speaker notes")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    src = args.pptx
    dst = args.output or src.with_name(f"{src.stem}_clean{src.suffix}")

    summary = clean_pptx(
        src,
        dst,
        remove_hidden=not args.keep_hidden,
        remove_notes=not args.keep_notes,
    )

    print(f"wrote: {dst}")
    print(f"slides remaining: {summary['slides_remaining']}")
    print(f"hidden slides removed: {len(summary['hidden_slides_removed'])}")
    if summary["hidden_slides_removed"]:
        print(f"removed slide numbers: {summary['hidden_slides_removed']}")
    print(f"package parts removed: {summary['parts_removed']}")


if __name__ == "__main__":
    main()
