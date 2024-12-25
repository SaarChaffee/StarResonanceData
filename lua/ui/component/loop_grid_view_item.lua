local LoopGridViewItem = class("LoopGridViewItem")

function LoopGridViewItem:ctor()
end

function LoopGridViewItem:Init(parent, zLoopGridViewItem)
  self.parent = parent
  self.loopGridView = parent.LoopGridView
  self.loopGridViewItem = zLoopGridViewItem
  self.uiBinder = UIBinderToLua(zLoopGridViewItem.gameObject)
  self.Index = 0
  self.IsSelected = false
  self.loopGridViewItem.OnSelectEvent:AddListener(function(isSelected, isClick)
    self.IsSelected = isSelected
    self:OnSelected(isSelected, isClick)
  end)
  self.loopGridViewItem.OnPointClickEvent:AddListener(function(go, eventData)
    self:OnPointerClick(go, eventData)
  end)
  self.loopGridViewItem.OnRecycleEvent:AddListener(function(go, eventData)
    self:OnRecycle()
  end)
  self:OnInit()
end

function LoopGridViewItem:UnInit()
  self:OnUnInit()
  self.parent = nil
  self.loopGridView = nil
  self.loopGridViewItem:ClearItemData()
  self.loopGridViewItem = nil
  self.uiBinder = nil
  self.Index = 0
  self.IsSelected = false
end

function LoopGridViewItem:Refresh(data)
  self:OnRefresh(data)
end

local onCoroEventErr = function(err)
  logError("coro event failed with err : {0}", err)
end

function LoopGridViewItem:AddAsyncListener(subject, func, onErr, onCancel)
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

function LoopGridViewItem:OnInit()
end

function LoopGridViewItem:OnUnInit()
end

function LoopGridViewItem:OnRecycle()
end

function LoopGridViewItem:OnRefresh(data)
end

function LoopGridViewItem:OnSelected(isSelected, isClick)
end

function LoopGridViewItem:OnPointerClick(go, eventData)
end

function LoopGridViewItem:GetCurData()
  return self.parent.DataList[self.Index]
end

function LoopGridViewItem:SetCanSelect(isCanSelect)
  self.loopGridViewItem.CanSelected = isCanSelect
  self.IsSelected = self.loopGridViewItem.IsSelected
end

return LoopGridViewItem
