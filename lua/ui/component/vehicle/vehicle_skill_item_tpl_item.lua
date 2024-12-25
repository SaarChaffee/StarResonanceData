local super = require("ui.component.loop_list_view_item")
local VehicleSkillItemTplItem = class("VehicleSkillItemTplItem", super)

function VehicleSkillItemTplItem:OnInit()
end

function VehicleSkillItemTplItem:OnRefresh(data)
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(data)
  if config then
    self.uiBinder.img_icon:SetImage(config.Icon)
    self.uiBinder.lab_title.text = config.Name
    self.uiBinder.lab_content.text = config.Desc
  end
end

function VehicleSkillItemTplItem:OnUnInit()
end

return VehicleSkillItemTplItem
