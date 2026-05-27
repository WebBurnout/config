-- Hammerspoon replacement for Moom window layouts.
-- Reload from the menu bar or with: hs -c 'hs.reload()'

hs.menuIcon(true)

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

local layouts = {
  { title = "Maximize",  unit = hs.layout.maximized },
  { title = "Left 1/2",  unit = { x = 0,       y = 0, w = 1 / 2, h = 1 } },
  { title = "Left 2/3",  unit = { x = 0,       y = 0, w = 2 / 3, h = 1 } },
  { title = "Wide Left",  unit = { x = 0,        y = 0, w = 14 / 15, h = 1 } },
  { title = "Wide Right", unit = { x = 1 / 15,   y = 0, w = 14 / 15, h = 1 } },
  { title = "Right 2/3", unit = { x = 1 / 3,   y = 0, w = 2 / 3, h = 1 } },
  { title = "Right 1/2", unit = { x = 1 / 2,   y = 0, w = 1 / 2, h = 1 } },
}

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

local keyBindings = {
  q = "left-1-2",
  w = "left-2-3",
  e = "wide-left",
  r = "wide-right",
  t = "right-2-3",
  y = "right-1-2",
  m = "maximize",
}

for key, slug in pairs(keyBindings) do
  hs.hotkey.bind(hyper, key, function()
    log("hotkey: hyper + " .. key)
    applyLayout(layoutsBySlug[slug])
  end)
end

-- URL hooks for manual testing, e.g.
-- open -g 'hammerspoon://window?action=left-14-15'
hs.urlevent.bind("window", function(_eventName, params)
  local action = params.action or params[1]
  log("url action: " .. tostring(action))
  local layout = layoutsBySlug[action]
  if layout then
    applyLayout(layout)
  else
    hs.alert.show("Unknown window action: " .. tostring(action))
  end
end)

hs.alert.show("Hammerspoon config loaded")
