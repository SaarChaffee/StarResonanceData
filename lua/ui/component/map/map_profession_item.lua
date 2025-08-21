local super = require("ui.component.loop_list_view_item")
local MapProfessionItem = class("MapProfessionItem", super)

function MapProfessionItem:OnInit()
end

function MapProfessionItem:OnRefresh(data)
  local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", data)
  if config == nil then
    return
  end
  self.uiBinder.img_on:SetImage(config.MapIcon)
  self.uiBinder.img_off:SetImage(config.MapIcon)
  local dataList = self.parent:GetData()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, self.Index ~= #dataList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
end

function MapProfessionItem:OnUnInit()
end

function MapProfessionItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
end

function MapProfessionItem:OnPointerClick()
  self.parent.UIView:OnProfessionItemClick(self:GetCurData())
end

return MapProfessionItem
