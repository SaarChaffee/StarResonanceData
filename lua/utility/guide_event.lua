local GuideEventSystem = {}
local isInit = false

function GuideEventSystem:Init()
  function self.onChangeWeaponWatcher_(container, dirtys)
    self:onChangeWeaponEvent(container, dirtys)
  end
  
  function self.onUnLockFunctionWatcher_(functionTabs)
    self:onUnLockFunctionEvent(functionTabs)
  end
  
  local weaponList = Z.ContainerMgr.CharSerialize.professionList
  if weaponList then
    weaponList.Watcher:RegWatcher(self.onChangeWeaponWatcher_)
  end
  
  function self.onInputAction_(inputActionData)
    Z.GuideMgr:onRemoveEvent(E.SteerType.AtWillOperation)
  end
  
  function self.equipListChangeFunc_(container, dirtys)
    self:changeEquipEvent(container, dirtys)
  end
  
  Z.ContainerMgr.CharSerialize.equip.Watcher:RegWatcher(self.equipListChangeFunc_)
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed)
  Z.EventMgr:Add(Z.ConstValue.UIOpen, self.onOpenViewEvent, self)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnFinishCutscene, self.OnEndCutsceneEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.OnEnterSceneEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.OnAddItemEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.InsertItem, self.OnAddItemEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.Accept, self.onQuestOrStepStart, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.Finish, self.onQuestOrStepFinish, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepStart, self.onQuestOrStepStart, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepFinish, self.onQuestOrStepFinish, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnStopEPFlow, self.onStopEPFlow, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnTriggerEvent, self.onTriggerEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnClickChangeGuideQuestId, self.onActiveTaskGuideEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnPlayCutscene, self.onPlayCutsceneEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnClickAllArea, self.OnClickAlllAreaEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnResonancEnvironment, self.OnResonancEnvironmentEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnGuideEvnet, self.onGuideEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnFinishGuideEvent, self.finishGuide, self)
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnFashionWearChange, self.onEntityFashionChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.UseItem, self.onUseItemEvent, self)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onUnLockFunctionWatcher_)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.onRoleLevelUpEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  self.onItemChange()
  isInit = true
end

function GuideEventSystem:UnInit()
  if self.onChangeWeaponWatcher_ then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onChangeWeaponWatcher_)
    self.onChangeWeaponWatcher_ = nil
  end
  if self.onUnLockFunctionWatcher_ then
    Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onUnLockFunctionWatcher_)
    self.onChangeWeaponWatcher_ = nil
  end
  if self.equipListChangeFunc_ then
    Z.ContainerMgr.CharSerialize.equip.Watcher:UnregWatcher(self.equipListChangeFunc_)
    self.equipListChangeFunc_ = nil
  end
  if self.onItemPackageChangedWatcher_ then
    local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Item]
    if package then
      package.Watcher:UnregWatcher()
    end
    self.onItemPackageChangedWatcher_ = nil
  end
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed)
  Z.EventMgr:RemoveObjAll(self)
  isInit = false
end

function GuideEventSystem:onFashionAttrChange(type, wearList)
  Z.GuideMgr:RefreshGuideView()
end

function GuideEventSystem:finishGuide(guideIds)
  Z.GuideMgr:RemoveNowGuide(guideIds)
  Z.GuideMgr:RefreshGuideView()
end

function GuideEventSystem:onOpenViewEvent(viewConfigKey)
  if not isInit then
    return
  end
  if Z.UIConfig[viewConfigKey] and Z.UIConfig[viewConfigKey].IsRefreshSteer ~= false then
    Z.GuideMgr:onRemoveEvent(E.SteerType.OpenUi, viewConfigKey)
    Z.GuideMgr:onChangeEvent(E.SteerType.OpenUi, viewConfigKey)
  end
end

function GuideEventSystem:onTriggerEvent(guideList)
  Z.GuideMgr:OnChangeIdList(E.SteerType.Trigger, guideList)
end

function GuideEventSystem:onInputEvent(inputType, param)
  Z.GuideMgr:onRemoveEvent(E.SteerType.InputEvent, inputType)
  Z.GuideMgr:onChangeEvent(E.SteerType.InputEvent, inputType)
end

function GuideEventSystem:onGuideEvent(param)
  Z.GuideMgr:onRemoveEvent(E.SteerType.GuideEvent, param)
  Z.GuideMgr:onChangeEvent(E.SteerType.GuideEvent, param)
end

function GuideEventSystem:changeEquipEvent(container, dirtys)
  Z.GuideMgr:onRemoveEvent(E.SteerType.AlreadyPutEquip, 0)
end

function GuideEventSystem:onItemPackageEvent(container, dirtys)
  local items = dirtys.items
  if items == nil then
    return
  end
  for k, v in pairs(items) do
    if v:IsNew() then
      Z.GuideMgr:onChangeEvent(E.SteerType.BagItem, k)
      return
    end
  end
end

function GuideEventSystem:onItemChange()
  Z.GuideMgr:onChangeEvent(E.SteerType.BagItem, 0)
end

function GuideEventSystem:onUnLockFunctionEvent(functionTabs)
  for functionId, isUnlock in pairs(functionTabs) do
    if isUnlock then
      Z.GuideMgr:onChangeEvent(E.SteerType.UnLockFunction, functionId)
      Z.GuideMgr:onRemoveEvent(E.SteerType.UnLockFunction, functionId)
    end
  end
end

function GuideEventSystem:onCloseViewEvent(viewConfigKey)
  if not isInit then
    return
  end
  if Z.UIConfig[viewConfigKey] and Z.UIConfig[viewConfigKey].IsRefreshSteer ~= false then
    Z.GuideMgr:OnQuiteUiView(viewConfigKey)
    Z.GuideMgr:onRemoveEvent(E.SteerType.CloseUi, viewConfigKey)
    Z.GuideMgr:onChangeEvent(E.SteerType.CloseUi, viewConfigKey)
  end
end

function GuideEventSystem:OnAddItemEvent(itemData)
  Z.GuideMgr:onChangeEvent(E.SteerType.ReceiveItem, itemData.configId)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", itemData.configId)
  if itemRow then
    Z.GuideMgr:onChangeEvent(E.SteerType.ReceiveItemType, itemRow.Type)
  end
  self.onItemChange(itemData)
end

function GuideEventSystem:OnEnterSceneEvent(dungeonId)
  Z.GuideMgr:onChangeEvent(E.SteerType.EnterScene, dungeonId)
end

function GuideEventSystem:onQuestOrStepStart(questIdOrStepId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.AcceptQuest, questIdOrStepId)
  Z.GuideMgr:onChangeEvent(E.SteerType.AcceptQuest, questIdOrStepId)
end

function GuideEventSystem:onQuestOrStepFinish(questIdOrStepId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.FinishQuest, questIdOrStepId)
  Z.GuideMgr:onChangeEvent(E.SteerType.FinishQuest, questIdOrStepId)
end

function GuideEventSystem:OnEndCutsceneEvent(cutsceneId)
  Z.GuideMgr:onChangeEvent(E.SteerType.EndCutscene, cutsceneId)
end

function GuideEventSystem:onStopEPFlow(flowId)
  Z.GuideMgr:onChangeEvent(E.SteerType.StopEPFlow, flowId)
end

function GuideEventSystem:onPlayCutsceneEvent(cutsceneId)
  Z.GuideMgr:onChangeEvent(E.SteerType.PlayCutscene, cutsceneId)
end

function GuideEventSystem:onEntityFashionChange(fashionId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.OnSelectFashion, fashionId)
end

function GuideEventSystem:onUseItemEvent(itemId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.UseItem, itemId)
  Z.GuideMgr:onChangeEvent(E.SteerType.UseItem, itemId)
end

function GuideEventSystem:onRoleLevelUpEvent(level)
  Z.GuideMgr:onRemoveEvent(E.SteerType.Rolelevel, level)
  Z.GuideMgr:onChangeEvent(E.SteerType.Rolelevel, level)
end

function GuideEventSystem:onChangeWeaponEvent(container, dirtys)
  if not dirtys.curProfessionId then
    return
  end
  local weaponId = dirtys.curProfessionId:Get()
  Z.GuideMgr:onRemoveEvent(E.SteerType.ChangeWeapon, weaponId)
end

function GuideEventSystem:onResonanceWeaponEvent(weaponId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.ResonanceWeapon, weaponId)
end

function GuideEventSystem:onPutOnEquipEvent(equipId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.PutOnEquip, equipId)
end

function GuideEventSystem:onServerGuideEvent(guideId)
end

function GuideEventSystem:onActiveTaskGuideEvent(taskId)
  Z.GuideMgr:onRemoveEvent(E.SteerType.ActiveTaskGuide, taskId)
end

function GuideEventSystem:OnClickAlllAreaEvent()
  Z.GuideMgr:onRemoveEvent(E.SteerType.OnClickAllArea, "")
end

function GuideEventSystem:OnResonancEnvironmentEvent(isShowRed)
  local type = 0
  type = isShowRed and 3 or 0
  Z.GuideMgr:onRemoveEvent(E.SteerType.ResonancEnvironment, type)
end

function GuideEventSystem:AddInputEvent(data)
  for _, guideData in ipairs(data.finishParms) do
    if guideData.tp == E.SteerType.InputEvent then
      local parmType = type(guideData.parm)
      if parmType == "string" then
        local parmTab = string.split(guideData.parm, "=")
        Z.SteerMgr:OnRegEventByTypeId(tonumber(parmTab[1]))
      else
        Z.SteerMgr:OnRegEventByTypeId(tonumber(guideData.parm))
      end
    end
  end
end

function GuideEventSystem:RemoveInputEvent(data)
  for _, guideData in ipairs(data.finishParms) do
    if guideData.tp == E.SteerType.InputEvent then
      local parmType = type(guideData.parm)
      if parmType == "string" then
        local parmTab = string.split(guideData.parm, "=")
        Z.SteerMgr:OnUnregEventByTypeId(tonumber(parmTab[1]))
      else
        Z.SteerMgr:OnUnregEventByTypeId(tonumber(guideData.parm))
      end
      Z.GuideMgr:CheckIsAddInputEvent()
    end
  end
  for _, guideData in ipairs(data.triggerParms) do
    if guideData.tp == E.SteerType.InputEvent and self.inputEventTab_[guideData.parm] then
      local parmType = type(guideData.parm)
      if parmType == "string" then
        local parmTab = string.split(guideData.parm, "=")
        Z.SteerMgr:OnUnregEventByTypeId(tonumber(parmTab[1]))
      else
        Z.SteerMgr:OnUnregEventByTypeId(tonumber(guideData.parm))
      end
      Z.GuideMgr:CheckIsAddInputEvent()
    end
  end
end

return GuideEventSystem
