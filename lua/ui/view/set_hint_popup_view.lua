local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_hint_popupView = class("Set_hint_popupView", super)

function Set_hint_popupView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_hint_popup", "set/set_hint_popup", UI.ECacheLv.None)
end

function Set_hint_popupView:OnActive()
  self.uiBinder.set_hint_popup:SetSizeDelta(0, 0)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeTipsView()
    end
  end, nil, nil)
  self:BindEvents()
end

function Set_hint_popupView:OnDeActive()
  if not self.IsActive then
    return
  end
  self.uiBinder.presscheck:StopCheck()
  self:UnBindEvents()
end

function Set_hint_popupView:OnRefresh()
  self.viewData.extraParams = self.viewData.extraParams or {}
  self:setProperty()
  self:setStyle()
  self:setNode()
end

function Set_hint_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.TipsRefreshNode, self.refreshNodeData, self)
  Z.EventMgr:Add(Z.ConstValue.UnderLineTipsClose, self.setProperty, self)
end

function Set_hint_popupView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.TipsRefreshNode, self.refreshNodeData, self)
  Z.EventMgr:Remove(Z.ConstValue.UnderLineTipsClose, self.setProperty, self)
end

function Set_hint_popupView:setNode()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitNode()
    self:setPosition()
    self:startAnimatedShow()
  end)()
end

function Set_hint_popupView:closeTipsView()
  if not self.IsActive then
    return
  end
  if self.viewData.extraParams.closeCallBack then
    self.viewData.extraParams.closeCallBack()
  end
  self:DeActive()
end

function Set_hint_popupView:refreshNodeData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.timerMgr:Clear()
    self:ClearAllUnits()
    self:asyncInitNode()
    self:setPosition()
  end)()
end

function Set_hint_popupView:asyncInitNode()
  for index, nodeData in ipairs(self.viewData.nodeDataList) do
    local funcGenerate = self["generateNodeByType" .. nodeData.Type]
    if funcGenerate then
      funcGenerate(self, nodeData, index)
    end
  end
end

function Set_hint_popupView:setPosition()
  if self.viewData.posTrans then
    self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.posTrans.position)
  end
  local posSource = self.uiBinder.img_bg.anchoredPosition
  local posResult = posSource + self.viewData.posOffset
  self.uiBinder.img_bg:SetAnchorPosition(posResult.x, posResult.y)
end

function Set_hint_popupView:setProperty()
end

function Set_hint_popupView:setStyle()
end

function Set_hint_popupView:generateNodeByType1(nodeData, index, targetNode)
  local titleData = nodeData
  local path = self:GetPrefabCacheDataNew(self.uiBinder.set_hint_popup_pcd, "set_tips_tpl")
  local node = targetNode or self:AsyncLoadUiUnit(path, "set_tips_tpl" .. index, self.uiBinder.node_info.transform, self.cancelSource:CreateToken())
  if node ~= nil then
    self:setLabelText(node.lab_title, titleData.Title)
    self:setLabelText(node.lab_title_addition, titleData.TitleAddition)
  end
end

function Set_hint_popupView:generateNodeByType3(nodeData, index)
  local descData = nodeData
  local path = self:GetPrefabCacheDataNew(self.uiBinder.set_hint_popup_pcd, "set_tips_tpl")
  local node = self:AsyncLoadUiUnit(path, "set_tips_tpl" .. index, self.uiBinder.node_info.transform, self.cancelSource:CreateToken())
  if node ~= nil then
    self:setLabelText(node, node.lab_equip_basics, descData.Desc)
  end
end

function Set_hint_popupView:setLabelText(node, lab_equip_basics, str)
  if str == nil or str == "" then
    node.Ref.UIComp:SetVisible(false)
  else
    lab_equip_basics.text = str
    node.Ref.UIComp:SetVisible(true)
  end
end

function Set_hint_popupView:startAnimatedShow()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Set_hint_popupView:startAnimatedHide()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

return Set_hint_popupView
