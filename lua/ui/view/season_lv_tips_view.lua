local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_lv_tipsView = class("Season_lv_tipsView", super)

function Season_lv_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "season_lv_tips", "season_title/season_lv_tips", UI.ECacheLv.None)
end

function Season_lv_tipsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeTipsView()
    end
  end, nil, nil)
  local curBpLevel_ = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.level
  self.uiBinder.lab_lv.text = Lang("SeasonCurrentPassLevel") .. curBpLevel_
  self:AddClick(self.uiBinder.btn_goview, function()
    self:jumpToBp()
  end)
end

function Season_lv_tipsView:OnDeActive()
  if not self.IsActive then
    return
  end
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.btn_goview:RemoveAllListeners()
end

function Season_lv_tipsView:OnRefresh()
end

function Season_lv_tipsView:jumpToBp()
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  local jumpParam_ = {}
  jumpParam_[1] = E.FunctionID.SeasonBattlePass
  jumpParam_[2] = nil
  quickJumpVm.DoJumpByConfigParam(E.QuickJumpType.Function, jumpParam_)
  self:closeTipsView()
end

function Season_lv_tipsView:closeTipsView()
  if not self.IsActive then
    return
  end
  self:DeActive()
end

return Season_lv_tipsView
