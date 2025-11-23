

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

      files = {
        rg_opts = [[--color=never --hidden --no-ignore-vcs --files -g "!{.git,node_modules}"]],
      },

      git = {
        files = {
          silent = true,
          prompt = '❯ ',
          cmd    = 'git ls-files --cached --others --exclude-standard',
        },
      },
      avante = {
        files = {
          prompt = '❯ ',
        },
      },

      winopts = {
        preview = {
          flip_columns = 1000,
          vertical = "down:75%",
        },
      },

    }

    -- it will use this for copilot chat with this setting
    require('fzf-lua').register_ui_select()

    function files_root_dir()
      local root = vim.fn.system("git rev-parse --show-toplevel")
      root = root:gsub("\n$", "")
      if vim.v.shell_error == 0 then
        print('root: ' .. root)
        require('fzf-lua').files({ cwd = root })
      else 
        print('not in git repo')
        require('fzf-lua').files()
      end

    end

    function live_grep_root_dir()
      local root = vim.fn.system("git rev-parse --show-toplevel")
      root = root:gsub("\n$", "")
      if vim.v.shell_error == 0 then
        require('fzf-lua').live_grep_glob({ cwd = root })
      else 
        require('fzf-lua').live_grep_glob()
      end
    end

    function project_files()
      vim.fn.system("git rev-parse --is-inside-work-tree")
      if vim.v.shell_error == 0 then
        require('fzf-lua').git_files()
      else
        require('fzf-lua').files()
      end
    end

  end,

  keys = {
    { "<c-p>", ":update<cr><cmd>lua project_files()<cr>", desc = "Find Files (Root Dir)" },
    { "<Leader>s", ":update<cr><cmd>lua files_root_dir()<cr>", desc = "Find Files (Root Dir)" },
    { "<Leader>g", ':update<cr><cmd>lua live_grep_root_dir()<cr>', desc = "Grep (Root Dir)" },

    -- { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },

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
