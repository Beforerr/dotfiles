// Plugins sideloaded into extensions/ are otherwise never detected (startupScanScopes)
// or left disabled (autoDisableScopes, Zotero default 15).
user_pref("extensions.startupScanScopes", 1);
user_pref("extensions.autoDisableScopes", 0);
// Attachments live in Box (Zotero/storage symlink). Zotero file sync would hash every
// attachment lacking a stored mtime, forcing Box to download the whole library.
user_pref("extensions.zotero.sync.storage.enabled", false);
// Public as Zotero's server drops browser requests without custom headers,
// so only local processes can reach the bridge.
user_pref("extensions.zotero.debug-bridge.token", "claude-bridge");
user_pref("extensions.zotero.translators.better-bibtex.skipFields", "file,urldate");
