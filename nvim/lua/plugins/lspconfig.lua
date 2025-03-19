
return {
 'neovim/nvim-lspconfig',
  -- keys = {
  --
  --   { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
  --   { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
  --   { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
  --   { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
  --   { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  --   { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
  --   { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
  --   { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
  --   { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
  --   { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
  --   { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
  --   { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
  --   { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
  --   { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
  --   { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
  --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
  --   { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
  --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
  --   { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
  --     desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
  --   { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
  --     desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
  --
  -- },
  config = function()



      -- --  This function gets run when an LSP attaches to a particular buffer.
      -- --    That is to say, every time a new file is opened that is associated with
      -- --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      -- --    function will be executed to configure the current buffer
      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      --   callback = function(event)
      --     -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      --     -- to define small helper and utility functions so you don't have to repeat yourself.
      --     --
      --     -- In this case, we create a function that lets us more easily define mappings specific
      --     -- for LSP related items. It sets the mode, buffer and description for us each time.
      --     local map = function(keys, func, desc, mode)
      --       mode = mode or 'n'
      --       vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      --     end
      --
      --     -- Jump to the definition of the word under your cursor.
      --     --  This is where a variable was first declared, or where a function is defined, etc.
      --     --  To jump back, press <C-t>.
      --     map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      --
      --     -- Find references for the word under your cursor.
      --     map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      --
      --     -- Jump to the implementation of the word under your cursor.
      --     --  Useful when your language has ways of declaring types without an actual implementation.
      --     map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      --
      --     -- Jump to the type of the word under your cursor.
      --     --  Useful when you're not sure what type a variable is and you want to see
      --     --  the definition of its *type*, not where it was *defined*.
      --     map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
      --
      --     -- Fuzzy find all the symbols in your current document.
      --     --  Symbols are things like variables, functions, types, etc.
      --     map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      --
      --     -- Fuzzy find all the symbols in your current workspace.
      --     --  Similar to document symbols, except searches over your entire project.
      --     map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      --
      --     -- Rename the variable under your cursor.
      --     --  Most Language Servers support renaming across files, etc.
      --     map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      --
      --     -- Execute a code action, usually your cursor needs to be on top of an error
      --     -- or a suggestion from your LSP for this to activate.
      --     map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
      --
      --     -- WARN: This is not Goto Definition, this is Goto Declaration.
      --     --  For example, in C this would take you to the header.
      --     map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      --
      --     -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
      --     ---@param client vim.lsp.Client
      --     ---@param method vim.lsp.protocol.Method
      --     ---@param bufnr? integer some lsp support methods only in specific files
      --     ---@return boolean
      --     local function client_supports_method(client, method, bufnr)
      --       if vim.fn.has 'nvim-0.11' == 1 then
      --         return client:supports_method(method, bufnr)
      --       else
      --         return client.supports_method(method, { bufnr = bufnr })
      --       end
      --     end
      --
      --     -- The following two autocommands are used to highlight references of the
      --     -- word under your cursor when your cursor rests there for a little while.
      --     --    See `:help CursorHold` for information about when this is executed
      --     --
      --     -- When you move your cursor, the highlights will be cleared (the second autocommand).
      --     local client = vim.lsp.get_client_by_id(event.data.client_id)
      --     if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      --       local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      --       vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      --         buffer = event.buf,
      --         group = highlight_augroup,
      --         callback = vim.lsp.buf.document_highlight,
      --       })
      --
      --       vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      --         buffer = event.buf,
      --         group = highlight_augroup,
      --         callback = vim.lsp.buf.clear_references,
      --       })
      --
      --       vim.api.nvim_create_autocmd('LspDetach', {
      --         group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      --         callback = function(event2)
      --           vim.lsp.buf.clear_references()
      --           vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      --         end,
      --       })
      --     end
      --
      --     -- The following code creates a keymap to toggle inlay hints in your
      --     -- code, if the language server you are using supports them
      --     --
      --     -- This may be unwanted, since they displace some of your code
      --     if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      --       map('<leader>th', function()
      --         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      --       end, '[T]oggle Inlay [H]ints')
      --     end
      --   end,
      -- })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      },
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }


    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/ts_ls.lua
    require'lspconfig'.ts_ls.setup{
      capabilities = capabilities,
    }

    -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/eslint.lua
    require'lspconfig'.eslint.setup{
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end,
    }
  end,
}
