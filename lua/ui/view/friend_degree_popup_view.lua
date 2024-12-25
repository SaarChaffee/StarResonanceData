local UI = Z.UI
local super = require("ui.ui_view_base")
local Friend_degree_popupView = class("Friend_degree_popupView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local friend_degree_list_item = require("ui.component.friends.friend_degree_list_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Friend_degree_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friend_degree_popup")
end

function Friend_degree_popupView:OnActive()
  self:onStartAnimatedShow()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:initData()
  self:initFunc()
  self:bindEvent()
end

function Friend_degree_popupView:OnDeActive()
  self:unBindEvent()
  self.linessLevelScrollRect_:ClearCells()
  Z.VMMgr.GetVM("helpsys").CloseTitleContentBtn()
end

function Friend_degree_popupView:OnRefresh()
end

function Friend_degree_popupView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
end

function Friend_degree_popupView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
end

function Friend_degree_popupView:initData()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.linessLevelScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_item, self, friend_degree_list_item)
  self.friendData_ = self.friendMainData_:GetFriendDataByCharId(self.viewData.charId)
  self.friendLinessData_ = self.friendMainData_:GetFriendLinessData(self.viewData.charId)
  self.friendShipLevelTableData_ = self.friendMainData_:GetFriendshipLevelTableData()
end

function Friend_degree_popupView:initFunc()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("friend_degree_popup")
  end)
  self:refreshFriendLiness()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncUpdatePlayerHead()
  end)()
  self:AddClick(self.uiBinder.btn_tips, function()
    Z.VMMgr.GetVM("helpsys").OpenMinTips(30021, self.uiBinder.btn_tips_ref)
  end)
end

function Friend_degree_popupView:updateExpProgress()
  if self.configInfo_ and self.configInfo_.Exp > 0 then
    self.uiBinder.img_progressbars:SetFillAmount(self.friendLinessData_.friendLinessCurExp / self.configInfo_.Exp)
  else
    self.uiBinder.img_progressbars:SetFillAmount(1)
  end
end

function Friend_degree_popupView:updateLinessLevel()
  self.uiBinder.lab_grade.text = Lang("Lv") .. self.friendLinessData_.friendLinessLevel
end

function Friend_degree_popupView:updateExperienceValue()
  local param = {}
  if self.configInfo_ then
    param = {
      val1 = self.friendLinessData_.friendLinessCurExp,
      val2 = self.configInfo_.Exp
    }
  else
    local value = 0
    local configInfo = Z.TableMgr.GetTable("FriendshipLevelMgr").GetRow(self.friendLinessData_.friendLinessLevel)
    if configInfo then
      value = configInfo.Exp
    end
    param = {val1 = value, val2 = value}
  end
  self.uiBinder.lab_experience.text = Lang("experience", param)
end

function Friend_degree_popupView:asyncUpdatePlayerHead()
  local socialData = self.socialVm_.AsyncGetHeadAndHeadFrameInfo(Z.ContainerMgr.CharSerialize.charBase.charId, self.cancelSource:CreateToken())
  if socialData then
    playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_head_self_item, socialData)
  end
  if self.friendData_ then
    playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_head_friend_item, self.friendData_:GetSocialData())
  end
end

function Friend_degree_popupView:updateLinessLevelReward()
  local awardConfig = {}
  for _, friendShipLevel in pairs(self.friendShipLevelTableData_) do
    if friendShipLevel.IsAwardLevel then
      awardConfig[#awardConfig + 1] = friendShipLevel
    end
  end
  self.linessLevelScrollRect_:SetData(awardConfig)
end

function Friend_degree_popupView:refreshFriendLiness()
  self.configInfo_ = Z.TableMgr.GetTable("FriendshipLevelMgr").GetRow(self.friendLinessData_.friendLinessLevel + 1, true)
  self:updateExpProgress()
  self:updateLinessLevel()
  self:updateLinessLevelReward()
  self:updateExperienceValue()
end

function Friend_degree_popupView:onStartAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Friend_degree_popupView
