#!/usr/bin/env python3
"""Strip LaTeX trackchanges commands and/or comments.

\\add[ed]{text}          -> text
\\annote[ed]{text}{note} -> text   (note arg optional)
\\change[ed]{old}{new}   -> new
\\note[ed]{text}         -> (removed)
\\remove[ed]{text}       -> (removed)
% comment               -> (removed, unless \\%)

Usage:
  strip_latex.py [--no-trackchanges] [--no-comments] src [dst]
  strip_latex.py ... -            # write to stdout
  echo ... | strip_latex.py -     # read from stdin
"""
import argparse, re, sys
from pathlib import Path

B = r'\{(?:[^{}]|\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\})*\}'
O = r'\[[^\]]*\]'
W = r'\s*'

TC_RULES = [
    (rf'\\(?:note|remove){O}{W}{B}',     lambda m: ''),
    (rf'\\add{O}{W}({B})',               lambda m: m.group(1)[1:-1]),
    (rf'\\change{O}{W}{B}{W}({B})',      lambda m: m.group(1)[1:-1]),
    (rf'\\annote{O}{W}({B})(?:{W}{B})?', lambda m: m.group(1)[1:-1]),
]

def strip_trackchanges(text):
    for pat, fn in TC_RULES:
        def repl(m, _text=text):
            line_start = _text.rfind('\n', 0, m.start()) + 1
            on_comment = _text[line_start:m.start()].lstrip().startswith('%')
            return m.group(0) if on_comment else fn(m)
        text = re.sub(pat, repl, text)
    return text

def strip_comments(text):
    lines = []
    for line in text.split('\n'):
        m = re.search(r'(?<!\\)%', line)
        if m is None:
            lines.append(line)
        elif line[:m.start()].strip() == '':
            pass  # pure comment line: drop entirely
        else:
            lines.append(line[:m.start()].rstrip())  # inline comment: keep code
    return '\n'.join(lines)

def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('src', help='input file, or - for stdin')
    p.add_argument('dst', nargs='?', default='',
                   help='output file, or - for stdout (default: <src>_clean.<ext>)')
    p.add_argument('--no-trackchanges', dest='trackchanges',
                   action='store_false', help='skip trackchanges stripping')
    p.add_argument('--no-comments', dest='comments',
                   action='store_false', help='skip comment stripping')
    p.set_defaults(trackchanges=True, comments=True)
    args = p.parse_args()

    text = sys.stdin.read() if args.src == '-' else Path(args.src).read_text()
    if args.trackchanges: text = strip_trackchanges(text)
    if args.comments:     text = strip_comments(text)

    if args.dst == '-':
        sys.stdout.write(text)
    else:
        out = Path(args.dst) if args.dst else Path(args.src).with_stem(Path(args.src).stem + '_clean')
        out.write_text(text)
        print(f"{args.src} -> {out}", file=sys.stderr)

if __name__ == '__main__':
    main()
