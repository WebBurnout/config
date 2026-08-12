-- Sends the current line (normal mode) or the visual selection (visual mode)
-- to the pi session running in a tmux pane in the same window.
--
-- The pane is matched to a pi session via the pid recorded in the socket
-- manifest, then the prompt is delivered over that session's unix socket. We
-- call send_raw rather than pi.prompt, because prompt() will hijack any nvim
-- terminal buffer named ":pi" and ignore the socket entirely.

local SOCKETS_DIR = "/tmp/pi-nvim-sockets"

return {
  "carderne/pi-nvim",
  config = function()
    local bridge = require("agent-bridge")
    local pi = require("pi-nvim")

    pi.setup({
      set_default_keymaps = false,
    })

    -- Live pi sessions, keyed by pid. A session that was SIGKILLed leaves its
    -- socket and manifest behind, so the pid has to be probed.
    local function live_sessions()
      local sessions = {}
      for _, info_path in ipairs(vim.fn.glob(SOCKETS_DIR .. "/*.info", false, true)) do
        local lines = vim.fn.readfile(info_path)
        local ok, info = pcall(vim.json.decode, lines[1] or "")
        local socket = info_path:gsub("%.info$", "")
        if ok and info and info.pid and vim.uv.fs_stat(socket) and bridge.pid_alive(info.pid) then
          sessions[tostring(info.pid)] = { socket = socket, cwd = info.cwd }
        end
      end
      return sessions
    end

    -- Prefer the manifest's cwd over the pane's: it is where pi was actually
    -- started, which is what its file paths are relative to.
    local function find_pi_socket(context)
      local sessions = live_sessions()
      return bridge.find_pane(context, function(_, pids)
        for _, pid in ipairs(pids) do
          local session = sessions[pid]
          if session then
            return session.socket, session.cwd
          end
        end
      end)
    end

    local function send_to_pi(socket, message)
      pi.config.socket_path = socket
      pi.send_raw({ type = "prompt", message = message }, function(err, resp)
        if err or not (resp and resp.ok) then
          vim.fn.setreg("+", message)
          vim.notify(
            "Failed to send to pi (copied to clipboard): " .. (err or resp and resp.error or "unknown"),
            vim.log.levels.ERROR
          )
        end
      end)
    end

    bridge.bind({
      name = "pi",
      keymap = "<leader>j",
      find = find_pi_socket,
      send = send_to_pi,
    })
  end,
}
