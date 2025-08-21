local WorldProxy = require("zproxy.world_proxy")
local redDotLogicNode = require("rednode.core.reddot_logic_node")
local RedDotMgr = {}
RedDotMgr.redPointData = {}
RedDotMgr.functionRedIds = {}
RedDotMgr.parentNodeMap = {}

function RedDotMgr.getNodeByFunction(functionId)
  if functionId == 0 then
    return nil
  end
  return RedDotMgr.redPointData[RedDotMgr.functionRedIds[functionId]]
end

function RedDotMgr.asyncPermanentCloseRedDot(nodeId)
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = Z.CancelSource.Rent()
    WorldProxy.PermanentCloseRedDot(nodeId, cancelSource:CreateToken())
    cancelSource:Recycle()
  end)()
end

function RedDotMgr.GetReaminSecondsTo24(time)
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

function RedDotMgr.CheckNodeIsNil(nodeId)
  local node = RedDotMgr.redPointData[nodeId]
  if node == nil then
    node = RedDotMgr.getNodeByFunction(nodeId)
    if node == nil then
      return nil
    end
  end
  return node
end

function RedDotMgr.RefreshAllNode()
  for key, node in pairs(RedDotMgr.redPointData) do
    local outType = node.LoseType[1]
    if outType == 3 then
      node:UpdateNodeData(node.Num, true)
    end
  end
end

function RedDotMgr.OnClickRedDot(nodeId)
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node == nil then
    return
  end
  node:OnClickRedDot()
end

function RedDotMgr.createLogicNode(redData, nodeId)
  if redData == nil then
    return
  end
  local logicNode = redDotLogicNode.new(redData, nodeId)
  RedDotMgr.redPointData[nodeId] = logicNode
end

function RedDotMgr.buildRedNodesTree(redDatas)
  for key, redData in pairs(redDatas) do
    local parentNode = RedDotMgr.redPointData[key]
    for _, v in pairs(redData.ChildrenID) do
      table.insert(parentNode.ChildrenIds, v)
      local node = RedDotMgr.redPointData[v]
      if node then
        node.ParentIds[parentNode.NodeId] = parentNode.NodeId
      end
    end
  end
end

function RedDotMgr.Init()
  RedDotMgr.redPointData = {}
  local redDotIndexCfg = Z.TableMgr.GetTable("RedDotIndexTableMgr")
  local redDatas = redDotIndexCfg.GetDatas()
  for _, redData in pairs(redDatas) do
    if redData.FunctionId ~= 0 and RedDotMgr.functionRedIds[redData.FunctionId] == nil then
      RedDotMgr.functionRedIds[redData.FunctionId] = redData.Id
    end
    RedDotMgr.createLogicNode(redData, redData.Id)
  end
  RedDotMgr.buildRedNodesTree(redDatas)
end

function RedDotMgr:UnInit()
  for key, node in pairs(RedDotMgr.redPointData) do
    node:UnInit()
  end
  RedDotMgr.redPointData = {}
end

function RedDotMgr.LoadRedDotItem(nodeId, uiView, redParent)
  if redParent == nil or uiView == nil or nodeId == nil then
    return
  end
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node == nil then
    return
  end
  node:LoadRedDotUIItems(uiView, redParent)
end

function RedDotMgr.RecordParentNodeMapping(redParent, nodeId)
  if not redParent or not nodeId then
    logError("Invalid parameters for RecordParentNodeMapping")
    return
  end
  if not RedDotMgr.parentNodeMap then
    RedDotMgr.parentNodeMap = {}
  end
  if not RedDotMgr.parentNodeMap[redParent] then
    RedDotMgr.parentNodeMap[redParent] = {}
  end
  RedDotMgr.parentNodeMap[redParent][nodeId] = true
end

function RedDotMgr.RemoveParentNodeMapping(nodeId, parentTrans)
  if not (nodeId and parentTrans) or not RedDotMgr.parentNodeMap then
    return
  end
  if RedDotMgr.parentNodeMap[parentTrans] then
    RedDotMgr.parentNodeMap[parentTrans][nodeId] = nil
    if not next(RedDotMgr.parentNodeMap[parentTrans]) then
      RedDotMgr.parentNodeMap[parentTrans] = nil
    end
  end
end

function RedDotMgr.UpdateNodeCount(nodeId, count, notUpdateState)
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node then
    if node.Num == count and count == 0 and not node.State then
      return
    end
    if notUpdateState and count ~= 0 then
      node:UpdateNodeData(count, false)
    else
      node:UpdateNodeData(count, true)
    end
  end
end

function RedDotMgr.AdjustNodeCount(nodeId, deltaCount, isUpdateState)
  assert(type(deltaCount) == "number", "deltaCount\229\191\133\233\161\187\228\184\186\230\149\176\229\128\188\231\177\187\229\158\139")
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node then
    local num = node.Num or 0
    local count = num + deltaCount
    node:UpdateNodeData(count, isUpdateState)
  end
end

function RedDotMgr.RemoveNodeItem(nodeId, view)
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node then
    node:HideRedDotItems(node, view)
  end
end

function RedDotMgr.RemoveChildernNodeItem(parent, view)
  if not parent or not view then
    return
  end
  local nodes = RedDotMgr.parentNodeMap[parent]
  if not nodes then
    return
  end
  for nodeId, _ in pairs(nodes) do
    local node = RedDotMgr.CheckNodeIsNil(nodeId)
    if node then
      node:RemoveNodeItemUIByParentTrans(parent, view)
    end
  end
  RedDotMgr.parentNodeMap[parent] = nil
end

function RedDotMgr.RemoveChildNodeData(parentNodeId, childNodeId)
  local node = RedDotMgr.CheckNodeIsNil(childNodeId)
  if node then
    if node.ChildNodeIds then
      logError("\232\175\165\232\138\130\231\130\185\230\156\137\229\173\144\232\138\130\231\130\185\239\188\140\228\184\141\232\131\189\229\136\160\233\153\164")
      return
    end
    if node.ParentIds then
      for k, v in pairs(node.ParentIds) do
        local node = RedDotMgr.CheckNodeIsNil(v)
        if node and node.ChildrenIds then
          table.zremoveByValue(node.ChildrenIds, childNodeId)
        end
      end
    end
    node:UnInit()
    RedDotMgr.redPointData[childNodeId] = nil
  end
end

function RedDotMgr.ResetAllChildNodeCount(parentNodeId)
  local node = RedDotMgr.CheckNodeIsNil(parentNodeId)
  if node then
    for i, v in ipairs(node.ChildrenIds) do
      RedDotMgr.UpdateNodeCount(v, 0)
    end
  end
end

function RedDotMgr.AddChildNodeData(parentNodeId, templateNodeCfgId, childNodeId, checkFunc)
  local childNode = RedDotMgr.redPointData[childNodeId]
  local parentNode = RedDotMgr.CheckNodeIsNil(parentNodeId)
  if childNode then
    if parentNode then
      if not table.zcontains(parentNode.ChildrenIds, childNodeId) then
        table.insert(parentNode.ChildrenIds, childNodeId)
      end
      childNode.ParentIds[parentNodeId] = parentNodeId
    end
    return
  end
  if parentNode then
    table.insert(parentNode.ChildrenIds, childNodeId)
    RedDotMgr.createLogicNode(Z.TableMgr.GetTable("RedDotIndexTableMgr").GetRow(templateNodeCfgId), childNodeId)
    local node = RedDotMgr.redPointData[childNodeId]
    node:SetCheckFunc(checkFunc)
    node.ParentIds[parentNodeId] = parentNodeId
  end
end

function RedDotMgr.GetRedState(nodeId)
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node then
    return node.State
  end
  return false
end

function RedDotMgr.RefreshRedNodeState(nodeId)
  local node = RedDotMgr.CheckNodeIsNil(nodeId)
  if node then
    node:UpdateNodeState()
    node:updateParentsNodeData()
  end
end

function RedDotMgr.AsyncCancelRedDot(redDotId)
  local worldProxy = require("zproxy.world_proxy")
  local CancelRedDotParam = {redDotId = redDotId}
  worldProxy.CancelRedDot(CancelRedDotParam)
end

return RedDotMgr
