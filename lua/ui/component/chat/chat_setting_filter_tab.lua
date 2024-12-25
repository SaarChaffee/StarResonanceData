local super = require("ui.component.loopscrollrectitem")
local ChatSettingFilterTab = class("ChatSettingFilterTab", super)

function ChatSettingFilterTab:ctor()
end

function ChatSettingFilterTab:OnInit()
  self.uiBinder.tog_item:AddListener(function()
    if self.uiBinder.tog_item.isOn then
      self.parent.uiView:RefreshChannel(self.data_.filterConfigId_)
    end
  end)
end

function ChatSettingFilterTab:Refresh()
  self.isSelected_ = false
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  local parent = self.parent.uiView:GetFilterTabParent()
  if not parent then
    return
  end
  self.uiBinder.tog_item.group = parent
  self.uiBinder.lab_on.text = self.data_.filterName_
  self.uiBinder.lab_off.text = self.data_.filterName_
  if self.parent.uiView:GetSelectChannelId() == self.data_.filterConfigId_ then
    self.uiBinder.tog_item.isOn = true
  end
end

function ChatSettingFilterTab:Selected(isSelected)
end

function ChatSettingFilterTab:OnUnInit()
  self.isSelected_ = false
end

function ChatSettingFilterTab:OnReset()
  self.isSelected_ = false
end

return ChatSettingFilterTab
