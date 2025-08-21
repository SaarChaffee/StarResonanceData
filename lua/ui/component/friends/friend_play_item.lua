local super = require("ui.component.loop_grid_view_item")
local FriendPlayItem = class("FriendPlayItem", super)
local singleAddIcon = "ui/atlas/friends/single_add"
local multipleAddIcon = "ui/atlas/friends/multiple_add"

function FriendPlayItem:ctor()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
end

function FriendPlayItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn_add, function()
    if self.data_ ~= nil and self.data_.roleInfos ~= nil then
      if #self.data_.roleInfos == 1 then
        local friendMainVM = Z.VMMgr.GetVM("friends_main")
        local ret = friendMainVM.AsyncSendAddFriend(self.data_.roleInfos[1].charId, E.FriendAddSource.ESuggestion, self.parent.UIView.cancelSource:CreateToken())
        if ret then
          self:refreshState()
        end
      else
        Z.UIMgr:OpenView("friends_play_friends_more_popup", self.data_.roleInfos)
      end
    end
  end)
end

function FriendPlayItem:OnRefresh(data)
  self.data_ = data
  self:httpGetHeadRimage(self.sdkVM_.GetFriendPicURLSuffix(self.data_.pictureUrl))
  self.uiBinder.lab_name.text = self.data_.userName
  if self.data_.roleInfos then
    local maxLevel = 0
    local isOnline = false
    local lastLogoutTime = 0
    for _, info in ipairs(self.data_.roleInfos) do
      maxLevel = math.max(maxLevel, info.charLevel or 0)
      local onlineTime = tonumber(info.onlineTime) or 0
      local offlineTime = tonumber(info.offlineTime) or 0
      if onlineTime > offlineTime then
        isOnline = true
      else
        lastLogoutTime = math.max(lastLogoutTime, offlineTime)
      end
    end
    self.uiBinder.lab_grade.text = Lang("FriendAddItemPc", {
      val = math.floor(maxLevel)
    })
    if isOnline then
      local config = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOnline)
      self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, config.Res))
      self.uiBinder.lab_state.text = config.StatusName
    else
      local config = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOutLine)
      self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, config.Res))
      self.uiBinder.lab_state.text = config.StatusName
    end
  else
    self.uiBinder.lab_grade.text = ""
    self.uiBinder.lab_state.text = ""
    self.uiBinder.img_state.enabled = false
  end
  self:refreshState()
end

function FriendPlayItem:OnUnInit()
  self:clearCachePhoto()
end

function FriendPlayItem:refreshState()
  if self.parent.UIView.viewData.isLogin or self.data_.roleInfos == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, false)
  else
    if #self.data_.roleInfos > 1 then
      self.uiBinder.img_add:SetImage(multipleAddIcon)
    else
      self.uiBinder.img_add:SetImage(singleAddIcon)
    end
    local isAllAddFriends = true
    local isAllSended = true
    for _, info in ipairs(self.data_.roleInfos) do
      if not self.friendMainData_:IsFriendByCharId(info.charId) then
        isAllAddFriends = false
        if not self.friendMainData_:GetIsSendedFriend(info.charId) then
          isAllSended = false
        end
      end
    end
    if isAllAddFriends then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, false)
    elseif isAllSended then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, true)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, false)
    end
  end
end

function FriendPlayItem:httpGetHeadRimage(url)
  self:clearCachePhoto()
  Z.CoroUtil.create_coro_xpcall(function()
    self.photoId_ = self.albumMainVm_.AsynHttpCachePhoto(url)
    self.uiBinder.rimg_portrait:SetNativeTexture(self.photoId_)
  end)()
end

function FriendPlayItem:clearCachePhoto()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

return FriendPlayItem
