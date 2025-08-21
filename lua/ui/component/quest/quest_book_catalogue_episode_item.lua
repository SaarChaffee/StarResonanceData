local super = require("ui.component.loop_list_view_item")
local QuestBookCatalogueEpisodeItem = class("QuestBookCatalogueEpisodeItem", super)

function QuestBookCatalogueEpisodeItem:OnInit()
end

function QuestBookCatalogueEpisodeItem:initComp()
end

function QuestBookCatalogueEpisodeItem:OnRefresh(data)
  if not data.isEpisode then
    return
  end
  self:SetCanSelect(false)
  self.uiBinder.tog_one_tpl.isOn = data.isFadeOut
  self.uiBinder.lab_on_content.text = data.episodeName
  self.uiBinder.lab_off_content.text = data.episodeName
end

function QuestBookCatalogueEpisodeItem:OnUnInit()
end

function QuestBookCatalogueEpisodeItem:OnPointerClick(go, eventData)
  local data = self:GetCurData()
  if data.isFadeOut then
    self.parent.UIView:FadeIndentEpisode(data.episodeId)
  else
    self.parent.UIView:FadeExpandEpisode(data.episodeId)
  end
end

return QuestBookCatalogueEpisodeItem
