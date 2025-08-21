local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_unlock_conditionView = class("Tips_unlock_conditionView", super)

function Tips_unlock_conditionView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_unlock_condition", "tips/tips_unlock_condition", true)
  self.anim_name_ = Z.IsPCUI and "anim_rolelevel_attribute_tpl_open_pc" or "anim_rolelevel_attribute_tpl_open"
  self.isShow_ = false
  self.commonVM_ = Z.VMMgr.GetVM("common")
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
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff_root)
  if self.timerId_ then
    self.timerMgr:StopTimer(self.timerId_)
    self.timerId_ = nil
  end
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
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff_root)
  self.uiBinder.img_icon:SetImage(table.Icon)
  Z.AudioMgr:Play("UI_Event_ItemGet_S")
  self.uiBinder.lab_condition.text = table.Name
  local token = self.cancelSource:CreateToken()
  self.commonVM_.CommonPlayAnim(self.uiBinder.anim, self.anim_name_, token, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function Tips_unlock_conditionView:Close()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Tips_unlock_conditionView
