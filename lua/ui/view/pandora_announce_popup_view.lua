local UI = Z.UI
local super = require("ui.ui_view_base")
local Pandora_announce_popupView = class("Pandora_announce_popupView", super)

function Pandora_announce_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "pandora_announce_popup")
  self.pandoraVM_ = Z.VMMgr.GetVM("pandora")
end

function Pandora_announce_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Pandora_announce_popupView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Pandora_announce_popupView:OnRefresh()
end

function Pandora_announce_popupView:OnInputBack()
  self.pandoraVM_:ClosePandoraAnnounce()
end

return Pandora_announce_popupView
