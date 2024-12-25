local super = require("ui.ui_view_base")
local SeasonAchievementDetail = class("SeasonAchievementDetail", super)
local LoopListView = require("ui.component.loop_list_view")
local DetailClassifyItem = require("ui.view.season_achievement.season_achievement_detail_classify_item")
local rewardItem = require("ui.view.season_achievement.season_achievement_reward_item")
local iconPath = "ui/atlas/season_achievement/"
local effectPath = "ui/uieffect/prefab/ui_sfx_season_001/ui_sfx_season_achievement_hit_common"
local Season_achievement_reward1_subView = require("ui.view.season_achievement_rewad_sub_01_view")
local Season_achievement_reward2_subView = require("ui.view.season_achievement_rewad_sub_02_view")
local Season_achievement_reward3_subView = require("ui.view.season_achievement_rewad_sub_03_view")
local Season_achievement_reward4_subView = require("ui.view.season_achievement_rewad_sub_04_view")
local Season_achievement_reward5_subView = require("ui.view.season_achievement_rewad_sub_05_view")
local Season_achievement_reward6_subView = require("ui.view.season_achievement_rewad_sub_06_view")
local season_achievement_icon_01 = "season_achievement_grade_frame_01"
local season_achievement_icon_02 = "season_achievement_grade_frame_02"
E.AchievementTypeIcon = {
  ENormalType = 1,
  EHighType = 2,
  ESpecialType = 3
}

function SeasonAchievementDetail:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_achievement_detail")
  self.seasonAchievementVm_ = Z.VMMgr.GetVM("season_achievement")
  self.seasonAchievementData_ = Z.DataMgr.Get("season_achievement_data")
end

function SeasonAchievementDetail:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  self.achievementReward1_ = Season_achievement_reward1_subView.new(self)
  self.achievementReward2_ = Season_achievement_reward2_subView.new(self)
  self.achievementReward3_ = Season_achievement_reward3_subView.new(self)
  self.achievementReward4_ = Season_achievement_reward4_subView.new(self)
  self.achievementReward5_ = Season_achievement_reward5_subView.new(self)
  self.achievementReward6_ = Season_achievement_reward6_subView.new(self)
  self.achievementReward_ = {
    [1] = self.achievementReward1_,
    [2] = self.achievementReward2_,
    [3] = self.achievementReward3_,
    [4] = self.achievementReward4_,
    [5] = self.achievementReward5_,
    [6] = self.achievementReward6_
  }
  self.effects_ = {}
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  self.classifyList_ = self.seasonAchievementVm_.GetClassify()
  self.classifyLoopListView_ = LoopListView.new(self, self.uiBinder.loopscroll_left, DetailClassifyItem, "season_achievement_detail_item_tpl")
  self.classifyLoopListView_:Init(self.classifyList_)
  self.rewardLoopListView_ = LoopListView.new(self, self.uiBinder.loop_reward, rewardItem, "com_item_square_8")
  self.rewardLoopListView_:Init({})
  self.selectClassify_ = self.seasonAchievementData_:GetSelectClassify()
  local index = 0
  local selectId = self.viewData.Id
  selectId = selectId or self.selectClassify_.Id
  for i = 1, #self.classifyList_ do
    if self.classifyList_[i].Id == selectId then
      index = i
      break
    end
  end
  self.classifyLoopListView_:SetSelected(index)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpSysVM = Z.VMMgr.GetVM("helpsys")
    helpSysVM.OpenFullScreenTipsView(400005)
  end)
  local size = self.uiBinder.lab_title:GetPreferredValues(Lang("SeasonalAchievements"), 285, 40)
  self.uiBinder.lab_title_ref:SetWidth(size.x)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_achievements, false)
end

function SeasonAchievementDetail:OnDeActive()
  self.classifyLoopListView_:UnInit()
  self.rewardLoopListView_:UnInit()
  self.selectClassify_ = nil
  self.classifyList_ = nil
  if self.curRewardSubView_ then
    self.curRewardSubView_:DeActive()
    self.curRewardSubView_ = nil
  end
  for _, effect in ipairs(self.effects_) do
    effect:ReleseEffGo()
  end
  self.effects_ = {}
end

function SeasonAchievementDetail:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("season_achievement_detail")
end

function SeasonAchievementDetail:SelectClassify(index, classify)
  for _, effect in ipairs(self.effects_) do
    effect:ReleseEffGo()
  end
  self.effects_ = {}
  self.seasonAchievementData_:SetSelectClassify(classify)
  self.selectClassify_ = classify
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_achievements, false)
  if self.curRewardSubView_ then
    self.curRewardSubView_:DeActive()
  end
  self.selectBinder_ = nil
  self.curRewardSubView_ = self.achievementReward_[index]
  self.curRewardSubView_:Active(self.selectClassify_.EntryList, self.uiBinder.node_sub_parent)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
end

function SeasonAchievementDetail:RefreshAchievement(subView, gradeList, bigIndex)
  self.bigIndex_ = bigIndex
  for i = 1, #gradeList do
    local binder = gradeList[i]
    if binder then
      if i > #self.selectClassify_.EntryList then
        subView.uiBinder.Ref:SetVisible(binder.Ref, false)
      else
        subView.uiBinder.Ref:SetVisible(binder.Ref, true)
        self:refreshContent(binder, self.selectClassify_.EntryList[i])
      end
    end
  end
  self:refreshReward()
end

function SeasonAchievementDetail:refreshContent(binder, achievementId)
  local detail, configData = self.seasonAchievementVm_.GetAchievementDetailByAchievementId(achievementId)
  if binder.btn_chest then
    binder.Ref:SetVisible(binder.btn_chest, false)
  end
  if binder.img_reddot then
    binder.Ref:SetVisible(binder.img_reddot, detail.state == 1)
  end
  if binder.img_achieved then
    binder.Ref:SetVisible(binder.img_achieved, detail.state == 2)
  end
  if binder.img_select then
    binder.Ref:SetVisible(binder.img_select, false)
  end
  if binder.img_lock then
    binder.Ref:SetVisible(binder.img_lock, false)
  end
  local icon
  if detail.config.TypeIcon == E.AchievementTypeIcon.ENormalType then
    icon = season_achievement_icon_02
  else
    icon = season_achievement_icon_01
  end
  binder.img_icon:SetImage(string.zconcat(iconPath, icon))
  if 1 < table.zcount(configData) then
    if binder.lab_lv then
      binder.lab_lv.text = detail.config.AchievementLevel
    end
    if binder.img_lv then
      binder.Ref:SetVisible(binder.img_lv, true)
    end
  else
    if binder.lab_lv then
      binder.lab_lv.text = ""
    end
    if binder.img_lv then
      binder.Ref:SetVisible(binder.img_lv, false)
    end
  end
  binder.btn_select:AddListener(function()
    if self.selectBinder_ and self.selectBinder_.img_select then
      self.selectBinder_.Ref:SetVisible(self.selectBinder_.img_select, false)
    end
    self.selectBinder_ = binder
    if binder.img_select then
      binder.Ref:SetVisible(binder.img_select, true)
    end
    self:refreshReward(binder, achievementId)
  end)
end

function SeasonAchievementDetail:refreshReward(binder, achievementId)
  if binder and achievementId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_achievements, true)
    self.uiBinder.node_sub_parent:SetLocalPos(-65, -41)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_0)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
    local detail, configData = self.seasonAchievementVm_.GetAchievementDetailByAchievementId(achievementId)
    self.uiBinder.lab_achievement_name.text = detail.config.Name
    local isBig = false
    if binder.img_achieved then
      isBig = true
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grade1.Ref, isBig)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grade2.Ref, not isBig)
    local icon
    if detail.config.TypeIcon == E.AchievementTypeIcon.ENormalType then
      icon = season_achievement_icon_02
    else
      icon = season_achievement_icon_01
    end
    self.uiBinder.node_grade1.img_icon:SetImage(string.zconcat(iconPath, icon))
    self.uiBinder.node_grade2.img_icon:SetImage(string.zconcat(iconPath, icon))
    if table.zcount(configData) > 0 then
      self.uiBinder.lab_describe.text = configData[1].AchievementWorldView
    end
    local progress = Lang("season_achievement_progress", {
      val1 = detail.current,
      val2 = detail.need
    })
    self.uiBinder.lab_condition.text = Z.Placeholder.Placeholder(detail.config.Des, {val = progress})
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, detail.current >= detail.need)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, detail.current < detail.need)
    local awardVM = Z.VMMgr.GetVM("awardpreview")
    local awards = awardVM.GetAllAwardPreListByIds(detail.config.RewardID)
    if awards and 0 < #awards then
      self.rewardLoopListView_:RefreshListView(awards, false)
    end
    local isCanShowBtn = false
    if detail.config.QuickJumpType and 0 < detail.config.QuickJumpType then
      isCanShowBtn = true
    end
    local showBtn = false
    local labBtn = ""
    if detail.state == 0 then
      if isCanShowBtn then
        labBtn = Lang("Goto")
        showBtn = true
      else
        labBtn = Lang("NotFinish")
      end
    elseif detail.state == 1 then
      labBtn = Lang("Receive")
      showBtn = true
    elseif detail.state == 2 then
      labBtn = Lang("Received")
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go.Ref, showBtn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, not showBtn)
    if showBtn then
      self:AddAsyncClick(self.uiBinder.btn_go.btn, function()
        if detail.state == 0 then
          local quickjumpVm_ = Z.VMMgr.GetVM("quick_jump")
          quickjumpVm_.DoJumpByConfigParam(detail.config.QuickJumpType, detail.config.QuickJumpParam)
        elseif detail.state == 1 then
          local ret = self.seasonAchievementVm_.AsyncGetAchievementReward(detail.config.Id, self.cancelSource:CreateToken())
          if ret == 0 then
            self:refreshContent(binder, achievementId)
            self:refreshReward(binder, achievementId)
            Z.AudioMgr:Play("UI_Event_Magic_C")
            binder.node_effect:CreatEFFGO(effectPath, Vector3.zero)
            binder.node_effect:SetEffectGoVisible(true)
            self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(binder.node_effect)
            table.insert(self.effects_, binder.node_effect)
          end
        end
      end)
      self.uiBinder.btn_go.btn.IsDisabled = false
    else
      self.uiBinder.btn_go.btn:RemoveAllListeners()
      self.uiBinder.btn_go.btn.IsDisabled = true
      self.uiBinder.lab_underway.text = labBtn
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, detail.state == 1)
    self.uiBinder.btn_go.lab_normal.text = labBtn
  else
    self.uiBinder.node_sub_parent:SetLocalPos(65, -41)
  end
end

return SeasonAchievementDetail
