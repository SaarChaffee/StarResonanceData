local super = require("ui.component.loop_grid_view_item")
local ChatSettingItem = class("ChatSettingItem", super)

function ChatSettingItem:OnInit()
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.chatSettingVm_ = Z.VMMgr.GetVM("chat_setting")
  self.getStateList_ = {
    [1] = self.GetChannelShow,
    [2] = self.GetDanmuState
  }
  self.setStateList_ = {
    [1] = self.SetChannelShow,
    [2] = self.SetDanmuState
  }
end

function ChatSettingItem:OnRefresh(data)
  self.data_ = data
  self.configId_ = data.configId
  self.funcIndex_ = data.funcIndex
  self.uiBinder.lab_title.text = data.configName
  self:refreshState()
end

function ChatSettingItem:OnPointerClick(go, eventData)
  local isShow = self.getStateList_[self.funcIndex_](self)
  self.setStateList_[self.funcIndex_](self, not isShow)
  self:refreshState()
  Z.AudioMgr:Play("sys_main_funcs_in")
end

function ChatSettingItem:refreshState()
  local isShow = self.getStateList_[self.funcIndex_](self)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isShow)
end

function ChatSettingItem:GetChannelShow()
  return self.chatSettingData_:GetChatList(self.configId_)
end

function ChatSettingItem:SetChannelShow(isOn)
  self.chatSettingData_:SetChatList(self.configId_, isOn)
end

function ChatSettingItem:GetDanmuState()
  return self.chatSettingData_:GetBullet(self.configId_)
end

function ChatSettingItem:SetDanmuState(isOn)
  self.chatSettingVm_.SetBullet(self.configId_, isOn)
end

return ChatSettingItem
