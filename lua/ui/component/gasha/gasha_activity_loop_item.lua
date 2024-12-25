local super = require("ui.component.loop_list_view_item")
local GashaActivityLoopItem = class("GashaActivityLoopItem", super)

function GashaActivityLoopItem:ctor()
end

function GashaActivityLoopItem:OnInit()
end

function GashaActivityLoopItem:OnRefresh(data)
  self.data = data
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  self.uiBinder.img_vehicle_on:SetImage(self.data.Sticker[1])
  self.uiBinder.img_vehicle_off:SetImage(self.data.Sticker[2])
  local hasLimit = false
  local timerId = data.TimerId
  local timerConfig = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timerId)
  if not timerConfig then
    hasLimit = false
  elseif timerConfig.endtime and string.len(timerConfig.endtime) > 0 then
    hasLimit = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.nodeLimit1, hasLimit)
  self.uiBinder.Ref:SetVisible(self.uiBinder.nodeLimit2, hasLimit)
end

function GashaActivityLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot_on, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot_off, not isSelected)
  if isSelected then
    if not self.effectCreated then
      self.effectCreated = true
      self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect)
      self.uiBinder.effect:CreatEFFGO(string.zconcat("ui/uieffect/prefab/", self.data.StickerEffect), Vector3.zero)
      self.uiBinder.effect:SetEffectGoVisible(true)
    end
    self.parent.UIView:OnToggleSelected(self.data.Id, self.Index)
  end
end

function GashaActivityLoopItem:OnUnInit()
  self.effectCreated = false
  self.uiBinder.effect:ReleseEffGo()
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect)
end

return GashaActivityLoopItem
