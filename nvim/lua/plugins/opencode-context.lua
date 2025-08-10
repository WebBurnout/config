return {
  dir = '/Users/tim/code/opencode-context.nvim',
  dev = true,
  keys = {
    { "<leader>oc", "<cmd>OpencodeSend<cr>", desc = "Send prompt to opencode" },
    { "<leader>oc", "<cmd>OpencodeSend<cr>", mode = "v", desc = "Send prompt to opencode" },
    { "<leader>ot", "<cmd>OpencodeSwitchMode<cr>", desc = "Toggle opencode mode" },
    { "<leader>op", "<cmd>OpencodePrompt<cr>", desc = "Open opencode persistent prompt" },
  },
  cmd = { "OpencodeSend", "OpencodeSwitchMode" },
}
