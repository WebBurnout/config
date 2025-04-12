

-- Bufferline provides file names at the top
return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  lazy = false,
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<C-k>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<C-j>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "<C-h>", ":update<cr>:bd<cr>", desc = "Delete Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },

    { "<M-1>", "<cmd>lua require('bufferline').go_to(1, true)<cr>", desc = "Move to first buffer" },
    { "<M-2>", "<cmd>lua require('bufferline').go_to(2, true)<cr>", desc = "Move to second buffer" },
    { "<M-3>", "<cmd>lua require('bufferline').go_to(3, true)<cr>", desc = "Move to third buffer" },
    { "<M-4>", "<cmd>lua require('bufferline').go_to(4, true)<cr>", desc = "Move to fourth buffer" },
    { "<M-5>", "<cmd>lua require('bufferline').go_to(5, true)<cr>", desc = "Move to fifth buffer" },
    { "<M-6>", "<cmd>lua require('bufferline').go_to(6, true)<cr>", desc = "Move to sixth buffer" },
    { "<M-7>", "<cmd>lua require('bufferline').go_to(7, true)<cr>", desc = "Move to seventh buffer" },
    { "<M-8>", "<cmd>lua require('bufferline').go_to(8, true)<cr>", desc = "Move to eighth buffer" },
    { "<M-9>", "<cmd>lua require('bufferline').go_to(9, true)<cr>", desc = "Move to ninth buffer" },
  },
  config = function()
    local bufferline = require("bufferline")

    local tabBG = '#11111b'
    local bgTabBG = '#1e1e2e'

    bufferline.setup {
      options = {
        separator_style = "slant",
        show_buffer_close_icons = false,
        offsets = { { filetype = "neo-tree", separator = true } },
      },
      highlights = {
        fill = {
          fg = tabBG,
          bg = tabBG,
        },
        separator = {
          fg = tabBG,
          bg = bgTabBG,
        },
        separator_selected = {
          fg = tabBG,
          bg = 'none',
        },
        separator_visible = {
          fg = tabBG,
          bg = 'none',
        },
        background = {
          bg = bgTabBG
        },

        -- fill = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- background = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- tab = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- tab_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- tab_separator = {
        --   fg = '<colour-value-here>',
        --   bg = '<colour-value-here>',
        -- },
        -- tab_separator_selected = {
        --   fg = '<colour-value-here>',
        --   bg = '<colour-value-here>',
        --   sp = '<colour-value-here>',
        --   underline = '<colour-value-here>',
        -- },
        -- tab_close = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- close_button = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- close_button_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- close_button_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- buffer_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- buffer_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- numbers = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- numbers_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- numbers_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- diagnostic = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- diagnostic_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- diagnostic_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- hint = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- hint_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- hint_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- hint_diagnostic = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- hint_diagnostic_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- hint_diagnostic_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- info = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- info_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- info_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- info_diagnostic = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- info_diagnostic_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- info_diagnostic_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- warning = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- warning_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- warning_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- warning_diagnostic = {
        --     fg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- warning_diagnostic_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- warning_diagnostic_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- error = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        -- },
        -- error_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- error_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- error_diagnostic = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        -- },
        -- error_diagnostic_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- error_diagnostic_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     sp = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- modified = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- modified_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- modified_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- duplicate_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     italic = true,
        -- },
        -- duplicate_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     italic = true,
        -- },
        -- duplicate = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     italic = true,
        -- },
        -- separator_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- separator_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- separator = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- indicator_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- indicator_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- pick_selected = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- pick_visible = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- pick = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        --     bold = true,
        --     italic = true,
        -- },
        -- offset_separator = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- },
        -- trunc_marker = {
        --     fg = '<colour-value-here>',
        --     bg = '<colour-value-here>',
        -- }

      },
    }

  end,
}


