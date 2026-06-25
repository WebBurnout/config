
return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  config = function()
    require('copilot').setup {
      -- Default root_dir crashes with ENOENT when the cwd no longer exists
      -- (uv.cwd() returns nil -> assert fires). Pass a string source to
      -- vim.fs.root to skip its internal assert(uv.cwd()) branch, and guard
      -- the cwd fallback so this can never throw.
      root_dir = function()
        local ok, cwd = pcall(vim.uv.cwd)
        local fallback = (ok and cwd) or vim.env.HOME or "/"
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then
          return fallback
        end
        return vim.fs.root(bufname, ".git") or vim.fs.dirname(bufname) or fallback
      end,
      panel = { enabled = false },
      suggestion = { enabled = false },  -- Disable native suggestions - using blink-cmp-copilot instead
      filetypes = {
        markdown = false,
        ["*"] = true,
      },
    }
  end,
}
