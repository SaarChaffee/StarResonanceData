local assetPath = "DamagrWeaponItem"
local dmgData = Z.DataMgr.Get("damage_data")
local dmg_tow_data = class("dmg_tow_data")
local dmg = require("ui/component/damage/dmg_skill_loop_item")

function dmg_tow_data:ctor(parent)
  self.parent_ = parent
  self.isFlag_ = true
  self.allUnit_ = {}
  self.allUnitData_ = {}
  self.viewData_ = nil
  self.unitName_ = ""
  self.allHit_ = 0
end

function dmg_tow_data:Refresh()
end

function dmg_tow_data:Active(itemName, viewData, parent, allHit)
  self.item_ = nil
  self.allHit_ = allHit
  self.viewData_ = viewData
  self.unitName_ = itemName .. viewData.id
  Z.CoroUtil.create_coro_xpcall(function()
    self.item_ = self.parent_:AsyncLoadUiUnit(GetLoadAssetPath(assetPath), self.unitName_, parent)
    self.item_.Ref:SetParent(parent)
    self:creatSkillItem()
    self.item_.panel_arrow.Btn:AddListener(function()
      self.isFlag_ = not self.isFlag_
      self.item_.node_data3:SetVisible(self.isFlag_)
      self:creatDmgSkillItem()
    end)
  end)()
end

function dmg_tow_data:creatSkillItem()
  for key, value in pairs(self.viewData_.data) do
    if self.allUnit_[value.skillUuid] == nil then
      local data = dmg.new(self.parent_)
      self.allUnit_[value.skillUuid] = data
      self.allUnitData_[value.skillUuid] = value
    else
      self.allUnitData_[value.skillUuid] = value
    end
  end
  self:creatDmgSkillItem()
  self:setTextData()
end

function dmg_tow_data:creatDmgSkillItem()
  if self.isFlag_ then
    for key, value in pairs(self.allUnit_) do
      value:Active(self.unitName_, self.allUnitData_[key], self.item_.node_data3.Trans, self.allHit_)
    end
  end
end

function dmg_tow_data:setTextData()
  local count = 0
  local hit = 0
  local overHit = 0
  for key, value in pairs(self.viewData_.data) do
    count = value.count + count
    overHit = overHit + value.overHit
    if dmgData.TypeIndex == 3 then
      hit = hit + value.Hit
    else
      hit = hit + value.sheildAndHpLessenValue
    end
  end
  local weaponTab = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(tonumber(self.viewData_.id), true)
  if weaponTab then
    self.item_.lab_01.TMPLab.text = weaponTab.Name
  else
    self.item_.lab_01.TMPLab.text = ""
  end
  local radio
  if self.allHit_ == 0 then
    radio = "0%"
  else
    radio = math.floor(hit / self.allHit_ * 100) .. "%"
  end
  local dps = string.format("%.2f", hit / self.viewData_.time)
  local str = string.zconcat(hit, "/", overHit, " (", dps, "/", Lang("EquipSecondsText"), ", ", count, Lang("GMCount"), "/", dmgData.ReleaseSkillCount, Lang("GMCount"), ", ", self.viewData_.time, "", Lang("EquipSecondsText"), ", ", radio, ")")
  self.item_.lab_02.TMPLab.text = str
  self.item_.slider.Slider.value = math.floor(hit / self.allHit_ * 100)
end

function dmg_tow_data:OnDeActive()
  for key, value in pairs(self.allUnit_) do
    value:OnDeActive()
  end
  self.parent_:RemoveUiUnit(self.unitName_)
  self.parent_ = nil
  self.isFlag_ = nil
  self.allUnit_ = nil
  self.item_ = nil
end

return dmg_tow_data
