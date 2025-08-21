local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photo_editor_container_filter_subView = class("Photo_editor_container_filter_subView", super)
local FilterPath = "ui/textures/photograph_decoration/filters/"

function Photo_editor_container_filter_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  super.ctor(self, "photoalbum_edit_container_filter_sub", "photograph/photoalbum_edit_container_filter_sub", UI.ECacheLv.None)
end

function Photo_editor_container_filter_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetFilterCfg()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetItemData(itemList)
  end)()
end

function Photo_editor_container_filter_subView:OnDeActive()
end

function Photo_editor_container_filter_subView:SetItemData(itemList)
  local unitPath = self.uiBinder.prefab_cashdata:GetString("filterUnit")
  if itemList and next(itemList) then
    for k, v in pairs(itemList) do
      local name = string.format("filter_%s", k)
      local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.rect_content)
      local splData = string.split(v.Res, "=")
      local icon = splData[1]
      local path = splData[2] and splData[2] or ""
      item.tog_icon.group = self.uiBinder.toggroup_content
      if self.viewData.operate then
        item.tog_icon:SetIsOnWithoutCallBack(self.viewData.operate(path))
      else
        item.tog_icon:SetIsOnWithoutCallBack(false)
      end
      item.tog_icon:AddListener(function(isOn)
        if isOn then
          self.viewData.callBack(path)
        end
      end)
      item.img_icon:SetImage(string.format("%s%s", FilterPath, icon))
    end
  end
  self.uiBinder.layoutrebuild_content:ForceRebuildLayoutImmediate()
end

return Photo_editor_container_filter_subView
