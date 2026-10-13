// Zotero's default (15) leaves plugins sideloaded into extensions/ disabled.
user_pref("extensions.autoDisableScopes", 0);
// Attachments live in Box (Zotero/storage symlink). Zotero file sync would hash every
// attachment lacking a stored mtime, forcing Box to download the whole library.
user_pref("extensions.zotero.sync.storage.enabled", false);
