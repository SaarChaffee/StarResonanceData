local super = require("ui.model.data_base")
local DmgData = class("DmgData", super)

function DmgData:ctor()
  super.ctor(self)
  self.TypeIndex = 1
  self.SkillIndex = 1
  self.TotalDamage = 0
  self.AllHit = 0
  self.timerMgr = Z.TimerMgr.new()
  self.ShowType = 0
  self.AllAttUuid = {}
  self.AllByAttUuid = {}
  self.NearByEnity = {}
  self.NowAttUuid = 0
  self.NowByAttUuid = 0
  self.ReleaseSkillCount = 0
  self.SelectAttUuid = Lang("DamageSelfTxt")
  self.SelectByAttUuid = Lang("DamageAllTxt")
  self.SelectPartId = 0
  self.ShowBodyDroTab = {}
  self.ShowTargetDroTab = {}
  self.ShowPartDroTab = {}
  self.Type = {}
  self.BodyUuid = {}
  self.Body = {}
  self.TargetUuid = {}
  self.Target = {}
  self.Part = {}
  self.Skill = {}
  self.ShowDamageDatas = {}
  self.DamageDatas = {}
  self.TakeDamageDatas = {}
  self.IsSelectedBuffDro = false
  self.IsSelectedSkillDro = false
  self.IsSelectedMonsterDro = false
  self.IsSelectedAttrDro = false
  self.ShowBuffDroData = {}
  self.ShowMonsterDroData = {}
  self.ShowDummyDroData = {}
  self.ShowSkillDroData = {}
  self.ShowAttrDroData = {}
  self.ControlMonsterTab = {}
  self.ControlDummyTab = {}
  self.ControlMonsterFormationTab = {}
  self.ControlNearMonsterTab = {}
  self.ControlNearDummyTab = {}
  self.ControlFightAttrData = {}
  self.ControlSkillTab = {}
  self.ControlBuffData = {}
  self.ControlMonsterAttrTab = {}
  self.ControlBuffPartTab = {}
  self.ControlBuffId = 0
  self.ControlBuffCount = 1
  self.ControlBuffTime = 0
  self.ControlShowBuffData = {}
  self.ControlSelectBuffPartData = ""
  self.ControlSelectedAttrData = ""
  self.ControlAttrCount = 0
  self.ControlAttrId = 0
  self.ControlSelectAttrPartData = ""
  self.ControlShowAttrData = {}
  self.ControlAttrPartData = {}
  self.ControlNowSelectTargetUuid = 0
  self.ControlSkillId = 0
  self.ControlFormationIndex = 0
  self.ControlSelectMonsterData = ""
  self.ControlSelectDummyData = ""
  self.IsShowNowBuff = true
  self.AttrTargetTab = {
    Lang("DamageSelfTxt")
  }
  self.AttrPartTab = {
    Lang("DamagePartTxt")
  }
  self.AttrNowSelectIndex = 0
  self.BuffTargetTab = {}
  self.BuffPartTab = {
    Lang("DamagePartTxt")
  }
  self.BuffNowSelectIndex = 0
  self.StatisBuffTablse = {}
  self.ShieldTargetTab = {}
  self.ShieldDataTab = {}
  self.IsShowNowShield = true
  self.ShieldStatisticsData = {}
end

function DmgData:Init()
  self.PlayerUuid = tostring(Z.EntityMgr.PlayerUuid)
  self.ShowType = 1
  self.TypeIndex = 1
  self.SelectPartId = 0
  self.SelectAttUuid = Lang("DamageSelfTxt")
  self.SelectByAttUuid = Lang("DamageAllTxt")
end

function DmgData:SetNearByEnity(data)
  self.NearByEnity = data
end

function DmgData:AddSkillTab(skillTab)
  self.Skill = skillTab
end

function DmgData:SetShieldTab(uuid, data)
  if self.StatisBuffTablse[uuid] then
    self.ShieldDataTab = {}
    self.ShieldDataTab[uuid] = {}
    for _, shieldData in pairs(data) do
      local tab = {}
      for buffConfigId, value in pairs(self.StatisBuffTablse[uuid].data) do
        if value.data.BuffUuid == shieldData.buffId then
          tab.buffDuration = value.data.Duration
          tab.buffConfigId = buffConfigId
          tab.shiedlData = shieldData
          tab.downTime = value.downTime
          tab.value = shieldData.value
          tab.maxValue = shieldData.maxValue
          tab.count = 1
          table.insert(self.ShieldDataTab[uuid], tab)
          break
        end
      end
    end
  end
end

function DmgData:SetAttrTargetTab(tab)
  self.AttrTargetTab = tab
  table.insert(self.AttrTargetTab, 1, Lang("DamageSelfTxt"))
end

function DmgData:SetShieldTargetTab(tab)
  self.ShieldTargetTab = tab
  table.insert(self.ShieldTargetTab, 1, Lang("DamageSelfTxt"))
end

function DmgData:SetBuffTargetTab(tab)
  self.BuffTargetTab = tab
  table.insert(self.BuffTargetTab, 1, Lang("DamageSelfTxt"))
end

function DmgData:SetTargetTab(tab)
  self.Target = tab
  table.insert(self.Target, 1, Lang("Team"))
  table.insert(self.Target, 1, Lang("DamageSelfTxt"))
  table.insert(self.Target, 1, Lang("DamageAllTxt"))
end

function DmgData:SetBodyTab(tab)
  self.Body = tab
  table.insert(self.Body, 1, Lang("Team"))
  table.insert(self.Body, 1, Lang("DamageSelfTxt"))
  table.insert(self.Body, 1, Lang("DamageAllTxt"))
end

function DmgData:SetShieldStatisticsData(uuid, data)
  if self.ShieldStatisticsData[uuid] == nil then
    self.ShieldStatisticsData[uuid] = {}
  end
  for _, shieldData in pairs(data) do
    local isHave = false
    for __, shield in pairs(self.ShieldStatisticsData[uuid]) do
      if shieldData.buffId == shield.buffUuid then
        isHave = true
        if self.StatisBuffTablse[uuid] then
          for buffConfigId, value in pairs(self.StatisBuffTablse[uuid].data) do
            if value.data.BuffUuid == shield.shiedlData.buffId then
              shield.buffDuration = value.data.Duration
              shield.value = shieldData.value
            end
          end
          break
        end
      end
    end
    if not isHave and self.StatisBuffTablse[uuid] then
      for buffConfigId, value in pairs(self.StatisBuffTablse[uuid].data) do
        if value.data.BuffUuid == shieldData.buffId then
          local tab = {}
          tab.buffDuration = value.data.Duration
          tab.buffConfigId = buffConfigId
          tab.shiedlData = shieldData
          tab.value = shieldData.value
          tab.maxValue = shieldData.maxValue
          tab.overShield = 0
          tab.buffUuid = shieldData.buffId
          table.insert(self.ShieldStatisticsData[uuid], tab)
          break
        end
      end
    end
  end
  for _, supertatisticsData in ipairs(self.ShieldStatisticsData[uuid]) do
    local isHave = false
    for __, shieldData in ipairs(self.ShieldDataTab[uuid]) do
      if supertatisticsData.buffUuid == shieldData.shiedlData.buffId then
        isHave = true
        break
      end
    end
    if isHave == false then
      supertatisticsData.overShield = supertatisticsData.value
    end
  end
end

function DmgData:GetShowShieldStatisticsData(uuid)
  local tabl = {}
  for _, supertatisticsData in ipairs(self.ShieldStatisticsData[uuid]) do
    if tabl[supertatisticsData.buffConfigId] == nil then
      tabl[supertatisticsData.buffConfigId] = {}
      tabl[supertatisticsData.buffConfigId].buffConfigId = supertatisticsData.buffConfigId
      tabl[supertatisticsData.buffConfigId].value = 0
      tabl[supertatisticsData.buffConfigId].maxValue = 0
      tabl[supertatisticsData.buffConfigId].overShield = 0
      tabl[supertatisticsData.buffConfigId].buffDuration = 0
    end
    tabl[supertatisticsData.buffConfigId].value = tabl[supertatisticsData.buffConfigId].value + supertatisticsData.value
    tabl[supertatisticsData.buffConfigId].maxValue = tabl[supertatisticsData.buffConfigId].maxValue + supertatisticsData.maxValue
    tabl[supertatisticsData.buffConfigId].overShield = tabl[supertatisticsData.buffConfigId].overShield + supertatisticsData.overShield
    if tabl[supertatisticsData.buffConfigId].buffDuration < supertatisticsData.buffDuration then
      tabl[supertatisticsData.buffConfigId].buffDuration = supertatisticsData.buffDuration
    end
  end
  return table.zvalues(tabl)
end

function DmgData:SetShowDmgData(data)
  self.ShowDamageDatas = data
end

function DmgData:SetTakeDmgData(data)
  self.TakeDamageDatas = data
end

function DmgData:AddPartTab(parTab)
  self.Part = {
    Lang("DamagePartTxt"),
    Lang("DamageAllPartTxt")
  }
  for key, value in pairs(parTab) do
    table.insert(self.Part, tostring(value))
  end
end

function DmgData:SetTotalDamage(number)
  self.TotalDamage = number
  for key, value in pairs(self.ShowDamageDatas) do
    value.allHit = self.TotalDamage
  end
end

function DmgData:AttUidAndByUuidISEquail(data, weaponID)
  for key, value in pairs(data) do
    if value.id == weaponID then
      return value
    end
  end
  return false
end

function DmgData:FindSklillUuid(data, skillId)
  for key, value in pairs(data) do
    if value.skillId == skillId then
      return value
    end
  end
  return false
end

function DmgData:CreateDmgData(weaponId, data1)
  local tab = {}
  tab.attUuid = data1.attUuid
  tab.byAttUuid = data1.byAttUuid
  tab.patrUuid = data1.patrUuid
  tab.hitType = data1.weapon.dmgSkill.hitType
  tab.allHit = 0
  tab.data = {}
  local weaponTab = self:CreateWeaponTab(weaponId)
  local skillTab = self:CreateSkillTab(data1)
  table.insert(weaponTab.data, skillTab)
  table.insert(tab.data, weaponTab)
  table.insert(self.DamageDatas, tab)
end

function DmgData:DownTimer(data)
  data.tim = data.tim + 0.1
  if data.tim >= 4.9 then
    data.time = data.time + 2
    data.tim = 0
    Z.VMMgr.GetVM("damage").ChangeDrowIndex()
  end
end

function DmgData:CreateSkillTab(data1)
  local skillTab = {}
  skillTab.Hit = data1.weapon.dmgSkill.hit
  skillTab.skillId = data1.weapon.dmgSkill.skillUuid
  skillTab.damageId = data1.weapon.dmgSkill.damageId
  skillTab.count = data1.weapon.dmgSkill.count
  skillTab.hpLessenValue = data1.weapon.dmgSkill.hpLessenValue
  skillTab.shieldLessenValue = data1.weapon.dmgSkill.shieldLessenValue
  skillTab.sheildAndHpLessenValue = skillTab.hpLessenValue + skillTab.shieldLessenValue
  skillTab.hitSource = data1.weapon.dmgSkill.hitSource
  skillTab.actualValue = data1.weapon.dmgSkill.actualValue
  if data1.weapon.dmgSkill.isDeda then
    skillTab.overHit = skillTab.Hit - skillTab.hpLessenValue
  else
    skillTab.overHit = 0
  end
  return skillTab
end

function DmgData:CreateWeaponTab(weaponId)
  local weaponTab = {}
  weaponTab.id = weaponId
  weaponTab.time = 1
  weaponTab.tim = 0
  weaponTab.timer = self.timerMgr:StartTimer(function()
    self:DownTimer(weaponTab)
  end, 0.1, 50)
  weaponTab.data = {}
  return weaponTab
end

function DmgData:SetDmgData(data1, weaponId)
  local isFlag = false
  self:FindAttack(data1.attUuid)
  self:FindByAttack(data1.byAttUuid)
  for key, value in pairs(self.DamageDatas) do
    if value.attUuid == data1.attUuid and value.byAttUuid == data1.byAttUuid and value.patrUuid == data1.patrUuid then
      isFlag = true
      local datas = self:AttUidAndByUuidISEquail(value.data, weaponId)
      if datas then
        if datas.timer ~= nil then
          self.timerMgr:StopTimer(datas.timer)
          if datas.tim > 1 then
            datas.time = math.floor(datas.tim) + datas.time
            datas.tim = 0
          end
        end
        datas.timer = self.timerMgr:StartTimer(function()
          self:DownTimer(datas)
        end, 0.1, 50)
        local skillData = self:FindSklillUuid(datas.data, data1.weapon.dmgSkill.skillUuid)
        if skillData then
          skillData.actualValue = skillData.actualValue + data1.weapon.dmgSkill.actualValue
          skillData.Hit = skillData.Hit + data1.weapon.dmgSkill.hit
          skillData.count = skillData.count + data1.weapon.dmgSkill.count
          skillData.hpLessenValue = skillData.hpLessenValue + data1.weapon.dmgSkill.hpLessenValue
          skillData.shieldLessenValue = skillData.shieldLessenValue + data1.weapon.dmgSkill.shieldLessenValue
          skillData.sheildAndHpLessenValue = skillData.hpLessenValue + skillData.shieldLessenValue
          if value.patrUuid == 0 then
            if data1.weapon.dmgSkill.isDeda then
              self.timerMgr:StopTimer(datas.timer)
              self:FindUuid(self.AllAttUuid, value.attUuid)
              self:FindUuid(self.AllByAttUuid, value.byAttUuid)
              skillData.overHit = skillData.overHit + data1.weapon.dmgSkill.hit - data1.weapon.dmgSkill.hpLessenValue
            else
              skillData.overHit = skillData.overHit + 0
            end
          elseif data1.weapon.dmgSkill.isDeda then
            self.timerMgr:StopTimer(datas.timer)
            self:FindUuid(self.AllAttUuid, value.attUuid)
            self:FindUuid(self.AllByAttUuid, value.byAttUuid)
            skillData.overHit = skillData.overHit + data1.weapon.dmgSkill.hit - data1.weapon.dmgSkill.hpLessenValue
          else
            skillData.overHit = skillData.overHit + 0
          end
        else
          local skillTab = self:CreateSkillTab(data1)
          table.insert(datas.data, skillTab)
        end
      else
        do
          local weaponTab = self:CreateWeaponTab(weaponId)
          local skillTab = self:CreateSkillTab(data1)
          table.insert(weaponTab.data, skillTab)
          table.insert(value.data, weaponTab)
        end
      end
    end
  end
  if not isFlag then
    self:CreateDmgData(weaponId, data1)
  end
  self.NowAttUuid = data1.attUuid
  self.NowByAttUuid = data1.byAttUuid
  Z.VMMgr.GetVM("damage").ChangeDrowIndex()
end

function DmgData:FindUuid(data, uuid)
  for key, value in pairs(data) do
    if value.uuid == uuid then
      self:StopTimer(value)
    end
  end
end

function DmgData:StopTimer(data)
  self.timerMgr:StopTimer(data.timer)
end

function DmgData:FindAttack(uuid)
  for key, value in pairs(self.AllAttUuid) do
    if value.uuid == uuid then
      if value.timer ~= nil then
        self.timerMgr:StopTimer(value.timer)
        if value.tim > 1 then
          value.time = math.floor(value.tim) + value.time
          value.tim = 0
        end
      end
      value.timer = self.timerMgr:StartTimer(function()
        self:DownTimer(value)
      end, 0.1, 50)
      return
    end
  end
  self:CreateAttack(uuid)
end

function DmgData:FindByAttack(uuid)
  for key, value in pairs(self.AllByAttUuid) do
    if value.uuid == uuid then
      if value.timer ~= nil then
        self.timerMgr:StopTimer(value.timer)
        if value.tim > 1 then
          value.time = math.floor(value.tim) + value.time
          value.tim = 0
        end
      end
      value.timer = self.timerMgr:StartTimer(function()
        self:DownTimer(value)
      end, 0.1, 50)
      return
    end
  end
  self:CreateByAttack(uuid)
end

function DmgData:CreateByAttack(uuid)
  local byatt = {}
  byatt.uuid = uuid
  byatt.time = 1
  byatt.tim = 0
  byatt.timer = self.timerMgr:StartTimer(function()
    self:DownTimer(byatt)
  end, 0.1, 50)
  table.insert(self.AllByAttUuid, byatt)
end

function DmgData:CreateAttack(uuid)
  local att = {}
  att.uuid = uuid
  att.time = 1
  att.tim = 0
  att.timer = self.timerMgr:StartTimer(function()
    self:DownTimer(att)
  end, 0.1, 50)
  table.insert(self.AllAttUuid, att)
end

function DmgData:RefreshData()
  self.NowAttUuid = 0
  self.NowByAttUuid = 0
  self.DamageDatas = {}
  self.NearByEnity = {}
  self.AllAttUuid = {}
  self.AllByAttUuid = {}
  self.timerMgr:Clear()
  self.ControlShowAttrData = {}
  self.ControlShowBuffData = {}
  self.StatisBuffTablse = {}
  self.ShieldStatisticsData = {}
  Z.VMMgr.GetVM("damage").ChangeDrowIndex()
end

function DmgData:SetBuffData(buffData, buffTable)
  if self.StatisBuffTablse[buffData.FireUuid] then
    local data = self.StatisBuffTablse[buffData.FireUuid].data[buffData.BuffBaseId]
    if data then
      data.data.Level = data.data.Level + buffData.Level
      data.data.Layer = data.data.Layer + buffData.Layer
      data.data.BuffUuid = buffData.BuffUuid
      data.data.Duration = data.data.Duration + buffData.Duration
      data.downTime = buffData.CreateTime + buffData.Duration
    else
      data = {
        data = buffData,
        downTime = buffData.CreateTime + buffData.Duration
      }
      self.StatisBuffTablse[buffData.FireUuid].data[buffData.BuffBaseId] = data
    end
  else
    self.StatisBuffTablse[buffData.FireUuid] = {
      data = {
        [buffData.BuffBaseId] = {
          data = buffData,
          downTime = buffData.CreateTime + buffData.Duration
        }
      }
    }
  end
end

function DmgData:GetEBuffData(fireUuid)
  if fireUuid == Lang("DamageSelfTxt") then
    fireUuid = self.PlayerUuid
  end
  fireUuid = tonumber(fireUuid)
  if self.StatisBuffTablse[fireUuid] == nil then
    self.ControlShowBuffData = nil
  else
    local part = self.ControlSelectBuffPartData
    if part == Lang("DamagePartTxt") then
      self.ControlShowBuffData = self.StatisBuffTablse[fireUuid].data
    else
      for key, value in pairs(self.StatisBuffTablse[fireUuid].data) do
        if value.PartId == tonumber(part) then
          table.insert(self.ControlShowBuffData, value)
        end
      end
    end
  end
end

function DmgData:UnInit()
  self:RefreshData()
end

return DmgData
