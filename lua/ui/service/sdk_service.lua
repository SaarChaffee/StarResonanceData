local super = require("ui.service.service_base")
local SDKService = class("SDKService", super)
local SDK_DEFINE = require("ui.model.sdk_define")
local charactorProxy = require("zproxy.grpc_charactor_proxy")

function SDKService:OnInit()
  self:initWakeUpDataDeal()
end

function SDKService:OnUnInit()
end

function SDKService:OnLogin()
  self:initEvaluationListener()
  self:registWakeUpDataDeal()
  self.sdkReport_ = false
end

function SDKService:OnLogout()
  self:uninitEvaluationListener()
  self:unRegistWakeUpDataDeal()
  self.sdkReport_ = false
end

function SDKService:OnEnterScene()
  self:APJSynvRoleInfo()
end

function SDKService:APJSynvRoleInfo()
  if Z.SDKLogin.GetPlatform() ~= E.LoginPlatformType.APJPlatform then
    return
  end
  if self.sdkReport_ ~= nil and self.sdkReport_ ~= true then
    local charName = Z.ContainerMgr.CharSerialize.charBase.name
    if charName == nil then
      return
    end
    local charLevel = Z.ContainerMgr.CharSerialize.roleLevel.level
    local serverId = Z.DataMgr.Get("server_data").NowSelectServerId
    local charId = Z.ContainerMgr.CharSerialize.charId
    Z.SDKAPJ.SyncRoleInfo(serverId, charId, charName, charLevel)
    Z.SDKAPJ.SetQueryProductsUrl("https://pay-query.playbpsr.com:7779/api/query/QueryProductInfo")
    self.sdkReport_ = true
  end
end

function SDKService:initEvaluationListener()
  Z.EventMgr:Add(Z.ConstValue.Quest.Finish, self.onQuestFinish, self)
  self.targetEvaluationQuestId_ = 0
  local cond = Z.Global.TapEvaluationCondition
  if cond == nil or cond == "" then
    return
  end
  local condSplit = string.split(cond, "=")
  if 2 <= #condSplit and tonumber(condSplit[1]) == E.ConditionType.TaskOver then
    self.targetEvaluationQuestId_ = tonumber(condSplit[2]) or 0
  end
end

function SDKService:uninitEvaluationListener()
  Z.EventMgr:Remove(Z.ConstValue.Quest.Finish, self.onQuestFinish, self)
end

function SDKService:onQuestFinish(questId)
  if questId and questId == self.targetEvaluationQuestId_ then
    local condSplit = string.split(Z.Global.TapEvaluationCondition, "=")
    local param = {}
    for i = 2, #condSplit do
      param[i - 1] = tonumber(condSplit[i])
    end
    if Z.ConditionHelper.CheckSingleCondition(E.ConditionType.TaskOver, false, table.unpack(param)) then
      self:evaluationSwitchHandler()
    end
  end
end

function SDKService:evaluationSwitchHandler()
  local sdkVM = Z.VMMgr.GetVM("sdk")
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if Z.SDKDevices.RuntimeOS == E.OS.iOS then
    if gotoFuncVM.CheckFuncCanUse(E.FunctionID.AppleStoreEvaluation, true) then
      sdkVM:OpenAppleStoreEvaluationPopup()
    end
  elseif Z.SDKDevices.RuntimeOS == E.OS.Android and tonumber(Z.SDKTencent.InstallChannel) == SDK_DEFINE.SDK_CHANNEL_ID.TapTap and gotoFuncVM.CheckFuncCanUse(E.FunctionID.TapTapEvaluation, true) then
    sdkVM:OpenTaptapEvaluationPopup()
  end
end

function SDKService:initWakeUpDataDeal()
  function self.wakeUpFunc_(wakeUpEventArgs)
    local extraJSON = wakeUpEventArgs.Extra
    
    if extraJSON then
      logGreen("TencentService WakeUp ExtraJson " .. extraJSON)
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local sdkVM = Z.VMMgr.GetVM("sdk")
      local sdkData = Z.DataMgr.Get("sdk_data")
      local request = {
        launchParam = sdkVM.DeserializeWakeUpData(wakeUpEventArgs)
      }
      local ret = charactorProxy.PrivilegeActivate(request, sdkData.CancelSource:CreateToken())
      if ret then
        if ret.errCode ~= 0 then
          Z.TipsVM.ShowTips(ret.errCode)
          Z.SDKTencent.CleanLastWakeUpData()
          return
        elseif ret.isChangeAccount then
          Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameNormal, E.ESysDialogGameNormalOrder.TencentChangeAccount, nil, Lang("QQGameStartOtherAccountTipsDes"), function()
            Z.SDKTencent.GetLastWakeUpData().ShouldSwitchAccount = true
            Z.VMMgr.GetVM("login"):Logout(true)
          end, function()
            Z.SDKTencent.CleanLastWakeUpData()
          end, true)
        else
          Z.EventMgr:Dispatch(Z.ConstValue.SDK.TencentPrivilegeRefresh, ret.isPrivilege)
          Z.SDKTencent.CleanLastWakeUpData()
        end
      else
        Z.SDKTencent.CleanLastWakeUpData()
      end
    end)()
  end
end

function SDKService:registWakeUpDataDeal()
  if Z.VMMgr.GetVM("sdk").IsNeedRegistWakeUpDataDeal() then
    Z.SDKTencent.RegistOnWakeUpHandler(self.wakeUpFunc_)
  end
end

function SDKService:unRegistWakeUpDataDeal()
  if Z.VMMgr.GetVM("sdk").IsNeedRegistWakeUpDataDeal() then
    Z.SDKTencent.CleanOnWakeUpHandler()
  end
end

return SDKService
