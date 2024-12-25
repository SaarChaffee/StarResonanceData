local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_frameView = class("Camera_menu_container_frameView", super)
local filterPath = "ui/atlas/photograph_decoration/frame/"
local decorateData_ = Z.DataMgr.Get("decorate_add_data")
local secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
local cameraData_ = Z.DataMgr.Get("camerasys_data")

function Camera_menu_container_frameView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_frame_sub", "photograph/camera_menu_container_frame_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.isToEditing_ = false
end

function Camera_menu_container_frameView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self:UpdateListItem()
end

function Camera_menu_container_frameView:OnDeActive()
  self.camerasysTabScrollRect = nil
end

function Camera_menu_container_frameView:OnRefresh()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.viewData = {}
    self.addViewData_ = secondaryData_
    self:UpdateListItem()
  else
    self.isToEditing_ = false
    self.addViewData_ = decorateData_
  end
end

function Camera_menu_container_frameView:updateSelectTog()
  if not self.units or not next(self.units) then
    return
  end
end

function Camera_menu_container_frameView:UpdateListItem()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetDecorateFrameCfg()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetItemData(itemList)
  end)()
end

function Camera_menu_container_frameView:removeUnit()
  self:ClearAllUnits()
end

function Camera_menu_container_frameView:SetItemData(itemList)
  if itemList and next(itemList) then
    for k, v in pairs(itemList) do
      local name = string.format("frame%s", k)
      local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Setting_Frame_Item), name, self.panel.layout_content.Trans)
      local data = v
      local index = k
      item.img_icon.Tog.group = self.panel.layout_content.TogGroup
      local splData = string.split(data.Res, "=")
      local icon = splData[1]
      local frameType = tonumber(splData[2])
      local path
      if self.isToEditing_ then
        if secondaryData_:GetMoviescreenData().frameData == data.Res then
          item.img_icon.Tog.isOn = true
        else
          item.img_icon.Tog.isOn = false
        end
      elseif frameType == E.CameraFrameType.None or decorateData_:GetMoviescreenData().frameData == data.Res then
        item.img_icon.Tog.isOn = true
      else
        item.img_icon.Tog.isOn = false
      end
      path = string.format("%s%s", filterPath, icon)
      item.img_icon.Img:SetImage(path)
      item.img_icon.Tog:AddListener(function()
        if item.img_icon.Tog.isOn then
          if self.isToEditing_ then
            secondaryData_:GetMoviescreenData().frameData = data.Res
          else
            cameraData_:SetIsSchemeParamUpdated(true)
            cameraData_.FrameIndex = index
            decorateData_:GetMoviescreenData().frameData = data.Res
            Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerSet, data)
          end
        end
      end)
    end
  end
  self.panel.layout_content.ZLayout:ForceRebuildLayoutImmediate()
end

return Camera_menu_container_frameView
