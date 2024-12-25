local super = require("ui.service.service_base")
local FriendService = class("FriendService", super)

function FriendService:OnInit()
end

function FriendService:OnUnInit()
end

function FriendService:OnLogin()
end

function FriendService:OnLogout()
end

function FriendService:OnReconnect()
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  friendMainData:ResetProp()
  self:loadFriendBaseData()
end

function FriendService:OnEnterScene()
  self:loadFriendBaseData()
end

function FriendService:loadFriendBaseData()
  Z.CoroUtil.create_coro_xpcall(function()
    if Z.StageMgr.GetIsInGameScene() then
      local friendsVm = Z.VMMgr.GetVM("friends_main")
      friendsVm.AsyncGetFriendBaseData()
    end
  end)()
end

return FriendService
