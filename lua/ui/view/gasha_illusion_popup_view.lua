local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_illusion_popupView = class("Gasha_illusion_popupView", super)

function Gasha_illusion_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_illusion_popup")
end

function Gasha_illusion_popupView:OnActive()
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.selectSub_ = nil
  self.selectSubType_ = 0
  self.selectWishId_ = 0
  self.select_ = 0
  self.wishItemCount_ = 0
  self.gashaPoolTableRow = self.viewData.gashaPoolTableRow
  Z.CoroUtil.create_coro_xpcall(function()
    self:initSelectSub()
  end)()
  self:AddAsyncClick(self.uiBinder.btn_supplication, function()
    local wishId = self.gashaVm_.GetGashaPoolWishId(self.gashaPoolTableRow.Id)
    if wishId == self.selectWishId_ then
      wishId = 0
    else
      wishId = self.selectWishId_
    end
    if wishId == 0 then
      local success = self.gashaVm_.AsyncGashaWishSelection(self.gashaPoolTableRow.Id, wishId, self.cancelSource:CreateToken())
      if success then
        Z.UIMgr:CloseView("gasha_illusion_popup")
      end
    elseif self.gashaVm_.CheckCanGashaWish(self.gashaPoolTableRow.Id) and wishId ~= 0 then
      local success = self.gashaVm_.AsyncGashaWishSelection(self.gashaPoolTableRow.Id, wishId, self.cancelSource:CreateToken())
      if success then
        Z.UIMgr:CloseView("gasha_illusion_popup")
      end
    end
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("gasha_illusion_popup")
  end)
  self:AddClick(self.uiBinder.btn_left, function()
    self:selectChange(false)
  end)
  self:AddClick(self.uiBinder.btn_right, function()
    self:selectChange(true)
  end)
  self:showStartAnim()
end

function Gasha_illusion_popupView:onSelectedPray(id)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
  if itemRow == nil then
    return
  end
  self.selectWishId_ = id
  self.uiBinder.lab_select_info.text = string.format(Lang("select_pray_item"), itemRow.Name)
  if self.selectWishId_ == self.gashaVm_.GetGashaPoolWishId(self.gashaPoolTableRow.Id) then
    self.uiBinder.lab_content.text = Lang("CancelGashaSupplication")
  else
    self.uiBinder.lab_content.text = Lang("GashaSupplication")
  end
end

function Gasha_illusion_popupView:OnDeActive()
  self:initEffectAndDepth()
  self.selectSub_ = nil
  self.selectSubType_ = 0
end

function Gasha_illusion_popupView:OnRefresh()
end

function Gasha_illusion_popupView:refreshSelectItem()
  local wishSelectItems = self.gashaPoolTableRow.WishItem
  local wishItem = self.gashaVm_.GetGashaPoolWishId(self.gashaPoolTableRow.Id)
  self.select_ = 1
  self.wishItemCount_ = #wishSelectItems
  for index, itemId in ipairs(wishSelectItems) do
    if itemId == wishItem then
      self.select_ = index
      break
    end
  end
  self:setItemSelected()
end

function Gasha_illusion_popupView:selectChange(add)
  if add then
    if self.select_ >= self.wishItemCount_ then
      return
    end
    self.select_ = self.select_ + 1
  else
    if self.select_ <= 1 then
      return
    end
    self.select_ = self.select_ - 1
  end
  self:setItemSelected()
end

function Gasha_illusion_popupView:onClickStandee(index)
  self.select_ = index
  self:setItemSelected()
end

function Gasha_illusion_popupView:showStartAnim()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Gasha_illusion_popupView:initSelectSub()
  if string.zisEmpty(self.gashaPoolTableRow.ResonancePrefab) then
    return
  end
  self.selectSub_ = self:AsyncLoadUiUnit(self.gashaPoolTableRow.ResonancePrefab, "GashaSelectSub", self.uiBinder.node_illusion_sub)
  self.selectSubType_ = string.sub(self.gashaPoolTableRow.ResonancePrefab, -1)
  for i = 1, self.selectSubType_ do
    self:AddClick(self.selectSub_["gasha_illusion_item_tpl_" .. i].btn_icon, function()
      self:onClickStandee(i)
    end)
  end
  self:initEffectAndDepth(true)
  self:refreshSelectItem()
end

function Gasha_illusion_popupView:initEffectAndDepth(isAdd)
  if isAdd then
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.selectSub_.ui_depth)
    for i = 1, self.selectSubType_ do
      self.selectSub_.ui_depth:AddChildDepth(self.selectSub_["rimg_icon_head_" .. i])
      self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.selectSub_["gasha_illusion_item_tpl_" .. i].effect_select)
    end
  else
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.selectSub_.ui_depth)
    for i = 1, self.selectSubType_ do
      self.selectSub_.ui_depth:RemoveChildDepth(self.selectSub_["rimg_icon_head_" .. i])
      self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.selectSub_["gasha_illusion_item_tpl_" .. i].effect_select)
    end
  end
end

function Gasha_illusion_popupView:setItemSelected()
  local selectItem = self.selectSub_["gasha_illusion_item_tpl_" .. self.select_]
  if not selectItem then
    return
  end
  self:hideEffect()
  selectItem.Trans:SetAsLastSibling()
  selectItem.Ref:SetVisible(selectItem.rimg_select, true)
  selectItem.anim_rimg_select:Restart(Z.DOTweenAnimType.Open)
  self.selectSub_["rimg_icon_head_" .. self.select_]:SetEffectGoVisible(true)
  self.selectSub_["gasha_illusion_item_tpl_" .. self.select_].effect_select:SetEffectGoVisible(true)
  self.selectSub_["gasha_illusion_item_tpl_" .. self.select_].effect_select:Play()
  self:onSelectedPray(self.gashaPoolTableRow.WishItem[self.select_])
end

function Gasha_illusion_popupView:hideEffect()
  local selectItem
  for i = 1, self.selectSubType_ do
    self.selectSub_["rimg_icon_head_" .. i]:SetEffectGoVisible(false)
    self.selectSub_["gasha_illusion_item_tpl_" .. i].effect_select:SetEffectGoVisible(false)
    selectItem = self.selectSub_["gasha_illusion_item_tpl_" .. i]
    selectItem.Ref:SetVisible(selectItem.rimg_select, false)
  end
end

return Gasha_illusion_popupView
