#!/bin/sh
# Only seeds missing plugins: Zotero self-updates each one via its update_url.
set -eu
export PATH="/opt/homebrew/bin:$PATH"
ext="$HOME/Library/Application Support/Zotero/Profiles/default/extensions"
mkdir -p "$ext"

install() { # <addon id> <github repo>
    [ -f "$ext/$1.xpi" ] && return
    url=$(curl -fsSL "https://api.github.com/repos/$2/releases/latest" |
        jq -r '[.assets[] | select(.name | endswith(".xpi"))][0].browser_download_url')
    curl -fsSL -o "$ext/$1.xpi" "$url"
}

install better-bibtex@iris-advies.com retorquere/zotero-better-bibtex
install zoterostyle@polygon.org MuiseDestiny/zotero-style
