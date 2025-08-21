local super = require("ui.component.loop_list_view_item")
local MasterChallengeDnugeonDiffItem = class("HeroDungeonMasterScoreTItem", super)
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")

function MasterChallengeDnugeonDiffItem:OnInit()
  self.heroDungeonVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function MasterChallengeDnugeonDiffItem:OnRefresh(data)
  self.data = data
  self.MasterChallenDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(data)
  self.maxDiff_ = self.heroDungeonVM_.GetMasterDungeonMaxDiff(self.MasterChallenDungeonRow.DungeonId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  local isMaxDiff = self.MasterChallenDungeonRow.Difficulty == #MasterChallenDungeonTableMap.DungeonId[self.MasterChallenDungeonRow.DungeonId]
  self.uiBinder.lab_num.text = self.MasterChallenDungeonRow.Difficulty
  self.uiBinder.lab_num_off.text = self.MasterChallenDungeonRow.Difficulty
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_ununlocked, self.MasterChallenDungeonRow.Difficulty > self.maxDiff_ + 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_num, self.MasterChallenDungeonRow.Difficulty <= self.maxDiff_ + 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unlock, self.MasterChallenDungeonRow.Difficulty <= self.maxDiff_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_right, self.MasterChallenDungeonRow.Difficulty <= self.maxDiff_)
  if isMaxDiff then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, self.MasterChallenDungeonRow.Difficulty <= self.maxDiff_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, self.MasterChallenDungeonRow.Difficulty > self.maxDiff_)
  end
end

function MasterChallengeDnugeonDiffItem:OnSelected(isSelect, isClick)
  if isSelect and self.maxDiff_ + 1 < self.MasterChallenDungeonRow.Difficulty then
    Z.TipsVM.ShowTips(15001151)
    self.parent:SetSelected(self.maxDiff_ + 1)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelect)
  if isSelect then
    self.parent.UIView:OnDiffSelectChange(self.MasterChallenDungeonRow.Difficulty)
  end
end

function MasterChallengeDnugeonDiffItem:OnUnInit()
end

return MasterChallengeDnugeonDiffItem
