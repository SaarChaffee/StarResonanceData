local super = require("ui.component.loop_list_view_item")
local CompetencyAssessmentLoopItem = class("CompetencyAssessmentLoopItem", super)
local NeedAccessColor = Color.New(0.2, 0.2, 0.2, 1)
local NoAccessColor = Color.New(0.6588235294117647, 0.6588235294117647, 0.6588235294117647, 1)

function CompetencyAssessmentLoopItem:OnInit()
end

function CompetencyAssessmentLoopItem:OnRefresh(data)
  self.uiBinder.img_icon:SetImage(data.icon)
  self.uiBinder.lab_attribute.text = data.attrName
  self.uiBinder.lab_current_num.text = data.curValue
  self.uiBinder.lab_reference_num.text = data.referenceValue == -1 and "--" or data.referenceValue
  self.uiBinder.img_icon.color = data.needAccess and NeedAccessColor or NoAccessColor
  self.uiBinder.lab_attribute.color = data.needAccess and NeedAccessColor or NoAccessColor
  self.uiBinder.lab_current_num.color = data.needAccess and NeedAccessColor or NoAccessColor
  self.uiBinder.lab_reference_num.color = data.needAccess and NeedAccessColor or NoAccessColor
end

function CompetencyAssessmentLoopItem:OnUnInit()
end

return CompetencyAssessmentLoopItem
