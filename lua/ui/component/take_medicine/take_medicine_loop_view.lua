local TakeMedicineLoopView = class("TakeMedicineLoopView")
local MoveType = {
  None = 0,
  Next = 1,
  Last = 2
}
local takeMedicineLoopItem = require("ui/component/take_medicine/take_medicine_loop_item")

function TakeMedicineLoopView:ctor(view, loopRect)
  self.IsInit = false
  self.UIView = view
  self.takeMedicineLoopScrollRect_ = loopRect
  self.takeMedicineLoopListItem_ = takeMedicineLoopItem
  self.curSelectDataIndex_ = 0
  self.loopListItems_ = {}
  self.datas_ = {}
  self.datasCount_ = 0
  self.moveType_ = MoveType.None
  self.IsInAnim = false
  self.offset_ = 0
  self.moveCallBack_ = nil
end

function TakeMedicineLoopView:Init()
  self.takeMedicineLoopScrollRect_:Init()
  self.curSelectDataIndex_ = 0
  self.loopListItems_ = {}
  self.datas_ = {}
  self.datasCount_ = 0
  self.moveType_ = MoveType.None
  self.IsInAnim = false
  self.offset_ = 0
  self.moveCallBack_ = nil
  self.IsInAnim = false
  local gameObjects = self.takeMedicineLoopScrollRect_:GetAllItemGameObject()
  for i = 1, self.takeMedicineLoopScrollRect_.AllItemsCount do
    self.loopListItems_[i] = self.takeMedicineLoopListItem_.new(self, gameObjects[i - 1])
    self.loopListItems_[i]:Init()
    self.loopListItems_[i]:RefreshData(nil)
  end
end

function TakeMedicineLoopView:UnInit()
  for i = 1, self.takeMedicineLoopScrollRect_.AllItemsCount do
    self.loopListItems_[i]:UnInit()
  end
  self.loopListItems_ = {}
  self.takeMedicineLoopScrollRect_:UnInit()
  self.moveCallBack_ = nil
  self.IsInAnim = false
end

function TakeMedicineLoopView:RefreshData(datas, selectIndex, moveType)
  self.datas_ = datas
  self.datasCount_ = #self.datas_
  if selectIndex then
    self.curSelectDataIndex_ = selectIndex - 1
  end
  if self.curSelectDataIndex_ > self.datasCount_ - 1 then
    self.curSelectDataIndex_ = 0
  end
  self.offset_ = self.curSelectDataIndex_
  if moveType and moveType == MoveType.Next then
    self.takeMedicineLoopScrollRect_:SpecialResetAllItemPosAndScale(true)
  elseif moveType and moveType == MoveType.Last then
    self.takeMedicineLoopScrollRect_:SpecialResetAllItemPosAndScale(false)
  else
    self.takeMedicineLoopScrollRect_:ResetAllItemPosAndScale(0)
  end
  if self.datasCount_ >= self.takeMedicineLoopScrollRect_.ShowItemsCount - 1 then
    for i = 1, self.takeMedicineLoopScrollRect_.AllItemsCount do
      if i < self.takeMedicineLoopScrollRect_.AllItemsCount / 2 + 1 then
        local fixIndex = (self.curSelectDataIndex_ + i - 1) % self.datasCount_ + 1
        self.loopListItems_[i]:RefreshData(self.datas_[fixIndex])
      else
        local fixIndex = self.takeMedicineLoopScrollRect_.AllItemsCount - i
        if fixIndex < self.curSelectDataIndex_ then
          self.loopListItems_[i]:RefreshData(self.datas_[self.curSelectDataIndex_ - fixIndex])
        else
          fixIndex = self.datasCount_ - (fixIndex - self.curSelectDataIndex_)
          self.loopListItems_[i]:RefreshData(self.datas_[fixIndex])
        end
      end
    end
  else
    for i = 1, self.takeMedicineLoopScrollRect_.AllItemsCount do
      local dataIndex = self.curSelectDataIndex_ + i
      if dataIndex <= self.datasCount_ then
        self.loopListItems_[i]:RefreshData(self.datas_[dataIndex])
      else
        local fixIndex = self.takeMedicineLoopScrollRect_.AllItemsCount - i
        if fixIndex < self.curSelectDataIndex_ then
          self.loopListItems_[i]:RefreshData(self.datas_[self.curSelectDataIndex_ - fixIndex])
        else
          self.loopListItems_[i]:RefreshData(nil)
        end
      end
    end
  end
end

function TakeMedicineLoopView:AddMoveCallBack(moveCallBack)
  self.moveCallBack_ = moveCallBack
  self.takeMedicineLoopScrollRect_:AddMoveCallBack(function(index)
    self.IsInAnim = false
    if self.moveType_ == MoveType.Next then
      self.curSelectDataIndex_ = self.curSelectDataIndex_ + 1
      self.curSelectDataIndex_ = self.curSelectDataIndex_ % self.datasCount_
    elseif self.moveType_ == MoveType.Last then
      self.curSelectDataIndex_ = self.curSelectDataIndex_ - 1
      if self.curSelectDataIndex_ < 0 then
        self.curSelectDataIndex_ = self.curSelectDataIndex_ + self.datasCount_
      end
    end
    if self.moveType_ == MoveType.Next then
      if self.datasCount_ >= self.takeMedicineLoopScrollRect_.ShowItemsCount - 1 then
        local tempIndex = self.curSelectDataIndex_ + math.floor(self.takeMedicineLoopScrollRect_.AllItemsCount / 2)
        tempIndex = tempIndex % self.datasCount_
        self.loopListItems_[index + 1]:RefreshData(self.datas_[tempIndex + 1])
      else
        self.loopListItems_[index + 1]:RefreshData(nil)
      end
    elseif self.moveType_ == MoveType.Last then
      if self.datasCount_ >= self.takeMedicineLoopScrollRect_.ShowItemsCount - 1 then
        local tempIndex = self.curSelectDataIndex_ - math.floor(self.takeMedicineLoopScrollRect_.AllItemsCount / 2)
        if tempIndex < 0 then
          tempIndex = tempIndex + self.datasCount_
        end
        self.loopListItems_[index + 1]:RefreshData(self.datas_[tempIndex + 1])
      else
        self.loopListItems_[index + 1]:RefreshData(nil)
      end
    end
    if self.moveCallBack_ then
      local tempIndex = self.curSelectDataIndex_ + 1
      self.moveCallBack_(self.datas_[tempIndex], tempIndex)
    end
    self.moveType_ = MoveType.None
  end)
end

function TakeMedicineLoopView:MoveNext()
  if self.IsInAnim then
    return
  end
  if self.datasCount_ == 0 or self.datasCount_ == 1 then
    return
  end
  self.IsInAnim = true
  if self.datasCount_ < self.takeMedicineLoopScrollRect_.ShowItemsCount - 1 and self.curSelectDataIndex_ + 1 == self.datasCount_ then
    self.curSelectDataIndex_ = 0
    self:RefreshData(self.datas_, self.curSelectDataIndex_ + 1, MoveType.Next)
  else
    self.moveType_ = MoveType.Next
    self.takeMedicineLoopScrollRect_:MoveNext()
  end
end

function TakeMedicineLoopView:MoveLast()
  if self.IsInAnim then
    return
  end
  if self.datasCount_ == 0 or self.datasCount_ == 1 then
    return
  end
  self.IsInAnim = true
  if self.datasCount_ < self.takeMedicineLoopScrollRect_.ShowItemsCount - 1 and self.curSelectDataIndex_ == 0 then
    self.curSelectDataIndex_ = self.datasCount_ - 1
    self:RefreshData(self.datas_, self.curSelectDataIndex_ + 1, MoveType.Last)
  else
    self.moveType_ = MoveType.Last
    self.takeMedicineLoopScrollRect_:MoveLast()
  end
end

function TakeMedicineLoopView:GetAllItems()
  return self.loopListItems_
end

return TakeMedicineLoopView
