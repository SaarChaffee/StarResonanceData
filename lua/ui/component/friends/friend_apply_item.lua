local super = require("ui.component.loop_list_view_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FriendApplyItem = class("FriendApplyItem", super)

function FriendApplyItem:OnInit()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.uiBinder.btn_cancel:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), false, "", self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.btn_ok:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      if not self.socialData_ or not self.socialData_.basicData then
        return
      end
      self.friendsMainVm_.AsyncProcessAddRequest(self.data_:GetCharId(), true, self.socialData_.basicData.name, self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.img_bg:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
end

function FriendApplyItem:OnRefresh(data)
  self.data_ = data
  self:refreshSource()
  self:refreshPlayerData()
end

function FriendApplyItem:refreshSource()
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
end

function FriendApplyItem:refreshPlayerData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.socialData_ = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
    if not self.socialData_ or not self.socialData_.basicData then
      return
    end
    if self.uiBinder == nil then
      return
    end
    self.uiBinder.lab_play_name.text = self.socialData_.basicData.name
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, self.socialData_.basicData.offlineTime ~= 0)
    playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, self.socialData_, nil, self.parent.UIView.cancelSource:CreateToken())
    self.uiBinder.lab_grade.text = Lang("Level", {
      val = self.socialData_.basicData.level
    })
  end)()
end

return FriendApplyItem
