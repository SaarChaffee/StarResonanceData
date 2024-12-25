local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_Mainbg_View = class("Personalzone_Mainbg_View", super)
local OriginalPath = "ui/textures/personalzone_bg/personalzone_main_bg_1"

function Personalzone_Mainbg_View:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_mainbg")
end

function Personalzone_Mainbg_View:OnActive()
  local pos = self.uiBinder.Trans.localPosition
  Z.WorldUIMgr:SetCanvasRoot(self.uiBinder.Trans)
  self.uiBinder.Trans:SetLocalPos(pos.x, pos.y)
  self:SetBg(self.viewData)
end

function Personalzone_Mainbg_View:SetBg(id)
  local backgroundTableMgr = Z.TableMgr.GetTable("BackgroundTableMgr")
  local config = backgroundTableMgr.GetRow(id)
  if config then
    self.uiBinder.rimg_bg:SetImage(config.Res)
  else
    self.uiBinder.rimg_bg:SetImage(OriginalPath)
  end
end

return Personalzone_Mainbg_View
