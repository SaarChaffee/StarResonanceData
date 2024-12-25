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
end

function EquipRecastPopupLooItem:OnRefresh(data)
  self.data_ = data
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data.configId
  itemData.uuid = data.uuid
  itemData.itemInfo = data
  itemData.isClickOpenTips = false
  self.itemClass_:Init(itemData)
end

function EquipRecastPopupLooItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected, isSelected)
  if isSelected then
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    local onClickSelect = function()
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.data_.configId, self.data_.uuid)
      self.uiView_:StartCheck()
      Z.EventMgr:Dispatch(Z.ConstValue.Equip.SelectedRecastItem, self.data_)
    end
    if self.data_ then
      local canTrade = self.tradeVM_:CheckItemCanExchange(self.data_.configId, self.data_.uuid)
      if canTrade then
        self.uiView_:StopCheck()
        self.equipVm_.OpenDayDialog(onClickSelect, Lang("EquipRecastCanTradeTips"), E.DlgPreferencesKeyType.EquipRecastCanTradeTips, function()
          self.uiView_:StartCheck()
          self.parent:ClearAllSelect()
        end)
      elseif self.data_.equipAttr.totalRecastCount > 0 then
        self.uiView_:StopCheck()
        self.equipVm_.OpenDayDialog(onClickSelect, Lang("EquipRecastingManytimesTips", {
          val1 = self.data_.equipAttr.totalRecastCount,
          val2 = self.data_.equipAttr.perfectionValue
        }), E.DlgPreferencesKeyType.EquipRecastingManytimesTips, function()
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
