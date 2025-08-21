local UI = Z.UI
local super = require("ui.ui_subview_base")
local Expression_window_pcView = class("Expression_window_pcView", super)

function Expression_window_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "expression_window_pc", "expression_pc/expression_window_pc", UI.ECacheLv.None)
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
  self.actionView_ = require("ui/view/expression_action_sub_view").new(self)
  self.fishingView_ = require("ui/view/expression_fishing_sub_view").new(self)
  self.fishing_data_ = Z.DataMgr.Get("fishing_data")
end

function Expression_window_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.togTab_ = {}
  self.currentSelectType_ = nil
  self.currentSubView_ = nil
  self.expressionData_.OpenSourceType = E.ExpressionOpenSourceType.Expression
  self:bindEvents()
  self:setTipsPosNodeVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:initTab()
  end)()
  local containGoEvent = self.uiBinder.presscheck.ContainGoEvent
  self:EventAddAsyncListener(containGoEvent, function(isContainer)
    if isContainer then
      local commonTipsInfo = self.expressionData_:GetCommonTipsInfo()
      self:SetCommonLogic(commonTipsInfo)
    end
    self:setTipsPosNodeVisible(false)
  end, nil, nil)
  self:initUi()
end

function Expression_window_pcView:initUi()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_fish_tog, false)
  self.uiBinder.tog_big:AddListener(function(isOn)
    if isOn then
      self.fishing_data_:SetActionIsMaxSize(true)
    end
  end)
  self.uiBinder.tog_small:AddListener(function(isOn)
    if isOn then
      self.fishing_data_:SetActionIsMaxSize(false)
    end
  end)
  local isMaxSize = self.fishing_data_:GetActionIsMaxSize()
  if isMaxSize then
    self.uiBinder.tog_big.isOn = true
  else
    self.uiBinder.tog_small.isOn = true
  end
end

function Expression_window_pcView:OnDeActive()
  self.currentSelectType_ = nil
  self:removeEvents()
  self.togTab_ = {}
  if self.currentSubView_ then
    self.currentSubView_:DeActive()
    self.currentSubView_ = nil
  end
end

function Expression_window_pcView:OnRefresh()
end

function Expression_window_pcView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Expression.ShowExpressionTipList, self.updatePos, self)
end

function Expression_window_pcView:removeEvents()
  Z.EventMgr:Remove(Z.ConstValue.Expression.ShowExpressionTipList, self.updatePos, self)
end

function Expression_window_pcView:initTab()
  local tabData = Z.Global.PCUIEmoteTabsShow
  if not tabData or #tabData == 0 then
    return
  end
  local path = self.uiBinder.prefab_cache:GetString("expression_tog_tpl")
  for k, v in ipairs(tabData) do
    local togTabTplBinder = self:AsyncLoadUiUnit(path, "expression_tog_tpl_" .. k, self.uiBinder.node_tog, self.cancelSource:CreateToken())
    self:initTabTog(togTabTplBinder, v, k)
    table.insert(self.togTab_, togTabTplBinder)
  end
  local firstOpenIndex = 1
  if self.viewData and self.viewData.firstOpenIndex then
    firstOpenIndex = self.viewData.firstOpenIndex
  end
  local showData = tabData[firstOpenIndex]
  self:initSubView(tonumber(showData[1]))
  self.togTab_[firstOpenIndex].tog_function:SetIsOnWithoutCallBack(true)
end

function Expression_window_pcView:initTabTog(item, data, k)
  if not item or not data then
    return
  end
  Z.GuideMgr:SetSteerIdByComp(item.node_steer, E.DynamicSteerType.expressionGroupIndex, k)
  item.tog_function:SetIsOnWithoutCallBack(false)
  item.tog_function.group = self.uiBinder.toggroup_tab
  item.img_icon_on:SetImage(data[2])
  item.img_icon_off:SetImage(data[2])
  item.tog_function:AddListener(function(isOn)
    if isOn then
      self:initSubView(tonumber(data[1]))
    end
  end)
end

function Expression_window_pcView:initSubView(type)
  if type == self.currentSelectType_ then
    return
  end
  if self.currentSubView_ then
    self.currentSubView_:DeActive()
  end
  if type == E.ExpressionTabType.Fishing then
    self.currentSubView_ = self.fishingView_
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_fish_tog, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_fish_tog, false)
    self.currentSubView_ = self.actionView_
  end
  self.currentSubView_:Active(type, self.uiBinder.node_sub)
end

function Expression_window_pcView:updatePos(trans)
  if not trans then
    return
  end
  self:setTipsPosNodeVisible(true)
  self.uiBinder.presscheck_adaptPos:UpdatePosition(trans, true, true)
end

function Expression_window_pcView:SetCommonLogic(commonTipsInfo)
  if not commonTipsInfo then
    return
  end
  if self.expressionVM_.CheckCommonDataLimit(commonTipsInfo.type, commonTipsInfo.id) and commonTipsInfo.isAdd then
    Z.TipsVM.ShowTipsLang(1000030)
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.expressionVM_.SetOftenUseShowPieceList(commonTipsInfo.type, commonTipsInfo.id, commonTipsInfo.isAdd)
  end)()
end

function Expression_window_pcView:setTipsPosNodeVisible(isShow)
  if isShow then
    self:updateCommonTips()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, isShow)
end

function Expression_window_pcView:updateCommonTips()
  local btnText = Lang("Emote_add_favorites")
  local btnImgPath = self.uiBinder.prefab_cache:GetString("addIcon")
  local commonTipsInfo = self.expressionData_:GetCommonTipsInfo()
  if not commonTipsInfo then
    return
  end
  if commonTipsInfo.commonTipsType == E.ExpressionCommonTipsState.Add then
    btnText = Lang("Emote_add_favorites")
    btnImgPath = self.uiBinder.prefab_cache:GetString("addIcon")
  else
    btnText = Lang("Emote_remove_favorites")
    btnImgPath = self.uiBinder.prefab_cache:GetString("removeIcon")
  end
  self.uiBinder.lab_info.text = btnText
  self.uiBinder.img_icon:SetImage(btnImgPath)
end

return Expression_window_pcView
