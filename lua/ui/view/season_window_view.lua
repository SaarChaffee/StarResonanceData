local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_windowView = class("Season_windowView", super)
local SDKDefine = require("ui.model.sdk_define")

function Season_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_window")
  self.curPage_ = 1
  self.pageViewList_ = {}
  self.pageDotList_ = {}
  self.pageAnimList_ = {}
  self.vm = Z.VMMgr.GetVM("season")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
end

function Season_windowView:OnActive()
  self:startAnimShow()
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self:setPage(self.curPage_ - 1)
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self:setPage(self.curPage_ + 1)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self:DeActive()
  end)
  self:AddClick(self.uiBinder.btn_share, function()
    self.uiBinder.node_share.Ref.UIComp:SetVisible(true)
    self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
    self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_moments.gameObject)
    self.uiBinder.node_share.group_press_check:StartCheck()
  end)
  self:EventAddAsyncListener(self.uiBinder.node_share.group_press_check.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
      self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
      self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_moments.gameObject)
      self.uiBinder.node_share.group_press_check:StopCheck()
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.node_share.btn_wechat, function()
    self.sdkVM_.SDKOriginalShare({
      SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.SeasonPlayFriend,
      false
    })
  end)
  self:AddAsyncClick(self.uiBinder.node_share.btn_moments, function()
    self.sdkVM_.SDKOriginalShare({
      SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.SeasonPlayFriend,
      true
    })
  end)
  table.insert(self.pageViewList_, self.uiBinder.node_info_affix)
  table.insert(self.pageViewList_, self.uiBinder.node_info_title)
  table.insert(self.pageViewList_, self.uiBinder.node_pass_fashion)
  table.insert(self.pageViewList_, self.uiBinder.node_title_fashion)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_01)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_02)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_03)
  table.insert(self.pageDotList_, self.uiBinder.img_dot_04)
  table.insert(self.pageAnimList_, Z.DOTweenAnimType.Tween_2)
  table.insert(self.pageAnimList_, Z.DOTweenAnimType.Tween_1)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:setPage(self.curPage_)
  self:refreshTitleUI()
  local isUnlock = self.gotoFuncVM_.FuncIsOn(E.FunctionID.TencentWechatOriginalShare, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, isUnlock and not Z.GameContext.IsPC and not Z.SDKDevices.IsCloudGame)
  self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_share.group_press_check:StopCheck()
end

function Season_windowView:refreshTitleUI()
  local seasonName, timeStr = self.vm.GetCurSeasonTimeShow()
  if seasonName and timeStr then
    self.uiBinder.node_season_title.lab_time.text = timeStr
    self.uiBinder.node_season_title.lab_season_name.text = seasonName
  else
    logError("\232\181\155\229\173\163\230\151\182\233\151\180\232\175\187\229\143\150\233\148\153\232\175\175")
  end
end

function Season_windowView:setPage(page)
  self.curPage_ = page
  if self.curPage_ > #self.pageViewList_ then
    self.curPage_ = 1
  elseif self.curPage_ < 1 then
    self.curPage_ = #self.pageViewList_
  end
  for k, v in ipairs(self.pageViewList_) do
    self.uiBinder.Ref:SetVisible(v, k == self.curPage_)
  end
  for k, v in ipairs(self.pageDotList_) do
    self.uiBinder.Ref:SetVisible(v, k == self.curPage_)
  end
  self:onStartClickAnimShow(self.pageAnimList_[self.curPage_])
end

function Season_windowView:OnDeActive()
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_moments.gameObject)
  self.uiBinder.node_share.group_press_check:StopCheck()
  self.pageViewList_ = {}
  self.pageDotList_ = {}
  self.pageAnimList_ = {}
end

function Season_windowView:OnRefresh()
end

function Season_windowView:startAnimShow()
  self.uiBinder.anim_season:Restart(Z.DOTweenAnimType.Open)
end

function Season_windowView:onStartClickAnimShow(page)
  if page == nil then
    return
  end
  self.uiBinder.anim_season:Restart(page)
end

return Season_windowView
