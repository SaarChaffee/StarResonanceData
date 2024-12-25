local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_unlock_conditionView = class("Tips_unlock_conditionView", super)

function Tips_unlock_conditionView:ctor()
  self.uiBinder = nil
  self.anim_name_ = Z.IsPCUI and "anim_rolelevel_attribute_tpl_open_2_pc" or "anim_rolelevel_attribute_tpl_open_2"
  if Z.IsPCUI then
    Z.UIConfig.tips_unlock_condition.PrefabPath = "tips/tips_unlock_condition_pc"
  else
    Z.UIConfig.tips_unlock_condition.PrefabPath = "tips/tips_unlock_condition"
  end
  super.ctor(self, "tips_unlock_condition")
  self.isShow_ = false
end

function Tips_unlock_conditionView:OnActive()
end

function Tips_unlock_conditionView:OnDeActive()
  if self.isShow_ then
    local data = self.viewData
    if not data or not data.functionId then
      return
    end
    Z.EventMgr:Dispatch(Z.ConstValue.ShowMainFeatureUnLockEffect, data.functionId)
  end
  if self.timerId_ then
    self.timerMgr:StopTimer(self.timerId_)
    self.timerId_ = nil
  end
  self.uiBinder.eff_root:SetEffectGoVisible(false)
end

function Tips_unlock_conditionView:OnRefresh()
  self.isShow_ = false
  local data = self.viewData
  if not data or not data.functionId then
    self:Close()
    return
  end
  local table = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(data.functionId)
  if not table then
    self:Close()
    return
  end
  self.isShow_ = true
  self.uiBinder.img_icon:SetImage(table.Icon)
  Z.AudioMgr:Play("UI_Event_ItemGet_S")
  self.uiBinder.lab_condition.text = table.Name
  self.uiBinder.anim:PlayOnce(self.anim_name_)
  if self.timerId_ then
    self.timerMgr:StopTimer(self.timerId_)
  end
  self.timerId_ = self.timerMgr:StartTimer(function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end, 1.5)
end

function Tips_unlock_conditionView:Close()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Tips_unlock_conditionView
