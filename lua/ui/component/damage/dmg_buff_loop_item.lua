local super = require("ui.component.loopscrollrectitem")
local dmgData = Z.DataMgr.Get("damage_data")
local DmgBuffLoop = class("DmgBuffLoop", super)

function DmgBuffLoop:OnInit()
end

function DmgBuffLoop:OnReset()
end

function DmgBuffLoop:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.unit.lab_01.TMPLab.text = self.data_.BuffBaseId
  local buffData = Z.TableMgr.GetTable("BuffTableMgr").GetRow(self.data_.BuffBaseId)
  if buffData then
    self.unit.lab_02.TMPLab.text = buffData.Name
  end
  if dmgData.IsShowNowBuff then
    self.unit.lab_03.TMPLab.text = self.data_.Layer
  else
    self.unit.lab_03.TMPLab.text = self.data_.Duration == 0 and self.data_.Duration or self.data_.Duration / 1000 .. "S"
  end
end

function DmgBuffLoop:OnUnInit()
end

return DmgBuffLoop
