#!/bin/sh
# BBT keeps auto-exports in its own store, not prefs, so user.js can't declare them.
# Registers each one through the debug bridge; silently skips while Zotero is closed,
# hence run_after (retries every apply) rather than run_onchange.
set -eu
bib="$HOME/projects/share/bibliography/research.bib"
mkdir -p "$(dirname "$bib")"

PYTHONPATH="$HOME/scripts" python3 - "$bib" <<'EOF'
import sys, urllib.error
import zotero_lib as z

try:
    r = z.bridge_exec("""
const AE = Zotero.BetterBibTeX.AutoExport;
if (AE.get(ARGS.path)) return null;
await AE.add({
  path: ARGS.path, type: "library", id: Zotero.Libraries.userLibraryID,
  translatorID: "ca65189f-8815-4afe-8c8b-8c7c15f0edca",  // Better BibTeX
  status: "done", recursive: false,
}, true);
return "registered";
""", {"path": sys.argv[1]}, timeout=30)
except urllib.error.URLError:
    sys.exit(0)
if r:
    print(f"zotero: BBT auto-export {r}: {sys.argv[1]}")
EOF
