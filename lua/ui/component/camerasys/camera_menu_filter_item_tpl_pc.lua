local super = require("ui.component.loop_grid_view_item")
local CameraFilterItemPcTpl = class("CameraFilterItemPcTpl", super)

function CameraFilterItemPcTpl:ctor()
  self.uiBinder = nil
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
end

function CameraFilterItemPcTpl:OnInit()
  self.parentUIView_ = self.parent.UIView
end

function CameraFilterItemPcTpl:Refresh(data)
  self.data_ = data
  self:setItemImg()
  self:setItemIsSelected()
end

function CameraFilterItemPcTpl:OnUnInit()
end

function CameraFilterItemPcTpl:OnSelected(selected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, selected)
  if selected then
    local splData = string.split(self.data_.Res, "=")
    local path = splData[2] and splData[2] or ""
    if self.parentUIView_.isToEditing_ then
      self.secondaryData_:GetMoviescreenData().filterData = path
      Z.CameraFrameCtrl:SetAlbumSecondFilter(path)
    else
      self.cameraData_.FilterIndex = self.Index
      self.decorateData_:GetMoviescreenData().filterData = path
      self.cameraData_:SetIsSchemeParamUpdated(true)
      self.cameraData_.FilterPath = path
      if not path or path == "" then
        Z.CameraFrameCtrl:SetDefineFilterAsync()
      else
        Z.CameraFrameCtrl:SetFilterAsync(path)
      end
    end
  end
end

function CameraFilterItemPcTpl:setItemImg()
  local pathData = string.split(self.data_.Res, "=")
  local pathPrefix = self.parentUIView_.uiBinder.prefab_cache:GetString("filterPath")
  local iconPath = pathData[1]
  self.uiBinder.img_icon:SetImage(string.format("%s%s", pathPrefix, iconPath))
end

function CameraFilterItemPcTpl:setItemIsSelected()
  if self.parentUIView_.isToEditing_ then
    if self.secondaryData_:GetMoviescreenData().frameData == self.data_.Res then
      self.parent:SelectIndex(self.Index)
    else
      self.parent:UnSelectIndex(self.Index)
    end
  end
end

return CameraFilterItemPcTpl
