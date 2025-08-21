local TrialRoadRed = {}
local trialRoadKeyCache = {}

function TrialRoadRed.initRoomRedItem(dataDict, nodeName)
  for _, v in pairs(dataDict) do
    local roomIdStr_ = "TrialRoadRoomSelect_" .. v.TrialRoadInfo.RoomId
    Z.RedPointMgr.AddChildNodeData(nodeName, E.RedType.TrialRoadRoomSelect, roomIdStr_)
    table.insert(trialRoadKeyCache, roomIdStr_)
    if #v.ListRoomTarget then
      for _, target in ipairs(v.ListRoomTarget) do
        local targetdStr_ = "TrialRoadRoomTarget_" .. target.RoomId * 1000 .. target.TargetId
        Z.RedPointMgr.AddChildNodeData(roomIdStr_, E.RedType.TrialRoadRoomTarget, targetdStr_)
        table.insert(trialRoadKeyCache, targetdStr_)
        local count_ = 0
        if target.TargetState == E.TrialRoadTargetState.UnGetReward then
          count_ = 1
        end
        Z.RedPointMgr.UpdateNodeCount(targetdStr_, count_)
      end
    end
  end
end

function TrialRoadRed.InitTrialRoadRoomTargetItemRed()
  Z.RedPointMgr.AddChildNodeData(E.RedType.TrialRoadMain, E.RedType.TrialRoadSelectTab, "TrialRoadTypeTab_Power")
  Z.RedPointMgr.AddChildNodeData(E.RedType.TrialRoadMain, E.RedType.TrialRoadSelectTab, "TrialRoadTypeTab_Guard")
  Z.RedPointMgr.AddChildNodeData(E.RedType.TrialRoadMain, E.RedType.TrialRoadSelectTab, "TrialRoadTypeTab_Auxiliary")
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  trialroadData:InitTrialRoadRoomDict()
  local powerDict_ = trialroadData:GetTrialRoadRoomDataListByType(E.TrialRoadType.Power)
  local guardDict_ = trialroadData:GetTrialRoadRoomDataListByType(E.TrialRoadType.Guard)
  local auxiliaryDict_ = trialroadData:GetTrialRoadRoomDataListByType(E.TrialRoadType.Auxiliary)
  TrialRoadRed.initRoomRedItem(powerDict_, "TrialRoadTypeTab_Power")
  TrialRoadRed.initRoomRedItem(guardDict_, "TrialRoadTypeTab_Guard")
  TrialRoadRed.initRoomRedItem(auxiliaryDict_, "TrialRoadTypeTab_Auxiliary")
end

function TrialRoadRed.RefreshTrialRoadRoomTargetItemRed(roomId)
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  local roomData_ = trialroadData:GetTrialRoadRoomDataById(roomId)
  if roomData_ and #roomData_.ListRoomTarget then
    for _, target in ipairs(roomData_.ListRoomTarget) do
      local targetdStr_ = "TrialRoadRoomTarget_" .. target.RoomId * 1000 .. target.TargetId
      local count_ = 0
      if target.TargetState == E.TrialRoadTargetState.UnGetReward then
        count_ = 1
      end
      Z.RedPointMgr.UpdateNodeCount(targetdStr_, count_)
    end
  end
end

function TrialRoadRed.LoadTrialRoadRoomTargetItem(roomId, targetId, view, parentTrans)
  local targetdStr_ = "TrialRoadRoomTarget_" .. roomId * 1000 .. targetId
  Z.RedPointMgr.LoadRedDotItem(targetdStr_, view, parentTrans)
end

function TrialRoadRed.RemoveTrialRoadRoomTargetItem(roomId, targetId, view)
  if roomId and targetId then
    local targetdStr_ = "TrialRoadRoomTarget_" .. roomId * 1000 .. targetId
    Z.RedPointMgr.RemoveNodeItem(targetdStr_, view)
  end
end

function TrialRoadRed.LoadTrialRoadSelectItem(type, view, parentTrans)
  if type == E.TrialRoadType.Auxiliary then
    Z.RedPointMgr.LoadRedDotItem("TrialRoadTypeTab_Auxiliary", view, parentTrans)
  elseif type == E.TrialRoadType.Power then
    Z.RedPointMgr.LoadRedDotItem("TrialRoadTypeTab_Power", view, parentTrans)
  else
    Z.RedPointMgr.LoadRedDotItem("TrialRoadTypeTab_Guard", view, parentTrans)
  end
end

function TrialRoadRed.LoadTrialRoadRoomSelectItem(roomId, view, parentTrans)
  local roomIdStr_ = "TrialRoadRoomSelect_" .. roomId
  Z.RedPointMgr.LoadRedDotItem(roomIdStr_, view, parentTrans)
end

function TrialRoadRed.RemoveTrialRoadRoomSelectItem(roomId, view)
  if roomId then
    local roomIdStr_ = "TrialRoadRoomSelect_" .. roomId
    Z.RedPointMgr.RemoveNodeItem(roomIdStr_, view)
  end
end

function TrialRoadRed.InitTrialRoadGradeTargetItemRed()
  for _, v in pairs(Z.TrialRoadConfig.TrialRoadAward) do
    local gradeStr_ = "TrialRoadGradeTarget_" .. v[1]
    Z.RedPointMgr.AddChildNodeData(E.RedType.TrialRoadGradeBtn, E.RedType.TrialRoadGradeTarget, gradeStr_)
    table.insert(trialRoadKeyCache, gradeStr_)
    local count_ = 0
    if Z.ContainerMgr.CharSerialize.trialRoad.targetAward and Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[v[1]] then
      local state_ = Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[v[1]].awardState
      if state_ == E.TrialRoadTargetState.UnGetReward then
        count_ = 1
      end
    end
    Z.RedPointMgr.UpdateNodeCount(gradeStr_, count_)
  end
end

function TrialRoadRed.RemoveAllTrialRoadRedItem(view)
  for _, v in ipairs(trialRoadKeyCache) do
    Z.RedPointMgr.RemoveNodeItem(v, view)
  end
end

function TrialRoadRed.RefreshTrialRoadGradeTargetItemRed()
  for _, v in pairs(Z.TrialRoadConfig.TrialRoadAward) do
    local gradeStr_ = "TrialRoadGradeTarget_" .. v[1]
    local count_ = 0
    if Z.ContainerMgr.CharSerialize.trialRoad.targetAward and Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[v[1]] then
      local state_ = Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[v[1]].awardState
      if state_ == E.TrialRoadTargetState.UnGetReward then
        count_ = 1
      end
    end
    Z.RedPointMgr.UpdateNodeCount(gradeStr_, count_)
  end
end

function TrialRoadRed.LoadTrialRoadGradeTargetItem(gradeTargetId, view, parentTrans)
  local gradeStr_ = "TrialRoadGradeTarget_" .. gradeTargetId
  Z.RedPointMgr.LoadRedDotItem(gradeStr_, view, parentTrans)
end

function TrialRoadRed.LoadTrialRoadGradeBtnItem(view, parentTrans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TrialRoadGradeBtn, view, parentTrans)
end

return TrialRoadRed
