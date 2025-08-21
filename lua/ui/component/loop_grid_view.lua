local LoopGridView = class("LoopGridView")

function LoopGridView:ctor(view, loopGridView, loopGridItem, prefabName, isHavePCItem)
  self.IsInit = false
  self.UIView = view
  self.LoopGridView = loopGridView
  self.loopGridItem_ = loopGridItem
  if Z.IsPCUI and isHavePCItem then
    self.prefabName_ = string.zconcat(prefabName, "_pc")
  else
    self.prefabName_ = prefabName
  end
  
  function self.getItemClassFunc(data)
    return self.loopGridItem_
  end
  
  function self.getPrefabNameFunc(data)
    return self.prefabName_
  end
end

function LoopGridView:Init(dataList)
  if self.IsInit then
    return
  end
  self.itemDict_ = {}
  self.DataList = dataList
  self.LoopGridView:InitGridView(#self.DataList, function(gridView, index, row, column)
    return self:onGetItemByRowColumn(gridView, index, row, column)
  end)
  self.IsInit = true
end

function LoopGridView:UnInit()
  if not self.IsInit then
    return
  end
  for _, item in pairs(self.itemDict_) do
    item:UnInit()
  end
  self.itemDict_ = nil
  self.DataList = nil
  self.UIView = nil
  self.loopGridItem_ = nil
  self.prefabName_ = nil
  self.getItemClassFunc = nil
  self.getPrefabNameFunc = nil
  self.LoopGridView:UnInitGridView()
  self.LoopGridView = nil
  self.IsInit = false
end

function LoopGridView:RefreshListView(dataList, resetPos)
  self.DataList = dataList
  self.LoopGridView:SetListItemCount(#self.DataList, resetPos)
  self.LoopGridView:RefreshAllShownItem()
end

function LoopGridView:ClearAllSelect(ignoreCallback)
  self.LoopGridView:ClearAllSelect(ignoreCallback)
end

function LoopGridView:RefreshAllShownItem()
  self.LoopGridView:RefreshAllShownItem()
end

function LoopGridView:MovePanelToItemIndex(itemIndex, offsetX, offsetY)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  self.LoopGridView:MovePanelToItemByIndex(itemIndex - 1, offsetX, offsetY)
end

function LoopGridView:SetGetItemClassFunc(func)
  self.getItemClassFunc = func
end

function LoopGridView:SetGetPrefabNameFunc(func)
  self.getPrefabNameFunc = func
end

function LoopGridView:onGetItemByRowColumn(gridView, index, row, column)
  if index < 0 then
    return nil
  end
  local curData = self.DataList[index + 1]
  if curData == nil then
    return nil
  end
  local prefabName = self.getPrefabNameFunc(curData)
  local item = gridView:NewListViewItem(prefabName)
  if item == nil then
    return nil
  end
  item.ItemIndex = index
  if self.itemDict_[item] == nil then
    local itemClass = self.getItemClassFunc(curData)
    self.itemDict_[item] = itemClass.new()
    self.itemDict_[item]:Init(self, item)
  end
  self.itemDict_[item].Index = index + 1
  self.itemDict_[item].IsSelected = item.IsSelected
  self.itemDict_[item]:Refresh(curData)
  return item
end

function LoopGridView:SetItemSize(size)
  self.LoopGridView:SetItemSize(size)
end

function LoopGridView:SetSelected(index)
  self.LoopGridView:OnPointerClickItem(index - 1)
end

function LoopGridView:SelectIndex(itemIndex)
  self.LoopGridView:SelectIndex(itemIndex)
end

function LoopGridView:UnSelectIndex(index)
  self.LoopGridView:UnSelectIndex(index - 1)
end

function LoopGridView:GetSelectedIndex()
  return self.LoopGridView.SelectedIndex + 1
end

function LoopGridView:GetMultiSelectedIndexList()
  return self.LoopGridView.SelectedList
end

function LoopGridView:RefreshItemByItemIndex(index)
  self.LoopGridView:RefreshItemByItemIndex(index - 1)
end

function LoopGridView:RefreshDataByIndex(index, data)
  if self.DataList[index] then
    self.DataList[index] = data
  end
end

function LoopGridView:ResetListView(resetPos)
  self.LoopGridView:ResetListView(resetPos)
end

function LoopGridView:GetAllItem()
  return self.itemDict_
end

function LoopGridView:GetData()
  return self.DataList
end

function LoopGridView:GetDataByIndex(index)
  if self.DataList[index] then
    return self.DataList[index]
  end
end

function LoopGridView:GetIndexByData(data)
  for key, value in ipairs(self.DataList) do
    if value == data then
      return key
    end
  end
  return -1
end

function LoopGridView:SetIsCenter(isCenter)
  self.LoopGridView.IsCenter = isCenter
end

function LoopGridView:SetSnapFinishCallback(callback)
  self.LoopGridView.mOnSnapItemFinished = callback
end

function LoopGridView:SetBeginDragAction(callback)
  self.LoopGridView.mOnBeginDragAction = callback
end

function LoopGridView:SetEndDragAction(callback)
  self.LoopGridView.mOnEndDragAction = callback
end

function LoopGridView:SetCanMultiSelected(isCanMultiSelected)
  if isCanMultiSelected == nil then
    isCanMultiSelected = false
  end
  self.LoopGridView.CanMultiSelected = isCanMultiSelected
end

function LoopGridView:SetGridFixedGroupCount(type, count)
  self.LoopGridView:SetGridFixedGroupCount(type, count)
end

function LoopGridView:SetItemPadding(size)
  self.LoopGridView:SetItemPadding(size)
end

function LoopGridView:GetFixedRowOrColumnCount()
  return self.LoopGridView.FixedRowOrColumnCount
end

return LoopGridView
