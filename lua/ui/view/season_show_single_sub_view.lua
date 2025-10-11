local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_show_single_subView = class("Season_show_single_subView", super)

function Season_show_single_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "season_show_single_sub", "season/season_show_single_sub", UI.ECacheLv.None)
end

function Season_show_single_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
end

function Season_show_single_subView:OnDeActive()
end

function Season_show_single_subView:OnRefresh()
  if not self.viewData then
    return
  end
  self.uiBinder.lab_title.text = self.viewData.SeasonTitle
  self.uiBinder.rimg_bg:SetImage(self.viewData.ResourceRoute[1])
  self.uiBinder.lab_content.text = self.viewData.Content
end

return Season_show_single_subView
