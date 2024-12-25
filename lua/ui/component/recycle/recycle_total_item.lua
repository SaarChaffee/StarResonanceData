local super = require("ui.component.loop_grid_view_item")
local RecycleLoopTotalItem = class("RecycleLoopTotalItem", super)
local itemBinder = require("common.item_binder")

function RecycleLoopTotalItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.recycleData_ = Z.DataMgr.Get("recycle_data")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
  self.uiBinder.btn_minus:AddListener(function()
    local curData = self:GetCurData()
    if curData == nil then
      return
    end
    self.parent.UIView:OnTotalItemReduce(curData)
    self:RefreshRecycleCount()
    self:CheckCloseTips()
  end)
end

function RecycleLoopTotalItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    uuid = data.itemUuid,
    configId = data.configId,
    isClickOpenTips = false,
    isBind = true
  }
  self.itemBinder_:RefreshByData(itemData)
  local isSelected = self.recycleData_:GetTempRecycleItemSelect(data.itemUuid)
  self.itemBinder_:SetSelected(isSelected)
  self:RefreshRecycleCount()
end

function RecycleLoopTotalItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

function RecycleLoopTotalItem:OnPointerClick()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.parent.UIView:OnTotalItemAdd(curData)
  self:RefreshRecycleCount()
  self.parent.UIView:OnTotalItemClick(self.Index, self.uiBinder.rimg_icon.transform, curData)
  Z.AudioMgr:Play("sys_general_frame")
end

function RecycleLoopTotalItem:RefreshRecycleCount()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local itemInfo = self.itemsVM_.GetItemInfobyItemId(curData.itemUuid, curData.configId)
  local haveCount = itemInfo and itemInfo.count or 0
  local selectCount = self.recycleData_:GetTempRecycleCount(curData)
  if selectCount <= 0 then
    self.itemBinder_:SetLab(haveCount)
    self:SetRecycleItemSelect(false)
  else
    local selectCountStr = Z.RichTextHelper.ApplyStyleTag(selectCount, E.TextStyleTag.Orange)
    local countStr = string.zconcat(selectCountStr, "/", haveCount)
    self.itemBinder_:SetLab(countStr)
    self:SetRecycleItemSelect(true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, 0 < selectCount)
end

function RecycleLoopTotalItem:SetRecycleItemSelect(isSelect)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.recycleData_:SetTempRecycleItemSelect(curData.itemUuid, isSelect)
  self.itemBinder_:SetSelected(isSelect)
end

function RecycleLoopTotalItem:CheckCloseTips()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local isSelected = self.recycleData_:GetTempRecycleItemSelect(curData.itemUuid)
  if not isSelected then
    self.parent.UIView:CloseItemTips()
  end
end

return RecycleLoopTotalItem
