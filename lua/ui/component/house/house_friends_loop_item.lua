local super = require("ui.component.loop_list_view_item")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local HouseFriendsLoopItem = class("HouseFriendsLoopItem", super)

function HouseFriendsLoopItem:OnInit()
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.data_ = {}
  self.friendNode1_ = self.uiBinder.house_meet_conditions_tpl_1
  self.friendNode2_ = self.uiBinder.house_meet_conditions_tpl_2
  self.uiView_ = self.parent.UIView
  self.uiView_:AddAsyncClick(self.friendNode1_.btn_add, function()
    self:asyncInviteCohabitant(self.data_.friendInfo1)
  end)
  self.uiView_:AddAsyncClick(self.friendNode2_.btn_add, function()
    self:asyncInviteCohabitant(self.data_.friendInfo2)
  end)
end

function HouseFriendsLoopItem:OnRefresh(data)
  self.data_ = data
  self:refreshFriendNode(self.friendNode1_, data.friendInfo1)
  if data.friendInfo2 then
    self.friendNode2_.Ref.UIComp:SetVisible(true)
    self:refreshFriendNode(self.friendNode2_, data.friendInfo2)
  else
    self.friendNode2_.Ref.UIComp:SetVisible(false)
  end
end

function HouseFriendsLoopItem:refreshFriendNode(friendNode, friendInfo)
  local friendlinessCondition = Z.GlobalHome.HouseLivetogetherFriendshipValue
  if friendInfo.socialData == nil then
    logError("socialData is nil")
  else
    friendNode.lab_name.text = friendInfo.socialData.basicData.name
  end
  friendNode.lab_content.text = Lang("FriendlinessCondition", {
    val1 = friendInfo.friendliness,
    val2 = friendlinessCondition
  })
  friendNode.lab_invited.text = Lang("Invited")
  friendNode.Ref:SetVisible(friendNode.lab_invited, friendInfo.isInvited)
  friendNode.Ref:SetVisible(friendNode.btn_add, self.data_.isSatisfy and not friendInfo.hasCohabitant and not friendInfo.isInvited)
  PlayerPortraitHgr.InsertNewPortraitBySocialData(friendNode.binder_head, friendInfo.socialData, nil, self.uiView_.cancelSource:CreateToken())
end

function HouseFriendsLoopItem:asyncInviteCohabitant(friendInfo)
  if friendInfo == nil or friendInfo.socialData == nil then
    return
  end
  self.houseVm_.AsyncInvitationCohabitant(friendInfo.socialData.basicData.charID, self.uiView_.cancelSource:CreateToken())
end

function HouseFriendsLoopItem:OnUnInit()
end

return HouseFriendsLoopItem
