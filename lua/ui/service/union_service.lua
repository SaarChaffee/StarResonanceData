local super = require("ui.service.service_base")
local UnionService = class("UnionService", super)
local unionRed_ = require("rednode.union_red")

function UnionService:OnInit()
end

function UnionService:OnUnInit()
end

function UnionService:OnLogin()
  self.quertDirty_ = false
  self:bindEvents()
  self:bindWatcher()
  unionRed_.Init()
end

function UnionService:OnLogout()
  self.quertDirty_ = false
  self:unbindEvents()
  self:unbindWatcher()
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  unionWarDanceData_:SetIsInDanceArea(false)
  unionWarDanceData_:SetRecommendRedChecked(false)
  unionRed_.UnInit()
  local unionData = Z.DataMgr.Get("union_data")
  unionData:SetHuntRecommendRedChecked(false)
end

function UnionService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  if subType == E.SceneSubType.Union then
    unionWarDanceVM:InitWatcher()
    unionWarDanceVM:ShowUnionWarDanceVibe(false)
    unionWarDanceVM:StartUnionWarDanceMusic(false)
  end
  if self.quertDirty_ then
    return
  end
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    local funcVM = Z.VMMgr.GetVM("gotofunc")
    if not funcVM.CheckFuncCanUse(E.UnionFuncId.Union, true) then
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
        self:InitRed()
      end
      self.quertDirty_ = true
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

return UnionService
