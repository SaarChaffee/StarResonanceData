local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local ChatChannelTab = class("ChatChannelTab", super)

function ChatChannelTab:ctor()
end

function ChatChannelTab:OnInit()
end

function ChatChannelTab:Refresh()
  self.isSelected_ = false
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.uiBinder.lab_off.text = self.data_.ChannelName
  self.uiBinder.lab_on.text = self.data_.ChannelName
  self:refreshState(false)
end

function ChatChannelTab:Selected(isSelected)
  if self.isSelected_ == isSelected then
    return
  end
  self.isSelected_ = isSelected
  if self.isSelected_ then
    self:refreshState(true)
    self.parent.uiView:SwitchChannel(self.data_.Id)
  else
    self:refreshState(false)
  end
  self.uiBinder.effect_root:SetEffectGoVisible(self.isSelected_)
end

function ChatChannelTab:refreshState(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_on, isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_off, not isSelect)
end

function ChatChannelTab:OnUnInit()
  self.isSelected_ = false
end

function ChatChannelTab:OnReset()
  self.isSelected_ = false
end

return ChatChannelTab
