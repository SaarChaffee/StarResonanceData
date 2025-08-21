local super = require("ui.component.loop_list_view_item")
local HouseLevelLoopItem = class("HouseLevelLoopItem", super)

function HouseLevelLoopItem:OnInit()
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  Z.EventMgr:Add(Z.ConstValue.House.HouseLevelChange, self.refreshUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseCleaninessChange, self.refreshUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.House.HouseExpChange, self.refreshUnlock, self)
end

function HouseLevelLoopItem:OnRefresh(data)
  self.data = data
  self.uiBinder.lab_level_num.text = tostring(data.Id)
  self:refreshUnlock()
end

function HouseLevelLoopItem:refreshUnlock()
  local curLevel = self.houseData_:GetHouseLevel()
  local isUnlocked = curLevel >= self.data.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished, isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.houseVm_.CheckHouseCanUpGrade(self.data.Id) and self.houseData_:IsHomeOwner())
end

function HouseLevelLoopItem:OnSelected(isSelected, isClick)
  self.parent.UIView:RefreshByLevel(self.data.Id)
  if isClick then
    self.parent.UIView:SetIsCenter(self.Index)
  end
end

function HouseLevelLoopItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.House.HouseLevelChange, self.refreshUnlock, self)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseCleaninessChange, self.refreshUnlock, self)
  Z.EventMgr:Remove(Z.ConstValue.House.HouseExpChange, self.refreshUnlock, self)
end

return HouseLevelLoopItem
