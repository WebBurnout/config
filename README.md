# Tim config

## Install

Install homebrew with instructions from the web page, then run:
```
brew install bash iterm2 tmux nvm
```

Add to /etc/shells:
```
/opt/homebrew/bin/bash
```

Change to bash:
```
chsh -s /opt/homebrew/bin/bash
```

For iTerm you will need to open settings and set it to load the preferences
from this directory.

For Tmux you will need to install the themepack with:
```
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
```

To use the config files, create symbolick links to the correct location (you
may need to remove the ones that are there).

```
ln -s ~/code/config/bash_profile ~/.bash_profile
ln -s ~/code/config/bash_aliases ~/.bash_aliases
ln -s ~/code/config/tmux.conf ~/.tmux.conf
ln -s ~/code/config/witch.plist ~/Library/Application\ Support/Witch/Settings.plist
ln -s ~/code/config/gitconfig ~/.gitconfig
ln -s ~/code/config/gitignore ~/.gitignore
ln -s ~/code/config/ssh_config ~/.ssh/config
mkdir -p ~/.config/nvim
ln -s ~/code/config/init.vim ~/.config/nvim/init.vim
ln -s ~/code/config/tim-snippets/ ~/.config/nvim/tim-snippets
```

Also some configs require hard links:
```
ln -f ~/code/config/karabiner.json ~/.config/karabiner/karabiner.json
sudo ln -f ~/code/config/hosts /etc/hosts
```

For NeoVim you will need to install the pyhton provider with:
```
python3 -m pip install --user --upgrade pynvim
```

Also, install VimPlug with something like:
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
Then do a `:PlugInstall` inside nvim and install treesitter languages `:TSInstall lua vim typescript html css`

Also the language servers:
```
npm install -g typescript typescript-language-server vscode-langservers-extracted
```

Install some GUI programs by downloading them and adding the license files if
needed: Transmit, Litle Snitch, iStat Menus, Witch, Karibiner Elements,
Rectangle, Dash, Colima.

For Rectangle, install the app and then import the preferences json using the GUI

For Karabiner to work with tmux, you will need to change the hotkey for changing input sources (input language) from control space to alt space. You can do so in System Preferences > Keyboard > Input > Shortcuts

Install Colima to run containers with
```
brew install docker colima
```

Then start Colima on startup with
```
brew services start colima
```

## Helpful Information

To reload `init.vim` without exiting Neovim run
```
:source $MYVIMRC
```

ctrl-t to transpose letters


## Vimium handiness

T search through tabs


## custom key mappings

f5 -- keyboard brightness down
f6 -- keyboard brightness up

hyper-f -- left in mission control
hyper-b -- right in mission control

hyper-n -- next app in witch
hyper-p -- previous app in witch


### tmux
hyper-q -- clear screen and scrollback
hyper-j -- down pane
hyper-k -- up pane
hyper-h -- left pane
hyper-l -- right pane
hyper-; -- split window vertically
hyper-' -- split window horizontally
hyper-x -- close pane
hyper-c -- create window


## Tmux handiness

c-space for escape
tmux a # -- attach to last created session 

tmux new -s [name of session]
tmux a -t [name of session]


## Vim handiness

I -- insert at the start of the line
to make the search case sensitive can do "set noic" or just use \c at the end
; repeat f-type motions
{ and } for moving cursor to blocks
zz to center cursor in screen
leader-/ Telescope lsp_document_symbols
c-v for visual block mode, I to insert, x to delete
v to expand selection, V to shrink it
zc close fold, zo open fold
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

