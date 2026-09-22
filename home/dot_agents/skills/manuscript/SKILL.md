---
name: manuscript
description: Scientific manuscript prose and figure conventions (LaTeX/Typst/Quarto papers, reports, theses). Use when writing, revising or reviewing paper text, captions, methods, abstracts, or paper figures. Tooling (Zotero, bib, PDF) is the research skill.
---

Write for a referee reading cold. Every sentence carries a fact, a choice, or a result; delete the rest.

## Prose

- A modifier earns its place only when the bare noun could be misread: "calibrated spectrum" only where an uncalibrated one is in play; otherwise "spectrum".
- No defensive writing. Do not rebut objections the text has not raised ("X is not Y, but..."). State what holds; caveats live in the discussion, once.
- State a fact where it first matters. A forward reference ("Section X states...") marks a fact parked in the wrong section: move it.
- One term per concept. Pick it at first use and never alias it (not "event"/"case"/"interval" for the same thing).
- Define a symbol once, at first use, in the sentence that needs it. No notation tables unless the journal requires one.
- Claims that are not the paper's own carry a citation; claims that are point to the figure, table or equation that shows them.
- No em dashes; use commas, colons, parentheses, or a new sentence.
- Cut evaluative adverbs and intensifiers ("clearly", "significantly" unless a test is reported, "novel", "importantly", "it is worth noting").
- Prefer a stated number to an adjective ("a factor of 3" over "much larger").

## Sections

- Abstract: what was done, what was found, one sentence of why it matters. Numbers, not adjectives. No citations.
- Introduction ends with what this paper does, in the order the sections do it.
- Methods state the choices a referee needs to judge the result, not the parameters that implement them (see below).
- Results report; Discussion interprets. A sentence starting "This suggests" in Results belongs in Discussion.
- Conclusion restates findings, not the method.

## Figures, tables, numbers

Generated artifacts, not documents. Each is owned by exactly one script; the manuscript only includes.

- One script per figure family or table; it writes to a fixed path the manuscript includes
  (`figs/<name>.<ext>`, `tables/<name>.tex`, `data/<name>.csv`). Name the output after the
  script or the manuscript label, so the path answers "what regenerates this".
- Numbers in the text come from that output: a generated macro file (`\newcommand` in LaTeX,
  a CSV the `.typ` maps over), never typed by hand. A number that changes in the script
  changes in the paper on the next build, with no edit to the text.
- Never edit a generated `.tex`, `.csv` or image. Fix the script and rebuild. Generated files
  carry a first-line comment naming their script.
- A build recipe (`just`, `make`) regenerates everything the manuscript includes, then copies
  it in. Pipeline parameters (FFT length, taper, overlap, thresholds, fallback policy) live
  there, not in the prose; Methods names the script or repository.
- Figures carry no interpretive prose: panel titles, axis labels, legends and data annotations
  only. How to read a panel and what it means belong in the text next to the figure.
- Panel labels in-axis, from one shared helper; colors and markers from one shared palette so
  the same quantity looks the same in every figure.
- Caption first sentence names what is plotted; later sentences define symbols and markers.
  Interpretation stays in the body.
- Every figure and table is referenced from the text, in order of first reference.

## Revising

- Reviewer rebuttals: quote the comment, state the change, point to the location. No thanks, no arguing beyond the fact.
- For AI-flavored prose, run the humanizer skill; for tooling, the research skill.
