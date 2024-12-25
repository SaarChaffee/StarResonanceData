local super = require("ui.component.loop_list_view_item")
local SeasonActivityLoopItem = class("SeasonActivityLoopItem", super)
local color = {
  [1] = E.ColorHexValues.DarkGreen,
  [2] = E.ColorHexValues.DarkBlue,
  [3] = E.ColorHexValues.DarkPruple,
  [4] = E.ColorHexValues.DarkBrown
}

function SeasonActivityLoopItem:ctor()
end

function SeasonActivityLoopItem:OnInit()
end

function SeasonActivityLoopItem:OnRefresh(data)
  self.data = data
  self.functionOpen_ = true
  if self.data.FunctionId and self.data.FunctionId ~= 0 then
    self.functionOpen_ = Z.VMMgr.GetVM("switch").CheckFuncSwitch(self.data.FunctionId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, Z.RedPointMgr.GetRedState(self.data.FunctionId))
  self.uiBinder.lab_tag.text = data.ActTag
  self.uiBinder.node_act:SetColorByHex(color[data.TagPic])
  self:SelectState(self.IsSelected)
  self.uiBinder.lab_name_off.text = self.data.Name
  self.uiBinder.lab_name_on.text = self.data.Name
end

function SeasonActivityLoopItem:OnSelected(isSelected, isClick)
  self:SelectState(isSelected, isClick)
end

function SeasonActivityLoopItem:SelectState(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock_on, self.functionOpen_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock_off, not self.functionOpen_)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("UI_Tab_Special")
    end
    self.parent.UIView:onActSelect(self.data.Id, self.Index)
    self.uiBinder.anim_group:Restart(Z.DOTweenAnimType.Tween_1)
  end
  self.uiBinder.lab_grade.text = ""
  if self.functionOpen_ then
  else
    local textStyleTag = E.TextStyleTag.White
    if self.IsSelected then
      textStyleTag = E.TextStyleTag.PureBlack
    end
    self.uiBinder.lab_grade.text = Z.RichTextHelper.ApplyStyleTag(Lang("common_lock"), textStyleTag)
  end
end

function SeasonActivityLoopItem:OnUnInit()
end

return SeasonActivityLoopItem
