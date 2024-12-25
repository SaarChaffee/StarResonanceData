local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_filterView = class("Camera_menu_container_filterView", super)
local filterPath = "ui/atlas/photograph_decoration/filters/"
local camerasysData = Z.DataMgr.Get("camerasys_data")
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")

function Camera_menu_container_filterView:ctor(parent)
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "photoalbum_edit_container_filter_sub", "photograph/photoalbum_edit_container_filter_sub", UI.ECacheLv.None)
  self.isToEditing_ = false
end

function Camera_menu_container_filterView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function Camera_menu_container_filterView:OnDeActive()
end

function Camera_menu_container_filterView:OnRefresh()
  if not self.viewData then
    self.isToEditing_ = false
  else
    self.isToEditing_ = self.viewData.isToEditing
    self.viewData = {}
  end
  self:UpdateListItem()
end

function Camera_menu_container_filterView:UpdateListItem()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetFilterCfg()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetItemData(itemList)
  end)()
end

function Camera_menu_container_filterView:removeUnit()
  self:ClearAllUnits()
end

function Camera_menu_container_filterView:SetItemData(itemList)
  local unitPath = self.uiBinder.prefab_cashdata:GetString("filterUnit")
  if itemList and next(itemList) then
    for k, v in pairs(itemList) do
      local name = string.format("filter%s", k)
      local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.rect_content)
      local index = k
      item.tog_icon.group = self.uiBinder.toggroup_content
      local splData = string.split(v.Res, "=")
      local icon = splData[1]
      local path = splData[2] and splData[2] or ""
      if self.isToEditing_ then
        item.tog_icon:SetIsOnWithoutCallBack(secondaryData:GetMoviescreenData().filterData == path)
      elseif type(camerasysData.FilterIndex) == "number" then
        item.tog_icon:SetIsOnWithoutCallBack(index == camerasysData.FilterIndex)
      elseif type(camerasysData.FilterIndex) == "string" then
        item.tog_icon:SetIsOnWithoutCallBack(path == camerasysData.FilterIndex)
      end
      item.img_icon:SetImage(string.format("%s%s", filterPath, icon))
      item.tog_icon:AddListener(function()
        if item.tog_icon.isOn then
          if self.isToEditing_ then
            secondaryData:GetMoviescreenData().filterData = path
            if not path then
              Z.CameraFrameCtrl:SetAlbumSecondFilter("")
            else
              Z.CameraFrameCtrl:SetAlbumSecondFilter(path)
            end
          else
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
        end
      end)
    end
  end
  self.uiBinder.layoutrebuild_content:ForceRebuildLayoutImmediate()
end

return Camera_menu_container_filterView
