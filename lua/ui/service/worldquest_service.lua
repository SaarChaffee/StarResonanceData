local super = require("ui.service.service_base")
local WorldQuestService = class("WorldQuestService", super)

function WorldQuestService:OnInit()
end

function WorldQuestService:OnUnInit()
end

function WorldQuestService:OnLogin()
  self.needShowFollowTips = true
  self.worldQuestVM_ = Z.VMMgr.GetVM("worldquest")
  self.worldQuestData_ = Z.DataMgr.Get("worldquest_data")
  self.worldQuestData_.AcceptWorldQuest = false
  
  function self.onWorldEventDataChange_(_, _)
    Z.EventMgr:Dispatch(Z.ConstValue.WorldQuestListChange)
    self.worldQuestData_:ClearDict()
  end
  
  Z.ContainerMgr.CharSerialize.worldEventMap.Watcher:RegWatcher(self.onWorldEventDataChange_)
end

function WorldQuestService:OnLogout()
  Z.ContainerMgr.CharSerialize.worldEventMap.Watcher:UnregWatcher(self.onWorldEventDataChange_)
end

function WorldQuestService:OnEnterScene(sceneId)
end

function WorldQuestService:OnSyncAllContainerData()
  local questMap = Z.ContainerMgr.CharSerialize.questList.questMap or {}
  for questId, v in pairs(questMap) do
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow and questRow.QuestType == E.QuestType.WorldQuest then
      local worldQuestData_ = Z.DataMgr.Get("worldquest_data")
      worldQuestData_.AcceptWorldQuest = true
      Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnWorldQuestRefresh)
    end
  end
end

return WorldQuestService
