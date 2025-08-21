local super = require("ui.component.loop_list_view_item")
local playerPortraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FriendDataItemPC = class("FriendDataItemPC", super)

function FriendDataItemPC:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function FriendDataItemPC:OnRefresh(data)
  self.data_ = data.friendData
  self:refreshItemData()
  self.uiBinder.img_bg:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function FriendDataItemPC:OnSelected(isSelected, isClick)
  if isSelected then
    self.friendMainData_:SetAddressSelectCharId(self.data_:GetCharId())
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncInitInfo(self.data_)
      self:refreshItemData()
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.SocialDataUpdata)
    end)()
    self.parent.UIView:OnSelectFriend(self.data_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function FriendDataItemPC:refreshItemData()
  if not self.uiBinder then
    return
  end
  self:refreshHead()
  self:refreshName()
  self:refreshShowState(self.data_:GetPlayerOffLineTime(), self.data_:GetPlayerSceneId(), self.data_:GetPlayerPersonalState())
end

function FriendDataItemPC:refreshHead()
  playerPortraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_head, self.data_:GetSocialData(), nil, self.parent.UIView.cancelSource:CreateToken())
end

function FriendDataItemPC:refreshName()
  local name = ""
  if self.data_:GetRemark() == "" then
    name = self.data_:GetPlayerName()
  else
    name = self.data_:GetRemark()
  end
  self.uiBinder.lab_play_name.text = name
end

function FriendDataItemPC:refreshShowState(offTime, scenenId, personalState)
  if offTime == 0 then
    self.uiBinder.lab_time.text = ""
    if scenenId and scenenId ~= 0 then
      local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(scenenId)
      if sceneRow then
        self.uiBinder.lab_time.text = sceneRow.Name
      end
    end
    local persData
    if personalState then
      persData = self.friendsMainVm_.GetFriendsStatus(offTime, personalState)
    else
      persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOnline)
    end
    if persData then
      self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  else
    self.uiBinder.lab_time.text = Z.VMMgr.GetVM("union"):GetLastTimeDesignText(offTime)
    local persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOutLine)
    if persData then
      self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
  end
end

return FriendDataItemPC
