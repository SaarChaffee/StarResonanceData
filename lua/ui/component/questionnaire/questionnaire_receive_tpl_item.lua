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
      self.questionnaireVM_.OpenQuestionnaireUrl(self.data_.id)
      Z.UIMgr:CloseView("questionnaire_banner_popup")
    end
  end)
  self.itemList_ = loopListView.new(self, self.uiBinder.loop_item, questionnaireItem, "com_item_square_8")
  self.itemList_:Init({})
end

function QuestionnaireReceiveTplItem:OnRefresh(data)
  self.data_ = data
  local config = self.questionnaireData_:GetQuestionnaireConfig(self.data_.id)
  if config == nil then
    return
  end
  self.uiBinder.lab_description.text = config.Name
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
  for key, value in ipairs(config.Award) do
    local data = {
      configId = value[1],
      isSquareItem = true,
      lab = value[2],
      isShowReceive = not isNotAnswered,
      labType = E.ItemLabType.Num
    }
    items[key] = data
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
