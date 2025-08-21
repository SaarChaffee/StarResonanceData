local BagMedicineLoopItem = class("BagMedicineLoopItem")
local item = require("common.item_binder")

function BagMedicineLoopItem:ctor(uiBinder_, parent)
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.uiBinder_ = uiBinder_
  self.parent_ = parent
  self.data_ = nil
  self.index_ = -1
  self.itemClass_ = item.new(self.parent_)
end

function BagMedicineLoopItem:Init()
  self.itemClass_:Init({
    uiBinder = self.uiBinder_
  })
  self.uiBinder_.btn_temp:AddListener(function()
    self.parent_:SetSelect(self.index_)
    self:SetSelect(true)
  end)
  self:initDragEvent()
  self.itemClass_:SetSelected(false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.event_triggle_temp, false)
end

function BagMedicineLoopItem:Refresh(data, index)
  self.data_ = data
  self.index_ = index
  if data == nil then
    self.itemClass_:HideUi()
    self:RefreshLock(false)
    if Z.IsPCUI then
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_lattice, true)
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_info, false)
    end
    self.package_ = nil
  else
    local itemData = {
      configId = data.configId,
      lab = self.itemsData_:GetItemTotalCount(data.configId)
    }
    self.itemClass_:RefreshByData(itemData)
    self:RefreshLock(data.isLock)
    if Z.IsPCUI then
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.node_info, true)
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_lattice, false)
    end
    self.package_ = self.itemVm_.GetPackageInfobyItemId(self.data_.configId)
  end
end

function BagMedicineLoopItem:UnInit()
  self:unInitDragEvent()
  self.itemClass_:UnInit()
end

function BagMedicineLoopItem:SetSelect(isSelect)
  self.itemClass_:SetSelected(isSelect)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.event_triggle_temp, isSelect)
end

function BagMedicineLoopItem:RefreshLock(isLock)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_lock, isLock)
end

function BagMedicineLoopItem:RefreshCdTime()
  if self.data_ == nil then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_cd, false)
    return
  end
  local cdTime, useCd = self.itemVm_.GetItemCd(self.package_, self.data_.configId)
  if cdTime == nil or useCd == nil then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_cd, false)
    return
  end
  self.itemClass_:RefreshItemCdUi(cdTime, useCd)
end

function BagMedicineLoopItem:initDragEvent()
  self.uiBinder_.event_triggle_temp.onBeginDrag:AddListener(function(go, pointerData)
    if self.data_ == nil then
      return
    end
    self.parent_:OnBeginDragItem(self.data_.configId, pointerData)
  end)
  self.uiBinder_.event_triggle_temp.onDrag:AddListener(function(go, pointerData)
    self.parent_:OnDragItem(pointerData)
  end)
  self.uiBinder_.event_triggle_temp.onEndDrag:AddListener(function()
    self.parent_:OnEndDragItem()
  end)
end

function BagMedicineLoopItem:unInitDragEvent()
  self.uiBinder_.event_triggle_temp.onBeginDrag:RemoveAllListeners()
  self.uiBinder_.event_triggle_temp.onDrag:RemoveAllListeners()
  self.uiBinder_.event_triggle_temp.onEndDrag:RemoveAllListeners()
end

return BagMedicineLoopItem
