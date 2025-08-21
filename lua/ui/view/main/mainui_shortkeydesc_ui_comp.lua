local MainUIShortKeyDescUIComp = class("MainUIShortKeyDescUIComp")
local inputKeyDescComp = require("input.input_key_desc_comp")

function MainUIShortKeyDescUIComp:ctor(...)
  self.questViewKeyDescComp = inputKeyDescComp.new()
  self.exitDungeonKeyDescComp = inputKeyDescComp.new()
  self.lineKeyDescComp = inputKeyDescComp.new()
  self.trackLeftKeyDescComp = inputKeyDescComp.new()
  self.trackRightKeyDescComp = inputKeyDescComp.new()
end

function MainUIShortKeyDescUIComp:Init(uiBinder)
  self.uiBinder = uiBinder
  self.questViewKeyDescComp:Init(118, self.uiBinder.com_icon_key_task)
  self.exitDungeonKeyDescComp:Init(112, self.uiBinder.com_icon_key_exit)
  self.lineKeyDescComp:Init(135, self.uiBinder.com_icon_key_line)
  self.trackLeftKeyDescComp:Init(156, self.uiBinder.track_left_binder)
  self.trackRightKeyDescComp:Init(157, self.uiBinder.track_right_binder)
end

function MainUIShortKeyDescUIComp:UnInit()
  self.questViewKeyDescComp:UnInit()
  self.exitDungeonKeyDescComp:UnInit()
  self.lineKeyDescComp:UnInit()
  self.trackLeftKeyDescComp:UnInit()
  self.trackRightKeyDescComp:UnInit()
  self.uiBinder = nil
end

function MainUIShortKeyDescUIComp:SetQuestPcIconState(isShow)
  if not Z.IsPCUI then
    return
  end
  self.questViewKeyDescComp:SetVisible(isShow)
end

function MainUIShortKeyDescUIComp:SetExitDungeonVisible(isShow)
  if not Z.IsPCUI then
    return
  end
  self.exitDungeonKeyDescComp:SetVisible(isShow)
end

function MainUIShortKeyDescUIComp:SetSceneLineVisible(isShow)
  if not Z.IsPCUI then
    return
  end
  self.lineKeyDescComp:SetVisible(isShow)
end

return MainUIShortKeyDescUIComp
