# Tim config

## Install

To use the config files, create symbolick links to the correct location (you
probably need to remove the ones that are there).

```
ln -s ~/code/config/bash_profile ~/.bash_profile
ln -s ~/code/config/bash_aliases ~/.bash_aliases
ln -s ~/code/config/init.vim ~/.config/nvim/init.vim
ln -s ~/code/config/tim-snippets/ ~/.config/nvim
ln -s ~/code/config/alacritty.yml ~/.alacritty.yml
ln -s ~/code/config/tmux.conf ~/.tmux.conf
```

For NeoVim you will need to do a `:PlugInstall` and for Tmux you will need to install the themepack with:

```
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

```

To get the correct colors in tmux you must follow [these instructions](https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95).


## Helpful Information

To reload `init.vim` without exiting Neovim run
```
:source $MYVIMRC
```

ctrl-shift-space for vi mode in Alacritty 

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

ctrl+space " -- split horizontally
ctrl+space % -- split vertically


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

