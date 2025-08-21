local LoopListView = class("LoopListView")

function LoopListView:ctor(view, loopListView, loopListItem, prefabName, isHavePCItem)
  self.IsInit = false
  self.UIView = view
  self.LoopListView = loopListView
  self.loopListItem_ = loopListItem
  if Z.IsPCUI and isHavePCItem then
    self.prefabName_ = string.zconcat(prefabName, "_pc")
  else
    self.prefabName_ = prefabName
  end
  
  function self.getItemClassFunc(data)
    return self.loopListItem_
  end
  
  function self.getPrefabNameFunc(data)
    return self.prefabName_
  end
end

function LoopListView:Init(dataList)
  if self.IsInit then
    return
  end
  self.itemDict_ = {}
  self.DataList = dataList
  self.LoopListView:InitListView(#self.DataList, function(listView, index)
    return self:onGetItemByIndex(listView, index)
  end)
  self.IsInit = true
end

function LoopListView:UnInit()
  if not self.IsInit then
    return
  end
  for _, item in pairs(self.itemDict_) do
    item:UnInit()
  end
  self.itemDict_ = nil
  self.DataList = nil
  self.UIView = nil
  self.loopListItem_ = nil
  self.prefabName_ = nil
  self.getItemClassFunc = nil
  self.getPrefabNameFunc = nil
  self.LoopListView:UnInitListView()
  self.LoopListView = nil
  self.IsInit = false
end

function LoopListView:RefreshListView(dataList, resetPos)
  self.DataList = dataList
  self.LoopListView:SetListItemCount(#self.DataList, resetPos)
  self.LoopListView:RefreshAllShownItem()
end

function LoopListView:ClearAllSelect(ignoreCallback)
  self.LoopListView:ClearAllSelect(ignoreCallback)
end

function LoopListView:RefreshAllShownItem()
  self.LoopListView:RefreshAllShownItem()
end

function LoopListView:MovePanelToItemIndex(itemIndex, offset)
  offset = offset or 0
  self.LoopListView:MovePanelToItemIndex(itemIndex - 1, offset)
end

function LoopListView:SetGetItemClassFunc(func)
  self.getItemClassFunc = func
end

function LoopListView:SetGetPrefabNameFunc(func)
  self.getPrefabNameFunc = func
end

function LoopListView:onGetItemByIndex(listView, index)
  if index < 0 then
    return nil
  end
  local curData = self.DataList[index + 1]
  if curData == nil then
    return nil
  end
  local prefabName = self.getPrefabNameFunc(curData)
  local item = listView:NewListViewItem(prefabName)
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

function LoopListView:SetItemSize(size)
  self.LoopListView:SetItemSize(size)
end

function LoopListView:SetSelected(index)
  self.LoopListView:OnPointerClickItem(index - 1)
end

function LoopListView:SelectIndex(itemIndex)
  self.LoopListView:SelectIndex(itemIndex)
end

function LoopListView:UnSelectIndex(index)
  self.LoopListView:UnSelectIndex(index - 1)
end

function LoopListView:GetSelectedIndex()
  return self.LoopListView.SelectedIndex + 1
end

function LoopListView:GetMultiSelectedIndexList()
  return self.LoopListView.SelectedList
end

function LoopListView:RefreshItemByItemIndex(index)
  self.LoopListView:RefreshItemByItemIndex(index - 1)
end

function LoopListView:RefreshDataByIndex(index, data)
  if self.DataList[index] then
    self.DataList[index] = data
  end
end

function LoopListView:ResetListView(resetPos)
  self.LoopListView:ResetListView(resetPos)
end

function LoopListView:GetAllItem()
  return self.itemDict_
end

function LoopListView:GetData()
  return self.DataList
end

function LoopListView:GetDataByIndex(index)
  if self.DataList[index] then
    return self.DataList[index]
  end
end

function LoopListView:GetIndexByData(data)
  for key, value in ipairs(self.DataList) do
    if value == data then
      return key
    end
  end
  return -1
end

function LoopListView:SetIsCenter(isCenter)
  self.LoopListView.IsCenter = isCenter
end

function LoopListView:SetSnapFinishCallback(callback)
  self.LoopListView.mOnSnapItemFinished = callback
end

function LoopListView:SetBeginDragAction(callback)
  self.LoopListView.mOnBeginDragAction = callback
end

function LoopListView:SetEndDragAction(callback)
  self.LoopListView.mOnEndDragAction = callback
end

function LoopListView:OnItemSizeChanged(index)
  self.LoopListView:OnItemSizeChanged(index - 1)
end

function LoopListView:UpDateByIndex(index, data)
  for k, v in pairs(self.itemDict_) do
    if v.Index == index then
      v:UpdateData(data)
    end
  end
end

return LoopListView
