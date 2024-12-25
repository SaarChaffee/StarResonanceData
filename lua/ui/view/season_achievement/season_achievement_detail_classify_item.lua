local super = require("ui.component.loop_list_view_item")
local SeasonAchievementDetailClassifyItem = class("SeasonAchievementDetailClassifyItem", super)

function SeasonAchievementDetailClassifyItem:ctor()
  self.seasonAchievementVm_ = Z.VMMgr.GetVM("season_achievement")
  self.seasonAchievementData_ = Z.DataMgr.Get("season_achievement_data")
end

function SeasonAchievementDetailClassifyItem:OnInit()
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  Z.EventMgr:Add(Z.ConstValue.SeasonAchievement.OnAchievementDataChange, self.onAchievementDataChange, self)
end

function SeasonAchievementDetailClassifyItem:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function SeasonAchievementDetailClassifyItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(self.data_.ClassBackground)
  self.uiBinder.lab_name.text = self.data_.ClassName
  local finish, total = self.seasonAchievementVm_.GetClassifyProgress(self.data_.Id)
  self.uiBinder.lab_frequency.text = Lang("season_achievement_progress", {val1 = finish, val2 = total})
  self:onSelectClassifyChange(false)
  self:onAchievementDataChange()
  self:checkBackAlpha(self.IsSelected)
end

function SeasonAchievementDetailClassifyItem:OnSelected(isSelected)
  self:onSelectClassifyChange(isSelected)
  if isSelected then
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_1)
  end
  self:checkBackAlpha(self.IsSelected)
end

function SeasonAchievementDetailClassifyItem:checkBackAlpha(isSelect)
  if isSelect then
    self.uiBinder.img_alpha.alpha = 1
  else
    self.uiBinder.img_alpha.alpha = 0.3
  end
end

function SeasonAchievementDetailClassifyItem:onSelectClassifyChange(isSelect)
  self:checkBackAlpha(isSelect)
  local color = isSelect and self.seasonAchievementData_:GetAchievementSelectColor() or self.seasonAchievementData_:GetAchievementUnSelectColor()
  self.uiBinder.img_icon:SetColor(color)
  self.uiBinder.lab_name.color = color
  self.uiBinder.lab_frequency.color = color
  if isSelect then
    Z.AudioMgr:Play("sys_questtimelimited_leftui02")
    self.parent.UIView:SelectClassify(self.Index, self.data_)
  end
end

function SeasonAchievementDetailClassifyItem:onAchievementDataChange()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.seasonAchievementVm_.ClassifyHasUnReceivedReward(self.data_.Id))
end

return SeasonAchievementDetailClassifyItem
