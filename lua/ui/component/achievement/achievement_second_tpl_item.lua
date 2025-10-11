local super = require("ui.component.loop_list_view_item")
local AchievementSecondTplItem = class("AchievementSecondTplItem", super)
local AchievementDefine = require("ui.model.achievement_define")
local AchievementDataTableMap = require("table.AchievementDateTableMap")

function AchievementSecondTplItem:OnInit()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function AchievementSecondTplItem:OnUnInit()
end

function AchievementSecondTplItem:OnRefresh(data)
  self.data_ = data
  local achievementId = AchievementDataTableMap.Dates[self.data_.Id]
  if achievementId and achievementId[1] then
    local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(achievementId[1])
    if config then
      self.uiBinder.lab_name.text = config.Sma11ClassName
      local finish, total = self.achievementVM_.GetSmallClassFinishCountAndTotalCount(self.data_.Id)
      self.uiBinder.lab_num.text = Lang("season_achievement_progress", {val1 = finish, val2 = total})
    end
  end
  local redNodeName = self.achievementVM_.GetRedNodeId(self.data_.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, Z.RedPointMgr.GetRedState(redNodeName))
  if self.IsSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  end
  if self.parent.UIView.IsInSearch then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_num, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_result, true)
    self.uiBinder.lab_result.text = Lang("AchievementSearchResult", {
      val = self.parent.UIView:GetAchievementIdCount(self.data_.ParentId, self.data_.Id)
    })
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_num, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_result, false)
  end
  self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
end

function AchievementSecondTplItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, true)
    self.parent.UIView:SelectAchievementId(self.data_.Id, false, isClick)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  else
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  end
end

return AchievementSecondTplItem
