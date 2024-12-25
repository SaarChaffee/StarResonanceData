local super = require("ui.component.loopscrollrectitem")
local PersonalZoneMedalSeasonEdit = class("PersonalZoneMedalSeasonEdit", super)

function PersonalZoneMedalSeasonEdit:ctor()
end

function PersonalZoneMedalSeasonEdit:OnInit()
  self.view_ = self.parent.uiView
  self.using_ = false
  self:AddClick(self.uiBinder.btn_click, function()
    if self.using_ then
      self.view_:RemoveMedal(self.data_.Id)
    else
      self.view_:AddNewMedal(self.data_.Id)
    end
  end)
end

function PersonalZoneMedalSeasonEdit:OnUnInit()
  self.view_ = nil
  self.using_ = nil
end

function PersonalZoneMedalSeasonEdit:Refresh()
  local index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index_)
  self.uiBinder.img_icon:SetImage(self.data_.Image)
  self.using_ = self.view_.medalInfos_[self.data_.Id] ~= nil
  self:SetUIVisible(self.uiBinder.node_on, self.using_)
end

return PersonalZoneMedalSeasonEdit
