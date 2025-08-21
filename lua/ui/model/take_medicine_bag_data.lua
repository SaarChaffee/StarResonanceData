local super = require("ui.model.data_base")
local TakeMedicineBagData = class("TakeMedicineBagData", super)
local cjson = require("cjson")

function TakeMedicineBagData:ctor()
  self.MaxBagCapacity = 30
  if Z.IsPCUI then
    self.DragDistance = 82
  else
    self.DragDistance = 110
  end
  self.AutoSynchronizeData = true
  self.medicineBag_ = {}
  self.emptyIndex_ = -1
  self.configIdToIndexDic_ = {}
  self.timerMgr_ = Z.TimerMgr.new()
  self.timerId_ = nil
end

function TakeMedicineBagData:Init()
  self.AutoSynchronizeData = true
  self.medicineBag_ = {}
  self.emptyIndex_ = -1
  self.configIdToIndexDic_ = {}
end

function TakeMedicineBagData:UnInit()
end

function TakeMedicineBagData:Clear()
  self.AutoSynchronizeData = true
  self.medicineBag_ = {}
  self.emptyIndex_ = -1
  self.configIdToIndexDic_ = {}
  if self.timerId_ then
    self.timerMgr_:StopTimer(self.timerId_)
    self.timerId_ = nil
  end
end

function TakeMedicineBagData:InitMedicineData()
  self:InitCharacterMedicineBagInfo()
  if self.AutoSynchronizeData then
    self:AutoSynchronizeMedicineBag()
  end
end

function TakeMedicineBagData:InitCharacterMedicineBagInfo()
  self.AutoSynchronizeData = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.BagMedicineAutoSync, true)
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.BagMedicineInfo) then
    local info = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.BagMedicineInfo)
    local tempInfo = cjson.decode(info)
    local itemsVM = Z.VMMgr.GetVM("items")
    for key, value in pairs(tempInfo) do
      if type(value) == "table" and value.configId and itemsVM.GetItemTotalCount(value.configId) > 0 then
        self.medicineBag_[key] = value
      end
    end
  else
    self.medicineBag_ = {}
  end
  for i = 1, self.MaxBagCapacity + 1 do
    if self.medicineBag_[i] == nil then
      if self.emptyIndex_ == -1 then
        self.emptyIndex_ = i
      end
    else
      self.configIdToIndexDic_[self.medicineBag_[i].configId] = i
    end
  end
end

function TakeMedicineBagData:SaveCharacterMedicineBagInfo()
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.BagMedicineAutoSync, self.AutoSynchronizeData)
  local info = cjson.encode(self.medicineBag_)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.BagMedicineInfo, info)
  Z.LocalUserDataMgr.Save()
end

function TakeMedicineBagData:GetAllMedicineBag()
  return self.medicineBag_
end

function TakeMedicineBagData:GetMedicineList()
  local res = {}
  local resCount = 0
  for i = 1, self.MaxBagCapacity do
    if self.medicineBag_[i] then
      resCount = resCount + 1
      res[resCount] = self.medicineBag_[i].configId
    end
  end
  return res
end

function TakeMedicineBagData:SynchronizeMedicineBag(bagInfo)
  self.medicineBag_ = table.zdeepCopy(bagInfo)
  for i = 1, self.MaxBagCapacity + 1 do
    if self.medicineBag_[i] == nil then
      if self.emptyIndex_ == -1 then
        self.emptyIndex_ = i
      end
    else
      self.configIdToIndexDic_[self.medicineBag_[i].configId] = i
    end
  end
end

function TakeMedicineBagData:AutoSynchronizeMedicineBag()
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
  local sortFunc = itemSortFactoryVm.GetItemSortFunc(E.BackPackItemPackageType.Item, nil)
  local tempItemsInfo = itemsVm.GetItemIds(E.BackPackItemPackageType.Item, nil, sortFunc, true)
  for _, info in ipairs(tempItemsInfo) do
    local listIndex = self.configIdToIndexDic_[info.configId]
    if listIndex == nil and self.emptyIndex_ <= self.MaxBagCapacity then
      self.medicineBag_[self.emptyIndex_] = {
        configId = info.configId,
        isLock = false
      }
      self.configIdToIndexDic_[info.configId] = self.emptyIndex_
      for i = self.emptyIndex_, self.MaxBagCapacity + 1 do
        if self.medicineBag_[i] == nil then
          self.emptyIndex_ = i
          break
        end
      end
    end
  end
  self:SaveCharacterMedicineBagInfo()
end

function TakeMedicineBagData:ItemChange(item)
  if self.configIdToIndexDic_[item.configId] == nil then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.TakeMedicineChangeItemPc)
end

function TakeMedicineBagData:ItemAdd(item)
  if not self.AutoSynchronizeData then
    return
  end
  if self.emptyIndex_ > self.MaxBagCapacity then
    return
  end
  local itemConfigData = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(item.configId, true)
  if itemConfigData and itemConfigData.CanQuick == 1 then
    if self.configIdToIndexDic_[item.configId] == nil then
      self.medicineBag_[self.emptyIndex_] = {
        configId = item.configId,
        isLock = false
      }
      self.configIdToIndexDic_[item.configId] = self.emptyIndex_
      for i = self.emptyIndex_, self.MaxBagCapacity + 1 do
        if self.medicineBag_[i] == nil then
          self.emptyIndex_ = i
          break
        end
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.TakeMedicineAddItemPc)
  end
end

function TakeMedicineBagData:ItemDel(item)
  if self.configIdToIndexDic_[item.configId] == nil then
    return
  end
  local itemCount = Z.DataMgr.Get("items_data"):GetItemTotalCount(item.configId)
  if itemCount <= 0 then
    local index = self.configIdToIndexDic_[item.configId]
    self.medicineBag_[index] = nil
    self.configIdToIndexDic_[item.configId] = nil
    self.emptyIndex_ = math.min(self.emptyIndex_, index)
    if self.timerId_ == nil and self.AutoSynchronizeData then
      self.timerId_ = self.timerMgr_:StartTimer(function()
        self.timerId_ = nil
        self:AutoSynchronizeMedicineBag()
        Z.EventMgr:Dispatch(Z.ConstValue.Backpack.TakeMedicineDelItemPc)
      end, 1, 1)
    else
      self:SaveCharacterMedicineBagInfo()
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.TakeMedicineDelItemPc)
end

return TakeMedicineBagData
