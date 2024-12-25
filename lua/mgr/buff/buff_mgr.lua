local BuffMgr = class("BuffMgr")
local EntityBuffData = require("mgr.buff.entitybuffdata")

function BuffMgr:ctor()
end

function BuffMgr:Init()
  self.entityBuffDatas_ = {}
end

function BuffMgr:Clear()
  for entityId, entityBuffData in pairs(self.entityBuffDatas_) do
    entityBuffData:Dispose()
    self.entityBuffDatas_[entityId] = nil
  end
  self.entityBuffDatas_ = {}
end

function BuffMgr:UnInit()
  self:Clear()
end

function BuffMgr:CreateEntityBuffData(entityId, source)
  if entityId == nil then
    return
  end
  local entity = Z.EntityMgr:GetEntity(entityId)
  if entity == nil then
    logError("BuffMgr:CreateEntityBuffData entity is nil")
    return
  end
  local entityBuffData = self.entityBuffDatas_[entityId]
  if entityBuffData then
    entityBuffData:AddSource(source)
    return
  end
  entityBuffData = EntityBuffData.new(entityId)
  entityBuffData:AddSource(source)
  self.entityBuffDatas_[entityId] = entityBuffData
end

function BuffMgr:GetEntityBuffData(entityId)
  return self.entityBuffDatas_[entityId]
end

function BuffMgr:RemoveBuffData(entityId, source)
  local entityBuffData = self.entityBuffDatas_[entityId]
  if not entityBuffData then
    return
  end
  entityBuffData:RemoveSource(source)
  if entityBuffData:CanDispose() == 0 then
    entityBuffData:Dispose()
    self.entityBuffDatas_[entityId] = nil
  end
end

function BuffMgr:GetBuffData(entityId, buffId)
  local entityBuffData = self.entityBuffDatas_[entityId]
  if not entityBuffData then
    return nil
  end
  return entityBuffData:GetBuffData(buffId)
end

function BuffMgr:BindBuffChangeCallBack(entityId, callBack)
  local entityBuffData = self.entityBuffDatas_[entityId]
  if not entityBuffData then
    return
  end
  entityBuffData:BindBuffChangeCallBack(callBack)
end

function BuffMgr:UnBindBuffChangeCallBack(entityId, callBack)
  local entityBuffData = self.entityBuffDatas_[entityId]
  if not entityBuffData then
    return
  end
  entityBuffData:UnBindBuffChangeCallBack(callBack)
end

return BuffMgr
