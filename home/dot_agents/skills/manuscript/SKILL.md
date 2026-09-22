---
name: manuscript
description: Scientific manuscript prose and figure conventions (LaTeX/Typst). Use when writing, revising or reviewing paper text, captions or figures.
---

Write for a reader reading cold.

## Prose

- A modifier earns its place only when the bare noun could be misread. If only one kind is in play, drop the qualifier.
- No defensive writing. Do not rebut objections the text has not raised ("X is not Y, but..."). State what holds; a caveat appears once, where it applies.
- State a fact where it first matters. A forward reference ("Section X describes...") marks a fact parked in the wrong section: move it.
- One term per concept; do not alias for variety.
- Prefer a stated number to an adjective. No intensifiers, no em dashes (commas, colons, parentheses, or a new sentence).
- Results report; Discussion interprets.
- Methods state the choices a reader needs to judge the result. Implementation parameters (window lengths, tapers, thresholds, fallbacks) stay in the code.

## Figures, tables, numbers

- Numbers in the text come from a generated file (macros, or a CSV the document maps over), never typed by hand.
- Never edit a generated file; fix the script that produces it.
- Figures carry no interpretive prose: panel titles, axis labels, legends and data annotations only. Reading and meaning belong in the text beside the figure.
- Panel labels in-axis. Colors and markers from one shared palette so the same quantity looks the same in every figure.
