local UI = Z.UI
local super = require("ui.ui_subview_base")
local Play_lab_info_subView = class("Play_lab_info_subView", super)

function Play_lab_info_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "play_lab_info_sub", "recommendedplay/play_lab_info_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "play_lab_info_sub", "recommendedplay/play_lab_info_sub", UI.ECacheLv.None)
  end
end

function Play_lab_info_subView:OnActive()
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(self.viewData)
  if config then
    self.uiBinder.lab_title.text = config.Name
    self.uiBinder.lab_info.text = config.OtherDes .. "\n" .. config.ActDes
  end
end

function Play_lab_info_subView:OnDeActive()
end

function Play_lab_info_subView:OnRefresh()
end

return Play_lab_info_subView
