local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_resonance_advance_windowView = class("Weapon_resonance_advance_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local weapon_resonance_tab_item = require("ui.component.weapon.weapon_resonance_tab_loop_item")
local common_reward_loop_list_item = require("ui.component.common_reward_loop_list_item")
local MAT_ID = 1009

function Weapon_resonance_advance_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_resonance_advance_window")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.skillVM_ = Z.VMMgr.GetVM("skill")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.commonVM = Z.VMMgr.GetVM("common")
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
  self:unLoadAttrItem()
  self:unLoadEffectItem()
  self:closeLabelTips()
  self:closeSourceTips()
  self:unLoadRedDotItem()
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
  self.attrItemBinders_ = {}
  self.effectItemBinders_ = {}
  self.curShowModelRotEuler_ = Vector3.New(0, 0, 0)
end

function Weapon_resonance_advance_windowView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.binder_tips.btn_operate, function()
    self:onOperateBtnClick()
  end)
  self.uiBinder.lab_title.text = self.commonVM.GetTitleByConfig({
    E.FunctionID.WeaponAoyiSkill
  })
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
  self.loopCostView_ = loopListView.new(self, self.uiBinder.binder_tips.loop_item, common_reward_loop_list_item, "item_prop")
  self.loopTabView_:Init(self.curAdvanceConfigList_)
  local costList = {}
  self.loopCostView_:Init(costList)
end

function Weapon_resonance_advance_windowView:refreshTabLoopListView()
  self:setSelectLevel()
  self.loopTabView_:ClearAllSelect()
  self.loopTabView_:MovePanelToItemIndex(self.curSelectAdvanceLevel_)
  self.loopTabView_:SetSelected(self.curSelectAdvanceLevel_)
end

function Weapon_resonance_advance_windowView:refreshCostLoopListView(costTbl)
  self.isCostEnough_ = true
  self.notEnoughItem_ = nil
  local dataList = {}
  for i, v in ipairs(costTbl) do
    local itemId = v[1]
    local num = v[2]
    dataList[i] = {ItemId = itemId, Num = num}
    local haveNum = self.itemsVM_.GetItemTotalCount(itemId)
    if num > haveNum then
      self.isCostEnough_ = false
      self.notEnoughItem_ = itemId
    end
  end
  self.loopCostView_:RefreshListView(dataList)
  self.uiBinder.binder_tips.btn_operate.IsDisabled = not self.isCostEnough_
end

function Weapon_resonance_advance_windowView:unInitLoopListView()
  self.loopTabView_:UnInit()
  self.loopCostView_:UnInit()
  self.loopTabView_ = nil
  self.loopCostView_ = nil
end

function Weapon_resonance_advance_windowView:refreshTotalInfo()
  self:showMonsterModel()
  self:refreshTipsInfo()
end

function Weapon_resonance_advance_windowView:showMonsterModel()
  if self.curShowModel_ then
    return
  end
  local monsterId = self.curResonanceConfig_.MonsterId
  local monsterRow = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
  local modelPos = Vector3.New(-0.4, 0, 0)
  local modelRot = Quaternion.Euler(Vector3.New(0, 160, 0))
  local intensityValue = 2
  local fresnelColor = Color.New(0, 0.11372549019607843 * intensityValue, 0.7490196078431373 * intensityValue, 1)
  local fresnelEffect = Vector4.New(-0.7, 1, 1, 1)
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, monsterRow.ModelID, function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos") + modelPos)
    model:SetAttrGoRotation(modelRot)
  end, nil, function(model)
    model.RenderComp:SetFresnelEffect(1, fresnelColor, fresnelEffect, Z.ModelRenderType.All)
  end, nil, false)
  self.curShowModel_:SetLuaAttrGoScale(self.curResonanceConfig_.ModelRatio)
end

function Weapon_resonance_advance_windowView:clearMonsterModel()
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
end

function Weapon_resonance_advance_windowView:refreshTipsInfo()
  local binderTips = self.uiBinder.binder_tips
  local curAdvanceConfig = self.curAdvanceConfigList_[self.curSelectAdvanceLevel_]
  if curAdvanceConfig == nil then
    return
  end
  local isAdvanced = self.curServerAdvanceLevel_ >= self.curSelectAdvanceLevel_
  local isOverLevel = self.curSelectAdvanceLevel_ > self.curServerAdvanceLevel_ + 1
  local isMaxLevel = self.curServerAdvanceLevel_ >= #self.curAdvanceConfigList_
  binderTips.lab_advance_level.text = Lang("AdvanceLevel", {
    val = self.curSelectAdvanceLevel_
  })
  local attrDescList, buffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(self.curSkillId_, self.curSelectAdvanceLevel_, false, true)
  Z.CoroUtil.create_coro_xpcall(function()
    binderTips.Ref:SetVisible(binderTips.group_desc, false)
    self:loadAttrItem(attrDescList)
    self:loadEffectItem(buffDescList)
    self.uiBinder.binder_tips.Ref:SetVisible(self.uiBinder.binder_tips.img_line, 0 < #attrDescList and 0 < #buffDescList)
    self.timerMgr:StartFrameTimer(function()
      binderTips.rebuild_layout:ForceRebuildLayoutImmediate()
      binderTips.Ref:SetVisible(binderTips.group_desc, true)
    end, 1, 1)
  end)()
  binderTips.btn_operate_binder.Ref:SetVisible(binderTips.btn_operate_binder.img_icon, false)
  binderTips.Ref:SetVisible(binderTips.group_cost, not isAdvanced)
  if not isAdvanced then
    self:refreshCostLoopListView(curAdvanceConfig.UpgradeCost)
    local conditionEnough = Z.ConditionHelper.CheckCondition(curAdvanceConfig.UlockSkillLevel)
    if not conditionEnough then
      for _, condition in ipairs(curAdvanceConfig.UlockSkillLevel) do
        if condition[1] == E.ConditionType.Level then
          binderTips.btn_operate_binder.lab_normal.text = string.format(Lang("rolelv_skill_remodel"), condition[2])
          binderTips.btn_operate_binder.Ref:SetVisible(binderTips.btn_operate_binder.img_icon, true)
          break
        end
      end
    end
  end
  binderTips.lab_had_advanced.text = isMaxLevel and Lang("ResonanceMaxLevel") or Lang("ResonanceAdvanceTip1")
  binderTips.Ref:SetVisible(binderTips.group_cost, not isAdvanced)
  binderTips.Ref:SetVisible(binderTips.btn_operate, not isAdvanced and not isOverLevel)
  binderTips.Ref:SetVisible(binderTips.lab_had_advanced, isAdvanced)
  binderTips.Ref:SetVisible(binderTips.lab_advance_tip, isOverLevel)
  self:loadRedDotItem()
end

function Weapon_resonance_advance_windowView:loadAttrItem(descList)
  self:unLoadAttrItem()
  for index, info in ipairs(descList) do
    local itemPath = self.uiBinder.prefab_cache:GetString("desc_item")
    local itemName = "attr_item_" .. index
    local itemBinder = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.binder_tips.node_normal_desc)
    self.attrItemBinders_[itemName] = itemBinder
    itemBinder.lab_value.text = info.title
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(itemBinder.lab_value, info.desc)
  end
end

function Weapon_resonance_advance_windowView:unLoadAttrItem()
  for itemName, itemBinder in pairs(self.attrItemBinders_) do
    self:RemoveUiUnit(itemName)
  end
  self.attrItemBinders_ = {}
end

function Weapon_resonance_advance_windowView:loadEffectItem(specialEffectList)
  self:unLoadEffectItem()
  for index, info in ipairs(specialEffectList) do
    local itemPath = self.uiBinder.prefab_cache:GetString("desc_item")
    local itemName = "special_effect_item_" .. index
    local itemBinder = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.binder_tips.node_special_desc)
    self.effectItemBinders_[itemName] = itemBinder
    itemBinder.lab_value.text = info.title
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(itemBinder.lab_value, info.desc)
  end
end

function Weapon_resonance_advance_windowView:unLoadEffectItem()
  for itemName, itemBinder in pairs(self.effectItemBinders_) do
    self:RemoveUiUnit(itemName)
  end
  self.effectItemBinders_ = {}
end

function Weapon_resonance_advance_windowView:loadRedDotItem()
  local advanceNodeId = self.weaponSkillVM_:GetResonanceAdvanceRedDotId(self.curSkillId_)
  if self.advanceNodeId_ and self.advanceNodeId_ ~= advanceNodeId then
    self:unLoadRedDotItem()
  end
  self.advanceNodeId_ = advanceNodeId
  Z.RedPointMgr.LoadRedDotItem(self.advanceNodeId_, self, self.uiBinder.binder_tips.btn_operate.transform)
end

function Weapon_resonance_advance_windowView:unLoadRedDotItem()
  if self.advanceNodeId_ then
    Z.RedPointMgr.RemoveNodeItem(self.advanceNodeId_, self)
    self.advanceNodeId_ = nil
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

function Weapon_resonance_advance_windowView:closeLabelTips()
  Z.CommonTipsVM.CloseRichText()
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
