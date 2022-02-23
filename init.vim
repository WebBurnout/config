
"
" Plugins (vim-plug)
"

call plug#begin()
  Plug 'dstein64/vim-startuptime'
  Plug 'ishan9299/nvim-solarized-lua'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'kyazdani42/nvim-tree.lua' " file browser

  Plug 'simrat39/symbols-outline.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'onsails/lspkind-nvim'
  Plug 'tami5/lspsaga.nvim'

  Plug 'max397574/better-escape.nvim' " improve jk typing to exit insert mode
  Plug 'kyazdani42/nvim-web-devicons' " icons everywhere
  Plug 'folke/trouble.nvim' " shows errors in a window

  Plug 'chentau/marks.nvim'
  Plug 'nvim-lualine/lualine.nvim' " statusline
  Plug 'noib3/nvim-cokeline'
  Plug 'jeffkreeftmeijer/vim-numbertoggle' " turns to relative in normal mode
  Plug 'tpope/vim-rsi'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzy-native.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tomtom/tcomment_vim'
  Plug 'rizzatti/dash.vim'
  Plug 'styled-components/vim-styled-components'
  Plug 'terryma/vim-expand-region'
call plug#end()


" these must go above nvim-tree.setup in lua
let g:nvim_tree_git_hl = 1
let g:nvim_tree_indent_markers = 1
let g:nvim_tree_special_files = { }
let g:nvim_tree_icons = {
    \  'default': '',
    \  'symlink': '',
    \}


lua << EOF


require'marks'.setup {
  sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
}

local get_hex = require('cokeline/utils').get_hex
require('cokeline').setup({
  default_hl = {
    focused = {
      fg = '#073642',
      bg = '#93a1a1',
    },
    unfocused = {
      fg = '#93a1a1',
      bg = '#073642',
    },
  },

  components = {
    {
      text = function(buffer) return ' ' .. buffer.devicon.icon end,
      hl = {
        fg = function(buffer) return buffer.devicon.color end,
      },
    },
    {
      text = function(buffer) return buffer.unique_prefix end,
      hl = {
        fg = get_hex('Comment', 'fg'),
        style = 'italic',
      },
    },
    {
      text = function(buffer) return buffer.filename .. ' ' end,
    },
    {
      text = ' ',
    }
  },

  rendering = {
    left_sidebar = {
      filetype = 'NvimTree',
      components = {
        {
          text = '  Files',
          hl = {
            fg = yellow,
            bg = get_hex('NvimTreeNormal', 'bg'),
            style = 'italic'
          }
        },
      }
    },
  },
})


require('lualine').setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      'branch', 
      {
        'diff',
        -- color = { bg = 'grey', }
        colored = false, 
      },
     'diagnostics',
    },
    lualine_c = {'filename'},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  extensions = { 'nvim-tree', 'symbols-outline' }
}

require('nvim-tree').setup {
  auto_close = true,
  git = {
    enable = true, -- not working :(
  },
  filters = {
    custom = { ".git" },
  },
}

-- used to improve typing of jk to exit insert mode
require('better_escape').setup {
  mapping = {'jk'},
}

-- preserves transparency
vim.g.solarized_termtrans = 1

local actions = require("telescope.actions")
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  },
  pickers = {
    git_files = {
      theme = "dropdown",
      prompt_prefix = " ",
    },
    find_files = {
      theme = "dropdown",
      prompt_prefix = " ",
    }
  },
  extensions = { }
}

require('telescope').load_extension('fzy_native')

project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(require"telescope.builtin".git_files, opts)
  if not ok then require"telescope.builtin".find_files(opts) end
end


require('gitsigns').setup {
  signs = {
    add = {
      hl = 'GitSignsAdd',
      text = '',
      numhl='GitSignsAddNr',
      linehl='GitSignsAddLn'
    },
    change = {
      hl = 'GitSignsChange',
      text = '卑',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
    },
    delete = {
      hl = 'GitSignsDelete',
      text = '',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
    },
    topdelete = {
      hl = 'GitSignsDelete',
      text = '',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
    },
    changedelete = {
      hl = 'GitSignsChange',
      text = '卑',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
    },
  },
}

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

-- change diagnostic signs in sign column
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- change the sign in front of the diagnostic text
vim.diagnostic.config({
  virtual_text = { prefix = '●', }
})


-- LSP

local lspconfig = require('lspconfig')
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local custom_lsp_attach = function(client)
  vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
  vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "<Leader>r", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "<Leader>x", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "x", "<Leader>x", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "<Leader>e", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", {silent = true, noremap = true})
  vim.api.nvim_buf_set_keymap(0, "n", "<C-f>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-f>')<cr>", {})
  vim.api.nvim_buf_set_keymap(0, "n", "<C-b>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-b>')<cr>", {})


  -- Use LSP as the handler for omnifunc.
  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Use LSP as the handler for formatexpr.
  vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

end


-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'tsserver', 'eslint' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = custom_lsp_attach
  }
end


local cmp = require'cmp'
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
  },
  formatting = {
    format = lspkind.cmp_format({
      -- mode = 'symbol', -- show only symbol annotations
      -- maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      --
      -- -- The function below will be called before any actual modifications from lspkind
      -- -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      -- before = function (entry, vim_item)
      --   return vim_item
      -- end
    })
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})


require('trouble').setup {}

require'nvim-web-devicons'.setup {
  default = true;
}

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

EOF



"
" Config
"

" line numbers (plugin will switch to relative numbers in normal mode)
set number

" eslint on save
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx EslintFixAll

" solarized color scheme
set termguicolors
colorscheme solarized
" change colors of omnifunc
highlight Pmenu guifg='#93a1a1' guibg='#002b36'
" with the transparency setting solarized doesnt set this color
highlight CursorLine guibg='#073642'
set cursorline


" so that aliases will work with !
let $BASH_ENV = "$HOME/.bash_aliases"

" put swap files and backups in a better place
set backup
set backupdir=~/tmp
set dir=~/tmp

" always display the sign column
set signcolumn=auto:1-2

set expandtab
set tabstop=2
set shiftwidth=2
set title

" disable use Ex mode
map Q <Nop>

" highlight 80 characters mark
set cc=80

" changes to working dir to that of current file
set autochdir

" use system clipboard yank / put
set clipboard=unnamed

" moves cursor to previous line when hitting back/forward movement
set whichwrap+=<,>,h,l,[,]

" Open new split panes to right and bottom, which feels more natural than
" Vim’s default:
set splitright
set splitbelow

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set showcmd		" display incomplete commands




"
" Keys
"

" leader is space bar
let mapleader = "\<Space>"

" floating terminal
nnoremap <silent> <Leader>t :Lspsaga open_floaterm<CR>
tnoremap <silent> <C-c> <C-\><C-n>:Lspsaga close_floaterm<CR>
tnoremap <silent> <C-d> <C-\><C-n>:Lspsaga close_floaterm<CR>

" symbols outline
nnoremap <silent> <Leader>s :SymbolsOutline<CR>

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>lua project_files()<cr>
nnoremap <Leader>g <cmd>Telescope live_grep<cr>

" clear search highlighting
nnoremap <Leader><space> :noh<cr>

" save with space w
nnoremap <Leader>w :w<CR>

" git signs commands
nmap <silent> <Leader>n <cmd>Gitsigns next_hunk<CR>
nmap <silent> <Leader>N <cmd>Gitsigns prev_hunk<CR>
nmap <silent> <Leader>u <cmd>Gitsigns reset_hunk<CR>

" toggle tree with q
nnoremap <silent> q :NvimTreeToggle<CR>

" region expanding
vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)

" move through buffers
nmap <silent> <C-j> :update<CR>:bn<CR>
nmap <silent> <C-k> :update<CR>:bp<CR>
nmap <silent> <C-h> :update<CR>:bd<CR>

nmap <silent> <leader>d <Plug>DashSearch

set noshowmode " hide vim's mode status which is duplicate of lualine

" vim-rsi gives us readline commands in insert mode. Here we reconfigure their
" movement to wrap lines
autocmd VimEnter * inoremap <expr> <C-D> "\<Lt>Del>"
autocmd VimEnter * cnoremap <expr> <C-D> "\<Lt>Del>"
autocmd VimEnter * inoremap <expr> <C-E> "\<Lt>End>"
autocmd VimEnter * inoremap <expr> <C-F> "\<Lt>Right>"
autocmd VimEnter * inoremap <expr> <C-F> "\<Lt>Right>"

" do all syntax highlighting when the file opens
autocmd BufEnter * :syntax sync fromstart

" fold with treesitter and unfold when the file opens
set foldmethod=syntax
set foldlevel=99

" following will work when Telescope issue is fixed: https://github.com/nvim-telescope/telescope.nvim/issues/699
" Use Treesitter for folding
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

