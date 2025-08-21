local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_title_contentView = class("Tips_title_contentView", super)

function Tips_title_contentView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "tips_title_content")
end

function Tips_title_contentView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.lab_info.text = self.viewData.content
  if self.viewData.subTitle then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_sub_title, true)
    self.uiBinder.lab_sub_title.text = self.viewData.subTitle
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_sub_title, false)
  end
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_title_contentView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Tips_title_contentView:OnRefresh()
end

return Tips_title_contentView
