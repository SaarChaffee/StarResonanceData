local UI = Z.UI
local super = require("ui.ui_subview_base")
local Bag_take_medicine_subView = class("Bag_take_medicine_subView", super)
local bagMedicineLoopItem = require("ui.component.bag.bag_medicine_loop_item")
local item = require("common.item_binder")

function Bag_take_medicine_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "bag_take_medicine_sub", "bag/bag_take_medicine_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "bag_take_medicine_sub", "bag/bag_take_medicine_sub", UI.ECacheLv.None)
  end
  self.parent_ = parent
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.takeMedicineData_ = Z.DataMgr.Get("take_medicine_bag_data")
  self.itemBinder_ = item.new(self)
  
  function self.itemSortFunc_(aConfigId, bConfigId)
    local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
    local aConfig = itemsTableMgr.GetRow(aConfigId)
    local bConfig = itemsTableMgr.GetRow(bConfigId)
    if aConfig == nil then
      return false
    end
    if bConfig == nil then
      return false
    end
    if aConfig.SortID < bConfig.SortID then
      return true
    elseif aConfig.SortID > bConfig.SortID then
      return false
    end
    if aConfig.Quality > bConfig.Quality then
      return true
    elseif aConfig.Quality < bConfig.Quality then
      return false
    end
    local itemsData = Z.DataMgr.Get("items_data")
    local aCount = itemsData:GetItemTotalCount(aConfigId)
    local bCount = itemsData:GetItemTotalCount(bConfigId)
    if aCount > bCount then
      return true
    elseif aCount < bCount then
      return false
    end
    return aConfigId < bConfigId
  end
end

function Bag_take_medicine_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_close, function()
    if self:CheckSecondDialog() then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("SecondCheck"), function()
        self:DeActive()
      end)
    else
      self:DeActive()
    end
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").CheckAndShowView(100000)
  end)
  self:AddClick(self.uiBinder.btn_refresh, function()
    self:sortMedicineBag()
    self:onBagRefresh()
  end)
  self:AddClick(self.uiBinder.btn_certain, function()
    self.takeMedicineData_:SynchronizeMedicineBag(self.allBagData_)
    self.takeMedicineData_:SaveCharacterMedicineBagInfo()
    Z.TipsVM.ShowTipsLang(1000752)
  end)
  self:AddClick(self.uiBinder.btn_lock, function()
    if self.selectIndex_ then
      local bagData = self.allBagData_[self.selectIndex_]
      local isLock = false
      if bagData ~= nil then
        isLock = not bagData.isLock
        self.allBagData_[self.selectIndex_].isLock = isLock
      end
      self.items_[self.selectIndex_].itemBinder:RefreshLock(isLock)
      if isLock then
        self.uiBinder.lab_lock.text = Lang("UnLock")
      else
        self.uiBinder.lab_lock.text = Lang("LockMedicine")
      end
    end
  end)
  self.uiBinder.tog_use:AddListener(function()
    self.takeMedicineData_.AutoSynchronizeData = not self.takeMedicineData_.AutoSynchronizeData
    self.takeMedicineData_:SaveCharacterMedicineBagInfo()
  end)
  self.uiBinder.tog_use:SetIsOnWithoutCallBack(self.takeMedicineData_.AutoSynchronizeData)
  self.items_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    self.allBagData_ = table.zdeepCopy(self.takeMedicineData_:GetAllMedicineBag())
    local itemPath = self.uiBinder.uiprefab_cache:GetString("item")
    for i = 1, self.takeMedicineData_.MaxBagCapacity do
      local itemName = "item" .. i
      local unit = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.node_content)
      if unit then
        local itemBinder = bagMedicineLoopItem.new(unit, self)
        itemBinder:Init()
        itemBinder:Refresh(self.allBagData_[i], i)
        self.items_[i] = {
          name = itemName,
          unit = unit,
          itemBinder = itemBinder
        }
      end
    end
    self.cdTimer_ = self.timerMgr:StartFrameTimer(function()
      self:refreshAllItemsCd()
    end, 1, -1)
  end)()
  self.itemBinder_:Init({
    uiBinder = self.uiBinder.item_drag
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_node, false)
  self.isDragConfigId_ = nil
  self.selectIndex_ = nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_lock, false)
end

function Bag_take_medicine_subView:OnDeActive()
  self.timerMgr:StopTimer(self.cdTimer_)
  for _, value in ipairs(self.items_) do
    value.itemBinder:UnInit()
    self:RemoveUiUnit(value.name)
  end
  self.items_ = {}
  self.uiBinder.tog_use:RemoveAllListeners()
  self.isDragConfigId_ = nil
  self.selectIndex_ = nil
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.TakeMedicineBagChangeRefreshMain)
  if self.viewData then
    self.viewData()
  end
end

function Bag_take_medicine_subView:OnRefresh()
end

function Bag_take_medicine_subView:CheckSecondDialog()
  if self.IsActive then
    local needDialog = false
    local saveBagMedicine = self.takeMedicineData_:GetAllMedicineBag()
    for i = 1, self.takeMedicineData_.MaxBagCapacity do
      if self.allBagData_[i] == nil and saveBagMedicine[i] ~= nil then
        needDialog = true
        break
      elseif self.allBagData_[i] ~= nil and saveBagMedicine[i] == nil then
        needDialog = true
        break
      elseif self.allBagData_[i] ~= nil and saveBagMedicine[i] ~= nil and self.allBagData_[i].configId ~= saveBagMedicine[i].configId then
        needDialog = true
        break
      end
    end
    return needDialog
  else
    return false
  end
end

function Bag_take_medicine_subView:onBagRefresh()
  for i = 1, self.takeMedicineData_.MaxBagCapacity do
    self.items_[i].itemBinder:Refresh(self.allBagData_[i], i)
  end
end

function Bag_take_medicine_subView:SetSelect(index)
  if self.selectIndex_ then
    self.items_[self.selectIndex_].itemBinder:SetSelect(false)
  end
  self.selectIndex_ = index
  local tempData = self.allBagData_[self.selectIndex_]
  if tempData == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_lock, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_lock, true)
    if tempData.isLock and tempData.isLock == true then
      self.uiBinder.lab_lock.text = Lang("UnLock")
    else
      self.uiBinder.lab_lock.text = Lang("LockMedicine")
    end
  end
end

function Bag_take_medicine_subView:OnBeginDragItem(configId, pointerData)
  self.parent_:SetMask(true)
  self.isDragConfigId_ = configId
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_node, true)
  self.itemBinder_:RefreshByData({
    configId = configId,
    lab = self.itemsData_:GetItemTotalCount(configId)
  })
  self:calDragItemPos(pointerData)
end

function Bag_take_medicine_subView:OnDragItem(pointerData)
  if self.isDragConfigId_ == nil then
    return
  end
  self:calDragItemPos(pointerData)
end

function Bag_take_medicine_subView:OnEndDragItem()
  self.parent_:SetMask(false)
  if self.isDragConfigId_ == nil then
    return
  end
  local dragDistance = self.takeMedicineData_.DragDistance
  local endIndex = -1
  local position = self.uiBinder.item_drag.Trans.position
  for index, value in ipairs(self.items_) do
    local trans = value.unit.Trans
    if trans then
      local distance = Panda.LuaAsyncBridge.GetScreenDistance(trans.position, position)
      if dragDistance > distance then
        endIndex = index
        break
      end
    end
  end
  self:exchangeItemIndex(self.isDragConfigId_, endIndex)
  self.isDragConfigId_ = nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_node, false)
  self:SetSelect(nil)
end

function Bag_take_medicine_subView:calDragItemPos(pointerData)
  local trans_ = self.uiBinder.item_drag.Trans
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(trans_, pointerData.position, nil)
  local posX, posY = trans_:GetAnchorPosition(nil, nil)
  posX = posX + uiPos.x
  posY = posY + uiPos.y
  trans_:SetAnchorPosition(posX, posY)
end

function Bag_take_medicine_subView:refreshAllItemsCd()
  for i = 1, self.takeMedicineData_.MaxBagCapacity do
    self.items_[i].itemBinder:RefreshCdTime()
  end
end

function Bag_take_medicine_subView:exchangeItemIndex(configId, endIndex)
  local existIndex = -1
  for k, v in pairs(self.allBagData_) do
    if v.configId == configId then
      existIndex = k
      break
    end
  end
  if existIndex == -1 then
    if endIndex ~= -1 then
      self.allBagData_[endIndex] = {configId = configId, isLock = false}
    end
  elseif endIndex ~= -1 then
    local tempData = self.allBagData_[endIndex]
    self.allBagData_[endIndex] = self.allBagData_[existIndex]
    self.allBagData_[existIndex] = tempData
  else
    self.allBagData_[existIndex] = nil
  end
  self:onBagRefresh()
end

function Bag_take_medicine_subView:sortMedicineBag()
  local tempItemConfigs = {}
  local tempItemConfigCount = 0
  for i = 1, self.takeMedicineData_.MaxBagCapacity do
    if self.allBagData_[i] ~= nil and self.allBagData_[i].isLock == false then
      tempItemConfigCount = tempItemConfigCount + 1
      tempItemConfigs[tempItemConfigCount] = self.allBagData_[i].configId
      self.allBagData_[i] = nil
    end
  end
  table.sort(tempItemConfigs, self.itemSortFunc_)
  local sortItemIndex = 0
  for i = 1, self.takeMedicineData_.MaxBagCapacity do
    if self.allBagData_[i] == nil then
      sortItemIndex = sortItemIndex + 1
      if tempItemConfigCount < sortItemIndex then
        break
      end
      self.allBagData_[i] = {
        configId = tempItemConfigs[sortItemIndex],
        isLock = false
      }
    end
  end
end

return Bag_take_medicine_subView
