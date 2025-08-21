local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_itemselect_tipsView = class("Fishing_itemselect_tipsView", super)
local loopListView = require("ui.component.loop_list_view")
local fishingItemSelectItem = require("ui.component.fishing.fishing_itemselect_loop_item")

function Fishing_itemselect_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_itemselect_tips", "fishing/fishing_itemselect_tips", UI.ECacheLv.None)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function Fishing_itemselect_tipsView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, fishingItemSelectItem, "fishing_select_tips_tpl")
  self.loopListView_:Init({})
end

function Fishing_itemselect_tipsView:refreshLoopListView()
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Item, nil)
  local dataListTmp_ = self.itemsVM_.GetItemIds(E.BackPackItemPackageType.Item, nil, sortFunc, false)
  local dataList_ = {}
  for _, v in ipairs(dataListTmp_) do
    local itemConfig_ = Z.TableMgr.GetTable("ItemTableMgr").GetRow(v.configId)
    if itemConfig_ and itemConfig_.Type == self.selectType_ then
      local data_ = {}
      data_.uuid = v.itemUuid
      data_.configId = v.configId
      data_.type = self.viewData.selectType
      table.insert(dataList_, data_)
    end
  end
  self.loopListView_:RefreshListView(dataList_)
  local noData_ = dataList_ == nil or #dataList_ == 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_buy, noData_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_tips, noData_)
end

function Fishing_itemselect_tipsView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Fishing_itemselect_tipsView:OnActive()
  self.selectType_ = self.viewData.selectType
  self.parentUIView_ = self.viewData.parentView
  self.uiBinder.presscheck:StopCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
  self:AddClick(self.uiBinder.btn_close, function()
    self:DeActive()
  end)
  self:AddClick(self.uiBinder.btn_buy, function()
    self.fishingVM_.OpenMainFuncWindow(E.FishingMainFunc.Shop)
    self:DeActive()
  end)
  self:initLoopListView()
  Z.UIMgr:AddShowMouseView("fishing_itemselect_tips_view")
end

function Fishing_itemselect_tipsView:OnDeActive()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.uiBinder.presscheck:StopCheck()
  self:unInitLoopListView()
  Z.UIMgr:RemoveShowMouseView("fishing_itemselect_tips_view")
end

function Fishing_itemselect_tipsView:OnRefresh()
  self.uiBinder.presscheck:StartCheck()
  local pivotX = self.viewData.extraParams.pivotX or 0.5
  local pivotY = self.viewData.extraParams.pivotY or 1
  self.uiBinder.img_bg:SetPivot(pivotX, pivotY)
  self.uiBinder.img_bg.position = self.viewData.extraParams.fixedPos
  self:refreshLoopListView()
end

function Fishing_itemselect_tipsView:OnItemSelect(id)
  if self.selectType_ == E.FishingItemType.FishBait then
    self.fishingVM_.SetFishingBaitAsync(id, self.parentUIView_.cancelSource:CreateToken())
  elseif self.selectType_ == E.FishingItemType.FishingRod then
    self.fishingVM_.SetFishingRodAsync(id, self.parentUIView_.cancelSource:CreateToken())
  end
  self:DeActive()
end

function Fishing_itemselect_tipsView:ShowItemTips(parentTrans, configId, uuid)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(parentTrans, configId, uuid)
end

return Fishing_itemselect_tipsView
