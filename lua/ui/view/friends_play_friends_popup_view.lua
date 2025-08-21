local UI = Z.UI
local super = require("ui.ui_view_base")
local Friends_play_friends_popupView = class("Friends_play_friends_popupView", super)
local loopGridView = require("ui/component/loop_grid_view")
local friendPlayItem = require("ui.component.friends.friend_play_item")
local SDKDefine = require("ui.model.sdk_define")

function Friends_play_friends_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friends_play_friends_popup")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
end

function Friends_play_friends_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_square_icon, function()
    local arkJson = self.chatMainVm_.AsyncGetArkJsonWithTencent(self.cancelSource:CreateToken())
    if arkJson and arkJson ~= "" then
      local url = self.sdkVM_.GetURL(SDKDefine.SDK_URL_FUNCTION_TYPE.ARK)
      Z.GameShareManager:ShareLink(Lang("QQClientArkTitle"), url, Bokura.Plugins.Share.SharePlatform.QQArk, "", Lang("QQClientArkDesc"), arkJson)
    end
  end)
  self.gridLoopItems_ = loopGridView.new(self, self.uiBinder.node_friend_list, friendPlayItem, "friends_play_friends_tpl")
  self.gridLoopItems_:Init(Z.DataMgr.Get("sdk_data").SDKFriends)
  if self.viewData.isLogin then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_square_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uid_num, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_square_icon, self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQArk))
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uid_num, true)
    self.uiBinder.lab_uid_num.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  end
end

function Friends_play_friends_popupView:OnDeActive()
  self.gridLoopItems_:UnInit()
end

function Friends_play_friends_popupView:OnRefresh()
end

return Friends_play_friends_popupView
