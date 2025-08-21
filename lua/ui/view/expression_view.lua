local super = require("ui.ui_view_base")
local ExpressionView = class("ExpressionView", super)

function ExpressionView:ctor()
  self.uiBinder = nil
  super.ctor(self, "expression")
  self.rightActionSubView_ = require("ui/view/camerasys_right_sub_view").new(self)
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function ExpressionView:OnActive()
  Z.AudioMgr:Play("sys_main_emo_in")
  self:startAnimatedShow()
  Z.LuaBridge.BakeMesh(false)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
  if self.viewData and self.viewData.firstOpenIndex then
    self:openCamerasysRightSub(self.viewData.firstOpenIndex)
  else
    self:openCamerasysRightSub()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  self:bindEvent()
  self:setTipsPosNodeVisible(false)
  local containGoEvent = self.uiBinder.presscheck.ContainGoEvent
  self:EventAddAsyncListener(containGoEvent, function(isContainer)
    if isContainer then
      local commonTipsInfo = self.expressionData_:GetCommonTipsInfo()
      self:SetCommonLogic(commonTipsInfo)
    end
    self:setTipsPosNodeVisible(false)
  end, nil, nil)
  self:registerInputActions()
end

function ExpressionView:OnDeActive()
  Z.LuaBridge.BakeMesh(true)
  Z.EventMgr:RemoveObjAll(self)
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
  self.rightActionSubView_:DeActive()
  self:unRegisterInputActions()
end

function ExpressionView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function ExpressionView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Panda.ZUi.DOTweenAnimType.Close)
end

function ExpressionView:openCamerasysRightSub(firstOpenIndex)
  local rightViewData = {
    OpenSourceType = E.ExpressionOpenSourceType.Expression,
    ShowWheelSetting = true,
    firstOpenIndex = firstOpenIndex
  }
  self.rightActionSubView_:Active(rightViewData, self.uiBinder.expression_right_bg)
end

function ExpressionView:setTipsPosNodeVisible(isShow)
  if isShow then
    self:updateCommonTips()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips_pos, isShow)
  self:onShowAnimatedShow(isShow)
end

function ExpressionView:updateCommonTips()
  local btnText = Lang("Emote_add_favorites")
  local btnImgPath = self.uiBinder.prefabCache:GetString("addIcon")
  local commonTipsInfo = self.expressionData_:GetCommonTipsInfo()
  if not commonTipsInfo then
    return
  end
  if commonTipsInfo.commonTipsType == E.ExpressionCommonTipsState.Add then
    btnText = Lang("Emote_add_favorites")
    btnImgPath = self.uiBinder.prefabCache:GetString("addIcon")
  else
    btnText = Lang("Emote_remove_favorites")
    btnImgPath = self.uiBinder.prefabCache:GetString("removeIcon")
  end
  self.uiBinder.lab_info.text = btnText
  self.uiBinder.img_icon:SetImage(btnImgPath)
end

function ExpressionView:updatePos(trans)
  if not trans then
    return
  end
  self:setTipsPosNodeVisible(true)
  self.uiBinder.presscheck_adaptPos:UpdatePosition(trans, true, true)
end

function ExpressionView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Expression.ShowExpressionTipList, self.updatePos, self)
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function ExpressionView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self.expressionVm_.CloseExpressionView()
  end
end

function ExpressionView:SetCommonLogic(commonTipsInfo)
  if not commonTipsInfo then
    return
  end
  if self.expressionVm_.CheckCommonDataLimit(commonTipsInfo.type, commonTipsInfo.id) and commonTipsInfo.isAdd then
    Z.TipsVM.ShowTipsLang(1000030)
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.expressionVm_.SetOftenUseShowPieceList(commonTipsInfo.type, commonTipsInfo.id, commonTipsInfo.isAdd)
  end)()
end

function ExpressionView:onShowAnimatedShow(isShow)
  if isShow then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_2)
  end
end

function ExpressionView:registerInputActions()
  Z.FuncInputActionComp:SetActionCallback(106, self.onInputAction_)
end

function ExpressionView:unRegisterInputActions()
  Z.FuncInputActionComp:SetActionCallback(106, nil)
end

return ExpressionView
