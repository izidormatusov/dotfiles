#!/bin/bash

set -eu

heading() {
  echo -e "\n\033[33;1m$@\033[0m"
}

# Only on Mac
if [ `uname -s` = "Darwin" ]
then

osascript -e 'tell application "System Preferences" to quit' || echo "Could not close system preferences"

heading "Setting up mac environment"
# Use Dark theme
defaults write -g AppleInterfaceStyle Dark
# Show scroll bars when scrolling
defaults write -g AppleShowScrollBars Automatic

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

heading "Sound"
# Don't play user interface sound effects
defaults write -g com.apple.sound.uiaudio.enabled -bool false
# Don't play feedback when volume is changed
defaults write -g com.apple.sound.beep.feedback -bool false
# Lower volume of the feedback
defaults write -g com.apple.sound.beep.volume -float 0.2

# Disable chime noise when plugging in power charger
# (source: https://apple.stackexchange.com/a/309947/327859)
# To make it take effect: killall PowerChime
# NOTE: this works only when the user is logged in. It does not work when the
# laptop lid is closed
defaults write com.apple.PowerChime ChimeOnNoHardware -bool true

# Disable startup noise
sudo nvram StartupMute=%01

heading "Background sounds"
# https://support.apple.com/en-me/guide/mac-help/mchl3061cdc6/mac
defaults write com.apple.ComfortSounds relativeVolume -float 0.18
# Stop after the computer is locked
defaults write com.apple.ComfortSounds stopsOnLock -bool true

heading "Mouse / trackpad"
# Fix scroll direction
defaults write -g com.apple.swipescrolldirection -bool false
# Increase mouse speed
defaults write -g com.apple.mouse.scaling -float 2.5
# Increase trackpad speed
defaults write -g com.apple.trackpad.scaling -float 1
# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

heading "Keyboard"
# Disable automatic text corrections
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticTextCompletionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Tab should focus for everything
defaults write -g AppleKeyboardUIMode -int 2

# Set fast key repeat rate
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Disable the popup menu for accents
defaults write -g ApplePressAndHoldEnabled -bool false

heading "Keyboard shortcuts"
# Disable spotlight with ⌘ + Space (Alfred should remap to it)
# defaults command is not powerful enough to update this configuration.
# PlistBuddy first removes the key entry and then adds it back disabled.
/usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
  -c "Delete :AppleSymbolicHotKeys:64" \
  -c "Add :AppleSymbolicHotKeys:64:enabled bool false" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 65535" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 1048576" \
  -c "Add :AppleSymbolicHotKeys:64:type string standard"

heading "Dock and windows"
# Disable the tiles in the window manager
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
# Workspace uses all available monitor (not workspace per monitor)
defaults write com.apple.spaces spans-displays -bool true
# Do not automatically switch to a space with the open windows for the application
defaults write -g AppleSpacesSwitchOnActivate -bool false

defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool False

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Put dock on the left side
defaults write com.apple.dock orientation -string left

# Make the icons smaller
defaults write com.apple.dock tilesize -int 31

# Make the icons smaller
defaults write com.apple.dock "show-recents" -int 0

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

heading "Hot corners"
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard (dashboard was deprecated)
# 10: Put display to sleep
# 11: Launchpad
# 12: Notifications center
# Top left: Mission control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right: Notifications center
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left: Put display to sleep
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right: no-op
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

heading "Menubar"
# Remove items from the menubar
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.appleuser" -bool false
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool false
# Show volume in menubar
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true

# Set the format of clock to something like "7 Feb 22:57"
defaults write com.apple.menuextra.clock DateFormat "d MMM HH:mm"

defaults write com.apple.Siri StatusMenuVisible -bool false

defaults write com.apple.Spotlight "NSStatusItem Visible Item-0" -bool false
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true
# Don't share spotlight queries
defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2

defaults write com.apple.airplay showInMenuBarIfPresent -bool false

defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible KeyboardBrightness" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false

# Display battery in menu bar with percentage and energy mode
defaults -currentHost write com.apple.controlcenter Battery -int 3
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults -currentHost write com.apple.controlcenter BatteryShowEnergyMode -bool true
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

heading "Screenshots"
# Save screenshots into Downloads folder
defaults write com.apple.screencapture location ~/Documents/screenshots
# Disable shadows around the window screenshots
defaults write com.apple.screencapture disable-shadow -bool false

heading "Finder"
# Show `Library` folder
chflags nohidden ~/Library/

# Prevent .DS_Store on network & USB disks
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRecentTags -bool false

# By default open Downloads folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

# When searching, search the current folder
# SCev -> This Mac
# SCcf -> Current Folder
# SCsp -> Previous Scope
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# Set the preferred view
# Flwv -> Cover Flow View
# Nlsv -> List View
# clmv -> Column View
# icnv -> Icon View
defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'

# Sort folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show all filename extensions
defaults write -g AppleShowAllExtensions -bool true

# Show the full path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

defaults write com.apple.finder "NSToolbar Configuration Browser" '{
    "TB Default Item Identifiers" = (
        "com.apple.finder.BACK",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SWCH",
        "com.apple.finder.ARNG",
        "com.apple.finder.ACTN",
        "com.apple.finder.SHAR",
        "com.apple.finder.LABL",
        NSToolbarFlexibleSpaceItem,
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SRCH"
    );
    "TB Display Mode" = 2;
    "TB Icon Size Mode" = 1;
    "TB Is Shown" = 1;
    "TB Item Identifiers" = (
        "com.apple.finder.BACK",
        "com.apple.finder.PATH",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SWCH",
        "com.apple.finder.ACTN",
        "com.apple.finder.NFLD",
        "com.apple.finder.TRSH",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SRCH"
    );
    "TB Size Mode" = 1;
}'

killall Finder

heading "Night shift"
NIGHT_SHIFT='{
  CBBlueLightReductionCCTTargetRaw = "3034";
  CBBlueReductionStatus =         {
      AutoBlueReductionEnabled = 1;
      BlueLightReductionAlgoOverride = 0;
      BlueLightReductionDisableScheduleAlertCounter = 3;
      BlueLightReductionSchedule =             {
          DayStartHour = 6;
          DayStartMinute = 30;
          NightStartHour = 19;
          NightStartMinute = 30;
      };
      BlueReductionAvailable = 1;
      BlueReductionEnabled = 0;
      BlueReductionMode = 2;
      BlueReductionSunScheduleAllowed = 1;
      Version = 1;
  };
}'

CORE_BRIGHTNESS="/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
CBUser="CBUser-$(dscl . -read ~ GeneratedUID | sed 's/GeneratedUID: //')"
sudo defaults write $CORE_BRIGHTNESS "CBUser-0" "$NIGHT_SHIFT"
sudo defaults write $CORE_BRIGHTNESS "$CBUser"  "$NIGHT_SHIFT"

heading "Automatic sleep"

# Show the currently scheduled things
#   sudo pmset -g sched
# Documentation
#   man pmset
# See https://iboysoft.com/news/missing-energy-saver-schedule-ventura.html
# Schedule the time to sleep at 10:01pm
sudo pmset repeat cancel && \
  sudo pmset repeat sleep MTWRFSU 22:01:00

heading "pinentry-mac"
# Do not force me to store password in the keychain
defaults write org.gpgtools.common DisableKeychain -bool yes

heading "Spotify"
mkdir -p ~/Library/Application\ Support/Spotify
touch ~/Library/Application\ Support/Spotify/prefs
echo 'app.autostart-mode="off"' >> ~/Library/Application\ Support/Spotify/prefs
echo 'app.autostart-banner-seen=true' >> ~/Library/Application\ Support/Spotify/prefs

heading "Restart apps to pick up the new settings"
set -x
killall SystemUIServer || true
killall -HUP Dock || true
killall Finder || true
killall cfprefsd || true

fi
