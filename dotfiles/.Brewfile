brew "bash"
brew "bash-completion"
brew "bat"
brew "broot"                       # Terminal viewer
brew "btop"                        # Fancier top
brew "coreutils"                   # Better sleep
brew "czkawka"                     # GUI deduplication tool
brew "direnv"
brew "exiftool"                    # extract EXIF metadata
brew "fd"                          # Replacement for find
brew "ffmpeg"
brew "findutils"                   # GNU find (better than Mac find)
brew "fish"                        # Friendly Interactive SHell
brew "fzf"
brew "gifski"
brew "gitui"
brew "gmailctl"                    # Manage gmail filters
brew "gnupg2"
brew "go"
brew "graphviz"
brew "htop"                        # Fancier top
brew "hyperfine"                   # Benchmarking tool https://github.com/sharkdp/hyperfine
brew "imagemagick"
brew "jless"                       # JSON explorer
brew "jq"                          # JSON query tool
brew "just"
brew "mtr"                         # My Trace Route - ping on steroids
brew "nmap"
brew "npm"
brew "pass"
brew "pass-otp"
brew "pinentry-mac"
brew "protobuf"
brew "qrencode"
brew "ripgrep"                    # Faster grep
brew "rsync"
brew "ruff"                       # Python formatter
brew "syncthing", restart_service: :changed
brew "tesseract"                  # OCR
brew "tesseract-lang"             # OCR
brew "timg"                       # Show images in terminal, either libsixel, iTerm, kitty or unicode pixelation
brew "tmux"
brew "uv"                         # Python package manager
brew "vim"                        # Support termguicolors
brew "wget"
brew "yazi"
brew "yt-dlp"                     # youtube-dl is no longer maintained
brew "zbar"
brew "zoxide"                     # Jumping around directories

cask "alfred"
cask "android-platform-tools"
cask "audacity"
cask "blender"
cask "db-browser-for-sqlite"
cask "gimp"
cask "google-chrome"
cask "inkscape"
cask "rectangle"
cask "signal"
cask "spotify"
cask "stats"                      # https://github.com/exelban/stats
cask "telegram"
cask "vlc"
cask "wezterm"                    # Terminal

# QuickLook plugins
# To get the plugin working, you might need to open up the plugin app directly.
# Then:
#  - `xattr -cr ~/Library/QuickLook/$APP.qlgenerator`
#  - `qlmanage -r && qlmanage -r cache`
#  - In Dock,  Option + right click on Finder and hit "Relaunch"
# Run `qlmanage -r` to reload plugins. You might need to manually open them to
# confirm that they can run.
cask "qlstephen"           # default files, e.g. README
cask "qlmarkdown"          # render markdown
cask "quicklook-json"      # json
cask "qlcolorcode"         # syntax highlight

mas "Flow", id: 1423210932        # Pomodoro timer

# Additional Brewfiles
Dir.glob(File.join(File.dirname(__FILE__), ".Brewfile_*")) do |brewfile|
  instance_eval(File.read(brewfile))
end

# vi: set ft=ruby :
