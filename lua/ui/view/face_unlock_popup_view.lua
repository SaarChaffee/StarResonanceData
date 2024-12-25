local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_unlock_popupView = class("Face_unlock_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local saveConfirmItem = require("ui.component.face.face_save_confirm_loop_item")

function Face_unlock_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_unlock_popup")
end

function Face_unlock_popupView:OnActive()
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView("face_unlock_popup")
  end)
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.styleLoopListView_ = loopListView.new(self, self.uiBinder.loop_item, saveConfirmItem, "face_style_item_tpl")
  self.styleLoopListView_:Init(self.viewData)
end

function Face_unlock_popupView:OnDeActive()
  self.styleLoopListView_:UnInit()
end

return Face_unlock_popupView
