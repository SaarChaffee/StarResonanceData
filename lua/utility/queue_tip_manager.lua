local Mgr = {}
local ViewState = {UnOpen = 0, IsOpen = 1}
local TypeMaxInQueueCount = {
  [E.EQueueTipType.FunctionOpen] = 10,
  [E.EQueueTipType.Episode] = 10,
  [E.EQueueTipType.ItemGet] = 10,
  [E.EQueueTipType.FinishSeasonAchievement] = 10,
  [E.EQueueTipType.FashionAndVehicle] = 5,
  [E.EQueueTipType.ResonanceSkillGet] = 10,
  [E.EQueueTipType.ItemShow] = 10,
  [E.EQueueTipType.SelectPack] = 10,
  [E.EQueueTipType.Activities] = 10,
  [E.EQueueTipType.LifeRecipe] = 20
}

function Mgr:AddQueueTipData(tipType, viewConfigKey, viewData, priority, unrealScenePath, unrealSceneConfig)
  local tipData = {
    tipType = tipType,
    viewConfigKey = viewConfigKey,
    viewData = viewData,
    priority = priority == nil and 0 or priority,
    unrealScenePath = unrealScenePath,
    unrealSceneConfig = unrealSceneConfig,
    state = ViewState.UnOpen
  }
  self:enQueue(tipData)
end

function Mgr:Init()
  self.queueViewDic_ = {}
  self.queueOpenViewConfigKey_ = {}
  self.queueViewDicCount_ = {}
  self.cancelSource_ = Z.CancelSource.Rent()
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function Mgr:UnInit()
  self:ClearTipsQueueData()
  if self.cancelSource_ then
    self.cancelSource_:Recycle()
    self.cancelSource_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function Mgr:ClearTipsQueueData()
  self.queueViewDic_ = {}
  self.queueOpenViewConfigKey_ = {}
  self.queueViewDicCount_ = {}
end

function Mgr:enQueue(tipData)
  if self.queueViewDic_[tipData.tipType] == nil then
    self.queueViewDic_[tipData.tipType] = {}
    self.queueViewDicCount_[tipData.tipType] = 0
  end
  if self.queueViewDicCount_[tipData.tipType] >= TypeMaxInQueueCount[tipData.tipType] then
    return
  end
  if self.queueViewDicCount_[tipData.tipType] == 0 then
    self.queueViewDic_[tipData.tipType][1] = tipData
    self.queueViewDicCount_[tipData.tipType] = 1
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
      coro(1, Z.PlayerLoopTiming.Update, self.cancelSource_:CreateToken())
      self:popQueue(tipData.tipType)
    end)()
  else
    local isInsert = false
    local start = 1
    if self.queueViewDic_[tipData.tipType][1].state == ViewState.IsOpen then
      start = 2
    end
    for i = start, self.queueViewDicCount_[tipData.tipType] do
      if self.queueViewDic_[tipData.tipType][i].priority > tipData.priority then
        isInsert = true
        table.insert(self.queueViewDic_[tipData.tipType], i, tipData)
        break
      end
    end
    if not isInsert then
      table.insert(self.queueViewDic_[tipData.tipType], tipData)
    end
    self.queueViewDicCount_[tipData.tipType] = self.queueViewDicCount_[tipData.tipType] + 1
  end
end

function Mgr:popQueue(type)
  if Z.EntityMgr.PlayerEnt then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
    if self.deadStateId_ == stateId then
      return
    end
  end
  if self.queueViewDic_[type] == nil then
    return
  end
  if self.queueViewDicCount_[type] == 0 then
    return
  end
  if self.queueViewDic_[type][1].state == ViewState.IsOpen then
    table.remove(self.queueViewDic_[type], 1)
    self.queueOpenViewConfigKey_[type] = nil
    self.queueViewDicCount_[type] = self.queueViewDicCount_[type] - 1
  end
  if self.queueViewDicCount_[type] > 0 then
    local viewInfo = self.queueViewDic_[type][1]
    if viewInfo.unrealScenePath then
      Z.UnrealSceneMgr:OpenUnrealScene(viewInfo.unrealScenePath, viewInfo.viewConfigKey, function()
        Z.UIMgr:OpenView(viewInfo.viewConfigKey, viewInfo.viewData)
      end, viewInfo.unrealSceneConfig)
    else
      Z.UIMgr:OpenView(viewInfo.viewConfigKey, viewInfo.viewData)
    end
    self.queueViewDic_[type][1].state = ViewState.IsOpen
    self.queueOpenViewConfigKey_[type] = viewInfo.viewConfigKey
  end
end

function Mgr:onCloseViewEvent(viewConfigKey)
  for type, v in pairs(self.queueOpenViewConfigKey_) do
    if v == viewConfigKey then
      self:popQueue(type)
    end
  end
end

return Mgr
