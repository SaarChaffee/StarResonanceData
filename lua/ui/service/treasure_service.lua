local super = require("ui.service.service_base")
local TreasureService = class("TreasureService", super)
local treasureRed = require("rednode.treasure_red")

function TreasureService:OnInit()
  function self.onChangeFunc(container, dirtyKeys)
    if dirtyKeys.subTargets then
      for _, treasureItemRow in pairs(Z.ContainerMgr.CharSerialize.treasure.rows) do
        if treasureItemRow.configId == container.configId then
          local data = treasureItemRow.subTargets
          
          local changeDirtyTarget = dirtyKeys.subTargets
          for key, value in pairs(data) do
            if changeDirtyTarget[key] then
              local targetRow = Z.TableMgr.GetTable("WeeklyTreasureTargetTableMgr").GetRow(value.targetId)
              if targetRow and targetRow.Num <= value.targetNum then
                local param = {
                  normalShow = true,
                  title = Lang("treasure_target_finish_pop_tips"),
                  labDesc = targetRow.TargetDes
                }
                Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "main_upgrade_window", param, 0)
              end
            end
          end
        end
      end
    end
  end
  
  function self.onflagChangeFunc(container, dirtyKeys)
    if dirtyKeys.flag then
      for _, treasureItemRow in pairs(Z.ContainerMgr.CharSerialize.treasure.rows) do
        treasureItemRow.Watcher:RegWatcher(self.onChangeFunc)
      end
    end
  end
end

function TreasureService:OnLateInit()
end

function TreasureService:OnUnInit()
end

function TreasureService:OnLogin()
end

function TreasureService:initCacheData(checkFinish)
end

function TreasureService:OnSyncAllContainerData()
  for _, treasureItemRow in pairs(Z.ContainerMgr.CharSerialize.treasure.rows) do
    treasureItemRow.Watcher:RegWatcher(self.onChangeFunc)
  end
  Z.ContainerMgr.CharSerialize.treasure.Watcher:RegWatcher(self.onflagChangeFunc)
  treasureRed:Init()
end

function TreasureService:OnLogout()
  for _, treasureItemRow in pairs(Z.ContainerMgr.CharSerialize.treasure.rows) do
    treasureItemRow.Watcher:UnregWatcher(self.onChangeFunc)
  end
  Z.ContainerMgr.CharSerialize.treasure.Watcher:UnregWatcher(self.onflagChangeFunc)
  treasureRed:UnInit()
end

function TreasureService:OnEnterScene(sceneId)
end

function TreasureService:OnLeaveScene()
end

return TreasureService
