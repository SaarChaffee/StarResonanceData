local PlayerCtrlBtnBase = class("PlayerCtrlBtnBase")

function PlayerCtrlBtnBase:ctor(key, panel, playerCtrlBtnTemplates)
  self.key_ = key
  self.panel_ = panel
  self.playerCtrlBtnTemplates_ = playerCtrlBtnTemplates
  self.parent_ = nil
  self.cancelSource = Z.CancelSource.Rent()
  self.luaEntityAttrWatchers = {}
  self.luaWordAttrWatchers = {}
  self.uiBinder = nil
  self.active_ = true
  self.isReset_ = false
  self.timerMgr = Z.TimerMgr.new()
  self.vm_ = Z.VMMgr.GetVM("player_ctrl_btns")
  self.layoutElement_ = nil
  self.scale_ = {}
  self.slotId = nil
end

function PlayerCtrlBtnBase:GetUIUnitPath()
  return ""
end

function PlayerCtrlBtnBase:Create(parent)
  self.parent_ = parent
  if not parent then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.uiBinder and self.parent_ then
      self.uiBinder = self.panel_:AsyncLoadUiUnit(self:GetUIUnitPath(), self.key_, self.parent_.transform)
    end
    if not self.uiBinder then
      return
    end
    if self.isReset_ then
      self.panel_:RemoveUiUnit(self.key_)
      return
    end
    if self.uiBinder ~= nil then
      self.uiBinder.Ref.UIComp:SetVisible(true)
      self:OnActive()
      self:BindLuaAttrWatchers()
      self:RegisterEvent()
    end
  end)()
end

function PlayerCtrlBtnBase:SetIgnoreLayout(flag)
  self.ignoreLayout_ = flag
  if self.uiBinder ~= nil and self.layoutElement_ ~= nil then
    self.layoutElement_:SetIgnoreLayout(flag)
  end
end

function PlayerCtrlBtnBase:OnActive()
end

function PlayerCtrlBtnBase:BindLuaAttrWatchers()
end

function PlayerCtrlBtnBase:getBindLuaAttrWatcherParamCtrlBtn(attrTypes, func, needToIndex)
  if attrTypes == nil or #attrTypes < 1 then
    return nil, nil
  end
  local f = function()
    if self.uiBinder ~= nil then
      func(self)
    end
  end
  if needToIndex then
    local indexs = {}
    for i = 1, #attrTypes do
      indexs[i] = Z.AttrCreator.ToIndex(attrTypes[i])
    end
    return indexs, f
  end
  return attrTypes, f
end

function PlayerCtrlBtnBase:BindEntityLuaAttrWatcher(attrTypes, entity, func, needToIndex)
  local indexs, f = self:getBindLuaAttrWatcherParamCtrlBtn(attrTypes, func, needToIndex)
  local attrTab = {}
  for _, attr in pairs(indexs) do
    table.insert(attrTab, attr)
  end
  if indexs == nil then
    logError("attrTypes is nil or count < 1")
    return nil
  end
  local watcherToken
  if entity then
    watcherToken = Z.EntityMgr:BindEntityLuaAttrWatcher(entity.Uuid, attrTab, f)
    self.luaEntityAttrWatchers[watcherToken] = entity.Uuid
  end
  return watcherToken
end

function PlayerCtrlBtnBase:BindWorldLuaAttrWatcher(attrTypes, func, needToIndex)
  if needToIndex == nil then
    needToIndex = false
  end
  local indexs, f = self:getBindLuaAttrWatcherParamCtrlBtn(attrTypes, func, needToIndex)
  if indexs == nil then
    logError("attrTypes is nil or count<1")
    return nil
  end
  local watcherToken
  watcherToken = Z.World:BindWorldLuaAttrWatcher(indexs, f)
  table.insert(self.luaWordAttrWatchers, watcherToken)
  return watcherToken
end

function PlayerCtrlBtnBase:RegisterEvent()
end

function PlayerCtrlBtnBase:UnregisterEvent()
end

function PlayerCtrlBtnBase:UnBindLuaAttrWatchers()
  for key in pairs(self.luaEntityAttrWatchers) do
    self:UnBindEntityLuaAttrWatcher(key)
  end
  self.luaEntityAttrWatchers = {}
  for key in pairs(self.luaWordAttrWatchers) do
    self:UnBindWorldLuaAttrWatcher(key, false)
  end
  self.luaWordAttrWatchers = {}
end

function PlayerCtrlBtnBase:UnBindEntityLuaAttrWatcher(watcherToken)
  if self.luaEntityAttrWatchers == nil or watcherToken == nil or self.luaEntityAttrWatchers[watcherToken] == nil then
    return false
  end
  local uuid = self.luaEntityAttrWatchers[watcherToken]
  Z.EntityMgr:UnbindEntityLuaAttrWater(uuid, watcherToken)
  self.luaEntityAttrWatchers[watcherToken] = nil
end

function PlayerCtrlBtnBase:UnBindWorldLuaAttrWatcher(watcherToken, isRemove)
  if watcherToken == nil then
    return false
  end
  local isOk = Z.World:UnbindWorldLuaAttrWater(watcherToken)
  for i, v in pairs(self.luaWordAttrWatchers) do
    if isRemove and v == watcherToken then
      table.remove(self.luaWordAttrWatchers, i)
      break
    end
  end
  return isOk
end

function PlayerCtrlBtnBase:AddAsyncClick(btn, clickFunc, onErr, onCancel)
  self.panel_:AddAsyncClick(btn, clickFunc, onErr, onCancel)
end

function PlayerCtrlBtnBase:OnDeActive()
end

function PlayerCtrlBtnBase:Reset()
  self.isReset_ = true
  if self.uiBinder then
    self:UnregisterEvent()
    self:UnBindLuaAttrWatchers()
    self:OnDeActive()
    self.timerMgr:Clear()
  end
  self.panel_:RemoveUiUnit(self.key_)
  Z.EventMgr:RemoveObjAll(self)
end

return PlayerCtrlBtnBase
