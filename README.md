
# Tim config


## Install

To use the config files, create symbolick links to the correct location (you
probably need to remove the ones that are there).

```
ln -s ~/code/config/bash_profile ~/.bash_profile
ln -s ~/code/config/bash_aliases ~/.bash_aliases
ln -s ~/code/config/init.vim ~/.config/nvim/init.vim
ln -s ~/code/config/alacritty.yml ~/.alacritty.yml
```

## Helpful Information

To reaload `init.vim` without exiting Neovim run
```
:source $MYVIMRC
```

ctrl-shift-space for vi Mode in terminal 

ctrl-t to transpose letters


## Vim handyness
 
v to expand selection, V to shrink it
zc close fold, zo open fold
leader-d - show dash
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
gd -- go to definition
gi -- go to implementation
gj -- next diagnostic
gk -- previous diagnostic
\<C-f> -- scroll popup down
\<C-b> -- scroll popup up

### Telescope
leader-g - live grep



## TODO

turn off autocompletion in markdown files

ctrl-d to exit terminal doesn't work

eslint is having trouble re-running or removing errors :(

must ctrl click on a link to open it in alacritty

way to make tab do first item in omnifunc list?
scroll in omnifunc conflicts with readline

way to have Telescope git_files do MRU
could move up /down with ctrl j/k in Telescope
want the previous searches with ctrl-p/n
feel like preview is kinds useless?
 
disable escape to exit insert mode --make it print ` :)

search could be case insensitive and another key to make it sensitive (find empty key near there like ;)

buffer left/right uses the plugin shortcuts to move in correct order

that plugin that makes you wait if you hold down j/k

cant scroll the popop

leader command for eslint format

https://github.com/David-Kunz/jester

leader command for Trouble

telescope for lsp symbols and rip grep
use ultisnips
https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings
https://github.com/neovim/nvim-lspconfig/wiki/Snippets
https://github.com/quangnguyen30192/cmp-nvim-ultisnips

jest integration to vim
https://github.com/David-Kunz/jester
can run tests from vim

