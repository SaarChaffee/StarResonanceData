local super = require("ui.component.loop_list_view_item")
local QuestDetailCatalogueQuestItem = class("QuestDetailCatalogueQuestItem", super)

function QuestDetailCatalogueQuestItem:OnInit()
  self.questGoalVM_ = Z.VMMgr.GetVM("quest_goal")
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self:initComp()
  self.limitComp_ = require("ui/component/quest/quest_limit_comp").new(self.parent.UIView, {
    date = function(state)
      self:refreshDateLimit(state)
    end
  })
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
  self.node_state_ = self.uiBinder.node_state
  self.img_state_ = self.uiBinder.img_state
  self.canvasgroup_line_ = self.uiBinder.canvasgroup_line
  self.img_time_flag_on_ = self.uiBinder.img_time_flag_on
  self.img_time_flag_off_ = self.uiBinder.img_time_flag_off
  self.img_state_empty_ = self.uiBinder.img_state_empty
end

function QuestDetailCatalogueQuestItem:OnRefresh(data)
  if data.isQuestType then
    return
  end
  self:SetCanSelect(true)
  self:refreshQuestTpl(data.questId)
  self.limitComp_:UnInit()
  self.limitComp_:Init(data.questId, nil)
end

function QuestDetailCatalogueQuestItem:OnUnInit()
  self.tog_item_.group = nil
  self.tog_item_.isOn = false
  self.limitComp_:UnInit()
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
  local name = self.questVM_.GetQuestName(questId)
  self.lab_name_off_.text = name
  self.lab_name_on_.text = name
  self.uiBinder.Ref:SetVisible(self.img_time_flag_off_, false)
  self.uiBinder.Ref:SetVisible(self.img_time_flag_on_, false)
  self:refreshQuestStateIcon(questId)
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  local goalIdx = self.questGoalVM_.GetUncompletedGoalIndex(questId)
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
  if not Z.IsPCUI then
    self.lab_distance_off_.text = sceneName
    self.uiBinder.Ref:SetVisible(self.group_quest_location_off_, sceneName ~= "")
  end
  self.uiBinder.Ref:SetVisible(self.group_quest_location_on_, sceneName ~= "")
  local isSelected = questDetailView:GetSelectedQuest() == questId
  self.tog_item_.isOn = isSelected
  local isShowRedDot = Z.RedCacheContainer:GetQuestRed().IsShowQuestRed(questId)
  self.uiBinder.Ref:SetVisible(self.img_dot_, isShowRedDot)
end

function QuestDetailCatalogueQuestItem:refreshQuestStateIcon(questId)
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local path = questIconVM.GetStateIconByQuestId(questId)
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsShowInTrackBar(questId) and path ~= nil and path ~= "" then
    self.uiBinder.Ref:SetVisible(self.img_state_, true)
    if Z.IsPCUI then
      self.uiBinder.Ref:SetVisible(self.img_state_empty_, false)
    end
    self.img_state_:SetImage(path)
    local trackId = questData:GetQuestTrackingId()
    local isTrace = trackId == questId
    if isTrace then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_light, true)
      self.uiBinder.anim_quest_light:Restart(Z.DOTweenAnimType.Open)
    end
    if not Z.IsPCUI then
      self.canvasgroup_line_.alpha = 1
    end
  else
    self.uiBinder.Ref:SetVisible(self.img_state_, false)
    if Z.IsPCUI then
      self.uiBinder.Ref:SetVisible(self.img_state_empty_, true)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_light, false)
    if not Z.IsPCUI then
      self.canvasgroup_line_.alpha = 0.1
    end
  end
end

function QuestDetailCatalogueQuestItem:OnPointerClick(go, eventData)
  if Z.IsPCUI then
    self.parent.UIView:OnClickBtnAnimShow()
  end
end

function QuestDetailCatalogueQuestItem:OnSelected(isSelected)
  self.tog_item_.isOn = isSelected
  if isSelected then
    self.parent.UIView:SelectQuest(self.questId_)
    Z.RedCacheContainer:GetQuestRed().CloseQuestRed(self.questId_)
    self.uiBinder.Ref:SetVisible(self.img_dot_, false)
  end
end

function QuestDetailCatalogueQuestItem:refreshDateLimit(idx, state, time)
  self.isShowTimeflag_ = state == E.QuestLimitState.NotMet
  self:refreshImgFlag()
end

function QuestDetailCatalogueQuestItem:refreshImgFlag()
  self.uiBinder.Ref:SetVisible(self.img_time_flag_on_, self.isShowTimeflag_)
  self.uiBinder.Ref:SetVisible(self.img_time_flag_off_, self.isShowTimeflag_)
end

return QuestDetailCatalogueQuestItem
