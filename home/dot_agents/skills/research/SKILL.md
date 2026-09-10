---
name: research
description: Papers and references — look up or import into Zotero, extract text/equations/figures from PDFs, research.bib. Use for citations, literature, reading or citing a paper, or any PDF of a paper.
---

- Zotero (must be running): `~/scripts/zotero.py <citekey|DOI|title>...` prints metadata + local PDF path;
  `~/scripts/zotero.py add <DOI|arXiv|url>... -c Collection` imports with PDF.
- `research.bib` in paper repos is an auto-export of the whole library; cite by its citekeys.
- PDF text: `pdftotext -layout in.pdf out.txt`.
- Equations/tables/figures: `uvx --from marker-pdf marker_single in.pdf --output_dir out --output_format markdown`
  → `out/<stem>/<stem>.md` with LaTeX math, figures as JPEG. ~30 s/paper.
- Figures of a Zotero item: `~/scripts/extract_figures.py <citekey> [out_dir]`.
