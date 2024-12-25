local UI = Z.UI
local super = require("ui.ui_view_base")
local Quest_book_windowView = class("Quest_book_windowView", super)
local loop_list_view = require("ui/component/loop_list_view")
local quest_book_catalogue_episode_item = require("ui.component.quest.quest_book_catalogue_episode_item")
local quest_book_catalogue_episode_chapter_item = require("ui.component.quest.quest_book_catalogue_episode_chapter_item")

function Quest_book_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "quest_book_window")
  self.questDetailVm_ = Z.VMMgr.GetVM("questdetail")
end

function Quest_book_windowView:OnActive()
  self:initComp()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.selectedEpisode_ = 0
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
end

function Quest_book_windowView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.questDetailVm_.CloseQuestCatalogView()
  end)
end

function Quest_book_windowView:initLoop()
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
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.selectedEpisode_ = 0
  self.loop_catalogue_view_:UnInit()
end

function Quest_book_windowView:OnRefresh()
  if self.viewData ~= nil then
  else
    self.questType_ = E.QuestType.Main
    self.episodeList = {1}
  end
  self:refrehsUI()
end

function Quest_book_windowView:refrehsUI()
  local catalogs = self.questDetailVm_.GetEpisodeOrderedChapterCatalog(self.questType_, self.episodeList)
  if not catalogs then
    return
  end
  local selectIndex = 0
  selectIndex = self.questDetailVm_.GetFirstEpisodeChaterIndex(catalogs)
  if selectIndex < 0 then
    logError("Quest_book_windowView:refrehsUI selectIndex < 0")
    return
  end
  self.loop_catalogue_view_:RefreshListView(catalogs)
  self.loop_catalogue_view_:SetSelected(selectIndex)
end

function Quest_book_windowView:OnSelectChapter(chapterInfo)
  self.selectChapterId_ = chapterInfo.Id
  self.lab_content_.text = chapterInfo.TaskInfo
  self.lab_title_.text = chapterInfo.TitleName
  if chapterInfo.TitlePic == nil or chapterInfo.TitlePic == "0" then
    self.uiBinder.Ref:SetVisible(self.node_rimg_, false)
    self.rect_title_:SetAnchorPosition(15, -22)
    self.rect_lab_content_:SetOffsetMax(-30, -88)
  else
    self.uiBinder.Ref:SetVisible(self.node_rimg_, true)
    self.rect_title_:SetAnchorPosition(15, -610)
    self.rect_lab_content_:SetOffsetMax(12, -676)
    self.rimg_photo_:SetImage(chapterInfo.TitlePic)
  end
end

function Quest_book_windowView:FadeExpandEpisode(episode)
  if table.zcontains(self.episodeList, episode) then
    return
  end
  table.insert(self.episodeList, episode)
  local catalogs = self.questDetailVm_.GetEpisodeOrderedChapterCatalog(self.questType_, self.episodeList)
  self.loop_catalogue_view_:RefreshListView(catalogs)
  local selectIndex = self:getIndex(catalogs)
  if 0 < selectIndex then
    self.loop_catalogue_view_:SetSelected(selectIndex)
  end
end

function Quest_book_windowView:FadeIndentEpisode(episode)
  if not table.zcontains(self.episodeList, episode) then
    return
  end
  table.zremoveByValue(self.episodeList, episode)
  local catalogs = self.questDetailVm_.GetEpisodeOrderedChapterCatalog(self.questType_, self.episodeList)
  self.loop_catalogue_view_:RefreshListView(catalogs)
  local selectIndex = self:getIndex(catalogs)
  if 0 < selectIndex then
    self.loop_catalogue_view_:SetSelected(selectIndex)
  end
end

function Quest_book_windowView:getIndex(catalogs)
  if self.selectChapterId_ == nil or self.selectChapterId_ == 0 then
    local selectIndex = self.questDetailVm_.GetFirstEpisodeChaterIndex(catalogs)
    return selectIndex
  end
  for i, v in ipairs(catalogs) do
    if v.isEpisode == false and v.chapterInfo.Id == self.selectChapterId_ then
      return i
    end
  end
  return -1
end

return Quest_book_windowView
