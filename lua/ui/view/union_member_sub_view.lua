local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_member_subView = class("Union_member_subView", super)
local loopListView = require("ui.component.loop_list_view")
local unionMemberListItem = require("ui.component.union.union_member_list_item")

function Union_member_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_member_sub", "union/union_member_sub", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_member_subView:initComponent()
  self.binderSortItemDict_ = {
    [E.UnionMemberSortMode.Position] = self.uiBinder.binder_posts,
    [E.UnionMemberSortMode.RoleLevel] = self.uiBinder.binder_grade,
    [E.UnionMemberSortMode.Contribution] = self.uiBinder.binder_active,
    [E.UnionMemberSortMode.OfflineTime] = self.uiBinder.binder_state
  }
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, unionMemberListItem, "union_member_list_tpl")
  self.loopListView_:Init({})
  self:AddAsyncClick(self.uiBinder.btn_manage, function()
    self:onManagerBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_list, function()
    self:onApplyBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_quit, function()
    self:onQuitBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_mass, function()
    self:onChatBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_search_close, function()
    self:onSearchCloseBtnClick()
  end)
  self.uiBinder.input_name:AddListener(function(text)
    self:onInputChanged(text)
  end)
  for sortMode, binder in pairs(self.binderSortItemDict_) do
    self:AddClick(binder.btn_item, function()
      self:onSortItemClick(sortMode)
    end)
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionApplyButton, self, self.uiBinder.trans_list)
end

function Union_member_subView:initData()
  self.curMemberListData_ = {}
  self.curSortMode_ = E.UnionMemberSortMode.None
  self.curOrderMode_ = E.UnionMemberOrderMode.None
end

function Union_member_subView:onManagerBtnClick()
  self.unionVM_:OpenUnionPositionManagePopup(E.UnionPositionPopupType.PositionEdit, self.cancelSource:CreateToken())
end

function Union_member_subView:onApplyBtnClick()
  self.unionVM_:OpenUnionApplicationPopup(self.cancelSource:CreateToken())
end

function Union_member_subView:onQuitBtnClick()
  if #self.curMemberListData_ == 1 then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("UnionDissolveDialogTips"), function()
      local errCode = self.unionVM_:AsyncReqLeaveUnion(self.unionVM_:GetPlayerUnionId(), self.unionData_.CancelSource:CreateToken())
      if errCode == 0 then
        self.unionData_:Clear()
        Z.UIMgr:CloseView("union_main")
      end
    end)
  elseif self.unionVM_:IsPlayerUnionPresident() and #self.curMemberListData_ > 1 then
    Z.DialogViewDataMgr:OpenOKDialog(Lang("UnionPresidentLeaveDialogTips"))
  else
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("UnionLeaveDialogTips"), function()
      local errCode = self.unionVM_:AsyncReqLeaveUnion(self.unionVM_:GetPlayerUnionId(), self.unionData_.CancelSource:CreateToken())
      if errCode == 0 then
        self.unionData_:Clear()
        Z.UIMgr:CloseView("union_main")
      end
    end)
  end
end

function Union_member_subView:onChatBtnClick()
  self.unionVM_:CloseUnionMainView()
  Z.DataMgr.Get("chat_main_data"):SetChannelId(E.ChatChannelType.EChannelUnion)
  Z.VMMgr.GetVM("socialcontact_main").OpenChatView()
end

function Union_member_subView:onSearchCloseBtnClick()
  self.curMemberListData_ = self.unionData_:GetMemberListData(self.curSortMode_, self.curOrderMode_)
  self.uiBinder.input_name.text = ""
  self:refreshUI()
end

function Union_member_subView:onInputChanged(content)
  if content == "" then
    self.curMemberListData_ = self.unionData_:GetMemberListData(self.curSortMode_, self.curOrderMode_)
    self.uiBinder.input_name.text = ""
  else
    self.curMemberListData_ = self.unionData_:GetSearchMemberListData(content, self.curSortMode_, self.curOrderMode_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_search_close, true)
  end
  self:refreshUI()
end

function Union_member_subView:onSortItemClick(sortMode)
  self:sortList(sortMode)
  self:refreshUI()
end

function Union_member_subView:onEvtRefresh()
  local curSearchInput = self.uiBinder.input_name.text
  if curSearchInput == "" then
    self.curMemberListData_ = self.unionData_:GetMemberListData(self.curSortMode_, self.curOrderMode_)
  else
    self.curMemberListData_ = self.unionData_:GetSearchMemberListData(curSearchInput, self.curSortMode_, self.curOrderMode_)
  end
  self:refreshUI()
end

function Union_member_subView:sortList(sortMode)
  if self.curSortMode_ ~= sortMode then
    self.curSortMode_ = sortMode
    self.curOrderMode_ = E.UnionMemberOrderMode.Descending
  elseif self.curOrderMode_ == E.UnionMemberOrderMode.None then
    self.curOrderMode_ = E.UnionMemberOrderMode.Descending
  elseif self.curOrderMode_ == E.UnionMemberOrderMode.Ascending then
    self.curOrderMode_ = E.UnionMemberOrderMode.Descending
  else
    self.curOrderMode_ = E.UnionMemberOrderMode.Ascending
  end
  local curSearchInput = self.uiBinder.input_name.text
  if curSearchInput == "" then
    self.curMemberListData_ = self.unionData_:GetMemberListData(self.curSortMode_, self.curOrderMode_)
  else
    self.curMemberListData_ = self.unionData_:GetSearchMemberListData(curSearchInput, self.curSortMode_, self.curOrderMode_)
  end
end

function Union_member_subView:refreshUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_search_close, self.uiBinder.input_name.text ~= "")
  local rotation = self.curOrderMode_ == E.UnionMemberOrderMode.Ascending and 180 or 0
  for sortMode, binder in pairs(self.binderSortItemDict_) do
    binder.Ref:SetVisible(binder.trans_sort, sortMode == self.curSortMode_)
    binder.trans_sort:SetLocalRot(0, 0, rotation)
  end
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  local onlineNum = self.unionVM_:GetOnlineMemberCount()
  local totalNum = unionInfo.baseInfo.num
  local maxNum = unionInfo.baseInfo.maxNum
  self.uiBinder.lab_digit.text = Lang("UnionPeopleNum", {
    num1 = onlineNum,
    num2 = totalNum,
    num3 = maxNum
  })
  self.loopListView_:RefreshListView(self.curMemberListData_)
end

function Union_member_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self:initComponent()
  self:initData()
  self:BindEvents()
end

function Union_member_subView:OnDeActive()
  self:UnBindEvents()
  self.uiBinder.input_name.text = ""
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  self.binderSortItemDict_ = nil
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionApplyButton)
end

function Union_member_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.onEvtRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateMemberData, self.onEvtRefresh, self)
end

function Union_member_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.onEvtRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateMemberData, self.onEvtRefresh, self)
end

function Union_member_subView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.unionVM_:AsyncReqUnionMemsList(self.unionVM_:GetPlayerUnionId(), self.cancelSource:CreateToken())
    self.curMemberListData_ = self.unionData_:GetMemberListData(self.curSortMode_, self.curOrderMode_)
    self:refreshUI()
  end)()
end

function Union_member_subView:startAnimatedShow()
  self.uiBinder.tween_main:Restart(Z.DOTweenAnimType.Open)
end

return Union_member_subView
