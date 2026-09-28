zotero-link:
    ln -s ~/Library/CloudStorage/Box-Box/storage ~/Zotero/storage

zotero-addons:
    curl -LOJ https://github.com/syt2/zotero-addons/releases/latest/download/zotero-addons.xpi

# Homebrew disabled the cask: Glance is ad-hoc signed. curl downloads are not quarantined, so Gatekeeper lets it run.
install-glance:
    #!/usr/bin/env bash
    set -euo pipefail
    url=$(curl -fsSL https://api.github.com/repos/chamburr/glance/releases/latest | jq -r '.assets[] | select(.name | endswith(".dmg")) | .browser_download_url')
    tmp=$(mktemp -d)
    curl -fsSL "$url" -o "$tmp/Glance.dmg"
    mnt=$(hdiutil attach -nobrowse -readonly "$tmp/Glance.dmg" | tail -1 | cut -f3-)
    rm -rf /Applications/Glance.app
    ditto "$mnt/Glance.app" /Applications/Glance.app
    hdiutil detach -quiet "$mnt"
    open /Applications/Glance.app

install-tana:
    curl -LOJ https://desktop-update.tana.inc/download/dmg
    open Tana*.dmg

popclip:
    curl https://pilotmoon.com/popclip/extensions/ext/DOI.popclipextz -o "DOI.popclipextz"

browser-extensions:
    # bitwarden
    open https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb
    # simplify-gmail
    open https://chromewebstore.google.com/detail/simplify-gmail/pbmlfaiicoikhdbjagjbglnbfcbcojpj 
    # violentmonkey
    open https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
    # ublock-origin
    open https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
    # saladict
    open https://chromewebstore.google.com/detail/saladict-pop-up-dictionar/cdonnmffkdaoajfknoeeecmchibpmkmg
