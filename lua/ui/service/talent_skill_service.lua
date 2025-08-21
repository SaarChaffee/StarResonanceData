local super = require("ui.service.service_base")
local TalentSkillService = class("TalentSkillService", super)

function TalentSkillService:OnInit()
end

function TalentSkillService:OnUnInit()
end

function TalentSkillService:OnLogin()
  function self.onContainerChanged(container, dirty)
    if dirty.curProfessionId then
      self:checkRedDot()
    end
    if dirty.professionList then
      self:checkRedDot()
    end
    if dirty.talentList then
      self:checkRedDot()
      Z.VMMgr.GetVM("weapon_skill"):RefreshReplaceSkill()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
  
  function self.onFuncDataChange_(functionTabs)
    for functionId, isUnlock in pairs(functionTabs) do
      if functionId == E.FunctionID.Talent then
        self:checkRedDot()
        break
      end
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  
  function self.onLevelContainerChanged(container, dirty)
    self:checkRedDot()
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.onLevelContainerChanged)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
  self.timeInited_ = false
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
end

function TalentSkillService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
  self.timeInited_ = false
  self.needCheckRed = false
  if self.onContainerChanged ~= nil then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
    self.onContainerChanged = nil
  end
  if self.onFuncDataChange_ ~= nil then
    Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
    self.onFuncDataChange_ = nil
  end
  if self.onLevelContainerChanged ~= nil then
    Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.onLevelContainerChanged)
    self.onLevelContainerChanged = nil
  end
end

function TalentSkillService:OnSyncAllContainerData()
end

function TalentSkillService:onTimerInited()
  self.timeInited_ = true
  if self.needCheckRed then
    self:checkRedDot()
  end
end

function TalentSkillService:onTimerUnInited()
  self.timeInited_ = false
end

function TalentSkillService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:checkRedDot()
  end
end

function TalentSkillService:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Currency) or itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Item) or itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.SpecialItem) then
    self:checkRedDot()
  end
end

function TalentSkillService:checkRedDot()
  self.needCheckRed = true
  if not self.timeInited_ then
    return
  end
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  local talentTreeRed = talentSkillVM.CheckTalentTreeRed()
  if talentSkillVM.CheckRed() or talentTreeRed then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.TalentTab, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.TalentTab, 0)
  end
  if talentTreeRed then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.TalentTree, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.TalentTree, 0)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.TalentSkill.TalentWeaponChange)
end

return TalentSkillService
