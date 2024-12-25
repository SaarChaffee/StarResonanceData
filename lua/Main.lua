collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

function Main()
  require("common.enum_define")
  require("common.define")
  require("common.lua_event_bridge")
  Z.RegPb()
  require("common.pb_enum_define")
  Z.Game.Init()
end

function OnLevelWasLoaded(level)
  collectgarbage("collect")
  Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
  Z.Game.UnInit()
end
