local inspect = require('inspect')
local alert = require 'hs.alert'
local application = require 'hs.application'
local geometry = require 'hs.geometry'
local grid = require 'hs.grid'
local hints = require 'hs.hints'
local hotkey = require 'hs.hotkey'
local layout = require 'hs.layout'
local window = require 'hs.window'
local speech = require 'hs.speech'


local hyper = {'ctrl', 'cmd'}

-- 1 is auto switch hide/unhide for the app
local key2App = {
  i = {'/Applications/iTerm.app', 'English', 2},
  e = {'/Applications/Emacs.app', 'English', 2},
  c = {'/Applications/Google Chrome.app', '', 2},
  w = {'/Applications/WeChat.app', 'Chinese', 1},
  m = {'/Applications/Mattermost.app', 'Chinese', 1},
  t = {'/Applications/TickTick.app', 'Chinese', 1},
  f = {'/System/Library/CoreServices/Finder.app', 'English', 1},
  s = {'/Applications/System Preferences.app', 'English', 1},
}

function findApplication(appPath)
  local apps = application.runningApplications()
  for i = 1, #apps do
    local app = apps[i]
    if app:path() == appPath then
      return app
    end
  end

  return nil
end



local function Chinese()
  hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

function updateFocusAppInputMethod()
  for key, app in pairs(key2App) do
    local appPath = app[1]
    local inputmethod = app[2]
    if window.focusedWindow():application():path() == appPath then
      if inputmethod == 'English' then
        English()
      elseif inputmethod ~= '' then 
        Chinese()
      end
      break
    end
  end
end


function fullscreen()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

hs.hotkey.bind({"cmd", "ctrl"}, "Up", fullscreen)
hs.hotkey.bind({"cmd", "shift"}, "Up", fullscreen)


function rightSize()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenframe = screen:frame()
  local frame_len = #hs.screen.allScreens()
  -- print(f)
  for k, v in pairs(hs.screen.allScreens()) do
    local frame = v:frame()
    -- print(frame)
    if(screenframe.x == frame.x) then
      -- print("found frame")
      -- print(frame)
      local new_screen_index = k - 1
      if new_screen_index < 1 then
        new_screen_index = frame_len
      end
      -- print('new screen index')
      -- print(new_screen_index)
      local select_screen_frame = hs.screen.allScreens()[new_screen_index];
      select_screen_frame = select_screen_frame:frame();
      -- print('select frame is')
      -- print(select_screen_frame)
      f.x = (select_screen_frame.w - f.w)/2 + select_screen_frame.x
      f.y = select_screen_frame.y
      win:setFrame(f)
      break
    end
  end
end

hs.hotkey.bind({"cmd", "ctrl"}, "Right",rightSize)
hs.hotkey.bind({"cmd", "shift"}, "Right",rightSize)

function leftSize()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenframe = screen:frame()
  local frame_len = #hs.screen.allScreens()
  -- print('foucuse window frame')
  -- print(f)
  -- print(screenframe)
  -- print('start loop screens')
  for k, v in pairs(hs.screen.allScreens()) do
    local frame = v:frame()
    -- print(frame)
    if(screenframe.x == frame.x) then
      local new_screen_index = k + 1
      if new_screen_index > frame_len then
        new_screen_index = 1
      end

      -- print('found target sreen size'..k)
      -- print(new_screen_index)
      local select_screen_frame = hs.screen.allScreens()[new_screen_index];
      select_screen_frame = select_screen_frame:frame();
      -- print(select_screen_frame)
      f.x = (select_screen_frame.w - f.w)/2 + select_screen_frame.x
      f.y = select_screen_frame.y
      win:setFrame(f)
      break
    end
  end
end

hs.hotkey.bind({"cmd", "ctrl"}, "Left",leftSize)
hs.hotkey.bind({"cmd", "shift"}, "Left",leftSize)


function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

function launch_androidstudio()
  hs.application.launchOrFocus("Android Studio.app")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'A', launch_androidstudio)
hs.hotkey.bind({"cmd", "shift"}, 'A', launch_androidstudio)



function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    -- hs.alert.show("Debug app activated" .. appName)
    if (appName == "访达") then
      -- hs.alert.show("Debug detech finder!")
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"窗口", "前置全部窗口"})
      -- hs.alert.show("Debug select menu")
    end
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

hs.hotkey.bind({"cmd","ctrl"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)


hs.urlevent.bind("CarlosAlert", function(eventName, params)
                   hs.alert.show(params.message,Null,hs.screen.mainScreen(),3)
end)

local carlosmenubar

function Init()
  carlosmenubar = hs.menubar.new()
  carlosmenubar:setIcon("/Users/carlos/ownCloud/carlos_data/system-config/hammerspoon/hammerspoon_config/tomato.png")

end

Init()

hs.urlevent.bind("CarlosUpdateMenubar", function(eventName, params)
                   carlosmenubar:setTitle(params.message)
                   carlosmenubar:setTooltip("123")
end)


-- Show launch application's keystroke.
local showAppKeystrokeAlertId = ""

local function showAppKeystroke()
  if showAppKeystrokeAlertId == "" then
    -- Show application keystroke if alert id is empty.
    local keystroke = ""
    local keystrokeString = ""
    for key, app in pairs(key2App) do
      keystrokeString = string.format("%-10s%s", key:upper(), app[1]:match("^.+/(.+)$"):gsub(".app", ""))

      if keystroke == "" then
        keystroke = keystrokeString
      else
        keystroke = keystroke .. "\n" .. keystrokeString
      end
    end

    showAppKeystrokeAlertId = hs.alert.show(keystroke, hs.alert.defaultStyle, hs.screen.mainScreen(), 10)
  else
    -- Otherwise hide keystroke alert.
    hs.alert.closeSpecific(showAppKeystrokeAlertId)
    showAppKeystrokeAlertId = ""
  end
end

hs.hotkey.bind(hyper, "z", showAppKeystroke)


function launchApp(appPath)
  application.launchOrFocus(appPath)
end

function toggleApplication(app)
  local appPath = app[1]
  local inputMethod = app[2]
  local switchide = app[3]

  -- Tag app path use for `applicationWatcher'.
  startAppPath = appPath

  local app = findApplication(appPath)
  local setInputMethod = true

  if not app then
    -- Application not running, launch app
    launchApp(appPath)
  else
    -- Application running, toggle hide/unhide
    local mainwin = app:mainWindow()
    if mainwin then
      if app:isFrontmost() then
        if switchide == 1 then
          mainwin:application():hide()
        end
        setInputMethod = false
        updateFocusAppInputMethod()
      else
        -- Focus target application if it not at frontmost.
        mainwin:application():activate(true)
        mainwin:application():unhide()
        mainwin:focus()
      end
    else
      -- Start application if application is hide.
      if app:hide() then
        launchApp(appPath)
      end
    end
  end

  if setInputMethod then
    if inputMethod == 'English' then
      English()
    else
      Chinese()
    end
  end
end

-- Start or focus application.
for key, app, switchhide in pairs(key2App) do
  hotkey.bind(
    hyper, key,
    function()
      toggleApplication(app)
  end)
end

-- hotkey.bind(
--   hyper, "x",
--   function()
--     hs.osascript.applescriptFromFile('/Users/carlos/ownCloud/carlos_data/system-config/tools/appscript_selecttxt.scpt')
--     print("Debug trigger hyber key pastboard:getContents:"..hs.pasteboard.getContents())
--     -- launchApp('/Users/carlos/Applications/Cerebro.app')
--     -- hs.eventtap.keyStrokes("d "..hs.pasteboard.getContents())
-- end)
local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end
hs.textDroppedToDockIconCallback = function(selectedtxt)
  launchApp('/Users/carlos/Applications/Cerebro.app')
  sleep(0.3)
  hs.eventtap.keyStrokes("d "..selectedtxt)
  end
