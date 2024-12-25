local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local super = require("ui.ui_view_base")
local ScreeneffectView = class("ScreeneffectView", super)

function ScreeneffectView:ctor()
  self.panel = nil
  super.ctor(self, "screeneffect")
end

function ScreeneffectView:OnActive()
end

function ScreeneffectView:OnRefresh()
  self:PlayEffect()
end

function ScreeneffectView:PlayEffect()
  local effectName, effectFunc
  if self.viewData then
    effectName = self.viewData.effectname
    effectFunc = self.viewData.effectfunc
  end
  if effectName == nil or effectName == "" then
    return
  end
  self.panel.ani_root.Fade:PlayFade(tostring(effectName), effectFunc)
end

function ScreeneffectView:OnDeActive()
end

return ScreeneffectView
