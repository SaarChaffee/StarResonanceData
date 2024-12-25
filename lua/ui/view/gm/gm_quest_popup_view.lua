local UI = Z.UI
local super = require("ui.ui_view_base")
local Gm_quest_popupView = class("Gm_quest_popupView", super)

function Gm_quest_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gm_quest_popup")
  self.questData_ = Z.DataMgr.Get("quest_data")
end

function Gm_quest_popupView:OnActive()
  self.trackingQuestId_ = 0
  self.questItemPath_ = self.uiBinder.prefab_cache:GetString("quest") or ""
  self.uiBinder.tog_content.isOn = false
  self:loadHiddenQuest()
  self:loadAllServerQuest()
  self.timerMgr:StartFrameTimer(function()
    self:refreshSceneLab()
    self:refreshVisualLayerLab()
    self:refreshTrackingQuest()
    self:refreshTrackDetail()
    self:refreshClickQuest()
  end, 1, -1)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("gm_quest_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_finish1, function()
    self:sendFinishGM(self.trackingQuestId_)
  end)
  self:AddAsyncClick(self.uiBinder.btn_finish2, function()
    self:sendFinishGM(self.questData_.GMSelectQuestId)
  end)
  self:AddClick(self.uiBinder.btn_flow1, function()
    self:openStepFlow(self.trackingQuestId_)
  end)
  self:AddClick(self.uiBinder.btn_flow2, function()
    self:openStepFlow(self.questData_.GMSelectQuestId)
  end)
  self.uiBinder.img_bg.onDrag:AddListener(function(go, pointerData)
    local pos = self.uiBinder.img_bg_ref.localPosition
    local posX = pos.x + pointerData.delta.x
    local posy = pos.y + pointerData.delta.y
    self.uiBinder.img_bg_ref:SetLocalPos(posX, posy)
  end)
end

function Gm_quest_popupView:OnDeActive()
  self.trackingQuestId_ = nil
end

function Gm_quest_popupView:sendFinishGM(questId)
  local quest = self.questData_:GetQuestByQuestId(questId)
  if quest then
    local cmdInfo = string.zconcat("finishQuest ", questId, ",", quest.stepId)
    local gmVM = Z.VMMgr.GetVM("gm")
    gmVM.SubmitGmCmd(cmdInfo, self.cancelSource)
  end
end

function Gm_quest_popupView:openStepFlow(questId)
  if questId <= 0 then
    return
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow and questRow.StepFlowPath ~= "" then
    Z.EPFlowBridge.OpenFlowWindow(questRow.StepFlowPath)
  end
end

function Gm_quest_popupView:refreshSceneLab()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local name = sceneRow and sceneRow.Name or ""
  self.uiBinder.lab_scene.text = sceneId .. " " .. name
end

function Gm_quest_popupView:refreshVisualLayerLab()
  local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  self.uiBinder.lab_visual_layer.text = visualLayerId
end

function Gm_quest_popupView:refreshTrackingQuest()
  local questId = self.questData_:GetQuestTrackingId()
  local quest = self.questData_:GetQuestByQuestId(questId)
  local stepId = quest and quest.stepId or 0
  self.trackingQuestId_ = questId
  self.uiBinder.lab_nowtracequest.text = string.zconcat(questId, ", ", stepId)
end

function Gm_quest_popupView:refreshTrackDetail()
  self.uiBinder.lab_force_track.text = self.questData_.forceTrackId_
  self.uiBinder.lab_follow_track.text = self.questData_.followTrackQuest_
  self.uiBinder.lab_select_track.text = self.questData_.selectTrackId_
  local optionList = self.questData_.trackOptionalIdList_
  self.uiBinder.lab_track_option.text = string.zconcat(optionList[1], ", ", optionList[2])
end

function Gm_quest_popupView:loadHiddenQuest()
  local questDict = self.questData_:GetAllQuestDict()
  Z.CoroUtil.create_coro_xpcall(function()
    for questId, quest in pairs(questDict) do
      local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
      if questRow then
        local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
        if typeRow and (typeRow.QuestListHide or not typeRow.ShowQuestUI) then
          local unit = self:AsyncLoadUiUnit(self.questItemPath_, questId, self.uiBinder.cont_content1)
          if unit then
            local lab = string.zconcat(questId, ", ", quest.stepId)
            unit.gm_quest_item.text = lab
          end
        end
      end
    end
  end)()
end

function Gm_quest_popupView:loadAllServerQuest()
  local questMap = Z.ContainerMgr.CharSerialize.questList.questMap
  local idList = {}
  for questId, _ in pairs(questMap) do
    table.insert(idList, questId)
  end
  table.sort(idList)
  Z.CoroUtil.create_coro_xpcall(function()
    for _, questId in ipairs(idList) do
      local quest = questMap[questId]
      if quest then
        local unit = self:AsyncLoadUiUnit(self.questItemPath_, "server" .. questId, self.uiBinder.cont_content2)
        if unit then
          local lab = string.zconcat(questId, ", ", quest.stepId)
          unit.gm_quest_item.text = lab
        end
      end
    end
  end)()
end

function Gm_quest_popupView:refreshClickQuest()
  local questId = self.questData_.GMSelectQuestId
  local quest = self.questData_:GetQuestByQuestId(questId)
  local stepId = quest and quest.stepId or 0
  local lab = string.zconcat(questId, ", ", stepId)
  self.uiBinder.lab_nowselecetquest.text = lab
end

return Gm_quest_popupView
