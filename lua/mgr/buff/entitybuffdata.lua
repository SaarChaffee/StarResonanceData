local EntityBuffData = class("EntityBuffData")

function EntityBuffData:ctor(entityId)
  self.entityId_ = entityId
  self.buffItemMap_ = {}
  local entity = Z.EntityMgr:GetEntity(entityId)
  if not entity then
    logError("BuffMgr:buildEntityBuffData entity is nil")
    return
  end
  self.buffItemMap_ = self:getBuffItems(entity)
  self:bindEntityBuffWatcher(entity)
end

function EntityBuffData:getBuffItems(entity)
  local buffItemMap = {}
  local buffItemList = entity:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if buffItemList then
    buffItemList = buffItemList.Value
    for i = 0, buffItemList.count - 1 do
      local data = buffItemList[i]
      if data then
        buffItemMap[data.BuffBaseId] = data
      end
    end
  end
  return buffItemMap
end

function EntityBuffData:bindEntityBuffWatcher(entity)
  if not entity then
    return
  end
  self.watcher_ = Z.EntityMgr:BindEntityLuaAttrWatcher(entity.Uuid, {
    Z.AttrCreator.ToIndex(Z.LocalAttr.ENowBuffList)
  }, function()
    self.buffItemMap_ = self:getBuffItems(entity)
    self:notifyBuffChange()
  end)
end

function EntityBuffData:notifyBuffChange()
  if not self.buffChangeCallBacks_ then
    return
  end
  for _, callBack in ipairs(self.buffChangeCallBacks_) do
    callBack()
  end
end

function EntityBuffData:AddSource(source)
  if not self.buffItemMap_ then
    return
  end
  if not source then
    logError("EntityBuffData:AddSource source is nil")
    source = 1
  end
  if self.sources_ == nil then
    self.sources_ = {}
  end
  local sourceCount = self.sources_[source] or 0
  self.sources_[source] = sourceCount + 1
end

function EntityBuffData:RemoveSource(source)
  if not self.buffItemMap_ then
    return
  end
  if not source then
    logError("EntityBuffData:RemoveSource source is nil")
    source = 1
  end
  if self.sources_ == nil then
    return
  end
  local sourceCount = self.sources_[source] or 0
  if 0 < sourceCount then
    self.sources_[source] = sourceCount - 1
  end
  if self.sources_[source] <= 0 then
    self.sources_[source] = nil
  end
end

function EntityBuffData:CanDispose()
  return self.sources_ == nil or next(self.sources_) == nil
end

function EntityBuffData:BindBuffChangeCallBack(callBack)
  if self.buffChangeCallBacks_ == nil or callBack == nil then
    self.buffChangeCallBacks_ = {}
  end
  table.insert(self.buffChangeCallBacks_, callBack)
end

function EntityBuffData:UnBindBuffChangeCallBack(callBack)
  if not self.buffChangeCallBacks_ or callBack == nil then
    return
  end
  for i, cb in ipairs(self.buffChangeCallBacks_) do
    if cb == callBack then
      table.remove(self.buffChangeCallBacks_, i)
      return
    end
  end
end

function EntityBuffData:GetBuffData(buffId)
  if not self.buffItemMap_ then
    return nil
  end
  return self.buffItemMap_[buffId]
end

function EntityBuffData:GetBuffItemMap()
  return self.buffItemMap_
end

function EntityBuffData:GetBuffDatas()
  return self.buffItemMap_
end

function EntityBuffData:Dispose()
  if self.watcher_ then
    Z.EntityMgr:UnbindEntityLuaAttrWater(self.entityId_, self.watcher_)
  end
  self.buffChangeCallBacks_ = nil
  self.buffItemMap_ = nil
  self.entityId_ = nil
  self.watcher_ = nil
  self.sources_ = nil
end

return EntityBuffData
