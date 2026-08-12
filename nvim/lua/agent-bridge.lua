-- Shared plumbing for sending code context from nvim to a coding agent
-- running in a neighbouring tmux pane (see plugins/claude.lua, plugins/pi.lua).

local M = {}

function M.in_tmux()
  return vim.env.TMUX_PANE ~= nil
end

function M.pid_alive(pid)
  vim.fn.system("kill -0 " .. pid .. " 2>/dev/null")
  return vim.v.shell_error == 0
end

--- @param pid string|number
--- @return string[] pids  `pid` and all of its descendants
function M.process_tree(pid)
  local pids = { tostring(pid) }
  for _, child in ipairs(vim.fn.systemlist("pgrep -P " .. pid .. " 2>/dev/null")) do
    vim.list_extend(pids, M.process_tree(child))
  end
  return pids
end

function M.comm(pid)
  local comm = vim.fn.trim(vim.fn.system("ps -p " .. pid .. " -o comm= 2>/dev/null"))
  return comm:match("[^/]+$") or comm
end

--- How specifically `cwd` covers `path`: the length of the containing prefix,
--- or 0 if it doesn't contain it at all.
local function containment(cwd, path)
  if cwd == "" or path == "" then
    return 0
  end
  if path == cwd or path:sub(1, #cwd + 1) == cwd .. "/" then
    return #cwd
  end
  return 0
end

--- Find the agent in nvim's tmux window. `match` is called with each pane other
--- than nvim's own, and returns an opaque target value plus that agent's cwd
--- (defaulting to the pane's own cwd), or nil if the pane isn't running the
--- agent.
---
--- The agent whose cwd most specifically contains `context` wins, so a session
--- open on the file's own project beats one that merely happens to be nearby.
--- Equally good matches are settled by taking the nearest pane to the left of
--- nvim, which keeps the choice predictable.
---
--- Panes are resolved through $TMUX_PANE rather than `display-message`, which
--- reports the attached client's active pane and so would look at the wrong
--- window whenever nvim isn't the focused pane.
--- @param context string  Absolute path the message is about
--- @param match fun(pane: { id: string, path: string }, pids: string[]): any|nil, string|nil
--- @return any|nil target
function M.find_pane(context, match)
  local self_pane = vim.env.TMUX_PANE
  local self_left
  local candidates = {}

  local panes = vim.fn.systemlist(string.format(
    "tmux list-panes -t '%s' -F '#{pane_id} #{pane_pid} #{pane_left} #{pane_current_path}' 2>/dev/null",
    self_pane
  ))

  for _, line in ipairs(panes) do
    local pane_id, pane_pid, left, pane_path = line:match("^(%S+)%s+(%S+)%s+(%S+)%s+(.*)$")
    if pane_id == self_pane then
      self_left = tonumber(left)
    elseif pane_id then
      local target, cwd = match({ id = pane_id, path = pane_path }, M.process_tree(pane_pid))
      if target ~= nil then
        table.insert(candidates, {
          left = tonumber(left),
          target = target,
          depth = containment(cwd or pane_path, context),
        })
      end
    end
  end

  local best
  for _, candidate in ipairs(candidates) do
    if not best or candidate.depth > best.depth then
      best = candidate
    elseif candidate.depth == best.depth and self_left and candidate.left < self_left then
      if best.left >= self_left or candidate.left > best.left then
        best = candidate
      end
    end
  end

  return best and best.target
end

function M.open_prompt(title, on_send)
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

--- Register normal and visual mode keymaps that prompt for an instruction and
--- send it, along with the current line or selection, to an agent.
--- @param opts { name: string, keymap: string, find: fun(context: string): any|nil, send: fun(target: any, message: string) }
function M.bind(opts)
  -- The path the agent is being asked about, used to pick the session working
  -- on that project.
  local function context()
    local file = vim.fn.expand("%:p")
    return file ~= "" and file or vim.fn.getcwd(0)
  end

  -- Resolve the agent up front so an unreachable agent is reported before the
  -- user types anything, then again on send in case the pane went away.
  local function find_target()
    if not M.in_tmux() then
      vim.notify("Not in a tmux session, cannot reach " .. opts.name, vim.log.levels.ERROR)
      return nil
    end
    local target = opts.find(context())
    if not target then
      vim.notify("No live " .. opts.name .. " pane in this tmux window", vim.log.levels.ERROR)
      return nil
    end
    return target
  end

  local function send(message)
    local target = find_target()
    if not target then
      vim.fn.setreg("+", message)
      vim.notify("Copied to clipboard instead", vim.log.levels.WARN)
      return
    end
    opts.send(target, message)
  end

  local function send_line()
    if not find_target() then return end

    local location = string.format("%s:%d", vim.fn.expand("%:p"), vim.fn.line("."))
    local title = string.format(" %s line %d ", opts.name, vim.fn.line("."))

    M.open_prompt(title, function(input)
      if input == "" then
        send(string.format("Look at this location: %s", location))
      else
        send(string.format("Location: %s\n\n%s", location, input))
      end
    end)
  end

  local function send_selection()
    vim.cmd("normal! \27")

    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local ok, lines = pcall(
      vim.fn.getregion,
      start_pos,
      end_pos,
      { type = vim.fn.visualmode() }
    )
    local selection = (ok and lines) and table.concat(lines, "\n") or ""
    if selection == "" then
      vim.notify("Empty selection", vim.log.levels.WARN)
      return
    end

    if not find_target() then return end

    local start_line = start_pos[2]
    local end_line = end_pos[2]
    local ft = vim.bo.filetype
    local header = string.format("%s lines %d-%d", vim.fn.expand("%:p"), start_line, end_line)
    local title = string.format(" %s selection %d-%d ", opts.name, start_line, end_line)

    M.open_prompt(title, function(input)
      if input == "" then
        send(string.format("Look at this code from %s:\n\n```%s\n%s\n```", header, ft, selection))
      else
        send(string.format("%s\n\nFrom %s:\n```%s\n%s\n```", input, header, ft, selection))
      end
    end)
  end

  vim.keymap.set("n", opts.keymap, function()
    vim.cmd("update")
    send_line()
  end, { desc = opts.name .. ": send current line" })

  vim.keymap.set("v", opts.keymap, function()
    vim.cmd("update")
    send_selection()
  end, { desc = opts.name .. ": send selection" })
end

return M
