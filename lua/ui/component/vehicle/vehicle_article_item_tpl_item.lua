local super = require("ui.component.loop_list_view_item")
local VehicleArticleItemTplItem = class("VehicleArticleItemTplItem", super)

function VehicleArticleItemTplItem:OnInit()
end

function VehicleArticleItemTplItem:OnRefresh(data)
  self.uiBinder.lab_name.text = data.name
  self.uiBinder.lab_number.text = data.num
end

function VehicleArticleItemTplItem:OnUnInit()
end

return VehicleArticleItemTplItem
