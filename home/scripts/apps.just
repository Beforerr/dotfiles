zotero-link:
    ln -s ~/Library/CloudStorage/Box-Box/storage ~/Zotero/storage

zotero-addons:
    aria2c https://github.com/syt2/zotero-addons/releases/latest/download/zotero-addons.xpi

install-tana:
    aria2c https://desktop-update.tana.inc/download/dmg
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

gpt-academic:
    #!/usr/bin/env sh
    cd ~/src/gpt_academic
    micromamba run -n gptac_venv python -m pip install -r requirements.txt # 这个步骤和pip安装一样的步骤
    micromamba run -n gptac_venv python main.py
