local LoopListViewItem = class("LoopListViewItem")

function LoopListViewItem:ctor()
end

function LoopListViewItem:Init(parent, zLoopListViewItem)
  self.parent = parent
  self.loopListView = parent.LoopListView
  self.loopListViewItem = zLoopListViewItem
  self.uiBinder = UIBinderToLua(zLoopListViewItem.gameObject)
  self.Index = 0
  self.IsSelected = false
  self.loopListViewItem.OnSelectEvent:AddListener(function(isSelected, isClick)
    self.IsSelected = isSelected
    self:OnSelected(isSelected, isClick)
  end)
  self.loopListViewItem.OnPointClickEvent:AddListener(function(go, eventData)
    self:OnPointerClick(go, eventData)
  end)
  self.loopListViewItem.OnRecycleEvent:AddListener(function(go, eventData)
    self:OnRecycle()
  end)
  self:OnInit()
end

function LoopListViewItem:UnInit()
  self:OnUnInit()
  self.parent = nil
  self.loopListView = nil
  self.loopListViewItem:ClearItemData()
  self.loopListViewItem = nil
  self.uiBinder = nil
  self.Index = 0
  self.IsSelected = false
end

function LoopListViewItem:Refresh(data)
  self:OnRefresh(data)
end

local onCoroEventErr = function(err)
  logError("coro event failed with err : {0}", err)
end

function LoopListViewItem:AddAsyncListener(subject, func, onErr, onCancel)
  if onErr == nil then
    onErr = onCoroEventErr
  end
  if subject == nil or subject.AddListener == nil then
    logError("AddAsyncListener fail, subject == nil or subject.AddListener == nil")
    return
  end
  subject.AddListener(subject, Z.CoroUtil.create_coro_xpcall(func, function(err)
    if err == Z.CancelException then
      if onCancel then
        onCancel()
      end
      return
    end
    if onErr then
      onErr(err)
    end
  end))
end

function LoopListViewItem:OnInit()
end

function LoopListViewItem:OnUnInit()
end

function LoopListViewItem:OnRecycle()
end

function LoopListViewItem:OnRefresh(data)
end

function LoopListViewItem:OnSelected(isSelected, isClick)
end

function LoopListViewItem:OnPointerClick(go, eventData)
end

function LoopListViewItem:GetCurData()
  return self.parent.DataList[self.Index]
end

function LoopListViewItem:SetCanSelect(isCanSelect)
  self.loopListViewItem.CanSelected = isCanSelect
  self.IsSelected = self.loopListViewItem.IsSelected
end

return LoopListViewItem
