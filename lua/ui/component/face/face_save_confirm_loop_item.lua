local super = require("ui.component.loop_list_view_item")
local FaceSaveConfirmLoopItem = class("FaceSaveConfirmLoopItem", super)
local iconPathPre = "ui/atlas/face/styleicon/"

function FaceSaveConfirmLoopItem:OnRefresh(data)
  self.faceOption_ = data
  local faceId = self.faceOption_:GetValue()
  local row = Z.TableMgr.GetTable("FaceTableMgr").GetRow(faceId)
  if row then
    self.uiBinder.img_icon:SetImage(string.zconcat(iconPathPre, row.Icon))
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
end

function FaceSaveConfirmLoopItem:OnSelected(isSelected)
  if isSelected then
    Z.EventMgr:Dispatch(Z.ConstValue.FaceSaveConfirmItemClick, self.faceOption_)
    Z.UIMgr:CloseView("face_unlock_popup")
  end
end

return FaceSaveConfirmLoopItem
