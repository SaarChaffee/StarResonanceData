local super = require("ui.ui_view_base")
local Tips_action_name_popupView = class("Tips_action_name_popupView", super)

function Tips_action_name_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_action_name_popup")
end

function Tips_action_name_popupView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.adaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.presscheck:StartCheck()
end

function Tips_action_name_popupView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Tips_action_name_popupView:OnRefresh()
end

return Tips_action_name_popupView
