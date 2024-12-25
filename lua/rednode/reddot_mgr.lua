local redPointData = {
  nodes = {}
}
local WorldProxy = require("zproxy.world_proxy")
local positions = {
  [1] = {x = 0, y = 1},
  [2] = {x = 0.5, y = 1},
  [3] = {x = 1, y = 1},
  [4] = {x = 0, y = 0.5},
  [5] = {x = 0.5, y = 0.5},
  [6] = {x = 1, y = 0.5},
  [7] = {x = 0, y = 0},
  [8] = {x = 0.5, y = 0},
  [9] = {x = 1, y = 0}
}
local rednodeType = {
  Normal = 0,
  Image = 1,
  Number = 2,
  CEffect = 3,
  UEffect = 4
}
local redPaths = {
  [rednodeType.Normal] = "ui/prefabs/c_common/c_com_reddot",
  [rednodeType.Image] = "ui/prefabs/c_common/c_com_reddot",
  [rednodeType.Number] = "ui/prefabs/c_common/c_com_reddot_number",
  [rednodeType.CEffect] = "ui/prefabs/c_common/c_com_reddot_effect",
  [rednodeType.UEffect] = "ui/prefabs/c_common/c_com_reddot_effect"
}
local rednodes = {
  [rednodeType.Normal] = require("rednode.normalrednode"),
  [rednodeType.Image] = require("rednode.imgrednode"),
  [rednodeType.Number] = require("rednode.numberrednode"),
  [rednodeType.CEffect] = require("rednode.ceffectrednode"),
  [rednodeType.UEffect] = require("rednode.ueffectrednode")
}
local functionRedIds = {}
local childernItemUnits = {}
local getNodeIsPermanentClose = function(nodeId)
  if Z.ContainerMgr.CharSerialize.redDot.permanentClosedRedDot[nodeId] then
    return false
  end
  return true
end
local getNodeByFunction = function(functionId)
  if functionId == 0 then
    return nil
  end
  return redPointData.nodes[functionRedIds[functionId]]
end
local checkFuncIsOn = function(functionId)
  if functionId and functionId ~= 0 then
    local funcVM = Z.VMMgr.GetVM("gotofunc")
    return funcVM.FuncIsOn(functionId, true)
  end
  return true
end
local asyncPermanentCloseRedDot = function(nodeId)
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = Z.CancelSource.Rent()
    WorldProxy.PermanentCloseRedDot(nodeId, cancelSource:CreateToken())
    cancelSource:Recycle()
  end)()
end
local getServerTime = function()
  return math.floor(Z.ServerTime:GetServerTime() / 1000)
end
local getReaminSecondsTo24 = function(time)
  local toYear = os.date("*t", time).year
  local toMonth = os.date("*t", time).month
  local toDay = os.date("*t", time).day
  local toTime = os.time({
    year = toYear,
    month = toMonth,
    day = toDay,
    hour = 23,
    min = 59,
    sec = 59
  })
  return toTime - time + 1
end
local checkNodeIsNil = function(nodeId)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    node = getNodeByFunction(nodeId)
    if node == nil then
      return nil
    end
  end
  return node
end
local hideRedDotItem = function(node, redClass, redType, view)
  if node and node.RedDotItem[redType] then
    for uiView, gos in pairs(node.RedDotItem[redType]) do
      for name, go in pairs(gos) do
        if view then
          if view == uiView then
            view:RemoveUiUnit(name)
          end
        else
          redClass:Hide(go)
        end
      end
    end
    if view then
      node.RedDotItem[redType][view] = {}
    else
      node.RedDotItem = {}
    end
  end
end
local updateRedDotItem = function(node, redClass, redType)
  if node and redClass and node.RedDotItem[redType] then
    for uiView, gos in pairs(node.RedDotItem[redType]) do
      for name, go in pairs(gos) do
        redClass:Update(go)
      end
    end
  end
end
local updateNode = function(nodeId)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    return
  end
  local outType = node.LoseTyep[1]
  if outType == 1 then
  end
  local index = 1
  local isShow = false
  if table.zcount(node.Rednodes) == 1 then
    for redType, redNode in pairs(node.Rednodes) do
      updateRedDotItem(node, redNode, redType)
    end
  else
    for redType, redNode in pairs(node.Rednodes) do
      local childrenId = node.ChildrenIds[index]
      index = index + 1
      local childrenNode = redPointData.nodes[childrenId]
      hideRedDotItem(node, redNode, redType)
      if childrenNode and childrenNode.State and childrenNode.State and not isShow then
        isShow = true
        updateRedDotItem(node, redNode, redType)
      end
    end
  end
end
local getNodeState = function(nodeId)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    return false
  end
  if #node.ChildrenIds > 0 then
    for key, clildId in ipairs(node.ChildrenIds) do
      local clildNode = redPointData.nodes[clildId]
      if clildNode.State then
        return clildNode.State
      end
    end
  end
  return false
end
local updateNodeState = function(node)
  local isActive = node.Num > 0
  if isActive then
    isActive = checkFuncIsOn(node.FunctionId)
    if node.LoseTyep[1] == 2 then
      node.State = getNodeIsPermanentClose(node.NodeId)
    end
  end
  node.State = isActive
  updateNode(node.NodeId)
end
local updateParentNodeState = function(nodeId)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    return
  end
  node.Num = 0
  for _, childId in ipairs(node.ChildrenIds) do
    local childNode = redPointData.nodes[childId]
    if childNode and childNode.State then
      node.Num = childNode.Num + node.Num
    end
  end
  updateNodeState(node)
end

local function updateParentNode(nodeId)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    return
  end
  if node then
    for key, parentNodeId in pairs(node.ParentIds) do
      local parentNode = redPointData.nodes[parentNodeId]
      if parentNode then
        updateParentNodeState(parentNode.NodeId)
        if table.zcount(parentNode.ParentIds) > 0 then
          updateParentNode(parentNode.NodeId)
        end
      end
    end
  end
end

local refreshNodeNum = function(nodeId, num, isServer)
  local node = redPointData.nodes[nodeId]
  if node == nil then
    return
  end
  node.Num = num
  if node.LoseTyep[1] == 3 then
    Z.LocalUserDataMgr.RemoveKey("BKL_REDDOTRED" .. nodeId, true)
  end
  if isServer then
    updateNodeState(node)
  end
end
local updateServerRedData = function(nodeId, count)
  refreshNodeNum(nodeId, count, true)
  updateParentNode(nodeId)
end
local updateClientRedData = function(key, value)
  refreshNodeNum(key, value, false)
  updateParentNode(key)
end
local refreshAllNode = function()
  for key, node in pairs(redPointData.nodes) do
    local outType = node.LoseTyep[1]
    if outType == 3 then
      updateServerRedData(node.NodeId, node.Num)
    end
  end
end
local onClickRedDot = function(nodeId)
  local node = checkNodeIsNil(nodeId)
  if node == nil then
    return
  end
  if node.State == false then
    return
  end
  local isHide = true
  local outType = node.LoseTyep[1]
  local checkFunc = node.LoseTyep[2]
  local childNodeId = node.LoseTyep[3]
  if checkFunc == 1 then
  end
  if checkFunc == 2 then
    local childNode = redPointData.nodes[childNodeId]
    if childNode then
      isHide = childNode.State
    end
  end
  if checkFunc == 3 then
    isHide = getNodeState(nodeId)
  end
  node.State = isHide
  updateNode(node.NodeId)
  updateParentNode(nodeId)
  if isHide == false then
    if outType == 1 then
    end
    if outType == 2 then
      asyncPermanentCloseRedDot(nodeId)
    end
    if outType == 3 then
      Z.LocalUserDataMgr.SetLong("BKL_REDDOTRED" .. nodeId, getServerTime(), 0)
      local time = getReaminSecondsTo24(getServerTime())
      if 0 < time then
        Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.RedDotPoint, function()
          refreshAllNode()
        end, time, 1)
      end
    end
  end
end
local init = function(redData, nodeId)
  if redData == nil then
    return
  end
  local node = {}
  node.NodeId = nodeId
  node.ParentIds = {}
  node.ChildrenIds = {}
  node.State = false
  node.StyleType = redData.ShowType
  node.LoseTyep = redData.LoseCheck
  node.OffSet = redData.OffSet
  node.Size = redData.Size
  node.Num = 0
  node.RedDotItem = {}
  node.Rednodes = {}
  node.EffectPath = redData.EffectPath
  node.PicturePath = redData.PicturePath
  node.FunctionId = redData.FunctionId
  for _, nodeType in ipairs(node.StyleType) do
    local rednode = rednodes[nodeType].new(node)
    node.Rednodes[nodeType] = rednode
  end
  redPointData.nodes[nodeId] = node
end
local initRedDotNode = function()
  redPointData = {
    nodes = {}
  }
  local redDotIndexCfg = Z.TableMgr.GetTable("RedDotIndexTableMgr")
  local redDatas = redDotIndexCfg.GetDatas()
  for _, redData in pairs(redDatas) do
    if redData.FunctionId ~= 0 and functionRedIds[redData.FunctionId] == nil then
      functionRedIds[redData.FunctionId] = redData.Id
    end
    init(redData, redData.Id)
  end
  for key, redData in pairs(redDatas) do
    local parentNode = redPointData.nodes[key]
    for _, v in pairs(redData.ChildrenID) do
      table.insert(parentNode.ChildrenIds, v)
      local node = redPointData.nodes[v]
      if node then
        node.ParentIds[parentNode.NodeId] = parentNode.NodeId
      end
    end
  end
end
local loadRedDotItem = function(nodeId, uiView, redParent, parmData)
  if redParent == nil or uiView == nil or nodeId == nil then
    return
  end
  local node = checkNodeIsNil(nodeId)
  if node == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local redDotItem
    for index, nodeType in ipairs(node.StyleType) do
      local nodeName = string.format("red_%s_%s_%s", node.NodeId, nodeType, redParent.name)
      uiView:RemoveUiUnit(nodeName)
      local path
      if nodeType == 1 then
        path = node.PicturePath
      else
        path = redPaths[nodeType]
      end
      if path then
        redDotItem = uiView:AsyncLoadRedUiUnit(node.NodeId, path, nodeName, redParent)
        if not childernItemUnits[redParent] then
          childernItemUnits[redParent] = {}
        end
        childernItemUnits[redParent][nodeName] = redDotItem
        if node.RedDotItem[nodeType] == nil then
          node.RedDotItem[nodeType] = {}
        end
        if node.RedDotItem[nodeType][uiView] == nil then
          node.RedDotItem[nodeType][uiView] = {}
        end
        node.RedDotItem[nodeType][uiView][nodeName] = childernItemUnits[redParent][nodeName]
      end
      if redDotItem then
        redDotItem.Ref:SetParent(redParent)
        local type = node.OffSet[1]
        local offsetX = node.OffSet[2]
        local offsetY = node.OffSet[3]
        local position = positions[type]
        redDotItem.Ref:SetSize(node.Size[1], node.Size[2])
        redDotItem.Ref:SetPosition(offsetX, offsetY)
        if position then
          local x = position.x
          local y = position.y
          redDotItem.Ref:SetAnchors(x, x, y, y)
          redDotItem.Ref:SetPivot(x, y)
        end
        if parmData and parmData.effectPath and parmData.effectPath ~= "" then
          node.EffectPath = parmData.effectPath
        end
      end
    end
    updateNode(node.NodeId)
  end)()
end
local refreshServerNodeCount = function(nodeId, count)
  local node = checkNodeIsNil(nodeId)
  if node then
    if node.Num == count and (count == 0 or node.State) then
      return
    end
    updateServerRedData(node.NodeId, count)
  end
end
local refreshClientNodeCount = function(nodeId, count)
  local node = checkNodeIsNil(nodeId)
  if node then
    if count <= 0 then
      updateServerRedData(node.NodeId, count)
    else
      updateClientRedData(node.NodeId, count)
    end
  end
end
local removeNodeItem = function(nodeId, view)
  local node = checkNodeIsNil(nodeId)
  if node then
    for redType, redNode in pairs(node.Rednodes) do
      hideRedDotItem(node, redNode, redType, view)
    end
  end
end
local removeChildernNodeItem = function(parent, view)
  if not parent or not view then
    return
  end
  if childernItemUnits[parent] then
    for nodeName, value in pairs(childernItemUnits[parent]) do
      view:RemoveUiUnit(nodeName)
    end
    childernItemUnits[parent] = {}
  end
end
local removeChildNodeData = function(parentNodeId, childNodeId)
  local node = checkNodeIsNil(parentNodeId)
  if node then
    table.zremoveOneByValue(node.ChildrenIds, childNodeId)
    redPointData.nodes[childNodeId] = nil
  end
end
local resetAllChildNodeCount = function(parentNodeId)
  local node = checkNodeIsNil(parentNodeId)
  if node then
    for i, v in ipairs(node.ChildrenIds) do
      refreshServerNodeCount(v, 0)
    end
  end
end
local addChildNodeData = function(parentNodeId, nodeId, childNodeId)
  local childNode = redPointData.nodes[childNodeId]
  local node = checkNodeIsNil(parentNodeId)
  if childNode then
    if node then
      if not table.zcontains(node.ChildrenIds, childNodeId) then
        table.insert(node.ChildrenIds, childNodeId)
      end
      childNode.ParentIds[parentNodeId] = parentNodeId
    end
    return
  end
  if node then
    table.insert(node.ChildrenIds, childNodeId)
    init(Z.TableMgr.GetTable("RedDotIndexTableMgr").GetRow(nodeId), childNodeId)
    redPointData.nodes[childNodeId].ParentIds[parentNodeId] = parentNodeId
  end
end
local getRedState = function(nodeId)
  local node = checkNodeIsNil(nodeId)
  if node then
    return node.State
  end
  return false
end
local refreshRedNodeState = function(nodeId)
  local node = checkNodeIsNil(nodeId)
  if node then
    updateNodeState(node)
    updateParentNode(node.NodeId)
  end
end
local asyncSetRedDotValue = function(redDotId, value, isAdd, cancelSource)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.SetRedDotValue(redDotId, value, isAdd, cancelSource)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  return true
end
local asyncCancelRedDot = function(redDotId)
  local worldProxy = require("zproxy.world_proxy")
  local CancelRedDotParam = {redDotId = redDotId}
  worldProxy.CancelRedDot(CancelRedDotParam)
end
local RedDot = {
  RefreshServerNodeCount = refreshServerNodeCount,
  RefreshClientNodeCount = refreshClientNodeCount,
  InitRedDotNode = initRedDotNode,
  LoadRedDotItem = loadRedDotItem,
  OnClickRedDot = onClickRedDot,
  RemoveNodeItem = removeNodeItem,
  RemoveChildernNodeItem = removeChildernNodeItem,
  AddChildNodeData = addChildNodeData,
  RemoveChildNodeData = removeChildNodeData,
  ResetAllChildNodeCount = resetAllChildNodeCount,
  CheckNodeIsNil = checkNodeIsNil,
  GetRedState = getRedState,
  RefreshRedNodeState = refreshRedNodeState,
  AsyncSetRedDotValue = asyncSetRedDotValue,
  AsyncCancelRedDot = asyncCancelRedDot
}
return RedDot
