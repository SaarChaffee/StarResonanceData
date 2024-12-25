local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_develop_skill_subView = class("Weapon_develop_skill_subView", super)
local itemClass = require("common.item_binder")

function Weapon_develop_skill_subView:ctor()
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_skill_sub", "weapon_develop/weapon_develop_skill_sub", UI.ECacheLv.None)
end

function Weapon_develop_skill_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.selectType_ = 1
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.skillVm_ = Z.VMMgr.GetVM("skill")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.itemUnits_ = {}
  self.itemClassTab_ = {}
  self.selectSkillId_ = self.viewData.skillId
  self.selectReplaceId_ = self.weaponSkillVm_:GetReplaceSkillId(self.selectSkillId_)
  self.professionId_ = self.viewData.professionId
  self:AddAsyncClick(self.uiBinder.btn_remodel, function()
    if self.weaponSkillVm_:ChechSkillRemodelMax(self.selectSkillId_) then
      return
    end
    self.weaponSkillVm_:OpenSkillRemodelPopUp(self.selectSkillId_)
  end)
  self:AddAsyncClick(self.uiBinder.btn_remodel_binder_unlock.btn, function()
    Z.TipsVM.ShowTips(130034)
  end)
  self:AddAsyncClick(self.uiBinder.btn_upgrade_binder_unlock.btn, function()
    Z.TipsVM.ShowTips(130034)
  end)
  self:AddAsyncClick(self.uiBinder.btn_upgrade, function()
    if self.weaponSkillVm_:GetSkillMaxlevel(self.selectSkillId_) == self.selectSkillLevel_ then
      Z.TipsVM.ShowTips(130033)
      return
    end
    if not self.weaponSkillVm_:CheckIsAchievementSkillConditions(self.selectSkillId_, self.selectSkillLevel_ + 1, true) then
      return
    end
    local viewData = {}
    viewData.skillType = self.viewData.skillType
    viewData.skillId = self.selectSkillId_
    viewData.professionId = self.professionId_
    viewData.skillLevel = self.weaponVm_.GetShowSkillLevel(self.professionId_, self.selectSkillId_)
    self.weaponSkillVm_:OpenSkillLevelUpView(viewData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_unlock, function()
    local talentSkillVm = Z.VMMgr.GetVM("talent_skill")
    talentSkillVm.UnlockWeaponSkill(self.professionId_, self.selectSkillId_, self.cancelSource:CreateToken())
  end)
  self.skillDataUnits = {}
  self.tagUnitsName_ = {}
  self.subTipsIdList_ = {}
  self:BindEvents()
end

function Weapon_develop_skill_subView:BindEvents()
  function self.onContainerChanged(container, dirty)
    if dirty.weaponList or dirty.aoyiSkillInfoMap then
      self.selectSkillId_ = self.viewData.skillId
      
      self.professionId_ = self.viewData.professionId
      self:refreshTitle()
      self:refreshSkillDesc()
      self:refreshBtnLvUp()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.UnLockSkill, function()
    local viewData = {
      viewType = E.UpgradeType.WeaponSkillUnlock,
      skillId = self.selectSkillId_
    }
    self.weaponVm_.OpenUpgradeView(viewData)
    self:refreshTitle()
    self:refreshSkillDesc()
    self:refreshBtnLvUp()
  end, self)
end

function Weapon_develop_skill_subView:OnRefresh()
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.btn_upgrade.transform, self)
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.btn_remodel.transform, self)
  Z.RedPointMgr.RemoveChildernNodeItem(self.uiBinder.btn_unlock.transform, self)
  self.selectSkillId_ = self.viewData.skillId
  self.selectReplaceId_ = self.weaponSkillVm_:GetReplaceSkillId(self.selectSkillId_)
  local remouldNodeId = self.weaponSkillVm_:GetSkillRemouldRedId(self.selectSkillId_)
  local upNodeId = self.weaponSkillVm_:GetSkillUpRedId(self.selectSkillId_)
  local unlockNodeId = self.weaponSkillVm_:GetSkillUnlockRedId(self.selectSkillId_)
  Z.RedPointMgr.LoadRedDotItem(upNodeId, self, self.uiBinder.btn_upgrade.transform)
  Z.RedPointMgr.LoadRedDotItem(remouldNodeId, self, self.uiBinder.btn_remodel.transform)
  Z.RedPointMgr.LoadRedDotItem(unlockNodeId, self, self.uiBinder.btn_unlock.transform)
  self.professionId_ = self.viewData.professionId
  self:refreshTitle()
  self:refreshSkillDesc()
  self:refreshBtnLvUp()
end

function Weapon_develop_skill_subView:refreshTitle()
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.selectReplaceId_)
  if config == nil then
    return
  end
  self.selectSkillLevel_ = self.weaponVm_.GetShowSkillLevel(self.professionId_, self.selectReplaceId_)
  local maxLevel = self.weaponSkillVm_:GetSkillMaxlevel(self.selectReplaceId_)
  self.uiBinder.lab_title.text = config.Name
  self.uiBinder.lab_grade.text = Lang("Lv") .. self.selectSkillLevel_ .. "/" .. maxLevel
  local skillFightData = self.weaponSkillVm_:GetSkillFightDataById(self.selectReplaceId_)
  local skillFightLvTblData = skillFightData[self.selectSkillLevel_]
  local skillAttrDescList
  local remodelLevel = self.weaponSkillVm_:GetSkillRemodelLevel(self.selectReplaceId_)
  if skillFightLvTblData ~= nil and skillFightLvTblData.Id ~= nil then
    skillAttrDescList = self.skillVm_.GetSkillDecs(skillFightLvTblData.Id, remodelLevel)
  end
end

function Weapon_develop_skill_subView:refreshBtnLvUp()
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.selectSkillId_)
  if skillRow == nil then
    return
  end
  local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(self.selectSkillId_)
  local unLock = self.weaponSkillVm_:CheckSkillUnlock(self.selectSkillId_, self.professionId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, not unLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_remodel, unLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_upgrade, unLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_cost, not unLock)
  self.uiBinder.btn_upgrade_binder_unlock.Ref.UIComp:SetVisible(false)
  self.uiBinder.btn_remodel_binder_unlock.Ref.UIComp:SetVisible(false)
  if unLock then
    if self.weaponSkillVm_:GetSkillMaxlevel(self.selectSkillId_) == self.selectSkillLevel_ then
      self.uiBinder.btn_upgrade.IsDisabled = true
      self.uiBinder.btn_upgrade_binder.lab_normal.text = Lang("skillFullLevel")
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_upgrade, true)
      self.uiBinder.btn_upgrade_binder_unlock.Ref.UIComp:SetVisible(false)
    else
      self.uiBinder.btn_upgrade.IsDisabled = false
      self.uiBinder.btn_upgrade_binder.lab_normal.text = Lang("levelUp")
      local achieve, condition = self.weaponSkillVm_:CheckIsAchievementSkillConditions(self.selectSkillId_, self.selectSkillLevel_ + 1)
      if not achieve then
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_upgrade, true)
        self.uiBinder.btn_upgrade_binder_unlock.Ref.UIComp:SetVisible(false)
        local bResult, unlockDesc, progress = Z.ConditionHelper.GetSingleConditionDesc(condition[1], condition[2])
        if condition[1] == E.ConditionType.Level then
          self.uiBinder.btn_upgrade_binder.lab_normal.text = Lang("rolelv_skill_upgrade", {
            val = condition[2]
          })
        elseif condition[1] == E.ConditionType.OpenServerDay then
          self.uiBinder.btn_upgrade_binder.lab_normal.text = Lang("server_skill_upgarde", {val = progress})
        else
          self.uiBinder.btn_upgrade_binder.lab_normal.text = unlockDesc
        end
      end
      self.uiBinder.node_viewport.offsetMin = Vector2.New(0, 0)
    end
  else
    local skillUpgradeRow = self.weaponSkillVm_:GetLevelUpSkilllRow(upgradeId, 1)
    self.uiBinder.btn_unlock_binder.lab_normal.text = Lang("UnLock")
    for _, value in ipairs(skillUpgradeRow.UnlockConditions) do
      if not Z.ConditionHelper.CheckSingleCondition(value[1], false, value[2]) then
        local bResult, unlockDesc, progress = Z.ConditionHelper.GetSingleConditionDesc(value[1], value[2])
        if value[1] == E.ConditionType.Level then
          self.uiBinder.btn_unlock_binder.lab_normal.text = Lang("NeedPlayerLevel", {
            val = value[2]
          })
          break
        end
        if value[1] == E.ConditionType.OpenServerDay then
          self.uiBinder.btn_unlock_binder.lab_normal.text = Lang("UnlockAfterNumberDay", {val = progress})
          break
        end
        self.uiBinder.btn_unlock_binder.lab_normal.text = unlockDesc
        break
      end
    end
    self:refreshUnlockInfo()
  end
  if unLock then
    if self.weaponSkillVm_:ChechSkillRemodelMax(self.selectSkillId_) then
      self.uiBinder.btn_remodel.IsDisabled = true
      self.uiBinder.btn_remodel_binder.lab_normal.text = Lang("skillFullRemodel")
    else
      self.uiBinder.btn_remodel.IsDisabled = false
      self.uiBinder.btn_remodel_binder.lab_normal.text = Lang("Remodel")
      local nowRemodellv = self.weaponSkillVm_:GetSkillRemodelLevel(self.selectSkillId_)
      local nowRemodelRow = self.weaponSkillVm_:GetSkillRemodelRow(self.selectSkillId_, nowRemodellv + 1)
      if nowRemodelRow and nowRemodelRow.UlockSkillLevel then
        local conditionEnough = Z.ConditionHelper.CheckCondition(nowRemodelRow.UlockSkillLevel)
        if not conditionEnough then
          for _, condition in ipairs(nowRemodelRow.UlockSkillLevel) do
            if condition[1] == E.ConditionType.Level then
              self.uiBinder.btn_remodel.IsDisabled = true
              self.uiBinder.btn_remodel_binder_unlock.lab_normal.text = string.format(Lang("rolelv_skill_remodel"), condition[2])
              self.uiBinder.btn_remodel_binder_unlock.Ref.UIComp:SetVisible(true)
              self.uiBinder.Ref:SetVisible(self.uiBinder.btn_remodel, false)
              break
            end
          end
        end
      end
    end
  end
end

function Weapon_develop_skill_subView:refreshUnlockInfo()
  self.notEnoughItem_ = nil
  local cost = {}
  local costRecord = {}
  local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(self.selectSkillId_)
  local skillRow = self.weaponSkillVm_:GetLevelUpSkilllRow(upgradeId, 1)
  for _, value in ipairs(skillRow.Cost) do
    local temp = {}
    local itemId = value[1]
    if costRecord[itemId] then
      costRecord[itemId].itemCount = costRecord[itemId].itemCount + value[2]
    else
      temp.itemID = itemId
      temp.itemCount = value[2]
      table.insert(cost, temp)
      costRecord[itemId] = cost[#cost]
    end
  end
  for _, value in ipairs(self.itemUnits_) do
    self:RemoveUiUnit(value)
  end
  if #cost == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_cost, false)
    self.uiBinder.node_viewport.offsetMin = Vector2.New(0, 0)
    return
  end
  local height = self.uiBinder.loop_item_cost.rect.height - 20
  self.uiBinder.node_viewport.offsetMin = Vector2.New(0, height)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_item_cost, true)
  local btnDisabled = false
  local parent = self.uiBinder.item_root_content
  Z.CoroUtil.create_coro_xpcall(function(...)
    for _, value in ipairs(cost) do
      local totalCount = self.itemVm_.GetItemTotalCount(value.itemID)
      local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New), value.itemID, parent)
      table.insert(self.itemUnits_, value.itemID)
      self.itemClassTab_[value.itemID] = itemClass.new(self)
      self.itemClassTab_[value.itemID]:Init({
        uiBinder = unit,
        configId = value.itemID,
        labType = E.ItemLabType.Expend,
        lab = totalCount,
        expendCount = value.itemCount,
        isSquareItem = true
      })
      if totalCount < value.itemCount then
        btnDisabled = true
        if not self.notEnoughItem_ then
          self.notEnoughItem_ = value.itemID
        end
      end
    end
  end)()
  self.uiBinder.btn_unlock.IsDisabled = btnDisabled
end

function Weapon_develop_skill_subView:refreshSkillDesc()
  local skillId = self.selectReplaceId_
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  local content = ""
  if config ~= nil then
    content = Z.TableMgr.DecodeLineBreak(config.Desc)
  end
  for _, value in ipairs(self.tagUnitsName_) do
    self:RemoveUiUnit(value)
  end
  self.tagUnitsName_ = {}
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local tagIds = weaponSkillVm:GetSkillAllTag(skillId)
  local parent = self.uiBinder.group_title_rect
  local unitPath = self.uiBinder.prefab_cache:GetString("skill_tag_unit")
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
    for _, value in ipairs(tagIds) do
      local tagTab = Z.TableMgr.GetTable("BdTagTableMgr").GetRow(value)
      if tagTab then
        local name = "SkillTagUnit" .. tostring(value)
        local unit = self:AsyncLoadUiUnit(unitPath, name, parent, self.cancelSource:CreateToken())
        if unit then
          Z.RichTextHelper.AddTmpLabClick(unit.lab_title, tagTab.TagName, function()
            Z.CommonTipsVM.OpenUnderline(skillId)
          end)
        end
        table.insert(self.tagUnitsName_, name)
      end
    end
    if self.tagTimer_ then
      self.timerMgr:StopFrameTimer(self.tagTimer_)
      self.tagTimer_ = nil
    end
    self.tagTimer_ = self.timerMgr:StartFrameTimer(function()
      self.uiBinder.group_title:SetLayoutGroup()
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, true)
    end, 1, 1)
  end)()
  local level = self.weaponVm_.GetShowSkillLevel(self.professionId_, self.selectSkillId_)
  local remodelLevel = self.weaponSkillVm_:GetSkillRemodelLevel(self.selectSkillId_)
  local skillFightData = self.weaponSkillVm_:GetSkillFightDataById(skillId)
  content = content .. "\n"
  local skillAttrDescList = self.skillVm_.GetSkillDecs(skillFightData[level].Id, remodelLevel)
  skillAttrDescList = self.skillVm_.GetSkillDecsWithColor(skillAttrDescList)
  if skillAttrDescList then
    for _, value in ipairs(skillAttrDescList) do
      content = content .. "\n" .. value.Dec .. Lang(":") .. value.Num
    end
  end
  content = content .. "\n"
  local remodelDatas = self.weaponSkillVm_:GetSkillRemodelConfig(self.selectReplaceId_)
  for _, row in pairs(remodelDatas) do
    if remodelLevel >= row.Level then
      local curLevelDesc = self.weaponSkillVm_:ParseRemodelDesc(self.selectReplaceId_, row.Level, false, true)
      if not string.zisEmpty(curLevelDesc) then
        content = content .. "\n" .. curLevelDesc
      end
    end
  end
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_content, content)
end

function Weapon_develop_skill_subView:OnDeActive()
  self.skillDataUnits = {}
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
  self.onContainerChanged = nil
  self.selectType_ = nil
  Z.CommonTipsVM.CloseRichText()
  Z.CommonTipsVM.CloseUnderline()
  if self.tagTimer_ then
    self.timerMgr:StopFrameTimer(self.tagTimer_)
    self.tagTimer_ = nil
  end
  for _, tipsId in pairs(self.subTipsIdList_) do
    Z.TipsVM.CloseItemTipsView(tipsId)
  end
  self.subTipsIdList_ = {}
  for _, value in pairs(self.itemClassTab_) do
    value:UnInit()
  end
  self.itemClassTab_ = {}
end

return Weapon_develop_skill_subView
