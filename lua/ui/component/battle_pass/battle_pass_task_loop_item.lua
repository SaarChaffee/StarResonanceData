local super = require("ui.component.loopscrollrectitem")
local BattlePassQuestLoopItem = class("BattlePassQuestLoopItem", super)
local awardPopupLoopItem = require("ui/component/battle_pass/battle_pass_award_loop_item")
local loopScrollRect_ = require("ui/component/loopscrollrect")

function BattlePassQuestLoopItem:ctor()
  super:ctor()
end

function BattlePassQuestLoopItem:OnInit()
  self:initParam()
  self:initWidgets()
  self:initBtn()
end

function BattlePassQuestLoopItem:initWidgets()
  self.content_node = self.uiBinder.node_info
  self.desc_lab = self.uiBinder.lab_describe
  self.complete_num_label = self.uiBinder.lab_completeness_num
  self.loopscroll_item = self.uiBinder.loopscroll_item
  self.get_btn = self.uiBinder.btn_get
  self.go_btn = self.uiBinder.btn_go
  self.underway_node = self.uiBinder.lab_underway
  self.not_open_node = self.uiBinder.lab_not_open
  self.buy_lock_node = self.uiBinder.node_buy_lock
  self.complete_node = self.uiBinder.img_completed
  self.tag_node = self.uiBinder.img_tag
end

function BattlePassQuestLoopItem:initComp()
  self.uiBinder.Ref:SetVisible(self.get_btn, false)
  self.uiBinder.Ref:SetVisible(self.go_btn, false)
  self.uiBinder.Ref:SetVisible(self.underway_node, false)
  self.uiBinder.Ref:SetVisible(self.not_open_node, false)
  self.uiBinder.Ref:SetVisible(self.buy_lock_node, false)
  self.uiBinder.Ref:SetVisible(self.complete_node, false)
  self.uiBinder.Ref:SetVisible(self.tag_node, false)
  self.content_node.alpha = 1
end

function BattlePassQuestLoopItem:initBtn()
  self:AddAsyncClick(self.get_btn, function()
    self.battlePassVM_.AsyncGetBattlePassQuestRequest(self.data_.configData.TargetId, self.parent.uiView.cancelSource:CreateToken())
  end)
  self:AddClick(self.go_btn, function()
    self.quickjumpVm_.DoJumpByConfigParam(self.data_.configData.QuickJumpType, self.data_.configData.QuickJump)
  end)
  self.loopScroll_ = loopScrollRect_.new(self.loopscroll_item, self, awardPopupLoopItem)
end

function BattlePassQuestLoopItem:initParam()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.seasonQuestVM_ = Z.VMMgr.GetVM("season_quest_sub")
  self.itemClassTab_ = {}
  self.composeView_ = self.parent.uiView
  self.quickjumpVm_ = Z.VMMgr.GetVM("quick_jump")
end

function BattlePassQuestLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self:initComp()
  self:setItemInfo()
  self:initAward()
end

function BattlePassQuestLoopItem:setItemInfo()
  local bpInfo = self.battlePassVM_.GetCurrentBattlePassContainer()
  if not bpInfo then
    return
  end
  local seasonBPTaskTargetTableData = Z.TableMgr.GetTable("SeasonBPTaskTargetTableMgr").GetRow(self.data_.configData.Target)
  if not seasonBPTaskTargetTableData then
    logGreen("SeasonBPTaskTargetTable is not find! id = " .. self.data_.configData.Target)
    return
  end
  self.desc_lab.text = Z.Placeholder.Placeholder(seasonBPTaskTargetTableData.Describe, {
    val = seasonBPTaskTargetTableData.Num
  })
  self.complete_num_label.text = string.format("%s/%s", self.data_.targetNum, seasonBPTaskTargetTableData.Num)
  self.uiBinder.Ref:SetVisible(self.tag_node, self.data_.configData.PassAward == 1)
  if self.data_.configData.PassAward == 1 and not bpInfo.isUnlock then
    self.uiBinder.Ref:SetVisible(self.buy_lock_node, true)
    return
  end
  if self.data_.award == E.DrawState.AlreadyDraw then
    self.uiBinder.Ref:SetVisible(self.complete_node, true)
    self.content_node.alpha = 0.6
  elseif self.data_.award == E.DrawState.CanDraw and self.data_.configData.ShowWeek <= self.battlePassVM_.GetSeasonCurrentWeek() then
    self.uiBinder.Ref:SetVisible(self.get_btn, true)
  elseif self.data_.configData.ShowWeek > self.battlePassVM_.GetSeasonCurrentWeek() then
    self.uiBinder.Ref:SetVisible(self.not_open_node, true)
  else
    self.uiBinder.Ref:SetVisible(self.underway_node, self.data_.configData.QuickJumpType <= 0)
    self.uiBinder.Ref:SetVisible(self.go_btn, self.data_.configData.QuickJumpType > 0)
  end
end

function BattlePassQuestLoopItem:initAward()
  if not self.data_.configData.AwardId then
    return
  end
  local awardTable = {
    self.data_.configData.AwardId
  }
  self.loopScroll_:SetData(awardTable)
end

function BattlePassQuestLoopItem:OnUnInit()
  self.loopScroll_:ClearCells()
end

return BattlePassQuestLoopItem
