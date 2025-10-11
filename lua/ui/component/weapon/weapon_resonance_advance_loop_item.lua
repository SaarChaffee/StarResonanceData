local super = require("ui.component.loop_list_view_item")
local WeaponResonanceAdvanceLoopItem = class("WeaponResonanceAdvanceLoopItem", super)

function WeaponResonanceAdvanceLoopItem:ctor()
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
end

function WeaponResonanceAdvanceLoopItem:OnInit()
end

function WeaponResonanceAdvanceLoopItem:OnRefresh(data)
  local itemHeight = 0
  if data.type == 1 then
    self.uiBinder.lab_name.text = data.desc
    self.uiBinder.lab_value.text = data.lastValue
    self.uiBinder.lab_add_value.text = data.curValue
    local valueHeight = math.max(self.uiBinder.lab_value.preferredHeight, self.uiBinder.lab_add_value.preferredHeight)
    itemHeight = valueHeight + math.max(60, self.uiBinder.lab_name.preferredHeight + 30)
  elseif data.type == 2 then
    self.uiBinder.lab_name.text = data.desc
    self.uiBinder.lab_value.text = ""
    itemHeight = self.uiBinder.lab_name.preferredHeight + 20
  elseif data.type == 3 then
    self.uiBinder.lab_name.text = data.desc
    self.uiBinder.lab_value.text = ""
    itemHeight = self.uiBinder.lab_name.preferredHeight + 20
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_promotion, data.type == 1)
  self.uiBinder.Trans:SetHeight(itemHeight)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function WeaponResonanceAdvanceLoopItem:OnUnInit()
end

return WeaponResonanceAdvanceLoopItem
