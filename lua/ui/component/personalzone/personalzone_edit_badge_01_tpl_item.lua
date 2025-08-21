local super = require("ui.component.loop_list_view_item")
local PersonalzoneEditBadge01TplItem = class("PersonalzoneEditBadge01TplItem", super)

function PersonalzoneEditBadge01TplItem:OnInit()
  self.uiBinder.btn_select:AddListener(function()
    Z.AudioMgr:Play("sys_general_frame")
    self.parent.UIView:SelectId(self.data_.Id)
  end)
end

function PersonalzoneEditBadge01TplItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.parent.UIView:IsSelect(self.data_.Id))
  self.uiBinder.img_icon:SetImage(self.data_.Image)
end

function PersonalzoneEditBadge01TplItem:OnUnInit()
end

function PersonalzoneEditBadge01TplItem:OnRecycle()
  self.uiBinder.img_icon.enabled = false
end

return PersonalzoneEditBadge01TplItem
