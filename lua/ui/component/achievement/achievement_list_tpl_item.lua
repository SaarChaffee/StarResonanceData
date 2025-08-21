local super = require("ui.component.loop_list_view_item")
local AchievementListTplItem = class("AchievementListTplItem", super)
local LoopScrollRect = require("ui.component.loop_list_view")
local SeasonAwardItem = require("ui.component.season.seasaon_activity_award_loop_item")

function AchievementListTplItem:OnInit()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
  self.awardpreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.seasonAwardScrollRect_ = LoopScrollRect.new(self.parent.UIView, self.uiBinder.loop_item, SeasonAwardItem, "com_item_square_1_8", true)
  self.seasonAwardScrollRect_:Init({})
  self:AddAsyncListener(self.uiBinder.btn_get, function()
    self.achievementVM_.AsyncGetAchievementReward(self.data_.Id, self.parent.UIView.cancelSource:CreateToken())
  end)
end

function AchievementListTplItem:OnUnInit()
  self.seasonAwardScrollRect_:UnInit()
  self.seasonAwardScrollRect_ = nil
end

function AchievementListTplItem:OnRefresh(data)
  self.data_ = data
  if self.data_ then
    self.uiBinder.lab_name.text = self.data_.Name
    local classConfig = self.achievementVM_.GetAchievementInClassConfig(self.data_.Id)
    if classConfig then
      self.uiBinder.img_icon:SetImage(classConfig.ClassBackground)
    end
    local awardList = self.awardpreviewVM_.GetAllAwardPreListByIds(self.data_.RewardID)
    self.seasonAwardScrollRect_:RefreshListView(awardList)
    local achievement = self.achievementVM_.GetServerAchievement(self.data_.Id)
    if achievement then
      local finishNum = math.min(achievement.finishNum, self.data_.Num)
      local progress = Lang("season_achievement_progress", {
        val1 = finishNum,
        val2 = self.data_.Num
      })
      self.uiBinder.lab_content.text = Z.Placeholder.Placeholder(self.data_.Des, {val = progress})
      if achievement.hasReceived then
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_count, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_question, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
      elseif achievement.finishNum >= self.data_.Num then
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_count, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_question, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_count, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_question, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
        self.uiBinder.lab_count.text = Lang("season_achievement_progress", {
          val1 = achievement.finishNum,
          val2 = self.data_.Num
        })
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_count, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_question, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
      local progress = Lang("season_achievement_progress", {
        val1 = 0,
        val2 = self.data_.Num
      })
      self.uiBinder.lab_content.text = Z.Placeholder.Placeholder(self.data_.Des, {val = progress})
      self.uiBinder.lab_count.text = Lang("season_achievement_progress", {
        val1 = 0,
        val2 = self.data_.Num
      })
    end
  end
end

return AchievementListTplItem
