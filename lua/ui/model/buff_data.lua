local super = require("ui.model.data_base")
local BuffData = class("BuffData", super)

function BuffData:ctor()
  super.ctor(self)
end

function BuffData:Init()
  self.buffBanFuncMap_ = {
    BuffIdMapFuncIds = {},
    BuffAbilityTypeMapFuncIds = {}
  }
  self.cacheResIconId_ = {}
  self:initBuffBanFuncMap()
  self:ClearProfessionBuff()
  Z.EventMgr:Add(Z.ConstValue.Buff.ProfessionBuffChange, self.SetProfessionBuff, self)
end

function BuffData:Clear()
  self:ClearProfessionBuff()
end

function BuffData:UnInit()
  self:ClearProfessionBuff()
  Z.EventMgr:Remove(Z.ConstValue.Buff.ProfessionBuffChange, self.SetProfessionBuff, self)
end

function BuffData:GetBuffBanFuncMap()
  return self.buffBanFuncMap_
end

function BuffData:initBuffBanFuncMap()
  self.buffBanFuncMap_.BuffAbilityTypeMapFuncIds[1] = {
    100601,
    100602,
    100603,
    100604,
    100701,
    100702,
    100703,
    100704,
    100705,
    100706,
    100707,
    100708,
    101101,
    101102,
    102017,
    102018,
    102019,
    103004,
    104100,
    104200,
    104210,
    104211,
    104212,
    110801,
    110802,
    110803,
    110804,
    110811,
    110821,
    200001,
    200500,
    200501,
    200502,
    200503,
    200504,
    200505,
    102001,
    200506,
    800800,
    100903,
    800505,
    800506,
    200700,
    200101,
    800500
  }
end

function BuffData:AddBanFuncsByBuffId(buffId, funcIds)
  if buffId == nil or funcIds == nil then
    return
  end
  local ids = self.buffBanFuncMap_.BuffIdMapFuncIds[buffId]
  if ids == nil then
    ids = {}
    self.buffBanFuncMap_.BuffIdMapFuncIds[buffId] = ids
  end
  for _, id in ipairs(funcIds) do
    if not table.zcontains(ids, id) then
      table.insert(ids, id)
    end
  end
end

function BuffData:RemoveBanFuncsByBuffId(buffId, funcIds)
  if buffId == nil or funcIds == nil then
    return
  end
  local ids = self.buffBanFuncMap_.BuffIdMapFuncIds[buffId]
  if ids == nil then
    ids = {}
  end
  for _, id in ipairs(funcIds) do
    table.zremoveByValue(ids, id)
  end
end

function BuffData:SetProfessionBuff(buffId, type, buffLayer)
  self.professionBuffId_ = type
  self.professionBuffLayer_ = buffLayer
  if 0 < buffLayer then
    if not table.zcontains(self.cacheResIconId_, type) then
      table.insert(self.cacheResIconId_, type)
    end
  else
    table.zremoveByValue(self.cacheResIconId_, type)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Buff.ProfessionBuffRefreshView)
end

function BuffData:GetProfessionBuff()
  return self.professionBuffId_, self.professionBuffLayer_, self.cacheResIconId_
end

function BuffData:ClearProfessionBuff()
  self.professionBuffId_ = nil
  self.professionBuffLayer_ = nil
  self.cacheResIconId_ = {}
end

function BuffData:GetProfessionBuffPosition1()
  if not self.professionBuffPosition1_ then
    if Z.IsPCUI then
      self.professionBuffPosition1_ = Vector3.New(-8, 0, 0)
    else
      self.professionBuffPosition1_ = Vector3.New(-12, 0, 0)
    end
  end
  return self.professionBuffPosition1_
end

function BuffData:GetProfessionBuffPosition2()
  if not self.professionBuffPosition2_ then
    self.professionBuffPosition2_ = Vector3.New(0, 0, 0)
  end
  return self.professionBuffPosition2_
end

return BuffData
