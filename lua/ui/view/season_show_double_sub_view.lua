local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_show_double_subView = class("Season_show_double_subView", super)

function Season_show_double_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "season_show_double_sub", "season/season_show_double_sub", UI.ECacheLv.None)
end

function Season_show_double_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
end

function Season_show_double_subView:OnDeActive()
end

function Season_show_double_subView:OnRefresh()
  if not self.viewData or #self.viewData.ResourceRoute == 0 then
    return
  end
  self.uiBinder.lab_title.text = self.viewData.SeasonTitle
  self.uiBinder.lab_content.text = self.viewData.Content
  for k, v in ipairs(self.viewData.ResourceRoute) do
    self.uiBinder["rimg_bg_" .. k]:SetImage(v)
  end
end

return Season_show_double_subView
