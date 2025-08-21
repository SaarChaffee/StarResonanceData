local super = require("ui.component.loop_grid_view_item")
local CameraFilterItemPcTpl = class("CameraFilterItemPcTpl", super)

function CameraFilterItemPcTpl:ctor()
  self.uiBinder = nil
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
end

function CameraFilterItemPcTpl:OnInit()
  self.parentUIView_ = self.parent.UIView
  self.unionBgGO_ = nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function CameraFilterItemPcTpl:Refresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(self.data_.Res)
end

function CameraFilterItemPcTpl:OnUnInit()
  self.unionBgComp_ = nil
end

function CameraFilterItemPcTpl:OnSelected(selected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, selected)
  if self.unionBgGO_ == nil then
    self.unionBgGO_ = Z.UnrealSceneMgr:GetGOByBinderName("UnionBg")
  end
  Z.CameraFrameCtrl:SetGOTexture(self.unionBgGO_, self.data_.Res)
end

return CameraFilterItemPcTpl
