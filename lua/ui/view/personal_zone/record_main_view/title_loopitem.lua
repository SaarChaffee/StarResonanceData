local super = require("ui.component.loop_grid_view_item")
local PersonalzoneTitileTplItem = class("PersonalzoneTitileTplItem", super)
local DEFINE = require("ui.model.personalzone_define")

function PersonalzoneTitileTplItem:ctor()
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.colors_ = {
    [1] = Color.New(1, 1, 1, 1),
    [2] = Color.New(1, 1, 1, 0.4)
  }
end

function PersonalzoneTitileTplItem:OnInit()
  self.view_ = self.parent.UIView
  self.uiBinder.btn:AddListener(function()
    if self.view_.selectId_ == self.data_.config.Id then
      return
    end
    self.view_:SetSelect(self.data_.config.Id)
  end)
end

function PersonalzoneTitileTplItem:OnUnInit()
end

function PersonalzoneTitileTplItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, self.data_.config.Unlock == DEFINE.ProfileImageUnlockType.DefaultUnlock)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.data_.config.Id)
  if config then
    self.uiBinder.lab_on_name.text = config.Name
    self.uiBinder.lab_lock_name.text = config.Name
  end
  local isUnlcok = self.personalZoneVM_.CheckProfileImageIsUnlock(self.data_.config.Id)
  if isUnlcok then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_lock, false)
    self.uiBinder.img_base:SetColor(self.colors_[1])
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_lock, true)
    self.uiBinder.img_base:SetColor(self.colors_[2])
  end
  local isUse = self.data_.config.Id == self.personalZoneVM_.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_me, isUse)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.data_.select)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.data_.config.Id))
end

return PersonalzoneTitileTplItem
