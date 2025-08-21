local super = require("ui.model.data_base")
local SettingVisibleData = class("SettingVisibleData", super)

function SettingVisibleData:ctor()
  super.ctor(self)
  self.settingVisible = {}
end

function SettingVisibleData:Init()
  super.Init(self)
  self:InitVisible()
end

function SettingVisibleData:Clear()
  super.Clear(self)
end

function SettingVisibleData:UnInit()
  super.UnInit(self)
end

function SettingVisibleData:InitVisible()
  self.settingVisible = {}
  for _, v in pairs(E.SettingID) do
    if v == E.SettingID.ShowSkillTag then
      self.settingVisible[v] = not Z.IsPCUI
    else
      self.settingVisible[v] = true
    end
    if v == E.SettingID.Voice then
      local switchVm = Z.VMMgr.GetVM("switch")
      self.settingVisible[v] = switchVm.CheckFuncSwitch(E.SetFuncId.NpcVoice)
    end
  end
end

function SettingVisibleData:CheckVisible(settingId)
  if self.settingVisible[settingId] ~= nil then
    return self.settingVisible[settingId]
  end
  return true
end

return SettingVisibleData
