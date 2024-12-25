local super = require("ui.component.loop_list_view_item")
local UnionLoopBuffItem = class("UnionLoopBuffItem", super)
local unionBuffitem = require("ui.component.union.union_buff_item")

function UnionLoopBuffItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.unionBuffItem_ = unionBuffitem.new()
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
end

function UnionLoopBuffItem:OnInit()
  self.unionBuffItem_:Init(self.uiBinder.binder_buff, {})
  self.isHavePower_ = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetBuildingEffect)
end

function UnionLoopBuffItem:OnRefresh(data)
  local equipBuffIdDict = self.unionVM_:GetEquipBuffInfoDict()
  self.isUnlock_, self.unlockBuildConfig_ = self.unionVM_:CheckUnionBuffUnlock(data.Id)
  local curBuffInfo = equipBuffIdDict[data.Id]
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  self.isEquiped_ = curBuffInfo and curServerTime < curBuffInfo.endTime
  local costItemId = data.UnionBankroll[1]
  local costItemValue = data.UnionBankroll[2]
  local buffItemData = {
    BuffId = data.Id
  }
  self.unionBuffItem_:Refresh(buffItemData)
  local itemsVm = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_cost_icon:SetImage(itemsVm.GetItemIcon(costItemId))
  self.uiBinder.lab_cost_num.text = costItemValue
  local colorTag = self.isUnlock_ and E.TextStyleTag.UnionDeviceNormal or E.TextStyleTag.UnionDeviceLock
  self.uiBinder.lab_content.text = Z.RichTextHelper.ApplyStyleTag(data.Desc, colorTag)
  self.uiBinder.trans_using:SetWidth(self.uiBinder.lab_using.preferredWidth + 28)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_using, self.isEquiped_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self:SetCanSelect(self.isHavePower_ and self.isUnlock_)
end

function UnionLoopBuffItem:OnUnInit()
  self.unionBuffItem_:UnInit()
  self.unlockBuildConfig_ = nil
end

function UnionLoopBuffItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.parent.UIView:onBuffItemSelected()
end

function UnionLoopBuffItem:OnPointerClick()
  if self.isUnlock_ then
    return
  end
  local buildConfig = self.unionVM_:GetUnionBuildConfig(self.unlockBuildConfig_.BuildingId)
  Z.TipsVM.ShowTips(1000559, {
    name = buildConfig.BuildingName,
    level = self.unlockBuildConfig_.Level
  })
end

return UnionLoopBuffItem
