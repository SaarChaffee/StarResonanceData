local super = require("ui.service.service_base")
local WeaponService = class("WeaponService", super)
local bagRed = require("rednode.bag_red")

function WeaponService:OnInit()
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
end

function WeaponService:OnUnInit()
end

function WeaponService:OnLogin()
  function self.onContainerDataChange_(container, dirtyKeys)
    if not Z.StageMgr.GetIsInGameScene() then
      return
    end
    if dirtyKeys.professionList then
      for key, value in pairs(dirtyKeys.professionList) do
        if value:IsNew() then
          local professionSystemRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(key)
          if professionSystemRow then
            Z.DialogViewDataMgr:OpenNormalDialog(Lang("profession_unlock_tips_" .. key), function()
              local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
              talentSkillVM.OpenTalentSkillMainWindow(key)
              Z.DialogViewDataMgr:CloseDialogView()
            end)
          end
        end
      end
    end
    if dirtyKeys.curProfessionId then
      Z.VMMgr.GetVM("weapon_skill"):RefreshReplaceSkill()
    end
    if dirtyKeys.aoyiSkillInfoMap then
      self:CheckSkillRedDot()
      self:CheckMakeRedDot()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerDataChange_)
  
  function self.onRoleLevelChange_(container, dirtyKeys)
    if not Z.StageMgr.GetIsInGameScene() then
      return
    end
    self:checkResonanceAdvanceRedDot()
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.onRoleLevelChange_)
  
  function self.onFuncDataChange_(functionTabs)
    for functionId, isUnlock in pairs(functionTabs) do
      if functionId == E.FunctionID.WeaponAoyiSkill then
        if isUnlock then
          self:CheckSkillRedDot()
          self:CheckMakeRedDot()
        end
        break
      end
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function WeaponService:OnLogout()
  if self.onContainerDataChange_ then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerDataChange_)
    self.onContainerDataChange_ = nil
  end
  if self.onRoleLevelChange_ then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onRoleLevelChange_)
    self.onRoleLevelChange_ = nil
  end
  if self.onFuncDataChange_ then
    Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
    self.onFuncDataChange_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function WeaponService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:CheckSkillRedDot()
    self:CheckMakeRedDot()
    Z.VMMgr.GetVM("weapon_skill"):RefreshReplaceSkill()
  end
end

function WeaponService:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  self:CheckSkillRedDot()
  self:CheckMakeRedDot()
end

function WeaponService:CheckSkillRedDot()
  self:checkResonanceActiveRedDot()
  self:checkResonanceAdvanceRedDot()
end

function WeaponService:checkResonanceActiveRedDot()
  if not self.funcVM_.FuncIsOn(E.FunctionID.WeaponAoyiSkill, true) then
    return
  end
  local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
  local itemsVM = Z.VMMgr.GetVM("items")
  local skillDataList = weaponSkillVM:GetMysteriesSkillList()
  for _, skillInfo in ipairs(skillDataList) do
    local nodeId = weaponSkillVM:GetResonanceActiveRedDotId(skillInfo.Config.Id)
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponResonanceActive, E.RedType.WeaponResonanceDynamic, nodeId)
    local isShowRed = false
    if not skillInfo.IsUnlock then
      local config = skillInfo.Config
      if config.SkillAdvancedItem then
        local isCostEnough = true
        for i, v in ipairs(config.SkillAdvancedItem) do
          local haveNum = itemsVM.GetItemTotalCount(v[1])
          if haveNum < v[2] then
            isCostEnough = false
            break
          end
        end
        isShowRed = isCostEnough
      end
    end
    Z.RedPointMgr.RefreshServerNodeCount(nodeId, isShowRed and 1 or 0)
  end
end

function WeaponService:checkResonanceAdvanceRedDot()
  if not self.funcVM_.FuncIsOn(E.FunctionID.WeaponAoyiSkill, true) then
    return
  end
  local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
  local itemsVM = Z.VMMgr.GetVM("items")
  Z.RedPointMgr.ResetAllChildNodeCount(E.RedType.WeaponResonanceAdvance)
  local skillDataList = weaponSkillVM:GetMysteriesSkillList()
  for _, skillInfo in ipairs(skillDataList) do
    local nodeId = weaponSkillVM:GetResonanceAdvanceRedDotId(skillInfo.Config.Id)
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponResonanceAdvance, E.RedType.WeaponResonanceDynamic, nodeId)
    local isShowRed = false
    if skillInfo.IsUnlock then
      local config = skillInfo.Config
      if not weaponSkillVM:CheckResonanceSkillRemodelMax(config.Id) then
        local curAdvanceLevel = weaponSkillVM:GetSkillRemodelLevel(config.Id)
        local advanceConfig = weaponSkillVM:GetResonanceSkillRemodelRow(config.Id, curAdvanceLevel + 1)
        if advanceConfig and Z.ConditionHelper.CheckCondition(advanceConfig.UlockSkillLevel) then
          local isCostEnough = true
          for i, v in ipairs(advanceConfig.UpgradeCost) do
            local haveNum = itemsVM.GetItemTotalCount(v[1])
            if haveNum < v[2] then
              isCostEnough = false
              break
            end
          end
          isShowRed = isCostEnough
        end
      end
    end
    Z.RedPointMgr.RefreshServerNodeCount(nodeId, isShowRed and 1 or 0)
  end
end

function WeaponService:CheckMakeRedDot()
  bagRed.CheckResonanceItemRedDot()
end

return WeaponService
