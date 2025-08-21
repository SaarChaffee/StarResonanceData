local UI = Z.UI
local super = require("ui.ui_view_base")
local Friends_play_friends_more_popupView = class("Friends_play_friends_more_popupView", super)
local loopListView = require("ui/component/loop_list_view")
local friendPlayMoreItem = require("ui.component.friends.friend_play_more_item")

function Friends_play_friends_more_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friends_play_friends_more_popup")
end

function Friends_play_friends_more_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_item, friendPlayMoreItem, "friends_play_friends_more_tpl")
  self.loopList_:Init(self.viewData)
end

function Friends_play_friends_more_popupView:OnDeActive()
  self.loopList_:UnInit()
end

function Friends_play_friends_more_popupView:OnRefresh()
end

return Friends_play_friends_more_popupView
