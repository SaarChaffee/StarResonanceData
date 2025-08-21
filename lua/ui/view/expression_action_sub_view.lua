local UI = Z.UI
local super = require("ui.ui_subview_base")
local Expression_action_subView = class("Expression_action_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local expression_action_item_tpl = require("ui/component/expression/expression_action_item_tpl")

function Expression_action_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "expression_action_sub", "expression_pc/expression_action_sub", UI.ECacheLv.None)
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
end

function Expression_action_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, false)
  self.loopList_ = loopGridView.new(self, self.uiBinder.scrollview_emote, expression_action_item_tpl, "expression_action_item_tpl")
  self.loopList_:Init({})
  self:bindLuaAttrWatchers()
end

function Expression_action_subView:OnDeActive()
  self:unBindLuaAttrWatchers()
  if self.loopList_ then
    self.loopList_:UnInit()
    self.loopList_ = nil
  end
end

function Expression_action_subView:OnRefresh()
  if not self.viewData then
    self:setEmptyState(true)
  else
    self:setEmptyState(false)
    self:refreshLoopScrollRect(self.viewData)
  end
end

function Expression_action_subView:bindLuaAttrWatchers()
  function self.unlockTypeListChange(container, dirty)
    if dirty.unlockTypeList then
      self:refreshLoopScrollRect(self.viewData)
    end
  end
  
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:RegWatcher(self.unlockTypeListChange)
end

function Expression_action_subView:unBindLuaAttrWatchers()
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:UnregWatcher(self.unlockTypeListChange)
  self.unlockTypeListChange = nil
end

function Expression_action_subView:refreshLoopScrollRect(type)
  local data = self.expressionData_:GetExpressionData(type)
  self.loopList_:ClearAllSelect()
  if not data then
    data = {}
    self:setEmptyState(true)
  end
  self.loopList_:RefreshListView(data)
end

function Expression_action_subView:setEmptyState(isShowEmpty)
  local showText = self.viewData == E.ExpressionTabType.Collection and Lang("LongPressToAddAction") or Lang("NotAvailableActionHistory")
  self.uiBinder.lab_empty.text = showText
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_emote, not isShowEmpty)
end

return Expression_action_subView
