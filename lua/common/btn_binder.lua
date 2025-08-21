local BtnBinder = class("BtnBinder")
local itemBtnUnit_ = require("ui.item_btns.itembtn_uiunit")

function BtnBinder:ctor(parent)
  self.uiView_ = parent
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function BtnBinder:InitData(btnBinderInfo)
  self.btnBinderInfo_ = btnBinderInfo
  self.uiBinder = btnBinderInfo.uiBinder
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self.units_ = {}
  self.tokens_ = {}
  self:init()
end

function BtnBinder:initZWidget()
  self.rightBtnBinder_ = self.uiBinder.btn_right_binder
  self.leftBtnBinder_ = self.uiBinder.btn_left_binder
  self.scrollRect_ = self.uiBinder.loop_item
  self.moreOffBinder_ = self.uiBinder.btn_more_off_binder
  self.moreOnBinder_ = self.uiBinder.btn_more_on_binder
  self.press_ = self.uiBinder.press
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function BtnBinder:init()
  self:initZWidget()
  self.itemBtnUnits_ = {}
  
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
  self:onRefresh()
end

function BtnBinder:OnUnInit()
  if self.uiBinder == nil then
    return
  end
  Z.RedPointMgr.RemoveChildernNodeItem(self.moreOffBinder_.Trans, self.uiView_)
  Z.RedPointMgr.RemoveChildernNodeItem(self.moreOnBinder_.Trans, self.uiView_)
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self.btnData_ = nil
  if self.itemBtnUnits_ then
    for key, value in pairs(self.itemBtnUnits_) do
      value:UnInit()
    end
  end
  self.itemBtnUnits_ = nil
  self.btnData_ = nil
  self.configId_ = nil
  self.itemUuId_ = nil
  self.rightBtnType_ = nil
  self.uiBinder = nil
  self.btnUnits_ = {}
  if self.itemData_ then
    self.itemData_.Watcher:UnregWatcher(self.refreshUI_)
  end
  self.itemData_ = nil
end

function BtnBinder:onRefresh()
  if not (self.btnBinderInfo_ and self.btnBinderInfo_.configId) or not self.btnBinderInfo_.itemUuId then
    return
  end
  if self.itemData_ then
    self.itemData_.Watcher:UnregWatcher(self.refreshUI_)
  end
  self.btnData_ = self.btnBinderInfo_.btnData
  self.configId_ = self.btnBinderInfo_.configId
  self.itemUuId_ = self.btnBinderInfo_.itemUuId
  self.itemData_ = self.itemsVm_.GetItemInfobyItemId(self.itemUuId_, self.configId_)
  self.btnData_.cancelSource = self.uiView_.cancelSource
  if self.itemData_ then
    self.itemData_.Watcher:RegWatcher(self.refreshUI_)
  end
  self:refreshBtns()
end

function BtnBinder:refreshBtnState()
  self.uiBinder.Ref:SetVisible(self.scrollRect_, self.isShowBtns_)
  self.moreOnBinder_.Ref.UIComp:SetVisible(self.isShowBtns_)
  self.moreOffBinder_.Ref.UIComp:SetVisible(not self.isShowBtns_)
end

function BtnBinder:refreshBtns()
  self.isShowBtns_ = false
  self:refreshBtnState()
  self.press_:StopCheck()
  self:removeAllOperationBtns()
  local btnInfos = {}
  if self.btnBinderInfo_.viewBtns then
    btnInfos = Z.ItemOperatBtnMgr.GetItemBtnInfosByType(self.btnBinderInfo_.viewBtns, self.itemUuId_, self.configId_, self.btnData_)
  else
    btnInfos = Z.ItemOperatBtnMgr.GetItemBtns(self.itemUuId_, self.configId_, self.btnData_)
  end
  self.btnInfos_ = btnInfos
  local count = #btnInfos
  for unitName, token in pairs(self.tokens_) do
    Z.CancelSource.ReleaseToken(token)
  end
  self.tokens_ = {}
  self.units_ = {}
  for unitName, unit in pairs(self.units_) do
    self.uiView_:RemoveUiUnit(unitName)
  end
  self.units_ = {}
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.RefreshBtnSubState, 0 < count)
  if count == 0 then
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(true)
  if self.itemsVm_.CheckPackageTypeByItemUuid(self.itemUuId_, E.BackPackItemPackageType.Equip) then
    if self.switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipFunc) then
      self:refreshEquipBtns()
    end
  else
    self:refreshItemBtns()
  end
  self.uiView_:AddClick(self.moreOffBinder_.btn, function()
    self.isShowBtns_ = not self.isShowBtns_
    self:refreshBtnState()
    if self.isShowBtns_ then
      self.press_:StartCheck()
    end
  end)
  self.uiView_:AddClick(self.moreOnBinder_.btn, function()
    self.isShowBtns_ = not self.isShowBtns_
    self:refreshBtnState()
    if self.isShowBtns_ then
      self.press_:StartCheck()
    end
  end)
  self.moreOffBinder_.lab_content.text = Lang("More")
  self.moreOnBinder_.lab_content.text = Lang("More")
  local btnItemPath = self.prefabCache_:GetString("btnItem")
  if btnItemPath ~= "" and btnItemPath ~= nil and #self.btnInfos_ > 2 then
    Z.CoroUtil.create_coro_xpcall(function()
      for key, value in pairs(self.btnInfos_) do
        if not self.rightBtnType_ or self.rightBtnType_ and self.rightBtnType_ ~= value.key and value.state == E.ItemBtnState.Active then
          local token = self.uiView_.cancelSource:CreateToken()
          local unitName = "btn_unit" .. key
          self.tokens_[unitName] = token
          local unit = self.uiView_:AsyncLoadUiUnit(btnItemPath, unitName, self.scrollRect_.content.transform, token)
          if unit then
            self.units_[unitName] = unit
            self:initGo(value, unit)
            local redName_ = Z.ItemOperatBtnMgr.LoadRedNode(value.key, self.itemUuId_, self.configId_)
            if redName_ then
              Z.RedPointMgr.LoadRedDotItem(redName_, self.uiView_, self.moreOffBinder_.Trans)
              Z.RedPointMgr.LoadRedDotItem(redName_, self.uiView_, self.moreOnBinder_.Trans)
            end
          end
        end
      end
    end)()
  end
end

function BtnBinder:setMoreBtnState(state)
  self.moreOffBinder_.Ref.UIComp:SetVisible(state)
end

function BtnBinder:refreshEquipBtns()
  local lefBtns, rightBtns = Z.ItemOperatBtnMgr.GetFilterEquipBtns(self.btnInfos_)
  if not lefBtns or not next(lefBtns) then
    self:setMoreBtnState(false)
  elseif #lefBtns == 1 then
    self:initGo(lefBtns[1], self.leftBtnBinder_)
  else
    self:setMoreBtnState(true)
    for key, value in pairs(lefBtns) do
      if value.key == Z.ItemOperatBtnMgr.EBtnType.EquipPutOnBtn or value.key == Z.ItemOperatBtnMgr.EBtnType.EquipReplaceBtn then
        self.rightBtnType_ = value.key
        self:initGo(value, self.rightBtnBinder_)
      end
    end
  end
  for key, value in pairs(rightBtns) do
    self.rightBtnType_ = value.key
    self:initGo(value, self.rightBtnBinder_)
  end
end

function BtnBinder:refreshItemBtns()
  local firstBtn = self.rightBtnBinder_
  local secondBtn = self.leftBtnBinder_
  if self.btnData_.isLeft then
    firstBtn = self.leftBtnBinder_
    secondBtn = self.rightBtnBinder_
  end
  local count = #self.btnInfos_
  if count <= 2 then
    self:initGo(self.btnInfos_[1], firstBtn)
    if count == 2 then
      self.rightBtnType_ = self.btnInfos_[2].key
      self:initGo(self.btnInfos_[2], secondBtn)
    end
  elseif 2 < count then
    self.rightBtnType_ = self.btnInfos_[1].key
    self:initGo(self.btnInfos_[1], firstBtn)
    self:setMoreBtnState(true)
  end
end

function BtnBinder:removeAllOperationBtns()
  self.rightBtnBinder_.Ref.UIComp:SetVisible(false)
  self.leftBtnBinder_.Ref.UIComp:SetVisible(false)
  self:setMoreBtnState(false)
  self.uiBinder.Ref:SetVisible(self.scrollRect_, false)
  if self.itemBtnUnits_ then
    for key, value in pairs(self.itemBtnUnits_) do
      value:UnInit()
    end
  end
  self.itemBtnUnits_ = {}
end

function BtnBinder:initGo(value, uiBinder)
  local itemBtnUnit = itemBtnUnit_.new()
  itemBtnUnit:Init_Go(self.uiView_, self.itemUuId_, self.configId_, value, uiBinder, self.btnData_)
  table.insert(self.itemBtnUnits_, itemBtnUnit)
  Z.GuideMgr:SetSteerIdByComp(uiBinder.steer, E.DynamicSteerType.EquipBtn, value.key)
end

return BtnBinder
