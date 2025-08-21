local UI = Z.UI
local super = require("ui.ui_view_base")
local Vehicle_tipsView = class("Vehicle_tipsView", super)
local vehicleDefine = require("ui.model.vehicle_define")
local vehicleTipsItemTplItem = require("ui/component/vehicle/vehicle_tips_item_tpl_item")

function Vehicle_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "vehicle_tips")
end

function Vehicle_tipsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  local config = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(self.viewData.vehicleId)
  if config == nil then
    return
  end
  local skills = {}
  local skillsCount = 0
  if self.viewData.type == vehicleDefine.PopType.Skill then
    self.uiBinder.lab_title.text = Lang("VehicleSkillDetail")
    for _, skill in ipairs(config.VehSkillIds) do
      if skill[2] then
        skillsCount = skillsCount + 1
        skills[skillsCount] = skill[2]
      end
    end
    for _, skill in ipairs(config.PassiveSkillId) do
      skillsCount = skillsCount + 1
      skills[skillsCount] = skill
    end
  elseif self.viewData.type == vehicleDefine.PopType.Property then
    self.uiBinder.lab_title.text = Lang("VehiclePropertyDetail")
    skills = config.PropertyId
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local path = self.uiBinder.uiprefab_cache:GetString("item")
    for _, skill in ipairs(skills) do
      local name = "unit" .. skill
      local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_info)
      if unit then
        vehicleTipsItemTplItem.RefreshTpl(unit, skill, self.viewData.type)
      end
    end
  end)()
end

function Vehicle_tipsView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Vehicle_tipsView:OnRefresh()
end

return Vehicle_tipsView
