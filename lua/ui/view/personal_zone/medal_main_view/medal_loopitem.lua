local super = require("ui.component.loop_grid_view_item")
local PersonalzoneMedalLoopItem = class("PersonalzoneMedalLoopItem", super)

function PersonalzoneMedalLoopItem:ctor()
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
end

function PersonalzoneMedalLoopItem:OnInit()
  self.view_ = self.parent.UIView
  self.uiBinder.img_bg:AddListener(function()
    if self.data_.Id ~= self.view_.selectMedalId_ then
      self.view_:onSelectItem(self.data_.Id)
    end
  end)
end

function PersonalzoneMedalLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(self.data_.Image)
  if self.data_.Id == self.view_.selectMedalId_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
  end
  local hasMedal = self.personalZoneVM_.HasMedal(self.data_.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not hasMedal)
  self.uiBinder.img_icon:SetColor(Color.New(1, 1, 1, hasMedal and 1 or 0.5882352941176471))
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.data_.Id))
end

function PersonalzoneMedalLoopItem:OnUnInit()
end

return PersonalzoneMedalLoopItem
