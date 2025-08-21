local super = require("ui.component.loop_list_view_item")
local AfficheFrameItem = class("AfficheFrameItem", super)

function AfficheFrameItem:ctor()
  self.uiBinder = nil
end

function AfficheFrameItem:OnInit()
  self.afficheVM_ = Z.VMMgr.GetVM("affiche")
  self.afficheData_ = Z.DataMgr.Get("affiche_data")
end

function AfficheFrameItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.tog_item:RemoveAllListeners()
  if self.data_.index_ == -1 then
    self.uiBinder.tog_item.isOn = false
    self.isToggleOn = false
  else
    self.uiBinder.tog_item.isOn = self.afficheData_:GetShowAfficheDataIndex() == self.data_.index_
    self.isToggleOn = self.afficheData_:GetShowAfficheDataIndex() == self.data_.index_
    self:setRedState()
  end
  self.uiBinder.tog_item:AddListener(function(isOn)
    if isOn then
      if self.data_ and self.data_.index_ ~= -1 then
        self.afficheData_:SetShowAfficheIndex(self.data_.index_)
        self.parent.UIView:refreshInfo(true)
      else
        self.uiBinder.tog_item.isOn = false
      end
      self.isToggleOn = true
    elseif self.isToggleOn then
      self.uiBinder.tog_item:SetIsOnWithoutCallBack(true)
    end
  end)
  self:setTitleLab()
end

function AfficheFrameItem:OnPointerClick()
end

function AfficheFrameItem:OnUnInit()
end

function AfficheFrameItem:OnReset()
end

function AfficheFrameItem:setTitleLab()
  if self.data_ ~= nil then
    self.uiBinder.lab_offcontent_off.text = self.data_.subTitleName_
    self.uiBinder.lab_oncontent_on.text = self.data_.subTitleName_
  end
end

function AfficheFrameItem:setRedState()
end

return AfficheFrameItem
