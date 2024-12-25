local LoopScrollRect = class("LoopScrollRect")

function LoopScrollRect:ctor(loopScrollRect, uiView, loopScrollRectItem, itemBindName)
  self.loopScrollRect = loopScrollRect
  self.loopScrollRectItem = loopScrollRectItem
  self.itemBindName = itemBindName
  self.uiView = uiView
  self.panel = uiView.panel
  self:Init()
end

function LoopScrollRect:Init()
  self.activeItems = {}
  self.deActiveItems = {}
  self:BindEvents()
end

function LoopScrollRect:UnInit()
  if #self.activeItems > 0 then
    for k, v in pairs(self.activeItems) do
      v:UnInit()
    end
  end
  self.Data = nil
  self.activeItems = nil
  self.deActiveItems = nil
end

function LoopScrollRect:BindEvents()
  Z.UIUtil.UnityEventAddCoroFunc(self.loopScrollRect.OnUnInitEvent, function()
    self:UnInit()
  end, function(err)
    logError("failed with err code:{0}", err)
  end, function()
    logGreen("canceled")
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.loopScrollRect.OnAddItemChangedEvent, function(item)
    self:CreateItem(item)
  end, function(err)
    logError("failed with err code:{0}", err)
  end, function()
    logGreen("canceled")
  end)
  Z.UIUtil.UnityEventAddCoroFunc(self.loopScrollRect.OnRemoveItemChangedEvent, function(item)
    self:RemoveItem(item)
  end, function(err)
    logError("failed with err code:{0}", err)
  end, function()
    logGreen("canceled")
  end)
end

function LoopScrollRect:SetData(data, playAnim, filledView, displayOffset)
  self.Data = data
  if data == nil then
    self.count = 0
    self.loopScrollRect:UpdateCount(0, 0, playAnim, filledView)
  else
    self.count = table.zcount(data)
    if not displayOffset or displayOffset < 0 or displayOffset > self.count then
      displayOffset = 0
    end
    self.loopScrollRect:UpdateCount(self.count, displayOffset, playAnim, filledView)
  end
end

function LoopScrollRect:SetDataFromEnd(data, displayOffset)
  self.Data = data
  if data == nil then
    self.count = 0
    self.loopScrollRect:UpdateCountFromEnd(0, 0)
  else
    self.count = table.zcount(data)
    if not displayOffset or displayOffset < 0 then
      displayOffset = 0
    end
    self.loopScrollRect:UpdateCountFromEnd(self.count, displayOffset)
  end
end

function LoopScrollRect:RefreshData(data)
  self.Data = data
  self.count = data and table.zcount(data) or 0
  self.loopScrollRect.TotalCount = self.count
  self.loopScrollRect:RefreshCells()
end

function LoopScrollRect:GetData()
  return self.Data
end

function LoopScrollRect:AsyncSetData(data, playAnim, filledView, displayOffset, cancelToken)
  self.Data = data
  local asyncCall = Z.CoroUtil.async_to_sync(self.loopScrollRect.AsyncUpdateCount)
  if data == nil then
    self.count = 0
    asyncCall(self.loopScrollRect, 0, 0, playAnim, filledView, cancelToken)
  else
    self.count = table.zcount(data)
    if not displayOffset or displayOffset < 0 or displayOffset > self.count then
      displayOffset = 0
    end
    asyncCall(self.loopScrollRect, self.count, displayOffset, playAnim, filledView, cancelToken)
  end
end

function LoopScrollRect:SetCount(count, playAnim, filledView)
  self.Data = nil
  self.count = count
  self.loopScrollRect:UpdateCount(count, 0, playAnim, filledView)
end

function LoopScrollRect:GetDataByIndex(index)
  if self.Data == nil or index < 1 or index > #self.Data then
    return nil
  end
  return self.Data[index]
end

function LoopScrollRect:GetCount()
  return self.count
end

function LoopScrollRect:SetSelected(index, isNotUnSelect)
  self.loopScrollRect:OnPointerClickItem(index, isNotUnSelect)
end

function LoopScrollRect:SetUnSelected(index)
  self.loopScrollRect:UnSelectIndex(index)
end

function LoopScrollRect:ClearSelected()
  self.loopScrollRect:ClearAllSelect()
end

function LoopScrollRect:GetSelected()
  return self.loopScrollRect.SelectedIndex
end

function LoopScrollRect:GetIndexByData(data)
  for key, value in pairs(self.Data) do
    if value == data then
      return key
    end
  end
  return -1
end

function LoopScrollRect:RefreshDataByIndex(index, data)
  for k, v in pairs(self.activeItems) do
    if k.Index == index and self.Data[index + 1] ~= nil then
      self.Data[index + 1] = data
      k.Index = index
    end
  end
end

function LoopScrollRect:UpDateByIndex(index, data)
  for k, v in pairs(self.activeItems) do
    if k.Index == index then
      v:UpdateData(data)
    end
  end
end

function LoopScrollRect:GetMultiSelecteds()
  return self.loopScrollRect.MultiSelected
end

function LoopScrollRect:ClearCells()
  return self.loopScrollRect:ClearCells()
end

function LoopScrollRect:SetCanMultiSelected(isCanMultiSelected)
  if isCanMultiSelected == nil then
    isCanMultiSelected = false
  end
  self.loopScrollRect.CanMultiSelected = isCanMultiSelected
end

function LoopScrollRect:CreateItem(loopScrollRectItem)
  if loopScrollRectItem == nil then
    logGreen("loopScrollRectItem is nil")
    return
  end
  local item
  if #self.deActiveItems > 0 then
    item = self.deActiveItems[#self.deActiveItems]
    table.remove(self.deActiveItems)
  else
    item = self.loopScrollRectItem.new()
  end
  self.activeItems[loopScrollRectItem] = item
  item:Init(self, loopScrollRectItem, self.itemBindName)
end

function LoopScrollRect:RefreshAllItem()
  for key, item in pairs(self.activeItems) do
    item:Refresh()
  end
end

function LoopScrollRect:RefreshAllItemState()
  for _, item in pairs(self.activeItems) do
    item:RefreshState()
  end
end

function LoopScrollRect:GetActiveItems()
  return self.activeItems
end

function LoopScrollRect:RemoveItem(loopScrollRectItem)
  for k, v in pairs(self.activeItems) do
    if k == loopScrollRectItem then
      v:UnInit()
      table.insert(self.deActiveItems, v)
      self.activeItems[k] = nil
      break
    end
  end
end

function LoopScrollRect:GetContainerGroupAnimComp()
  return self.loopScrollRect:GetContainerGroupAnimComp()
end

function LoopScrollRect:SetHorizontalNormalizedPosition(value)
  self.loopScrollRect:SetHorizontalNormalizedPosition(value)
end

function LoopScrollRect:SetVerticalNormalizedPosition(value)
  return self.loopScrollRect:SetVerticalNormalizedPosition(value)
end

function LoopScrollRect:GetHorizontalNormalizedPosition()
  return self.loopScrollRect.HorizontalNormalizedPosition
end

function LoopScrollRect:GetVerticalNormalizedPosition()
  return self.loopScrollRect.VerticalNormalizedPosition
end

function LoopScrollRect:OnScroll(data)
end

return LoopScrollRect
