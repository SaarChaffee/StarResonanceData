local super = require("ui.model.data_base")
local SettingKeyData = class("SettingKeyData", super)
local setKeyDirectionTable = {
  [0] = {
    [E.InputDirectionType.Front] = "InputDirectionFront",
    [E.InputDirectionType.Back] = "InputDirectionBack",
    [E.InputDirectionType.Left] = "InputDirectionLeft",
    [E.InputDirectionType.Right] = "InputDirectionRight"
  }
}

function SettingKeyData:GetSettingKeyDescName(settingKeyCtx)
  if not settingKeyCtx then
    return ""
  end
  if settingKeyCtx.inputDirection == E.InputDirectionType.None then
    return settingKeyCtx.setKeyboardTableRow.SetDes
  else
    local lan = setKeyDirectionTable[settingKeyCtx.setKeyboardTableRow.NameRule][settingKeyCtx.inputDirection]
    return Lang(lan, {
      value = settingKeyCtx.setKeyboardTableRow.SetDes
    })
  end
end

function SettingKeyData:ctor()
  super.ctor(self)
end

function SettingKeyData:Init()
  super.Init(self)
end

function SettingKeyData:Clear()
  super.Clear(self)
end

function SettingKeyData:UnInit()
  super.UnInit(self)
end

return SettingKeyData
