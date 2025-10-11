local super = require("ui.service.service_base")
local SkillService = class("SkillService", super)
local skillRed = require("rednode.skill_red")

function SkillService:OnInit()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponData_ = Z.DataMgr.Get("weapon_data")
  self.professionVm_ = Z.VMMgr.GetVM("profession")
  
  function self.onProfessionChangeFunc(container, dirtyKeys)
    if dirtyKeys.curProfessionId then
      Z.EventMgr:Dispatch(Z.ConstValue.Hero.ChangeProfession, container.professionId)
      self.weaponData_:InitSlotSkill()
    end
    if dirtyKeys.professionList then
      for k, v in pairs(dirtyKeys.professionList) do
        if v:IsNew() then
          local professionInfo = Z.ContainerMgr.CharSerialize.professionList.professionList[k]
          professionInfo.Watcher:RegWatcher(self.onProfessionSkillChangeFunc)
          for _, value in pairs(professionInfo.skillInfoMap) do
            value.Watcher:RegWatcher(self.onSkillChangeFunc)
          end
        end
      end
    end
  end
  
  function self.onProfessionSkillChangeFunc(container, dirtyKeys)
    if dirtyKeys.activeSkillIds then
      for skillId, _ in pairs(dirtyKeys.skillInfoMap) do
        Z.EventMgr:Dispatch(Z.ConstValue.TalentSkill.UnLockSkill, skillId)
        local professionId = self.professionVm_:GetContainerProfession()
        local professionInfo = Z.ContainerMgr.CharSerialize.professionList.professionList[professionId]
        if professionInfo then
          professionInfo.skillInfoMap[skillId].Watcher:RegWatcher(self.onSkillChangeFunc)
        end
      end
    end
  end
  
  function self.onSkillChangeFunc(container, dirtyKeys)
    if dirtyKeys.level then
      self.weaponData_:UpdateSkillData(container.skillId, container.level)
      Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, container.skillId)
    end
    if dirtyKeys.remodelLevel then
      Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillRemodelSuccess, container.skillId)
    end
    if dirtyKeys.activeSkillSkins then
      Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillSkinUnlock)
    end
    if dirtyKeys.curSkillSkin then
      Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkillSkinChange)
    end
  end
  
  function self.onSlotChangeFunc(container, dirtyKeys)
    if dirtyKeys.slots then
      for slotId, _ in pairs(dirtyKeys.slots) do
        local skillId = self.weaponSkillVm_:GetSkillBySlot(slotId)
        local beforeSkillID = self.weaponData_:GetWeaponSlotSkill(slotId)
        if beforeSkillID ~= 0 then
          Z.EventMgr:Dispatch(Z.ConstValue.Hero.InstallSkill, beforeSkillID)
        end
        if skillId ~= 0 then
          Z.EventMgr:Dispatch(Z.ConstValue.Hero.InstallSkill, skillId)
        end
        self.weaponData_:UpdateSlotSkill(slotId, skillId)
      end
    end
  end
end

function SkillService:OnUnInit()
end

function SkillService:OnLogin()
  skillRed.Init()
end

function SkillService:OnLeaveScene()
end

function SkillService:OnLateInit()
  local skillVm = Z.VMMgr.GetVM("skill")
  skillVm.CacheSKillFightLevelTable()
end

function SkillService:OnLogout()
  skillRed.UnInit()
  for id, professionInfo in pairs(Z.ContainerMgr.CharSerialize.professionList.professionList) do
    for _, value in pairs(professionInfo.skillInfoMap) do
      value.Watcher:UnregWatcher(self.onSkillChangeFunc)
    end
    professionInfo.Watcher:UnregWatcher(self.onProfessionSkillChangeFunc)
  end
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onProfessionChangeFunc)
  Z.ContainerMgr.CharSerialize.slots.Watcher:UnregWatcher(self.onSlotChangeFunc)
end

function SkillService:OnEnterScene(sceneId)
end

function SkillService:OnSyncAllContainerData()
  for id, professionInfo in pairs(Z.ContainerMgr.CharSerialize.professionList.professionList) do
    professionInfo.Watcher:RegWatcher(self.onProfessionSkillChangeFunc)
    for _, value in pairs(professionInfo.skillInfoMap) do
      value.Watcher:RegWatcher(self.onSkillChangeFunc)
    end
  end
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onProfessionChangeFunc)
  Z.ContainerMgr.CharSerialize.slots.Watcher:RegWatcher(self.onSlotChangeFunc)
  self.weaponData_:InitSlotSkill()
end

return SkillService
