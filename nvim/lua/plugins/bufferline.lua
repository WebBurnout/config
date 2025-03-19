

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
    { "<C-j>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<C-k>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
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

    bufferline.setup {
      options = {
        separator_style = "slant",
        show_buffer_close_icons = false,
        offsets = { { filetype = "neo-tree", separator = true } },
      },
    }

  end,
}


