local super = require("ui.service.service_base")
local UnionService = class("UnionService", super)
local unionRed_ = require("rednode.union_red")
local SDK_DEFINE = require("ui.model.sdk_define")
local TENCENT_DEFINE = require("ui.model.tencent_define")
local SDK_GROUP_EVENT_TYPE = Panda.SDK.Tencent.GroupEventType

function UnionService:OnInit()
end

function UnionService:OnUnInit()
end

function UnionService:OnLogin()
  self.queryDirty_ = false
  self:bindEvents()
  self:bindWatcher()
  self:initSDKGroup()
  unionRed_.Init()
end

function UnionService:OnLogout()
  self.queryDirty_ = false
  self:unbindEvents()
  self:unbindWatcher()
  self:uninitSDKGroup()
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  unionWarDanceData_:SetIsInDanceArea(false)
  unionWarDanceData_:SetRecommendRedChecked(false)
  unionRed_.UnInit()
  local unionData = Z.DataMgr.Get("union_data")
  unionData:SetHuntRecommendRedChecked(false)
  unionData:SetSignRecommendRedChecked(false)
end

function UnionService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  if subType == E.SceneSubType.Union then
    unionWarDanceVM:InitWatcher()
    unionWarDanceVM:ShowUnionWarDanceVibe()
    unionWarDanceVM:StartUnionWarDanceMusic(false)
  end
  if self.queryDirty_ then
    return
  end
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    local funcVM = Z.VMMgr.GetVM("gotofunc")
    if not funcVM.FuncIsOn(E.UnionFuncId.Union, true) then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local unionVM = Z.VMMgr.GetVM("union")
      local unionData = Z.DataMgr.Get("union_data")
      unionVM:AsyncReqUnionInfo(0, unionData.CancelSource:CreateToken())
      local unionId = unionVM:GetPlayerUnionId()
      if unionId ~= 0 then
        unionVM:AsyncReqUnionMemsList(unionId, unionData.CancelSource:CreateToken())
        unionVM:AsyncGetUnlockUnionSceneData(unionData.CancelSource:CreateToken())
        if funcVM.FuncIsOn(E.FunctionID.TencentGroup, true) then
          unionVM:CallGetGroupRelation()
        end
        self:InitRed()
      end
      self.queryDirty_ = true
      local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
      if unionWarDanceVM:isInWarDanceActivity() then
        unionWarDanceVM:NoticeActivityOpen()
      end
      if unionWarDanceVM:isinWillOpenWarDanceActivity() then
        unionWarDanceVM:NoticeActivityWillOpen()
      end
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionDataReady)
    end)()
  end
end

function UnionService:OnLeaveScene()
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  unionWarDanceVM:UnInitWatcher()
  unionWarDanceVM:HideUnionWarDanceVibe()
  unionWarDanceVM:EndUnionWarDanceMusic()
end

function UnionService:InitRed()
  unionRed_.InitUnionActiveItemRed()
  unionRed_.InitUnionBuildingItemRed()
  unionRed_.RefreshHuntRecommendRed()
  unionRed_.RefreshDanceRecommendRed()
end

function UnionService:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionActiveRewardInfoChange, self.onUnionActiveRewardInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnion, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.LeaveUnion, self.onLeaveUnion, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionMemberPositionChange, self.onUnionMemberPositionChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionSceneUnLock, self.onUnionSceneUnLock, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionSceneUnlockRedRefresh, self.onUnionSceneUnlockRedRefresh, self)
end

function UnionService:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionActiveRewardInfoChange, self.onUnionActiveRewardInfoChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnion, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.LeaveUnion, self.onLeaveUnion, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionMemberPositionChange, self.onUnionMemberPositionChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionSceneUnLock, self.onUnionSceneUnLock, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionSceneUnlockRedRefresh, self.onUnionSceneUnlockRedRefresh, self)
end

function UnionService:bindWatcher()
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(self.onHuntCountChange)
end

function UnionService:unbindWatcher()
  Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(self.onHuntCountChange)
end

function UnionService:onHuntCountChange()
  unionRed_.RefreshHuntRecommendRed()
  unionRed_.RefreshDanceRecommendRed()
end

function UnionService:onUnionResourceChange()
  unionRed_.RefreshUnionActiveItemRed()
  unionRed_.RefreshUnionBuildingItemRed()
end

function UnionService:onUnionSceneUnLock()
  unionRed_.RefreshUnionBuildingItemRed(true)
  unionRed_.CheckUnionSceneUnlockRed()
end

function UnionService:onUnionSceneUnlockRedRefresh()
  unionRed_.CheckUnionSceneUnlockRed()
end

function UnionService:onUnionActiveRewardInfoChange()
  unionRed_.RefreshUnionActiveItemRed()
end

function UnionService:onUnionBuildInfoChange()
  unionRed_.RefreshUnionBuildingItemRed()
end

function UnionService:onJoinUnion()
  self:InitRed()
end

function UnionService:onLeaveUnion()
  unionRed_.RefreshUnionActiveItemRed()
  unionRed_.RefreshUnionBuildingItemRed()
  unionRed_.CheckUnionSceneUnlockRed()
end

function UnionService:onUnionMemberPositionChange()
  unionRed_.RefreshUnionBuildingItemRed()
end

function UnionService:onOpenPrivateChat()
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:CloseAllUnionView()
end

function UnionService:initSDKGroup()
  local unionVM = Z.VMMgr.GetVM("union")
  if not Z.GameContext.IsPlayInMobile then
    return
  end
  if not unionVM:CheckSDKGroupValid() then
    return
  end
  
  function self.onGetGroupStateAction_(args)
    return self:onGetGroupState(args)
  end
  
  function self.onGetGroupRelationAction_(args)
    return self:onGetGroupRelation(args)
  end
  
  function self.onCreateGroupAction_(args)
    return self:onCreateGroup(args)
  end
  
  function self.onJoinGroupAction_(args)
    return self:onJoinGroup(args)
  end
  
  function self.onBindGroupAction_(args)
    return self:onBindGroup(args)
  end
  
  function self.onUnbindGroupAction_(args)
    return self:onUnbindGroup(args)
  end
  
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnGetGroupState, self.onGetGroupStateAction_)
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnGetGroupRelation, self.onGetGroupRelationAction_)
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnCreateGroup, self.onCreateGroupAction_)
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnJoinGroup, self.onJoinGroupAction_)
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnBindGroup, self.onBindGroupAction_)
  Z.SDKTencent.RegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnUnbindGroup, self.onUnbindGroupAction_)
end

function UnionService:uninitSDKGroup()
  local unionVM = Z.VMMgr.GetVM("union")
  if not Z.GameContext.IsPlayInMobile then
    return
  end
  if not unionVM:CheckSDKGroupValid() then
    return
  end
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnGetGroupState, self.onGetGroupStateAction_)
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnGetGroupRelation, self.onGetGroupRelationAction_)
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnCreateGroup, self.onCreateGroupAction_)
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnJoinGroup, self.onJoinGroupAction_)
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnBindGroup, self.onBindGroupAction_)
  Z.SDKTencent.UnRegisterGroupEventHandler(SDK_GROUP_EVENT_TYPE.OnUnbindGroup, self.onUnbindGroupAction_)
  self.onGetGroupStateAction_ = nil
  self.onGetGroupRelationAction_ = nil
  self.onCreateGroupAction_ = nil
  self.onJoinGroupAction_ = nil
  self.onBindGroupAction_ = nil
  self.onUnbindGroupAction_ = nil
end

function UnionService:checkSDKGroupRet(retCode, thirdCode, ShowTips)
  if retCode == nil then
    return false
  end
  if retCode == 0 then
    return true
  else
    if thirdCode and thirdCode ~= 0 and ShowTips then
      local messageId
      local accountData = Z.DataMgr.Get("account_data")
      if accountData.LoginType == E.LoginType.QQ then
        messageId = TENCENT_DEFINE.GROUP_QQ_RET_MESSAGE[thirdCode]
      elseif accountData.LoginType == E.LoginType.WeChat then
        messageId = TENCENT_DEFINE.GROUP_WECHAT_RET_MESSAGE[thirdCode]
      end
      if messageId then
        Z.TipsVM.ShowTips(messageId)
      else
        Z.TipsVM.ShowTips(TENCENT_DEFINE.GROUP_COMMON_RET_MESSAGE, {errCode = thirdCode})
      end
    end
    logError("[Union SDK Group] SDK RetCode = {0}, thirdCode = {1}", retCode, thirdCode or 0)
    return false
  end
end

function UnionService:onGetGroupState(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData.SDKGroupInfo.BindState = args.Status or 0
    unionData.SDKGroupInfo.GroupId = args.GroupId or ""
    unionData.SDKGroupInfo.GroupName = args.GroupName or ""
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupState)
  end
end

function UnionService:onGetGroupRelation(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData.SDKGroupInfo.GroupRelation = args.Status or 0
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupRelation)
  end
end

function UnionService:onCreateGroup(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret, true) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData.SDKGroupInfo.GroupId = args.GroupId or ""
    unionData.SDKGroupInfo.GroupName = args.GroupName or ""
    local accountData = Z.DataMgr.Get("account_data")
    if accountData.LoginType == E.LoginType.QQ then
      Z.TipsVM.ShowTips(160138)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnCreateGroup)
  end
end

function UnionService:onJoinGroup(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret, true) then
    local accountData = Z.DataMgr.Get("account_data")
    if accountData.LoginType == E.LoginType.QQ then
      Z.TipsVM.ShowTips(160139)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnJoinGroup)
  end
end

function UnionService:onBindGroup(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret) then
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnBindGroup)
  end
end

function UnionService:onUnbindGroup(args)
  if args == nil then
    return
  end
  if self:checkSDKGroupRet(args.RetCode, args.Ret) then
    Z.EventMgr:Dispatch(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnUnbindGroup)
  end
end

return UnionService
