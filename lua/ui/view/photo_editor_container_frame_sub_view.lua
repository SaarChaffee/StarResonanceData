local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photo_editor_container_frame_subView = class("Photo_editor_container_frame_subView", super)
local FilterPath = "ui/textures/photograph_decoration/frame/"

function Photo_editor_container_frame_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  self.camerasysData_ = Z.DataMgr.Get("camerasys_data")
  super.ctor(self, "photo_editor_container_frame_sub", "photograph/photoalbum_edit_container_frame_sub", UI.ECacheLv.None)
end

function Photo_editor_container_frame_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  local itemList = self.camerasysData_:GetDecorateFrameCfg()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    self:CreateItems(itemList)
  end)()
end

function Photo_editor_container_frame_subView:OnDeActive()
end

function Photo_editor_container_frame_subView:CreateItems(itemList)
  local unitPath = self.uiBinder.prefab_cashdata:GetString("frameUnit")
  for k, v in pairs(itemList) do
    local name = string.format("frame_%s", k)
    local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.rect_content)
    item.tog_icon.group = self.uiBinder.toggroup_layout
    local frameType = v.Parameter
    local path = string.format("%s%s", FilterPath, v.Res)
    item.img_icon:SetImage(path)
    if self.viewData.operate then
      item.tog_icon:SetIsOnWithoutCallBack(self.viewData.operate(frameType, v.Res))
    else
      item.tog_icon:SetIsOnWithoutCallBack(false)
    end
    item.tog_icon:AddListener(function(isOn)
      if isOn then
        self.viewData.callBack(frameType, v.Res)
      end
    end)
  end
  self.uiBinder.layout_content:ForceRebuildLayoutImmediate()
end

return Photo_editor_container_frame_subView
