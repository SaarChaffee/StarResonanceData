local super = require("ui.component.loop_grid_view_item")
local AchievementBadgeItem = class("AchievementBadgeItem", super)
local AchievementDefine = require("ui.model.achievement_define")

function AchievementBadgeItem:OnInit()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function AchievementBadgeItem:OnUnInit()
end

function AchievementBadgeItem:OnRefresh(data)
  self.data_ = data
  local finish, total = self.achievementVM_.GetClassFinishCountAndTotalCount(data)
  local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(data)
  if config then
    self.uiBinder.img_icon:SetImage(config.ClassBackground)
    self.uiBinder.lab_name.text = config.ClassName
    self.uiBinder.lab_digit.text = Lang("season_achievement_progress", {val1 = finish, val2 = total})
    local size = self.uiBinder.lab_digit:GetPreferredValues()
    self.uiBinder.img_strip:SetWidth(size.x + 50)
    local redDot = self.achievementVM_.GetRedNodeId(data)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, Z.RedPointMgr.GetRedState(redDot))
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer, E.DynamicSteerType.AchievementSeasonClassId, config.Id)
  end
end

function AchievementBadgeItem:OnSelected(isSelected)
  if isSelected then
    local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(self.data_)
    if config then
      if config.Type == AchievementDefine.PermanentAchievementType then
        Z.UIMgr:OpenView("achievement_detail_window", self.data_)
      else
        Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "season_achievement_detail_window", function()
          Z.UIMgr:OpenView("season_achievement_detail_window", self.data_)
        end)
      end
    end
  end
end

function AchievementBadgeItem:OnRecycle()
  self.uiBinder.steer:ClearSteerList()
end

function AchievementBadgeItem:OnUnInit()
  self.uiBinder.steer:ClearSteerList()
end

return AchievementBadgeItem
