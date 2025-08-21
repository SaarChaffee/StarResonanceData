local UI = Z.UI
local super = require("ui.ui_view_base")
local Gm_fashion_popupView = class("Gm_fashion_popupView", super)

function Gm_fashion_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gm_fashion_popup")
  self.vm_ = Z.VMMgr.GetVM("gm_fashion_popup")
end

function Gm_fashion_popupView:OnActive()
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.inputColorValue_ = ""
  self.uiBinder.input_color.text = ""
  self.colorValue_ = 1
  self.curColorString_ = ""
  self.uiBinder.lab_color_value.text = ""
  self.uiBinder.lab_color_cur.text = ""
  self.curFashionId_ = 0
  self.uiBinder.img_bg.onDrag:AddListener(function(go, pointerData)
    local pos = self.uiBinder.img_bg_ref.localPosition
    local posX = pos.x + pointerData.delta.x
    local posy = pos.y + pointerData.delta.y
    self.uiBinder.img_bg_ref:SetLocalPos(posX, posy)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.vm_.CloseGmFashionPopup()
  end)
  self:AddClick(self.uiBinder.input_color, function(value)
    self.inputColorValue_ = value
  end)
  self:AddClick(self.uiBinder.btn_load, function()
    self:loadColor()
  end)
  self:AddClick(self.uiBinder.btn_copy, function()
    self:copyColor()
  end)
  self:AddClick(self.uiBinder.btn_res, function()
    self:copyResource()
  end)
  self:BindEvents()
end

function Gm_fashion_popupView:OnDeActive()
  self:UnBindEvents()
end

function Gm_fashion_popupView:loadColor()
  local colorArray = string.split(self.inputColorValue_, "|")
  for _, colorInfo in pairs(colorArray) do
    if colorInfo ~= "" then
      local colorData = string.split(colorInfo, "=")
      local area = tonumber(colorData[1])
      local h = tonumber(colorData[2])
      local s = tonumber(colorData[3])
      local v = tonumber(colorData[4])
      if self.curFashionId_ and area and h and s and v then
        self.fashionVM_.SetFashionColor(self.curFashionId_, area, {
          h = h,
          s = s,
          v = v
        }, true, true)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.FashionColorChange)
end

function Gm_fashion_popupView:copyColor()
  Z.LuaBridge.SystemCopy(self.curColorString_)
end

function Gm_fashion_popupView:copyResource()
  if self.fashionTableData_ then
    Z.LuaBridge.SystemCopy(self.fashionTableData_.Model)
  end
end

function Gm_fashion_popupView:changeColorInfo(fashionId)
  if self.curFashionId_ ~= fashionId then
    self.fashionTableData_ = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId)
  end
  self.curFashionId_ = fashionId
  local colorArea = self.fashionData_:GetColor(fashionId)
  if colorArea then
    self.curColorString_ = ""
    for area, color in pairs(colorArea) do
      self.curColorString_ = string.zconcat(self.curColorString_, area, "=", color.h, "=", color.s, "=", color.v, "|")
    end
    self.uiBinder.lab_color_cur.text = self.curColorString_
  end
end

function Gm_fashion_popupView:changeColorIPrice(isHeightCost)
  if isHeightCost then
    self.uiBinder.lab_color_value.text = Lang("gm_fashion_high")
  else
    self.uiBinder.lab_color_value.text = Lang("gm_fashion_low")
  end
end

function Gm_fashion_popupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.GM.GMFashionView, self.changeColorInfo, self)
  Z.EventMgr:Add(Z.ConstValue.GM.GMFashionViewPrice, self.changeColorIPrice, self)
end

function Gm_fashion_popupView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.GM.GMFashionView, self.changeColorInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.GM.GMFashionViewPrice, self.changeColorIPrice, self)
end

return Gm_fashion_popupView
