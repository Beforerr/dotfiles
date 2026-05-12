# Strip LaTeX trackchanges commands, keeping accepted text
strip-trackchanges src dst="":
    #!/usr/bin/env python3
    import re
    from pathlib import Path

    # Balanced {…} up to 4 levels of nesting — enough for \cite{} inside args
    B = r'\{(?:[^{}]|\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\})*\}'
    O = r'\[[^\]]*\]'  # [optional]
    W = r'\s*'

    RULES = [
        (rf'\\(?:note|remove){O}{W}{B}',     lambda m: ''),
        (rf'\\add{O}{W}({B})',               lambda m: m.group(1)[1:-1]),
        (rf'\\change{O}{W}{B}{W}({B})',      lambda m: m.group(1)[1:-1]),
        (rf'\\annote{O}{W}({B})(?:{W}{B})?', lambda m: m.group(1)[1:-1]),
    ]

    # \add[ed]{text}          -> text
    # \annote[ed]{text}{note} -> text   (note arg optional)
    # \change[ed]{old}{new}   -> new
    # \note[ed]{text}         -> (removed)
    # \remove[ed]{text}       -> (removed)

    def strip_trackchanges(text):
        for pat, fn in RULES:
            def repl(m, _text=text):
                line_start = _text.rfind('\n', 0, m.start()) + 1
                on_comment = _text[line_start:m.start()].lstrip().startswith('%')
                return m.group(0) if on_comment else fn(m)
            text = re.sub(pat, repl, text)
        return text

    src = Path("{{ src }}")
    dst = Path("{{ dst }}") if "{{ dst }}" else src.with_stem(src.stem + '_clean')
    dst.write_text(strip_trackchanges(src.read_text()))
    print(f"{src} -> {dst}")
