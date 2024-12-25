local super = require("ui.model.data_base")
local FishingSettingData = class("FishingSettingData", super)

function FishingSettingData:ctor()
  super.ctor(self)
end

function FishingSettingData:Init()
  super.Init(self)
  self.CancelSource = Z.CancelSource.Rent()
  self.ShowEntityAllCfg = {}
  self.ShowUIAllCfg = {}
end

function FishingSettingData:UnInit()
  self.CancelSource:Recycle()
end

function FishingSettingData:InitShowCfg()
  self.ShowEntityAllCfg = {
    {
      type = E.CamerasysShowEntityType.Stranger,
      txt = Lang("Stranger"),
      state = true
    },
    {
      type = E.CamerasysShowEntityType.FriendlyNPCS,
      txt = Lang("Photograph_Display_NPC"),
      state = true
    },
    {
      type = E.CamerasysShowEntityType.WeaponsAppearance,
      txt = Lang("FishingWeaponShowSetting"),
      state = false
    }
  }
  self.ShowUIAllCfg = {
    {
      type = E.CamerasysShowUIType.Name * -1,
      txt = Lang("Name"),
      state = true
    }
  }
  self:ReadSettingData()
end

function FishingSettingData:SetShowEntityCfg(type, state)
  for k, v in ipairs(self.ShowEntityAllCfg) do
    if v.type == type then
      v.state = state
      break
    end
  end
end

function FishingSettingData:SetShowUICfg(type, state)
  for k, v in ipairs(self.ShowUIAllCfg) do
    if v.type == type then
      v.state = state
      break
    end
  end
end

function FishingSettingData:ReadSettingData()
  local data = Z.LocalUserDataMgr.GetString("FishingShowSetting")
  if data ~= "" then
    local settingDict = self:AnalysisData(data)
    for _, eCfg in ipairs(self.ShowEntityAllCfg) do
      eCfg.state = true
      if settingDict[eCfg.type] ~= nil then
        eCfg.state = settingDict[eCfg.type]
      end
    end
    for _, uCfg in ipairs(self.ShowUIAllCfg) do
      uCfg.state = true
      if settingDict[uCfg.type] ~= nil then
        uCfg.state = settingDict[uCfg.type]
      end
    end
  end
end

function FishingSettingData:WriteSettingData()
  local data = self:ConcatSettingData()
  Z.LocalUserDataMgr.SetString("FishingShowSetting", data)
end

function FishingSettingData:AnalysisData(data)
  local settingDict = {}
  local value = string.split(data, ",")
  if 0 < #value then
    for _, v in ipairs(value) do
      local cfg = string.split(v, "=")
      local id = tonumber(cfg[1])
      local state = cfg[2] == "1"
      if id then
        settingDict[id] = state
      end
    end
  end
  return settingDict
end

function FishingSettingData:ConcatSettingData()
  local data = ""
  for i, eCfg in ipairs(self.ShowEntityAllCfg) do
    if i ~= 1 then
      data = string.zconcat(data, ",", eCfg.type, "=", eCfg.state and 1 or 0)
    else
      data = string.zconcat(data, eCfg.type, "=", eCfg.state and 1 or 0)
    end
  end
  data = string.zconcat(data, ",")
  for i, uCfg in ipairs(self.ShowUIAllCfg) do
    if i ~= 1 then
      data = string.zconcat(data, ",", uCfg.type, "=", uCfg.state and 1 or 0)
    else
      data = string.zconcat(data, uCfg.type, "=", uCfg.state and 1 or 0)
    end
  end
  return data
end

function FishingSettingData:GetEntityTypeState(type)
  for k, v in ipairs(self.ShowEntityAllCfg) do
    if v.type == type then
      return v.state
    end
  end
end

return FishingSettingData
