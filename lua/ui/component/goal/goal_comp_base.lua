local GoalCompBase = class("GoalCompBase")

function GoalCompBase:ctor(parentView, index, uiType)
  self.parentView_ = parentView
  self.index_ = index
  self.uiType_ = uiType
end

function GoalCompBase:Init(uiBinder)
  self.uiBinder_ = uiBinder
  if self.uiType_ == E.GoalUIType.DetailPanel then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_mask, self.index_ % 2 == 0)
  end
  self.isSameVisualLayer_ = false
  self.isPlayerInZone_ = false
  self.isNotSameScene_ = false
  
  function self:refreshZoneInfo(isEnter, zoneUid)
    if self:getGoalZoneUid() == zoneUid then
      self:updateGoalDistance()
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.PlayerEnterOrExitZone, self.refreshZoneInfo, self)
  
  function self.refreshVisualLayerInfo()
    self:updateGoalDistance()
  end
  
  self.parentView_:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrVisualLayerUid")
  }, Z.EntityMgr.PlayerEnt, self.refreshVisualLayerInfo)
end

function GoalCompBase:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self.parentView_.timerMgr:StopTimer(self.distTimer_)
  self.distTimer_ = nil
  self.uiBinder_ = nil
end

function GoalCompBase:getGoalContentDesc()
  error("func must be override!")
end

function GoalCompBase:getGoalGroupData()
  error("func must be override!")
end

function GoalCompBase:getGoalPos()
  error("func must be override!")
end

function GoalCompBase:getDescUIData()
  error("func must be override!")
end

function GoalCompBase:isHideGoalDistanceLab()
  return false
end

function GoalCompBase:refreshAll()
  local desc = self:getGoalContentDesc()
  if desc and desc ~= "" then
    self.uiBinder_.Ref.UIComp:SetVisible(true)
    self:refreshGoalUI()
  else
    self.uiBinder_.Ref.UIComp:SetVisible(false)
  end
  self:updateGoalDistance()
end

function GoalCompBase:refreshGoalUI()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.module_target_type, true)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_check, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_current, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_lock, false)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_link, false)
  if self.uiType_ == E.GoalUIType.TrackBar then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_slider, false)
  end
  local data = self:getGoalGroupData()
  if not data then
    return
  end
  local targetNumDict = data.targetNumDict
  local targetMaxNumDict = data.targetMaxNumDict
  local targetCount = table.zcount(targetNumDict)
  local goalRefreshFuncDict = {
    [E.QuestGoalGroupType.Single] = function()
      self:refreshGoalDesc(self.index_ == 1)
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.module_target_type, false)
    end,
    [E.QuestGoalGroupType.Serial] = function()
      local serialIndex = 0
      for i = 1, targetCount do
        if targetNumDict[i - 1] >= targetMaxNumDict[i - 1] then
          serialIndex = i
        end
      end
      if serialIndex > self.index_ - 1 then
        self:refreshGoalDesc(false)
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_check, true)
      elseif serialIndex < self.index_ - 1 then
        self:refreshGoalDesc(false)
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_lock, true)
      else
        self:refreshGoalDesc(true)
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_current, true)
      end
      if self.index_ ~= targetCount then
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_link, true)
      end
    end,
    [E.QuestGoalGroupType.All] = function()
      local isUndone = targetNumDict[self.index_ - 1] < targetMaxNumDict[self.index_ - 1]
      self:refreshGoalDesc(isUndone)
      if isUndone then
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_current, true)
      else
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_check, true)
      end
    end,
    [E.QuestGoalGroupType.ReachNum] = function()
      local isUndone = targetNumDict[self.index_ - 1] < targetMaxNumDict[self.index_ - 1]
      self:refreshGoalDesc(isUndone)
      if isUndone then
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_current, true)
      else
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_check, true)
      end
    end,
    [E.QuestGoalGroupType.Optional] = function()
      local isUndone = targetNumDict[self.index_ - 1] < targetMaxNumDict[self.index_ - 1]
      self:refreshGoalDesc(isUndone)
      local isRequired = false
      local requiredTargetArray = data.stepTargetCondition[1]
      if requiredTargetArray then
        for _, targetIndexStr in ipairs(requiredTargetArray) do
          local targetIndex = tonumber(targetIndexStr)
          if self.index_ == targetIndex + 1 then
            isRequired = true
            break
          end
        end
      end
      if isUndone then
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_current, true)
      else
        self.uiBinder_.Ref:SetVisible(self.uiBinder_.img_goal_check, true)
      end
    end
  }
  local refreshFunc = goalRefreshFuncDict[data.stepTargetType]
  if refreshFunc then
    refreshFunc()
    self:updateGoalDistance()
    self:updateProgressBar(targetNumDict[self.index_ - 1], targetMaxNumDict[self.index_ - 1])
  else
    self.uiBinder_.lab_target_desc.text = ""
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_location, false)
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.module_target_type, false)
  end
end

function GoalCompBase:refreshGoalDesc(isActive)
  local colorTag = isActive and E.TextStyleTag.White or E.TextStyleTag.ChannelSetting
  if self.uiType_ == E.GoalUIType.MapPanel then
    colorTag = E.TextStyleTag.White
  end
  local desc = self:getGoalContentDesc()
  self.uiBinder_.lab_target_desc.text = Z.RichTextHelper.ApplyStyleTag(desc, colorTag)
  local alphaValue = isActive and 1 or self.uiType_ == E.GoalUIType.MapPanel and 0.6 or 0.7
  self.uiBinder_.lab_target_desc.alpha = alphaValue
  local data = self:getDescUIData()
  if not data then
    return
  end
  if isActive and data.isNeedGuide then
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local toSceneId = data.toSceneId
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_location, true)
    if 0 < toSceneId and toSceneId ~= sceneId then
      local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(toSceneId)
      local sceneName = sceneRow and sceneRow.Name or ""
      self.uiBinder_.lab_distance.text = sceneName
      self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_location, self.uiType_ ~= E.GoalUIType.DetailPanel)
      self.isNotSameScene_ = true
    else
      self.isNotSameScene_ = false
    end
  else
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_location, false)
  end
end

function GoalCompBase:updateGoalDistance()
  if self.uiBinder_ == nil then
    logError("GoalCompBase:updateGoalDistance self.uiBinder_ is nil")
    return
  end
  if self:isHideGoalDistanceLab() then
    self.uiBinder_.goal_distance_update:ClearGoal()
    self.uiBinder_.lab_distance.text = ""
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_location, false)
    return
  end
  self.isPlayerInZone_ = Z.LuaBridge.IsPlayerInZone(self:getGoalZoneUid())
  self.isSameVisualLayer_ = self:getIsInGoalVisualLayer()
  if not self.isSameVisualLayer_ then
    self.uiBinder_.goal_distance_update:ClearGoal()
    self.uiBinder_.lab_distance.text = Lang("NotInVisualLayer")
    return
  end
  if self.isPlayerInZone_ then
    self.uiBinder_.goal_distance_update:ClearGoal()
    self.uiBinder_.lab_distance.text = Lang("GoalGuideInZone")
    return
  end
  local goalPos = self:getGoalPos()
  if goalPos then
    self.uiBinder_.goal_distance_update:SetGoalPos(goalPos.x, goalPos.y, goalPos.z)
  else
    self.uiBinder_.goal_distance_update:ClearGoal()
  end
end

function GoalCompBase:updateProgressBar(targetNum, targetMaxNum)
  local isShowProgressBar = self.stepRow_:IsShowGoalProgressBar(self.index_)
  if self.uiType_ ~= E.GoalUIType.TrackBar then
    return
  end
  if targetMaxNum == nil or targetMaxNum == 0 or not isShowProgressBar then
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_slider, false)
  else
    self.uiBinder_.Ref:SetVisible(self.uiBinder_.group_slider, true)
    local progress = targetNum / targetMaxNum
    if 1 < progress then
      progress = 1
    end
    self.uiBinder_.slider_task.value = progress
  end
end

function GoalCompBase:getGoalZoneUid()
  return 0
end

function GoalCompBase:getIsInGoalVisualLayer()
  return true
end

return GoalCompBase
