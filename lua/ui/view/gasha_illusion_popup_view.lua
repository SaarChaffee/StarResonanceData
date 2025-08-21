local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_illusion_popupView = class("Gasha_illusion_popupView", super)

function Gasha_illusion_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_illusion_popup")
end

function Gasha_illusion_popupView:OnActive()
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.gashaPoolTableRow = self.viewData.gashaPoolTableRow
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
  self:AddAsyncClick(self.uiBinder.btn_left, function()
    self:selectChange(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_right, function()
    self:selectChange(true)
  end)
  for i = 1, 4 do
    self:AddClick(self.uiBinder["btn_standee_" .. i], function()
      self:onClickStandee(i)
    end)
  end
  self.selectWishId_ = 0
  self.select_ = 0
  self.wishItemCount_ = 0
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
end

function Gasha_illusion_popupView:OnRefresh()
  self:refreshSelectItem()
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
  self:setItemImg()
end

function Gasha_illusion_popupView:setItemImg()
  if string.zisEmpty(self.gashaPoolTableRow.ResonancePrefab) then
    return
  end
  local selectImgPath = string.format("%s%d", self.gashaPoolTableRow.ResonancePrefab, self.select_)
  self.uiBinder.rimg_icon:SetImage(selectImgPath)
  self:onSelectedPray(self.gashaPoolTableRow.WishItem[self.select_])
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
  self:setItemImg()
end

function Gasha_illusion_popupView:onClickStandee(index)
  self.select_ = index
  self:setItemImg()
end

return Gasha_illusion_popupView
