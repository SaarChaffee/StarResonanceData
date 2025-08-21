local super = require("ui.component.loop_grid_view_item")
local CameraInvitedAddLoopItem = class("CameraInvitedAddLoopItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function CameraInvitedAddLoopItem:ctor()
  super:ctor()
end

function CameraInvitedAddLoopItem:OnInit()
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self:initBtn()
end

function CameraInvitedAddLoopItem:initBtn()
  self.parent.UIView:AddClick(self.uiBinder.btn_add, function()
    self.cameraMemberVM_:AddMemberToList(self.data_.basicData.charID, self.data_)
  end)
end

function CameraInvitedAddLoopItem:OnRefresh(data)
  self.data_ = data
  self:refreshPlayerInfo()
  self:setHead()
end

function CameraInvitedAddLoopItem:refreshPlayerInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data_.basicData.isNewbie))
  self.uiBinder.lab_level.text = Lang("RoleLevel", {
    val = self.data_.basicData.level
  })
  self.uiBinder.lab_name.text = self.data_.basicData.name
end

function CameraInvitedAddLoopItem:setHead()
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, self.data_)
end

function CameraInvitedAddLoopItem:OnUnInit()
end

return CameraInvitedAddLoopItem
