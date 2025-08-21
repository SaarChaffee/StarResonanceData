local UI = Z.UI
local super = require("ui.ui_subview_base")
local Competency_assessment_subView = class("Competency_assessment_subView", super)
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")
local loopListView = require("ui.component.loop_list_view")
local caLoopItem = require("ui.component.competency_assessment.competency_assessment_loop_item")

function Competency_assessment_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "competency_assessment_sub", "competency_rating/competency_assessment_sub", UI.ECacheLv.None)
  self.capabilityAssessVM_ = Z.VMMgr.GetVM("capability_assessment")
  self.recommendFightValueVM_ = Z.VMMgr.GetVM("recommend_fightvalue")
end

function Competency_assessment_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.uiBinder.presscheck:StopCheck()
  self.dungeonId_ = self.viewData.dungeonId
  self.difficulty_ = self.viewData.difficulty
  self.isMasterDungeon_ = self.viewData.isMasterDungeon
  local commonVM = Z.VMMgr.GetVM("common")
  commonVM.SetLabText(self.uiBinder.lab_title, {
    E.FunctionID.RoleInfo,
    E.FunctionID.CompetencyAssess
  })
  local funcCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.CompetencyAssess)
  if funcCfg then
    self.uiBinder.img_icon:SetImage(funcCfg.Icon)
  end
  self.attrLoopView_ = loopListView.new(self, self.uiBinder.loop_item, caLoopItem, "competency_assessment_item_tpl")
  self.attrLoopView_:Init({})
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(400202)
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self:DeActive()
  end)
  self:AddClick(self.uiBinder.btn_rf, function()
    self.recommendFightValueVM_.OpenMainView()
    self:DeActive()
  end)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
  Z.EventMgr:Dispatch(Z.ConstValue.CompetencyAssess.IsHideLeftView, true)
end

function Competency_assessment_subView:OnDeActive()
  self.attrLoopView_:UnInit()
  self.attrLoopView_ = nil
  self.uiBinder.presscheck:StopCheck()
  Z.EventMgr:Dispatch(Z.ConstValue.CompetencyAssess.IsHideLeftView, false)
end

function Competency_assessment_subView:OnRefresh()
  self.uiBinder.presscheck:StartCheck()
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  local assessId = 0
  local recommendFightValue = 0
  if dungeonCfg then
    assessId = dungeonCfg.AssessId
    recommendFightValue = dungeonCfg.RecommendFightValue
  end
  if self.isMasterDungeon_ then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[self.dungeonId_][self.difficulty_]
    local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    assessId = masterChallengeDungeonRow.AssessId
    recommendFightValue = masterChallengeDungeonRow.RecommendFightValue
  end
  if self.viewData.assessId then
    assessId = self.viewData.assessId
  end
  if self.viewData.recommendFightValue then
    recommendFightValue = self.viewData.recommendFightValue
  end
  if dungeonCfg then
    local dataList, suggest = self.capabilityAssessVM_.GetAllAttrValue(assessId)
    self.attrLoopView_:RefreshListView(dataList)
    self.uiBinder.lab_suggest.text = Lang("ReviewSuggestions") .. suggest
    local curRF = self.recommendFightValueVM_.GetTotalPoint()
    local suggestRF = recommendFightValue
    local colorKey = curRF >= suggestRF and E.TextStyleTag.TipsGreen or E.TextStyleTag.TipsRed
    local curRFStr = Z.RichTextHelper.ApplyStyleTag(curRF, colorKey)
    self.uiBinder.lab_current_score.text = Lang("CurAndSuggestRFPoint") .. curRFStr .. "/" .. suggestRF
    self.uiBinder.lab_name.text = dungeonCfg.Name
  end
end

return Competency_assessment_subView
