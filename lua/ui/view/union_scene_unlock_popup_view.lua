local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_scene_unlock_popupView = class("Union_scene_unlock_popupView", super)

function Union_scene_unlock_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_scene_unlock_popup")
end

function Union_scene_unlock_popupView:OnActive()
  self:initComponent()
  self:onStartAnimShow()
  local endTime = Z.TimeTools.Now() + Z.Global.UnionunlocksceneBuildingTime * 1000
  self:refreshTimeLab(Z.Global.UnionunlocksceneBuildingTime)
  self.countTimer_ = self.timerMgr:StartTimer(function()
    local time = math.floor((endTime - Z.TimeTools.Now()) / 1000)
    if 0 <= time then
      self:refreshTimeLab(time)
    else
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, 1, -1)
end

function Union_scene_unlock_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_item_eff)
  if self.countTimer_ then
    self.timerMgr:StopTimer(self.countTimer_)
    self.countTimer_ = nil
  end
end

function Union_scene_unlock_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.anim:PlayOnce("anim_union_scene_unlock_popup_open")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Union_scene_unlock_popupView:OnRefresh()
end

function Union_scene_unlock_popupView:initComponent()
  self.uiBinder.scenemask_bg:SetSceneMaskByKey(self.SceneMaskKey)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self:AddClick(self.uiBinder.btn_mask, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function Union_scene_unlock_popupView:refreshTimeLab(time)
  self.uiBinder.lab_time.text = Lang("UnionSceneUnlockDesc", {
    val = Z.TimeFormatTools.FormatToDHMS(time, true)
  })
end

return Union_scene_unlock_popupView
