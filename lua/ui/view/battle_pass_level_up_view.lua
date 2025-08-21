local super = require("ui.ui_view_base")
local BattlePassLevelUpTipsView = class("BattlePassLevelUpTipsView", super)

function BattlePassLevelUpTipsView:ctor()
  self.panel = nil
  super.ctor(self, "battle_pass_level_up")
end

function BattlePassLevelUpTipsView:OnActive()
  Z.AudioMgr:Play("UI_Event_Magic_B")
  self:setViewInfo()
end

function BattlePassLevelUpTipsView:OnRefresh()
end

function BattlePassLevelUpTipsView:OnDeActive()
  self.timerMgr:Clear()
end

function BattlePassLevelUpTipsView:onStartAnimEnd()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function BattlePassLevelUpTipsView:onStartAnimShow()
  self:playAnimation("anim_cont_level_up_tpl_open", function()
    self:onStartAnimEnd()
  end)
end

function BattlePassLevelUpTipsView:playAnimation(animName, onComplete)
  self.uiBinder.anim:CoroPlayOnce(animName, self.cancelSource:CreateToken(), function()
    if onComplete then
      onComplete()
    end
  end, function(err)
    if err ~= ZUtil.ZCancelSource.CancelException then
      logError(err)
    end
  end)
end

function BattlePassLevelUpTipsView:setViewInfo()
  if self.viewData then
    self.uiBinder.lab_level.text = self.viewData.level
    self:onStartAnimShow()
  else
    self:onStartAnimEnd()
  end
end

return BattlePassLevelUpTipsView
