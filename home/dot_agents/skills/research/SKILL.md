---
name: research
description: Zotero lookup/full-text grep/import, OpenAlex literature search, paper notes vault, PDF extraction, research.bib, LaTeX/Typst manuscripts. Use for papers, citations, literature.
---

- Zotero (must be running): `~/scripts/zotero.py <citekey|DOI|title>...` → metadata + local PDF path;
  `zotero.py grep <regex>` → citekeys + snippets from Zotero's full-text index (indexed PDFs only);
  `zotero.py add <DOI|arXiv|url>... -c Collection` imports with PDF.
  Storage is Box files-on-demand: never `rga`/`pdftotext` across `~/Zotero/storage`, it downloads the library.
- Beyond the library: `~/scripts/openalex.py search "<topic>" [--since 2020] [--sort cites]`, `get <DOI> --abstract`,
  `citing <DOI>`, `refs <DOI>` → `year | cites | DOI | author | title`; pipe DOIs into `zotero.py add`.
- Notes vault `~/Documents/papers/<citekey>/`: README.md (frontmatter + abstract + figure notes), paper.pdf, fig*.png.
  Read it before re-reading a paper. Create/extend: `~/scripts/extract_figures.py <citekey> [--figures "1,3,5-7"]`
  (also symlinks `./sources/papers/<citekey>` into cwd).
- `research.bib`: master at `~/projects/share/bibliography/research.bib` (Better BibTeX auto-export); paper repos symlink it.
- PDF text: `pdftotext -layout in.pdf out.txt`. Equations/tables/figures: `uvx --from marker-pdf marker_single in.pdf
  --output_dir out --output_format markdown` → `out/<stem>/<stem>.md`, ~30 s.
- Manuscripts: LaTeX or Typst. `just --justfile ~/justfile latex strip f.tex` drops trackchanges + comments; `~/scripts/latex/clean_unicode.py` unicode → LaTeX.
