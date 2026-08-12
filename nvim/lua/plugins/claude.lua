-- Sends the current line (normal mode) or the visual selection (visual mode)
-- to the Claude Code process running in a tmux pane in the same window.
--
-- This file intentionally registers its keymaps at import time and returns an
-- empty spec: there is no third-party plugin to install, we just drive tmux.

local bridge = require("agent-bridge")

-- Match on the executable basename rather than the full command line, because
-- Claude reports its version as the process title (so pane_current_command
-- looks like "2.1.181"), and matching the command line would also catch e.g.
-- nvim editing a file named claude.lua.
local function find_claude_pane(context)
  return bridge.find_pane(context, function(pane, pids)
    for _, pid in ipairs(pids) do
      if bridge.comm(pid) == "claude" then
        return pane.id
      end
    end
  end)
end

-- Bracketed-paste the message into the Claude pane, then submit it.
local function send_to_claude(target, message)
  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, "w")
  if not f then
    vim.fn.setreg("+", message)
    vim.notify("Failed to create temp file (copied to clipboard)", vim.log.levels.ERROR)
    return
  end
  f:write(message)
  f:close()

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
    vim.fn.setreg("+", message)
    vim.notify("Failed to send to Claude pane (copied to clipboard)", vim.log.levels.ERROR)
  end
end

bridge.bind({
  name = "claude",
  keymap = "<leader>k",
  find = find_claude_pane,
  send = send_to_claude,
})

return {}
