local super = require("ui.component.loop_list_view_item")
local QuestDetailCatalogueQuestItem = class("QuestDetailCatalogueQuestItem", super)

function QuestDetailCatalogueQuestItem:OnInit()
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self:initComp()
end

function QuestDetailCatalogueQuestItem:initComp()
  self.lab_name_off_ = self.uiBinder.lab_name_off
  self.lab_name_on_ = self.uiBinder.lab_name_on
  self.lab_distance_on_ = self.uiBinder.lab_distance_on
  self.lab_distance_off_ = self.uiBinder.lab_distance_off
  self.group_quest_location_off_ = self.uiBinder.group_quest_location_off
  self.group_quest_location_on_ = self.uiBinder.group_quest_location_on
  self.img_dot_ = self.uiBinder.img_dot
  self.tog_item_ = self.uiBinder.tog_item
  self.img_state_ = self.uiBinder.img_state
  self.canvasgroup_line_ = self.uiBinder.canvasgroup_line
end

function QuestDetailCatalogueQuestItem:OnRefresh(data)
  if data.isQuestType then
    return
  end
  self:SetCanSelect(true)
  self:refreshQuestTpl(data.questId)
end

function QuestDetailCatalogueQuestItem:OnUnInit()
  self.tog_item_.group = nil
  self.tog_item_.isOn = false
end

function QuestDetailCatalogueQuestItem:refreshQuestTpl(questId)
  self.questId_ = questId
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questRow = questTbl.GetRow(questId)
  if not questRow then
    return
  end
  local questDetailView = self.parent.UIView
  local questData = Z.DataMgr.Get("quest_data")
  self.lab_name_off_.text = questRow.QuestName
  self.lab_name_on_.text = questRow.QuestName
  self:refreshQuestStateIcon(questId)
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  local goalIdx = self.questVM_.GetUncompletedGoalIndex(questId)
  local trackData = questData:GetGoalTrackData(quest.stepId, goalIdx)
  local toSceneId = trackData and trackData.toSceneId or 0
  local sceneName
  if 0 < toSceneId then
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(toSceneId)
    sceneName = sceneRow and sceneRow.Name or ""
  else
    sceneName = ""
  end
  self.lab_distance_on_.text = sceneName
  self.lab_distance_off_.text = sceneName
  self.uiBinder.Ref:SetVisible(self.group_quest_location_off_, sceneName ~= "")
  self.uiBinder.Ref:SetVisible(self.group_quest_location_on_, sceneName ~= "")
  local isSelected = questDetailView:GetSelectedQuest() == questId
  self.tog_item_.isOn = isSelected
  self.uiBinder.Ref:SetVisible(self.img_dot_, self.questVM_.IsShowQuestRed(questId))
end

function QuestDetailCatalogueQuestItem:refreshQuestStateIcon(questId)
  local questDetailVM = Z.VMMgr.GetVM("questdetail")
  local path = questDetailVM.GetStateIconByQuestId(questId)
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsShowInTrackBar(questId) and path ~= nil and path ~= "" then
    self.uiBinder.Ref:SetVisible(self.img_state_, true)
    self.img_state_:SetImage(path)
    self.canvasgroup_line_.alpha = 1
  else
    self.uiBinder.Ref:SetVisible(self.img_state_, false)
    self.canvasgroup_line_.alpha = 0.1
  end
end

function QuestDetailCatalogueQuestItem:OnSelected(isSelected)
  self.tog_item_.isOn = isSelected
  if isSelected then
    self.parent.UIView:SelectQuest(self.questId_)
    self.questVM_.CloseQuestRed(self.questId_)
    self.uiBinder.Ref:SetVisible(self.img_dot_, false)
  end
end

return QuestDetailCatalogueQuestItem
