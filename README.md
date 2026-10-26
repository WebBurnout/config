# Tim config

## Install

Install homebrew with instructions from the web page, then run:
```
brew install bash alacritty tmux nvm weechat bluesnooze
brew install --cask hammerspoon
```

Add to /etc/shells:
```
/opt/homebrew/bin/bash
```

Change to bash:
```
chsh -s /opt/homebrew/bin/bash
```

For Tmux you will need to install the catpuccin with:
```
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
```
And the minimal-status-line:
```
git clone git@github.com:niksingh710/minimal-tmux-status.git ~/.config/tmux/plugins/minimal-status-line
```

There are two bash config files: `bashrc_mac` and `bashrc_linux`. Both are the
interactive shell config (aliases, functions, prompt) and both get symlinked to
`~/.bashrc` on their respective platform — they're just kept separate because
the machines differ. On macOS, `~/.bash_profile` additionally sources
`~/.bashrc` (see below).

To use the config files, create symbolic links to the correct location (you
may need to remove the ones that are there).

```bash
ln -s ~/code/config/bashrc_mac ~/.bashrc
# macOS terminals open *login* shells, which read ~/.bash_profile, not
# ~/.bashrc. So point .bash_profile at .bashrc to get the interactive config.
echo 'source ~/.bashrc' > ~/.bash_profile
ln -s ~/code/config/tmux.conf ~/.tmux.conf
ln -s ~/code/config/witch.plist ~/Library/Application\ Support/Witch/Settings.plist
ln -s ~/code/config/gitconfig ~/.gitconfig
ln -s ~/code/config/gitignore ~/.gitignore
ln -s ~/code/config/aerospace.toml ~/.aerospace.toml
ln -s ~/code/config/ssh_config ~/.ssh/config
ln -s ~/code/config/nvim ~/.config/nvim
ln -s ~/code/config/opencode ~/.config/opencode
ln -s ~/code/config/alacritty ~/.config/
ln -s ~/code/config/hammerspoon.lua ~/.hammerspoon/init.lua
ln -s ~/code/config/firefox-user-chrome.css ~/Library/Application\ Support/Firefox/Profiles/nhn7zq27.default-release/chrome/userChrome.css
ln -s ~/code/config/weechat-irc.conf ~/.config/weechat/irc.conf
```

For Claude Code, symlink the individual config files back into `~/.claude` (the
rest of that directory is runtime data and secrets, so don't symlink the whole
thing):

```bash
mkdir -p ~/.claude
ln -s ~/code/config/claude/settings.json ~/.claude/settings.json
ln -s ~/code/config/claude/statusline-context.js ~/.claude/statusline-context.js
ln -s ~/code/config/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/code/config/claude/notify.sh ~/.claude/notify.sh
```

For pi configuration, create a symlink of the whole directory:

```bash
# Create parent directory and symlink the entire agent directory
mkdir -p ~/.pi
ln -s ~/code/config/pi ~/.pi/agent
```

**Note:** The `bin/`, `git/`, and `sessions/` directories exist in the repo directory but are excluded from version control via `.gitignore`. They contain binaries, cloned repositories, and runtime data respectively.

### Claude bridge

Install `pi-claude-bridge` to use Claude through the official Claude Agent SDK
and the subscription authenticated by the Claude Code CLI:

```bash
claude
pi install npm:pi-claude-bridge
```

The bridge configuration is stored in `~/.pi/agent/claude-bridge.json`. Select
a `claude-bridge/*` model from Pi's model picker after installation.

Karabiner was not working with a symlink so just copy it when you make changes
```
cp ~/.config/karabiner/karabiner.json .
```

For NeoVim you will need to install the python provider with:
```
python3 -m pip install --user --upgrade pynvim
```

Also the language servers:
```
npm install -g typescript typescript-language-server vscode-langservers-extracted @olrtg/emmet-language-server
```

Install ripgrep for use in nvim
```
brew install ripgrep
```

Install SwitchAudioSource
```
brew install switchaudio-osx
```

### Keeping USB speakers awake

The USB bookshelf speakers power themselves down when idle.
`bin/keep-speakers-awake.sh` plays a two second 30 Hz tone at -12 dB to keep
them on. It exits immediately unless the machine is on AC power and the
speakers are the selected output device (`afplay` can only play to whatever
output is selected). launchd re-runs it every 60 seconds:

```
ln -s ~/code/config/launchd/com.tim.keep-speakers-awake.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.tim.keep-speakers-awake.plist
```

Stop it with `launchctl bootout gui/$(id -u)/com.tim.keep-speakers-awake`.
The device name defaults to `USB2.0 Device` (as reported by
`SwitchAudioSource -a`) and can be overridden with `KEEP_AWAKE_DEVICE`.

### Disconnecting Bluetooth audio on sleep

When the machine sleeps, Hammerspoon runs `bin/bt-disconnect-audio.sh`. The
script disconnects every Bluetooth device except the keyboard and trackpad, so
a closed lid doesn't hold on to the headphones, and the keyboard and trackpad
can still wake it. Nothing reconnects on wake. The script runs through a
launchd job because blueutil crashes when Hammerspoon starts it directly
(Hammerspoon's Info.plist has no Bluetooth usage description):

```
brew install blueutil
ln -s ~/code/config/launchd/com.tim.bt-disconnect-audio.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.tim.bt-disconnect-audio.plist
```

The job has no schedule; it only runs when Hammerspoon kickstarts it. Output
goes to `/tmp/bt-disconnect-audio.log`. Devices to keep connected are listed by
address in the script (`blueutil --paired` shows them).

### Voice dictation (whisper.cpp)

`hyper+f` toggles dictation in Hammerspoon: press once to start recording, press
again to stop, transcribe, and paste at the cursor. Audio is captured with
ffmpeg and transcribed locally with whisper.cpp via `bin/whisper-transcribe.sh`.

Install the tools and download a model:
```
brew install whisper-cpp ffmpeg
mkdir -p ~/.local/share/whisper-models
curl -L -o ~/.local/share/whisper-models/ggml-base.en.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
```

Grant Hammerspoon Microphone access in System Settings > Privacy & Security >
Microphone (you are prompted on first use).

For better accuracy on technical terms, download a larger model (e.g.
`ggml-small.en.bin` from the same URL path) and point the `MODEL` default in
`bin/whisper-transcribe.sh` (or the `WHISPER_MODEL` env var) at it.

Note: the built-in mic is disabled when the lid is closed (clamshell). The
recorder uses the `:default` input device, so connect/select an external mic
(System Settings > Sound, or cycle with SwitchAudioSource) to dictate with the
lid shut.

Install some GUI programs by downloading them and adding the license files if
needed: Transmit, Litle Snitch, iStat Menus, Witch, Karibiner Elements,
AeroSpace, Hammerspoon, Dash, Colima.

Hammerspoon replaces Moom for window management. It needs Accessibility
permissions in System Settings > Privacy & Security > Accessibility.

For Karabiner to work with tmux, you will need to change the hotkey for changing input sources (input language) from control space to alt space. You can do so in System Preferences > Keyboard > Input > Shortcuts

Install Colima to run containers with
```
brew install docker colima
```

Then start Colima on startup with
```
brew services start colima
```


## Linux setup

For Debian and Raspberry Pi OS. Run as your normal user; the checkout lives at
`~/config`. On a new Pi, first flash Raspberry Pi OS Lite (64-bit), configure the
user and SSH public key in Raspberry Pi Imager, boot, and connect over SSH.
The first boot can take several minutes.

### Base tools and GitHub access

```sh
sudo apt update
sudo apt install -y git curl ca-certificates jq fzf
ssh-keygen -t ed25519 -C "$(hostname)"
```

Add `~/.ssh/id_ed25519.pub` to your GitHub account, then clone the configuration:

```sh
cd ~
git clone git@github.com:WebBurnout/config.git
```

### Passwordless sudo

```sh
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010-$USER-nopasswd
sudo chmod 440 /etc/sudoers.d/010-$USER-nopasswd
sudo visudo -c
```

Expect `parsed OK`. This gives your user unrestricted sudo without a password.

### SSH key authentication

Confirm you can log in with your SSH key before disabling password authentication.
Keep the current session open while testing a second login.

```sh
echo "PasswordAuthentication no" | sudo tee /etc/ssh/sshd_config.d/no-passwords.conf
sudo /usr/sbin/sshd -t
sudo systemctl restart ssh
```

The validation command should print nothing and exit successfully before you
restart SSH.

### Locale

If login reports locale errors:

```sh
sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8
```

Log out and reconnect for the new locale.

### Neovim

The config needs Neovim 0.11+, which is newer than Debian's `neovim` package, so
install the official release build. Set `NVIM_VERSION` to the latest tag from
https://github.com/neovim/neovim/releases. `uname -m` picks the arm64 build on a
Pi and the x86_64 build on a PC.

```sh
NVIM_VERSION=v0.12.6
NVIM_PKG=nvim-linux-$(uname -m | sed 's/aarch64/arm64/')
cd "$(mktemp -d)"
curl -fsSLO https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$NVIM_PKG.tar.gz
curl -fsSL https://api.github.com/repos/neovim/neovim/releases/tags/$NVIM_VERSION \
  | jq -r --arg f $NVIM_PKG.tar.gz '.assets[] | select(.name == $f) | "\(.digest | ltrimstr("sha256:"))  \($f)"' \
  | sha256sum -c
tar xzf $NVIM_PKG.tar.gz
sudo rm -rf /opt/nvim
sudo mv $NVIM_PKG /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
cd ~
hash -r
nvim --version | head -1
```

The checksum line must print `OK`; if it doesn't, stop and don't install that
tarball. To upgrade, rerun with a new `NVIM_VERSION`. `/usr/local/bin` comes
before `/usr/bin` on `PATH`, so this wins over an apt-installed `neovim` (remove
that with `sudo apt remove neovim`).

### Shell, Git, and Neovim configuration

Move any existing files out of the way before creating these symlinks.

```sh
mkdir -p ~/.config
ln -s ~/config/bashrc_linux ~/.bashrc
ln -s ~/config/gitconfig ~/.gitconfig
ln -s ~/config/nvim ~/.config/nvim
```

Start a new shell to load the Bash configuration.

### Node.js and pi

Install Node.js with nvm, matching the Mac and the homelab. Set `NVM_VERSION`
to the latest tag from https://github.com/nvm-sh/nvm/releases. `PROFILE=/dev/null`
stops the installer from appending to `~/.bashrc`; `bashrc_linux` already loads
nvm and runs `nvm use 26`.

```sh
NVM_VERSION=v0.40.8
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh -o /tmp/nvm-install.sh
PROFILE=/dev/null bash /tmp/nvm-install.sh
source ~/.bashrc
nvm install 26
nvm alias default 26
hash -r
node --version
```

nvm refuses to work if npm has a global `prefix` set, so if an old `~/.npmrc`
sets one, remove it with `npm config delete prefix`.

Install pi and Claude Code. Global packages go under `~/.nvm`, so no sudo:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
npm install -g @anthropic-ai/claude-code
mkdir -p ~/.pi
ln -s ~/config/pi ~/.pi/agent
pi --version
claude --version
```

Expect Node.js, pi, and Claude Code version numbers. Move an existing
`~/.pi/agent` directory out of the way before creating the symlink. After
switching to a new major Node version with `nvm install`, reinstall these global
packages; each Node version has its own.

`node`, `pi`, and `claude` are only on `PATH` in shells that load `~/.bashrc`.
Cron jobs and systemd units need the full path, e.g.
`~/.nvm/versions/node/v26.x.y/bin/pi`.

### Tailscale

```sh
curl -fsSL https://tailscale.com/install.sh -o /tmp/install-tailscale.sh
sh /tmp/install-tailscale.sh
sudo tailscale up
```

Follow the authentication URL, then disable key expiry for this device in the
Tailscale admin console.



## Helpful Information

To reload `init.vim` without exiting Neovim run
```
:source $MYVIMRC
```

To reload `tmux.conf`
```
tmux source-file ~/.tmux.conf
```








## Tmux handiness

renumbers windows to remove gaps
tmux move-window -r

move window
tmux move-window -t 1

swap window
tmux swap-window -t 1




## Vimium handiness


T search through tabs

leader-h -- for local history of a file

Find and replace in a directory:
```
:args spec/javascripts/**/*.* 
:argdo %s/foo/bar/g
```

## custom key mappings

delete by workd ctrl-w
forward delete by word alt-d

not custom but dont forget: readline by word in macos is ctrl-option-f/b

s and S mappings are ripe for changing because i don't use them and they have a two character one that's directly equivalent

hyper-q -- Hammerspoon left 1/2
hyper-w -- Hammerspoon left 2/3
hyper-e -- Hammerspoon left 14/15
hyper-r -- Hammerspoon right 14/15
hyper-t -- Hammerspoon right 2/3
hyper-y -- Hammerspoon right 1/2
hyper-m -- Hammerspoon maximize

hyper-n -- next app in witch
hyper-p -- previous app in witch

f5 -- keyboard brightness down
f6 -- keyboard brightness up

hyper-a -- play/pause
hyper-s -- volume down
hyper-d -- volume up
hyper-f -- voice dictation (whisper.cpp toggle)


### tmux
hyper-g -- previous tmux pane
hyper-h -- next tmux pane
hyper-j -- down pane
hyper-k -- up pane
hyper-l -- right pane
hyper-; -- split window vertically
hyper-' -- split window horizontally
hyper-x -- close pane
hyper-c -- create window


## Tmux handiness

ctrl-u/d for half page scroll

c-space for escape

tmux a # -- attach to last created session 

tmux new -s [name of session]
tmux a -t [name of session]


## Vim handiness

Ctrl-o and forward with Ctrl-i to move through history of jumplist in vim
:undolist to see all branches, g- and g+ to move through time-based changes, or :earlier and :later with time specifications like :earlier 5m to go back 5 minutes
q opens the command-line window, search, edit, and run with enter
:global to run command on on multiple lines
ciw is change word, ci" change inside quotes, yi) yank inside parens
view all registers with :reg
marks include `` ```` (last jump position), '. (last change), '" (last position before exiting), and '[/'] (start/end of last change).
The & character in replacements refers to the entire match, while \1, \2, etc. refer to capture groups (combine with :global
 gn text object selects the next search match, enabling workflows like /pattern followed by cgn to change the next occurrence.
In insert mode, Ctrl-r= followed by an expression like 2+3<Enter> inserts "5"


[d / ]d is next/previous diagnostic
<c-[> go to definition

za - toggle fold at cursor
zR - open all folds
zM - close all open folds

ctrl-t to transpose letters

I -- insert at the start of the line
to make the search case sensitive can do "set noic" or just use \c at the end
; repeat f-type motions
{ and } for moving cursor to blocks
% - move to other side of parens
zz to center cursor in screen
leader-/ Telescope lsp_document_symbols
c-v for visual block mode, I to insert, x to delete, v to expand selection, V to shrink it
zc close fold, zo open fold, or just za to toggle fold
leader-k - show dash
leader-w -- save file
C replaces the rest of the line (starting at cursor position) with your edit.
cc and S are synonyms and replace the whole line(s) with your edit.
s replace character with your edit
gq - format to 79 line width
:delm to delete a mark
m, Set the next available alphabetical (lowercase) mark
dmx Delete mark x
dm- Delete all marks on the current line
nvim-tree commands: https://github.com/kyazdani42/nvim-tree.lua#default-actions
Ctrl + e - move screen down one line (without moving cursor)
Ctrl + y - move screen up one line (without moving cursor)



### git
leader-n next git hunk
leader-N previous git hunk
leader-u undo git hunk

### LSP
K - show info
leader-s - signs outline
leader-r - rename
leader-x - code action
leader-e - line diagnostics
leader-d -- go to definition
leader-i -- go to implementation
gj -- next diagnostic
gk -- previous diagnostic
\<C-f> -- scroll popup down
\<C-b> -- scroll popup up

### Telescope
leader-g - live grep
c-t open a Telescope search in Trouble (put it in a window)


### Weechat
todo:
change scroll buffer to alt-j/k and few lines alt-shift-j/k
could change ctrl-n/p to move up down one line and change buffers to alt-n/p
