local GuideManager = class("GuideManager")
local worldProxy = require("zproxy.world_proxy")
local refreshGuideType = {
  [E.SteerType.OpenUi] = 1,
  [E.SteerType.EnterScene] = 2,
  [E.SteerType.CloseUi] = 3,
  [E.SteerType.PlayCutscene] = 4
}
local ShowType = {
  All = 0,
  Pc = 1,
  Mobile = 2
}
local GuideEventSystem = require("utility.guide_event")
local GuideCondition = require("utility.guide_condition")
local notOpenSteerViewByViewConfigKeys = {
  "steer_helpsy_window",
  "helpsys_window",
  "helpsys_popup02",
  "helpsys_popup01",
  "talk_info_window",
  "battle_pass_purchase_level"
}

function GuideManager:setLoadItemSteerData()
  self.loadItemSteerDic_ = {}
  for key, guideCfgData in pairs(self.notActiveGuideTab_) do
    local type = tonumber(guideCfgData.data.DynamicUI[1])
    if type then
      local parm = table.concat(guideCfgData.data.DynamicUI, "=", 2)
      parm = tonumber(parm) or parm
      if self.loadItemSteerDic_[type] == nil then
        self.loadItemSteerDic_[type] = {}
      end
      if self.loadItemSteerDic_[type][parm] == nil then
        self.loadItemSteerDic_[type][parm] = {}
      end
      table.insert(self.loadItemSteerDic_[type][parm], guideCfgData.data.Id)
    end
  end
end

function GuideManager:GetLoadSteerIdByTypeAndParm(type, param)
  if self.loadItemSteerDic_ and self.loadItemSteerDic_[type] then
    return self.loadItemSteerDic_[type][param] or {}
  end
  return {}
end

function GuideManager:SetSteerId(steerWidget, type, parm)
  if steerWidget and steerWidget.Steer then
    steerWidget.Steer:ClearSteerList()
    local steerIds = self:GetLoadSteerIdByTypeAndParm(type, parm)
    for index, steerId in ipairs(steerIds) do
      if steerId then
        steerWidget.Steer:OnAddSteerId(steerId)
      end
    end
  end
end

function GuideManager:SetSteerIdByComp(steerComp, type, parm)
  if steerComp then
    steerComp:ClearSteerList()
    local steerIds = self:GetLoadSteerIdByTypeAndParm(type, parm)
    for index, steerId in ipairs(steerIds) do
      if steerId then
        steerComp:OnAddSteerId(steerId)
      end
    end
  end
end

function GuideManager:ctor()
  self.isInitFinish_ = false
  self.blockSteerMap_ = {}
end

function GuideManager:OpenView()
  if self:IsBlocked() then
    self:CloseView()
    return
  end
  if table.zcount(self.nowGuideData_) == 0 then
    self:CloseView()
    return
  end
  for index, value in pairs(self.nowGuideData_) do
    if 0 < value.data.ShowHelplibraryId then
      local helpVm = Z.VMMgr.GetVM("helpsys")
      self:RemoveNowGuide({
        value.data.Id
      })
      local guideAutoShowHelplibrary = Z.Global.GuideAutoShowHelplibrary
      local isOpenSteerHelpsView = false
      for index, helpId in ipairs(guideAutoShowHelplibrary) do
        if helpId == value.data.Id then
          isOpenSteerHelpsView = true
          helpVm.OpenSteerHelpsyView(value.data.ShowHelplibraryId)
          break
        end
      end
      if isOpenSteerHelpsView == false then
        helpVm.CheckAndShowView(value.data.ShowHelplibraryId)
      end
    end
  end
  for key, viewConfigKey in pairs(notOpenSteerViewByViewConfigKeys) do
    if Z.UIMgr:IsActive(viewConfigKey) then
      self:CloseView()
      return
    end
  end
  Z.UIMgr:OpenView("steer_tips_window", self.nowGuideData_)
end

function GuideManager:IsBlocked()
  return next(self.blockSteerMap_) ~= nil
end

function GuideManager:SetBlockSteer(blockSteerType, blockState)
  if blockState then
    self.blockSteerMap_[blockSteerType] = true
  else
    self.blockSteerMap_[blockSteerType] = nil
  end
  self:RefreshGuideView()
end

function GuideManager:CloseView()
  if Z.UIMgr:IsActive("steer_tips_window") then
    Z.UIMgr:CloseView("steer_tips_window")
  end
end

function GuideManager:RefreshGuideView()
  if self.activeGuideTab_ == nil then
    return
  end
  if table.zcount(self.activeGuideTab_) == 0 then
    self:CloseView()
    return
  end
  self:setNowShowGuide()
  self:OpenView()
end

function GuideManager:Clear()
  if self.isInitFinish_ == false then
    return
  end
  self.isInitFinish_ = false
  if self.cancelSource then
    self.cancelSource:Recycle()
    self.cancelSource = nil
  end
  if self.timerMgr then
    self.timerMgr:Clear()
  end
  for timerId, value in pairs(self.timerIds_) do
    Z.DIServiceMgr.ZCfgTimerService:UnRegisterTimerAction(timerId, value)
  end
  GuideEventSystem:UnInit()
end

function GuideManager:InitCfgData()
  local guideCfgDatas = Z.TableMgr.GetTable("GuideTableMgr").GetDatas()
  local completedGuide = Z.ContainerMgr.CharSerialize.help.completedGuide
  for _, guideCfgData in pairs(guideCfgDatas) do
    if not completedGuide[guideCfgData.Id] then
      table.insert(self.notActiveGuideTab_, self:getGuideDataByCfgData(guideCfgData))
    end
  end
  if table.zcount(self.notActiveGuideTab_) > 0 then
    self:setLoadItemSteerData()
    GuideEventSystem:Init()
    self:CheckIsAddInputEvent()
  end
end

function GuideManager:InitGuideData()
  if self.isInitFinish_ == true then
    return
  end
  self.guideCountDownTimes_ = {}
  self.activeGuideTab_ = {}
  self.notActiveGuideTab_ = {}
  self.nowGuideData_ = {}
  self.nowShowGuideIdDic_ = {}
  self.inputEventTab_ = {}
  self.guideTimeTab_ = {}
  self.timerIds_ = {}
  self.timerMgr = Z.TimerMgr.new()
  self.cancelSource = Z.CancelSource.Rent()
  self:InitCfgData()
  self.isInitFinish_ = true
  self:addTimeEvent()
end

function GuideManager:timeEvent(timerId, state, offestIndex)
  if state == E.TimerExeType.CycleStart or state == E.TimerExeType.Start then
    GuideManager:onChangeEvent(E.SteerType.Timer, timerId)
  else
    GuideManager:onRemoveEvent(E.SteerType.Timer, timerId)
  end
end

function GuideManager:addTimeEvent()
  for timerId, value in pairs(self.timerIds_) do
    self.timerIds_[timerId] = function(state, offestIndex)
      GuideManager:timeEvent(timerId, state, offestIndex)
    end
    Z.DIServiceMgr.ZCfgTimerService:RegisterTimerAction(timerId, self.timerIds_[timerId])
  end
end

function GuideManager:stopTime(guideId)
  if self.guideTimeTab_[guideId] then
    self.timerMgr:StopTimer(self.guideTimeTab_[guideId])
    self.guideTimeTab_[guideId] = nil
  end
end

function GuideManager:StartTime(guideId)
  if self.nowGuideData_[guideId] == nil or self.nowGuideData_[guideId].data == nil then
    return
  end
  if self.nowGuideData_[guideId].data.CompletionConditionValue == "" and self.nowGuideData_[guideId].data.CompletionConditionType == "" and self.nowGuideData_[guideId].data.AutoCompleteTime == 0 then
    logError("\230\156\170\233\133\141\231\189\174\229\174\140\230\136\144\230\157\161\228\187\182\229\146\140\230\140\129\231\187\173\229\128\146\232\174\161\230\151\182")
  end
  if self.guideTimeTab_[guideId] then
    return
  end
  if self.nowGuideData_[guideId].data.AutoCompleteTime > 0 then
    self.guideCountDownTimes_[guideId] = self.nowGuideData_[guideId].data.AutoCompleteTime
    self.guideTimeTab_[guideId] = self.timerMgr:StartTimer(function()
      self.guideCountDownTimes_[guideId] = self.guideCountDownTimes_[guideId] - 1
      if self.guideCountDownTimes_[guideId] <= 0 then
        self:finishGuide({guideId})
        self.guideTimeTab_[guideId] = nil
      end
    end, 1, self.nowGuideData_[guideId].data.AutoCompleteTime)
  end
end

function GuideManager:GetCountDownByGuideId(guideId)
  if self.guideCountDownTimes_[guideId] and self.guideCountDownTimes_[guideId] > 0 then
    return self.guideCountDownTimes_[guideId]
  end
end

function GuideManager:CheckIsAddInputEvent()
  for _, guideData in ipairs(self.notActiveGuideTab_) do
    for i = 1, #guideData.triggerParms do
      local trigger = guideData.triggerParms[i]
      if trigger.tp == E.SteerType.InputEvent then
        local parm = trigger.parm
        if parm then
          local parmType = type(parm)
          if parmType == "string" then
            local parmTab = string.split(parm, "=")
            Z.SteerMgr:OnRegEventByTypeId(tonumber(parmTab[1]))
          else
            Z.SteerMgr:OnRegEventByTypeId(tonumber(parm))
          end
        end
      end
    end
  end
end

function GuideManager:AddNowShowGuideId(steerId)
  self.nowShowGuideIdDic_[steerId] = true
end

function GuideManager:RemoveNowShowGuideId(steerId)
  if self.nowShowGuideIdDic_[steerId] then
    self.nowShowGuideIdDic_[steerId] = nil
  end
end

function GuideManager:ClearNowShowGuideId()
  self.nowShowGuideIdDic_ = {}
end

function GuideManager:setNowShowGuide()
  self.nowGuideData_ = {}
  for _, guideData in ipairs(self.activeGuideTab_) do
    local isShow = true
    for index, parms in ipairs(guideData.showParms) do
      isShow = GuideCondition["GuideCondition" .. parms.tp](parms)
      if isShow == false then
        break
      end
    end
    self.nowGuideData_[guideData.data.Id] = guideData
    guideData.isShow = isShow
  end
end

function GuideManager:IsGuideShow(guideId)
  return self.nowGuideData_[guideId] ~= nil
end

function GuideManager:OnChangeIdList(eventType, ...)
  local isRefresh = false
  local platformType = Z.IsPCUI and ShowType.Pc or ShowType.Mobile
  for key, guideId in pairs((...)) do
    for i = #self.notActiveGuideTab_, 1, -1 do
      local isActive = false
      local guiData = self.notActiveGuideTab_[i].data
      if guiData.Id == guideId then
        if guiData.Pcchoice == ShowType.All then
          isActive = true
        elseif guiData.Pcchoice == platformType then
          isActive = true
        end
        if isActive then
          isRefresh = true
          table.insert(self.activeGuideTab_, self.notActiveGuideTab_[i])
          table.remove(self.notActiveGuideTab_, i)
        end
      end
    end
  end
  if refreshGuideType[eventType] then
    isRefresh = true
  end
  if isRefresh then
    self:RefreshGuideView()
  end
end

function GuideManager:onChangeEvent(eventType, ...)
  local paramType = type(...)
  local isRefresh = false
  local platformType = Z.IsPCUI and ShowType.Pc or ShowType.Mobile
  if paramType == "table" then
    self:OnChangeIdList(eventType, ...)
  else
    for i = #self.notActiveGuideTab_, 1, -1 do
      local trigger = self.notActiveGuideTab_[i].triggerParms
      local guiData = self.notActiveGuideTab_[i].data
      local isActive = false
      if guiData.Pcchoice == ShowType.All then
        isActive = true
      elseif guiData.Pcchoice == platformType then
        isActive = true
      end
      if isActive then
        for j = 1, #trigger do
          if trigger[j].tp == eventType then
            local value
            if paramType == "string" then
              value = tostring(trigger[j].parm)
            elseif paramType == "number" then
              value = tonumber(trigger[j].parm)
            end
            local state = false
            if eventType == E.SteerType.BagItem then
              state = GuideCondition["GuideCondition" .. eventType](value)
            end
            if value == (...) or state then
              isRefresh = true
              table.insert(self.activeGuideTab_, self.notActiveGuideTab_[i])
              table.remove(self.notActiveGuideTab_, i)
              break
            end
          end
        end
      end
    end
    if refreshGuideType[eventType] then
      isRefresh = true
    end
    if isRefresh then
      self:RefreshGuideView()
    end
  end
end

function GuideManager:OnQuiteUiView(viewKey)
  local groupIds = {}
  for i = #self.activeGuideTab_, 1, -1 do
    local data = self.activeGuideTab_[i].data
    if data.IfShowcheck and viewKey == data.ShowConditionValue then
      groupIds[data.GuideGroup] = true
    end
  end
  for index, value in pairs(groupIds) do
    self:RemoveByGroupId(index)
  end
end

function GuideManager:onRemoveEvent(eventType, param)
  local guideIds = {}
  for index, guideInfoData in pairs(self.nowGuideData_) do
    if guideInfoData.data then
      local finish = guideInfoData.finishParms
      for __, finishData in ipairs(finish) do
        if finishData.tp == eventType then
          local paramType = type(param)
          local value
          if paramType == "string" then
            value = tostring(finishData.parm) or ""
          elseif paramType == "number" then
            value = (finishData.parm == "" or finishData.parm == nil) and 0 or tonumber(finishData.parm) or -1
          end
          local state = false
          if eventType == E.SteerType.AlreadyPutEquip then
            state = GuideCondition["GuideCondition" .. eventType](value)
          end
          if value == param or value == "" or value == 0 or state then
            table.insert(guideIds, guideInfoData.data.Id)
            break
          end
        end
      end
    end
  end
  if 0 < #guideIds and self:RemoveNowGuide(guideIds) then
    self:RefreshGuideView()
  end
end

function GuideManager:RemoveNowGuide(guideIds)
  local removeSteerIdList = {}
  for index, guideId in ipairs(guideIds) do
    if self.nowGuideData_[guideId] then
      for i = #self.activeGuideTab_, 1, -1 do
        local data = self.activeGuideTab_[i].data
        if data.Id == guideId then
          local isRemove = false
          if data.CheckCompletion and tonumber(data.CompletionConditionType) ~= E.SteerType.OnClickAllArea then
            if self.nowShowGuideIdDic_[guideId] then
              isRemove = true
            end
          else
            isRemove = true
          end
          if isRemove then
            Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnSaveCompletedGuide, guideId)
            Z.GuideEventMgr:RemoveInputEvent(self.activeGuideTab_[i])
            table.remove(self.activeGuideTab_, i)
            Z.SteerMgr:RemoveSteerById(guideId)
            self:saveCompletedGuide(guideId)
            self:stopTime(guideId)
            local helpsysData = Z.DataMgr.Get("helpsys_data")
            helpsysData:UnlockHelpsys(tonumber(guideId))
            table.insert(removeSteerIdList, guideId)
          end
        end
      end
    end
  end
  for index, removeId in ipairs(removeSteerIdList) do
    self:onRemoveEvent(E.SteerType.OnFinishSteer, removeId)
    self:onChangeEvent(E.SteerType.OnFinishSteer, removeId)
  end
  local isRemove = 0 < #removeSteerIdList
  if isRemove then
    self.nowGuideData_ = {}
  end
  return isRemove
end

function GuideManager:saveCompletedGuide(guideId)
  Z.CoroUtil.create_coro_xpcall(function()
    worldProxy.SaveCompletedGuide(guideId, self.cancelSource:CreateToken())
  end)()
end

function GuideManager:RemoveByGroupId(groupId)
  for i = #self.notActiveGuideTab_, 1, -1 do
    local guideData = self.notActiveGuideTab_[i]
    if guideData.data.GuideGroup == groupId then
      self:saveCompletedGuide(guideData.data.Id)
      table.remove(self.notActiveGuideTab_, i)
    end
  end
  for i = #self.activeGuideTab_, 1, -1 do
    local guideData = self.activeGuideTab_[i]
    if guideData.data.GuideGroup == groupId then
      self:saveCompletedGuide(guideData.data.Id)
      table.remove(self.activeGuideTab_, i)
    end
  end
  self.nowGuideData_ = {}
  self:RefreshGuideView()
end

function GuideManager:finishGuide(guideIds)
  self:RemoveNowGuide(guideIds)
  self:RefreshGuideView()
end

function GuideManager:showGuide(guideId)
  local guideCfgData = Z.TableMgr.GetTable("GuideTableMgr").GetRow(guideId)
  if guideCfgData then
    table.insert(self.activeGuideTab_, self:getGuideDataByCfgData(guideCfgData))
    self:RefreshGuideView()
  end
end

function GuideManager:getGuideDataByCfgData(guideCfgData)
  local guideData = {}
  guideData.data = guideCfgData
  guideData.triggerParms = {}
  guideData.finishParms = {}
  guideData.showParms = {}
  for index, type in ipairs(guideCfgData.ShowConditionType) do
    local parmTab = {}
    parmTab.tp = type
    local parm = string.split(guideCfgData.ShowConditionValue, "=")[index]
    local showParms = string.split(parm, "|")
    parmTab.parms = {}
    for i = 1, #showParms do
      local parm = showParms[i]
      if parm then
        table.insert(parmTab.parms, parm)
      end
    end
    table.insert(guideData.showParms, parmTab)
  end
  local triggerTypes = string.split(guideCfgData.TriggerConditionType, "|")
  local triggerParms = string.split(guideCfgData.TriggerConditionValue, "|")
  for i = 1, #triggerTypes do
    local tp = tonumber(triggerTypes[i])
    if tp then
      if tp == E.SteerType.Timer then
        local timerId = tonumber(triggerParms[i])
        if timerId then
          self.timerIds_[timerId] = true
        end
      end
      table.insert(guideData.triggerParms, {
        tp = tp,
        parm = triggerParms[i]
      })
    end
  end
  local finishParmss = string.split(guideCfgData.CompletionConditionValue, "|")
  local finishTypes = string.split(guideCfgData.CompletionConditionType, "|")
  for i = 1, #finishTypes do
    local tp = tonumber(finishTypes[i])
    if tp then
      if tp == E.SteerType.Timer then
        local timerId = tonumber(finishParmss[i])
        if timerId then
          self.timerIds_[timerId] = true
        end
      end
      table.insert(guideData.finishParms, {
        tp = tp,
        parm = finishParmss[i]
      })
    end
  end
  return guideData
end

return GuideManager
