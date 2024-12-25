local super = require("ui.component.loop_grid_view_item")
local PersonalzoneMedalEditLoopItem = class("PersonalzoneMedalEditLoopItem", super)

function PersonalzoneMedalEditLoopItem:ctor()
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
end

function PersonalzoneMedalEditLoopItem:OnInit()
  self.view_ = self.parent.UIView
  self.using_ = false
  self.uiBinder.btn_click:AddListener(function()
    if self.using_ then
      self.view_:RemoveMedal(self.data_.Id)
    else
      self.view_:AddNewMedal(self.data_.Id)
    end
  end)
end

function PersonalzoneMedalEditLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(self.data_.Image)
  self.using_ = self.view_.medalInfos_[self.data_.Id] ~= nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.using_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.data_.Id))
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.MedalEditItemIndex, self.Index)
end

function PersonalzoneMedalEditLoopItem:OnUnInit()
end

return PersonalzoneMedalEditLoopItem
