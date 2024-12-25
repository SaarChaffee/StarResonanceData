local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_key_expend_popupView = class("Hero_dungeon_key_expend_popupView", super)

function Hero_dungeon_key_expend_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_key_expend_popup")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Hero_dungeon_key_expend_popupView:OnActive()
  self:initBinders()
  self:initBaseData()
end

function Hero_dungeon_key_expend_popupView:OnDeActive()
end

function Hero_dungeon_key_expend_popupView:OnRefresh()
end

function Hero_dungeon_key_expend_popupView:initBaseData()
  self.itemUuid = self.viewData.itemUuid
  local costCfg = self.itemsVM_.GetRecastKeyCost()
  local costItemId = Z.SystemItem.ItemCoin
  local costNum = 0
  if costCfg then
    costItemId = costCfg[#costCfg - 1]
    costNum = costCfg[#costCfg]
  end
  if 0 < costNum then
    local item = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(costItemId))
    self.uiBinder.lab_02.text = "x" .. costNum
  end
  self:SetUIVisible(self.uiBinder.node_empty, costNum == 0)
  self:SetUIVisible(self.uiBinder.node_lab, 0 < costNum)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  local needTips = self.itemsVM_.GetIsNeedRecastKeyTips()
  self.uiBinder.tog_item.isOn = not needTips
end

function Hero_dungeon_key_expend_popupView:initBinders()
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    local ret = self.itemsVM_.AsyncReforgeKey(self.itemUuid, self.cancelSource:CreateToken())
    if ret == 0 then
      local isOn = self.uiBinder.tog_item.isOn
      self.itemsVM_.SetIsNeedRecastKeyTips(not isOn)
      self.itemsVM_:CloseKeyRecastConfirmView()
    end
  end)
  self:AddClick(self.uiBinder.btn_no, function()
    self.itemsVM_:CloseKeyRecastConfirmView()
  end)
end

return Hero_dungeon_key_expend_popupView
