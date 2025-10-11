local UI = Z.UI
local super = require("ui.ui_view_base")
local Steer_tips_windowView = class("Steer_tips_windowView", super)

function Steer_tips_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "steer_tips_window")
  self.settKeyVm_ = Z.VMMgr.GetVM("setting_key")
end

function Steer_tips_windowView:initWidget()
  self.eff_root_ = self.uiBinder.eff_root
  self.tipsNode_ = self.uiBinder.node_tips
  self.node_circle_ = self.uiBinder.node_circle
  self.node_mask_ = self.uiBinder.node_mask
  self.node_content_ = self.uiBinder.node_content
  self.event_trigger_ = self.uiBinder.node_event_trigger
  self.interactionNode_ = self.uiBinder.node_interaction
  self.interactionBinder_ = self.uiBinder.steer_interaction_mobile
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function Steer_tips_windowView:OnActive()
  self:initData()
  self:initWidget()
  self.event_trigger_.onClick:AddListener(function()
    self:triggerEvent()
  end)
  self.event_trigger_.onDrag:AddListener(function()
    self:triggerEvent()
  end)
  Z.EventMgr:Add(Z.ConstValue.SteerEventName.OnSaveCompletedGuide, self.finishGuide, self)
end

function Steer_tips_windowView:triggerEvent()
  if self.isTriggerEvent_ then
    return
  end
  self.isTriggerEvent_ = true
  self.uiBinder.Ref:SetVisible(self.event_trigger_, false)
  local tab = {}
  for steer, value in pairs(self.onClickSteerDic_) do
    if value then
      self.onClickSteerDic_[steer] = nil
      table.insert(tab, steer)
    end
  end
  if self.onClickGuideId_ == self.nowShowGuideId_ then
    self.nowShowGuideId_ = 0
  else
    local data = self.allSteerData_[self.nowShowGuideId_]
    if data and data.data.IfCheck then
      Z.GuideMgr:RemoveByGroupId(data.data.GuideGroup)
    end
    self.nowShowGuideId_ = 0
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnFinishGuideEvent, tab)
end

function Steer_tips_windowView:finishGuide(guideid)
  if self.setCameraId_[guideid] then
    local idList = ZUtil.Pool.Collections.ZList_int.Rent()
    idList:Add(self.setCameraId_[guideid])
    Z.CameraMgr:CameraInvokeByList(E.CameraState.Position, false, idList, false)
    ZUtil.Pool.Collections.ZList_int.Return(idList)
  end
end

function Steer_tips_windowView:initData()
  self.data_ = {}
  self.tipsBgTab_ = {}
  self.circleTab_ = {}
  self.maskTab_ = {}
  self.timeUiBinders_ = {}
  self.onClickGuideId_ = 0
  self.setCameraId_ = {}
  self.isTriggerEvent_ = false
  self.nowShowGuideId_ = 0
  self.onClickSteerDic_ = {}
  self.nowShowSteerGroupDic_ = {}
  self.allSteerData_ = {}
  self.nowShowSteerDic_ = {}
  self.allCircleSteerDatas = {}
  Z.GuideMgr:ClearNowShowGuideId()
end

function Steer_tips_windowView:OnDeActive()
end

function Steer_tips_windowView:loadLab(steerId, content)
  local labPath = self.prefabCache_:GetString("lab")
  if not (labPath ~= "" and labPath) or self.tipsBgTab_[steerId] == nil then
    return
  end
  if content == "" then
    return
  end
  local unitName = "lab" .. steerId
  if self.cancelTokens[unitName] then
    return
  end
  local unit = self:AsyncLoadUiUnit(labPath, unitName, self.tipsBgTab_[steerId].layout_steer.transform)
  if unit then
    unit.lab.text = content
  end
end

function Steer_tips_windowView:loadTime(guideData)
  if guideData.AutoCompleteTime > 0 then
    local labPath = self.prefabCache_:GetString("time")
    if not (labPath ~= "" and labPath) or not self.tipsBgTab_[guideData.Id] then
      return
    end
    local time = Z.GuideMgr:GetCountDownByGuideId(guideData.Id) or guideData.AutoCompleteTime
    if time == nil then
      return
    end
    local unitName = "time" .. guideData.Id
    if self.cancelTokens[unitName] then
      return
    end
    self.timeUiBinders_[guideData.Id] = self:AsyncLoadUiUnit(labPath, unitName, self.tipsBgTab_[guideData.Id].layout_steer.transform)
    if self.timeUiBinders_[guideData.Id] then
      self:startTimeCondown(self.timeUiBinders_[guideData.Id], guideData.AutoCompleteTime, time)
      self.timerMgr:StartTimer(function()
        time = time - 1
        self:startTimeCondown(self.timeUiBinders_[guideData.Id], guideData.AutoCompleteTime, time)
      end, 1, time)
    end
  end
end

function Steer_tips_windowView:startTimeCondown(unit, autoCompleteTime, time)
  unit.img_progress.fillAmount = time / autoCompleteTime
  unit.img_arrow:SetLocalEuler(0, 0, 270 - time / autoCompleteTime * 360)
end

function Steer_tips_windowView:getIsMouse(keyCode)
  local key = tonumber(keyCode)
  if key == 323 or key == 324 or key == 325 then
    return true
  end
  return false
end

function Steer_tips_windowView:loadMouseTpl(steerId, mouseTab)
  local mousePath = self.prefabCache_:GetString("mouse")
  if not (mousePath ~= "" and mousePath) or self.tipsBgTab_[steerId] == nil then
    return
  end
  if Z.IsPCUI then
    mousePath = mousePath .. "_pc"
  end
  local contrastTbl = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr")
  for key, value in pairs(mouseTab) do
    local row = contrastTbl.GetRow(value)
    if row then
      local unitName = "mouse" .. steerId .. value
      if self.cancelTokens[unitName] then
        return
      end
      local unit = self:AsyncLoadUiUnit(mousePath, unitName, self.tipsBgTab_[steerId].layout_steer.transform)
      if unit then
        unit.img_mouse:SetImage(row.ImageWay)
      end
    end
  end
end

function Steer_tips_windowView:loadKey(steerId, KeyboardTab)
  local keyPath = self.prefabCache_:GetString("key")
  if not (keyPath ~= "" and keyPath) or self.tipsBgTab_[steerId] == nil then
    return
  end
  if Z.IsPCUI then
    keyPath = keyPath .. "_pc"
  end
  for key, keyName in pairs(KeyboardTab) do
    local unitName = key .. steerId
    if self.cancelTokens[unitName] then
      return
    end
    local unit = self:AsyncLoadUiUnit(keyPath, unitName, self.tipsBgTab_[steerId].layout_steer.transform)
    if unit then
      unit.lab_name.text = keyName
    end
  end
end

function Steer_tips_windowView:getMouseTabAndKeyTab(guideData)
  local KeyboardTab = {}
  local keyboardArray = {}
  local mouseTab = {}
  for key, keyId in ipairs(guideData.KeyboardId) do
    if keyId == 0 then
      return KeyboardTab, mouseTab, keyboardArray
    end
    local keyList = self.settKeyVm_.GetKeyCodeDescListByKeyId(keyId)
    if keyList == nil or table.zcount(keyList) == 0 then
      return KeyboardTab, mouseTab, keyboardArray
    end
    if 1 < #keyList then
      local tempStr = ""
      for _, keyCode in ipairs(keyList) do
        keyboardArray[#keyboardArray + 1] = keyCode
        tempStr = string.zconcat(tempStr, keyCode)
      end
      KeyboardTab["key" .. keyId] = tempStr
    else
      keyboardArray[#keyboardArray + 1] = keyList[1]
      KeyboardTab["key" .. keyId] = keyList[1]
    end
  end
  return KeyboardTab, mouseTab, keyboardArray
end

function Steer_tips_windowView:loadTipsBg(steerId)
  local bgPath = self.prefabCache_:GetString("tipsBg")
  if bgPath ~= "" and bgPath then
    local unitName = "tips" .. steerId
    if self.cancelTokens[unitName] then
      return
    end
    if Z.IsPCUI then
      bgPath = bgPath .. "_pc"
    end
    self.tipsBgTab_[steerId] = self:AsyncLoadUiUnit(bgPath, unitName, self.tipsNode_.transform)
    if self.tipsBgTab_[steerId] then
      self.tipsBgTab_[steerId].Ref.UIComp:SetVisible(false)
    end
  end
end

function Steer_tips_windowView:setCircleState(guideData, isShow)
  local steerId = guideData.Id
  local isHideCircle = false
  if Z.IsPCUI and guideData.UIView ~= "" and Z.UIMgr:IsActive(guideData.UIView) then
    isShow = true
    isHideCircle = true
  end
  if isShow then
    self:showSteer(guideData)
  else
    if self.nowShowSteerGroupDic_[guideData.GuideGroup] == steerId then
      self.nowShowSteerGroupDic_[guideData.GuideGroup] = nil
      self:refreshCircleSteer(steerId)
    end
    self:changeState(steerId, false)
  end
  if isHideCircle and self.circleTab_[steerId] then
    self.circleTab_[steerId].Ref.UIComp:SetVisible(false)
  end
end

function Steer_tips_windowView:refreshCircleSteer(hideSteerId)
  for steerId, guideData in pairs(self.allCircleSteerDatas) do
    if hideSteerId ~= steerId and self.circleTab_[steerId] and self.circleTab_[steerId].steer_circle.IsShow then
      self:setCircleState(guideData, true)
    end
  end
end

function Steer_tips_windowView:loadCircle(guideData)
  local steerId = guideData.Id
  self.allCircleSteerDatas[steerId] = guideData
  local circlePath = self.prefabCache_:GetString("circle")
  if circlePath ~= "" and circlePath then
    if Z.IsPCUI then
      circlePath = circlePath .. "_pc"
    end
    local unitName = "circle" .. steerId
    if self.cancelTokens[unitName] then
      return
    end
    self.circleTab_[steerId] = self:AsyncLoadUiUnit(circlePath, unitName, self.node_circle_.transform)
    if self.circleTab_[steerId] then
      self:onResetAnim(self.circleTab_[steerId].anim, self.circleTab_[steerId].anim_lab)
      Z.SteerMgr:AddSteerById(guideData.Id)
      if Z.IsPCUI then
        self.circleTab_[steerId].Ref:SetVisible(self.circleTab_[steerId].node_tips, #guideData.KeyboardId == 0)
      end
      self.circleTab_[steerId].Ref:SetVisible(self.circleTab_[steerId].btn, self:inClickSteerArea(guideData))
      self:AddClick(self.circleTab_[steerId].btn, function()
        self.onClickGuideId_ = steerId
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnFinishGuideEvent, {steerId})
      end)
      self.circleTab_[steerId].steer_circle:SetSteerId(steerId)
      self:setCircleState(guideData, self.circleTab_[steerId].steer_circle.IsShow)
      self:AddClick(self.circleTab_[steerId].steer_circle, function(isShow)
        if self.IsActive then
          self:setCircleState(guideData, isShow)
        end
      end)
      self.circleTab_[steerId].steer_time_tpl.Ref.UIComp:SetVisible(false)
      local time = Z.GuideMgr:GetCountDownByGuideId(guideData.Id) or guideData.AutoCompleteTime
      if time == nil or time == 0 then
        return
      end
      self.circleTab_[steerId].steer_time_tpl.Ref.UIComp:SetVisible(true)
      self.circleTab_[steerId].steer_time_tpl.img_progress.fillAmount = time / guideData.AutoCompleteTime
      self.timerMgr:StartTimer(function()
        time = time - 1
        self.circleTab_[steerId].steer_time_tpl.img_progress.fillAmount = time / guideData.AutoCompleteTime
        local vec3 = Vector3.zero
        vec3.z = 270 - time / guideData.AutoCompleteTime * 360
        self.circleTab_[steerId].steer_time_tpl.img_arrow:SetRot(0, 0, 270 - time / guideData.AutoCompleteTime * 360)
      end, 1, time)
    end
  end
end

function Steer_tips_windowView:loadMask(steerId)
  local maskPath = self.prefabCache_:GetString("mask")
  if maskPath ~= "" and maskPath then
    local unitName = "mask" .. steerId
    if self.cancelTokens[unitName] then
      return
    end
    self.maskTab_[steerId] = self:AsyncLoadUiUnit(maskPath, unitName, self.node_mask_.transform)
    if self.maskTab_[steerId] then
      self.maskTab_[steerId].Ref.UIComp:SetVisible(false)
      self.maskTab_[steerId].Trans:SetSizeDelta(0, 0)
      self.maskTab_[steerId].img_mask:SetSteerId(steerId)
      self.maskTab_[steerId].img_mask:AddOnChangeListener(function(isShow)
        self.maskTab_[steerId].Ref.UIComp:SetVisible(isShow)
      end)
      self:AddClick(self.maskTab_[steerId].img_mask, function()
        Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnFinishGuideEvent, {steerId})
      end)
    end
  end
end

function Steer_tips_windowView:refreshInteraction(guideData)
  self.interactionBinder_.lab_tips.text = guideData.TextMiddle
end

function Steer_tips_windowView:inClickSteerArea(guideCfgData)
  local finishTypes = string.split(guideCfgData.CompletionConditionType, "|")
  for i = 1, #finishTypes do
    local type = tonumber(finishTypes[i])
    if type == E.SteerType.OnClickSteerArea then
      return true
    end
  end
  return false
end

function Steer_tips_windowView:isClickEvent(guideCfgData)
  local finishTypes = string.split(guideCfgData.CompletionConditionType, "|")
  for i = 1, #finishTypes do
    local type = tonumber(finishTypes[i])
    if type == E.SteerType.OnClickAllArea then
      return true
    end
  end
  return false
end

function Steer_tips_windowView:refreshGuide(guideInfoDatas)
  Z.SteerMgr:ClearFindSteerIds()
  self:closeGuide()
  self:initData()
  if guideInfoDatas == nil then
    return
  end
  for index, guideDatas in pairs(guideInfoDatas) do
    if guideDatas.isShow then
      local guideData = guideDatas.data
      if guideData then
        local isReturn = false
        if guideData.DelayTime > 0 then
          Z.Delay(guideData.DelayTime, self.cancelSource:CreateToken())
        end
        self.allSteerData_[guideData.Id] = guideDatas
        if self:isClickEvent(guideData) then
          if guideData.IsShowUIFrame then
            self.onClickSteerDic_[guideData.Id] = false
          else
            self.onClickSteerDic_[guideData.Id] = true
          end
        end
        if guideData.IsBlack then
          self:loadMask(guideData.Id)
        end
        if guideData.CameraID ~= 0 then
          self.setCameraId_[guideData.Id] = guideData.CameraID
          local idList = ZUtil.Pool.Collections.ZList_int.Rent()
          idList:Add(guideData.CameraID)
          Z.CameraMgr:CameraInvokeByList(E.CameraState.Position, true, idList, false)
          ZUtil.Pool.Collections.ZList_int.Return(idList)
          self:refreshInteraction(guideData)
          self.uiBinder.Ref:SetVisible(self.interactionNode_, true)
          self:showSteer(guideData)
          isReturn = true
        else
          local str = ""
          if Z.IsPCUI then
            local mouseTab = {}
            local KeyboardTab = {}
            local keyboardArray = {}
            str = guideData.TextMiddle
            if 0 < #guideData.KeyboardId then
              KeyboardTab, mouseTab, keyboardArray = self:getMouseTabAndKeyTab(guideData)
              if 0 < table.zcount(KeyboardTab) then
                local param = {keyboard = KeyboardTab}
                str = Z.Placeholder.Placeholder(str, param)
              end
            end
            if 0 < table.zcount(mouseTab) or 0 < table.zcount(keyboardArray) or str ~= "" then
              self:loadTipsBg(guideData.Id)
              self:loadMouseTpl(guideData.Id, mouseTab)
              self:loadKey(guideData.Id, keyboardArray)
              self:loadLab(guideData.Id, str)
              self:loadTime(guideData)
            end
          else
            if 0 < #guideData.KeyboardId then
              if not guideData.IsShowUIFrame then
                str = Z.IsPCUI and guideData.TextAround or guideData.MobileTextAround
              end
            else
              str = guideData.TextMiddle
            end
            if str ~= "" then
              self:loadTipsBg(guideData.Id)
              self:loadLab(guideData.Id, str)
            end
          end
          local IsShowUIFrame = guideData.IsShowUIFrame and (not Z.IsPCUI or not guideData.OnlyKey)
          if IsShowUIFrame then
            self:loadCircle(guideData)
          else
            isReturn = true
          end
          if not IsShowUIFrame and self.tipsBgTab_[guideData.Id] and str ~= "" then
            self:showSteer(guideData)
          end
          self:setEventTriggerState()
        end
        if isReturn then
          return
        end
      end
    end
  end
end

function Steer_tips_windowView:showSteer(steerData)
  local isShow = true
  local steerId = steerData.Id
  if steerData.GuideGroup == 0 then
    self:changeState(steerId, isShow)
    return
  end
  local nowShowSteerId = self.nowShowSteerGroupDic_[steerData.GuideGroup]
  if nowShowSteerId then
    if steerData.GuideGroup ~= 0 then
      local tab = Z.TableMgr.GetTable("GuideTableMgr").GetRow(nowShowSteerId)
      if tab then
        isShow = steerData.Priority <= tab.Priority
      end
    end
  else
    self.nowShowSteerGroupDic_[steerData.GuideGroup] = steerId
  end
  if isShow then
    self.nowShowSteerGroupDic_[steerData.GuideGroup] = steerId
    if nowShowSteerId ~= steerId then
      self:changeState(nowShowSteerId, false)
    end
  end
  self:changeState(steerId, isShow)
end

function Steer_tips_windowView:changeState(steerId, isShow)
  if self.onClickSteerDic_[steerId] ~= nil then
    self:setEventTriggerState()
    self.onClickSteerDic_[steerId] = isShow
  end
  if self.nowShowSteerDic_[steerId] and not isShow then
    self.nowShowSteerDic_[steerId] = nil
  end
  if isShow then
    if table.zcount(self.nowShowSteerDic_) >= 1 then
      return
    end
    self.nowShowSteerDic_[steerId] = true
    if self.allSteerData_[steerId] then
      Z.GuideEventMgr:AddInputEvent(self.allSteerData_[steerId])
    end
    Z.GuideMgr:StartTime(steerId)
    Z.GuideMgr:AddNowShowGuideId(steerId)
    self.nowShowGuideId_ = steerId
    if self.circleTab_[steerId] then
      if self.allSteerData_[steerId] and self.allSteerData_[steerId].data.IfDynamic then
        self:onPlayAnim(self.circleTab_[steerId].anim, self.circleTab_[steerId].anim_lab)
      else
        self:onResetAnim(self.circleTab_[steerId].anim, self.circleTab_[steerId].anim_lab)
      end
    end
  else
    Z.GuideMgr:RemoveNowShowGuideId(steerId)
  end
  if self.tipsBgTab_[steerId] then
    self.tipsBgTab_[steerId].Ref.UIComp:SetVisible(isShow)
  end
  if self.circleTab_[steerId] then
    self.circleTab_[steerId].Ref.UIComp:SetVisible(isShow)
  end
  if self.maskTab_[steerId] then
    self.maskTab_[steerId].Ref.UIComp:SetVisible(isShow)
    if isShow then
      self.maskTab_[steerId].img_mask:SetSteerId(steerId)
    end
  end
  self:setEventTriggerState()
end

function Steer_tips_windowView:setEventTriggerState()
  self.uiBinder.Ref:SetVisible(self.event_trigger_, false)
  local data = self.allSteerData_[self.nowShowGuideId_]
  if data and data.data.IfCheck then
    self.uiBinder.Ref:SetVisible(self.event_trigger_, true)
    return
  end
  for steerId, value in pairs(self.onClickSteerDic_) do
    if value then
      self.uiBinder.Ref:SetVisible(self.event_trigger_, true)
      return
    end
  end
end

function Steer_tips_windowView:closeGuide()
  self.uiBinder.Ref:SetVisible(self.event_trigger_, false)
  self.uiBinder.Ref:SetVisible(self.interactionNode_, false)
end

function Steer_tips_windowView:clearAllUnits()
  for index, value in pairs(self.maskTab_) do
    value.img_mask:RemoveAllListeners()
  end
  for index, value in pairs(self.circleTab_) do
    value.steer_circle:RemoveAllListeners()
  end
  self:ClearAllUnits()
end

function Steer_tips_windowView:sortActiveGuideTab(guideInfoDatas)
  if guideInfoDatas == nil then
    return
  end
  local tab = table.zvalues(guideInfoDatas)
  if table.zcount(tab) > 1 then
    table.sort(tab, function(a, b)
      if a.data.PriorityGlobal ~= 0 or b.data.PriorityGlobal ~= 0 then
        return a.data.PriorityGlobal < b.data.PriorityGlobal
      else
        return a.data.Priority < b.data.Priority
      end
    end)
  end
  self:refreshGuide(tab)
end

function Steer_tips_windowView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearAllUnits()
    self.uiBinder.Ref.UIComp:SetVisible(true)
    self.timerMgr:Clear()
    self:sortActiveGuideTab(self.viewData)
  end)()
end

function Steer_tips_windowView:playLoopAnim(anim)
end

function Steer_tips_windowView:onPlayAnim(anim, labAnim)
  labAnim:PlayOnce("ui_anim_steer_on_tpl_star_open_02")
  anim:CoroPlayOnce("ui_anim_steer_on_tpl_star_open_01", self.cancelSource:CreateToken(), function()
    anim:PlayLoop("ui_anim_steer_on_tpl_star_loop")
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

function Steer_tips_windowView:onResetAnim(anim, labAnim)
  anim:ResetAniState("ui_anim_steer_on_tpl_star_open", 0)
  anim:ResetAniState("ui_anim_steer_on_tpl_star_open_01", 0)
  labAnim:ResetAniState("ui_anim_steer_on_tpl_star_open_02", 0)
  anim:PlayLoop("ui_anim_steer_on_tpl_star_loop")
end

return Steer_tips_windowView
