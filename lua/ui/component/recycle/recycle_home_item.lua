local super = require("ui.component.loop_grid_view_item")
local RecycleLoopHomeItem = class("RecycleLoopHomeItem", super)
local itemBinder = require("common.item_binder")

function RecycleLoopHomeItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.recycleData_ = Z.DataMgr.Get("recycle_data")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function RecycleLoopHomeItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.ConfigId,
    isClickOpenTips = false,
    isBind = true
  }
  self.itemBinder_:RefreshByData(itemData)
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, isSelected)
  self:RefreshRecycleCount()
end

function RecycleLoopHomeItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

function RecycleLoopHomeItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_more_selected, isSelected)
  if isSelected then
    local columnCount = self.recycleData_:GetTempRecycleColumnCount()
    if columnCount >= Z.Global.RecycleItemMax then
      Z.TipsVM.ShowTips(800001)
      self.parent:UnSelectIndex(self.Index)
      return
    end
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    self:RefreshRecycleCount()
    if isClick then
      self.parent.UIView:OnTotalItemClick(self.Index, self.uiBinder.rimg_icon.transform, curData)
      Z.AudioMgr:Play("sys_general_frame")
    end
  else
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    self.parent.UIView:OnTotalItemClear(curData)
    self:RefreshRecycleCount()
    self:CheckCloseTips()
  end
end

function RecycleLoopHomeItem:RefreshRecycleCount()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local itemInfo = curData.ownerToStackMap[Z.ContainerMgr.CharSerialize.charId]
  local haveCount = itemInfo and itemInfo.count or 0
  local selectCount = self.recycleData_:GetTempRecycleCount(curData, self.parent.UIView.curRecycleRow_.SystemId)
  if selectCount <= 0 then
    self.itemBinder_:SetLab(haveCount)
    self:SetRecycleItemSelect(false)
  else
    local countStr = string.zconcat(math.floor(selectCount), "/", haveCount)
    self.itemBinder_:SetLab(countStr)
    self:SetRecycleItemSelect(true)
  end
end

function RecycleLoopHomeItem:SetRecycleItemSelect(isSelect)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.recycleData_:SetTempRecycleItemSelect(curData.InstanceId, isSelect)
  self.itemBinder_:SetSelected(isSelect)
end

function RecycleLoopHomeItem:CheckCloseTips()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local isSelected = self.recycleData_:GetTempRecycleItemSelect(curData.InstanceId)
  if not isSelected then
    self.parent.UIView:CloseItemTips()
  end
end

return RecycleLoopHomeItem
