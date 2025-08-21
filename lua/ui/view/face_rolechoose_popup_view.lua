local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_rolechoose_popupView = class("Face_rolechoose_popupView", super)

function Face_rolechoose_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_rolechoose_popup")
  self.loginVM_ = Z.VMMgr.GetVM("login")
end

function Face_rolechoose_popupView:OnActive()
  self:initComp()
end

function Face_rolechoose_popupView:OnDeActive()
end

function Face_rolechoose_popupView:OnRefresh()
end

function Face_rolechoose_popupView:initComp()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.viewConfigKey)
  self:AddClick(self.uiBinder.btn_no, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_yes, function()
    self:confirmDeleteRole()
  end)
  self.uiBinder.input_lab:AddListener(function(value)
    self.uiBinder.btn_yes.IsDisabled = value ~= Lang("RoleDeleteConfirmLab")
  end)
  self.uiBinder.btn_yes.IsDisabled = true
  self.uiBinder.input_lab.text = ""
  local day = math.floor(Z.Global.DeleteRoleTime / 24)
  self.uiBinder.lab_desc.text = Lang("RoleDeleteDesc", {day = day})
end

function Face_rolechoose_popupView:confirmDeleteRole()
  if self.uiBinder.btn_yes.IsDisabled then
    return
  end
  local charId = self.viewData.charId
  local reply = self.loginVM_:AsyncDeleteChar(charId)
  if reply.errCode == 0 and self.viewData.successCallback then
    self.viewData.successCallback(reply.charId, reply.deleteLeftTime)
  end
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Face_rolechoose_popupView
