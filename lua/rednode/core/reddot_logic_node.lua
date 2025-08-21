local RedDotStyleNodeClassMap = {
  [E.RedDotStyleType.Normal] = require("rednode.core.uistylenode.normal_red_style_item"),
  [E.RedDotStyleType.Image] = require("rednode.core.uistylenode.normal_red_style_item"),
  [E.RedDotStyleType.Number] = require("rednode.core.uistylenode.number_red_style_item"),
  [E.RedDotStyleType.CEffect] = require("rednode.core.uistylenode.c_effect_red_style_item"),
  [E.RedDotStyleType.UEffect] = require("rednode.core.uistylenode.u_effect_red_style_item")
}
local RedDotLogicNode = class("RedDotLogicNode")

function RedDotLogicNode:ctor(redDotIndexTableRow, nodeId)
  if redDotIndexTableRow == nil then
    return
  end
  self.NodeId = nodeId
  self.ParentIds = {}
  self.ChildrenIds = {}
  self.State = false
  self.StyleTypes = redDotIndexTableRow.ShowType
  self.LoseType = redDotIndexTableRow.LoseCheck
  self.OffSet = redDotIndexTableRow.OffSet
  self.PCOffSet = redDotIndexTableRow.PCOffSet
  self.Num = 0
  self.RedDotStyleUIItems = {}
  self.Arguments = redDotIndexTableRow.Arguments
  self.FunctionId = redDotIndexTableRow.FunctionId
  for _, nodeType in ipairs(self.StyleTypes) do
    local redStyleUI = RedDotStyleNodeClassMap[nodeType].new(self)
    self.RedDotStyleUIItems[nodeType] = redStyleUI
  end
end

function RedDotLogicNode:Init()
end

function RedDotLogicNode:UnInit()
  for _, redDotStyleUIItem in pairs(self.RedDotStyleUIItems) do
    redDotStyleUIItem:UnInit()
  end
end

function RedDotLogicNode:LoadRedDotUIItems(uiView, redParent)
  Z.CoroUtil.create_coro_xpcall(function()
    Z.RedPointMgr.RecordParentNodeMapping(redParent, self.NodeId)
    for _, redDotStyleUIItem in pairs(self.RedDotStyleUIItems) do
      redDotStyleUIItem:LoadRedDotUI(uiView, redParent)
    end
    self:updateNodeUI()
  end)()
end

function RedDotLogicNode:updateRedDotItems(node)
  if node == nil then
    node = self
  end
  for k, v in pairs(node.RedDotStyleUIItems) do
    v:UpdateRedDotUI()
  end
end

function RedDotLogicNode:HideRedDotItems(node, view)
  if node == nil then
    node = self
  end
  for k, v in pairs(node.RedDotStyleUIItems) do
    v:HideRedDotUI(view)
  end
end

function RedDotLogicNode:updateNodeUI()
  local outType = self.LoseType[1]
  if outType == 1 then
  end
  local isShow = false
  self:updateRedDotItems(self)
  if self.ChildNodeIds == nil then
    return
  end
  for _, childrenId in pairs(self.ChildNodeIds) do
    local childrenNode = Z.RedPointMgr.CheckNodeIsNil(childrenId)
    self:HideRedDotItems(childrenNode)
    if childrenNode and childrenNode.State and childrenNode.State and not isShow then
      isShow = true
      self:updateRedDotItems(childrenNode)
    end
  end
end

function RedDotLogicNode:UpdateNodeData(value, isUpdateState)
  self:refreshNodeNum(value, isUpdateState)
  self:updateParentsNodeData()
end

function RedDotLogicNode:refreshNodeNum(value, isUpdateState)
  value = math.max(0, value)
  self.Num = value
  if self.LoseType[1] == 3 then
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Character, "BKL_REDDOTRED" .. self.NodeId)
  end
  if isUpdateState then
    self:UpdateNodeState()
  end
end

function RedDotLogicNode:UpdateNodeState()
  local isActive = self.Num > 0
  if isActive then
    isActive = self:checkFuncIsOn(self.FunctionId)
    if self.LoseType[1] == 2 then
      self.State = self:getNodeIsPermanentClose(self.NodeId)
    end
  end
  if isActive and self.CheckFunction then
    isActive = self.CheckFunction()
  end
  self.State = isActive
  self:updateNodeUI()
end

function RedDotLogicNode:getNodeIsPermanentClose()
  if Z.ContainerMgr.CharSerialize.redDot.permanentClosedRedDot[self.NodeId] then
    return false
  end
  return true
end

function RedDotLogicNode:checkFuncIsOn(functionId)
  if functionId and functionId ~= 0 then
    local funcVM = Z.VMMgr.GetVM("gotofunc")
    return funcVM.FuncIsOn(functionId, true)
  end
  return true
end

function RedDotLogicNode:SetCheckFunc(checkFunc)
  self.CheckFunction = checkFunc
end

function RedDotLogicNode:updateParentsNodeData()
  if self.ParentIds == nil or table.zcount(self.ParentIds) < 1 then
    return
  end
  for _, parentNodeId in pairs(self.ParentIds) do
    local node = Z.RedPointMgr.CheckNodeIsNil(parentNodeId)
    if node == nil then
      return
    end
    node.Num = 0
    for _, childId in ipairs(node.ChildrenIds) do
      local childNode = Z.RedPointMgr.CheckNodeIsNil(childId)
      if childNode and childNode.State then
        node.Num = childNode.Num + node.Num
      end
    end
    node:UpdateNodeState()
    node:updateParentsNodeData()
  end
end

function RedDotLogicNode:RemoveNodeItemUIByParentTrans(parentTrans, view)
  for k, v in pairs(self.RedDotStyleUIItems) do
    v:RemoveNodeItemUIByParentTrans(parentTrans, view)
  end
end

function RedDotLogicNode:OnClickRedDot()
  if self.State == false then
    return
  end
  local isHide = true
  local outType = self.LoseType[1]
  local checkType = self.LoseType[2]
  local childNodeId = self.LoseType[3]
  if checkType == 1 then
    logError("\230\156\170\229\174\158\231\142\176 checkType == 1")
  end
  if checkType == 2 then
    local childNode = Z.RedPointMgr.CheckNodeIsNil(childNodeId)
    if childNode then
      isHide = childNode.State
    end
  end
  if checkType == 3 then
    isHide = self.State
  end
  self.State = isHide
  self:updateNodeUI()
  self:updateParentsNodeData()
  if isHide == false then
    if outType == 1 then
    end
    if outType == 2 then
      Z.RedPointMgr.AsyncPermanentCloseRedDot(self.NodeId)
    end
    if outType == 3 then
      local serverTime = Z.TimeTools.Now()
      Z.LocalUserDataMgr.SetLongByLua(E.LocalUserDataType.Character, "BKL_REDDOTRED" .. self.NodeId, serverTime)
      local time = Z.RedPointMgr.GetReaminSecondsTo24(serverTime)
      if 0 < time then
        Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.RedDotPoint, function()
          Z.RedPointMgr.RefreshAllNode()
        end, time, 1)
      end
    end
  end
end

return RedDotLogicNode
