local super = require("ui.component.loop_list_view_item")
local QuestBookCatalogueEpisodeChapterItem = class("QuestBookCatalogueEpisodeChapterItem", super)

function QuestBookCatalogueEpisodeChapterItem:OnInit()
  self:SetCanSelect(true)
end

function QuestBookCatalogueEpisodeChapterItem:initComp()
end

function QuestBookCatalogueEpisodeChapterItem:OnRefresh(data)
  self.uiBinder.lab_name_off.text = data.chapterInfo.TitleName
  self.uiBinder.lab_name_on.text = data.chapterInfo.TitleName
  self.uiBinder.tog_item.isOn = self.IsSelected
end

function QuestBookCatalogueEpisodeChapterItem:OnUnInit()
end

function QuestBookCatalogueEpisodeChapterItem:OnSelected(isSelected)
  self.uiBinder.tog_item.isOn = isSelected
  if isSelected then
    self.parent.UIView:OnSelectChapter(self:GetCurData().chapterInfo)
  end
end

return QuestBookCatalogueEpisodeChapterItem
