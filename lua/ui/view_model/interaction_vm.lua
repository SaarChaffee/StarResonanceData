local interactMgr = Panda.ZGame.ZInteractionMgr.Instance
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local interactionMgr = require("ui.component.interaction.interaction_mgr")
local interactionActionMgr = require("ui.component.interaction.interaction_action")
local interactionData = Z.DataMgr.Get("interaction_data")
local asyncgetInteractiveName = function(uuid, btnId, defaultName, interactionCfgId)
  local btnCfg = Z.TableMgr.GetTable("InteractBtnTableMgr").GetRow(btnId)
  if btnCfg == nil then
    return defaultName
  end
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity == nil then
    return btnCfg.Name
  end
  local attrId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local holderParam = {}
  Z.Placeholder.SetNpcPlaceholder(holderParam, attrId)
  Z.Placeholder.SetSceneObjPlaceholder(holderParam, attrId)
  Z.Placeholder.SetCollectPlaceholder(holderParam, attrId)
  Z.Placeholder.SetDungeonValVluew(holderParam)
  if btnCfg.BtnType ~= 0 and btnCfg.BtnType ~= Z.EInteractionBtnType.EBase:ToInt() then
    local actionStageData = interactMgr:GetInteractionActionStageLuaData(uuid, interactionCfgId)
    if btnCfg.BtnType == Z.EInteractionBtnType.EDungeon:ToInt() then
      Z.Placeholder.SetDungeonName(holderParam, actionStageData)
    elseif btnCfg.BtnType == Z.EInteractionBtnType.EHeroNormalDungeon:ToInt() then
      Z.Placeholder.AsyncSetHeroNormalDungeonName(holderParam, actionStageData)
    elseif btnCfg.BtnType == Z.EInteractionBtnType.EHeroChallengeDungeon:ToInt() then
      Z.Placeholder.SetHeroChallengeDungeonName(holderParam, actionStageData)
    end
  end
  holderParam.player = {name = defaultName}
  local content = Z.Placeholder.Placeholder(btnCfg.Name, holderParam)
  return content
end
local addInteractionOption = function(uiData)
  if uiData == nil then
    return
  end
  if not Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.ActionInteractive) then
    return
  end
  local uuid = uiData.uuid
  local interactionCfgId = uiData.interactionCfgId
  if interactionData:HasData(uuid, interactionCfgId) then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    interactionMgr.AsyncInitInteraction(uiData)
    local data = interactionData:GetData()
    if data then
      interactMgr:SetInteractionCount(#data)
    end
  end)()
end
local doInteractionAction = function(uuid, interactionCfgId, templateId, actionData)
  interactionActionMgr.DoInteractionAction(uuid, interactionCfgId, templateId, actionData)
end
local doInteractionActionEndTrigger = function(uuid, interactionCfgId, templateId, actionData)
  interactionActionMgr.DoInteractionEndTriggerAction(uuid, interactionCfgId, templateId, actionData)
end
local doInteractionActionAbort = function(uuid, interactionCfgId, templateId, actionData)
  interactionActionMgr.DoInteractionActionAbort(uuid, interactionCfgId, templateId, actionData)
  local talkVM = Z.VMMgr.GetVM("talk")
  talkVM.StopWaitNpcTalkState(uuid)
end
local doInteractionActionEnd = function(uuid, interactionCfgId, templateId, actionData)
  interactionActionMgr.DoInteractionActionEnd(uuid, interactionCfgId, templateId, actionData)
  local talkVM = Z.VMMgr.GetVM("talk")
  talkVM.StopWaitNpcTalkState(uuid)
end
local doInteractionActionBack = function(isSuccess, uuid, templateId, interactionCfgId, actionType)
  interactionActionMgr.DoInteractionActionBack(isSuccess, uuid, templateId, interactionCfgId, actionType)
end
local deleteInteractionOption = function(uiData)
  if uiData == nil then
    logError("deleteInteractionOption uiData is nil")
    return
  end
  local uuid = uiData.uuid
  local interactionCfgId = uiData.interactionCfgId
  local btnType = uiData.btnType
  local handleDataList = interactionData:GetData()
  for i = #handleDataList, 1, -1 do
    local handlerData = handleDataList[i]
    if handlerData:GetNew() then
      if uuid == handlerData:GetUuid() and interactionCfgId == handlerData:GetInteractionCfgId() then
        interactionData:DeleteData(i)
      end
    else
      local triggerData = uiData.triggerData
      if btnType == handlerData:GetInteractionBtnType() and handlerData:IsCanDelete(triggerData) then
        interactionData:DeleteData(i)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.DeActiveOption)
  local data = interactionData:GetData()
  interactMgr:SetInteractionCount(#data)
end
local interactionUIProgressBegin = function(uiData)
  if uiData == nil then
    return
  end
  local uuid = uiData.uuid
  local duration = uiData.duration
  local btnDataList = interactionData:GetData()
  for i = #btnDataList, 1, -1 do
    local btnData = btnDataList[i]
    if btnData:GetUuid() == uuid and btnData:GetInteractionCfgId() == uiData.interactionCfgId then
      btnData:SetProgressTime(duration)
      Z.EventMgr:Dispatch(Z.ConstValue.InteractionProgressBegin, btnData)
    end
  end
end
local interactionUIProgressEnd = function(uiData)
  if uiData == nil then
    return
  end
  local uuid = uiData.uuid
  local btnDataList = interactionData:GetData()
  for i = #btnDataList, 1, -1 do
    local btnData = btnDataList[i]
    if btnData:GetUuid() == uuid and btnData:GetInteractionCfgId() == uiData.interactionCfgId then
      btnData:SetProgressTime(0)
      Z.EventMgr:Dispatch(Z.ConstValue.InteractionProgressEnd, btnData)
    end
  end
end
local selectInteractionOption = function(selectIndex)
  if not Z.IsPCUI then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SelectInteractionOption, selectIndex)
end
local onPointClickListener = function(index)
  if not Z.IsPCUI then
    return
  end
  local handleDataList = interactionData:GetData()
  if not handleDataList[index] then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.PointClickOption, index)
end
local onLogin = function()
end
local asyncUserOptionSelect = function(str, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.UserDoAction(str, cancelToken)
  Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnOptionSelect, str)
end
local asyncInterruptCollect = function(interruptType, token)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ClientBreakState(interruptType, token)
  Z.TipsVM.ShowTips(ret)
end
local asyncInteractPersonEntity = function(uuid, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.PersonalObjectAction(uuid, cancelToken)
  Z.TipsVM.ShowTips(ret)
end
local openInteractionSkipView = function()
  Z.UIMgr:OpenView("interaction_skip_window")
end
local closeInteractionSkipView = function()
  Z.UIMgr:CloseView("interaction_skip_window")
end
local checkHasInterationDataByUidAndEntType = function(uid, entType)
  local entityVM = Z.VMMgr.GetVM("entity")
  local handleDataList = interactionData:GetData()
  for i = 1, #handleDataList do
    if handleDataList[i]:GetNew() then
      local dataUid = entityVM.UuidToEntId(handleDataList[i]:GetUuid())
      local dataEntType = entityVM.UuidToEntType(handleDataList[i]:GetUuid())
      if dataUid == uid and dataEntType == entType then
        return true
      end
    end
  end
  return false
end
local ret = {
  OnLogin = onLogin,
  AddInteractionOption = addInteractionOption,
  DeleteInteractionOption = deleteInteractionOption,
  DoInteractionAction = doInteractionAction,
  DoInteractionActionEndTrigger = doInteractionActionEndTrigger,
  DoInteractionActionAbort = doInteractionActionAbort,
  DoInteractionActionEnd = doInteractionActionEnd,
  DoInteractionActionBack = doInteractionActionBack,
  SelectInteractionOption = selectInteractionOption,
  OnPointClickListener = onPointClickListener,
  InteractionUIProgressBegin = interactionUIProgressBegin,
  InteractionUIProgressEnd = interactionUIProgressEnd,
  AsyncUserOptionSelect = asyncUserOptionSelect,
  AsyncInterruptCollect = asyncInterruptCollect,
  AsyncInteractPersonEntity = asyncInteractPersonEntity,
  AsyncGetInteractiveName = asyncgetInteractiveName,
  OpenInteractionSkipView = openInteractionSkipView,
  CloseInteractionSkipView = closeInteractionSkipView,
  CheckHasInterationDataByUidAndEntType = checkHasInterationDataByUidAndEntType
}
return ret
