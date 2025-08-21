local UI = Z.UI
local super = require("ui.ui_view_base")
local Fashion_weapon_skill_windowView = class("Fashion_weapon_skill_windowView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local skillItem = require("ui.component.weapon_skill_skin.weapon_skill_skin_skill_item")
local skillSkinItem = require("ui.component.weapon_skill_skin.weapon_skill_skin_item")
local skillActiveItem = require("ui.component.weapon_skill_skin.weapon_skill_skin_active_item")

function Fashion_weapon_skill_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fashion_weapon_skill_window")
end

function Fashion_weapon_skill_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  self.weaoponVm_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.SelectProfessionId = self.viewData.professionId or self.weaoponVm_:GetCurWeapon()
  self.SelectSkllId = self.viewData.skillId
  self:AddAsyncClick(self.uiBinder.btn_return, function()
    self.weaponSkillSkinVm_:CloseSkillSkinView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_activation, function()
    if self.notEnoughItem_ then
      if self.sourceTipId_ then
        Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
        self.sourceTipId_ = nil
      end
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
      if itemConfig then
        Z.TipsVM.ShowTipsLang(1045006, {
          val = itemConfig.Name
        })
        self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.notEnoughItem_, self.uiBinder.tips_root)
      end
      return
    end
    self.weaponSkillSkinVm_:AsyncActivateProfessionSkillSkin(self.SelectProfessionId, self.SelectSkllId, self.selectSkillSkinId_, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    self.weaponSkillSkinVm_:AsyncUseProfessionSkillSkin(self.SelectProfessionId, self.SelectSkllId, self.selectSkillSkinId_, self.cancelSource:CreateToken())
  end)
  self.uiBinder.group_video:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
  end, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, true)
  end)
  self:AddClick(self.uiBinder.btn_play, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
    self.uiBinder.group_video:PlayCurrent(true)
    self:StopAudio()
    self:PlayAudio()
  end)
  self.skillSkins_ = {}
  self:bindEvents()
  self:refreshSkillLoop()
end

function Fashion_weapon_skill_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillSkinUnlock, self.refreshSkillSkinLoop, self)
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillSkinChange, self.refreshSkillSkinLoop, self)
end

function Fashion_weapon_skill_windowView:refreshSkillLoop()
  local data = {}
  local skillGroup = {}
  local skillSkinData = Z.TableMgr.GetTable("SkillSkinTableMgr").GetDatas()
  for skillId, value in pairs(skillSkinData) do
    local titleSkillId = value.SkillId[1]
    if value.Id == titleSkillId and value.ProfessionId == self.SelectProfessionId and not table.zcontains(skillGroup, titleSkillId) then
      table.insert(data, value)
      table.insert(skillGroup, titleSkillId)
    end
    if self.skillSkins_[titleSkillId] == nil then
      self.skillSkins_[titleSkillId] = {}
    end
    table.insert(self.skillSkins_[titleSkillId], value)
  end
  for index, value in pairs(self.skillSkins_) do
    table.sort(value, function(a, b)
      return a.Sort < b.Sort
    end)
  end
  table.sort(data, function(a, b)
    return a.Sort < b.Sort
  end)
  local selectedIndex = 1
  for index, value in ipairs(data) do
    if value.SkillId[1] == self.SelectSkllId then
      selectedIndex = index
    end
  end
  if self.skillLoop == nil then
    self.skillLoop = loopGridView.new(self, self.uiBinder.loop_skill, skillItem, "fashion_weapon_skill_tpl")
    self.skillLoop:Init(data)
  else
    self.skillLoop:RefreshListView(data)
  end
  self.skillLoop:SetSelected(selectedIndex)
end

function Fashion_weapon_skill_windowView:OnSelectSkill(skillId)
  self.SelectSkllId = skillId
  if self.weaponSkillVm_:CheckSkillUnlock(skillId) then
    local upgradeId = self.weaponSkillVm_:GetSkillUpgradeId(skillId)
    local skillUpgradeRow = self.weaponSkillVm_:GetLevelUpSkilllRow(upgradeId, 1)
    for _, value in ipairs(skillUpgradeRow.UnlockConditions) do
      if not Z.ConditionHelper.CheckSingleCondition(value[1], false, value[2]) then
        local bResult, unlockDesc, progress = Z.ConditionHelper.GetSingleConditionDesc(value[1], value[2])
        if value[1] == E.ConditionType.Level then
          self.uiBinder.btn_activation_binder.lab_normal.text = Lang("NeedPlayerLevel", {
            val = value[2]
          })
          break
        end
        if value[1] == E.ConditionType.OpenServerDay then
          self.uiBinder.btn_activation_binder.lab_normal.text = Lang("UnlockAfterNumberDay", {val = progress})
          break
        end
        self.uiBinder.btn_activation_binder.lab_normal.text = unlockDesc
        break
      end
    end
  else
    self.uiBinder.btn_activation_binder.lab_normal.text = Lang("Activation")
  end
  self:refreshSkillSkinLoop()
end

function Fashion_weapon_skill_windowView:refreshSkillSkinLoop()
  local data = self.skillSkins_[self.SelectSkllId]
  if self.skillSkinLoop == nil then
    self.skillSkinLoop = loopListView.new(self, self.uiBinder.loop_skill_skin, skillSkinItem, "fashion_weapon_list_tpl")
    self.skillSkinLoop:Init(data)
  else
    self.skillSkinLoop:RefreshListView(data)
  end
  if self.selectSkillSkinId_ == nil then
    self.selectSkillSkinId_ = self.weaponSkillSkinVm_:GetSkillSkinId(self.SelectSkllId)
  end
  local selectIndex = 1
  for index, value in pairs(data) do
    if value.Id == self.selectSkillSkinId_ then
      selectIndex = index
      break
    end
  end
  self.skillSkinLoop:ClearAllSelect()
  self.skillSkinLoop:SetSelected(selectIndex)
  self:StopAudio()
end

function Fashion_weapon_skill_windowView:OnSelectSkillSkin(SkillSkinId)
  self:StopAudio()
  self.selectSkillSkinId_ = SkillSkinId
  local skillSkinRow = Z.TableMgr.GetTable("SkillSkinTableMgr").GetRow(self.selectSkillSkinId_)
  if not skillSkinRow then
    return
  end
  self.uiBinder.lab_content.text = skillSkinRow.Desc
  if not string.zisEmpty(skillSkinRow.SkillIdsVideo) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, true)
    self.uiBinder.group_video:Prepare(skillSkinRow.SkillIdsVideo .. ".mp4", false, true)
    local array = string.split(skillSkinRow.SkillIdsVideo, "/")
    self.audioName = array[#array]
    self:PlayAudio()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquiesce, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquiesce, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, false)
  end
  if self.weaponSkillSkinVm_:CheckSkillSkinUnlock(self.SelectSkllId, SkillSkinId, self.SelectProfessionId) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, true)
    local isEquip = self.weaponSkillSkinVm_:CheckSkillSkinEquip(self.SelectSkllId, SkillSkinId, self.SelectProfessionId)
    self.uiBinder.btn_save.IsDisabled = isEquip
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, false)
    self:refreshUnlock()
  end
end

function Fashion_weapon_skill_windowView:PlayAudio()
  self.playingId = Z.AudioMgr:Play(self.audioName)
end

function Fashion_weapon_skill_windowView:StopAudio()
  if self.audioName then
    Z.AudioMgr:StopSound(self.audioName, nil, 0.2)
  end
end

function Fashion_weapon_skill_windowView:refreshUnlock()
  self:refreshActiveItem()
end

function Fashion_weapon_skill_windowView:refreshActiveItem()
  local skillSkinRow = Z.TableMgr.GetTable("SkillSkinTableMgr").GetRow(self.selectSkillSkinId_)
  local data = {}
  if skillSkinRow then
    data = skillSkinRow.UnlockConsume
  end
  self.notEnoughItem_ = nil
  for _, value in ipairs(data) do
    local totalCount = self.itemVm_.GetItemTotalCount(value[1])
    if totalCount < value[2] then
      self.notEnoughItem_ = value[1]
      break
    end
  end
  if self.itemLoop_ == nil then
    self.itemLoop_ = loopListView.new(self, self.uiBinder.loop_item, skillActiveItem, "com_item_square_8")
    self.itemLoop_:Init(data)
  else
    self.itemLoop_:RefreshListView(data)
  end
end

function Fashion_weapon_skill_windowView:OnDeActive()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
  if self.skillLoop then
    self.skillLoop:UnInit()
    self.skillLoop = nil
  end
  if self.skillSkinLoop then
    self.skillSkinLoop:UnInit()
    self.skillSkinLoop = nil
  end
  if self.itemLoop_ then
    self.itemLoop_:UnInit()
    self.itemLoop_ = nil
  end
  self.uiBinder.group_video:RemoveAllListeners()
  self:StopAudio()
end

function Fashion_weapon_skill_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.viewConfigKey)
end

function Fashion_weapon_skill_windowView:OnRefresh()
end

return Fashion_weapon_skill_windowView
