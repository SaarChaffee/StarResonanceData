local super = require("ui.component.loop_list_view_item")
local QuestDetailCatalogueQuestTypeItem = class("QuestDetailCatalogueQuestTypeItem", super)

function QuestDetailCatalogueQuestTypeItem:OnInit()
  self:initComp()
end

function QuestDetailCatalogueQuestTypeItem:initComp()
  self.lab_quest_type_ = self.uiBinder.lab_quest_type
  self.img_quest_type_ = self.uiBinder.img_quest_type
end

function QuestDetailCatalogueQuestTypeItem:OnRefresh(data)
  if not data.isQuestType then
    return
  end
  self:SetCanSelect(false)
  local typeGroupRow = data.tblRow
  self.lab_quest_type_.text = typeGroupRow.GroupName
  self.img_quest_type_:SetImage("ui/atlas/quest/icon/quest_icon_type_" .. typeGroupRow.TypeGroupUI)
end

function QuestDetailCatalogueQuestTypeItem:OnUnInit()
end

return QuestDetailCatalogueQuestTypeItem
