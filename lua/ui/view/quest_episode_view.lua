local super = require("ui.ui_view_base")
local Quest_episodeView = class("Quest_episodeView", super)

function Quest_episodeView:ctor()
  super.ctor(self, "quest_episode")
end

function Quest_episodeView:OnActive()
  self.episodeId_ = self.viewData.EpisodeId
  self.isStart_ = self.viewData.IsStart
  Z.LuaBridge.SetIsOnlyTalkLayer(true, Panda.ZGame.EIgnoreMaskSource.QuestEpisode)
  local episodeRow = Z.TableMgr.GetTable("EpisodeTableMgr").GetRow(self.episodeId_)
  if episodeRow then
    self.uiBinder.lab_title.text = episodeRow.EpisodeName
    self.uiBinder.lab_info.text = episodeRow.ChapterPreview
    local str = self.isStart_ and "\229\188\128\229\167\139" or "\231\187\147\230\157\159"
    self.uiBinder.lab_name.text = episodeRow.Episode .. str
  end
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("quest_episode")
  end)
end

function Quest_episodeView:OnRefresh()
end

function Quest_episodeView:OnDeActive()
  Z.LuaBridge.SetIsOnlyTalkLayer(false, Panda.ZGame.EIgnoreMaskSource.QuestEpisode)
  local goalType = self.isStart_ and E.GoalType.EpisodeStart or E.GoalType.EpisodeEnd
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(goalType, self.episodeId_)
  self.episodeId_ = nil
  self.isStart_ = nil
end

return Quest_episodeView
