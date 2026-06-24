return {
  "carderne/pi-nvim",
  config = function()
    local pi = require("pi-nvim")
    pi.setup({
      set_default_keymaps = false,
    })

    local function select_session_for_cwd()
      local cwd = vim.fn.getcwd(0)
      local info_paths = vim.fn.glob("/tmp/pi-nvim-sockets/*.info", false, true)
      local best_session
      local best_length = 0

      for _, info_path in ipairs(info_paths) do
        local lines = vim.fn.readfile(info_path)
        local ok, info = pcall(vim.json.decode, lines[1] or "")
        local socket = info_path:gsub("%.info$", "")
        local session_cwd = ok and info and info.cwd

        if session_cwd and vim.uv.fs_stat(socket) then
          local contains_cwd = cwd == session_cwd
            or cwd:sub(1, #session_cwd + 1) == session_cwd .. "/"

          if contains_cwd and #session_cwd > best_length then
            best_length = #session_cwd
            best_session = socket
          end
        end
      end

      pi.config.socket_path = best_session
    end

    local function send_to_pi(message)
      select_session_for_cwd()
      pi.prompt(message)
    end

    local function open_prompt(title, on_send)
      local width = math.min(72, math.floor(vim.o.columns * 0.5))
      local min_height = 4
      local max_height = 6
      local buf = vim.api.nvim_create_buf(false, true)

      vim.bo[buf].buftype = "nofile"
      vim.b[buf].completion = false
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = min_height,
        row = math.floor(vim.o.lines / 3),
        col = math.floor((vim.o.columns - width - 2) / 2),
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
      })
      vim.wo[win].wrap = true
      vim.wo[win].linebreak = true

      local function resize()
        if not vim.api.nvim_win_is_valid(win) then return end

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local rows = 0
        for _, text in ipairs(lines) do
          rows = rows + math.max(1, math.ceil(math.max(#text, 1) / width))
        end
        vim.api.nvim_win_set_height(win, math.max(min_height, math.min(max_height, rows)))
      end

      local function close()
        vim.cmd("stopinsert")
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end

      local function send()
        local input = vim.fn.trim(table.concat(
          vim.api.nvim_buf_get_lines(buf, 0, -1, false),
          "\n"
        ))
        close()
        on_send(input)
      end

      local opts = { buffer = buf, noremap = true, silent = true }
      vim.keymap.set({ "i", "n" }, "<CR>", send, opts)
      vim.keymap.set({ "i", "n" }, "<Esc>", close, opts)
      vim.keymap.set({ "i", "n" }, "<C-c>", close, opts)

      vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        buffer = buf,
        callback = resize,
      })

      vim.cmd("startinsert")
    end

    local function send_line_prompt()
      local file = vim.fn.expand("%:p")
      local line = vim.fn.line(".")
      local location = string.format("%s:%d", file, line)

      open_prompt(" pi line " .. line .. " ", function(input)
        if input == "" then
          send_to_pi(string.format("Look at this location: %s", location))
        else
          send_to_pi(string.format("Location: %s\n\n%s", location, input))
        end
      end)
    end

    local function send_selection_prompt()
      vim.cmd("normal! \27")

      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local ok, lines = pcall(
        vim.fn.getregion,
        start_pos,
        end_pos,
        { type = vim.fn.visualmode() }
      )
      if not ok or not lines or #lines == 0 then
        vim.notify("Empty selection", vim.log.levels.WARN)
        return
      end

      local selection = table.concat(lines, "\n")
      if selection == "" then
        vim.notify("Empty selection", vim.log.levels.WARN)
        return
      end

      local file = vim.fn.expand("%:p")
      local start_line = start_pos[2]
      local end_line = end_pos[2]
      local ft = vim.bo.filetype
      local header = string.format("%s lines %d-%d", file, start_line, end_line)

      local title = " pi selection " .. start_line .. "-" .. end_line .. " "
      open_prompt(title, function(input)
        if input == "" then
          send_to_pi(string.format(
            "Look at this code from %s:\n\n```%s\n%s\n```",
            header,
            ft,
            selection
          ))
        else
          send_to_pi(string.format(
            "%s\n\nFrom %s:\n```%s\n%s\n```",
            input,
            header,
            ft,
            selection
          ))
        end
      end)
    end

    vim.keymap.set("n", "<leader>j", function()
      vim.cmd("update")
      send_line_prompt()
    end, { desc = "Pi: send current line" })

    vim.keymap.set("v", "<leader>j", function()
      vim.cmd("update")
      send_selection_prompt()
    end, { desc = "Pi: send selection" })
  end,
}
