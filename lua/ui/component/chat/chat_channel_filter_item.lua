local super = require("ui.component.loop_grid_view_item")
local ChatChannelFilterItem = class("ChatChannelFilterItem", super)

function ChatChannelFilterItem:OnInit()
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
end

function ChatChannelFilterItem:OnRefresh(data)
  self.configId_ = data.configId
  self.uiBinder.lab_title.text = data.configName
  self:refreshState()
end

function ChatChannelFilterItem:OnPointerClick(go, eventData)
  local isShow = self.chatSettingData_:GetSynthesis(self.configId_)
  self.chatSettingData_:SetSynthesis(self.configId_, not isShow)
  self:refreshState()
  self.chatMainVm_.UpdateComprehensiveRecord()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
end

function ChatChannelFilterItem:refreshState()
  local isShow = self.chatSettingData_:GetSynthesis(self.configId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isShow)
end

return ChatChannelFilterItem
