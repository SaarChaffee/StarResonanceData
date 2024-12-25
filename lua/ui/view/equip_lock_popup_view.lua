local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_lock_popupView = class("Equip_lock_popupView", super)

function Equip_lock_popupView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_lock_popup", "equip/equip_lock_popup", UI.ECacheLv.None)
end

function Equip_lock_popupView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
  self.uiBinder.lab_current_perfect_num.text = self.viewData.tips or ""
end

function Equip_lock_popupView:OnDeActive()
end

function Equip_lock_popupView:OnRefresh()
end

return Equip_lock_popupView
