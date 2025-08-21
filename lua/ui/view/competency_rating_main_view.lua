local UI = Z.UI
local super = require("ui.ui_view_base")
local Competency_rating_mainView = class("Competency_rating_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local rfLoopItem = require("ui.component.recommend_fightvalue.recommend_fightvalue_loop_item")
local RecommendFightItemState = {
  Lock = 1,
  Normal = 2,
  Expand = 3
}

function Competency_rating_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "competency_rating_main")
  self.recommendFightValueVM_ = Z.VMMgr.GetVM("recommend_fightvalue")
  self.recommendFightValueData_ = Z.DataMgr.Get("recommend_fightvalue_data")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.quickJumpVm_ = Z.VMMgr.GetVM("quick_jump")
end

function Competency_rating_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  local commonVM = Z.VMMgr.GetVM("common")
  commonVM.SetLabText(self.uiBinder.lab_title, {
    E.FunctionID.RoleInfo,
    E.FunctionID.RecommendFightValue
  })
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(400201)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.recommendFightValueVM_.CloseMainView()
  end)
  self.rfTypes = self.recommendFightValueData_:GetAssessModuleRows()
  self.awardLoopViewDict_ = {}
  self.rfExpandRecord_ = {}
  for _, cfg in ipairs(self.rfTypes) do
    self.rfExpandRecord_[cfg.Id] = false
  end
  self.modelPos_ = Z.UnrealSceneMgr:GetTransPos("pos")
  self.modelQuaternion_ = Quaternion.Euler(Vector3.New(0, 165, 0))
end

function Competency_rating_mainView:OnDeActive()
  for k, v in pairs(self.awardLoopViewDict_) do
    v:UnInit()
    v = nil
  end
  self.awardLoopViewDict_ = {}
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function Competency_rating_mainView:OnRefresh()
  for index, cfg in ipairs(self.rfTypes) do
    local itemBinder = self.uiBinder["competency_rating_item_tpl_" .. index]
    self:refreshCompetencyItem(itemBinder, cfg)
  end
  self:createPlayerModel()
  self:refreshTotalPoint()
end

function Competency_rating_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Competency_rating_mainView:refreshTotalPoint()
  local totalPoint = self.recommendFightValueVM_.GetTotalPoint()
  self.uiBinder.lab_total_point.text = totalPoint
end

function Competency_rating_mainView:refreshCompetencyItem(itemBinder, cfg)
  local unLock = self.gotoFuncVM_.CheckFuncCanUse(cfg.Id, true)
  local state = unLock and RecommendFightItemState.Normal or RecommendFightItemState.Lock
  if self.rfExpandRecord_[cfg.Id] then
    state = RecommendFightItemState.Expand
  end
  itemBinder.node_sys.Ref.UIComp:SetVisible(state ~= RecommendFightItemState.Lock)
  itemBinder.node_item.Ref.UIComp:SetVisible(state == RecommendFightItemState.Expand)
  itemBinder.node_lock.Ref.UIComp:SetVisible(state == RecommendFightItemState.Lock)
  itemBinder.Ref:SetVisible(itemBinder.node_unlock, state ~= RecommendFightItemState.Lock)
  if state ~= RecommendFightItemState.Lock then
    if cfg.Id == E.RecommendFightValueType.Level then
      itemBinder.node_score.Ref.UIComp:SetVisible(true)
      itemBinder.node_sys.Ref.UIComp:SetVisible(false)
      self:refreshNodeLevelScore(itemBinder.node_score, cfg)
    else
      self:refreshNodeSys(itemBinder.node_sys, cfg)
      self:refreshNodeItem(itemBinder.node_item, cfg)
    end
  else
    self:refreshNodeLock(itemBinder.node_lock, cfg)
  end
  local funcCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(cfg.Id)
  if funcCfg and state ~= RecommendFightItemState.Lock then
    itemBinder.img_icon_on:SetImage(funcCfg.Icon)
  end
  itemBinder.Ref:SetVisible(itemBinder.btn_drop_down, state ~= RecommendFightItemState.Lock)
  if state ~= RecommendFightItemState.Lock then
    local rod = state == RecommendFightItemState.Expand and 0 or 180
    itemBinder.img_drop_down.transform:SetLocalRot(0, 0, rod)
    itemBinder.btn_drop_down:RemoveAllListeners()
    self:AddClick(itemBinder.btn_drop_down, function()
      self.rfExpandRecord_[cfg.Id] = not self.rfExpandRecord_[cfg.Id]
      self:refreshCompetencyItem(itemBinder, cfg)
    end)
  end
  local reach = self.recommendFightValueVM_.CheckExceedingRecommendedValue(cfg.Id)
  itemBinder.Ref:SetVisible(itemBinder.img_recommend, not reach)
end

function Competency_rating_mainView:refreshNodeLevelScore(binder, cfg)
  local curPoint = self.recommendFightValueVM_.GetPointByType(cfg.Id)
  binder.lab_all_scene.text = Lang("TotalScore") .. curPoint
  local rolelevelData = Z.DataMgr.Get("role_level_data")
  binder.lab_title.text = cfg.TextDes .. rolelevelData:GetRoleLevel()
  binder.btn_go:RemoveAllListeners()
  self:AddClick(binder.btn_go, function()
    local jumpParam = {}
    jumpParam[1] = self.recommendFightValueData_:GetJumpIdByType(cfg.Id)
    jumpParam[2] = nil
    self.quickJumpVm_.DoJumpByConfigParam(E.QuickJumpType.Function, jumpParam)
  end)
end

function Competency_rating_mainView:refreshNodeSys(binder, cfg)
  local curPoint = self.recommendFightValueVM_.GetPointByType(cfg.Id)
  binder.lab_score.text = Lang("TotalScore") .. curPoint
  binder.lab_sys.text = cfg.Title
  binder.lab_info.text = cfg.TextDes
end

function Competency_rating_mainView:refreshNodeItem(binder, cfg)
  local awardList = {}
  for _, v in ipairs(cfg.NeedItem) do
    local itemData = {ItemId = v}
    table.insert(awardList, itemData)
  end
  if self.awardLoopViewDict_[cfg.Id] == nil then
    self.awardLoopViewDict_[cfg.Id] = loopListView.new(self, binder.scrollview_item, rfLoopItem, "com_item_square_8")
    self.awardLoopViewDict_[cfg.Id]:Init(awardList)
  else
    self.awardLoopViewDict_[cfg.Id]:RefreshListView(awardList)
  end
  binder.btn_item_go:RemoveAllListeners()
  self:AddClick(binder.btn_item_go, function()
    local jumpParam = {}
    jumpParam[1] = self.recommendFightValueData_:GetJumpIdByType(cfg.Id)
    jumpParam[2] = nil
    self.quickJumpVm_.DoJumpByConfigParam(E.QuickJumpType.Function, jumpParam)
  end)
end

function Competency_rating_mainView:refreshNodeLock(binder, cfg)
  binder.lab_sys.text = cfg.Title
  binder.lab_info.text = cfg.TextDes
  local funcCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(cfg.Id)
  if funcCfg then
    binder.img_icon_off:SetImage(funcCfg.Icon)
  end
  self:AddClick(binder.btn_lock, function()
    self.gotoFuncVM_.CheckFuncCanUse(cfg.Id)
  end)
end

function Competency_rating_mainView:createPlayerModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    model:SetAttrGoPosition(self.modelPos_)
    model:SetAttrGoRotation(self.modelQuaternion_)
    model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
  end)
end

return Competency_rating_mainView
