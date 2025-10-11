local super = require("ui.component.loop_list_view_item")
local QuestBookCatalogueEpisodeChapterItem = class("QuestBookCatalogueEpisodeChapterItem", super)

function QuestBookCatalogueEpisodeChapterItem:OnInit()
  self:SetCanSelect(true)
end

function QuestBookCatalogueEpisodeChapterItem:initComp()
end

function QuestBookCatalogueEpisodeChapterItem:OnRefresh(data)
  local placeholderParam = Z.Placeholder.SetPlayerSelfPronoun()
  local phaseName = Z.Placeholder.Placeholder(data.phaseInfo.PhaseName, placeholderParam)
  self.uiBinder.lab_name_off.text = phaseName
  self.uiBinder.lab_name_on.text = phaseName
  self.uiBinder.tog_item.isOn = self.IsSelected
end

function QuestBookCatalogueEpisodeChapterItem:OnUnInit()
end

function QuestBookCatalogueEpisodeChapterItem:OnSelected(isSelected)
  self.uiBinder.tog_item.isOn = isSelected
  if isSelected then
    self.parent.UIView:OnSelectPhase(self:GetCurData().phaseInfo)
  end
end

return QuestBookCatalogueEpisodeChapterItem
