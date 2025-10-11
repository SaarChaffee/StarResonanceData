local super = require("ui.service.service_base")
local SDKReportService = class("SDKReportService", super)

function SDKReportService:OnInit()
end

function SDKReportService:OnUnInit()
end

function SDKReportService:OnLogin()
  function self.onContainerRoleLevelChange_(container, dirty)
    if dirty.level then
      local level = dirty.level.Get()
      
      if level == 19 then
        Z.SDKReport.Report(Z.SDKReportEvent.TutorialComplete)
      end
      Z.SDKReport.SetInfo("RoleLevel", tostring(level))
      Z.SDKReport.ReportLevelUp(level)
    end
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.onContainerRoleLevelChange_)
  
  function self.onContainerRoleNameChange_(container, dirty)
    if dirty.name then
      Z.SDKReport.SetInfo("RoleName", dirty.name.Get())
    end
  end
  
  Z.ContainerMgr.CharSerialize.charBase.Watcher:RegWatcher(self.onContainerRoleNameChange_)
  
  function self.currencyChangeFunc_(container, dirtyKeys)
    if dirtyKeys.currencyDatas then
      for k, _ in pairs(dirtyKeys.currencyDatas) do
        if k == Z.SystemItem.ItemDiamond then
          local curDiamond = Z.ContainerMgr.CharSerialize.itemCurrency.currencyDatas[Z.SystemItem.ItemDiamond]
          if curDiamond == nil then
            curDiamond = 0
          else
            curDiamond = curDiamond.count
          end
          local increasDiamon = curDiamond - Z.DataMgr.Get("sdk_report_data").CurGemCount
          Z.SDKReport.ReportDiamonIncreased(increasDiamon)
          Z.DataMgr.Get("sdk_report_data").CurGemCount = curDiamond
          return
        end
      end
    end
  end
  
  Z.ContainerMgr.CharSerialize.itemCurrency.Watcher:RegWatcher(self.currencyChangeFunc_)
  Z.DataMgr.Get("sdk_report_data"):ResetData()
end

function SDKReportService:OnLogout()
  if self.onContainerRoleLevelChange_ ~= nil then
    Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.onContainerRoleLevelChange_)
    self.onContainerRoleLevelChange_ = nil
  end
  if self.onContainerRoleNameChange_ ~= nil then
    Z.ContainerMgr.CharSerialize.charBase.Watcher:UnregWatcher(self.onContainerRoleNameChange_)
    self.onContainerRoleNameChange_ = nil
  end
  if self.currencyChangeFunc_ ~= nil then
    Z.ContainerMgr.CharSerialize.itemCurrency.Watcher:UnregWatcher(self.currencyChangeFunc_)
    self.currencyChangeFunc_ = nil
  end
end

function SDKReportService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    local curDiamond = Z.ContainerMgr.CharSerialize.itemCurrency.currencyDatas[Z.SystemItem.ItemDiamond]
    if curDiamond == nil then
      curDiamond = 0
    else
      curDiamond = curDiamond.count
    end
    Z.DataMgr.Get("sdk_report_data").CurGemCount = curDiamond
  end
end

function SDKReportService:OnSyncAllContainerData()
  Z.SDKReport.SetInfo("RoleName", Z.ContainerMgr.CharSerialize.charBase.name)
  Z.SDKReport.SetInfo("RoleLevel", Z.ContainerMgr.CharSerialize.roleLevel.level)
end

return SDKReportService
