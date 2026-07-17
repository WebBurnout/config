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
    win:setFrame({
      x = sf.x + (sf.w - centered.w) / 2,
      y = sf.y + (sf.h - centered.h) / 2,
      w = centered.w,
      h = centered.h,
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

hs.alert.show("Hammerspoon config loaded")
