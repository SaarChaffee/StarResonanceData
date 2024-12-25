local UI = Z.UI
local super = require("ui.ui_view_base")
local Item_shortcuts_popupView = class("Item_shortcuts_popupView", super)
local itemClass = require("common.item")

function Item_shortcuts_popupView:ctor()
  self.panel = nil
  super.ctor(self, "item_shortcuts_popup")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
end

function Item_shortcuts_popupView:initZWidget()
  self.content_ = self.panel.node_content
  self.press_ = self.panel.node_press
end

function Item_shortcuts_popupView:OnActive()
  self:initZWidget()
  self.itemClassTab_ = {}
  self.press_.PressCheck:StartCheck()
  self:AddClick(self.press_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      Z.UIMgr:CloseView("item_shortcuts_popup")
    end
  end)
  self:initItem()
  self:setImagePos()
end

function Item_shortcuts_popupView:setImagePos()
  if not self.viewData then
    return
  end
  self.panel.img_bg.Trans.position = self.viewData
end

function Item_shortcuts_popupView:initItem()
  local sortFunc = self.itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.Item, nil)
  self.allItemInfos_ = self.itemsVm_.GetItemIds(E.BackPackItemPackageType.Item, nil, sortFunc, true)
  local itemPath = self:GetPrefabCacheData("item")
  if not itemPath then
    return
  end
  self.panel.lab_noitem:SetVisible(table.zcount(self.allItemInfos_) == 0)
  Z.CoroUtil.create_coro_xpcall(function()
    for _, itemIds in pairs(self.allItemInfos_) do
      local name = "item" .. itemIds.configId
      if self.units[name] == nil then
        local unit = self:AsyncLoadUiUnit(itemPath, name, self.content_.Trans)
        self.itemClassTab_[name] = itemClass.new(self)
        self.itemClassTab_[name]:InitCircleItem(unit, itemIds.configId, itemIds.uuid)
        local count = self.itemsVm_.GetItemTotalCount(itemIds.configId)
        if 99 < count then
          count = 99 .. "+"
        end
        unit.lab_shortcuts_num.TMPLab.text = count
        self:AddAsyncClick(unit.btn_bg.Btn, function()
          local ret = self.itemsVm_.AsyncSetQuickBar(itemIds.configId, self.cancelSource:CreateToken())
          if ret == 0 then
            Z.UIMgr:CloseView("item_shortcuts_popup")
          end
        end, nil, nil)
        self:EventAddAsyncListener(unit.btn_bg.Btn.OnLongPressEvent, function()
          if itemIds.configId == 0 then
            return
          end
          self.tipsId = Z.TipsVM.ShowItemTipsView(unit.Trans, itemIds.configId, itemIds.uuid)
        end, nil, nil)
      end
    end
  end)()
end

function Item_shortcuts_popupView:OnDeActive()
  self.press_.PressCheck:StopCheck()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.CloseShortcutsPopup)
end

function Item_shortcuts_popupView:OnRefresh()
end

return Item_shortcuts_popupView
