local super = require("ui.component.toggleitem")
local WarehouseFirstClassLoopItem = class("WarehouseFirstClassLoopItem", super)
local allItemIconPath = "ui/atlas/item/c_tab_icon/com_icon_tab_166"

function WarehouseFirstClassLoopItem:ctor()
end

function WarehouseFirstClassLoopItem:OnInit()
  self.data_ = Z.DataMgr.Get("warehouse_data")
end

function WarehouseFirstClassLoopItem:Refresh()
  self.isSelected = false
  local type = self.data_:GetWarehouseTypeByIndex(self.index)
  if type and type ~= -1 then
    local row = Z.TableMgr.GetTable("WarehouseTableMgr").GetRow(type)
    if row then
      self.uiBinder.img_on:SetImage(row.Icon)
      self.uiBinder.img_off:SetImage(row.Icon)
    end
  else
    self.uiBinder.img_on:SetImage(allItemIconPath)
    self.uiBinder.img_off:SetImage(allItemIconPath)
  end
end

function WarehouseFirstClassLoopItem:OnSelected(isOn)
  self.isSelected = isOn
end

function WarehouseFirstClassLoopItem:UnInit()
end

return WarehouseFirstClassLoopItem
