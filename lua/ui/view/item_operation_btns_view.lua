local UI = Z.UI
local super = require("ui.ui_subview_base")
local Item_operation_btnsView = class("Item_operation_btnsView", super)
local itemBtnUnit_ = require("ui.item_btns.itembtn_uiunit")

function Item_operation_btnsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "item_operation_btns_sub", "bag/item_operation_btns_sub", UI.ECacheLv.None)
  self.switchVm_ = Z.VMMgr.GetVM("switch")
end

function Item_operation_btnsView:initZWidget()
  self.rightBtnBinder_ = self.uiBinder.btn_right_binder
  self.leftBtnBinder_ = self.uiBinder.btn_left_binder
  self.scrollRect_ = self.uiBinder.loop_item
  self.moreOffBinder_ = self.uiBinder.btn_more_off_binder
  self.moreOnBinder_ = self.uiBinder.btn_more_on_binder
  self.press_ = self.uiBinder.press
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function Item_operation_btnsView:OnActive()
  self:initZWidget()
  self.itemBtnUnits_ = {}
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  
  function self.refreshUI_(container, dirtys)
    self:refreshBtns()
  end
  
  Z.UIUtil.UnityEventAddCoroFunc(self.press_.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.isShowBtns_ = false
      self:refreshBtnState()
      self.press_:StopCheck()
    end
  end)
end

function Item_operation_btnsView:OnDeActive()
  self:ClearAllUnits()
  self.btnData_ = nil
  self.itemBtnUnits_ = nil
  self.btnData_ = nil
  self.configId_ = nil
  self.itemUuId_ = nil
  self.rightBtnType_ = nil
  self.btnUnits_ = {}
  if self.itemData_ then
    self.itemData_.Watcher:UnregWatcher(self.refreshUI_)
  end
  self.itemData_ = nil
end

function Item_operation_btnsView:OnRefresh()
  if not (self.viewData and self.viewData.configId) or not self.viewData.itemId then
    return
  end
  if self.itemData_ then
    self.itemData_.Watcher:UnregWatcher(self.refreshUI_)
  end
  self.btnData_ = self.viewData.btnData
  self.configId_ = self.viewData.configId
  self.itemUuId_ = self.viewData.itemId
  self.itemData_ = self.itemsVm_.GetItemInfobyItemId(self.itemUuId_, self.configId_)
  self.btnData_.cancelSource = self.cancelSource
  if self.itemData_ then
    self.itemData_.Watcher:RegWatcher(self.refreshUI_)
  end
  self:refreshBtns()
end

function Item_operation_btnsView:refreshBtnState()
  self.uiBinder.Ref:SetVisible(self.scrollRect_, self.isShowBtns_)
  self.moreOnBinder_.Ref.UIComp:SetVisible(self.isShowBtns_)
  self.moreOffBinder_.Ref.UIComp:SetVisible(not self.isShowBtns_)
end

function Item_operation_btnsView:refreshBtns()
  self.isShowBtns_ = false
  self:refreshBtnState()
  self.press_:StopCheck()
  self:removeAllOperationBtns()
  self:ClearAllUnits()
  local btnInfos = Z.ItemOperatBtnMgr.GetItemBtns(self.itemUuId_, self.configId_, self.btnData_)
  self.btnInfos_ = btnInfos
  local count = #btnInfos
  if count == 0 then
    return
  end
  if self.itemsVm_.CheckPackageTypeByItemUuid(self.itemUuId_, E.BackPackItemPackageType.Equip) then
    if self.switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipFunc) then
      self:refreshEquipBtns()
    end
  else
    self:refreshItemBtns()
  end
  self:AddClick(self.moreOffBinder_.btn, function()
    self.isShowBtns_ = not self.isShowBtns_
    self:refreshBtnState()
    if self.isShowBtns_ then
      self.press_:StartCheck()
    end
  end)
  self:AddClick(self.moreOnBinder_.btn, function()
    self.isShowBtns_ = not self.isShowBtns_
    self:refreshBtnState()
    if self.isShowBtns_ then
      self.press_:StartCheck()
    end
  end)
  self.moreOffBinder_.lab_content.text = Lang("More")
  self.moreOnBinder_.lab_content.text = Lang("More")
  local btnItemPath = self.prefabCache_:GetString("btnItem")
  if btnItemPath ~= "" and btnItemPath ~= nil then
    Z.CoroUtil.create_coro_xpcall(function()
      for key, value in pairs(self.btnInfos_) do
        if not self.rightBtnType_ or self.rightBtnType_ and self.rightBtnType_ ~= value.key and value.state == E.ItemBtnState.Active then
          local uiBinder = self:AsyncLoadUiUnit(btnItemPath, key, self.scrollRect_.content.transform)
          local itemBtnUnit = itemBtnUnit_.new()
          itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, value, uiBinder, self.btnData_)
          local redName_ = Z.ItemOperatBtnMgr.LoadRedNode(value.key, self.itemUuId_, self.configId_)
          if redName_ then
            Z.RedPointMgr.LoadRedDotItem(redName_, self, self.moreOffBinder_.Trans)
            Z.RedPointMgr.LoadRedDotItem(redName_, self, self.moreOnBinder_.Trans)
          end
          uiBinder.steer:ClearSteerList()
          Z.GuideMgr:SetSteerIdByComp(uiBinder.steer, E.DynamicSteerType.EquipBtn, value.key)
        end
      end
    end)()
  end
end

function Item_operation_btnsView:setMoreBtnState(state)
  self.moreOffBinder_.Ref.UIComp:SetVisible(state)
end

function Item_operation_btnsView:refreshEquipBtns()
  local lefBtns, rightBtns = Z.ItemOperatBtnMgr.GetFilterEquipBtns(self.btnInfos_)
  if not lefBtns or not next(lefBtns) then
    self:setMoreBtnState(false)
  elseif #lefBtns == 1 then
    local itemBtnUnit = itemBtnUnit_.new()
    itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, lefBtns[1], self.leftBtnBinder_, self.btnData_)
    Z.GuideMgr:SetSteerIdByComp(self.leftBtnBinder_.steer, E.DynamicSteerType.EquipBtn, lefBtns[1].key)
    table.insert(self.itemBtnUnits_, itemBtnUnit)
  else
    self:setMoreBtnState(true)
    for key, value in pairs(lefBtns) do
      if value.key == Z.ItemOperatBtnMgr.EBtnType.EquipPutOnBtn or value.key == Z.ItemOperatBtnMgr.EBtnType.EquipReplaceBtn then
        self.rightBtnType_ = value.key
        local itemBtnUnit = itemBtnUnit_.new()
        itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, value, self.rightBtnBinder_, self.btnData_)
        Z.GuideMgr:SetSteerIdByComp(self.rightBtnBinder_.steer, E.DynamicSteerType.EquipBtn, value.key)
        table.insert(self.itemBtnUnits_, itemBtnUnit)
      end
    end
  end
  for key, value in pairs(rightBtns) do
    self.rightBtnType_ = value.key
    local itemBtnUnit = itemBtnUnit_.new()
    itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, value, self.rightBtnBinder_, self.btnData_)
    Z.GuideMgr:SetSteerIdByComp(self.rightBtnBinder_.steer, E.DynamicSteerType.EquipBtn, value.key)
    table.insert(self.itemBtnUnits_, itemBtnUnit)
  end
end

function Item_operation_btnsView:refreshItemBtns()
  local firstBtn = self.rightBtnBinder_
  local secondBtn = self.leftBtnBinder_
  if self.btnData_.isLeft then
    firstBtn = self.leftBtnBinder_
    secondBtn = self.rightBtnBinder_
  end
  local count = #self.btnInfos_
  if count <= 2 then
    local itemBtnUnit = itemBtnUnit_.new()
    itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, self.btnInfos_[1], firstBtn, self.btnData_)
    table.insert(self.itemBtnUnits_, itemBtnUnit)
    Z.GuideMgr:SetSteerIdByComp(firstBtn.steer, E.DynamicSteerType.EquipBtn, self.btnInfos_[1].key)
    if count == 2 then
      self.rightBtnType_ = self.btnInfos_[2].key
      local itemBtnUnit = itemBtnUnit_.new()
      itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, self.btnInfos_[2], secondBtn, self.btnData_)
      Z.GuideMgr:SetSteerIdByComp(secondBtn.steer, E.DynamicSteerType.EquipBtn, self.rightBtnType_)
      table.insert(self.itemBtnUnits_, itemBtnUnit)
    end
  elseif 2 < count then
    self.rightBtnType_ = self.btnInfos_[1].key
    local itemBtnUnit = itemBtnUnit_.new()
    itemBtnUnit:Init_Go(self, self.itemUuId_, self.configId_, self.btnInfos_[1], firstBtn, self.btnData_)
    table.insert(self.itemBtnUnits_, itemBtnUnit)
    self:setMoreBtnState(true)
  end
end

function Item_operation_btnsView:removeAllOperationBtns()
  self.rightBtnBinder_.Ref.UIComp:SetVisible(false)
  self.leftBtnBinder_.Ref.UIComp:SetVisible(false)
  self:setMoreBtnState(false)
  self.uiBinder.Ref:SetVisible(self.scrollRect_, false)
  self.itemBtnUnits_ = {}
end

return Item_operation_btnsView
