local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_title_content_btnView = class("Tips_title_content_btnView", super)

function Tips_title_content_btnView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_title_content_btn")
end

function Tips_title_content_btnView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.lab_info.text = self.viewData.content
  self.uiBinder.lab_content.text = self.viewData.btnContent
  self:AddAsyncClick(self.uiBinder.btn_go, function()
    if self.viewData.func then
      self.viewData.func()
    end
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.btn_go.enabled = self.viewData.enabled
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_title_content_btnView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_title_content_btnView:OnRefresh()
end

return Tips_title_content_btnView
