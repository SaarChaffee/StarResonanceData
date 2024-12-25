local UI = Z.UI
local super = require("ui.ui_subview_base")
local Play_award_subView = class("Play_award_subView", super)
local tipsText = {
  [1] = Lang("HeroDungeonAwardLimit"),
  [2] = Lang("HeroKeyAward"),
  [3] = Lang("RewardRoll")
}

function Play_award_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "play_award_sub", "recommendedplay/play_award_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "play_award_sub", "recommendedplay/play_award_sub", UI.ECacheLv.None)
  end
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Play_award_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(self.viewData)
  if config == nil then
    return
  end
  self.uiBinder.lab_name.text = config.OtherDes
  self.uiBinder.lab_title.text = config.Name
  self.uiBinder.lab_info.text = config.ActDes
end

function Play_award_subView:OnDeActive()
end

function Play_award_subView:OnRefresh()
end

return Play_award_subView
