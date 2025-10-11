local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_take_medicine_subView = class("Main_take_medicine_subView", super)
local takeMedicineLoopView = require("ui/component/take_medicine/take_medicine_loop_view")
local TIME_INTERVAL = 0.05
local inputKeyDescComp = require("input.input_key_desc_comp")

function Main_take_medicine_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_take_medicine_sub", "main/takemedicine/main_take_medicine", UI.ECacheLv.None)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.takeMedicineBagData_ = Z.DataMgr.Get("take_medicine_bag_data")
  self.deadVm_ = Z.VMMgr.GetVM("dead")
  self.parentView_ = parent
  
  function self.moveLeft_()
    if self.deadVm_.CheckPlayerIsDead() then
      return
    end
    if self.isInQuickUseItem_ then
      return
    end
    self.loopView_:MoveLast()
  end
  
  function self.moveRight_()
    if self.deadVm_.CheckPlayerIsDead() then
      return
    end
    if self.isInQuickUseItem_ then
      return
    end
    self.loopView_:MoveNext()
  end
  
  function self.quickUse_()
    if self.deadVm_.CheckPlayerIsDead() then
      return
    end
    if self.loopView_.IsInAnim then
      return
    end
    self:onInputQuickUse()
  end
  
  self.leftIputKeyDescComp_ = inputKeyDescComp.new()
  self.rightIputKeyDescComp_ = inputKeyDescComp.new()
  self.useIputKeyDescComp_ = inputKeyDescComp.new()
end

function Main_take_medicine_subView:OnActive()
  self:AddAsyncClick(self.uiBinder.btn_arrow_left, function()
    self.moveLeft_()
  end)
  self:AddAsyncClick(self.uiBinder.btn_arrow_right, function()
    self.moveRight_()
  end)
  self.leftIputKeyDescComp_:Init(17, self.uiBinder.key_left)
  self.rightIputKeyDescComp_:Init(122, self.uiBinder.key_right)
  self.useIputKeyDescComp_:Init(121, self.uiBinder.key_use)
  self.allItemInfos_ = self.takeMedicineBagData_:GetMedicineList()
  self.selectDataIndex_ = 1
  self.selectDataConfigId_ = nil
  self.isInQuickUseItem_ = false
  if Z.ContainerMgr.CharSerialize.itemPackage.quickBar then
    local isExist = false
    for index, configId in ipairs(self.allItemInfos_) do
      if configId == Z.ContainerMgr.CharSerialize.itemPackage.quickBar then
        self.selectDataIndex_ = index
        self.selectDataConfigId_ = Z.ContainerMgr.CharSerialize.itemPackage.quickBar
        isExist = true
        break
      end
    end
    if not isExist and self.allItemInfos_[self.selectDataIndex_] then
      self.selectDataConfigId_ = self.allItemInfos_[self.selectDataIndex_]
      Z.CoroUtil.create_coro_xpcall(function()
        self.itemsVm_.AsyncSetQuickBar(self.allItemInfos_[self.selectDataIndex_], self.cancelSource:CreateToken())
      end)()
    end
  elseif self.allItemInfos_[self.selectDataIndex_] then
    self.selectDataConfigId_ = self.allItemInfos_[self.selectDataIndex_]
  end
  self:refreshItemName()
  self.loopView_ = takeMedicineLoopView.new(self, self.uiBinder.take_medicine)
  self.loopView_:Init()
  self.loopView_:RefreshData(self.allItemInfos_, self.selectDataIndex_)
  self.loopView_:AddMoveCallBack(function(configId, index)
    self.selectDataIndex_ = index
    self.selectDataConfigId_ = self.allItemInfos_[self.selectDataIndex_]
    self:refreshItemName()
    Z.CoroUtil.create_coro_xpcall(function()
      self.itemsVm_.AsyncSetQuickBar(self.allItemInfos_[self.selectDataIndex_], self.cancelSource:CreateToken())
    end)()
  end)
  self.loopViewItems_ = self.loopView_:GetAllItems()
  Z.EventMgr:Add(Z.ConstValue.Backpack.TakeMedicineBagChangeRefreshMain, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.TakeMedicineAddItemPc, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.TakeMedicineDelItemPc, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.TakeMedicineChangeItemPc, self.onItemChange, self)
  
  function self.onPackageChangedFunc_(container, dirty)
    self:onPackageChanged(container, dirty)
  end
  
  function self.onGropCdChangedFunc_(container, dirty)
    self:onGropCdChanged(container, dirty)
  end
  
  for _, package in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages) do
    package.Watcher:RegWatcher(self.onPackageChangedFunc_)
  end
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:RegWatcher(self.onGropCdChangedFunc_)
  self.cdTimer_ = self.timerMgr:StartTimer(function()
    self:refreshCd()
  end, TIME_INTERVAL, -1)
end

function Main_take_medicine_subView:OnDeActive()
  self.leftIputKeyDescComp_:UnInit()
  self.rightIputKeyDescComp_:UnInit()
  self.useIputKeyDescComp_:UnInit()
  self.timerMgr:StopTimer(self.cdTimer_)
  Z.EventMgr:RemoveObjAll(self)
  for _, package in pairs(Z.ContainerMgr.CharSerialize.itemPackage.packages) do
    package.Watcher:UnregWatcher(self.onPackageChangedFunc_)
  end
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:UnregWatcher(self.onGropCdChangedFunc_)
  self.loopView_:UnInit()
  self.loopView_ = nil
end

function Main_take_medicine_subView:OnRefresh()
end

function Main_take_medicine_subView:refreshItemName()
  if self.selectDataConfigId_ then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.selectDataConfigId_)
    if itemRow then
      self.uiBinder.lab_name.text = itemRow.Name
    end
  else
    self.uiBinder.lab_name.text = ""
  end
end

function Main_take_medicine_subView:onItemChange()
  self.allItemInfos_ = self.takeMedicineBagData_:GetMedicineList()
  local isExist = false
  if self.selectDataConfigId_ then
    for index, configId in ipairs(self.allItemInfos_) do
      if configId == self.selectDataConfigId_ then
        self.selectDataIndex_ = index
        isExist = true
        break
      end
    end
  end
  if not isExist then
    self.selectDataIndex_ = 1
    if self.allItemInfos_[self.selectDataIndex_] then
      self.selectDataConfigId_ = self.allItemInfos_[self.selectDataIndex_]
      self:refreshItemName()
      Z.CoroUtil.create_coro_xpcall(function()
        self.itemsVm_.AsyncSetQuickBar(self.allItemInfos_[self.selectDataIndex_], self.cancelSource:CreateToken())
      end)()
    else
      self.selectDataConfigId_ = nil
      self:refreshItemName()
    end
  end
  self.loopView_:RefreshData(self.allItemInfos_, self.selectDataIndex_)
end

function Main_take_medicine_subView:refreshCd()
  for _, item in ipairs(self.loopViewItems_) do
    item:RefreshCd(TIME_INTERVAL)
  end
end

function Main_take_medicine_subView:refreshItemUI()
  for _, item in ipairs(self.loopViewItems_) do
    item:RefreshUI()
  end
end

function Main_take_medicine_subView:QuickUseItem(configId)
  Z.CoroUtil.create_coro_xpcall(function()
    if configId == nil then
      Z.TipsVM.ShowTipsLang(1000751)
      return
    end
    local ownNum = self.itemsVm_.GetItemTotalCount(configId)
    if ownNum <= 0 then
      return
    end
    local cdTime = 0
    local package = self.itemsVm_.GetPackageInfobyItemId(configId)
    if package and next(package) then
      local cdTime, useCd = self.itemsVm_.GetItemCd(package, configId)
      if cdTime and useCd then
        local serverTime = Z.ServerTime:GetServerTime()
        local diffTime = (cdTime - serverTime) / 1000
        if 0 < diffTime then
          cdTime = diffTime
        end
      end
    end
    if 0 < cdTime then
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
      if itemRow then
        local param = {
          item = {
            name = itemRow.Name
          }
        }
        Z.TipsVM.ShowTipsLang(100103, param)
      end
    else
      self.isInQuickUseItem_ = true
      local ret = self:asyncQuickUseItem(configId)
      if ret then
        self:refreshItemUI()
      end
      self.isInQuickUseItem_ = false
    end
  end)()
end

function Main_take_medicine_subView:onInputQuickUse()
  self:QuickUseItem(self.selectDataConfigId_)
end

function Main_take_medicine_subView:asyncQuickUseItem(configId)
  local ret = self.itemsVm_.AsyncUseItemByConfigId(configId, self.cancelSource:CreateToken())
  if ret == 0 then
    return true
  else
    return false
  end
end

function Main_take_medicine_subView:onPackageChanged(container, dirtyKeys)
  if dirtyKeys.itemCd and dirtyKeys.itemCd[self.selectDataConfigId_] then
    local timeStamp = dirtyKeys.itemCd[self.selectDataConfigId_]:Get()
    if timeStamp then
      self:refreshItemUI()
    end
  end
end

function Main_take_medicine_subView:onGropCdChanged(container, dirtyKeys)
  if dirtyKeys.useGroupCd then
    self:refreshItemUI()
  end
end

function Main_take_medicine_subView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.QuickUse1 then
    self.quickUse_()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.TakeMedicineLeft then
    self.moveLeft_()
  end
  if inputActionEventData.ActionId == Z.InputActionIds.TakeMedicineRight then
    self.moveRight_()
  end
end

return Main_take_medicine_subView
