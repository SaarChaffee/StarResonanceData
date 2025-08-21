local RedDotStyleBaseItem = class("Style")
local Positions = {
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

function RedDotStyleBaseItem:ctor(node)
  self.Node = node
  self.styleType_ = nil
  self.uiItems_ = {}
end

function RedDotStyleBaseItem:Init()
  self:OnInit()
end

function RedDotStyleBaseItem:UnInit()
  self:OnUnInit()
  self:removeAllNodeItemUI()
  self.styleType_ = nil
  self.Node = nil
end

function RedDotStyleBaseItem:refreshNodeTrans(redDotItem, node, redParent)
  redDotItem.Ref:SetParent(redParent)
  local type = node.OffSet[1]
  local offsetX = node.OffSet[2]
  local offsetY = node.OffSet[3]
  if Z.IsPCUI and node.PCOffSet[1] and node.PCOffSet[2] then
    offsetX = node.PCOffSet[1]
    offsetY = node.PCOffSet[2]
  end
  local position = Positions[type]
  redDotItem.Ref:SetPosition(offsetX, offsetY)
  if position then
    local x = position.x
    local y = position.y
    redDotItem.Ref:SetAnchors(x, x, y, y)
    redDotItem.Ref:SetPivot(x, y)
  end
end

function RedDotStyleBaseItem:LoadRedDotUI(uiView, redParent)
  if self.uiItems_[uiView] == nil then
    self.uiItems_[uiView] = {}
  end
  if self.uiItems_[uiView][redParent] == nil then
    self.uiItems_[uiView][redParent] = nil
  end
  local nodeUIUnit
  local nodeId = self.Node.NodeId
  local concatTable = {
    "red",
    nodeId,
    self.styleType_,
    redParent.name
  }
  local nodeName = table.concat(concatTable, "_")
  uiView:RemoveUiUnit(nodeName)
  local path
  if Z.IsPCUI then
    path = Z.ConstValue.RedDotPCUIStyleAssetPaths[self.styleType_]
  else
    path = Z.ConstValue.RedDotUIStyleAssetPaths[self.styleType_]
  end
  if path then
    nodeUIUnit = uiView:AsyncLoadRedUiUnit(nodeId, path, nodeName, redParent)
  end
  if nodeUIUnit then
    self.uiItems_[uiView][redParent] = {nodeName = nodeName, nodeUIUnit = nodeUIUnit}
    self:refreshNodeTrans(nodeUIUnit, self.Node, redParent)
  end
end

function RedDotStyleBaseItem:UpdateRedDotUI()
  if self.uiItems_ == nil then
    return
  end
  for _, redDotUIItems in pairs(self.uiItems_) do
    for _, redDotItem in pairs(redDotUIItems) do
      if redDotItem.nodeUIUnit == nil then
        logError("RedDotStyleBaseItem:UpdateRedDotUI redDotItem.nodeUIUnit is nil " .. redDotItem.nodeName)
      else
        self:Update(redDotItem.nodeUIUnit)
      end
    end
  end
end

function RedDotStyleBaseItem:HideRedDotUI(view)
  if not self.uiItems_ or not next(self.uiItems_) then
    return
  end
  for uiView, parentTabs in pairs(self.uiItems_) do
    if view == uiView or view == nil then
      for parentTrans, redDotItem in pairs(parentTabs) do
        if view then
          self:RemoveNodeItemUIByParentTrans(parentTrans, view)
        else
          self:Hide(redDotItem.nodeUIUnit)
        end
      end
    end
  end
  if view then
    self.uiItems_[view] = {}
  else
    self.uiItems_ = {}
  end
end

function RedDotStyleBaseItem:RemoveNodeItemUIByParentTrans(parentTrans, view)
  if view == nil or parentTrans == nil then
    return
  end
  if self.uiItems_ == nil or self.uiItems_[view] == nil or self.uiItems_[view][parentTrans] == nil then
    return
  end
  local uiItem = self.uiItems_[view][parentTrans]
  if uiItem then
    view:RemoveUiUnit(uiItem.nodeName)
  end
  self.uiItems_[view][parentTrans] = nil
  Z.RedPointMgr.RemoveParentNodeMapping(self.Node.NodeId, parentTrans)
end

function RedDotStyleBaseItem:removeAllNodeItemUI()
  if self.uiItems_ == nil or not next(self.uiItems_) then
    return
  end
  for view, parentTabs in pairs(self.uiItems_) do
    for parentTrans, uiItem in pairs(parentTabs) do
      if view == nil then
        logError("RedDotSylteItem:RemoveAllNodeItemUI view is nil")
      else
        self:RemoveNodeItemUIByParentTrans(parentTrans, view)
      end
    end
  end
  self.uiItems_ = {}
end

function RedDotStyleBaseItem:Update(redDotItem)
end

function RedDotStyleBaseItem:Hide(redDotItem)
end

function RedDotStyleBaseItem:OnInit()
end

function RedDotStyleBaseItem:OnUnInit(...)
end

return RedDotStyleBaseItem
