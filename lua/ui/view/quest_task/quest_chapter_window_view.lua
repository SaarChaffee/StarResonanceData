local UI = Z.UI
local super = require("ui.ui_view_base")
local Quest_chapter_windowView = class("Quest_chapter_windowView", super)

function Quest_chapter_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "quest_chapter_window")
  Z.AudioMgr:Play("UI_Event_TitleStart")
end

function Quest_chapter_windowView:OnActive()
  self.episodeId_ = self.viewData.EpisodeId
  self.isStart_ = self.viewData.IsStart
  Z.LuaBridge.SetIsOnlyTalkLayer(true, Panda.ZGame.EIgnoreMaskSource.QuestEpisode)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local episodeRow = Z.TableMgr.GetTable("EpisodeTableMgr").GetRow(self.episodeId_)
  if episodeRow then
    self.uiBinder.lab_chapters_num.text = episodeRow.Episode
    if self.isStart_ then
      self.uiBinder.lab_chapters_name.text = episodeRow.EpisodeName
    else
      self.uiBinder.lab_chapters_name.text = Lang("ChapterConclusion")
    end
  end
  self:autoCloseView()
end

function Quest_chapter_windowView:OnDeActive()
  Z.LuaBridge.SetIsOnlyTalkLayer(false, Panda.ZGame.EIgnoreMaskSource.QuestEpisode)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.episodeId_ = nil
  self.isStart_ = nil
end

function Quest_chapter_windowView:autoCloseView()
  Z.CoroUtil.create_coro_xpcall(function()
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, "quest_chapter_window_open", self.cancelSource:CreateToken())
    asyncCall(self.uiBinder.anim, "quest_chapter_window_cloes", self.cancelSource:CreateToken())
    Z.UIMgr:CloseView("quest_chapter_window")
  end)()
end

function Quest_chapter_windowView:OnRefresh()
end

return Quest_chapter_windowView
