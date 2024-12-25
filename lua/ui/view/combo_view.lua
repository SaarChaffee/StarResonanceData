local UI = Z.UI
local super = require("ui.ui_view_base")
local ComboView = class("ComboView", super)

function ComboView:ctor()
  self.panel = nil
  super.ctor(self, "combo")
end

function ComboView:OnActive()
end

function ComboView:OnDeActive()
end

function ComboView:OnRefresh()
  if not self.viewData then
    return
  end
  local comboNumber = tonumber(self.viewData.comboNumber)
  self.panel.zuicombo.Combo:PlayEnterAim(comboNumber)
end

function ComboView:startAnimatedHide()
  local combo = self.panel.zuicombo.Combo
  local asyncCall = Z.CoroUtil.async_to_sync(combo.AsyncPlayEndAnim)
  asyncCall(combo, self.cancelSource:CreateToken())
end

return ComboView
