local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_application_popupView = class("Union_application_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local applicationItem = require("ui.component.union.union_application_item")

function Union_application_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_application_popup")
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function Union_application_popupView:initComponent()
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.unionVM_:CloseUnionApplicationPopup()
  end)
  self:AddAsyncClick(self.uiBinder.btn_refuse, function()
    self:oneKeyOperation(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:oneKeyOperation(true)
  end)
  local unionInfo = self.unionVM_:GetPlayerUnionInfo()
  self.uiBinder.tog_auto.isOn = unionInfo.autoPass
  self:AddAsyncClick(self.uiBinder.tog_auto, function()
    local autoPass = self.uiBinder.tog_auto.isOn
    self.unionVM_:AsyncSetUnionAutoPass(self.unionVM_:GetPlayerUnionId(), autoPass, self.cancelSource:CreateToken())
  end)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
end

function Union_application_popupView:initData()
  self.applicantDataList_ = {}
end

function Union_application_popupView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.looplist_appoint, applicationItem, "union_application_item_tpl")
  self.loopListView_:Init(self.applicantDataList_)
end

function Union_application_popupView:refreshLoopListView(resetPos)
  self.loopListView_:RefreshListView(self.applicantDataList_, resetPos)
end

function Union_application_popupView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_application_popupView:OnActive()
  self:startAnimatedShow()
  self:initComponent()
  self:initData()
  self:initLoopListView()
  self:bindEvents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:asyncQueryApplicationList()
end

function Union_application_popupView:OnDeActive()
  self:unInitLoopListView()
  self:unBindEvents()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Union_application_popupView:OnRefresh()
end

function Union_application_popupView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_application_popupView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_application_popupView:startAnimatedShow()
  self.uiBinder.tween_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_application_popupView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.tween_main.CoroPlay)
  coro(self.uiBinder.tween_main, Z.DOTweenAnimType.Close)
end

function Union_application_popupView:agreeOrReject(charId, agreeValue)
  local operationList = {}
  operationList[charId] = agreeValue
  local reply = self.unionVM_:AsyncApprovalRequest(self.unionVM_:GetPlayerUnionId(), operationList, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    self.applicantDataList_ = self:sortList(reply.reqList)
  end
  self:refreshUI(false)
end

function Union_application_popupView:oneKeyOperation(agreeValue)
  local operationList = {}
  for i = 1, #self.applicantDataList_ do
    operationList[self.applicantDataList_[i].socialData.basicData.charID] = agreeValue
  end
  local reply = self.unionVM_:AsyncApprovalRequest(self.unionVM_:GetPlayerUnionId(), operationList, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    self.applicantDataList_ = self:sortList(reply.reqList)
  end
  self:refreshUI(true)
end

function Union_application_popupView:refreshUI(resetPos)
  local isEmpty = #self.applicantDataList_ == 0
  local hasPower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.ProcessApplication)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_tog_bg, hasPower)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_btn_root, not isEmpty and hasPower)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_list, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_empty, isEmpty)
  self:refreshLoopListView(resetPos)
end

local sortFunc = function(l, r)
  local l_onlineState = l.socialData.basicData.offlineTime == 0 and 1 or 0
  local r_onlineState = r.socialData.basicData.offlineTime == 0 and 1 or 0
  if l_onlineState == r_onlineState then
    if l.applyInfo.requestTime == r.applyInfo.requestTime then
      return l.applyInfo.charId < r.applyInfo.charId
    else
      return l.applyInfo.requestTime > r.applyInfo.requestTime
    end
  else
    return l_onlineState > r_onlineState
  end
end

function Union_application_popupView:sortList(data)
  local onlineList = {}
  local offlineList = {}
  for i = 1, #data do
    if data[i].socialData.basicData.offlineTime == 0 then
      onlineList[#onlineList + 1] = data[i]
    else
      offlineList[#offlineList + 1] = data[i]
    end
    data[i].clickFunc = function(charId, agreeValue)
      self:agreeOrReject(charId, agreeValue)
    end
  end
  table.sort(onlineList, sortFunc)
  table.sort(offlineList, sortFunc)
  return table.zmerge(onlineList, offlineList)
end

function Union_application_popupView:asyncQueryApplicationList()
  Z.CoroUtil.create_coro_xpcall(function()
    local reply = self.unionVM_:AsyncGetRequestList(self.unionVM_:GetPlayerUnionId(), self.cancelSource:CreateToken())
    if reply.errCode == 0 then
      if reply.reqList then
        self.applicantDataList_ = self:sortList(reply.reqList)
      else
        self.applicantDataList_ = {}
      end
    else
      self.applicantDataList_ = {}
    end
    self:refreshUI(true)
  end)()
end

function Union_application_popupView:onOpenPrivateChat()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Union_application_popupView
