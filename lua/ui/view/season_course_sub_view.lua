local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_course_subView = class("Season_course_subView", super)
local loopGridView_ = require("ui.component.loop_grid_view")
local loopListView_ = require("ui.component.loop_list_view")
local season_course_item = require("ui.component.season_title.season_course_item")
local comRewardItem = require("ui.component.common_reward_grid_list_item")

function Season_course_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_course_sub")
  self.seasonData_ = Z.DataMgr.Get("season_data")
  self.seasonTitleVM_ = Z.VMMgr.GetVM("season_title")
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  self.seasonTitleData_ = Z.DataMgr.Get("season_title_data")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.curSelectRankId_ = -1
  self.canReceived_ = false
end

function Season_course_subView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:SwicthVirtualStyle(E.UnrealSceneSlantingLightStyle.Turquoise)
  self:onStartAnimShow()
  self:AddClick(self.uiBinder.binder_btn_close.btn, function()
    Z.UIMgr:CloseView("season_course_sub")
  end)
  self:AddAsyncClick(self.uiBinder.btn_get, function()
    local selectRankConfig = self.seasonTitleData_:GetRankIdConfig(self.curSelectRankId_)
    if self.canReceived_ and selectRankConfig then
      self.seasonTitleVM_.AsyncReceiveSeasonRankAward(selectRankConfig.Id)
    end
  end)
  self:AddClick(self.uiBinder.node_season_title.btn_view, function()
    Z.UIMgr:OpenView("season_window")
  end)
  self.allRankScrollRect_ = loopGridView_.new(self, self.uiBinder.scrollview_reward, season_course_item, "season_course_item_tpl")
  self.rewardScrollRect_ = loopListView_.new(self, self.uiBinder.scrollview_item, comRewardItem, "com_item_square_1_8")
  self.rewardScrollRect_:Init({})
  self:BindEvents()
end

function Season_course_subView:OnDeActive()
  self:unInitLoopGridView()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:UnBindEvents()
end

function Season_course_subView:unInitLoopGridView()
  self.allRankScrollRect_:UnInit()
  self.allRankScrollRect_ = nil
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function Season_course_subView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Season_course_subView:OnRefresh()
  self:initLoopListView()
  self:refreshTitleUI()
end

function Season_course_subView:refreshTitleUI()
  local seasonName, timeStr = self.seasonVM_.GetCurSeasonTimeShow()
  if seasonName and timeStr then
    self.uiBinder.node_season_title.lab_time.text = timeStr
    self.uiBinder.node_season_title.lab_season_name.text = seasonName
  else
    logError("\232\181\155\229\173\163\230\151\182\233\151\180\232\175\187\229\143\150\233\148\153\232\175\175")
  end
end

function Season_course_subView:initLoopListView()
  local rankId = self.seasonTitleVM_.GetUnReceivedRankId()
  local allConfigs = self.seasonTitleData_:GetRankRewardConfigList()
  local index = 1
  local selectIndex = 1
  local infos = {}
  for _, value in pairs(allConfigs) do
    if value.RankId == rankId then
      selectIndex = index
    end
    index = index + 1
    if value.RewardId ~= 0 then
      table.insert(infos, value.RankId)
    end
  end
  self.allRankScrollRect_:ClearAllSelect()
  self.allRankScrollRect_:Init(infos)
  self.allRankScrollRect_:SetSelected(selectIndex)
  self:SetCurSelectItem(rankId)
end

function Season_course_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.SeasonTitle.ReceivedRankReward, self.refreshInfo, self)
end

function Season_course_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SeasonTitle.ReceivedRankReward, self.refreshInfo, self)
end

function Season_course_subView:refreshInfo()
  self:SetCurSelectItem(self.curSelectRankId_)
  self.allRankScrollRect_:RefreshAllShownItem()
end

function Season_course_subView:SetCurSelectItem(rankId)
  self.canReceived_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reach, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  self.curSelectRankId_ = rankId
  if self.curSelectRankId_ == -1 then
    return
  end
  local seasonInfo = self.seasonTitleData_:GetCurRankInfo()
  if seasonInfo == nil then
    return
  end
  local receivedRankStars = {}
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    receivedRankStars[value] = value
  end
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local seasonRankConfig = seasonRankTableMgr.GetRow(seasonInfo.curRanKStar)
  if seasonRankConfig == nil then
    return
  end
  local selectRankConfig = self.seasonTitleData_:GetRankIdConfig(self.curSelectRankId_)
  if selectRankConfig == nil then
    return
  end
  local isReceived = false
  if receivedRankStars[selectRankConfig.Id] then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reach, true)
    isReceived = true
  elseif self.curSelectRankId_ <= seasonRankConfig.RankId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, true)
    self.uiBinder.btn_get.IsDisabled = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, true)
    self.canReceived_ = true
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, true)
    self.uiBinder.btn_get.IsDisabled = true
  end
  local allConfigs = self.seasonTitleData_:GetRankRewardConfigList()
  local index = 1
  local selectIndex = 1
  for _, value in pairs(allConfigs) do
    if value.RankId == rankId then
      selectIndex = index
    end
    index = index + 1
  end
  self.allRankScrollRect_:ClearAllSelect()
  self.allRankScrollRect_:SetSelected(selectIndex)
  local styStr = Z.RichTextHelper.ApplySizeTag(tostring(selectIndex), 150)
  self.uiBinder.lab_award_title.text = string.format(Lang("FirstLevelReward"), styStr)
  local rankStr = string.format("(%s)", string.format(Lang("GetRewardWhenSeasonTitle"), selectRankConfig.Name))
  local styStr = Z.RichTextHelper.ApplyStyleTag(rankStr, "season_title_reward_title")
  self.uiBinder.lab_rank_get.text = string.format("%s%s", Lang("RewardContent"), styStr)
  local selectRankConfig = self.seasonTitleData_:GetRankIdConfig(self.curSelectRankId_)
  if selectRankConfig == nil then
    return
  end
  local rewards = self.awardPreviewVM_.GetAllAwardPreListByIds(selectRankConfig.RewardId)
  for _, value in ipairs(rewards) do
    value.received = isReceived
  end
  self.rewardScrollRect_:RefreshListView(rewards, true)
  self.rewardScrollRect_:ClearAllSelect()
  self.uiBinder.rimg_icon:SetImage(selectRankConfig.IconBig)
  self.uiBinder.lab_name.text = selectRankConfig.Name
end

function Season_course_subView:onStartAnimShow()
  self.uiBinder.anim_course:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.anim_course:Restart(Z.DOTweenAnimType.Tween_1)
end

return Season_course_subView
