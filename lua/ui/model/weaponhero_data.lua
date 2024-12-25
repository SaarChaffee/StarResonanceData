local super = require("ui.model.data_base")
local WeaponHeroData = class("WeaponHeroData", super)
local elementColor = {
  [1] = Color.New(0.9333333333333333, 0.611764705882353, 0.5843137254901961, 1),
  [2] = Color.New(0.5137254901960784, 0.6745098039215687, 0.8588235294117647, 1),
  [3] = Color.New(0.7137254901960784, 0.6313725490196078, 0.9058823529411765, 1)
}

function WeaponHeroData:ctor()
  self.cacheUuid_ = {}
  self.cacheAnimKey_ = ""
  self.cacheIndex_ = 0
  self.cacheProfessionId_ = 0
  self.showEffect_ = false
  self.resonanceHeroId_ = nil
end

function WeaponHeroData:Init()
  self:cacheHeroAttrs()
end

function WeaponHeroData:GetJobElementColor(element)
  return elementColor[element]
end

function WeaponHeroData:SetAnimKey(keyName)
  self.cacheAnimKey_ = keyName
end

function WeaponHeroData:GetAnimKey()
  local cacheName = self.cacheAnimKey_
  self.cacheAnimKey_ = ""
  return cacheName
end

function WeaponHeroData:CacheEffUUid(k, v)
  if self.cacheUuid_ == nil then
    self.cacheUuid_ = {}
  end
  self.cacheUuid_[k] = v
end

function WeaponHeroData:GetCacheEffUUid(key)
  return self.cacheUuid_[key] or {}
end

function WeaponHeroData:CacheInitProfession(index)
  self.cacheIndex_ = index
end

function WeaponHeroData:GetCacheInitProfession(index)
  return self.cacheIndex_
end

function WeaponHeroData:CacheSelectProfessionId(professionId)
  self.cacheProfessionId_ = professionId
end

function WeaponHeroData:GetCacheSelectProfessionId(professionId)
  local selectId = self.cacheProfessionId_
  self.cacheProfessionId_ = 0
  return selectId
end

function WeaponHeroData:SetShowAllSignEffect()
  self.showEffect_ = true
end

function WeaponHeroData:ClearShowAllSignEffect()
  self.showEffect_ = false
end

function WeaponHeroData:GetShowAllSignEffect()
  local flag = self.showEffect_
  self.showEffect_ = false
  return flag
end

function WeaponHeroData:SetResonanceHeroId(weaponHeroId)
  self.resonanceHeroId_ = weaponHeroId
end

function WeaponHeroData:GetResonanceHeroId()
  return self.resonanceHeroId_
end

function WeaponHeroData:cacheHeroAttrs()
  self.cacheWeaponHeroAttrData_ = {}
  local config = Z.TableMgr.GetTable("HeroAttrTableMgr").GetDatas()
  for _, value in pairs(config) do
    if self.cacheWeaponHeroAttrData_[value.WeaponID] == nil then
      self.cacheWeaponHeroAttrData_[value.WeaponID] = {}
    end
    self.cacheWeaponHeroAttrData_[value.WeaponID][value.Level] = value
  end
end

function WeaponHeroData:GetHeroAttrTableRow(heroId, heroLevel)
  local heroLevelAttrs = self.cacheWeaponHeroAttrData_[heroId]
  if heroLevelAttrs == nil then
    return nil
  end
  if heroLevel < 1 then
    heroLevel = 1
  elseif heroLevel > #heroLevelAttrs then
    heroLevel = #heroLevelAttrs
  end
  return heroLevelAttrs[heroLevel]
end

return WeaponHeroData
