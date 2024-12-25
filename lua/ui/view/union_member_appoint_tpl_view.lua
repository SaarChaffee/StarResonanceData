local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_member_appoint_tplView = class("Union_member_appoint_tplView", super)
local loopListView = require("ui.component.loop_list_view")
local UnionPositionMemberItem = require("ui.component.union.union_position_member_item")

function Union_member_appoint_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_member_appoint_tpl", "union/union_member_appoint_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_member_appoint_tplView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:BindEvents()
  self:initLoopListView()
end

function Union_member_appoint_tplView:OnDeActive()
  self:UnBindEvents()
  self:unInitLoopListView()
end

function Union_member_appoint_tplView:OnRefresh()
end

function Union_member_appoint_tplView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.looplist_appoint, UnionPositionMemberItem, "union_position_member_tpl")
  local memberList = self.unionData_:GetDefaultSortMemberListData()
  self.loopListView_:Init(memberList)
end

function Union_member_appoint_tplView:refreshLoopListView()
  local memberList = self.unionData_:GetDefaultSortMemberListData()
  self.loopListView_:RefreshListView(memberList)
end

function Union_member_appoint_tplView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_member_appoint_tplView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateMemberData, self.refreshLoopListView, self)
end

function Union_member_appoint_tplView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateMemberData, self.refreshLoopListView, self)
end

return Union_member_appoint_tplView
