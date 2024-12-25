local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_key_popupView = class("Hero_dungeon_key_popupView", super)
local item = require("common.item_binder")

function Hero_dungeon_key_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_key_popup")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self)
end

function Hero_dungeon_key_popupView:OnActive()
  self:initBinders()
  self:initBaseData()
  self:BindEvents()
end

function Hero_dungeon_key_popupView:OnDeActive()
  self.itemClass_:UnInit()
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

function Hero_dungeon_key_popupView:OnRefresh()
end

function Hero_dungeon_key_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.KeyRecastSuccess, self.playKeyRecastEffect, self)
end

function Hero_dungeon_key_popupView:UnBindAllEvents()
  Z.EventMgr:Remove(Z.ConstValue.KeyRecastSuccess, self.playKeyRecastEffect, self)
end

function Hero_dungeon_key_popupView:initBinders()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    if self.itemEnough_ == false then
      Z.TipsVM.ShowTips(1004102)
      return
    end
    if self.costNum_ > 0 or self.itemsVM_.GetIsNeedRecastKeyTips() then
      self.itemsVM_.OpenKeyRecastConfirmView(self.itemId, self.itemUuid)
    else
      local ret = self.itemsVM_.AsyncReforgeKey(self.itemUuid, self.cancelSource:CreateToken())
      if ret == 0 then
        self:refreshCostItem()
      end
    end
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    if self.canClose_ == false then
      return
    end
    self.itemsVM_:CloseKeyRecastView()
  end)
end

function Hero_dungeon_key_popupView:initBaseData()
  self.itemUuid = self.viewData.itemUuid
  self.itemId = self.viewData.itemId
  local itemData = {}
  itemData.configId = self.itemId
  itemData.uiBinder = self.uiBinder.com_item
  itemData.labType, itemData.lab = E.ItemLabType.Num, 1
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  self:refreshCostItem()
end

function Hero_dungeon_key_popupView:refreshCostItem()
  local costCfg = self.itemsVM_.GetRecastKeyCost()
  local costNum = 0
  local costItem = Z.SystemItem.ItemCoin
  if costCfg then
    costNum = costCfg[#costCfg]
    costItem = costCfg[#costCfg - 1]
  end
  local item = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItem)
  self.costNum_ = costNum
  self.needShowTips = self.itemsVM_.GetIsNeedRecastKeyTips()
  self:SetUIVisible(self.uiBinder.lab_notice, costNum == 0)
  self:SetUIVisible(self.uiBinder.layout_lab, 0 < costNum)
  self.itemEnough_ = true
  if 0 < costNum then
    local itemCount = self.itemsVM_.GetItemTotalCount(costItem)
    self.itemEnough_ = costNum <= itemCount
    local strType = self.itemEnough_ and E.TextStyleTag.White or E.TextStyleTag.Red
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(costItem))
    local str = "x" .. costNum
    self.uiBinder.lab_02.text = Z.RichTextHelper.ApplyStyleTag(str, strType)
  end
  local affixStr = self.itemsVM_.GetKeyAffixStr(self.itemUuid, E.BackPackItemPackageType.Item)
  local linkDatas = {}
  local itemInfo = self.itemsVM_.GetItemInfo(self.itemUuid, E.BackPackItemPackageType.Item)
  if itemInfo then
    linkDatas = itemInfo.affixData.affixIds
  end
  self.uiBinder.lab_tips.text = Lang("KeyRecastAffixs") .. affixStr
  self.uiBinder.lab_tips:AddListener(function(key)
    local index = tonumber(key)
    local linkData = linkDatas[index]
    if linkData then
      Z.CommonTipsVM.OpenAffixTips({linkData}, self.uiBinder.transform)
    end
  end, true)
end

function Hero_dungeon_key_popupView:playKeyRecastEffect()
  self:refreshCostItem()
end

return Hero_dungeon_key_popupView
