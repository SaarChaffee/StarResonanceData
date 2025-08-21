local super = require("ui.service.service_base")
local LifeProfessionService = class("LifeProfessionService", super)

function LifeProfessionService:OnInit()
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionRed = require("rednode.life_profession_red")
  Z.EventMgr:Add(Z.ConstValue.OnConditionChanged, self.onConditionChanged, self)
  self.regBasicInfoIDs = {}
  self.regTargetIDs = {}
  
  function self.basicInfoChangeFunc(container, dirtys)
    if dirtys.level then
      self.lifeProfessionVM_.ShowProLevelUp(container.id, container.level)
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, container.id)
    end
    if dirtys.exp then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionExpChanged, container.id)
    end
    if dirtys.specialization then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, container.id)
    end
  end
  
  function self.targetInfoChangeFunc(container, dirtys)
    if dirtys.value then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionTargetLevelChanged, container.id)
    end
    if dirtys.lifeTargetRewardStates then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionTargetStateChanged, container.id)
    end
  end
  
  function self.basicInfoMapChangeFunc(container, dirtys)
    if dirtys.professionInfo then
      for k, lifeProfessionBasic in pairs(container.professionInfo) do
        if not table.zcontains(self.regBasicInfoIDs, k) then
          table.insert(self.regBasicInfoIDs, k)
          if lifeProfessionBasic.level == 1 then
            self.lifeProfessionVM_.ShowProLevelUp(lifeProfessionBasic.id, lifeProfessionBasic.level)
            Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, lifeProfessionBasic.id)
            Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionUnlocked, lifeProfessionBasic.id)
          end
          lifeProfessionBasic.Watcher:RegWatcher(self.basicInfoChangeFunc)
        end
      end
    end
    if dirtys.lifeTargetInfo then
      for k, lifeProfessionTargetInfo in pairs(container.lifeTargetInfo) do
        if not table.zcontains(self.regTargetIDs, k) then
          table.insert(self.regTargetIDs, k)
          lifeProfessionTargetInfo.Watcher:RegWatcher(self.targetInfoChangeFunc)
        end
      end
    end
    if dirtys.lifeProfessionRecipe then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionRecipeChanged)
    end
    if dirtys.point then
      Z.EventMgr:Dispatch(Z.ConstValue.LifeProfession.LifeProfessionPointChanged)
    end
  end
end

function LifeProfessionService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.OnConditionChanged, self.onConditionChanged, self)
end

function LifeProfessionService:onConditionChanged(conditionType)
  self.lifeProfessionVM_.CheckHasNewRecipe(conditionType)
end

function LifeProfessionService:OnLogin()
end

function LifeProfessionService:OnLogout()
  self:UninitContainerWatcher()
  self.lifeProfessionRed.UnInit()
end

function LifeProfessionService:OnSyncAllContainerData()
  self.lifeProfessionVM_.SetAllLockedRecipe()
  self:InitContainerWatcher()
  self.lifeProfessionRed.Init()
end

function LifeProfessionService:OnReconnect()
end

function LifeProfessionService:OnEnterScene()
end

function LifeProfessionService:InitContainerWatcher()
  self:UninitContainerWatcher()
  Z.ContainerMgr.CharSerialize.lifeProfession.Watcher:RegWatcher(self.basicInfoMapChangeFunc)
  for k, lifeProfessionBasic in pairs(Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo) do
    if not table.zcontains(self.regBasicInfoIDs, k) then
      table.insert(self.regBasicInfoIDs, k)
      lifeProfessionBasic.Watcher:RegWatcher(self.basicInfoChangeFunc)
    end
  end
  for k, lifeProfessionTargetInfo in pairs(Z.ContainerMgr.CharSerialize.lifeProfession.lifeTargetInfo) do
    if not table.zcontains(self.regTargetIDs, k) then
      table.insert(self.regTargetIDs, k)
      lifeProfessionTargetInfo.Watcher:RegWatcher(self.targetInfoChangeFunc)
    end
  end
end

function LifeProfessionService:UninitContainerWatcher()
  self.regBasicInfoIDs = {}
  self.regTargetIDs = {}
  Z.ContainerMgr.CharSerialize.lifeProfession.Watcher:UnregWatcher(self.basicInfoMapChangeFunc)
  for k, lifeProfessionBasic in pairs(Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo) do
    lifeProfessionBasic.Watcher:UnregWatcher(self.basicInfoChangeFunc)
  end
  for k, lifeProfessionTargetInfo in pairs(Z.ContainerMgr.CharSerialize.lifeProfession.lifeTargetInfo) do
    lifeProfessionTargetInfo.Watcher:UnregWatcher(self.targetInfoChangeFunc)
  end
end

return LifeProfessionService
