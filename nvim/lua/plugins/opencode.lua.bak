return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Uncomment this for better UI experience
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      port = 9001,
      -- Disable provider so it doesn't try to start a new instance
      provider = {
        enabled = false,
      },
      ask = {
        prompt = "Ask opencode: ",
        blink_cmp_sources = { "opencode", "buffer" },
        snacks = {
          icon = false,
          win = {
            title_pos = "left",
            relative = "cursor",
            row = 1, -- Row below the cursor
            col = 0, -- Align with the cursor
            width = 60,
            max_width = 60,
            height = 5,
            wo = {
              wrap = true,
            },
          },
        },
      },
      -- Configure contexts to use absolute paths
      contexts = {
        ["@buffer"] = function()
          return vim.fn.expand('%:p')  -- Full absolute path instead of relative
        end,
        ["@buffers"] = function()
          local buffers = {}
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= '' then
                table.insert(buffers, vim.fn.fnamemodify(name, ':p'))  -- Absolute path
              end
            end
          end
          return table.concat(buffers, '\n')
        end,
        ["@this"] = function()
          -- For visual selection or cursor position
          local mode = vim.fn.mode()
          if mode:match('[vV\22]') then
            -- Visual mode - return selection with absolute path
            local start_pos = vim.fn.getpos("'<")
            local end_pos = vim.fn.getpos("'>")
            local lines = vim.fn.getline(start_pos[2], end_pos[2])
            return vim.fn.expand('%:p') .. ':' .. start_pos[2] .. '-' .. end_pos[2]
          else
            -- Normal mode - return cursor position with absolute path
            local pos = vim.fn.getcurpos()
            return vim.fn.expand('%:p') .. ':' .. pos[2] .. ':' .. pos[3]
          end
        end,
      },
    }
    
    vim.keymap.set(
      { "n", "x" }, "<leader>oa",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode" }
    )

    vim.keymap.set(
      { "n", "x" }, "<leader>ox",
      function() require("opencode").select() end,
      { desc = "Execute opencode action…" }
    )

    vim.keymap.set(
      { "n", "x" }, "<leader>op",
      function() require("opencode").prompt("@this") end,
      { desc = "Add to opencode" }
    )

  end,
}
