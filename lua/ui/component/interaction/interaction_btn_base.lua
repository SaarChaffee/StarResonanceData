local InteractionBtnBase = class("InteractionBtnBase")
local interactMgr = Panda.ZGame.ZInteractionMgr.Instance

function InteractionBtnBase:ctor()
  self.interactionBtnParentType_ = E.InteractionBtnParentType.LayoutContent
  self.triggerData_ = ""
  self.unitName_ = ""
  self.sortId_ = 1
  self.unitContentStr_ = ""
  self.unitIcon_ = nil
  self.attrId_ = 0
  self.btnClick_ = nil
  self.interactionCfgId = 0
  self.templateId_ = 0
  self.replaceBtnId_ = 0
  self.addTime_ = 0
  self.conditionMet = nil
  self.inited = false
  self.vm_ = Z.VMMgr.GetVM("interaction")
end

function InteractionBtnBase:AsyncInit(uiData, btnType)
  self.inited = true
  self.uuid_ = uiData.uuid
  self.templateId_ = uiData.templateId
  self.interactionCfgId_ = uiData.interactionCfgId
  self.replaceBtnId_ = uiData.btnId
  self.interactionBtnType_ = btnType
  self:AsyncSetData()
end

function InteractionBtnBase:UnInit()
  self.inited = false
end

function InteractionBtnBase:AsyncSetData()
  local intercfg = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(self.templateId_)
  if intercfg == nil then
    logError("intercfg not found, templateId={0}, interactionCfgId={1}", self.templateId_, self.interactionCfgId_)
    return
  end
  local btnId = self.replaceBtnId_
  local interBtnCfg = Z.TableMgr.GetTable("InteractBtnTableMgr").GetRow(btnId)
  if interBtnCfg == nil then
    logError("interBtnCfg not found, templateId={0}, interactionCfgId={1}", self.templateId_, self.interactionCfgId_)
    return
  end
  local defaultName = ""
  self.entityType_ = 0
  self.entityId_ = 0
  self.entityCfgId_ = 0
  local entity = Z.EntityMgr:GetEntity(self.uuid_)
  if entity ~= nil then
    defaultName = entity:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
    self.entityCfgId_ = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
    self.entityType_ = entity.LuaEntType
    self.entityId_ = entity.EntId
  end
  self.unitContentStr_ = self.vm_.AsyncGetInteractiveName(self.uuid_, btnId, defaultName, self.interactionCfgId_)
  if not self.inited then
    return
  end
  self.unitIcon_ = interBtnCfg.IconPath
  self.unitName_ = self.interactionCfgId_ .. self.uuid_
  self.sortId_ = intercfg.SortId
  self.addTime_ = Time.time
  self.conditionMet = interactMgr:CheckCondition(self.uuid_, self.interactionCfgId_, false)
end

function InteractionBtnBase:CheckBtnShow()
  return true
end

function InteractionBtnBase:OnStateChange()
end

function InteractionBtnBase:ChangeProgress()
end

function InteractionBtnBase:IsCanDelete()
  return true
end

function InteractionBtnBase:CheckCanBtn()
  return true
end

function InteractionBtnBase:OnBtnClick(cancelSource)
  local goalVm = Z.VMMgr.GetVM("goal")
  goalVm.SetGoalFinish(E.GoalType.FinishOperate, self.entityType_, self.entityId_, self.interactionCfgId_)
  if not interactMgr:CheckCondition(self.uuid_, self.interactionCfgId_) then
    return
  end
  Z.AudioMgr:Play("sys_general_interact")
  Z.InteractionMgr:BeginInteraction(self.uuid_, self.interactionCfgId_, self.templateId_)
end

function InteractionBtnBase:ExitState()
end

function InteractionBtnBase:GetUnitName()
  return self.unitName_
end

function InteractionBtnBase:GetContentStr()
  return self.unitContentStr_
end

function InteractionBtnBase:GetIcon()
  return self.unitIcon_
end

function InteractionBtnBase:GetUuid()
  return self.uuid_
end

function InteractionBtnBase:GetTemplateId()
  return self.templateId_
end

function InteractionBtnBase:GetInteractionCfgId()
  return self.interactionCfgId_
end

function InteractionBtnBase:GetInteractionBtnType()
  return self.interactionBtnType_
end

function InteractionBtnBase:GetProgressTime()
  return self.progressTime_
end

function InteractionBtnBase:SetProgressTime(time)
  self.progressTime_ = time
end

function InteractionBtnBase:GetSortId()
  return self.sortId_
end

function InteractionBtnBase:GetAddTime()
  return self.addTime_
end

function InteractionBtnBase:GetReplaceBtnId()
  return self.replaceBtnId_
end

function InteractionBtnBase:GetNew()
  return true
end

function InteractionBtnBase:HasNpcQuestTalk()
  if self.entityCfgId_ == 0 then
    return false
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local talkData = Z.DataMgr.Get("talk_data")
  local questTalkFlowDict = talkData:GetQuestTalkFlowDictByNpcAndScene(self.entityCfgId_, curSceneId)
  if questTalkFlowDict ~= nil and 0 < table.zcount(questTalkFlowDict) then
    return true
  else
    return false
  end
end

function InteractionBtnBase:GetInteractionBtnType()
  return self.interactionBtnType_
end

function InteractionBtnBase:IsCanDelete(triggerData)
  return true
end

function InteractionBtnBase:CheckCondition()
  return self.conditionMet
end

return InteractionBtnBase
