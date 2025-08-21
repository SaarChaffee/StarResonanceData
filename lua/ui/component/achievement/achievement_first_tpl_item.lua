local super = require("ui.component.loop_list_view_item")
local AchievementFirstTplItem = class("AchievementFirstTplItem", super)

function AchievementFirstTplItem:OnInit()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function AchievementFirstTplItem:OnUnInit()
end

function AchievementFirstTplItem:OnRefresh(data)
  self.data_ = data
  local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(self.data_.Id)
  if config then
    self.uiBinder.lab_name.text = config.ClassName
    local finish, total = self.achievementVM_.GetClassFinishCountAndTotalCount(self.data_.Id)
    self.uiBinder.lab_num.text = Lang("season_achievement_progress", {val1 = finish, val2 = total})
    self.uiBinder.img_icon:SetImage(config.ClassIcon)
  end
  local redNodeName = self.achievementVM_.GetRedNodeId(self.data_.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, Z.RedPointMgr.GetRedState(redNodeName))
  local selectClass = self.parent.UIView:GetSelectAchievementClass()
  if selectClass and selectClass == self.data_.Id then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, true)
    self.uiBinder.img_arrow:SetScale(1, 1, 1)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
    self.uiBinder.img_arrow:SetScale(-1, 1, 1)
  end
  if self.parent.UIView.IsInSearch then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_result, true)
    self.uiBinder.lab_result.text = Lang("AchievementSearchResult", {
      val = self.parent.UIView:GetClassesCount(self.data_.Id)
    })
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_result, false)
  end
end

function AchievementFirstTplItem:OnSelected(isSelected)
  local selectClass = self.parent.UIView:GetSelectAchievementClass()
  if selectClass and selectClass == self.data_.Id then
    self.parent.UIView:ResetAchievementId()
    return
  end
  if isSelected then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, true)
    self.uiBinder.img_arrow:SetScale(1, 1, 1)
    self.parent.UIView:SelectAchievementClass(self.data_.Id)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
    self.uiBinder.img_arrow:SetScale(-1, 1, 1)
  end
end

return AchievementFirstTplItem
