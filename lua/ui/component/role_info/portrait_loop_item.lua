local super = require("ui.component.loopscrollrectitem")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local PortraitLoopItem = class("PortraitLoopItem", super)

function PortraitLoopItem:ctor()
end

function PortraitLoopItem:OnInit()
  self.vm_ = Z.VMMgr.GetVM("portrait_indiv_popup")
end

function PortraitLoopItem:Refresh()
  self:setUI()
end

function PortraitLoopItem:OnReset()
  self.unit.content.img_select:SetVisible(false)
end

function PortraitLoopItem:setUI()
  local index = self.component.Index + 1
  if index > self.parent:GetCount() then
    self.component.CanSelected = false
    self.unit:SetVisible(false)
    return
  end
  self.data = self.parent:GetDataByIndex(index)
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local viewData = {
    id = self.data.Id,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.CharId,
    isShowCombinationIcon = false,
    isShowTalentIcon = false,
    token = self.parent.uiView.cancelSource:CreateToken()
  }
  playerPortraitHgr.InsertPortrait(self.unit.content, viewData)
  self.unit.content.group_unlocked:SetVisible(not self.vm_.CheckPortraitUnlock(self.data.Id))
  self.unit.content.img_select:SetVisible(false)
end

function PortraitLoopItem:Selected(isSelected)
  if isSelected then
    Z.EventMgr:Dispatch(Z.ConstValue.PortraitSelect, self.data.Id)
  end
  self.unit.content.img_select:SetVisible(isSelected)
end

return PortraitLoopItem
