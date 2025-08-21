local super = require("ui.component.loop_list_view_item")
local QuestionnaireReceiveTplItem = class("QuestionnaireReceiveTplItem", super)
local loopListView = require("ui/component/loop_list_view")
local questionnaireItem = require("ui/component/questionnaire/questionnaire_item")

function QuestionnaireReceiveTplItem:ctor()
  self.questionnaireVM_ = Z.VMMgr.GetVM("questionnaire")
  self.questionnaireData_ = Z.DataMgr.Get("questionnaire_data")
  self.data_ = nil
end

function QuestionnaireReceiveTplItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn_goto, function()
    if self.data_ then
      self.questionnaireVM_.OpenQuestionnaireUrl(self.data_.link)
      Z.UIMgr:CloseView("questionnaire_banner_popup")
    end
  end)
  self.itemList_ = loopListView.new(self, self.uiBinder.loop_item, questionnaireItem, "com_item_square_8")
  self.itemList_:Init({})
end

function QuestionnaireReceiveTplItem:OnRefresh(data)
  self.data_ = data
  if self.data_.name then
    self.uiBinder.lab_description.text = self.data_.name
  else
    self.uiBinder.lab_description.text = ""
  end
  local isNotAnswered = self.data_.status == Z.PbEnum("QuestionnaireStatus", "QuestionnaireNotAnswered")
  if isNotAnswered then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, false)
    self.uiBinder.anim.alpha = 1
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_goto, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, true)
    self.uiBinder.anim.alpha = 0.5
  end
  local items = {}
  local itemCount = 0
  for _, value in ipairs(self.data_.awards) do
    local data = {
      configId = value.configId,
      isSquareItem = true,
      lab = value.count,
      isShowReceive = not isNotAnswered,
      labType = E.ItemLabType.Num
    }
    itemCount = itemCount + 1
    items[itemCount] = data
  end
  self.itemList_:RefreshListView(items)
end

function QuestionnaireReceiveTplItem:OnUnInit()
  if self.itemList_ then
    self.itemList_:UnInit()
    self.itemList_ = nil
  end
end

return QuestionnaireReceiveTplItem
