local UI = Z.UI
local super = require("ui.ui_view_base")
local Quest_book_windowView = class("Quest_book_windowView", super)
local loop_list_view = require("ui/component/loop_list_view")
local quest_book_catalogue_episode_item = require("ui.component.quest.quest_book_catalogue_episode_item")
local quest_book_catalogue_episode_chapter_item = require("ui.component.quest.quest_book_catalogue_episode_chapter_item")
local quest_book_chapter_item = require("ui.component.quest.quest_book_chapter_item")

function Quest_book_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "quest_book_window")
  self.questDetailVm_ = Z.VMMgr.GetVM("questdetail")
  self.questBookManualVm_ = Z.VMMgr.GetVM("quest_book_manual")
end

function Quest_book_windowView:OnActive()
  self.episodeAndPhasesDatas_ = {}
  self.fadeOutEpisodeIds_ = {}
  self.isNotSetFadeOut_ = true
  self.unLockedChapterInfos_ = nil
  self.isFirst_ = true
  self:onStartAnimShow()
  self:initComp()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_info)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.selectQuestType_ = E.QuestType.Main
  self.selectChapterId_ = nil
  self:initBtns()
  self:initLoop()
end

function Quest_book_windowView:initComp()
  self.closeBtn_ = self.uiBinder.btn_close
  self.lab_content_ = self.uiBinder.lab_content
  self.rimg_photo_ = self.uiBinder.rimg_photo
  self.loop_catalogue_ = self.uiBinder.loop_catalogue
  self.lab_title_ = self.uiBinder.lab_title
  self.node_rimg_ = self.uiBinder.node_rimg
  self.rect_title_ = self.uiBinder.rect_title
  self.rect_lab_content_ = self.uiBinder.rect_lab_content
  self.loop_chatper_ = self.uiBinder.loop_chatper
  self.lab_chapter_name_ = self.uiBinder.lab_chapter_name
  self.scroll_content_ = self.uiBinder.scroll_content
end

function Quest_book_windowView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.questDetailVm_.CloseQuestCatalogView()
  end)
end

function Quest_book_windowView:initLoop()
  self.loop_chatper_view_ = loop_list_view.new(self, self.loop_chatper_, quest_book_chapter_item, "quest_book_chapters_tab_tpl")
  self.loop_chatper_view_:Init({})
  self.loop_catalogue_view_ = loop_list_view.new(self, self.loop_catalogue_)
  self.loop_catalogue_view_:SetGetItemClassFunc(function(data)
    if data.isEpisode then
      return quest_book_catalogue_episode_item
    else
      return quest_book_catalogue_episode_chapter_item
    end
  end)
  self.loop_catalogue_view_:SetGetPrefabNameFunc(function(data)
    if data.isEpisode then
      return "quest_book_tog_list"
    else
      return "quest_book_tog_two_tpl"
    end
  end)
  self.loop_catalogue_view_:Init({})
end

function Quest_book_windowView:OnDeActive()
  self.episodeAndPhasesDatas_ = {}
  self.unLockedChapterInfos_ = nil
  self.isFirst_ = true
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_info)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.loop_catalogue_view_:UnInit()
  self.loop_chatper_view_:UnInit()
end

function Quest_book_windowView:OnRefresh()
  if self.viewData ~= nil then
  else
    self.questType_ = E.QuestType.Main
  end
  self:refreshChapterLoopUi()
end

function Quest_book_windowView:refreshChapterLoopUi()
  self.unLockedChapterInfos_ = self.questBookManualVm_.GetUnlockedChapters(self.questType_)
  if not self.unLockedChapterInfos_ or #self.unLockedChapterInfos_ < 1 then
    logError("Quest_book_windowView:refreshChapterLoopUi chapterInfos is nil")
    return
  end
  self.loop_chatper_view_:RefreshListView(self.unLockedChapterInfos_)
  self.loop_chatper_view_:SetSelected(#self.unLockedChapterInfos_)
end

function Quest_book_windowView:OnSelectChapter(chapterInfo)
  if chapterInfo == nil then
    logError("Quest_book_windowView:OnSelectChapter questInfoTitleTableRow is nil")
    return
  end
  self.curChapterInfo_ = chapterInfo
  local questInfoTitleTableRow = chapterInfo.questInfoTitleTableRow
  if questInfoTitleTableRow == nil then
    logError("Quest_book_windowView:OnSelectChapter questInfoTitleTableRow is nil")
    return
  end
  self.lab_chapter_name_.text = questInfoTitleTableRow.EpisodeName
  self:refreshEpisodeCatalogUI(self.curChapterInfo_)
end

function Quest_book_windowView:refreshEpisodeCatalogUI(chapterInfo)
  local chapterId = chapterInfo.questInfoTitleTableRow.Id
  self.curEpisodeAndPhasesData_ = self.episodeAndPhasesDatas_[chapterId]
  if self.curEpisodeAndPhasesData_ == nil then
    self.curEpisodeAndPhasesData_ = self.questBookManualVm_.GetChapterEpisodeAndPhases(chapterInfo.unlockedPhaseIds)
    self.episodeAndPhasesDatas_[chapterId] = self.curEpisodeAndPhasesData_
  end
  if #self.fadeOutEpisodeIds_ < 1 and self.isNotSetFadeOut_ then
    self.isNotSetFadeOut_ = false
    local lastIndex = #self.curEpisodeAndPhasesData_
    local id = self.curEpisodeAndPhasesData_[lastIndex].episodeId
    table.insert(self.fadeOutEpisodeIds_, id)
  end
  self:refreshCatalogueListView()
end

function Quest_book_windowView:OnSelectPhase(questInfoTableRow)
  if not self.isFirst_ then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  end
  self.isFirst_ = false
  local placeholderParam = Z.Placeholder.SetPlayerSelfPronoun()
  self.lab_content_.text = Z.Placeholder.Placeholder(questInfoTableRow.TaskInfo, placeholderParam)
  self.selectQuestInfoTableRow_ = questInfoTableRow
  self.lab_title_.text = Z.Placeholder.Placeholder(questInfoTableRow.PhaseName, placeholderParam)
  self.scroll_content_.VerticalNormalizedPosition = 1
  local picPath = questInfoTableRow.TitlePic
  if picPath == nil or picPath == "0" or picPath == "" then
    self.uiBinder.Ref:SetVisible(self.node_rimg_, false)
    self.rect_title_:SetAnchorPosition(15, -22)
    self.rect_lab_content_:SetOffsetMax(-30, -88)
  else
    self.uiBinder.Ref:SetVisible(self.node_rimg_, true)
    self.rect_title_:SetAnchorPosition(15, -590)
    self.rect_lab_content_:SetOffsetMax(12, -654)
    self.rimg_photo_:SetImage(picPath)
  end
end

function Quest_book_windowView:FadeExpandEpisode(episodeId)
  if table.zcontains(self.fadeOutEpisodeIds_, episodeId) then
    return
  end
  table.insert(self.fadeOutEpisodeIds_, episodeId)
  self:refreshCatalogueListView()
end

function Quest_book_windowView:FadeIndentEpisode(episodeId)
  if not table.zcontains(self.fadeOutEpisodeIds_, episodeId) then
    return
  end
  table.zremoveByValue(self.fadeOutEpisodeIds_, episodeId)
  self:refreshCatalogueListView()
end

function Quest_book_windowView:refreshCatalogueListView()
  self.showDatas_ = self.questBookManualVm_.GetBookShowEpisodeAnPhaseDatas(self.curEpisodeAndPhasesData_, self.fadeOutEpisodeIds_)
  self.loop_catalogue_view_:RefreshListView(self.showDatas_)
  local index = self:getIndex()
  self.loop_catalogue_view_:SetSelected(index)
end

function Quest_book_windowView:getIndex()
  if self.showDatas_ == nil or #self.showDatas_ < 1 then
    return -1
  end
  if self.selectQuestInfoTableRow_ == nil then
    return #self.showDatas_
  end
  for i, v in ipairs(self.showDatas_) do
    if not v.isEpisode and v.phaseInfo.Id == self.selectQuestInfoTableRow_.Id then
      return i
    end
  end
  return -1
end

function Quest_book_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Quest_book_windowView
