local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_evaluate_tplView = class("Main_evaluate_tplView", super)
local EVALUATE_DEFINE = require("ui.model.main_evaluate_define")

function Main_evaluate_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_evaluate_tpl", "main/evaluate/main_evaluate_tpl", UI.ECacheLv.None, true)
  self.parent_ = parent
end

function Main_evaluate_tplView:OnActive()
  Z.EventMgr:Add(Z.ConstValue.MainUI.ShakeEvaluateUI, self.shakeEvaluateUI, self)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_single)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_ss)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.eff_sss)
end

function Main_evaluate_tplView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.MainUI.ShakeEvaluateUI, self.shakeEvaluateUI, self)
  self.lastLevel_ = nil
  self.curLevel_ = nil
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_single)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_ss)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.eff_sss)
end

function Main_evaluate_tplView:OnRefresh()
  self.lastLevel_ = self.curLevel_
  self.curLevel_ = self.viewData
  self:refreshEvaluateUI()
end

function Main_evaluate_tplView:refreshEvaluateUI()
  if self.lastLevel_ ~= nil then
    self:playSwitchAnim()
  else
    self:playShowAnim()
  end
end

function Main_evaluate_tplView:setEvaluateColor()
  local color = EVALUATE_DEFINE.COLOR_DEFINE[self.curLevel_]
  if color == nil then
    return
  end
  self.uiBinder.rimg_bottom_1.color = color
  self.uiBinder.rimg_bottom_2.color = color
  self.uiBinder.rimg_bottom_3.color = color
  self.uiBinder.rimg_bottom_4.color = color
end

function Main_evaluate_tplView:setEvaluateImg()
  local imgPath = EVALUATE_DEFINE.IMAGE_DEFINE[self.curLevel_]
  if imgPath == nil then
    return
  end
  if self.curLevel_ <= 5 then
    self.uiBinder.rimg_icon_single:SetImage(imgPath)
  elseif self.curLevel_ == 6 then
    self.uiBinder.rimg_icon_ss_1:SetImage(imgPath)
    self.uiBinder.rimg_icon_ss_2:SetImage(imgPath)
  elseif self.curLevel_ == 7 then
    self.uiBinder.rimg_icon_sss_1:SetImage(imgPath)
    self.uiBinder.rimg_icon_sss_2:SetImage(imgPath)
    self.uiBinder.rimg_icon_sss_3:SetImage(imgPath)
  end
  self:SetUIVisible(self.uiBinder.node_single, self.curLevel_ <= 5)
  self:SetUIVisible(self.uiBinder.node_ss, self.curLevel_ == 6)
  self:SetUIVisible(self.uiBinder.node_sss, self.curLevel_ == 7)
end

function Main_evaluate_tplView:shakeEvaluateUI()
  self:playShakeAnim()
end

function Main_evaluate_tplView:getEffectComp(level)
  if self.curLevel_ <= 5 then
    return self.uiBinder.eff_single
  elseif self.curLevel_ == 6 then
    return self.uiBinder.eff_ss
  elseif self.curLevel_ == 7 then
    return self.uiBinder.eff_sss
  end
end

function Main_evaluate_tplView:playShowAnim()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setEvaluateColor()
    self:setEvaluateImg()
    local effComp = self:getEffectComp(self.curLevel_)
    local effPath = Z.IsPCUI and EVALUATE_DEFINE.PC_START_EFFECT_PATH[self.curLevel_] or EVALUATE_DEFINE.START_EFFECT_PATH[self.curLevel_]
    local animName = Z.IsPCUI and EVALUATE_DEFINE.PC_START_ANIM_NAME[self.curLevel_] or EVALUATE_DEFINE.START_ANIM_NAME[self.curLevel_]
    effComp:CreatEFFGO(effPath, Vector3.zero, true)
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, animName, self.cancelSource:CreateToken())
  end)()
end

function Main_evaluate_tplView:playSwitchAnim()
  Z.CoroUtil.create_coro_xpcall(function()
    local effComp1 = self:getEffectComp(self.lastLevel_)
    local effPath1 = Z.IsPCUI and EVALUATE_DEFINE.PC_END_EFFECT_PATH[self.curLevel_] or EVALUATE_DEFINE.END_EFFECT_PATH[self.curLevel_]
    local animName1 = Z.IsPCUI and EVALUATE_DEFINE.PC_END_ANIM_NAME[self.lastLevel_] or EVALUATE_DEFINE.END_ANIM_NAME[self.lastLevel_]
    effComp1:CreatEFFGO(effPath1, Vector3.zero, true)
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, animName1, self.cancelSource:CreateToken())
    self:setEvaluateColor()
    self:setEvaluateImg()
    local effComp2 = self:getEffectComp(self.curLevel_)
    local effPath2 = Z.IsPCUI and EVALUATE_DEFINE.PC_START_EFFECT_PATH[self.curLevel_] or EVALUATE_DEFINE.START_EFFECT_PATH[self.curLevel_]
    local animName2 = Z.IsPCUI and EVALUATE_DEFINE.PC_START_ANIM_NAME[self.curLevel_] or EVALUATE_DEFINE.START_ANIM_NAME[self.curLevel_]
    effComp2:CreatEFFGO(effPath2, Vector3.zero, true)
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, animName2, self.cancelSource:CreateToken())
  end)()
end

function Main_evaluate_tplView:playShakeAnim()
  Z.CoroUtil.create_coro_xpcall(function()
    local effComp = self:getEffectComp(self.curLevel_)
    local effPath = Z.IsPCUI and EVALUATE_DEFINE.PC_LOOP_EFFECT_PATH[self.curLevel_] or EVALUATE_DEFINE.LOOP_EFFECT_PATH[self.curLevel_]
    local animName = Z.IsPCUI and EVALUATE_DEFINE.PC_LOOP_ANIM_NAME[self.curLevel_] or EVALUATE_DEFINE.LOOP_ANIM_NAME[self.curLevel_]
    effComp:CreatEFFGO(effPath, Vector3.zero, true)
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, animName, self.cancelSource:CreateToken())
  end)()
end

return Main_evaluate_tplView
