local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_skill_unlock_popupView = class("Weapon_skill_unlock_popupView", super)
local itemClass = require("common.item_binder")

function Weapon_skill_unlock_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_skill_unlock_popup")
end

function Weapon_skill_unlock_popupView:OnActive()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.skillId_ = self.viewData.skillId
  self.skillType_ = self.viewData.skillType
  self.weaponId_ = self.weaponVm_.GetCurWeapon()
  self.conditionMet_ = true
  self.itemLack_ = false
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    self.weaponSkillVm_.CloseSkillIUnlockView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    if not self.conditionMet_ then
      local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.skillId_)
      Z.ConditionHelper.CheckCondition(skillRow.UnlockCondition, true)
      return
    end
    if self.itemLack_ then
      Z.TipsVM.ShowTipsLang(10010)
      return
    end
    self.weaponSkillVm_:AsyncProfessionSkillUnlock(self.skillId_, self.skillType_, self.weaponId_, self.cancelSource:CreateToken())
  end)
  self:BindEvent()
  self:refreshInfo()
end

function Weapon_skill_unlock_popupView:BindEvent()
  function self.onContainerChanged(container, dirty)
    if dirty.weaponList or dirty.aoyiSkillInfoMap then
      self.weaponSkillVm_.CloseSkillIUnlockView()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
end

function Weapon_skill_unlock_popupView:refreshInfo()
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.skillId_)
  if #skillRow.UnlockCondition == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lab, false)
    self.uiBinder.node_info.localPosition = Vector2.New(0, 65)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lab, true)
    self.conditionMet_ = Z.ConditionHelper.CheckCondition(skillRow.UnlockCondition)
    local results = Z.ConditionHelper.GetConditionDescList(skillRow.UnlockCondition)
    local content = ""
    for _, value in ipairs(results) do
      content = content .. value.Desc
    end
    self.uiBinder.lab_content.text = content
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.conditionMet_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.conditionMet_)
    self.uiBinder.node_info.localPosition = Vector2.zero
  end
  local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(self.skillId_)
  local cost = {}
  local skillLevelDatas = Z.TableMgr.GetTable("SkillUpgradeTableMgr").GetDatas()
  for _, value in pairs(skillLevelDatas) do
    if value.UpgradeId == upgradeId and value.SkillLevel == 1 then
      cost = value.Cost
      break
    end
  end
  local parent = self.uiBinder.layout_item
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(cost) do
      local itemUIBinder = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.BackPack_Item_Unit_Addr1_8_New), index, parent)
      local totalCount = self.itemVm_.GetItemTotalCount(value[1])
      if totalCount < value[2] then
        self.itemLack_ = true
      end
      local itemClassData = {
        uiBinder = itemUIBinder,
        configId = value[1],
        isShowZero = true,
        lab = totalCount,
        expendCount = value[2],
        isSquareItem = true
      }
      local item = itemClass.new(self)
      item:Init(itemClassData)
      item:SetExpendCount(totalCount, value[2])
    end
  end)()
end

function Weapon_skill_unlock_popupView:OnDeActive()
  Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
  self.onContainerChanged = nil
end

function Weapon_skill_unlock_popupView:OnRefresh()
end

return Weapon_skill_unlock_popupView
