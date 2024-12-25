local super = require("ui.component.loop_grid_view_item")
local SeasonAchievementItem = class("SeasonAchievementItem", super)

function SeasonAchievementItem:OnInit()
  self.seasonAchievementVm_ = Z.VMMgr.GetVM("season_achievement")
end

function SeasonAchievementItem:OnUnInit()
end

function SeasonAchievementItem:OnRefresh(data)
  self.data_ = data
  local finish, total = self.seasonAchievementVm_.GetClassifyProgress(data.Id)
  self.uiBinder.img_icon:SetImage(data.ClassBackground)
  self.uiBinder.lab_name.text = data.ClassName
  self.uiBinder.lab_digit.text = Lang("season_achievement_progress", {val1 = finish, val2 = total})
  local size = self.uiBinder.lab_digit:GetPreferredValues()
  self.uiBinder.img_strip:SetWidth(size.x + 50)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.seasonAchievementVm_.ClassifyHasUnReceivedReward(data.Id))
end

function SeasonAchievementItem:OnSelected(isSelected)
  if isSelected then
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "season_achievement_detail", function()
      Z.UIMgr:OpenView("season_achievement_detail", self.data_)
    end)
  end
end

return SeasonAchievementItem
