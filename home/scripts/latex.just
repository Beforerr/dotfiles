# Strip trackchanges and/or comments (both on by default).
[no-cd]
strip *args:
    ~/scripts/latex/strip_trackchanges.py {{ args }}
