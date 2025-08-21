local UI = Z.UI
local super = require("ui.ui_view_base")
local Achievement_windowView = class("Achievement_windowView", super)

function Achievement_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "achievement_window")
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function Achievement_windowView:OnActive()
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpSysVM = Z.VMMgr.GetVM("helpsys")
    helpSysVM.OpenFullScreenTipsView(400010)
  end)
  self:AddClick(self.uiBinder.btn, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.Achievement)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
  self.subView_ = require("ui/view/achievement_badge_sub_view").new(self)
  self.subView_:Active(nil, self.uiBinder.node_sub)
end

function Achievement_windowView:OnDeActive()
  self.subView_:DeActive()
end

function Achievement_windowView:OnRefresh()
end

return Achievement_windowView
