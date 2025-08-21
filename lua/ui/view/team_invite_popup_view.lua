local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_invite_popupView = class("Team_invite_popupView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local inviteLoopItem = require("ui.component.team.invite_loop_item")

function Team_invite_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_invite_popup")
end

function Team_invite_popupView:OnActive()
  self:initBinder()
  self:AddClick(self.btn_close_, function()
    self.teamInviteVM_.CloseInviteView()
  end)
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:startAnimatedShow()
  self.teamInviteVM_ = Z.VMMgr.GetVM("team_invite_popup")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.lab_title_.text = Lang("InviteTeamMember")
  self.inviteLoopScrollRect_ = loopScrollRect.new(self.loopscroll_, self, inviteLoopItem)
  self:setTog()
  self:BindEvents()
end

function Team_invite_popupView:OnDeActive()
  self:clearTog()
end

function Team_invite_popupView:initBinder()
  self.togGroup_ = self.uiBinder.group_tog
  self.friendTog_ = self.uiBinder.tog_friend
  self.UnionTog_ = self.uiBinder.tog_union
  self.nearbtTog_ = self.uiBinder.tog_nearby
  self.scenemask_ = self.uiBinder.scenemask
  self.anim_ = self.uiBinder.anim
  self.loopscroll_ = self.uiBinder.loopscroll
  self.btn_close_ = self.uiBinder.btn_close
  self.node_empty_black_ = self.uiBinder.node_empty_black
  self.lab_title_ = self.uiBinder.lab_title
end

function Team_invite_popupView:setTog()
  self.loopscroll_:ClearCells()
  self.togList_ = {
    self.friendTog_,
    self.UnionTog_,
    self.nearbtTog_
  }
  for i = 1, 3 do
    self:initTog(self.togList_[i], i)
  end
  self.friendTog_.tog_item.isOn = true
end

function Team_invite_popupView:initTog(uibinder, type)
  uibinder.Ref.UIComp:SetVisible(true)
  uibinder.tog_item.group = self.togGroup_
  uibinder.tog_item:AddListener(function(isOn)
    if isOn then
      self:initData(type)
    end
  end)
end

function Team_invite_popupView:clearTog()
  self.friendTog_.tog_item:RemoveAllListeners()
  self.UnionTog_.tog_item:RemoveAllListeners()
  self.nearbtTog_.tog_item:RemoveAllListeners()
  self.friendTog_.tog_item.group = nil
  self.UnionTog_.tog_item.group = nil
  self.nearbtTog_.tog_item.group = nil
  self.friendTog_.tog_item.isOn = false
  self.UnionTog_.tog_item.isOn = false
  self.nearbtTog_.tog_item.isOn = false
end

function Team_invite_popupView:initData(inviteType)
  local list = {}
  if inviteType == E.TeamInviteType.Friend then
    list = self.friendMainData_:GetOnlineFriendList()
  elseif inviteType == E.TeamInviteType.Guild then
    local memberList = self.unionVM_:GetOnlineMemberList()
    for i = 1, #memberList do
      if memberList[i].socialData.basicData.charID ~= Z.ContainerMgr.CharSerialize.charBase.charId then
        list[#list + 1] = memberList[i].socialData.basicData.charID
      end
    end
  elseif inviteType == E.TeamInviteType.Near then
    list = self.teamInviteVM_.GetNearPlayerList()
  end
  local members = self.teamData_.TeamInfo.members
  if members and next(members) ~= nil then
    for i = #list, 1, -1 do
      if members[list[i]] then
        table.remove(list, i)
      end
    end
  end
  self.inviteLoopScrollRect_:SetData(list, true, nil, 0)
  self.uiBinder.Ref:SetVisible(self.node_empty_black_, #list == 0)
end

function Team_invite_popupView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Team_invite_popupView:updateInviteBtn(charId)
  local activeItems = self.inviteLoopScrollRect_:GetActiveItems()
  for _, v in pairs(activeItems) do
    v:refreshBtnInteractable(charId)
  end
end

function Team_invite_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateInviteBtn, self.updateInviteBtn, self)
end

return Team_invite_popupView
