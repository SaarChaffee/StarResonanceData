local UI = Z.UI
local super = require("ui.ui_view_base")
local Dead_property_popupView = class("Dead_property_popupView", super)
local itemBinder = require("common.item_binder")

function Dead_property_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dead_property_popup")
  self.deadVM_ = Z.VMMgr.GetVM("dead")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Dead_property_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:onClickConfirm()
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:onClickCancel()
  end)
  self.isCostEnough_ = true
  self.reviveRow_ = Z.TableMgr.GetRow("ReviveTableMgr", self.viewData.ReviveId)
  self:refreshInfo()
end

function Dead_property_popupView:OnDeActive()
  if self.itemBinder_ then
    self.itemBinder_:UnInit()
    self.itemBinder_ = nil
  end
end

function Dead_property_popupView:OnRefresh()
end

function Dead_property_popupView:getCostConsumeInfo(reviveRow)
  local costType = reviveRow.Consume[1]
  local costItemId = reviveRow.Consume[2]
  local costNum = reviveRow.Consume[3]
  local haveNum = self.itemsVM_.GetItemTotalCount(costItemId)
  if costType == 2 then
    local addNum = reviveRow.Consume[4]
    local maxNum = reviveRow.Consume[5]
    local reviveInfo = self.deadVM_.GetPlayerReviveInfo(reviveRow.Id)
    local totalNum = costNum + addNum * reviveInfo.PersonReviveCount
    if maxNum < totalNum then
      totalNum = maxNum
    end
    costNum = totalNum
  end
  return haveNum, costNum, haveNum >= costNum
end

function Dead_property_popupView:refreshInfo()
  local costItemId = self.reviveRow_.Consume[2]
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", costItemId)
  if itemTableRow == nil then
    return
  end
  local haveNum, costNum, isCostEnough = self:getCostConsumeInfo(self.reviveRow_)
  self.isCostEnough_ = isCostEnough
  self.uiBinder.lab_content.text = Lang("ReviveCostTip", {
    option = self.reviveRow_.Name,
    num = costNum,
    name = itemTableRow.Name
  })
  self.itemBinder_ = itemBinder.new(self)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder.binder_item,
    isSquareItem = true
  })
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = costItemId
  })
  self.itemBinder_:SetExpendCount(haveNum, costNum)
end

function Dead_property_popupView:onClickConfirm()
  if not self.isCostEnough_ then
    Z.TipsVM.ShowTipsLang(1050001)
    return
  end
  self.deadVM_.AsyncRevive(self.reviveRow_.Id, self.cancelSource:CreateToken())
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Dead_property_popupView:onClickCancel()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Dead_property_popupView
