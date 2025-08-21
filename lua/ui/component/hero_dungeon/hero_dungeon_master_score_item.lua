local super = require("ui.component.loop_grid_view_item")
local HeroDungeonMasterScoreItem = class("HeroDungeonMasterScoreTItem", super)

function HeroDungeonMasterScoreItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.heroDungeonVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function HeroDungeonMasterScoreItem:OnRefresh(data)
  local maxScore = self.heroDungeonVM_.GetDungeonScoreMax(data.dungeonId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_lab, maxScore <= data.score)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, data.score > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, data.score == 0)
  local challengeDungeonRow = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(data.dungeonId)
  if challengeDungeonRow then
    self.uiBinder.rimg_dungeon_on:SetImage(challengeDungeonRow.MasterModePic)
    self.uiBinder.rimg_dungeon_off:SetImage(challengeDungeonRow.MasterModePic)
  end
  local scoreText = self.heroDungeonVM_.GetPlayerSeasonMasterDungeonScoreWithColor(data.score)
  self.uiBinder.lab_num.text = scoreText
  self.uiView_:AddAsyncClick(self.uiBinder.btn_click, function()
    if data.masterChallengeDungeonId == nil then
      return
    end
    local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(data.dungeonId)
    if dungeonRow == nil then
      return
    end
    local title = dungeonRow.Name
    local subTitle = string.format(Lang("master_dungeon_score"), data.score) .. "\n"
    if data.score >= maxScore then
      subTitle = subTitle .. Z.RichTextHelper.ApplyColorTag(Lang("master_dungeon_max_score"), "#CFEA88")
    end
    local content = ""
    if data.score == 0 then
      content = Lang("master_dungeon_best_diff_title") .. Lang("noYet")
      content = content .. "\n" .. Lang("master_dungeon_best_time") .. Lang("noYet")
    else
      content = string.format(Lang("master_dungeon_best_diff"), data.diff)
      content = content .. "\n" .. Lang("master_dungeon_best_time") .. self:formatDuration(data.time)
    end
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.Trans, title, content, subTitle)
  end)
end

function HeroDungeonMasterScoreItem:formatDuration(seconds)
  local minutes = math.floor(seconds / 60)
  local remainingSeconds = seconds % 60
  local formattedMinutes = string.format("%02d", minutes)
  local formattedSeconds = string.format("%02d", remainingSeconds)
  return formattedMinutes .. ":" .. formattedSeconds
end

function HeroDungeonMasterScoreItem:OnUnInit()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

return HeroDungeonMasterScoreItem
