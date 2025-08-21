local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_resonance_advance_windowView = class("Weapon_resonance_advance_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local weapon_resonance_tab_item = require("ui.component.weapon.weapon_resonance_tab_loop_item")
local weaponResonanceSkillTipsView = require("ui.view.weapon_resonance_skill_tips_view")
local ResonanceSkillDefine = require("ui.model.resonance_skill_define")

function Weapon_resonance_advance_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_resonance_advance_window")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.skillVM_ = Z.VMMgr.GetVM("skill")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.commonVM = Z.VMMgr.GetVM("common")
  self.professionVM_ = Z.VMMgr.GetVM("profession")
  self.skillAoyiTableMgr_ = Z.TableMgr.GetTable("SkillAoyiTableMgr")
end

function Weapon_resonance_advance_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self:onStartAnimShow()
  self:bindEvents()
  self:initData()
  self:initComponent()
  self:initDragEvent()
  self:initLoopListView()
  self:refreshTabLoopListView()
end

function Weapon_resonance_advance_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unBindEvents()
  self:unInitDragEvent()
  self:unInitLoopListView()
  self:clearMonsterModel()
  self:closeSourceTips()
  self:closeTipsSubView()
end

function Weapon_resonance_advance_windowView:OnRefresh()
end

function Weapon_resonance_advance_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.viewConfigKey)
end

function Weapon_resonance_advance_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnResonanceSkillAdvanceSuccess, self.onResonanceSkillAdvanceSuccess, self)
end

function Weapon_resonance_advance_windowView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Weapon.OnResonanceSkillAdvanceSuccess, self.onResonanceSkillAdvanceSuccess, self)
end

function Weapon_resonance_advance_windowView:initData()
  self.curSkillId_ = self.viewData.skillId
  self.curResonanceConfig_ = self.skillAoyiTableMgr_.GetRow(self.curSkillId_)
  self.curAdvanceConfigList_ = self.weaponSkillVM_:GetResonanceSkillRemodelLevelList(self.curSkillId_)
  self.curServerAdvanceLevel_ = self.weaponSkillVM_:GetSkillRemodelLevel(self.curSkillId_)
  self.curShowModelRotEuler_ = Vector3.New(0, 0, 0)
  self.tempModelEffectScale_ = nil
  self.tempModelScale_ = nil
end

function Weapon_resonance_advance_windowView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.uiBinder.lab_title.text = self.commonVM.GetTitleByConfig({
    E.FunctionID.WeaponAoyiSkill
  })
  self.weaponResonanceSkillTips_ = weaponResonanceSkillTipsView.new(self)
  self:showTipsSubView()
end

function Weapon_resonance_advance_windowView:initDragEvent()
  self:AddClick(self.uiBinder.event_trigger.onBeginDrag, function(go, eventData)
    self:onBeginDrag(eventData)
  end)
  self:AddClick(self.uiBinder.event_trigger.onDrag, function(go, eventData)
    self:onDrag(eventData)
  end)
end

function Weapon_resonance_advance_windowView:unInitDragEvent()
  self.uiBinder.event_trigger.onBeginDrag:RemoveAllListeners()
  self.uiBinder.event_trigger.onDrag:RemoveAllListeners()
end

function Weapon_resonance_advance_windowView:showTipsSubView()
  local viewData = {
    skillId = self.weaponSkillVM_:GetOriginSkillId(self.curSkillId_),
    professionId = self.professionVM_:GetContainerProfession(),
    advanceLevel = self.curSelectAdvanceLevel_
  }
  self.weaponResonanceSkillTips_:Active(viewData, self.uiBinder.tips_root)
end

function Weapon_resonance_advance_windowView:closeTipsSubView()
  self.weaponResonanceSkillTips_:DeActive()
end

function Weapon_resonance_advance_windowView:setSelectLevel()
  local maxLevel = #self.curAdvanceConfigList_
  if maxLevel <= self.curServerAdvanceLevel_ then
    self.curSelectAdvanceLevel_ = maxLevel
  else
    self.curSelectAdvanceLevel_ = self.curServerAdvanceLevel_ + 1
  end
end

function Weapon_resonance_advance_windowView:initLoopListView()
  self.loopTabView_ = loopListView.new(self, self.uiBinder.loop_tab, weapon_resonance_tab_item, "item_tab")
  self.loopTabView_:Init(self.curAdvanceConfigList_)
end

function Weapon_resonance_advance_windowView:refreshTabLoopListView()
  self:setSelectLevel()
  self.loopTabView_:ClearAllSelect()
  self.loopTabView_:MovePanelToItemIndex(self.curSelectAdvanceLevel_)
  self.loopTabView_:SetSelected(self.curSelectAdvanceLevel_)
end

function Weapon_resonance_advance_windowView:unInitLoopListView()
  self.loopTabView_:UnInit()
  self.loopTabView_ = nil
end

function Weapon_resonance_advance_windowView:refreshTotalInfo()
  self:showMonsterModel()
  self:showTipsSubView()
end

function Weapon_resonance_advance_windowView:showMonsterModel()
  if self.curShowModel_ then
    if self.curShowModel_.Loaded then
      self:createModelEffect(self.curShowModel_)
    end
    return
  end
  local monsterId = self.curResonanceConfig_.MonsterId
  local monsterRow = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
  local modelPos = Vector3.New(-0.4, 0, 0)
  local modelRot = Quaternion.Euler(Vector3.New(0, 160, 0))
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, monsterRow.ModelID, function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos") + modelPos)
    model:SetAttrGoRotation(modelRot)
    if self.curResonanceConfig_.ModelAnim ~= "" then
      model:SetLuaAttrModelPreloadClip(self.curResonanceConfig_.ModelAnim)
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(self.curResonanceConfig_.ModelAnim))
    else
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
    end
  end, nil, function(model)
    self:createModelEffect(model)
  end)
  self.curShowModel_:SetLuaAttrGoScale(self.tempModelScale_ or self.curResonanceConfig_.ModelRatio)
end

function Weapon_resonance_advance_windowView:clearMonsterModel()
  self:clearModelEffect()
  if self.curShowModel_ then
    self.curShowModel_.RenderComp:SetUIResonanceOutline(false)
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
end

function Weapon_resonance_advance_windowView:OnTabSelected(advanceLevel)
  self.curSelectAdvanceLevel_ = advanceLevel
  self:refreshTotalInfo()
end

function Weapon_resonance_advance_windowView:onBeginDrag(eventData)
  if self.curShowModel_ == nil then
    return
  end
  local modelRot = self.curShowModel_:GetAttrGoRotation()
  self.curShowModelRotEuler_ = modelRot.eulerAngles
end

function Weapon_resonance_advance_windowView:onDrag(eventData)
  if self.curShowModel_ == nil then
    return
  end
  self.curShowModelRotEuler_.y = self.curShowModelRotEuler_.y - eventData.delta.x
  self.curShowModel_:SetAttrGoRotation(Quaternion.Euler(self.curShowModelRotEuler_))
end

function Weapon_resonance_advance_windowView:createModelEffect(model)
  self:clearModelEffect()
  local curAdvanceConfig = self.curAdvanceConfigList_[self.curSelectAdvanceLevel_]
  if curAdvanceConfig == nil or #curAdvanceConfig.ModelPointScale == 0 then
    return
  end
  if model == nil then
    return
  end
  local qualityConfig = Z.Global.SkillAoyiModelSkin1
  if self.curResonanceConfig_.RarityType > 1 then
    qualityConfig = Z.Global.SkillAoyiModelSkin2
  end
  local fresnelColor, effectQuality
  for i, v in ipairs(qualityConfig) do
    local minLv = v[1]
    local maxLv = v[2]
    local quality = v[3]
    if minLv <= self.curSelectAdvanceLevel_ and maxLv >= self.curSelectAdvanceLevel_ then
      effectQuality = quality
    end
  end
  if 4 <= effectQuality then
    local intensityValue = 1.1375
    fresnelColor = Color.New(0.7490196078431373 * intensityValue, 0.21568627450980393 * intensityValue, 0, 1)
  else
    local intensityValue = 2.2
    fresnelColor = Color.New(0, 0.08627450980392157 * intensityValue, 0.7490196078431373 * intensityValue, 1)
  end
  if effectQuality == nil then
    return
  end
  local effectPathConfig = ResonanceSkillDefine.Model_Effect_Path_Config[effectQuality]
  if effectPathConfig == nil then
    return
  end
  self.curEffectList_ = {}
  for index, scale in ipairs(curAdvanceConfig.ModelPointScale) do
    if self.tempModelEffectScale_ and self.tempModelEffectScale_[index] then
      scale = self.tempModelEffectScale_[index]
    end
    local config = ResonanceSkillDefine.Model_Effect_Config[index]
    if config and 0 < scale then
      local effectPath = string.format(effectPathConfig, config.MountPointKey)
      local effectPoint = config.MountPointName
      local effectScale = Vector3.New(scale, scale, scale)
      local effectUuid = Z.UnrealSceneMgr:CreateEffectOnModelPoint(model, effectPath, effectPoint, Vector3.zero, Vector3.zero, effectScale, true, -1)
      table.insert(self.curEffectList_, effectUuid)
    end
  end
  local fresnelEffect = Vector4.New(-0.7, 1, 1, 1)
  model.RenderComp:SetFresnelEffect(1, fresnelColor, fresnelEffect, Z.ModelRenderMask.All)
  local headFresnelEffect = Vector4.New(0.15, 1, 1, 1)
  model.RenderComp:SetFresnelEffect(1, fresnelColor, headFresnelEffect, Z.ModelRenderMask.Hair)
end

function Weapon_resonance_advance_windowView:clearModelEffect()
  if self.curEffectList_ then
    for i, uuid in ipairs(self.curEffectList_) do
      Z.UnrealSceneMgr:ClearEffect(uuid)
    end
    self.curEffectList_ = nil
  end
end

function Weapon_resonance_advance_windowView:closeSourceTips()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
end

function Weapon_resonance_advance_windowView:onOperateBtnClick()
  local isAdvanced = self.curServerAdvanceLevel_ >= self.curSelectAdvanceLevel_
  if isAdvanced then
    return
  end
  if not self.isCostEnough_ then
    self:closeSourceTips()
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.notEnoughItem_)
    if itemConfig then
      Z.TipsVM.ShowTipsLang(1045007, {
        val = itemConfig.Name
      })
      self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.notEnoughItem_, self.uiBinder.binder_tips.group_cost)
    end
    return
  end
  local curAdvanceConfig = self.curAdvanceConfigList_[self.curSelectAdvanceLevel_]
  if curAdvanceConfig then
    self.weaponSkillVM_:AsyncAoYiSkillRemodel(curAdvanceConfig.Id, self.cancelSource:CreateToken())
  end
end

function Weapon_resonance_advance_windowView:onResonanceSkillAdvanceSuccess()
  self.curServerAdvanceLevel_ = self.weaponSkillVM_:GetSkillRemodelLevel(self.curSkillId_)
  self:refreshTabLoopListView()
end

function Weapon_resonance_advance_windowView:GetCurSkillId()
  return self.curSkillId_
end

function Weapon_resonance_advance_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Weapon_resonance_advance_windowView
