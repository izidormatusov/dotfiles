# Setting up MacOS

## Settings

 - Login to Apple Account
 - Pick a screen saver (e.g. _Shuffle Cityscape_)
 - Bluetooth pair with headphones and mouse
 - Add the printer

Appearance:

 - Set the wallpaper

Displays:

 - Night shift from 19:30 to 6:30, about 80% warm

Bluetooth:

 - Add headphones and mouse

Lock screen:

 - Start Screen Saver when inactive: _For 10 minutes_
 - Require password after screen saver begins or display is turned off:
   _Immediately_
 - Login window show: _Name and password_

Keyboard:

 - Turn off keyboard brightness to 0
 - Modifier keys: remap Caps Lock to Escape for each keyboard

Copy the keyboard layout and then add it in preferences:

```shell
cp -r ~/code/dotfiles/keyboard_layout/izidor_keyboard.bundle ~/Library/Keyboard\ Layouts
```

Privacy:

 - Full Disk Access: Add _Alfred_ and terminal
 - FileVault: turn on the disk encryption

Network:

 - Enable _Firewall_

## Console

Set the default shell to bash (list of valid shells is listed in `/etc/shells`):

```shell
chsh -s /bin/bash
```

Set the hostname:

```shell
./tools/set_hostname $new_hostname
```

Move GPG private keys from the old device to the new one:

```shell
export GPG_TTY=$(tty)
gpg --homedir ~/gpgrecovery/.gnupg/ --export-secret-keys | gpg --import
```

For each key then run `gpg --edit-key $KEY` and specify `trust` with level `5`
(ultimate trust).

Generate a new SSH key for the machine (passwords are under
`server/ssh.$(hostname)`:

```shell
ssh-keygen -o -a 100 -t ed25519 -C "$(hostname -s)"
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_deployment -C "$(hostname -s) deployment"

cat ~/.ssh/id_ed25519.pub >> ~/code/server/roles/common/files/public_keys
cat ~/.ssh/id_deployment.pub >> ~/code/server/roles/common/files/deployment_public_keys
```

Afterwards:

 - edit `~/.ssh/config` (probably want to base it on previous configuration)
 - update [bitbucket](https://bitbucket.org/account/settings/ssh-keys/)
 - update [github](https://github.com/settings/keys)
 - update [gitlab](https://gitlab.com/-/user_settings/ssh_keys)
 - update websupport (check SSH console on a hosting)

## Set up apps

 - Alfred
 - Google Drive (mirror files for offline copy)
 - Syncthing
 - Setup samba shares (<kbd>⌘</kbd> + <kbd>K</kbd>)
 - Signal
 - Telegram
 - Spotify
 - Test quick look preview for Markdown and code files

### Chrome

Try to join a meeting and share a window. This should require setting up
permissions for mic, camera and window sharing.

Open `chrome://settings/content/federatedIdentityApi?search=privacy` and click
_Block sign-in prompts from identity services_ to prevent _Log in with Google_
prompts.

### Firefox

Extensions:

   - [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
   - [SponsorBlock](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)
