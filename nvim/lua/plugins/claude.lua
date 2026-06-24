-- Minimal Claude bridge.
--
-- Sends the current line (normal mode) or the visual selection (visual mode)
-- to the Claude Code process running in the tmux pane immediately to the LEFT
-- of nvim. Uses the same floating prompt box as pi.lua so you can add an
-- instruction along with the code.
--
-- This file intentionally registers its keymaps at import time and returns an
-- empty spec: there is no third-party plugin to install, we just drive tmux.

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

-- Does the process `pid` or any of its descendants run claude? We check the
-- executable basename (comm) rather than the full command line, because Claude
-- reports its version as the process title (so pane_current_command looks like
-- "2.1.181"), and matching the command line would also catch e.g. nvim editing
-- a file named claude.lua.
local function tree_has_claude(pid)
  local comm = vim.fn.system("ps -p " .. pid .. " -o comm= 2>/dev/null")
  comm = vim.fn.trim(comm)
  if (comm:match("[^/]+$") or comm) == "claude" then
    return true
  end
  for _, child in ipairs(vim.fn.systemlist("pgrep -P " .. pid .. " 2>/dev/null")) do
    if tree_has_claude(child) then
      return true
    end
  end
  return false
end

-- Find the pane running Claude in the current window (left, right, anywhere),
-- excluding nvim's own pane. If more than one Claude pane exists, prefer the
-- one immediately to the left of nvim. Returns a tmux target string or nil.
local function find_claude_pane()
  local current = vim.fn.trim(vim.fn.system("tmux display-message -p '#{pane_id}' 2>/dev/null"))

  local claude_panes = {}
  for _, line in ipairs(vim.fn.systemlist("tmux list-panes -F '#{pane_id} #{pane_pid}' 2>/dev/null")) do
    local pane_id, pid = line:match("^(%S+)%s+(%S+)$")
    if pane_id and pane_id ~= current and tree_has_claude(pid) then
      claude_panes[pane_id] = true
      claude_panes[#claude_panes + 1] = pane_id
    end
  end

  if #claude_panes == 0 then
    return nil
  end

  -- With multiple Claude panes, prefer the one to the left of nvim.
  if #claude_panes > 1 then
    local left = vim.fn.trim(vim.fn.system("tmux display-message -p -t '{left-of}' '#{pane_id}' 2>/dev/null"))
    if left ~= "" and claude_panes[left] then
      return left
    end
  end

  return claude_panes[1]
end

-- Paste a message into the Claude pane in this window and submit it.
local function send_to_claude(message)
  -- Copy to clipboard as a fallback if the tmux send fails.
  vim.fn.setreg("+", message)

  vim.fn.system('tmux display-message -p "#{session_name}" 2>/dev/null')
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a tmux session (copied to clipboard)", vim.log.levels.WARN)
    return
  end

  -- Prefer the detected Claude pane; fall back to the pane on the left.
  local target = find_claude_pane()
  if not target then
    vim.notify("No Claude pane in this window, trying pane on the left", vim.log.levels.WARN)
    target = "{left-of}"
  end

  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Failed to create temp file (copied to clipboard)", vim.log.levels.ERROR)
    return
  end
  f:write(message)
  f:close()

  -- Load into a named buffer, bracketed-paste it into the pane on the left,
  -- then press Enter to submit.
  local cmd = string.format(
    "tmux load-buffer -b claude-bridge %s \\; "
      .. "paste-buffer -p -d -b claude-bridge -t '%s' \\; "
      .. "send-keys -t '%s' Enter",
    vim.fn.shellescape(tmpfile),
    target,
    target
  )
  vim.fn.system(cmd)
  local ok = vim.v.shell_error == 0
  vim.fn.delete(tmpfile)

  if not ok then
    vim.notify("Failed to send to Claude pane (copied to clipboard)", vim.log.levels.WARN)
  end
end

local function send_line_prompt()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local location = string.format("%s:%d", file, line)

  open_prompt(" claude line " .. line .. " ", function(input)
    if input == "" then
      send_to_claude(string.format("Look at this location: %s", location))
    else
      send_to_claude(string.format("Location: %s\n\n%s", location, input))
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

  local title = " claude selection " .. start_line .. "-" .. end_line .. " "
  open_prompt(title, function(input)
    if input == "" then
      send_to_claude(string.format(
        "Look at this code from %s:\n\n```%s\n%s\n```",
        header,
        ft,
        selection
      ))
    else
      send_to_claude(string.format(
        "%s\n\nFrom %s:\n```%s\n%s\n```",
        input,
        header,
        ft,
        selection
      ))
    end
  end)
end

vim.keymap.set("n", "<leader>k", function()
  vim.cmd("update")
  send_line_prompt()
end, { desc = "Claude: send current line" })

vim.keymap.set("v", "<leader>k", function()
  vim.cmd("update")
  send_selection_prompt()
end, { desc = "Claude: send selection" })

return {}
