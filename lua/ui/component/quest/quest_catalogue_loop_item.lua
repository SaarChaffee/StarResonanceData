local super = require("ui.component.loopscrollrectitem")
local QuestCatalogueLoopItem = class("QuestCatalogueLoopItem", super)
local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
local questVm = Z.VMMgr.GetVM("quest")

function QuestCatalogueLoopItem:OnInit()
  self:initComp()
end

function QuestCatalogueLoopItem:initComp()
  self.group_quest_lab_ = self.uiBinder.group_quest_lab
  self.quest_name_item_tpl_ = self.uiBinder.quest_name_item_tpl
  self.lab_quest_type_ = self.uiBinder.lab_quest_type
  self.img_quest_type_ = self.uiBinder.img_quest_type
  self.lab_name_1_ = self.uiBinder.lab_name_1
  self.lab_name_2_ = self.uiBinder.lab_name_2
  self.lab_distance_on_ = self.uiBinder.lab_distance_on
  self.lab_distance_off_ = self.uiBinder.lab_distance_off
  self.group_quest_location_1_ = self.uiBinder.group_quest_location_1
  self.group_quest_location_2_ = self.uiBinder.group_quest_location_2
  self.img_frame_ = self.uiBinder.img_frame
  self.img_select_ = self.uiBinder.img_select
  self.img_dot_ = self.uiBinder.img_dot
  self.tog_item_ = self.uiBinder.tog_item
  self.img_state_ = self.uiBinder.img_state
end

function QuestCatalogueLoopItem:Refresh()
  questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local index = self.component.Index + 1
  local catalogueData = self.parent:GetDataByIndex(index)
  self.uiBinder.Ref:SetVisible(self.group_quest_lab_, catalogueData.isTip)
  self.uiBinder.Ref:SetVisible(self.quest_name_item_tpl_, not catalogueData.isTip)
  if catalogueData.isTip then
    self:initLabTpl(catalogueData.tblRow)
  else
    self:initQuestTpl(catalogueData.questId)
  end
end

function QuestCatalogueLoopItem:initLabTpl(tblRow)
  local typeGroupRow = tblRow
  self.lab_quest_type_.text = typeGroupRow.GroupName
  self.img_quest_type_:SetImage("ui/atlas/quest/icon/quest_icon_type_" .. typeGroupRow.TypeGroupUI)
end

function QuestCatalogueLoopItem:initQuestTpl(questId)
  local questRow = questTbl.GetRow(questId)
  if not questRow then
    return
  end
  local questDetailView = self.parent.uiView
  local questData = Z.DataMgr.Get("quest_data")
  local questName = questVm.GetQuestName(questRow.id)
  self.lab_name_1_.text = questName
  self.lab_name_2_.text = questName
  self:refreshQuestStateIcon(questId)
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  local goalIdx = questGoalVM.GetUncompletedGoalIndex(questId)
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
  self.uiBinder.Ref:SetVisible(self.group_quest_location_1_, sceneName ~= "")
  self.uiBinder.Ref:SetVisible(self.group_quest_location_2_, sceneName ~= "")
  local isSelected = questDetailView:GetSelectedQuest() == questId
  self.uiBinder.Ref:SetVisible(self.img_frame_, not isSelected)
  self.uiBinder.Ref:SetVisible(self.img_select_, isSelected)
  self.tog_item_.group = self.parent.uiView.uiBinder.toggroup_catalogue
  self.tog_item_:AddListener(function(isOn)
    if isOn then
      questDetailView:SelectQuest(questId)
      Z.RedCacheContainer:GetQuestRed().CloseQuestRed(questId)
      self.uiBinder.Ref:SetVisible(self.img_dot_, false)
    end
  end)
  self.tog_item_.isOn = self.parent.uiView.selectQuest_ == questId
  local isShowRedDot = Z.RedCacheContainer:GetQuestRed().IsShowQuestRed(questId)
  self.uiBinder.Ref:SetVisible(self.img_dot_, isShowRedDot)
end

function QuestCatalogueLoopItem:OnReset()
  self.tog_item_.group = nil
  self.tog_item_.isOn = false
  self.uiBinder.Ref:SetVisible(self.group_quest_lab_, false)
  self.uiBinder.Ref:SetVisible(self.quest_name_item_tpl_, false)
end

function QuestCatalogueLoopItem:refreshQuestStateIcon(questId)
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local path = questIconVM.GetStateIconByQuestId(questId)
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsShowInTrackBar(questId) and path ~= nil and path ~= "" then
    self.uiBinder.Ref:SetVisible(self.img_state_, true)
    self.img_state_:SetImage(path)
  else
    self.uiBinder.Ref:SetVisible(self.img_state_, false)
  end
end

return QuestCatalogueLoopItem
