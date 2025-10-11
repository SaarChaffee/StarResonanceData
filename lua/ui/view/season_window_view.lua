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
  self.vm = Z.VMMgr.GetVM("season")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.singleView_ = require("ui/view/season_show_single_sub_view").new(self)
  self.doubleView_ = require("ui/view/season_show_double_sub_view").new(self)
  self.subViews_ = {
    self.singleView_,
    self.doubleView_
  }
end

function Season_windowView:OnActive()
  self:startAnimShow()
  self.showConfig_ = self.vm.GetSeasonShowConfig()
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
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.CoroUtil.create_coro_xpcall(function()
    self:initDotItem()
  end)()
  self:refreshTitleUI()
  local isUnlock = self.gotoFuncVM_.FuncIsOn(E.FunctionID.TencentWechatOriginalShare, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, isUnlock and not Z.GameContext.IsPC and not Z.SDKDevices.IsCloudGame)
  self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_share.group_press_check:StopCheck()
end

function Season_windowView:initDotItem()
  local path = self.uiBinder.prefa_cahce:GetString("imgDotItem")
  local name
  for k, v in ipairs(self.showConfig_) do
    name = "img_dot_" .. k
    local item = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_dot)
    item.Ref:SetVisible(item.img_select, k == 1)
    self.pageDotList_[k] = {name = name, item = item}
  end
  self:setPage(self.curPage_)
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
  if self.curPage_ > #self.showConfig_ then
    self.curPage_ = 1
  elseif self.curPage_ < 1 then
    self.curPage_ = #self.showConfig_
  end
  for k, v in ipairs(self.showConfig_) do
    if k == self.curPage_ then
      self:setSubView(v)
    end
  end
  for k, v in ipairs(self.pageDotList_) do
    v.item.Ref:SetVisible(v.item.img_select, k == self.curPage_)
  end
end

function Season_windowView:OnDeActive()
  self:resetSubView()
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
  self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_moments.gameObject)
  self.uiBinder.node_share.group_press_check:StopCheck()
  self.pageViewList_ = {}
  for k, v in ipairs(self.pageDotList_) do
    self:RemoveUiUnit(v.name)
  end
  self.pageDotList_ = {}
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

function Season_windowView:setSubView(showInfo)
  if not showInfo then
    return
  end
  self:resetSubView()
  self.subViews_[showInfo.PreviewType]:Active(showInfo, self.uiBinder.node_show)
end

function Season_windowView:resetSubView()
  for _, v in ipairs(self.subViews_) do
    if v.IsActive then
      v:DeActive()
    end
  end
end

return Season_windowView
