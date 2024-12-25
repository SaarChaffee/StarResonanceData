local super = require("ui.component.loopscrollrectitem")
local SmashLoopItem = class("SmashLoopItem", super)
local item = require("common.item")

function SmashLoopItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.refineSystemVm = Z.VMMgr.GetVM("refine_system")
  self.refineData = Z.DataMgr.Get("refine_data")
end

function SmashLoopItem:OnInit()
  self.isSelected = false
  Z.EventMgr:Add(Z.ConstValue.Refine.CancelSelected, self.coustumeSelected, self)
  self.itemClass_ = item.new(self.parent.uiView)
end

function SmashLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  self.updateTimer_ = nil
  self.itemWatcherFun_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function SmashLoopItem:BindEvents()
end

function SmashLoopItem:UnBindEvents()
end

function SmashLoopItem:updateSmashData()
  Z.EventMgr:Dispatch(Z.ConstValue.Refine.RefreshEnergy)
  Z.EventMgr:Dispatch(Z.ConstValue.Refine.UpdateSmashBtnGray)
end

function SmashLoopItem:setSmashItemCount()
  if not self.itemData_ or self.itemData_.count == 0 then
    return
  end
  if self.isSelected then
    local count = self.refineData:GetSmashItemData(self.uuid)
    self.itemClass_:SetExpendCount(self.itemData_.count, count)
  else
    self.itemClass_:SetLab(tostring(self.itemData_.count))
  end
end

function SmashLoopItem:Refresh()
  self.component.CanSelected = false
  local index = self.component.Index + 1
  if index > self.parent:GetCount() then
    self.component.CanSelected = false
    self.unit.cont_info:SetVisible(false)
    return
  end
  self.unit.cont_info:SetVisible(true)
  local data = self.parent:GetDataByIndex(index)
  self.uuid = data.uuid
  self.configId = data.configId
  self.smashId = data.smashId
  local itemsVm = Z.VMMgr.GetVM("items")
  self.package_ = itemsVm.GetPackageInfobyItemId(self.configId)
  self.itemData_ = self.package_.items[self.uuid]
  self:setui()
  self.unit.cont_info.btn_temp:SetVisible(true)
  self:AddAsyncClick(self.unit.cont_info.btn_temp.Btn, function()
    local nowAddEnergy = self.refineData:GetAddEnergy(true)
    if nowAddEnergy >= Z.ContainerMgr.CharSerialize.energyItem.energyLimit then
      Z.TipsVM.ShowTipsLang(500004)
      return
    end
    local smashItemCount = self.refineData:GetSmashItemData(self.uuid)
    local plusCount = smashItemCount + 1
    if plusCount > self.itemData_.count then
      plusCount = self.itemData_.count
      Z.TipsVM.ShowTipsLang(500001)
      return
    end
    self.refineSystemVm.SetSmashItemData(self.uuid, plusCount)
    self.refineSystemVm.SetSmashItemConfigData(self.configId, self.smashId, 1, true)
    self:coustumeSelected()
    self:updateSmashData()
  end, nil, nil)
  self:AddAsyncClick(self.unit.cont_info.btn_close.Btn, function()
    local smashItemCount = self.refineData:GetSmashItemData(self.uuid)
    local subCount = smashItemCount - 1
    if subCount < 0 then
      subCount = 0
    end
    self.refineSystemVm.SetSmashItemData(self.uuid, subCount)
    self.refineSystemVm.SetSmashItemConfigData(self.configId, self.smashId, 1)
    self:coustumeSelected()
    self:updateSmashData()
  end, nil, nil)
  self:coustumeSelected()
end

function SmashLoopItem:setui()
  local backpackData = Z.DataMgr.Get("backpack_data")
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.configId)
  if itemTableRow == nil then
    return
  end
  self.itemClass_:Init({
    unit = self.unit,
    configId = self.configId,
    uuid = self.uuid
  })
  self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  self:setSmashItemCount()
  self.isNew_ = backpackData.NewItems[self.uuid] ~= nil
  self.unit.cont_info.img_reddot:SetVisible(self.isNew_)
end

function SmashLoopItem:OnReset()
  self.itemData_ = nil
  self.package_ = nil
  self.configId = -1
  self.uuid = -1
  self.component.CanSelected = false
end

function SmashLoopItem:coustumeSelected()
  local smashItemCount = self.refineData:GetSmashItemData(self.uuid)
  self.isSelected = 0 < smashItemCount
  self:setSmashItemCount()
  self.unit.cont_info.img_select:SetVisible(self.isSelected)
  self.unit.cont_info.btn_close:SetVisible(self.isSelected)
end

return SmashLoopItem
