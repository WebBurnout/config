

-- File searcher
return {
  "ibhagwan/fzf-lua",
  cmd = "Fzflua",

  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()

    require('fzf-lua').setup {
      fzf_opts = {
        ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua-history'
      },

      git = {
        files = {
          prompt        = 'GitFiles❯ ',
          cmd           = 'git ls-files --cached --others --exclude-standard',
        },
      },

    }

    function project_files()
      local git = require('fzf-lua.path').git_root({})
      if git then require('fzf-lua').git_files()
      else return require('fzf-lua').files() end
    end

  end,

  keys = {
    -- { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
    -- { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
    -- {
    --   "<leader>,",
    --   "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
    --   desc = "Switch Buffer",
    -- },
    -- { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    -- { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
    { "<c-p>", ":update<cr><cmd>lua project_files()<cr>", desc = "Find Files (Root Dir)" },

    -- vim.api.nvim_set_keymap("n", "<C-\\>", [[<Cmd>lua require"fzf-lua".buffers()<CR>]], {})
    -- vim.api.nvim_set_keymap("n", "<C-k>", [[<Cmd>lua require"fzf-lua".builtin()<CR>]], {})
    -- vim.api.nvim_set_keymap("n", "<C-p>", [[<Cmd>lua require"fzf-lua".files()<CR>]], {})
    -- vim.api.nvim_set_keymap("n", "<C-l>", [[<Cmd>lua require"fzf-lua".live_grep_glob()<CR>]], {})
    -- vim.api.nvim_set_keymap("n", "<C-g>", [[<Cmd>lua require"fzf-lua".grep_project()<CR>]], {})
    -- vim.api.nvim_set_keymap("n", "<F1>", [[<Cmd>lua require"fzf-lua".help_tags()<CR>]], {})


    -- -- find
    -- { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
    -- { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
    -- { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    -- { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    -- { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
    -- { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
    -- { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    -- -- git
    -- { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
    -- { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },
    -- -- search
    -- { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
    -- { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
    -- { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
    -- { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
    -- { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
    -- { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
    -- { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
    -- { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    -- { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    -- { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
    -- { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
    -- { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
    -- { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
    -- { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
    -- { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
    -- { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
    -- { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
    -- { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
    -- { "<leader>sw", LazyVim.pick("grep_cword"), desc = "Word (Root Dir)" },
    -- { "<leader>sW", LazyVim.pick("grep_cword", { root = false }), desc = "Word (cwd)" },
    -- { "<leader>sw", LazyVim.pick("grep_visual"), mode = "v", desc = "Selection (Root Dir)" },
    -- { "<leader>sW", LazyVim.pick("grep_visual", { root = false }), mode = "v", desc = "Selection (cwd)" },
    -- { "<leader>uC", LazyVim.pick("colorschemes"), desc = "Colorscheme with Preview" },
    -- {
    --   "<leader>ss",
    --   function()
    --     require("fzf-lua").lsp_document_symbols({
    --       regex_filter = symbols_filter,
    --     })
    --   end,
    --   desc = "Goto Symbol",
    -- },
    -- {
    --   "<leader>sS",
    --   function()
    --     require("fzf-lua").lsp_live_workspace_symbols({
    --       regex_filter = symbols_filter,
    --     })
    --   end,
    --   desc = "Goto Symbol (Workspace)",
    -- },
  },
  opts = {}
}
