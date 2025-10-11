local super = require("ui.component.loop_grid_view_item")
local EquipRecastPopupLooItem = class("EquipRecastPopupLooItem", super)
local item = require("common.item_binder")

function EquipRecastPopupLooItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
  
  function self.itemWatcherFun_(container, dirtyKeys)
    local backpackData = Z.DataMgr.Get("backpack_data")
    if backpackData.SortState then
      return
    end
    self:OnRefresh(self:GetCurData())
  end
  
  function self.packageWatcherFun(container, dirtyKeys)
    self.package_ = container
  end
  
  self.tradeVM_ = Z.VMMgr.GetVM("trade")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function EquipRecastPopupLooItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function EquipRecastPopupLooItem:OnRefresh(data)
  self.data_ = data
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.ConfigId,
    itemInfo = data.IsEquipItem and data.Item or nil,
    uuid = data.IsEquipItem and data.Item.uuid or nil,
    expendCount = not data.IsEquipItem and data.ExpendNum or nil,
    labType = not data.IsEquipItem and E.ItemLabType.Expend or nil,
    lab = self.itemVm_.GetItemTotalCount(data.ConfigId),
    isSquareItem = true,
    isClickOpenTips = false
  }
  self.itemClass_:RefreshByData(itemData)
end

function EquipRecastPopupLooItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected, isSelected)
  if isSelected then
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    local onClickSelect = function()
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.data_.ConfigId, self.data_.IsEquipItem and self.data_.Item.uuid or nil)
      self.uiView_:StartCheck()
      Z.EventMgr:Dispatch(Z.ConstValue.Equip.SelectedRecastItem, self.data_)
    end
    if self.data_.IsEquipItem then
      local canTrade = self.tradeVM_:CheckItemCanExchange(self.data_.Item.configId, self.data_.Item.uuid)
      if canTrade then
        local labDesc = self.uiView_:GetIsRecast() and Lang("EquipRecastCanTradeTips") or Lang("EquipCreateCanTradeTips")
        self.uiView_:StopCheck()
        self.equipVm_.OpenDayDialog(onClickSelect, labDesc, E.DlgPreferencesKeyType.EquipRecastCanTradeTips, function()
          self.uiView_:StartCheck()
          self.parent:ClearAllSelect()
        end)
      elseif self.data_.Item.equipAttr.totalRecastCount > 0 then
        self.uiView_:StopCheck()
        local labDesc = self.uiView_:GetIsRecast() and Lang("EquipRecastingManytimesTips", {
          val1 = self.data_.Item.equipAttr.totalRecastCount,
          val2 = self.data_.Item.equipAttr.perfectionValue
        }) or Lang("EquipCreateGoodTips", {
          val1 = self.data_.Item.equipAttr.totalRecastCount,
          val2 = self.data_.Item.equipAttr.perfectionValue
        })
        self.equipVm_.OpenDayDialog(onClickSelect, labDesc, E.DlgPreferencesKeyType.EquipRecastingManytimesTips, function()
          self.uiView_:StartCheck()
          self.parent:ClearAllSelect()
        end)
      else
        onClickSelect()
      end
    else
      onClickSelect()
    end
  end
end

function EquipRecastPopupLooItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function EquipRecastPopupLooItem:OnBeforePlayAnim()
end

return EquipRecastPopupLooItem
