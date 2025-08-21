local UI = Z.UI
local super = require("ui.ui_view_base")
local Raid_monster_windowView = class("Raid_monster_windowView", super)
local competencyAssessView = require("ui.view.competency_assessment_sub_view")
local loopListView = require("ui.component.loop_list_view")
local previewRewardItem = require("ui.component.common_recharge.common_preview_loop_item")

function Raid_monster_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "raid_monster_window")
end

function Raid_monster_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.raidVm_ = Z.VMMgr.GetVM("raid")
  self.dungeonVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.units_ = {}
  self.unitTokens_ = {}
  self.itemClassTab_ = {}
  self.rewardLoopList_ = loopListView.new(self, self.uiBinder.loop_item, previewRewardItem, "com_item_square_1_8")
  self.rewardLoopList_:Init({})
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.raidVm_:CloseRaidMonsterView()
  end)
  self.capabilityAssessVM_ = Z.VMMgr.GetVM("capability_assessment")
  self.competencyAssessView_ = competencyAssessView.new()
  self.dungeonId_ = self.viewData.dungeonId
  self.dungeonRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  self.raidDungeonRow_ = Z.TableMgr.GetTable("RaidDungeonTableMgr").GetRow(self.dungeonId_)
  self:AddClick(self.uiBinder.btn_strength_assessment, function()
    local isOn = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.CompetencyAssess)
    if not isOn then
      return
    end
    if self.dungeonId_ then
      self.competencyAssessView_:Active({
        dungeonId = self.dungeonId_,
        assessId = self.raidBoosRow_.AssessId,
        recommendFightValue = self.raidBoosRow_.RecommendFightValue
      }, self.uiBinder.Trans)
    end
  end)
  self:initBossBtn()
  self:AddAsyncClick(self.uiBinder.btn_guide, function()
    Z.VMMgr.GetVM("helpsys").OpenMulHelpSysView(self.raidBoosRow_.HelpID)
  end)
end

function Raid_monster_windowView:gotoHelpSysView()
end

function Raid_monster_windowView:initBossBtn()
  local btnGroup = {
    self.uiBinder.node_monster_01,
    self.uiBinder.node_monster_02,
    self.uiBinder.node_monster_03
  }
  local select = 1
  for index, value in ipairs(btnGroup) do
    local bossId = self.raidDungeonRow_.BossId[index]
    if bossId == self.viewData.bossId then
      value.Ref:SetVisible(value.img_select, true)
      self.selectTog_ = value
    else
      value.Ref:SetVisible(value.img_select, false)
    end
    local raidBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
    local isOpen = false
    if raidBossRow then
      value.img_icon:SetImage(raidBossRow.BossIcon)
      isOpen = Z.TimeTools.CheckIsInTimeByTimeId(raidBossRow.OpenTimerId)
      value.Ref:SetVisible(value.node_unlock, not isOpen)
    end
    self:AddAsyncClick(value.btn_select, function()
      if not isOpen then
        local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
        local startTime = Z.TimeTools.GetStartEndTimeByTimerId(raidBossRow.OpenTimerId)
        local dTime = startTime - nowTime
        local leftTimeDesc = Z.TimeFormatTools.FormatToDHMS(dTime)
        Z.TipsVM.ShowTips(124024, {val = leftTimeDesc})
        return
      end
      if self.selectTog_ then
        self.selectTog_.Ref:SetVisible(self.selectTog_.img_select, false)
      end
      self.selectTog_ = value
      self.selectTog_.Ref:SetVisible(self.selectTog_.img_select, true)
      self:onBossTogSelect(bossId)
    end)
  end
  self:onBossTogSelect(self.viewData.bossId)
end

function Raid_monster_windowView:onBossTogSelect(bossId)
  self.raidBoosRow_ = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
  local _, suggest = self.capabilityAssessVM_.GetAllAttrValue(self.raidBoosRow_.AssessId)
  self.uiBinder.lab_tips.text = Lang("ReviewSuggestions") .. suggest
  self.uiBinder.lab_assessment.text = Lang("GSSuggest", {
    val = self.raidBoosRow_.RecommendFightValue
  })
  local monsterRow = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(bossId)
  if monsterRow then
    self.uiBinder.lab_name.text = monsterRow.Name
    self.uiBinder.lab_guide_name.text = monsterRow.Name
  end
  self.uiBinder.lab_content.text = self.raidBoosRow_.Content
  self.uiBinder.rimg_bg:SetImage(self.raidBoosRow_.Background)
  self:refreshAward()
end

function Raid_monster_windowView:refreshAward()
  local firstPassAwardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(self.raidBoosRow_.FirstPassAward)
  local passAwardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(self.raidBoosRow_.PassAward)
  self.rewardLoopList_:RefreshListView(passAwardList)
end

function Raid_monster_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.rewardLoopList_ then
    self.rewardLoopList_:UnInit()
    self.rewardLoopList_ = nil
  end
end

function Raid_monster_windowView:OnRefresh()
end

return Raid_monster_windowView
