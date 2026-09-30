#!/bin/bash

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock launchanim -bool true
defaults write com.apple.dock orientation -string bottom
# Hot corners (modifier 0 = none): TL Mission Control, TR Desktop, BL screen saver, BR Notification Center
if command -v dockutil >/dev/null; then
    for app in Contacts Photos; do dockutil --remove "$app" --no-restart 2>/dev/null; done
fi
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 12
defaults write com.apple.dock wvous-br-modifier -int 0

defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder FXPreferredViewStyle -string clmv
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false
defaults write com.apple.finder ShowPathbar -bool false
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
chflags nohidden ~/Library

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Amphetamine rewrites its prefs on quit, so write while it's closed.
osascript -e 'quit app "Amphetamine"' 2>/dev/null
defaults write com.if.Amphetamine "Enable Triggers" -bool true
defaults write com.if.Amphetamine "Allow Closed-Display Sleep" -bool false
defaults write com.if.Amphetamine "Allow Display Sleep" -bool true
defaults write com.if.Amphetamine "Allow Display Sleep When Screen Is Locked" -bool true
defaults write com.if.Amphetamine "End Session On Low Battery" -bool true
defaults write com.if.Amphetamine "Show Welcome Window" -bool false
# TypeIDs 8 = Battery & Power Adapter criterion; RequireAC 1 = only while plugged in.
defaults write com.if.Amphetamine "Trigger Data" -array '<dict>
    <key>ActivateOnAC</key><string>0</string>
    <key>ActivateOnNoAC</key><string>0</string>
    <key>AllowDisplaySleep</key><true/>
    <key>AllowSysSleepOnClsdDisp</key><false/>
    <key>AndOr</key><string>0</string>
    <key>BatteryThreshold</key><string>50.000000</string>
    <key>Enabled</key><true/>
    <key>Name</key><string>Power Adapter: connected</string>
    <key>RequireAC</key><string>1</string>
    <key>RequireNoAC</key><string>0</string>
    <key>TypeIDs</key><array><string>8</string></array>
</dict>'
[ -d /Applications/Amphetamine.app ] && open -a Amphetamine

for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    defaults write $domain Clicking -bool true
    defaults write $domain TrackpadRightClick -bool true
    defaults write $domain TrackpadThreeFingerDrag -bool true
done

# Touch ID for sudo; sudo_local survives macOS updates, unlike edits to /etc/pam.d/sudo.
if ! grep -q pam_tid /etc/pam.d/sudo_local 2>/dev/null; then
    echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# Pinyin – Simplified. TISEnableInputSource updates the running input menu; `defaults write` to
# HIToolbox only lands after relogin. The parent SCIM method must be enabled too, or the mode stays inert.
osascript -l JavaScript -e '
ObjC.import("Carbon");
for (const id of ["com.apple.inputmethod.SCIM", "com.apple.inputmethod.SCIM.ITABC"]) {
    const f = $.NSDictionary.dictionaryWithObjectForKey(id, "TISPropertyInputSourceID");
    $.TISEnableInputSource(ObjC.castRefToObject($.TISCreateInputSourceList(f, true)).objectAtIndex(0));
}' >/dev/null

# Preinstalled apps plus their shared content
sudo rm -rf /Applications/GarageBand.app /Applications/iMovie.app \
    "/Library/Application Support/GarageBand" "/Library/Application Support/logic" \
    "/Library/Audio/Apple Loops/Apple"

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock Finder 2>/dev/null || true
