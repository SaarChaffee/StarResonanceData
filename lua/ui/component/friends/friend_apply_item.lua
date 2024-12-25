local super = require("ui.component.loopscrollrectitem")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FriendApplyItem = class("FriendApplyItem", super)

function FriendApplyItem:ctor()
end

function FriendApplyItem:OnInit()
end

function FriendApplyItem:Refresh()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), false, "", self.parent.uiView.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.img_bg, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_:GetCharId(), self.parent.uiView.cancelSource:CreateToken())
  end)
  if self.data_:GetApplySource() == E.FriendAddSource.ESearch then
    self.uiBinder.lab_seek.text = Lang("FriendSearchSourceSearch")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EIdcard then
    self.uiBinder.lab_seek.text = Lang("FriendSearchSourceIdcard")
  elseif self.data_:GetApplySource() == E.FriendAddSource.ESuggestion then
    self.uiBinder.lab_seek.text = Lang("FriendSearchSourceESuggestion")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EDungeon then
    self.uiBinder.lab_seek.text = Lang("Dungeon")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EPersonalzone then
    self.uiBinder.lab_seek.text = Lang("SpaceOfPersonality")
  else
    self.uiBinder.lab_seek.text = ""
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(self.data_:GetCharId(), self.parent.uiView.cancelSource:CreateToken())
    if not (socialData and socialData.basicData) or not socialData.avatarInfo then
      return
    end
    if self.uiBinder == nil then
      return
    end
    self.uiBinder.lab_play_name.text = socialData.basicData.name
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
    playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, socialData)
    self.uiBinder.lab_grade.text = Lang("Lv") .. socialData.basicData.level
    self:AddAsyncClick(self.uiBinder.btn_ok, function()
      self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), true, socialData.basicData.name, self.parent.uiView.cancelSource:CreateToken())
    end)
  end)()
end

function FriendApplyItem:Selected(isSelected)
end

function FriendApplyItem:onSelectedGroup()
end

function FriendApplyItem:OnUnInit()
end

function FriendApplyItem:OnReset()
end

return FriendApplyItem
