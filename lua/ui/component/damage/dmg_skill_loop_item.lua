local assetPath = "DamagrSkillItem"
local dmgData = Z.DataMgr.Get("damage_data")
local dmg_skill_data = class("dmg_skill_data")
local EDamageSourceSkill = Z.PbEnum("EDamageSource", "EDamageSourceSkill")
local EDamageSourceBullet = Z.PbEnum("EDamageSource", "EDamageSourceBullet")
local EDamageSourceBuff = Z.PbEnum("EDamageSource", "EDamageSourceBuff")
local EDamageSourceFall = Z.PbEnum("EDamageSource", "EDamageSourceFall")

function dmg_skill_data:ctor(parent)
  self.parent_ = parent
  self.item_ = nil
  self.viewData_ = nil
  self.allHit_ = 0
  self.unitName_ = nil
end

function dmg_skill_data:Refresh()
end

function dmg_skill_data:Active(itemName, viewData, parent, allHit)
  self.allHit_ = allHit
  self.viewData_ = viewData
  self.unitName_ = itemName .. viewData.skillId
  Z.CoroUtil.create_coro_xpcall(function()
    self.item_ = self.parent_:AsyncLoadUiUnit(GetLoadAssetPath(assetPath), self.unitName_, parent)
    self.item_.Ref:SetParent(parent)
    self:setTextData()
  end)()
end

function dmg_skill_data:setTextData()
  if self.viewData_.hitSource == EDamageSourceSkill then
    local skillTab = Z.TableMgr.GetTable("SkillTableMgr").GetRow(tonumber(self.viewData_.skillId))
    if skillTab then
      local skillEffectCfgData = Z.TableMgr.GetTable("SkillEffectTableMgr").GetRow(skillTab.EffectIDs[1])
      self.item_.lab_01.TMPLab.text = Lang("WeaponHeroSkill") .. skillEffectCfgData.Id .. skillEffectCfgData.Name
    end
  elseif self.viewData_.hitSource == EDamageSourceBuff then
    local buffTab = Z.TableMgr.GetTable("BuffTableMgr").GetRow(tonumber(self.viewData_.skillId))
    if buffTab then
      self.item_.lab_01.TMPLab.text = "Buff" .. buffTab.Id .. buffTab.Name
    end
  elseif self.viewData_.hitSource == EDamageSourceBullet then
    local bulletTab = Z.TableMgr.GetTable("BulletTableMgr").GetRow(tonumber(self.viewData_.skillId))
    if bulletTab then
      self.item_.lab_01.TMPLab.text = Lang("Bullet") .. bulletTab.Id .. bulletTab.Name
    end
  else
    self.item_.lab_01.TMPLab.text = self.viewData_.skillId
  end
  local radio
  local hit = dmgData.TypeIndex == 3 and self.viewData_.Hit or self.viewData_.sheildAndHpLessenValue
  if self.allHit_ == 0 then
    radio = "0%"
  else
    radio = math.floor(hit / self.allHit_ * 100) .. "%"
  end
  local str = string.zconcat(hit, "/", self.viewData_.overHit, " (", self.viewData_.count, Lang("GMCount"), "/ ", dmgData.ReleaseSkillCount, Lang("GMCount"), ", ", radio, ")")
  self.item_.lab_02.TMPLab.text = str
  self.item_.slider.Slider.value = math.floor(hit / self.allHit_ * 100)
end

function dmg_skill_data:OnDeActive()
  self.parent_:RemoveUiUnit(self.unitName_)
  self.item_ = nil
  self.viewData_ = nil
  self.parent_ = nil
end

return dmg_skill_data
