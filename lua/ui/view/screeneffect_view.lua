local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local super = require("ui.ui_view_base")
local ScreeneffectView = class("ScreeneffectView", super)

function ScreeneffectView:ctor()
  super.ctor(self, "screeneffect")
end

function ScreeneffectView:OnActive()
end

function ScreeneffectView:OnRefresh()
  self:PlayEffect()
end

function ScreeneffectView:PlayEffect()
  local effectType, effectFunc
  if self.viewData then
    effectType = self.viewData.effectType
    effectFunc = self.viewData.effectFunc
  end
  self.uiBinder.fade_effect:PlayFade(effectType, effectFunc)
end

function ScreeneffectView:OnDeActive()
end

return ScreeneffectView
