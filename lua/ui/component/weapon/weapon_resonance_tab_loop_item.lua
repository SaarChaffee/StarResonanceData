local super = require("ui.component.loop_list_view_item")
local WeaponResonanceTabLoopItem = class("WeaponResonanceTabLoopItem", super)

function WeaponResonanceTabLoopItem:ctor()
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
end

function WeaponResonanceTabLoopItem:OnInit()
end

function WeaponResonanceTabLoopItem:OnRefresh(data)
  local curSkillId = self.parent.UIView:GetCurSkillId()
  local advanceLevel = self.weaponSkillVM_:GetSkillRemodelLevel(curSkillId)
  local levelNum = data.Level
  local isUnlock = levelNum <= advanceLevel + 1
  local levelStr = levelNum
  if levelNum < 10 then
    levelStr = "0" .. levelStr
  end
  local colorRichText = isUnlock and "<alpha=#ff>" or "<alpha=#1A>"
  levelStr = string.zconcat(colorRichText, levelStr)
  self.uiBinder.lab_normal.text = levelStr
  self.uiBinder.lab_select.text = levelStr
  local count = #self.parent.DataList
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, levelNum ~= count)
  self:refreshSelectUI()
  local curSkillId = self.parent.UIView:GetCurSkillId()
  self:loadRedDotItem(curSkillId, data.Level)
end

function WeaponResonanceTabLoopItem:refreshSelectUI()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_normal, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_select, self.IsSelected)
end

function WeaponResonanceTabLoopItem:OnUnInit()
end

function WeaponResonanceTabLoopItem:OnSelected()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self:refreshSelectUI()
  if self.IsSelected then
    self.parent.UIView:OnTabSelected(curData.Level)
  end
end

function WeaponResonanceTabLoopItem:loadRedDotItem(skillId, skillLv)
  local nodeId = self.weaponSkillVM_:GetResonanceAdvanceRedDotId(skillId, skillLv)
  Z.RedPointMgr.LoadRedDotItem(nodeId, self.parent.UIView, self.uiBinder.Trans)
end

return WeaponResonanceTabLoopItem
