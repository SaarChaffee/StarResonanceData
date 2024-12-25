local super = require("ui.component.loop_grid_view_item")
local StyleIconLoopItem = class("StyleIconLoopItem", super)
local iconPathPre = "ui/atlas/face/styleicon/"
local faceRed = require("rednode.face_red")

function StyleIconLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self.faceData_ = Z.DataMgr.Get("face_data")
  Z.EventMgr:Add(Z.ConstValue.FaceStyleUnlock, self.onFaceStyleUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.Face.FaceOptionCanUnlock, self.refreshStyleRed, self)
end

function StyleIconLoopItem:OnRefresh(data)
  self.isSelected_ = false
  self.styleData_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  local faceId = self.styleData_.Id
  if 0 < faceId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
    self.uiBinder.img_icon:SetImage(iconPathPre .. self.styleData_.Icon)
    local isUnlocked = self.faceData_:GetFaceStyleItemIsUnlocked(self.styleData_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not isUnlocked)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
  end
  self:refreshStyleRed()
end

function StyleIconLoopItem:OnSelected(isSelected, isClick)
  self.isSelected_ = isSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if self.isSelected_ then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parentView_:OnSelectFaceStyle(self.styleData_.Id)
  end
end

function StyleIconLoopItem:OnPointerClick(go, eventData)
  if not self.isSelected_ then
    self.parentView_:OnClickFaceStyle(self.styleData_.Id)
  end
end

function StyleIconLoopItem:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
  self.isSelected_ = false
  self.parentView_ = nil
end

function StyleIconLoopItem:onFaceStyleUnlock(faceId)
  if self.styleData_.Id == faceId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  end
end

function StyleIconLoopItem:refreshStyleRed()
  if self.styleData_.Id > 0 then
    local isCheckRed = faceRed.IsShowFaceRedType(self.styleData_.Type)
    local isUnlocked = self.faceData_:GetFaceStyleItemIsUnlocked(self.styleData_.Id)
    if isCheckRed and not isUnlocked and 0 < #self.styleData_.Unlock then
      local isCanUnlock = faceRed.CheckFaceCanUnlock(self.styleData_.Unlock)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, isCanUnlock)
    end
  end
end

return StyleIconLoopItem
