#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["pylatexenc"]
# ///
"""Convert unicode to LaTeX, strip math-mode \\ensuremath, drop unicode-math."""
import re
import sys
from pylatexenc.latexencode import UnicodeToLatexEncoder

enc = UnicodeToLatexEncoder(non_ascii_only=True, replacement_latex_protection='braces-after-macro')

POST = [
    # Unwrap \ensuremath; insert a space only when needed to break macro-letter collision.
    (re.compile(r'\\ensuremath\{(\\[a-zA-Z]+)\}(?=[a-zA-Z])'), r'\1 '),
    (re.compile(r'\\ensuremath\{([^{}]*)\}'), r'\1'),
    (re.compile(r'\\textperiodcentered(?:\{\}|\b)\s?'), r'\\cdot '),
    (re.compile(r'\\textemdash(?:\{\}|\b)\s?'), '---'),
    (re.compile(r'\\textendash(?:\{\}|\b)\s?'), '--'),
    (re.compile(r'^\\usepackage\{unicode-math\}\s*\n', re.MULTILINE), ''),
]

def clean(text):
    text = enc.unicode_to_latex(text)
    for pat, repl in POST:
        text = pat.sub(repl, text)
    return text

if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else 'article.tex'
    with open(path, encoding='utf-8') as f:
        src = f.read()
    out = clean(src)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(out)
    leftover = sorted({c for c in out if ord(c) > 127})
    print(f'wrote {path}; non-ASCII left: {leftover or "none"}')
