local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_expView = class("Tips_expView", super)

function Tips_expView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_exp")
end

function Tips_expView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, false)
  self.uiBinder.lab_info_1.text = self.viewData.info1
  self.uiBinder.lab_info_2.text = self.viewData.info2
end

function Tips_expView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_expView:OnRefresh()
end

return Tips_expView
