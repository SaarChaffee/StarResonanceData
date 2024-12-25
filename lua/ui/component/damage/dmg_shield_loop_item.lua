local super = require("ui.component.loopscrollrectitem")
local dmgData = Z.DataMgr.Get("damage_data")
local DmgShieldLoop = class("DmgShieldLoop", super)

function DmgShieldLoop:OnInit()
end

function DmgShieldLoop:OnReset()
end

function DmgShieldLoop:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if self.data_ == nil then
    return
  end
  local buffCfgData = Z.TableMgr.GetTable("BuffTableMgr").GetRow(self.data_.buffConfigId)
  self.unit.lab_id.TMPLab.text = self.data_.buffConfigId
  if buffCfgData then
    self.unit.lab_name.TMPLab.text = buffCfgData.Name
  end
  if dmgData.IsShowNowShield then
    self.unit.lab_03:SetVisible(false)
    self.unit.lab_04.TMPLab.text = self.data_.value
    local time = math.floor((self.data_.downTime - Z.ServerTime:GetServerTime()) / 1000)
    self.unit.lab_05.TMPLab.text = time .. Lang("EquipSecondsText")
  else
    self.unit.lab_03:SetVisible(true)
    self.unit.lab_04.TMPLab.text = self.data_.maxValue - self.data_.value
    local time = math.floor(self.data_.buffDuration / 1000)
    self.unit.lab_03.TMPLab.text = time .. Lang("EquipSecondsText")
    self.unit.lab_05.TMPLab.text = self.data_.overShield
  end
end

function DmgShieldLoop:OnUnInit()
end

return DmgShieldLoop
