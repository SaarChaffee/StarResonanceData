local skill_slot_vm = {}

function skill_slot_vm:RegisterEvent()
  Z.EventMgr:Add("OnUIPlayEffect", self.OnUIPlayEffect, self)
  if self.effectList == nil then
    self.effectList = {}
  end
end

function skill_slot_vm:OnUIPlayEffect(skillId, slotId, effectName, isRun)
  local key = slotId
  if skillId and skillId ~= 0 then
    key = skillId
  end
  Z.EventMgr:Dispatch("UIEffectEventFired", skillId, slotId, effectName, isRun)
  if isRun == false then
    self:RemoveEffectInfo(key, effectName)
  else
    self:AddEffectInfo(key, effectName)
  end
end

function skill_slot_vm:AddEffectInfo(key, effectName)
  if self.effectList[key] == nil then
    self.effectList[key] = {}
  end
  table.insert(self.effectList[key], effectName)
end

function skill_slot_vm:RemoveEffectInfo(key, effectName)
  if self.effectList == nil then
    return
  end
  if self.effectList[key] == nil then
    return
  end
  for i = 1, #self.effectList[key] do
    if self.effectList[key][i] == effectName then
      self.effectList[key][i] = nil
      break
    end
  end
end

function skill_slot_vm:GetSlotEffects(skillId, slotId)
  if self.effectList == nil then
    return nil
  end
  if self.effectList[skillId] ~= nil then
    return self.effectList[skillId]
  end
  if self.effectList[slotId] ~= nil then
    return self.effectList[slotId]
  end
  return nil
end

function skill_slot_vm:GetComboSkillCount(comboStarSkillId, curskillId)
  local count = 1
  local skillIdx = 0
  local row = Z.TableMgr.GetTable("SkillTableMgr").GetRow(comboStarSkillId)
  if row then
    while tonumber(row.NextSkillId) ~= 0 do
      if row.NextSkillId ~= "" then
        count = count + 1
        if row.NextSkillId == curskillId then
          skillIdx = count - 1
        end
        row = Z.TableMgr.GetTable("SkillTableMgr").GetRow(row.NextSkillId)
        if row == nil then
          do return end
          else
            break
          end
        end
    end
  end
  return count - skillIdx
end

return skill_slot_vm
