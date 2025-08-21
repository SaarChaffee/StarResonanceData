local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_functionView = class("Equip_functionView", super)
local decomposeView_ = require("ui.view.equip_decompose_view")
local recastView = require("ui.view.equip_recast_sub_view")
local refineView = require("ui.view.equip_refining_sub_view")
local enchantView = require("ui.view.equip_enchant_sub_view")
local switchVm_ = Z.VMMgr.GetVM("switch")

function Equip_functionView:ctor()
  self.uiBinder = nil
  local assetPath
  if Z.IsPCUI then
    assetPath = "equip/equip_function_main_pc"
  end
  super.ctor(self, "equip_function", assetPath)
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Equip_functionView:initWeights()
  self.clostBtn_ = self.uiBinder.btn_close
  self.recastBinder_ = self.uiBinder.binder_func_recast_item
  self.refineBinder_ = self.uiBinder.binder_func_refine_item
  self.decomposeBinder_ = self.uiBinder.binder_func_decompose_item
  self.enchantBinder_ = self.uiBinder.binder_func_enchant_item
  self.leftLine_ = self.uiBinder.img_line_left
  self.toggleGroup_ = self.uiBinder.layout_tab
  self.subviewParent_ = self.uiBinder.node_subview_parent
  self.emptyLab_ = self.uiBinder.lab_empty
  self.getBinder_ = self.uiBinder.binder_get
  self.getBtn_ = self.getBinder_.btn
  self.titleLab_ = self.uiBinder.lab_title
  self.titleNode_ = self.uiBinder.layout_left_title
end

function Equip_functionView:OnActive()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initWeights()
  self:isHideLeftView(false)
  self:AddClick(self.clostBtn_, function()
    self.equipVm_:CloeseEquipFuncView()
  end)
  local decomposeState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipDecompose)
  self.decomposeBinder_.Ref.UIComp:SetVisible(decomposeState == nil and true or decomposeState)
  local recastState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipRecast)
  self.recastBinder_.Ref.UIComp:SetVisible(recastState == nil and true or recastState)
  local refineState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipRefine)
  self.refineBinder_.Ref.UIComp:SetVisible(refineState == nil and true or refineState)
  local enchantState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipEnchant)
  self.enchantBinder_.Ref.UIComp:SetVisible(enchantState == nil and true or enchantState)
  local breakState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipBreak)
  local makeState = switchVm_.CheckFuncSwitch(E.EquipFuncId.EquipMake)
  self.funcTable_ = {}
  Z.RedPointMgr.LoadRedDotItem(E.RedType.EquipRefineRed, self, self.refineBinder_.Trans)
  self.funcTable_.decompose = {
    container = self.decomposeBinder_,
    funcId = E.EquipFuncId.EquipDecompose,
    cacheData = nil,
    subView = decomposeView_.new(self)
  }
  self.funcTable_.recast = {
    container = self.recastBinder_,
    funcId = E.EquipFuncId.EquipRecast,
    cacheData = nil,
    subView = recastView.new(self)
  }
  self.funcTable_.refine = {
    container = self.refineBinder_,
    funcId = E.EquipFuncId.EquipRefine,
    cacheData = nil,
    subView = refineView.new(self)
  }
  self.funcTable_.enchant = {
    container = self.enchantBinder_,
    funcId = E.EquipFuncId.EquipEnchant,
    cacheData = nil,
    subView = enchantView.new(self)
  }
  for key, value in pairs(self.funcTable_) do
    value.container.tog_tab_select.group = self.toggleGroup_
    local viewType = key
    self:AddClick(value.container.tog_tab_select, function(ison)
      if ison then
        self:openSubView(viewType)
      end
    end)
    value.container.Ref:SetVisible(value.container.img_off, true)
    value.container.Ref:SetVisible(value.container.img_on, false)
  end
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(30013)
  end)
  self:AddClick(self.getBtn_, function()
    self.equipVm_.OpenEquipSearchTips(self.getBtn_.transform)
  end)
  self:EmptyState(true, "")
  self:BindEvents()
end

function Equip_functionView:GetCacheData()
  if self.curSubViewType_ then
    local cacheData = {}
    local viewCache = self.funcTable_[self.curSubViewType_]
    cacheData.subViewType = self.curSubViewType_
    cacheData.subViewData = viewCache.subView:GetCacheData()
    return cacheData
  end
  return nil
end

function Equip_functionView:OnDestory()
end

function Equip_functionView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubViewType_ then
    local viewCache = self.funcTable_[self.curSubViewType_]
    viewCache.container.Ref:SetVisible(viewCache.container.img_off, true)
    viewCache.container.Ref:SetVisible(viewCache.container.img_on, false)
  end
  self.equipVm_.CloseApproach()
  for key, value in pairs(self.funcTable_) do
    value.subView:DeActive()
    value.container.tog_tab_select:RemoveAllListeners()
  end
  self.funcTable_ = nil
  self.curSubViewType_ = nil
end

function Equip_functionView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Equip.RefreshEmptyState, self.EmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.IsHideLeftView, self.isHideLeftView, self)
end

function Equip_functionView:selected()
  for subViewType, value in pairs(self.funcTable_) do
    if switchVm_.CheckFuncSwitch(value.funcId) then
      value.container.tog_tab_select.isOn = true
      self:openSubView(subViewType)
      return
    end
  end
end

function Equip_functionView:OnRefresh()
  local subViewType
  if self.viewData and self.viewData.subViewType then
    subViewType = self.viewData.subViewType
    self.funcTable_[subViewType].container.tog_tab_select.isOn = true
    self:openSubView(subViewType)
  else
    self:selected()
  end
end

function Equip_functionView:isHideLeftView(isShow)
  self.uiBinder.Ref:SetVisible(self.titleNode_, not isShow)
  self.uiBinder.Ref:SetVisible(self.toggleGroup_, not isShow)
  self.uiBinder.Ref:SetVisible(self.leftLine_, not isShow)
end

function Equip_functionView:EmptyState(state, emptyStr)
  self.uiBinder.Ref:SetVisible(self.emptyLab_, not state)
  self.emptyLab_.text = emptyStr
  self.getBinder_.Ref.UIComp:SetVisible(not state)
end

function Equip_functionView:openSubView(viewType)
  if not viewType then
    logError("Equip_functionView open subView failed ,viewType is nil")
    return
  end
  if viewType == self.curSubViewType_ then
    return
  end
  if self.curSubViewType_ then
    local viewCache = self.funcTable_[self.curSubViewType_]
    viewCache.container.Ref:SetVisible(viewCache.container.img_off, true)
    viewCache.container.Ref:SetVisible(viewCache.container.img_on, false)
    viewCache.cacheData = viewCache.subView:GetCacheData()
    viewCache.subView:DeActive()
  end
  self.curSubViewType_ = viewType
  local viewCache = self.funcTable_[self.curSubViewType_]
  viewCache.container.Ref:SetVisible(viewCache.container.img_off, false)
  viewCache.container.Ref:SetVisible(viewCache.container.img_on, true)
  self.commonVM_.CommonPlayTogAnim(viewCache.container.anim_tog, self.cancelSource:CreateToken())
  if viewCache.cacheData ~= nil then
    viewCache.subView:Active(viewCache.cacheData, self.subviewParent_.transform)
  elseif self.viewData and self.viewData.subViewData then
    viewCache.subView:Active(self.viewData.subViewData, self.subviewParent_.transform)
    self.viewData = nil
  else
    viewCache.subView:Active(nil, self.subviewParent_.transform)
  end
  self.titleLab_.text = self.commonVM_.GetTitleByConfig({
    E.EquipFuncId.Equip,
    viewCache.funcId
  })
end

function Equip_functionView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Equip_functionView:CustomClose()
end

return Equip_functionView
