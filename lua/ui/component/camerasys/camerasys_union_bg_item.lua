local super = require("ui.component.loop_grid_view_item")
local CamerasUnionBgItem = class("CamerasUnionBgItem", super)

function CamerasUnionBgItem:ctor()
end

function CamerasUnionBgItem:OnInit()
  self.view_ = self.parent.UIView
  self.unionBgGO_ = nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_unlocked, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, false)
end

function CamerasUnionBgItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, isSelected)
  if self.unionBgGO_ == nil then
    self.unionBgGO_ = Z.UnrealSceneMgr:GetGOByBinderName("UnionBg")
  end
  Z.CameraFrameCtrl:SetGOTexture(self.unionBgGO_, self.data_.Res)
end

function CamerasUnionBgItem:OnUnInit()
  self.unionBgComp_ = nil
end

function CamerasUnionBgItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_photo:SetImage(self.data_.Res)
end

return CamerasUnionBgItem
