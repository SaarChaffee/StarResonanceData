local interactMgr = Panda.ZGame.ZInteractionMgr.Instance
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local interactionMgr = require("ui.component.interaction.interaction_mgr")
local interactionActionMgr = require("ui.component.interaction.interaction_action")
local interactionData = Z.DataMgr.Get("interaction_data")
local checkHandelData = function(uuid, interactionCfgId)
  local handleDataList = interactionData:GetData()
  for i = 1, #handleDataList do
    if handleDataList[i]:GetNew() and handleDataList[i]:GetUuid() == uuid and handleDataList[i]:GetInteractionCfgId() == interactionCfgId then
      return false
    end
  end
  return true
end
local getInteractiveName = function(uuid, btnId, defaultName, interactionCfgId)
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
      Z.Placeholder.SetHeroNormalDungeonName(holderParam, actionStageData)
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
  if not Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.ActionInteractive) then
    return
  end
  local uuid = uiData.uuid
  local interactionCfgId = uiData.interactionCfgId
  if checkHandelData(uuid, interactionCfgId) == false then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    interactionMgr.InitInteraction(uiData)
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
local doInteractionActionBack = function(isSuccess, uuid, templateId, interactionCfgId, actionType)
  interactionActionMgr.DoInteractionActionBack(isSuccess, uuid, templateId, interactionCfgId, actionType)
end
local refreshSelectOption = function()
  if not Z.IsPCUI then
    return
  end
  local handleDataList = interactionData:GetData()
  for key, value in pairs(handleDataList) do
    local unit = value:GetUnit()
    if unit and unit.cont_key_icon then
      itemHelper.IsShowContKyeIcon(unit, key == 1)
      itemHelper.SetSelectState(unit, key == 1)
    end
  end
end
local deleteInteractionOption = function(uiData)
  if uiData == nil then
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
        Z.EventMgr:Dispatch(Z.ConstValue.RemoveOption, handlerData)
      end
    else
      local triggerData = uiData.triggerData
      if btnType == handlerData:GetInteractionBtnType() and handlerData:IsCanDelete(triggerData) then
        interactionData:DeleteData(i)
        Z.EventMgr:Dispatch(Z.ConstValue.RemoveOption, handlerData)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.DeActiveOption)
  local data = interactionData:GetData()
  interactMgr:SetInteractionCount(#data)
  refreshSelectOption()
end
local deleteInteractionOptionByUnitName = function(unitName)
  Z.EventMgr:Dispatch(Z.ConstValue.DeActiveOptionByName, unitName)
end
local selectInteractionOption = function(selectIndex)
  if not Z.IsPCUI then
    return
  end
  local handleDataList = interactionData:GetData()
  if not handleDataList[selectIndex] then
    return
  end
  for key, value in pairs(handleDataList) do
    local unit = value:GetUnit()
    if unit and unit.cont_key_icon then
      itemHelper.IsShowContKyeIcon(unit, key == selectIndex)
      itemHelper.SetSelectState(unit, key == selectIndex)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SelectInteractionOption, selectIndex)
end
local onPointClickListener = function(index)
  if not Z.IsPCUI then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if stateId ~= Z.PbEnum("EActorState", "ActorStateDefault") and stateId ~= Z.PbEnum("EActorState", "ActorStateSwim") and stateId ~= Z.PbEnum("EActorState", "ActorStatePedalWall") then
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
local ret = {
  OnLogin = onLogin,
  AddInteractionOption = addInteractionOption,
  DeleteInteractionOption = deleteInteractionOption,
  DeleteInteractionOptionByUnitName = deleteInteractionOptionByUnitName,
  DoInteractionAction = doInteractionAction,
  DoInteractionActionEndTrigger = doInteractionActionEndTrigger,
  DoInteractionActionBack = doInteractionActionBack,
  SelectInteractionOption = selectInteractionOption,
  OnPointClickListener = onPointClickListener,
  RefreshSelectOption = refreshSelectOption,
  AsyncUserOptionSelect = asyncUserOptionSelect,
  AsyncInterruptCollect = asyncInterruptCollect,
  AsyncInteractPersonEntity = asyncInteractPersonEntity,
  GetInteractiveName = getInteractiveName
}
return ret
