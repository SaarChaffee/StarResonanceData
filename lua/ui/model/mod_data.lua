local super = require("ui.model.data_base")
local ModData = class("ModData", super)

function ModData:ctor()
  super.ctor(self)
  self:ResetData()
end

function ModData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.ModFilter = {}
end

function ModData:UnInit()
  self.CancelSource:Recycle()
end

function ModData:Clear()
  self.ModFilter = {}
end

function ModData:OnReconnect()
end

function ModData:ResetData()
  self.modQualityConfig_ = {}
  self.modEffectConfig_ = {}
  self.modLinkEffectConfig_ = {}
  self.modLinkEffectConfigCount_ = 0
  local modEnhancedconsumption = Z.Global.ModEnhancedconsumption
  for _, config in ipairs(modEnhancedconsumption) do
    local quality = config[1]
    local enhancedConsumption = config
    local enhancementHoleNum = {}
    local successRate = {}
    local path = ""
    for _, value in ipairs(Z.Global.EnhancementHoleNum) do
      if value[1] == quality then
        enhancementHoleNum = value
        break
      end
    end
    for _, value in ipairs(Z.Global.ModEnhancementSuccessRate) do
      if value[1] == quality then
        successRate = value
        break
      end
    end
    for _, value in ipairs(Z.Global.ModModel) do
      if tonumber(value[1]) == quality then
        path = value[2]
        break
      end
    end
    local equipConfig = {
      quality = quality,
      enhancedConsumption = {
        itemId = enhancedConsumption[2] ~= nil and enhancedConsumption[2] or 0,
        count = enhancedConsumption[3] ~= nil and enhancedConsumption[3] or 0
      },
      enhancementHoleNum = enhancementHoleNum[2] ~= nil and enhancementHoleNum[2] or 0,
      successRate = {rate = successRate},
      modelPath = path
    }
    self.modQualityConfig_[quality] = equipConfig
  end
  local effectConfigs = Z.TableMgr.GetTable("ModEffectTableMgr").GetDatas()
  for _, config in ipairs(effectConfigs) do
    if self.modEffectConfig_[config.EffectID] == nil then
      self.modEffectConfig_[config.EffectID] = {}
    end
    self.modEffectConfig_[config.EffectID][config.Level + 1] = config
  end
  self.modLinkEffectConfig_ = Z.TableMgr.GetTable("ModLinkEffectTableMgr").GetDatas()
  self.modLinkEffectConfigCount_ = #self.modLinkEffectConfig_
  self.modHoleConfigs_ = Z.TableMgr.GetTable("ModHoleTableMgr").GetDatas()
end

function ModData:GetQualityConfig(quality)
  return self.modQualityConfig_[quality]
end

function ModData:GetEffectTableConfig(effectId, level)
  return self.modEffectConfig_[effectId][level + 1]
end

function ModData:GetEffectTableConfigList(effectId)
  return self.modEffectConfig_[effectId]
end

function ModData:GetAllEffectList()
  return self.modEffectConfig_
end

function ModData:GetSuccessRate(quality)
  return self.modQualityConfig_[quality].successRate.rate
end

function ModData:GetModLinkEffectConfig(successTimes)
  for i = self.modLinkEffectConfigCount_, 1, -1 do
    if successTimes >= self.modLinkEffectConfig_[i].LinkTime then
      return self.modLinkEffectConfig_[i]
    end
  end
  return nil
end

function ModData:GetModLinkEffectNextLevelConfig(successTimes)
  for i = self.modLinkEffectConfigCount_, 1, -1 do
    if successTimes >= self.modLinkEffectConfig_[i].LinkTime then
      if i == self.modLinkEffectConfigCount_ then
        return nil
      else
        return self.modLinkEffectConfig_[i + 1]
      end
    end
  end
  return nil
end

function ModData:MergeModLinkEffectConfigAttr(curConfig, mergeConfig)
  local mergeAttrs = {}
  for _, attr in ipairs(curConfig.LinkLevelEffect) do
    mergeAttrs[attr[2]] = {
      curValue = attr[3],
      nextValue = 0
    }
  end
  if mergeConfig then
    for _, attr in ipairs(mergeConfig.LinkLevelEffect) do
      if mergeAttrs[attr[2]] then
        mergeAttrs[attr[2]].nextValue = attr[3]
      else
        mergeAttrs[attr[2]] = {
          curValue = 0,
          nextValue = attr[3]
        }
      end
    end
  end
  local tempRes = {}
  local tempResIndex = 0
  for key, value in pairs(mergeAttrs) do
    tempResIndex = tempResIndex + 1
    tempRes[tempResIndex] = {
      attrId = key,
      curValue = value.curValue,
      nextValue = value.nextValue
    }
  end
  table.sort(tempRes, function(a, b)
    return a.attrId < b.attrId
  end)
  return tempRes
end

function ModData:SetIntensifyModUuid(uuid)
  self.intensifyModUuid_ = uuid
end

function ModData:GetIntensifyModUuid()
  return self.intensifyModUuid_
end

function ModData:GetHoleConfigs()
  return self.modHoleConfigs_
end

return ModData
