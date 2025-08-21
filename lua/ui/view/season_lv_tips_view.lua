local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_lv_tipsView = class("Season_lv_tipsView", super)

function Season_lv_tipsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "season_lv_tips", "season_title/season_lv_tips", UI.ECacheLv.None)
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
end

function Season_lv_tipsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeTipsView()
    end
  end, nil, nil)
  local curBpCardData = self.battlePassVM_.GetCurrentBattlePassContainer()
  if not curBpCardData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_lv, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_lv, true)
    self.uiBinder.lab_lv.text = Lang("SeasonCurrentPassLevel") .. curBpCardData.level
  end
  self:AddClick(self.uiBinder.btn_goview, function()
    self:jumpToBp()
  end)
  self.uiBinder.adapt_pos:UpdatePosition(self.viewData.rect, true, false, false)
  if self.viewData.posOffset then
    local posSource = self.uiBinder.rect_bg.anchoredPosition
    local posResult = posSource + self.viewData.posOffset
    local size = self.uiBinder.rect_bg.sizeDelta
    local pivot = self.uiBinder.rect_bg.pivot
    local width = size.x * pivot.x
    local height = size.y * pivot.y
    if posResult.x < -(Z.UIRoot.CurCanvasSafeSize.x - width) * 0.5 then
      posResult.x = posSource.x - self.viewData.posOffset.x
    end
    if posResult.y < -(Z.UIRoot.CurCanvasSafeSize.y - height) * 0.5 then
      posResult.y = posSource.y - self.viewData.posOffset.y
    end
    self.uiBinder.rect_bg:SetAnchorPosition(posResult.x, posResult.y)
  end
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
