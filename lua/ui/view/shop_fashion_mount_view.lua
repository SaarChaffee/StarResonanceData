local UI = Z.UI
local super = require("ui.view.shop_fashion_base_view")
local Shop_fashion_mount_subView = class("Shop_fashion_mount_subView", super)

function Shop_fashion_mount_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.subCtor(self, "shop_fashion_treasure_sub", "shop/shop_fashion_treasure_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_mount_subView:OnActive()
  super.OnActive(self)
  self:InitShopList()
  self:refreshShopList()
  self:refreshBtnState()
end

function Shop_fashion_mount_subView:OnDeActive()
  super.OnDeActive(self)
  self:ClearShopList()
end

function Shop_fashion_mount_subView:refreshBtnState()
  self.uiBinder.lab_goto.text = Lang("MountView")
  self.uiBinder.img_goto:SetImage("ui/atlas/item/c_tab_icon/com_icon_tab_94")
end

function Shop_fashion_mount_subView:refreshShopList()
  if not self.viewData.mallTableRow then
    return
  end
  local itemList = self:GetShopItemList(self.viewData.mallTableRow.Id)
  self.shopGridView_:RefreshListView(itemList, false)
  self:refreshItemSelect(itemList)
end

function Shop_fashion_mount_subView:refreshItemSelect(items)
  self.shopGridView_:ClearAllSelect()
  if self.viewData.configId then
    local index = 1
    for i = 1, #items do
      if items[i].cfg and items[i].cfg.ItemId == self.viewData.configId then
        index = i
        break
      end
    end
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
    self.viewData.configId = nil
  elseif self.viewData.shopItemIndex then
    local index = self.viewData.shopItemIndex
    self:clearShopItemIndex()
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
  elseif 1 <= #items then
    if not items[1].cfg then
      return
    end
    if items[1].cfg.GoodsType == E.EShopGoodsType.EMount then
      self:OnSelectMount(items[1].cfg)
    else
      self:CheckNormalShopItemPreview(items[1].cfg)
    end
    self:AsyncRefreshUnrealSceneBG(items[1].cfg.UnrealSceneBg)
  end
end

function Shop_fashion_mount_subView:onClickFashion()
  local previewMount = false
  local vehicleVM = Z.VMMgr.GetVM("vehicle")
  if self.curMallItemRow_ then
    if self.curMallItemRow_.GoodsType == E.EShopGoodsType.EMount then
      local mountId = self.curMallItemRow_.ItemId
      if self.curMallItemRow_.FashionList[1] and self.curMallItemRow_.FashionList[1] > 0 then
        mountId = self.curMallItemRow_.FashionList[1]
      end
      vehicleVM.OpenVehicleMain(mountId)
      previewMount = true
    else
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.curMallItemRow_.ItemId, true)
      if itemRow and itemRow.Type == E.ItemType.VehicleUnlockItem then
        if not self.vehicleBaseTableMap_ then
          self.vehicleBaseTableMap_ = require("table.VehicleBaseTableMap")
        end
        local vehicleList = self.vehicleBaseTableMap_.VehicleSkinUnlock[self.curMallItemRow_.ItemId]
        if vehicleList and vehicleList[1] then
          vehicleVM.OpenVehicleMain(vehicleList[1])
          previewMount = true
        end
      end
    end
  end
  if not previewMount then
    vehicleVM.OpenVehicleMain()
  end
end

return Shop_fashion_mount_subView
