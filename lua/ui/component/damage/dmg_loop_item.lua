local super = require("ui.component.loopscrollrectitem")
local dmgData = Z.DataMgr.Get("damage_data")
local dmg = require("ui/component/damage/dmg_weapon_loop_item")
local dmgVm = Z.VMMgr.GetVM("damage")
local DmgLoopItem = class("DmgLoopItem", super)

function DmgLoopItem:ctor()
end

function DmgLoopItem:OnInit()
  self.isFlag = false
  self.allUnit_ = {}
  self.allUnitData_ = {}
  self.allWeaponId = {}
  self:AddClick(self.unit.panel_arrow.Btn, function()
    self.isFlag = not self.isFlag
    self.unit.node_data2:SetVisible(self.isFlag)
    if self.isFlag then
      self:refreshChildItem()
    end
  end)
end

function DmgLoopItem:refreshChildItem()
  for key, value in pairs(self.allUnit_) do
    for k, v in pairs(self.allWeaponId) do
      if key == self.data_.attUuid .. self.data_.byAttUuid .. self.data_.patrUuid .. v and self.isFlag then
        value:Active(key, self.allUnitData_[key], self.unit.node_data2.Trans, self.hit)
      end
    end
  end
end

function DmgLoopItem:refreshLab()
  local attrName = ""
  local ent = Z.EntityMgr:GetEntity(tonumber(self.data_.attUuid))
  if ent then
    attrName = ent:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
    if attrName == nil then
      local monsterTab = dmgVm.GetMonsterTab(self.data_.attUuid)
      if monsterTab == nil then
        attrName = self.data_.attUuid
      else
        attrName = monsterTab.Name
      end
    end
  else
    attrName = self.data_.byAttUuid
  end
  local byAttName = ""
  local ent = Z.EntityMgr:GetEntity(tonumber(self.data_.byAttUuid))
  if ent then
    byAttName = ent:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
    if byAttName == nil then
      local monsterTab = dmgVm.GetMonsterTab(self.data_.byAttUuid)
      if monsterTab == nil then
        byAttName = self.data_.byAttUuid
      else
        byAttName = monsterTab.Name
      end
    end
  else
    byAttName = self.data_.byAttUuid
  end
  if self.data_.patrUuid ~= 0 then
    self.unit.lab_01.TMPLab.text = string.zconcat(attrName, "-", byAttName, "-", self.data_.patrUuid)
  else
    self.unit.lab_01.TMPLab.text = attrName .. "-" .. byAttName
  end
  local count = 0
  local time = 0
  local overHit = 0
  for key, value in pairs(self.data_.data) do
    for k, v in pairs(value.data) do
      count = count + v.count
      if dmgData.TypeIndex == 3 then
        self.hit = self.hit + v.Hit
      else
        self.hit = self.hit + v.sheildAndHpLessenValue
      end
      overHit = overHit + v.overHit
    end
    time = time + value.time
  end
  local ratio
  if self.data_.allHit == 0 then
    ratio = "0%"
  else
    ratio = math.floor(self.hit / self.data_.allHit * 100) .. "%"
  end
  self.unit.slider.Slider.value = math.floor(self.hit / self.data_.allHit * 100)
  local dps = string.format("%.2f", self.hit / time)
  local str = string.zconcat(self.hit, "/", overHit, " (", dps, "/ ", Lang("EquipSecondsText"), ", ", count, Lang("GMCount"), "/", dmgData.ReleaseSkillCount, Lang("GMCount"), ", ", time, Lang("EquipSecondsText"), ", ", ratio, ")")
  self.unit.lab_02.TMPLab.text = str
end

function DmgLoopItem:Refresh()
  self.hit = 0
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  for key, value in pairs(self.data_.data) do
    if not self.allWeaponId[value.id] then
      self.allWeaponId[value.id] = value.id
    end
    if self.allUnit_[self.data_.attUuid .. self.data_.byAttUuid .. self.data_.patrUuid .. value.id] == nil then
      local data = dmg.new(self.parent.uiView)
      self.allUnit_[self.data_.attUuid .. self.data_.byAttUuid .. self.data_.patrUuid .. value.id] = data
      self.allUnitData_[self.data_.attUuid .. self.data_.byAttUuid .. self.data_.patrUuid .. value.id] = value
    else
      self.allUnitData_[self.data_.attUuid .. self.data_.byAttUuid .. self.data_.patrUuid .. value.id] = value
    end
  end
  self:refreshLab()
  self:refreshChildItem()
end

function DmgLoopItem:OnUnInit()
  for key, value in pairs(self.allUnit_) do
    value:OnDeActive()
  end
  self.allUnit_ = nil
end

return DmgLoopItem
