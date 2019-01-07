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


function launch_chrome()
  hs.application.launchOrFocus("Google Chrome")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'C', launch_chrome)
hs.hotkey.bind({"cmd", "shift"}, 'C', launch_chrome)

function launch_emacs()
  hs.application.launchOrFocus("Emacs")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'E', launch_emacs)
hs.hotkey.bind({"cmd", "shift"}, 'E', launch_emacs)


function launch_androidstudio()
  hs.application.launchOrFocus("Android Studio.app")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'A', launch_androidstudio)
hs.hotkey.bind({"cmd", "shift"}, 'A', launch_androidstudio)


function launch_wechat()
  -- hs.alert.show("wechat_ctrl: " .. (hs.application.get("微信"):name() or "") .. string.format("bool: %s",hs.application.get("微信"):isFrontmost()) )
  if not hs.application.get("微信") or not hs.application.get("微信"):isFrontmost() then
    hs.application.launchOrFocus("Wechat")
  else
    hs.application.get("微信"):hide()
  end
end
hs.hotkey.bind({"cmd", "ctrl"}, 'W', launch_wechat)
hs.hotkey.bind({"cmd", "shift"}, 'W', launch_wechat)

function launch_iterm()
  hs.application.launchOrFocus("iTerm")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'I', launch_iterm)
hs.hotkey.bind({"cmd", "shift"}, 'I', launch_iterm)

function launch_finder()
  hs.application.launchOrFocus("Finder")
end
hs.hotkey.bind({"cmd", "ctrl"}, 'F', launch_finder)
hs.hotkey.bind({"cmd", "shift"}, 'F', launch_finder)

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
                   -- print('debug params message:' .. params.message)
                   hs.alert.show(params.message)
end)

