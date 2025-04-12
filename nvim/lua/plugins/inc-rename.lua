return {
  "smjonas/inc-rename.nvim",
  config = function()
    vim.keymap.set("n", "<leader>r", ":IncRename ")
    require("inc_rename").setup()
  end,
}
