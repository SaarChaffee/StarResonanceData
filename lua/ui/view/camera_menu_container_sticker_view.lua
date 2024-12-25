local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_stickerView = class("Camera_menu_container_stickerView", super)
local data = Z.DataMgr.Get("camerasys_data")
local iconPath = "ui/atlas/photograph_decoration/stickers/"
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")

function Camera_menu_container_stickerView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_sticker_sub", "photograph/camera_menu_container_sticker_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.viewType_ = E.DecorateLayerType.AlbumType
end

function Camera_menu_container_stickerView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self:updateListItem()
  self:BindEvents()
end

function Camera_menu_container_stickerView:OnDeActive()
end

function Camera_menu_container_stickerView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
end

function Camera_menu_container_stickerView:OnRefresh()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.viewData = {}
    self.addViewData_ = secondaryData
    self.viewType_ = E.DecorateLayerType.AlbumType
  else
    self.isToEditing_ = false
    self.addViewData_ = decorateData
    self.viewType_ = E.DecorateLayerType.CamerasysType
  end
  self:setNumber()
end

function Camera_menu_container_stickerView:updateListItem()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetDecorateStickerCfg()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setItemData(itemList)
  end)()
end

function Camera_menu_container_stickerView:removeUnit()
  if not self.units or not next(self.units) then
    return
  end
  for k, item in pairs(self.units) do
    item.buttom_left.DragTool:ClearAll()
    self:RemoveUiUnit(k)
  end
end

function Camera_menu_container_stickerView:setItemData(itemList)
  if itemList and next(itemList) then
    local lastState
    for k, v in pairs(itemList) do
      local name = string.format("sticker%s", k)
      local item = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Camera.Setting_Sticker_Item), name, self.panel.layout_content.Trans)
      item.img_icon.Img:SetImage(string.format("%s%s_2", iconPath, v.Res))
      self:AddClick(item.img_icon.Btn, function()
        local valueData = {}
        valueData.value = v
        valueData.type = E.CamerasysFuncType.Sticker
        valueData.viewType = self.viewType_
        local camerasys_data = Z.DataMgr.Get("camerasys_data")
        local num = self.addViewData_:GetDecoreateNum()
        local maxNum = camerasys_data:GetDecoreateMaxNum()
        if num >= tonumber(maxNum) then
          Z.TipsVM.ShowTipsLang(1000029)
          return
        end
        Z.EventMgr:Dispatch(Z.ConstValue.Camera.CreateDecorate, valueData)
      end)
    end
  end
  self.panel.layout_content.ZLayout:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_stickerView:OnDeActive()
end

function Camera_menu_container_stickerView:setNumber()
  self.panel.lab_max.TMPLab.text = string.format("%s/%s", self.addViewData_:GetDecoreateNum(), data:GetDecoreateMaxNum())
end

return Camera_menu_container_stickerView
