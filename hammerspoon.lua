-- Hammerspoon replacement for Moom window layouts.
-- Reload from the menu bar or with: hs -c 'hs.reload()'

hs.menuIcon(true)

-- Load IPC so the `hs` CLI can talk to this instance (debugging/introspection).
require("hs.ipc")

local hyper = {"cmd", "ctrl", "alt", "shift"}

local function log(message)
  print(os.date("%Y-%m-%d %H:%M:%S") .. " [window] " .. message)
end

local function focusedWindow()
  local win = hs.window.focusedWindow()
  if not win then
    hs.alert.show("No focused window")
    return nil
  end
  return win
end

-- Each width key toggles: first press puts the window on the left at that
-- width, pressing again flips it to the right.
local widths = {
  { key = "q", name = "1/4",  w = 1 / 4 },
  { key = "w", name = "1/3",  w = 1 / 3 },
  { key = "e", name = "1/2",  w = 1 / 2 },
  { key = "r", name = "2/3",  w = 2 / 3 },
  { key = "t", name = "3/4",  w = 3 / 4 },
  { key = "y", name = "Wide", w = 14 / 15 },
}

local layouts = {
  { title = "Maximize", unit = hs.layout.maximized },
}

for _, spec in ipairs(widths) do
  spec.left  = { title = spec.name .. " Left",  unit = { x = 0,          y = 0, w = spec.w, h = 1 } }
  spec.right = { title = spec.name .. " Right", unit = { x = 1 - spec.w, y = 0, w = spec.w, h = 1 } }
  table.insert(layouts, spec.left)
  table.insert(layouts, spec.right)
end

local layoutsBySlug = {}
for _, layout in ipairs(layouts) do
  layout.slug = layout.title:lower():gsub("[^%w]+", "-"):gsub("^%-", ""):gsub("%-$", "")
  layoutsBySlug[layout.slug] = layout
end

local layoutAlert

local function showLayoutAlert(title)
  if layoutAlert then
    hs.alert.closeSpecific(layoutAlert, 0)
  end
  layoutAlert = hs.alert.show(title, 0.5)
end

local function applyLayout(layout)
  log("applying layout: " .. layout.title)
  local win = focusedWindow()
  if win then
    win:moveToUnit(layout.unit, 0)
    showLayoutAlert(layout.title)
  end
end

-- Centered: fixed-size window centered on the current screen.
local centered = { w = 1900, h = 1300 }

local function applyCentered()
  log("applying layout: Centered")
  local win = focusedWindow()
  if win then
    local sf = win:screen():frame()
    local w = math.min(centered.w, sf.w)
    local h = math.min(centered.h, sf.h)
    win:setFrame({
      x = sf.x + (sf.w - w) / 2,
      y = sf.y + (sf.h - h) / 2,
      w = w,
      h = h,
    }, 0)
    showLayoutAlert("Centered")
  end
end

-- A window "is" a layout if its frame matches within a few pixels.
local function frameMatchesUnit(win, unit)
  local sf = win:screen():frame()
  local f = win:frame()
  local eps = 5
  return math.abs(f.x - (sf.x + unit.x * sf.w)) < eps
    and math.abs(f.y - (sf.y + unit.y * sf.h)) < eps
    and math.abs(f.w - unit.w * sf.w) < eps
    and math.abs(f.h - unit.h * sf.h) < eps
end

for _, spec in ipairs(widths) do
  hs.hotkey.bind(hyper, spec.key, function()
    log("hotkey: hyper + " .. spec.key .. " (" .. spec.name .. ")")
    local win = focusedWindow()
    if not win then return end
    if frameMatchesUnit(win, spec.left.unit) then
      applyLayout(spec.right)
    else
      applyLayout(spec.left)
    end
  end)
end

hs.hotkey.bind(hyper, "m", function()
  log("hotkey: hyper + m")
  applyLayout(layoutsBySlug["maximize"])
end)

hs.hotkey.bind(hyper, "b", function()
  log("hotkey: hyper + b")
  applyCentered()
end)

-- URL hooks for manual testing, e.g.
-- open -g 'hammerspoon://window?action=left-14-15'
hs.urlevent.bind("window", function(_eventName, params)
  local action = params.action or params[1]
  log("url action: " .. tostring(action))
  if action == "centered" then
    applyCentered()
    return
  end
  local layout = layoutsBySlug[action]
  if layout then
    applyLayout(layout)
  else
    hs.alert.show("Unknown window action: " .. tostring(action))
  end
end)

-- Voice dictation via whisper.cpp.
-- Toggle with hyper + d: press once to start recording, again to stop,
-- transcribe, and paste the text wherever the cursor is.
-- Requires: `brew install whisper-cpp ffmpeg` and a model in ~/.local/share/whisper-models.
-- First run prompts for Microphone access for Hammerspoon.
local whisper = {
  wav = "/tmp/hs-whisper-ptt.wav",
  script = os.getenv("HOME") .. "/code/config/bin/whisper-transcribe.sh",
  mic = ":default", -- follows the input device selected in System Settings → Sound
  -- (use an index like ":0" to pin a specific device; list them with:
  --  ffmpeg -f avfoundation -list_devices true -i "")
  recording = false,
  recordTask = nil,
  alertId = nil,
}

local function whisperPaste(text)
  text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    hs.alert.show("🎤 nothing heard")
    return
  end
  local original = hs.pasteboard.getContents()
  hs.pasteboard.setContents(text)
  hs.eventtap.keyStroke({ "cmd" }, "v")
  hs.timer.doAfter(0.4, function()
    if original ~= nil then hs.pasteboard.setContents(original) end
  end)
end

local function whisperTranscribe()
  hs.alert.show("🧠 Transcribing", 0.6)
  hs.task.new("/bin/bash", function(code, stdout, _stderr)
    if code == 0 then
      whisperPaste(stdout)
    else
      log("whisper transcribe failed: rc=" .. tostring(code))
      hs.alert.show("🎤 transcription failed")
    end
  end, { whisper.script, whisper.wav }):start()
end

local function whisperToggle()
  if whisper.recording then
    log("whisper: stop")
    whisper.recording = false
    if whisper.alertId then
      hs.alert.closeSpecific(whisper.alertId, 0)
      whisper.alertId = nil
    end
    if whisper.recordTask and whisper.recordTask:isRunning() then
      whisper.recordTask:terminate() -- ffmpeg finalizes the wav, then its callback transcribes
    end
  else
    log("whisper: start")
    os.remove(whisper.wav)
    whisper.recordTask = hs.task.new("/opt/homebrew/bin/ffmpeg", function()
      if not whisper.recording then whisperTranscribe() end
    end, { "-y", "-f", "avfoundation", "-i", whisper.mic, "-ar", "16000", "-ac", "1", whisper.wav })
    if whisper.recordTask:start() then
      whisper.recording = true
      -- Keep the alert up for the whole recording (closed on stop above).
      whisper.alertId = hs.alert.show("🎤 Listening", 86400)
    else
      hs.alert.show("🎤 couldn't start recording")
    end
  end
end

hs.hotkey.bind(hyper, "f", function()
  log("hotkey: hyper + f (dictate)")
  whisperToggle()
end)

-- Cycle the audio output device (hyper + z), showing the one we switched to.
-- Requires: `brew install switchaudio-osx`.
local switchAudio = "/opt/homebrew/bin/SwitchAudioSource"
local audioAlert

local function showAudioAlert(text)
  if audioAlert then
    hs.alert.closeSpecific(audioAlert, 0)
  end
  audioAlert = hs.alert.show(text, 1)
end

hs.hotkey.bind(hyper, "z", function()
  log("hotkey: hyper + z (audio source)")
  hs.task.new(switchAudio, function(code, _stdout, _stderr)
    if code ~= 0 then
      showAudioAlert("🔈 audio switch failed")
      return
    end
    -- Report the device we landed on.
    hs.task.new(switchAudio, function(_c, current)
      local name = (current or ""):gsub("%s+$", "")
      showAudioAlert("🔈 " .. name)
    end, { "-c" }):start()
  end, { "-n" }):start()
end)

-- Seat change reminder. The clock runs only while an external monitor is
-- connected and the machine is being used; after an hour of that, a pill
-- appears in the corner and stays until clicked, which starts the next hour.
local seat = {
  goal = 60 * 60,
  poll = 10,
  idleCutoff = 60, -- no keyboard/mouse for this long and the clock pauses
  active = 0,
  connected = false,
  canvas = nil,
  timer = nil,
}

local function seatMonitorConnected()
  for _, screen in ipairs(hs.screen.allScreens()) do
    if not screen:name():match("Built%-in") then return true end
  end
  return false
end

local function seatDismiss()
  if seat.canvas then
    seat.canvas:delete(0.2)
    seat.canvas = nil
  end
  seat.active = 0
end

local function seatShow()
  if seat.canvas then return end
  log("seat: nagging")

  local w, h = 340, 64
  local margin = 20
  local sf = hs.screen.mainScreen():frame()
  local canvas = hs.canvas.new({ x = sf.x + sf.w - w - margin, y = sf.y + margin, w = w, h = h })

  canvas:appendElements({
    type = "rectangle",
    action = "fill",
    frame = { x = 0, y = 0, w = w, h = h },
    roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 },
    fillGradient = "linear",
    fillGradientAngle = 90,
    fillGradientColors = {
      { hex = "#ff5a5a", alpha = 0.97 },
      { hex = "#a1001a", alpha = 0.97 },
    },
    withShadow = true,
    shadow = { blurRadius = 24, offset = { h = -6, w = 0 }, color = { alpha = 0.45 } },
  }, {
    type = "rectangle",
    action = "stroke",
    frame = { x = 0.5, y = 0.5, w = w - 1, h = h - 1 },
    roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 },
    strokeColor = { white = 1, alpha = 0.3 },
    strokeWidth = 1,
  }, {
    type = "text",
    text = "Change your seat",
    textFont = "Helvetica Neue Bold",
    textSize = 22,
    textColor = { white = 1 },
    textAlignment = "center",
    frame = { x = 0, y = (h - 27) / 2, w = w, h = 30 },
  })

  canvas:level(hs.canvas.windowLevels.overlay)
  canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  canvas:clickActivating(false)
  canvas:canvasMouseEvents(true, true)
  canvas:mouseCallback(function(_canvas, message)
    if message == "mouseUp" then
      log("seat: dismissed")
      seatDismiss()
    end
  end)
  canvas:show(0.25)

  seat.canvas = canvas
end

local function seatTick()
  -- While the pill is up the clock is stopped; clearing it starts the next hour.
  if seat.canvas or not seat.connected then return end
  if hs.host.idleTime() > seat.idleCutoff then return end

  seat.active = seat.active + seat.poll
  if seat.active >= seat.goal then
    seatShow()
  end
end

local function seatScreensChanged()
  local connected = seatMonitorConnected()
  if connected == seat.connected then return end
  seat.connected = connected
  if connected then
    log("seat: monitor connected, timing")
    seat.active = 0
  else
    log("seat: monitor disconnected, paused")
    seatDismiss()
  end
end

seat.connected = seatMonitorConnected()
hs.screen.watcher.new(seatScreensChanged):start()
seat.timer = hs.timer.doEvery(seat.poll, seatTick)

-- Manual testing, e.g. open -g 'hammerspoon://seat?action=show'
hs.urlevent.bind("seat", function(_eventName, params)
  local action = params.action or params[1]
  if action == "show" then
    seatShow()
  elseif action == "dismiss" then
    seatDismiss()
  else
    local status = string.format(
      "seat: %s, %d/%d min active",
      seat.connected and "connected" or "disconnected",
      math.floor(seat.active / 60),
      math.floor(seat.goal / 60))
    log(status)
    hs.alert.show(status)
  end
end)

hs.alert.show("Hammerspoon config loaded")
