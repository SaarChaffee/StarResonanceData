local super = require("ui.service.service_base")
local FashionService = class("FashionService", super)
local fashionRed = require("rednode.fashion_red")
local onFashionBenefitChange = function(container, dirtyKeys)
  fashionRed.CheckFashionBenefitLastRewardRed()
  Z.EventMgr:Dispatch(Z.ConstValue.Collection.FashionBenefitChange)
end
local onFashionSettingChange = function(container, dirtyKeys)
  local fashionVM = Z.VMMgr.GetVM("fashion")
  fashionVM.RefreshWearAttr()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSettingChange)
end
local onFashionAdd = function(container, dirtyKeys)
  if not dirtyKeys.allFashion then
    return
  end
  for fashionId, _ in pairs(dirtyKeys.allFashion) do
    fashionRed.AddNewFashionRed(fashionId)
  end
end
local onFuncDataChange = function(functionTabs)
  for functionId, isUnlock in pairs(functionTabs) do
    if isUnlock and functionId == E.FunctionID.CollectionReward then
      fashionRed.CheckFashionCollectionPointReward()
    end
    if isUnlock and functionId == E.FunctionID.CollectionVipLevel then
      fashionRed.CheckFashionBenefitLastRewardRed()
    end
  end
end
local onProfessionChange = function()
  fashionRed.RefreshWeaponSkinRed()
end

function FashionService:OnInit()
end

function FashionService:OnUnInit()
end

function FashionService:OnLogin()
  fashionRed.Init()
  Z.ContainerMgr.CharSerialize.fashionBenefit.Watcher:RegWatcher(onFashionBenefitChange)
  Z.ContainerMgr.CharSerialize.settingData.Watcher:RegWatcher(onFashionSettingChange)
  Z.ContainerMgr.CharSerialize.fashion.Watcher:RegWatcher(onFashionAdd)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, onFuncDataChange)
  Z.EventMgr:Add(Z.ConstValue.Hero.ChangeProfession, onProfessionChange)
end

function FashionService:OnSyncAllContainerData()
  fashionRed.InitFashionCustomRed()
  fashionRed.CheckFashionCollectionPointReward()
  fashionRed.CheckFashionBenefitLastRewardRed()
  self:registerWeaponSkinUnlock()
end

function FashionService:OnLogout()
  Z.ContainerMgr.CharSerialize.fashionBenefit.Watcher:UnregWatcher(onFashionBenefitChange)
  Z.ContainerMgr.CharSerialize.settingData.Watcher:UnregWatcher(onFashionSettingChange)
  Z.ContainerMgr.CharSerialize.fashion.Watcher:UnregWatcher(onFashionAdd)
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, onFuncDataChange)
  Z.EventMgr:Remove(Z.ConstValue.Hero.ChangeProfession, onProfessionChange)
  fashionRed.UnInit()
  self:unRegisterWeaponSkinUnlock()
end

function FashionService:registerWeaponSkinUnlock()
  local weaponSkinData = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetDatas()
  for _, value in pairs(weaponSkinData) do
    if value.IsOpen then
      Z.ItemEventMgr.RegisterNewEvent(E.ItemAddEventType.ItemId, value.Id, fashionRed.AddNewWeaponSkinRed)
    end
  end
end

function FashionService:unRegisterWeaponSkinUnlock()
  local weaponSkinData = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetDatas()
  for _, value in pairs(weaponSkinData) do
    Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemChangeType.Add, E.ItemAddEventType.ItemId, value.Id)
  end
end

function FashionService:OnReconnect()
end

function FashionService:OnEnterScene()
end

return FashionService
