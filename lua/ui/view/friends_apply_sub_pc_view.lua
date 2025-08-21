local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_apply_sub_pcView = class("Friends_apply_sub_pcView", super)
local loopListView = require("ui.component.loop_list_view")
local friendApplyItemPC = require("ui.component.friends_pc.friend_apply_item_pc")

function Friends_apply_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_apply_sub_pc", "friends_pc/friends_apply_sub_pc", UI.ECacheLv.None)
end

function Friends_apply_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, -76)
  self.uiBinder.Trans:SetOffsetMax(0, -10)
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  local curApplicationList = self.friendMainData_:GetApplicationList()
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_list, friendApplyItemPC, "friend_apply_item_tpl_pc")
  self.loopList_:Init(curApplicationList)
  self:AddAsyncClick(self.uiBinder.btn_ignore, function()
    local friendsMainVM = Z.VMMgr.GetVM("friends_main")
    local charList = self.friendMainData_:GetApplicationCharList()
    for i = 1, #charList do
      friendsMainVM.AsyncProcessAddRequest(charList[i], false, "", self.cancelSource:CreateToken())
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_sub_pcView:OnDeActive()
  self.loopList_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_sub_pcView:refreshApplication()
  local curApplicationList = self.friendMainData_:GetApplicationList()
  self.loopList_:RefreshListView(curApplicationList, false)
end

return Friends_apply_sub_pcView
