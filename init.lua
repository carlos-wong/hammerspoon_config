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
local spotify = require 'hs.spotify'
local wf = hs.window.filter.new()


local hyper = {'ctrl', 'cmd'}

-- 1 is auto switch hide/unhide for the app
local key2App = {
  i = {'/Applications/iTerm.app', 'English', 2},
  e = {'/Applications/Emacs.app', 'English', 2},
  c = {'/Applications/Google Chrome.app', '', 2},
  w = {'/Applications/WeChat.app', 'Chinese', 1},
  -- u = {'/Applications/Unity/Hub/Editor/2021.3.11f1/Unity.app', 'Chinese', 1},
  -- m = {'/Applications/Mattermost.app', 'Chinese', 1},
  t = {'/Applications/Todoist.app', 'Chinese', 1},
  f = {'/System/Library/CoreServices/Finder.app', 'English', 1},
  -- s = {'/Applications/System Preferences.app', 'English', 1},
  -- a = {'/Applications/Android Studio.app', 'English', 1},
  s = {'/Applications/Skim.app', 'English', 1},
  -- m = {'/Applications/Microsoft Remote Desktop Beta.app','English',1},
  q = {'/Applications/企业微信.app','Chinese',1},
  p = {'/Applications/PushDeer.app','Chinese',1},
  d = {'/System/Applications/Calendar.app','Chinese',1},
  -- r = {'/Applications/微信读书.app','Chinese',1},
  -- f20 = {'/Applications/NeteaseMusic.app','English',1},
  -- f20 = {'/Applications/QQMusic.app','English',1},
}

function getConnectWifiSsid()
	local wifi_info = hs.wifi.currentNetwork("en0")
  return wifi_info
end

function findApplication(app)
  local appPath = app[1]
  local inputMethod = app[2]
  local switchide = app[3]
  local appBundleId = ""
  if app[4] then
    appBundleId = app[4]
  end
  if not appPath then
    return nil
  end
  local app_info = hs.application.infoForBundlePath(appPath)
  if app_info then
    app = hs.application.get(app_info["CFBundleIdentifier"])
    if app then
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
  f.x = max.x + 2
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

-- hs.hotkey.bind({"cmd", "ctrl"}, "Up", fullscreen)
hs.hotkey.bind({"cmd", "shift"}, "Up", fullscreen)


function rightSize()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local screenframe = screen:frame()
  local frame_len = #hs.screen.allScreens()
  if frame_len == 1 then
    local half_screenframewidth = screenframe.w/2
    local current_x = f.x
    if current_x < half_screenframewidth then
      f.x = half_screenframewidth
    else
      f.x = screenframe.x
    end

    f.y = screenframe.y
    f.w = half_screenframewidth
    f.h = screenframe.h
    win:setFrame(f)
  else
    for k, v in pairs(hs.screen.allScreens()) do
      local frame = v:frame()
      if(screenframe.x == frame.x) then
        -- print(frame)
        local new_screen_index = k + 1
        if new_screen_index > frame_len then
          new_screen_index = 1
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
end

function leftSize()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local screenframe = screen:frame()
  local frame_len = #hs.screen.allScreens()
  -- print('foucuse window frame')
  -- print(f)
  -- print(screenframe)
  -- print('start loop screens')
  if frame_len == 1 then
    local half_screenframewidth = screenframe.w/2
    local current_x = f.x
    if current_x < half_screenframewidth then
      f.x = half_screenframewidth
    else
      f.x = screenframe.x
    end

    f.y = screenframe.y
    f.w = half_screenframewidth
    f.h = screenframe.h
    win:setFrame(f)
  else
    for k, v in pairs(hs.screen.allScreens()) do
      local frame = v:frame()
      -- print(frame)
      if(screenframe.x == frame.x) then

        local new_screen_index = k - 1
        if new_screen_index < 1 then
          new_screen_index = frame_len
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
end


hs.hotkey.bind({"cmd", "shift"}, "Right",leftSize)

hs.hotkey.bind({"cmd", "shift"}, "Left",rightSize)




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


function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    -- hs.alert.show("Debug app activated" .. appName)
    if (appName == "访达") then
      -- hs.alert.show("Debug detech finder!")
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"窗口", "前置全部窗口"})
      -- hs.alert.show("Debug select menu")
    end
    if (appName == "预览") then
      -- hs.alert.show("Debug detech finder!")
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"窗口", "前置全部窗口"})
      appObject:selectMenuItem({"显示", "缩放至窗口大小"})
      -- hs.alert.show("Debug select menu")
    end
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

hs.hotkey.bind({"cmd","ctrl"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

hs.urlevent.bind("CarlosCtrlApps",function(eventName, params)
                   local app = findApplication({params.appPath,'English',1})
                   if app then
                     app:selectMenuItem({params.firstitem, params.seconditem})
                   end
end)


hs.urlevent.bind("CarlosWifiSSID",function(eventName, params)
                   local wifissid = getConnectWifiSsid()
                   hs.json.write({wifi=wifissid},"/tmp/carlos_wifissid")
end)


hs.urlevent.bind("CarlosCtrlMusicApps",function(eventName, params)
                   if params.type == "Netease" then
                     local app = findApplication({'/Applications/NeteaseMusic.app','English',1})
                     if app then
                       app:selectMenuItem({params.firstitem, params.seconditem})
                     end
                   end

                   if params.type == "QQMusic" then
                     app = findApplication({'/Applications/QQMusic.app','English',1})
                     if app then
                       app:selectMenuItem({params.firstitem, params.seconditem})
                     end
                   end

end)

hs.urlevent.bind("CarlosAlert", function(eventName, params)
                   for k, select_screen in pairs(hs.screen.allScreens()) do
                     hs.alert.show(params.message,{atScreenEdge=0,
                                                   fadeInDuration = 0.15,
                                                   fadeOutDuration = 5,
                                                   textSize = 18,
                                                   fillColor={red=255/255,green=150/255,blue=203/255}},select_screen,2.618)
                     -- drawRectangle(2)
                   end
end)

hs.urlevent.bind("toggleApplication", function(eventName, params)
                   toggleApplication(params.app)
end)

local carlosmenubar

function Init()
  carlosmenubar = hs.menubar.new()
  -- carlosmenubar:setIcon("/Users/carlos/ownCloud/carlos_data/system-config/hammerspoon/hammerspoon_config/tomato.png")
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
  if appPath then
    local app = application.launchOrFocus(appPath)
  end
end

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function moveCursorToCenterOfFocusedWindow()
  -- Get the currently focused window
  local win = hs.window.focusedWindow()

  -- Get the frame of the window
  local frame = win:frame()

  -- Calculate the center of the window
  local center = hs.geometry.rectMidPoint(frame)

  -- Move the cursor to the center of the window
  hs.mouse.setAbsolutePosition(center)
end


function toggleApplication(app)
  local appPath = app[1]
  local inputMethod = app[2]
  local switchide = app[3]
  setInputMethod = true

  if not appPath then
    return
  end

  startAppPath = appPath

  local app_info = hs.application.infoForBundlePath(appPath)
  if app_info then
    app = hs.application.get(app_info["CFBundleIdentifier"])
  end
  if not app then
    -- Application not running, launch app
    if appPath then
      launchApp(appPath)
    else
      return
    end

  else
    -- Application running, toggle hide/unhide
    local mainwin = app:mainWindow()
    -- print("app main win is:"..mainwin)
    if mainwin then
      if app:isFrontmost() then
        if switchide == 1 then
          mainwin:application():hide()
        end
        -- updateFocusAppInputMethod()
      else
        -- Focus target application if it not at frontmost.
        mainwin:application():activate(true)
        mainwin:application():unhide()
        mainwin:focus()

      end
      -- local appwindowsframe = app:focusedWindow():frame();
      -- hs.mouse.absolutePosition({x=appwindowsframe.x+appwindowsframe.w/2, y=appwindowsframe.y+appwindowsframe.h/2})
      -- hs.mouse.setRelativePosition({x=0,y=0})
      -- local overlay = hs.drawing.rectangle(hs.geometry(appwindowsframe.x, appwindowsframe.y, appwindowsframe.w, appwindowsframe.h))
      -- overlay:setStrokeColor(hs.drawing.color.asRGB({red=1.0,green=0.0,blue=1.0}))
      -- overlay:setStrokeWidth(25)
      -- overlay:setAlpha(0.3)
      -- overlay:setFill(nil)
      -- overlay:show()
      -- hs.timer.doAfter(0.500, function ()
      --                    overlay:delete()                
      -- end)

    else
      -- Start application if application is hide.
      if app:hide() then
        launchApp(appPath)
      end
    end
  end
  if app_info["CFBundleIdentifier"] == "org.gnu.Emacs" then
    hs.mouse.setAbsolutePosition({x=0, y=0})
  else
    moveCursorToCenterOfFocusedWindow()
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


function changeVolume(diff)
  return function()
    local current = hs.audiodevice.defaultOutputDevice():volume()
    local new = 0
    if diff > 0 then
      new = math.min(100, math.max(0, math.ceil(current + diff)))
    else
      new = math.min(100, math.max(0, math.floor(current + diff)))
    end

    if new > 0 then
      hs.audiodevice.defaultOutputDevice():setMuted(false)
    end
    hs.alert.closeAll(0.0)
    hs.alert.show("Volume " .. new .. "%", {}, 0.5)
    hs.audiodevice.defaultOutputDevice():setVolume(new)
  end
end

hs.hotkey.bind({"ctrl", "alt"}, "End",changeVolume(-100))

hs.hotkey.bind({"ctrl", "alt"}, "Up",changeVolume(1),nil,changeVolume(2))

hs.hotkey.bind({"ctrl", "alt"}, "Down",changeVolume(-1),nil,changeVolume(-2))

function Spoitfy_next_song()
  app = findApplication({'/Applications/Spotify.app','English',1})
  if app then
    hs.spotify.next()
  end
end

function Spoitfy_prev_song()
  app = findApplication({'/Applications/Spotify.app','English',1})
  if app then
    hs.spotify.previous()
  end
end

function Spoitfy_like_song()
  app = findApplication({'/Applications/Spotify.app','English',1})
  if app  then
    hs.eventtap.keyStroke({"option", "shift"}, "b", app)
  end
end

function Spoitfy_toggle_play_or_stop()
  app = findApplication({'/Applications/Spotify.app','English',1})
  if app then
    hs.spotify.playpause()
  end
end



hs.hotkey.bind({"ctrl", "alt"}, "l",Spoitfy_like_song)
hs.hotkey.bind({"ctrl", "alt"}, "space",Spoitfy_toggle_play_or_stop)
hs.hotkey.bind({"ctrl", "alt"}, "Left",Spoitfy_prev_song)
hs.hotkey.bind({"ctrl", "alt"}, "Right",Spoitfy_next_song)

-- local showing_rect = {}

-- local function drawBorderOnfocusedWindow()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--   local fx = f.x
--   local fy = f.y
--   local fw = f.w
--   local fh = f.h

--   -- Create a rectangle object and set its attributes
--   local rect = hs.drawing.rectangle(hs.geometry.rect(fx, fy, fw, fh))
--   rect:setStrokeWidth(3)
--   rect:setStrokeColor({["red"]=0.259,["blue"]=0.545,["green"]=0.792,["alpha"]=1})
--   rect:setFill(false)
--   rect:setLevel(hs.drawing.windowLevels.overlay)
--   rect:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)

--   -- Show the rectangle object
--   rect:show()

--   -- Remove the rectangle object after 2 seconds
--   hs.timer.doAfter(1.0,
--                    function()
--                      rect:delete()
--                    end)
-- end


-- -- Set up a callback function to handle window focus events
-- wf:subscribe(hs.window.filter.windowFocused, function(window, appName)
--                drawBorderOnfocusedWindow()
-- end)

hs.application.enableSpotlightForNameSearches(true)
