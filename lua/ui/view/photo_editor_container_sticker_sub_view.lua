local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photo_editor_container_sticker_subView = class("Photo_editor_container_sticker_subView", super)
local IconPath = "ui/atlas/photograph_decoration/stickers/"

function Photo_editor_container_sticker_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  self.camerasysData_ = Z.DataMgr.Get("camerasys_data")
  super.ctor(self, "photo_editor_container_sticker_sub", "photograph/photoalbum_edit_container_sticker_sub", UI.ECacheLv.None)
end

function Photo_editor_container_sticker_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self.lastState_ = nil
  local itemList = self.camerasysData_:GetDecorateStickerCfg()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    self:CreateItems(itemList)
  end)()
end

function Photo_editor_container_sticker_subView:updateListItem()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local itemList = camerasysData:GetDecorateStickerCfg()
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setItemData(itemList)
  end)()
end

function Photo_editor_container_sticker_subView:CreateItems(itemList)
  local unitPath = self.uiBinder.prefab_cashdata:GetString("stickUnit")
  for k, v in pairs(itemList) do
    local name = string.format("sticker_%s", v.Id)
    local item = self:AsyncLoadUiUnit(unitPath, name, self.uiBinder.rect_layout)
    item.img_icon:SetImage(string.format("%s%s_2", IconPath, v.Res))
    item.tog_icon:RemoveAllListeners()
    item.tog_icon:SetIsOnWithoutCallBack(false)
    item.tog_icon:AddListener(function(isOn)
      if self.lastState_ == v.Id then
        return
      end
      if self.lastState_ ~= nil then
        local lastName = string.format("sticker_%s", self.lastState_)
        self.units[lastName].tog_icon:SetIsOnWithoutCallBack(false)
      end
      if isOn then
        self.lastState_ = v.Id
        self.viewData.callBack(v.Res)
        self:refreshDecorateCount()
      end
    end)
  end
  self.uiBinder.rebuild_layout:ForceRebuildLayoutImmediate()
  self:refreshDecorateCount()
end

function Photo_editor_container_sticker_subView:refreshDecorateCount()
  local stickCount = 0
  local maxCount = 0
  if self.viewData.operate then
    stickCount, maxCount = self.viewData.operate()
  end
  self.uiBinder.lab_max.text = string.format("%s/%s", stickCount, maxCount)
end

function Photo_editor_container_sticker_subView:OnDeActive()
  self.lastState_ = nil
end

return Photo_editor_container_sticker_subView
