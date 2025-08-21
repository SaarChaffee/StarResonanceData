local super = require("ui.component.loop_grid_view_item")
local CameraFrameLoopItem = class("CameraFrameLoopItem", super)

function CameraFrameLoopItem:ctor()
  self.uiBinder = nil
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
end

function CameraFrameLoopItem:OnInit()
  self.parentUIView_ = self.parent.UIView
end

function CameraFrameLoopItem:Refresh(data)
  self.data_ = data
  self:setItemImg()
  self:setItemIsSelected()
end

function CameraFrameLoopItem:OnUnInit()
end

function CameraFrameLoopItem:OnSelected(selected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, selected)
  if selected then
    if self.parentUIView_.isToEditing_ then
      self.secondaryData_:GetMoviescreenData().frameData = self.data_.Res
    else
      self.cameraData_:SetIsSchemeParamUpdated(true)
      self.cameraData_.FrameIndex = self.Index
      self.decorateData_:GetMoviescreenData().frameData = self.data_.Res
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerSet, self.data_)
    end
  end
end

function CameraFrameLoopItem:setItemImg()
  local pathData = string.split(self.data_.Res, "=")
  local pathPrefix = self.parentUIView_.uiBinder.prefab_cache:GetString("filterPath")
  local iconPath = pathData[1]
  self.uiBinder.img_frame:SetImage(string.format("%s%s", pathPrefix, iconPath))
end

function CameraFrameLoopItem:setItemIsSelected()
  if self.parentUIView_.isToEditing_ then
    if self.secondaryData_:GetMoviescreenData().frameData == self.data_.Res then
      self.parent:SelectIndex(self.Index)
    else
      self.parent:UnSelectIndex(self.Index)
    end
  end
end

return CameraFrameLoopItem
