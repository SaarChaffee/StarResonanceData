local super = require("ui.component.loop_grid_view_item")
local ResonancePowerDecomposeMainLoopItem = class("ResonancePowerDecomposeMainLoopItem", super)
local item = require("common.item_binder")

function ResonancePowerDecomposeMainLoopItem:ctor()
end

function ResonancePowerDecomposeMainLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.uiView)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.uiBinder.btn_minus:AddListener(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    self.parentUIView:OnSelectResonancePowerItemDecompose(false, curData)
    self:RefreshConsumeCount()
    self:closeTips()
  end)
end

function ResonancePowerDecomposeMainLoopItem:OnRefresh(data)
  self.data = data
  local index = self.Index + 1
  if not data then
    logError("EquipItemsLoopItem data is nil,index is " .. index)
    return
  end
  self:SetCanSelect(true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
  self.uuid_ = data.itemUuid
  self.configId = data.configId
  local itemsVM = Z.VMMgr.GetVM("items")
  self.itemData_ = itemsVM.GetItemInfobyItemId(self.uuid_, self.configId)
  if not self.itemData_ then
    self:refreshNoItemUi()
    return
  end
  self:refreshItemUI()
  self:refreshSelectUI()
end

function ResonancePowerDecomposeMainLoopItem:refreshNoItemUi()
  self:SetCanSelect(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, false)
end

function ResonancePowerDecomposeMainLoopItem:refreshItemUI()
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.configId)
  local data = {
    uiBinder = self.uiBinder,
    uuid = self.uuid_,
    configId = self.configId,
    isClickOpenTips = false,
    isBind = true
  }
  self.itemClass_:Init(data)
  if itemTableRow and self.uuid_ then
    self.itemClass_:RefreshItemFlags(self.itemData_, itemTableRow)
  end
  self:RefreshConsumeCount()
end

function ResonancePowerDecomposeMainLoopItem:refreshSelectUI()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function ResonancePowerDecomposeMainLoopItem:openTips()
  self:closeTips()
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.configId, self.uuid_)
end

function ResonancePowerDecomposeMainLoopItem:closeTips()
  if self.tipsId_ ~= nil then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function ResonancePowerDecomposeMainLoopItem:OnPointerClick(go, eventData)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.parentUIView:OnSelectResonancePowerItemDecompose(true, curData)
  self:RefreshConsumeCount()
  self:openTips()
  Z.AudioMgr:Play("sys_general_frame")
end

function ResonancePowerDecomposeMainLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  self:closeTips()
end

function ResonancePowerDecomposeMainLoopItem:RefreshConsumeCount()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local itemInfo = self.itemsVM_.GetItemInfobyItemId(curData.itemUuid, curData.configId)
  local haveCount = itemInfo and itemInfo.count or 0
  local selectCount = self.parent.UIView:GetDecomposeSelectCount(curData.itemUuid)
  if selectCount <= 0 then
    self.itemClass_:SetLab(haveCount)
    self.itemClass_:SetSelected(false)
  else
    local selectCountStr = Z.RichTextHelper.ApplyStyleTag(selectCount, E.TextStyleTag.Orange)
    local countStr = string.zconcat(selectCountStr, "/", haveCount)
    self.itemClass_:SetLab(countStr)
    self.itemClass_:SetSelected(true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, 0 < selectCount)
end

return ResonancePowerDecomposeMainLoopItem
