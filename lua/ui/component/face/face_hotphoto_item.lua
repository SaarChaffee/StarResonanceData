local super = require("ui.component.loop_grid_view_item")
local FaceHotphotoItem = class("FaceHotphotoItem", super)

function FaceHotphotoItem:OnInit()
end

function FaceHotphotoItem:OnRefresh(data)
  self.uiBinder.img_head:SetImage(data.Icon)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function FaceHotphotoItem:OnSelected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parent.UIView:OnSelect(self.data_, self.Index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function FaceHotphotoItem:OnUnInit()
end

return FaceHotphotoItem
