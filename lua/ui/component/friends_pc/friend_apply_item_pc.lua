local super = require("ui.component.loop_list_view_item")
local FriendApplyItemPC = class("FriendApplyItemPC", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendApplyItemPC:OnInit()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.idCardVM_ = Z.VMMgr.GetVM("idcard")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.uiBinder.node_head.img_bg:AddListener(function()
    self:showIdCard()
  end)
  self.uiBinder.btn_cancel:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), false, "", self.friendMainData_.CancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.btn_ok:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), true, "", self.friendMainData_.CancelSource:CreateToken())
    end)()
  end)
end

function FriendApplyItemPC:OnRefresh(data)
  self.data_ = data
  self.socialData_ = data:GetSocialData()
  if not self.socialData_ then
    Z.CoroUtil.create_coro_xpcall(function()
      local mask = self.socialVm_.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
      mask = self.socialVm_.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAvatar, mask)
      mask = self.socialVm_.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, mask)
      mask = self.socialVm_.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeWeapon, mask)
      self.socialData_ = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
      self.data_:SetSocialData(self.socialData_)
      self:refreshItemData()
    end)()
  else
    self:refreshItemData()
  end
end

function FriendApplyItemPC:refreshItemData()
  self:refreshHeadByHeadId()
  self:refreshProfession()
  self:refreshLevel()
  self:refreshPlayerName()
  self:refreshApplyInfo()
  self:refreshPlayerState()
end

function FriendApplyItemPC:OnSelected(isSelected, isClick)
end

function FriendApplyItemPC:refreshHeadByHeadId()
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_head, self.socialData_, nil, self.parent.UIView.cancelSource:CreateToken())
end

function FriendApplyItemPC:showIdCard()
  Z.CoroUtil.create_coro_xpcall(function()
    self.idCardVM_.AsyncGetCardData(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
  end)()
end

function FriendApplyItemPC:refreshProfession()
  local professionId = 0
  if self.socialData_.professionData then
    professionId = self.socialData_.professionData.professionId
  end
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId, true)
  if not professionRow then
    return
  end
  self.uiBinder.img_profession:SetImage(professionRow.Icon)
end

function FriendApplyItemPC:refreshLevel()
  self.uiBinder.lab_grade.text = Lang("Level", {
    val = self.socialData_.basicData.level
  })
end

function FriendApplyItemPC:refreshPlayerName()
  local name = ""
  if self.socialData_.basicData then
    name = self.socialData_.basicData.name
  end
  self.uiBinder.lab_name.text = name
end

function FriendApplyItemPC:refreshApplyInfo()
  if self.data_:GetApplySource() == E.FriendAddSource.ESearch then
    self.uiBinder.lab_info.text = Lang("FriendSearchSourceSearch")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EIdcard then
    self.uiBinder.lab_info.text = Lang("FriendSearchSourceIdcard")
  elseif self.data_:GetApplySource() == E.FriendAddSource.ESuggestion then
    self.uiBinder.lab_info.text = Lang("FriendSearchSourceESuggestion")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EDungeon then
    self.uiBinder.lab_info.text = Lang("Dungeon")
  elseif self.data_:GetApplySource() == E.FriendAddSource.EPersonalzone then
    self.uiBinder.lab_info.text = Lang("SpaceOfPersonality")
  else
    self.uiBinder.lab_info.text = ""
  end
end

function FriendApplyItemPC:refreshPlayerState()
  local offlineTime = self.socialData_.basicData.offlineTime
  local personalState = self.socialData_.basicData.personalState
  local persData
  if personalState then
    persData = self.friendsMainVm_.GetFriendsStatus(offlineTime, personalState)
  else
    local chatStatusTableMgr = Z.TableMgr.GetTable("ChatStatusTableMgr")
    if offlineTime == 0 then
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOnline, true)
    else
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOutLine, true)
    end
  end
  if persData then
    self.uiBinder.lab_state.text = persData.StatusName
    self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, persData.Res))
  end
end

return FriendApplyItemPC
