local super = require("ui.component.loop_list_view_item")
local QuestBookChapterItem = class("QuestBookChapterItem", super)

function QuestBookChapterItem:OnInit()
end

function QuestBookChapterItem:OnRefresh(data)
  local questInfoTitleTableRow = data.questInfoTitleTableRow
  self.uiBinder.img_bg:SetImage(questInfoTitleTableRow.EpisodeIcon)
  self.uiBinder.lab_name.text = questInfoTitleTableRow.EpisodeTitle
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_select, self.IsSelected)
end

function QuestBookChapterItem:OnUnInit()
end

function QuestBookChapterItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_select, self.IsSelected)
  if isSelected then
    local view = self.parent.UIView
    view:OnSelectChapter(self:GetCurData())
  end
end

return QuestBookChapterItem
