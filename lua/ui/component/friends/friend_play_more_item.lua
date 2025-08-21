local super = require("ui.component.loop_grid_view_item")
local FriendPlayMoreItem = class("FriendPlayMoreItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendPlayMoreItem:ctor()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
end

function FriendPlayMoreItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn_add, function()
    if self.data_ ~= nil then
      local friendMainVM = Z.VMMgr.GetVM("friends_main")
      local ret = friendMainVM.AsyncSendAddFriend(self.data_.charId, E.FriendAddSource.ESuggestion, self.parent.UIView.cancelSource:CreateToken())
      if ret then
        self:refreshBtnState()
      end
    end
  end)
end

function FriendPlayMoreItem:OnRefresh(data)
  self.data_ = data
  if self.data_ == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVM = Z.VMMgr.GetVM("social")
    local socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
    self.uiBinder.lab_name.text = socialData.basicData.name
    local level = 0
    if self.data_.charLevel ~= nil then
      level = math.floor(self.data_.charLevel)
    end
    self.uiBinder.lab_grade.text = Lang("FriendAddItemPc", {val = level})
    local onlineTime = tonumber(self.data_.onlineTime) or 0
    local offlineTime = tonumber(self.data_.offlineTime) or 0
    if onlineTime > offlineTime then
      local config = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOnline)
      self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, config.Res))
      self.uiBinder.lab_state.text = config.StatusName
    else
      local config = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOutLine)
      self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, config.Res))
      self.uiBinder.lab_state.text = config.StatusName
    end
    playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, socialData, function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
    end, self.parent.UIView.cancelSource:CreateToken())
    self:refreshBtnState()
  end)()
end

function FriendPlayMoreItem:OnUnInit()
end

function FriendPlayMoreItem:refreshBtnState()
  if self.data_ == nil then
  elseif self.friendMainData_:IsFriendByCharId(self.data_.charId) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, false)
  else
    local isSended = self.friendMainData_:GetIsSendedFriend(self.data_.charId)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, not isSended)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, isSended)
  end
end

return FriendPlayMoreItem
