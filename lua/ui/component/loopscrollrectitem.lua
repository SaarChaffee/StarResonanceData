local LoopScrollRectItem = class("LoopScrollRectItem")

function LoopScrollRectItem:ctor()
end

function LoopScrollRectItem:Init(parent, component, bindName)
  self.parent = parent
  self.component = component
  self.goObj = self.component.gameObject
  self.uiBinder = UIBinderToLua(self.goObj)
  if self.uiBinder == nil then
    self.unit = UICompBindLua(self.goObj)
    self.unit:Init()
  end
  local refreshEvent = self.component.OnRefreshEvent
  self:AddAsyncListener(refreshEvent, refreshEvent.AddListener, function()
    self:Refresh()
  end)
  self.component.OnResetEvent:AddListener(function()
    self:OnReset()
  end)
  self.component.OnBeforePlayAnimEvent:AddListener(function()
    self:OnBeforePlayAnim()
  end)
  self.component.OnPlayAnimEvent:AddListener(function()
    self:PlayAnim()
  end)
  self.component.OnSelectedEvent:AddListener(function(isSelected)
    self:Selected(isSelected)
  end)
  self.component.OnPointClickEvent:AddListener(function(go, eventData)
    self:OnPointerClick(go, eventData)
  end)
  self:OnInit()
end

function LoopScrollRectItem:UnInit()
  self:OnReset()
  if self.unit then
    self.unit:UnInit()
    self.unit = nil
  end
  self.uiBinder = nil
  self:OnUnInit()
  self.component = nil
  self.goObj = nil
  self.parent = nil
end

local onCoroClickErr = function(err)
  logError("coro click failed with err : {0}", err)
end
local onCoroEventErr = function(err)
  logError("coro event failed with err : {0}", err)
end

function LoopScrollRectItem:AddAsyncClick(btn, clickFunc, onErr, onCancel)
  if onErr == nil then
    onErr = onCoroClickErr
  end
  self:AddAsyncListener(btn, btn.AddListener, clickFunc, onErr, onCancel)
end

function LoopScrollRectItem:OnPointerClick(go, eventData)
end

function LoopScrollRectItem:EventAddAsyncListener(event, Func, onErr, onCancel)
  self:AddAsyncListener(event, event.AddListener, Func, onErr, onCancel)
end

function LoopScrollRectItem:AddAsyncListener(subject, registerFunc, func, onErr, onCancel)
  if onErr == nil then
    onErr = onCoroEventErr
  end
  if registerFunc == nil or subject == nil then
    logError("AddAsyncListener fail, registerFunc == nil or subject == nil")
    return
  end
  registerFunc(subject, Z.CoroUtil.create_coro_xpcall(func, function(err)
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

function LoopScrollRectItem:SetUIVisible(ui, visible)
  self.uiBinder.Ref:SetVisible(ui, visible)
end

function LoopScrollRectItem:AddClick(btn, clickFunc)
  btn:AddListener(clickFunc)
end

function LoopScrollRectItem:UpdateData(data)
end

function LoopScrollRectItem:RefreshState()
end

function LoopScrollRectItem:Selected(isSelected)
end

function LoopScrollRectItem:Refresh()
end

function LoopScrollRectItem:OnBeforePlayAnim()
end

function LoopScrollRectItem:PlayAnim()
end

function LoopScrollRectItem:OnReset()
end

function LoopScrollRectItem:OnInit()
end

function LoopScrollRectItem:OnUnInit()
end

return LoopScrollRectItem
