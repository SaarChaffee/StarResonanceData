local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_unionBgView = class("Camera_menu_container_unionBgView", super)
local camerasysData = Z.DataMgr.Get("camerasys_data")
local CameraUnionBgItem = require("ui.component.camerasys.camerasys_union_bg_item")
local loopGridView = require("ui.component.loop_grid_view")

function Camera_menu_container_unionBgView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_bg_sub", "photograph/camera_menu_container_bg_sub", UI.ECacheLv.None)
end

function Camera_menu_container_unionBgView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cardLoopScroll_ = loopGridView.new(self, self.uiBinder.scrollview_filter, CameraUnionBgItem, "photo_idcard_bg_tpl")
  local data = self.cameraData_:GetUnionBgCfg()
  self.cardLoopScroll_:Init(data)
  self.cardLoopScroll_:SetSelected(1)
end

function Camera_menu_container_unionBgView:OnDeActive()
  self.cardLoopScroll_:UnInit()
  self.cardLoopScroll_ = nil
end

function Camera_menu_container_unionBgView:OnRefresh()
end

function Camera_menu_container_unionBgView:updateListItem()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetFilterCfg()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetItemData(itemList)
  end)()
end

function Camera_menu_container_unionBgView:removeUnit()
  self:ClearAllUnits()
end

function Camera_menu_container_unionBgView:SetItemData(itemList)
  if itemList and next(itemList) then
    for k, v in pairs(itemList) do
      local name = string.format("filter%s", k)
      local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Setting_Filter_Item), name, self.panel.layout_content.Trans)
      local data = v
      local index = k
      item.img_icon.Tog.group = self.panel.layout_content.TogGroup
      local splData = string.split(data.Res, "=")
      local icon = splData[1]
      local path = splData[2] and splData[2] or ""
      if type(camerasysData.FilterIndex) == "number" then
        if index == camerasysData.FilterIndex then
          item.img_icon.Tog.isOn = true
        end
      elseif type(camerasysData.FilterIndex) == "string" and path == camerasysData.FilterIndex then
        item.img_icon.Tog.isOn = true
      end
      item.img_icon.Img:SetImage(string.format("%s%s", filterPath, icon))
      item.img_icon.Tog:AddListener(function()
        if item.img_icon.Tog.isOn then
          camerasysData.FilterIndex = index
          decorateData:GetMoviescreenData().filterData = path
          camerasysData:SetIsSchemeParamUpdated(true)
          camerasysData.FilterPath = path
          if not path or path == "" then
            Z.CameraFrameCtrl:SetDefineFilterAsync()
          else
            Z.CameraFrameCtrl:SetFilterAsync(path)
          end
        end
      end)
    end
  end
  self.panel.layout_content.ZLayout:ForceRebuildLayoutImmediate()
end

return Camera_menu_container_unionBgView
