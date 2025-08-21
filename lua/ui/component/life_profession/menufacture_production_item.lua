local super = require("ui.component.loop_list_view_item")
local MenufactureProductionItem = class("MenufactureProductionItem", super)
local item = require("common.item_binder")
local life_metarial_preview_sub_view = require("ui.view.life_metarial_preview_sub_view")

function MenufactureProductionItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.cookVm_ = Z.VMMgr.GetVM("cook")
  self.tipsBoxShowPopupVM = Z.VMMgr.GetVM("tips_box_show_popup")
  self.life_metarial_preview_sub_view_ = life_metarial_preview_sub_view.new(self.parent.UIView)
end

function MenufactureProductionItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemsVM_ = Z.VMMgr.GetVM("items")
  local itemData = {}
  local itemID = data.itemID
  local materials = {}
  if data.isItemType then
    materials = self.cookVm_.GetAllCookMaterialData(data.itemID)
    if #materials == 0 then
      return
    end
    itemID = materials[1].Id
  end
  itemData.configId = itemID
  itemData.uiBinder = self.uiBinder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.labType = E.ItemLabType.Expend
  local homeData = Z.DataMgr.Get("home_editor_data")
  local curHave = 0
  if homeData:GetItemIsHouseWarehouseItem(itemID) then
    curHave = homeData:GetSelfFurnitureWarehouseItemCount(itemID)
  else
    curHave = itemsVM_.GetItemTotalCount(itemID)
  end
  itemData.lab = curHave
  itemData.expendCount = data.count
  itemData.colorKey = E.TextStyleTag.ItemNotEnough
  local itemTypeFunction = function()
    local awardDataList = {}
    for k, v in pairs(materials) do
      local itemPreviewData = {}
      itemPreviewData.awardId = v.Id
      table.insert(awardDataList, itemPreviewData)
    end
    self.life_metarial_preview_sub_view_:Active({data = awardDataList}, self.parent.UIView.uiBinder.node_tips)
  end
  itemData.clickCallFunc = data.isItemType and 1 < #materials and itemTypeFunction or nil
  self.itemClass_:RefreshByData(itemData)
  self.itemClass_:SetImgAskState(data.isItemType and 1 < #materials)
end

function MenufactureProductionItem:OnUnInit()
  self.itemClass_:UnInit()
  self.life_metarial_preview_sub_view_:DeActive()
end

function MenufactureProductionItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
end

return MenufactureProductionItem
