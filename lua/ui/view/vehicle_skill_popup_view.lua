local UI = Z.UI
local super = require("ui.ui_view_base")
local Vehicle_skill_popupView = class("Vehicle_skill_popupView", super)
local loopListView = require("ui/component/loop_list_view")
local vehicleDefine = require("ui.model.vehicle_define")
local vehicleSkillItemTplItem = require("ui/component/vehicle/vehicle_skill_item_tpl_item")
local vehiclePeculiarityItemTplItem = require("ui/component/vehicle/vehicle_peculiarity_item_tpl_item")

function Vehicle_skill_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "vehicle_skill_popup")
end

function Vehicle_skill_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.listSkillItem_ = loopListView.new(self, self.uiBinder.loop_item_skill, vehicleSkillItemTplItem, "vehicle_skill_item_tpl")
  self.listPropertyItem_ = loopListView.new(self, self.uiBinder.loop_item_peculiarity, vehiclePeculiarityItemTplItem, "vehicle_peculiarity_item_tpl")
  if self.viewData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_skill, self.viewData.type == vehicleDefine.PopType.Skill)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_peculiarity, self.viewData.type == vehicleDefine.PopType.Property)
    local config = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(self.viewData.vehicleId)
    if config then
      if self.viewData.type == vehicleDefine.PopType.Skill and config.SkillId and config.SkillId ~= 0 then
        self.uiBinder.lab_title.text = Lang("VehicleSkillDetail")
        self.listSkillItem_:Init({
          config.SkillId
        })
      elseif self.viewData.type == vehicleDefine.PopType.Property then
        self.uiBinder.lab_title.text = Lang("VehiclePropertyDetail")
        self.listPropertyItem_:Init(config.PropertyId)
      end
    end
  end
end

function Vehicle_skill_popupView:OnDeActive()
  if self.listSkillItem_ then
    self.listSkillItem_:UnInit()
    self.listSkillItem_ = nil
  end
  if self.listPropertyItem_ then
    self.listPropertyItem_:UnInit()
    self.listPropertyItem_ = nil
  end
end

function Vehicle_skill_popupView:OnRefresh()
end

return Vehicle_skill_popupView
