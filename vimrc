" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

"
" Plugin (Vundle)
"

filetype off  " required for Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'rizzatti/dash.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'airblade/vim-gitgutter'
Plugin 'neoclide/coc.nvim'
Plugin 'tomtom/tcomment_vim'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-scripts/gitignore'
Plugin 'tpope/vim-rsi'
Plugin 'bling/vim-airline'
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'othree/html5.vim'
Plugin 'haya14busa/incsearch.vim'
Plugin 'terryma/vim-expand-region'
Plugin 'frazrepo/vim-rainbow'

" Snipets
Plugin 'honza/vim-snippets'
Plugin 'epilande/vim-es2015-snippets'
Plugin 'epilande/vim-react-snippets'

" Dart
Plugin 'dart-lang/dart-vim-plugin'
Plugin 'thosakwe/vim-flutter'

" JavaScript and TypeScript
Plugin 'yuezk/vim-js'
Plugin 'HerringtonDarkholme/yats.vim'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'digitaltoad/vim-pug'
Plugin 'styled-components/vim-styled-components'

call vundle#end()




"
" Config
"

let $BASH_ENV = "$HOME/.bash_aliases"

" put swap files and backups in a better place
set backup
set backupdir=/Users/omar/tmp
set dir=/Users/omar/tmp

" syntax highlighting
syntax on

set expandtab
set tabstop=2
set shiftwidth=2
set autowrite
set mouse=a
set title

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't use Ex mode, use Q for formatting
map Q gq

" solarized color scheme
set background=dark
colorscheme solarized
set t_Co=256

" highlight after 80 characters
let &colorcolumn=join(range(81,999),",")

" syntax sync minlines=256
autocmd BufEnter * :syntax sync fromstart

" changes to working dir to that of current file
set autochdir

" sets terminal title upon exit so the unhelpful Thanks for flying message is not shown
let &titleold=getcwd()

" line numbers (plugin uses relative)
set number

" use system clipboard yank / put
set clipboard=unnamed

" moves cursor to previous line when hitting back/forward movement
set whichwrap+=<,>,h,l,[,]

" Open new split panes to right and bottom, which feels more natural than Vim’s default:
set splitright
set splitbelow

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set showcmd		" display incomplete commands




"
" Keys
"

" leader is space bar
let mapleader = "\<Space>"

" space space to visual line mode
nmap <Leader><Leader> V

" save with space w
nnoremap <Leader>w :w<CR>

" git gutter commands
nmap <Leader>hn <Plug>GitGutterNextHunk
nmap <Leader>hN <Plug>GitGutterPrevHunk
nmap <Leader>hs <Plug>GitGutterStageHunk
nmap <Leader>hu <Plug>GitGutterUndoHunk

" nerd tree with q key
nnoremap <silent> q :NERDTreeToggle<CR>

" exit insert mode (ESC is far away)
imap jj <Esc>

" region expanding
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" move through buffers
nmap <silent> <C-j> :bn<CR>
nmap <silent> <C-k> :bp<CR>
nmap <silent> <C-h> :update<CR>:bd<CR>

" newline with Enter / Shift-Enter
nmap <CR> o<Esc>
nmap <S-Enter> O<Esc>

nmap <silent> <leader>d <Plug>DashSearch


"
" Plugin Config
"

" CoC extensions
let g:coc_global_extensions = ['coc-tsserver', 'coc-json', 'coc-eslint']

" https://github.com/neoclide/coc.nvim#example-vim-configuration
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

inoremap <silent><expr> <c-j> coc#refresh()

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <C-j> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <C-j> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <C-j> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" <C-j> also advances in Snippets
imap <C-j> <Plug>(coc-snippets-expand-jump)

" for Yats https://github.com/HerringtonDarkholme/yats.vim#config
set re=0

" Jest + CoC
" Run jest for current project
command! -nargs=0 Jest :call  CocAction('runCommand', 'jest.projectTest')
command! -nargs=0 JestCurrent :call  CocAction('runCommand', 'jest.fileTest', ['%'])
nnoremap <leader>te :call CocAction('runCommand', 'jest.singleTest')<CR>
command! JestInit :call CocAction('runCommand', 'jest.init')

" rainbow parenthesis
let g:rainbow_active = 1

" airline
set laststatus=2
set noshowmode
let g:airline#extensions#tabline#enabled = 1

" gitgutter will complain all the time if it exceeds the max
let g:gitgutter_max_signs=9999

" make ctrl-p faster
let g:ctrlp_use_caching = 0
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif

" incsearch plugin does highlighting
set hlsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)zz
map N  <Plug>(incsearch-nohl-N)zz
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" vim-rsi gives us readline commands in insert mode. Here we reconfigure their
" right movement to wrap lines
au VimEnter * inoremap <expr> <C-D> "\<Lt>Del>"
au VimEnter * cnoremap <expr> <C-D> "\<Lt>Del>"
au VimEnter * inoremap <expr> <C-E> "\<Lt>End>"
au VimEnter * inoremap <expr> <C-F> "\<Lt>Right>"
au VimEnter * inoremap <expr> <C-F> "\<Lt>Right>"

