---
name: research
description: Zotero, paper notes vault, PDF/EPUB extraction, research.bib, Quarto/LaTeX manuscripts. Use for papers, citations, literature.
---

- Zotero (must be running): `~/scripts/zotero.py <citekey|DOI|title>...` → metadata + local PDF path;
  `~/scripts/zotero.py add <DOI|arXiv|url>... -c Collection` imports with PDF.
- Notes vault `~/Documents/papers/<citekey>/`: README.md (frontmatter + abstract + figure notes), paper.pdf, fig*.png.
  Read it before re-reading a paper. Create/extend: `~/scripts/extract_figures.py <citekey> [--figures "1,3,5-7"]`
  (also symlinks `./sources/papers/<citekey>` into cwd).
- `research.bib`: master at `~/projects/share/bibliography/research.bib` (Better BibTeX auto-export); paper repos symlink it.
- PDF text: `pdftotext -layout in.pdf out.txt`. Equations/tables/figures: `uvx --from marker-pdf marker_single in.pdf
  --output_dir out --output_format markdown` → `out/<stem>/<stem>.md`, ~30 s. EPUB: `~/scripts/epub2txt.py book.epub`.
- Manuscripts: Quarto (`index.qmd`, `quarto render index.qmd --to typst|pdf`) or LaTeX.
  `just --justfile ~/justfile latex strip f.tex` drops trackchanges + comments; `~/scripts/latex/clean_unicode.py` unicode → LaTeX.
