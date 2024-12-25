local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_icontitle_contentView = class("Tips_icontitle_contentView", super)

function Tips_icontitle_contentView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_icontitle_content")
end

function Tips_icontitle_contentView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.lab_info.text = self.viewData.content
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_icontitle_contentView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_icontitle_contentView:OnRefresh()
end

return Tips_icontitle_contentView
