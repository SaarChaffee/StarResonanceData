local super = require("ui.component.loop_list_view_item")
local VehiclePeculiarityItemTplItem = class("VehiclePeculiarityItemTplItem", super)

function VehiclePeculiarityItemTplItem:OnInit()
end

function VehiclePeculiarityItemTplItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("VehiclePropertyTableMgr").GetRow(data)
  if config then
    self.uiBinder.img_icon:SetImage(config.Icon)
    self.uiBinder.lab_title.text = config.Name
    self.uiBinder.lab_content.text = config.Desc
  end
end

function VehiclePeculiarityItemTplItem:OnUnInit()
end

return VehiclePeculiarityItemTplItem
