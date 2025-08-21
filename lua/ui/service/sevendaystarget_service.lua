local super = require("ui.service.service_base")
local SevendaysTargetService = class("SevendaysTargetService", super)

function SevendaysTargetService:OnInit()
end

function SevendaysTargetService:OnUnInit()
end

function SevendaysTargetService:OnLogin()
  function self.refreshOrInitSevenDaysTargetRed_(container, dirtyKeys)
    self:refreshTasksAndRedPoints()
  end
  
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:RegWatcher(self.refreshOrInitSevenDaysTargetRed_)
  
  function self.onFuncDataChange_(funcTable)
    local funcPreviewData = Z.DataMgr.Get("function_preview_data")
    funcPreviewData:refreshStateDict()
    if funcTable ~= nil then
      for funcId, isOpen in pairs(funcTable) do
        if (funcId == E.FunctionID.SeasonHandbook or funcId == E.FunctionID.SevendayTargetTitlePage or funcId == E.FunctionID.SevendayTargetManual) and isOpen then
          self:refreshTasksAndRedPoints()
          break
        end
      end
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  Z.ContainerMgr.CharSerialize.FunctionData.Watcher:RegWatcher(self.onFuncDataChange_)
end

function SevendaysTargetService:OnLogout()
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:UnregWatcher(self.refreshOrInitSevenDaysTargetRed_)
  Z.ContainerMgr.CharSerialize.FunctionData.Watcher:UnregWatcher(self.onFuncDataChange_)
  self.refreshOrInitSevenDaysTargetRed_ = nil
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  self.onFuncDataChange_ = nil
end

function SevendaysTargetService:OnEnterScene(sceneId)
end

function SevendaysTargetService:refreshTasksAndRedPoints()
  local vm = Z.VMMgr.GetVM("season_quest_sub")
  local sevendays_red_ = require("rednode.sevendays_target_red")
  local tasks_ = vm.GetTaskList(true)
  sevendays_red_.RefreshOrInitSevenDaysTargetRed(tasks_)
end

return SevendaysTargetService
