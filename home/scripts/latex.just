# Strip LaTeX trackchanges and/or comments (both on by default).
[no-cd]
strip *args:
    python3 ~/scripts/strip_latex.py {{ args }}
