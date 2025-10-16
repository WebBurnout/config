

-- snippets
return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",


  config = function()
    vim.keymap.set({"i", "s"}, "<C-j>", function() require("luasnip").jump(1) end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-k>", function() require("luasnip").jump(-1) end, {silent = true})

    require("luasnip.loaders.from_snipmate").lazy_load()
  end,
}
