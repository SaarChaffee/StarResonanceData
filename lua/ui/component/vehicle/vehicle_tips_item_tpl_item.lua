local VehicleTipsItemTplItem = class("VehicleTipsItemTplItem")
local vehicleDefine = require("ui.model.vehicle_define")

function VehicleTipsItemTplItem.RefreshTpl(uibinder, id, type)
  if type == vehicleDefine.PopType.Skill then
    uibinder.vehicle_icon_item_tpl.Ref.UIComp:SetVisible(false)
    uibinder.vehicle_skill_item_tpl.Ref.UIComp:SetVisible(true)
    local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(id)
    if config then
      uibinder.vehicle_skill_item_tpl.img_icon:SetImage(config.Icon)
      uibinder.lab_title.text = config.Name
      uibinder.lab_content.text = config.Desc
    end
  else
    uibinder.vehicle_icon_item_tpl.Ref.UIComp:SetVisible(true)
    uibinder.vehicle_skill_item_tpl.Ref.UIComp:SetVisible(false)
    local config = Z.TableMgr.GetTable("VehiclePropertyTableMgr").GetRow(id)
    if config then
      uibinder.vehicle_icon_item_tpl.img_icon:SetImage(config.Icon)
      uibinder.lab_title.text = config.Name
      uibinder.lab_content.text = config.Desc
    end
  end
end

return VehicleTipsItemTplItem
