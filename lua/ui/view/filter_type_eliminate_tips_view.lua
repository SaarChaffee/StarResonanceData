local UI = Z.UI
local super = require("ui.ui_subview_base")
local Filter_type_eliminate_tipsView = class("Filter_type_eliminate_tipsView", super)

function Filter_type_eliminate_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "filter_type_eliminate_tips", "common_filter/filter_type_eliminate_tips", UI.ECacheLv.None)
  self.helper_ = parent
  self.mod_data_ = Z.DataMgr.Get("mod_data")
  self.units_ = {}
end

function Filter_type_eliminate_tipsView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_close, function()
    if self.viewData and self.viewData.clearFunc then
      self.viewData.clearFunc()
    else
      self:DeActive()
    end
  end)
end

function Filter_type_eliminate_tipsView:OnDeActive()
  self:clearUnits()
end

function Filter_type_eliminate_tipsView:OnRefresh()
  self:clearUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    local path = self.uiBinder.prefab_cache:GetString("item")
    for type, data in pairs(self.viewData.filterRes) do
      for key, value in pairs(data.value) do
        if value then
          local name = type .. key
          local unit = self:AsyncLoadUiUnit(path, name, self.uiBinder.content, self.cancelSource:CreateToken())
          if unit then
            self:refreshUnit(unit, type, key)
            table.insert(self.units_, name)
          end
        end
      end
    end
  end)()
end

function Filter_type_eliminate_tipsView:clearUnits()
  for _, name in ipairs(self.units_) do
    self:RemoveUiUnit(name)
  end
  self.units_ = {}
end

function Filter_type_eliminate_tipsView:refreshUnit(unit, type, key)
  if type == self.helper_.FilterType.ModType then
    unit.lab_name.text = Lang("ModType_" .. key)
  elseif type == self.helper_.FilterType.ModQuality then
    unit.lab_name.text = Lang("ModQuality_" .. key)
  elseif type == self.helper_.FilterType.ModEffectSelect then
    local config = self.mod_data_:GetEffectTableConfig(key, 0)
    unit.lab_name.text = config.EffectName
  end
end

return Filter_type_eliminate_tipsView
