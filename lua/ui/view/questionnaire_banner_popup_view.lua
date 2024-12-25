local super = require("ui.ui_view_base")
local Questionnaire_banner_popupView = class("Questionnaire_banner_popupView", super)
local loopListView = require("ui/component/loop_list_view")
local receiveTplItem = require("ui/component/questionnaire/questionnaire_receive_tpl_item")

function Questionnaire_banner_popupView:ctor()
  self.panel = nil
  super.ctor(self, "questionnaire_banner_popup")
  self.questionnaireVM_ = Z.VMMgr.GetVM("questionnaire")
end

function Questionnaire_banner_popupView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self.list_ = loopListView.new(self, self.uiBinder.loop_item, receiveTplItem, "questionnaire_receive_tpl")
  self.list_:Init(self.questionnaireVM_.GetAllOpenedQuestionnaireInfos())
end

function Questionnaire_banner_popupView:OnDeActive()
  if self.list_ then
    self.list_:UnInit()
    self.list_ = nil
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

return Questionnaire_banner_popupView
