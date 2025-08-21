local UI = Z.UI
local super = require("ui.ui_view_base")
local Item_shortcuts_popupView = class("Item_shortcuts_popupView", super)
local itemClass = require("common.item")

function Item_shortcuts_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "item_shortcuts_popup")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.takeMedicineData_ = Z.DataMgr.Get("take_medicine_bag_data")
end

function Item_shortcuts_popupView:OnActive()
  self.itemClassTab_ = {}
  self:AddClick(self.uiBinder.press_check.ContainGoEvent, function(isCheck)
    if not isCheck then
      Z.UIMgr:CloseView("item_shortcuts_popup")
    end
  end)
  self.uiBinder.press_check:StartCheck()
  self:initItem()
  self:setImagePos()
end

function Item_shortcuts_popupView:setImagePos()
  if not self.viewData then
    return
  end
  self.uiBinder.trans_bg.position = self.viewData
end

function Item_shortcuts_popupView:initItem()
  self.allItemInfos_ = self.takeMedicineData_:GetMedicineList()
  local itemPath = self.uiBinder.uiprefab_cache:GetString("item")
  if not itemPath then
    return
  end
  self:SetUIVisible(self.uiBinder.lab_item_empty, #self.allItemInfos_ == 0)
  Z.CoroUtil.create_coro_xpcall(function()
    for _, itemIds in ipairs(self.allItemInfos_) do
      local name = "item" .. itemIds
      if self.units[name] == nil then
        local unit = self:AsyncLoadUiUnit(itemPath, name, self.uiBinder.trans_content)
        self.itemClassTab_[name] = itemClass.new(self)
        self.itemClassTab_[name]:InitCircleItem(unit, itemIds)
        local count = self.itemsVm_.GetItemTotalCount(itemIds)
        if 99 < count then
          count = 99 .. "+"
        end
        unit.lab_shortcuts_num.TMPLab.text = count
        self:AddAsyncClick(unit.btn_bg.Btn, function()
          local ret = self.itemsVm_.AsyncSetQuickBar(itemIds, self.cancelSource:CreateToken())
          if ret == 0 then
            Z.UIMgr:CloseView("item_shortcuts_popup")
          end
        end, nil, nil)
        self:EventAddAsyncListener(unit.btn_bg.Btn.OnLongPressEvent, function()
          if itemIds == 0 then
            return
          end
          self.tipsId = Z.TipsVM.ShowItemTipsView(unit.Trans, itemIds)
        end, nil, nil)
      end
    end
  end)()
end

function Item_shortcuts_popupView:OnDeActive()
  self.uiBinder.press_check:StopCheck()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.CloseShortcutsPopup)
end

function Item_shortcuts_popupView:OnRefresh()
end

return Item_shortcuts_popupView
