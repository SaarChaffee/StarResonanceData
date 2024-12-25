local Login = {}
local this = Login
local testOnClick = function()
  logGreen("testOnClick")
end

function this.Awake(object)
  local loginBtn = object
  logGreen("this.Awake")
  GameObject.Find("TestButton"):GetComponent("Button").onClick:AddListener(testOnClick)
  local table_manager = require("utility.table_manager")
  local p = table_manager.GetTable("AchievementTableMgr")
  for k, v in pairs(p.GetDatas()) do
    print(v.id)
  end
  print("hello")
end

return Login
