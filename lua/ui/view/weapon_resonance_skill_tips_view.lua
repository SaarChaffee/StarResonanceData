local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_resonance_skill_tipsView = class("Weapon_resonance_skill_tipsView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item = require("ui.component.common_reward_loop_list_item")
local HEIGHT_ACTIVATE = 285
local HEIGHT_ADVANCED = 120

function Weapon_resonance_skill_tipsView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "weapon_develop/weapon_resonance_skill_tips"
  if Z.IsPCUI then
    assetPath = "weapon_develop/weapon_resonance_skill_tips_pc"
  end
  super.ctor(self, "weapon_resonance_skill_tips", assetPath, UI.ECacheLv.None)
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.skillVM_ = Z.VMMgr.GetVM("skill")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Weapon_resonance_skill_tipsView:OnActive()
  self:initData()
  self:initComponent()
  self:bindEvents()
end

function Weapon_resonance_skill_tipsView:OnDeActive()
  self:unInitLoopListView()
  self:unBindEvents()
  self:clearTagFrameTimer()
  self:clearTagItem()
  Z.CommonTipsVM.CloseUnderline()
  self:closeSourceTips()
  self:unLoadRedDotItem()
  Z.CommonTipsVM.CloseRichText()
  self.curSkillConfig_ = nil
end

function Weapon_resonance_skill_tipsView:OnRefresh()
  self.costNotEnoughItem_ = nil
  self.curSkillId_ = self.viewData.skillId
  self.curProfessionId_ = self.viewData.professionId
  self.curAdvanceLevel_ = self.viewData.advanceLevel or self.weaponSkillVM_:GetSkillRemodelLevel(self.curSkillId_)
  self.isAdvanceTips_ = self.viewData.advanceLevel ~= nil
  self.curWeaponInfo_ = self.weaponVM_.GetWeaponInfo(self.curProfessionId_)
  self.isUnlock_ = self.weaponSkillVM_:CheckSkillUnlock(self.curSkillId_)
  self.isEquip_ = self.weaponSkillVM_:CheckSkillEquip(self.curSkillId_)
  self.curSkillConfig_ = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.curSkillId_)
  self.curResonanceConfig_ = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(self.curSkillId_)
  if self.curSkillConfig_ then
    self:refreshSkillInfo()
  end
  self:loadRedDotItem()
end

function Weapon_resonance_skill_tipsView:initData()
  self.tagItemDict_ = {}
  self.advanceFuncUnlock_ = self.gotoFuncVM_.CheckFuncCanUse(E.ResonanceFuncId.Advance, true)
end

function Weapon_resonance_skill_tipsView:initComponent()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initLoopListView()
  self:AddAsyncClick(self.uiBinder.btn_operate, function()
    if self.isAdvanceTips_ then
      self:operateAdvancedSkill()
    elseif self.isUnlock_ then
      self:operateAdvancedSkill()
    else
      self:operateActivateSkill()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_lookeffect, function()
    self:operateAdvancedSkill()
  end)
end

function Weapon_resonance_skill_tipsView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Weapon_resonance_skill_tipsView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function Weapon_resonance_skill_tipsView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, common_reward_loop_list_item, "com_item_square_8")
  local dataList = {}
  self.loopListView_:Init(dataList)
end

function Weapon_resonance_skill_tipsView:refreshLoopListView(costTbl)
  self.costNotEnoughItem_ = nil
  local dataList = {}
  for i, v in ipairs(costTbl) do
    local itemId = v[1]
    local num = v[2]
    dataList[i] = {ItemId = itemId, Num = num}
    local haveNum = self.itemsVM_.GetItemTotalCount(itemId)
    if num > haveNum then
      self.costNotEnoughItem_ = itemId
    end
  end
  self.loopListView_:RefreshListView(dataList)
  if self.isAdvanceTips_ then
    self.uiBinder.btn_operate.IsDisabled = self.costNotEnoughItem_ ~= nil or not self.isUnlock_
  else
    self.uiBinder.btn_operate.IsDisabled = self.costNotEnoughItem_ ~= nil
  end
end

function Weapon_resonance_skill_tipsView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Weapon_resonance_skill_tipsView:refreshSkillInfo()
  self:refreshSkillBaseInfo()
  self:refreshSkillTags()
  self:refreshSkillDesc()
  self:refreshSkillCost()
  self:refreshSkillButton()
end

function Weapon_resonance_skill_tipsView:refreshSkillBaseInfo()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.curResonanceConfig_.AoyiItemId)
  self.uiBinder.lab_name.text = self.curSkillConfig_.Name
  local binderCard = self.uiBinder.binder_card
  binderCard.lab_advance_level.text = Lang("AdvanceLevel", {
    val = self.curAdvanceLevel_
  })
  binderCard.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(self.curResonanceConfig_.AoyiItemId))
  binderCard.Ref:SetVisible(binderCard.trans_equip, self.isEquip_)
  binderCard.img_bg_quality:SetColor(Z.ConstValue.QualityBgColor[itemRow.Quality])
end

function Weapon_resonance_skill_tipsView:refreshSkillTags()
  local tagTableMgr = Z.TableMgr.GetTable("BdTagTableMgr")
  local tagIdList = self.weaponSkillVM_:GetSkillAllTag(self.curSkillId_)
  local parent = self.uiBinder.trans_tags
  local itemPath = self.uiBinder.prefab_cache:GetString("skillTagItem")
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
    self:clearTagItem()
    for _, tagId in ipairs(tagIdList) do
      local tagTab = tagTableMgr.GetRow(tagId)
      if tagTab then
        local itemName = "SkillTagItem_" .. tagId
        if self.tagItemDict_[itemName] == nil then
          self:RemoveUiUnit(itemName)
          local itemBinder = self:AsyncLoadUiUnit(itemPath, itemName, parent, self.cancelSource:CreateToken())
          if itemBinder then
            Z.RichTextHelper.AddTmpLabClick(itemBinder.lab_title, tagTab.TagName, function()
              Z.CommonTipsVM.OpenUnderline(self.curSkillId_)
            end)
          end
          self.tagItemDict_[itemName] = itemBinder
        end
      end
    end
    self:createTagFrameTimer()
  end)()
end

function Weapon_resonance_skill_tipsView:createTagFrameTimer()
  self:clearTagFrameTimer()
  self.tagFrameTimer_ = self.timerMgr:StartFrameTimer(function()
    self.uiBinder.uneven_layout:SetLayoutGroup()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, true)
  end, 1, 1)
end

function Weapon_resonance_skill_tipsView:clearTagFrameTimer()
  if self.tagFrameTimer_ then
    self.tagFrameTimer_:Stop()
    self.tagFrameTimer_ = nil
  end
end

function Weapon_resonance_skill_tipsView:refreshSkillDesc()
  local content = self.weaponSkillVM_:ParseResonanceSkillBaseDesc(self.curSkillId_, self.curAdvanceLevel_)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_normal_effect_desc, content)
  local attrDescList, buffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(self.curSkillId_, self.curAdvanceLevel_, true)
  local resultDescList = {}
  for i, info in ipairs(attrDescList) do
    table.insert(resultDescList, info.desc)
    table.insert(resultDescList, "\n")
  end
  for i, info in ipairs(buffDescList) do
    table.insert(resultDescList, info.desc)
    table.insert(resultDescList, "\n")
  end
  local isSpecialEffectEmpty = #resultDescList == 0
  if not isSpecialEffectEmpty then
    local content = table.concat(resultDescList)
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_special_effect_desc, content)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_special_effect_title, not isSpecialEffectEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_special_effect_desc, not isSpecialEffectEmpty)
  self.uiBinder.lab_special_effect_title.text = Lang("PassiveEffect")
end

function Weapon_resonance_skill_tipsView:refreshSkillCost()
  local isMaxLv = self.weaponSkillVM_:CheckResonanceSkillRemodelMax(self.curSkillId_)
  local showCost = not isMaxLv
  if self.isAdvanceTips_ then
    local advanceConfig = self.weaponSkillVM_:GetResonanceSkillRemodelRow(self.curSkillId_, self.curAdvanceLevel_)
    if advanceConfig then
      self:refreshLoopListView(advanceConfig.UpgradeCost)
    end
    local serverAdvanceLevel = self.weaponSkillVM_:GetSkillRemodelLevel(self.curSkillId_)
    if serverAdvanceLevel >= self.curAdvanceLevel_ then
      showCost = false
    end
  elseif not self.isUnlock_ then
    local mysteriesConfig = self.weaponVM_.GetMysteriesSkillConfig(self.curSkillId_)
    if mysteriesConfig then
      self:refreshLoopListView(mysteriesConfig.SkillAdvancedItem)
    end
  else
    self.uiBinder.btn_operate.IsDisabled = false
    showCost = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_active_cost, showCost)
  local bottomValue = showCost and HEIGHT_ACTIVATE or HEIGHT_ADVANCED
  self.uiBinder.trans_scroll:SetOffsetMin(4, bottomValue)
end

function Weapon_resonance_skill_tipsView:refreshSkillButton()
  local isMaxLv = self.weaponSkillVM_:CheckResonanceSkillRemodelMax(self.curSkillId_)
  local isShowTips = false
  if self.isAdvanceTips_ then
    local serverAdvanceLevel = self.weaponSkillVM_:GetSkillRemodelLevel(self.curSkillId_)
    self.uiBinder.lab_operate.text = Lang("Advanced")
    if not self.isUnlock_ then
      self.uiBinder.lab_tips.text = Lang("AdvanceNotActiveTips")
      isShowTips = true
    else
      if isMaxLv then
        self.uiBinder.lab_tips.text = Lang("ResonanceMaxLevel2")
        isShowTips = true
      elseif serverAdvanceLevel >= self.curAdvanceLevel_ then
        self.uiBinder.lab_tips.text = Lang("ResonanceAdvanceTip1")
        isShowTips = true
      elseif self.curAdvanceLevel_ > serverAdvanceLevel + 1 then
        self.uiBinder.lab_tips.text = Lang("ResonanceAdvanceTip2")
        isShowTips = true
      end
      if not self.weaponSkillVM_:CheckResonanceSkillRemodelMax(self.curSkillId_) then
        local nextLvRemodelRow = self.weaponSkillVM_:GetResonanceSkillRemodelRow(self.curSkillId_, self.curAdvanceLevel_)
        if nextLvRemodelRow and nextLvRemodelRow.UlockSkillLevel then
          local conditionEnough = Z.ConditionHelper.CheckCondition(nextLvRemodelRow.UlockSkillLevel)
          if not conditionEnough then
            for _, condition in ipairs(nextLvRemodelRow.UlockSkillLevel) do
              if condition[1] == E.ConditionType.Level then
                self.uiBinder.lab_operate.text = string.format(Lang("rolelv_skill_remodel"), condition[2])
                break
              end
            end
          end
        end
      end
    end
    self.uiBinder.lab_cost_title.text = Lang("AdvanceCost")
  elseif self.isUnlock_ then
    self.uiBinder.lab_operate.text = Lang(isMaxLv and "ResonanceMaxLevel2" or "Advanced")
    self.uiBinder.lab_cost_title.text = Lang("ActivationCost")
  else
    self.uiBinder.lab_operate.text = Lang("Activation")
    self.uiBinder.lab_cost_title.text = Lang("ActivationCost")
  end
  self:SetUIVisible(self.uiBinder.btn_lookeffect, self.advanceFuncUnlock_ and not self.isUnlock_ and not self.isAdvanceTips_)
  self:SetUIVisible(self.uiBinder.lab_tips, isShowTips)
  local isShowAdvanceBtn = not isShowTips and (not self.isUnlock_ or self.advanceFuncUnlock_)
  self:SetUIVisible(self.uiBinder.btn_operate, isShowAdvanceBtn)
end

function Weapon_resonance_skill_tipsView:clearTagItem()
  for itemName, itemBinder in pairs(self.tagItemDict_) do
    self:RemoveUiUnit(itemName)
  end
  self.tagItemDict_ = {}
end

function Weapon_resonance_skill_tipsView:closeSourceTips()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
end

function Weapon_resonance_skill_tipsView:operateActivateSkill()
  if self.costNotEnoughItem_ ~= nil then
    Z.TipsVM.ShowTips(150106)
    self:closeSourceTips()
    self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.costNotEnoughItem_, self.uiBinder.trans_active_cost)
    return
  end
  self.weaponSkillVM_:AsyncProfessionSkillUnlock(self.curSkillId_, E.SkillType.MysteriesSkill, self.curProfessionId_, self.cancelSource:CreateToken())
end

function Weapon_resonance_skill_tipsView:operateAdvancedSkill()
  if self.isAdvanceTips_ then
    if not self.isUnlock_ then
      Z.TipsVM.ShowTips(150109)
      return
    end
    if self.weaponSkillVM_:CheckResonanceSkillRemodelMax(self.curSkillId_) then
      return
    end
    if not self.weaponSkillVM_:CheckResonanceSkillRemodelMax(self.curSkillId_) then
      local nextLvRemodelRow = self.weaponSkillVM_:GetResonanceSkillRemodelRow(self.curSkillId_, self.curAdvanceLevel_)
      if nextLvRemodelRow and nextLvRemodelRow.UlockSkillLevel and not Z.ConditionHelper.CheckCondition(nextLvRemodelRow.UlockSkillLevel, true) then
        return
      end
    end
    if self.costNotEnoughItem_ ~= nil then
      Z.TipsVM.ShowTips(150107)
      self:closeSourceTips()
      self.sourceTipId_ = Z.TipsVM.OpenSourceTips(self.costNotEnoughItem_, self.uiBinder.trans_active_cost)
      return
    end
    local advanceConfig = self.weaponSkillVM_:GetResonanceSkillRemodelRow(self.curSkillId_, self.curAdvanceLevel_)
    if advanceConfig then
      self.weaponSkillVM_:AsyncAoYiSkillRemodel(advanceConfig.Id, self.cancelSource:CreateToken())
    end
  else
    self.weaponSkillVM_:OpenResonanceSkillAdvanceView({
      skillId = self.curSkillId_
    })
  end
end

function Weapon_resonance_skill_tipsView:loadRedDotItem()
  local activeNodeId = self.weaponSkillVM_:GetResonanceActiveRedDotId(self.curSkillId_)
  if self.activeNodeId_ and self.activeNodeId_ ~= activeNodeId then
    Z.RedPointMgr.RemoveNodeItem(self.activeNodeId_, self)
  end
  self.activeNodeId_ = activeNodeId
  Z.RedPointMgr.LoadRedDotItem(self.activeNodeId_, self, self.uiBinder.btn_operate.transform)
  if self.advanceFuncUnlock_ then
    local advanceNodeId = self.weaponSkillVM_:GetResonanceAdvanceRedDotId(self.curSkillId_)
    if self.advanceNodeId_ and self.advanceNodeId_ ~= advanceNodeId then
      Z.RedPointMgr.RemoveNodeItem(self.advanceNodeId_, self)
    end
    self.advanceNodeId_ = advanceNodeId
    Z.RedPointMgr.LoadRedDotItem(self.advanceNodeId_, self, self.uiBinder.btn_operate.transform)
  end
end

function Weapon_resonance_skill_tipsView:unLoadRedDotItem()
  if self.activeNodeId_ then
    Z.RedPointMgr.RemoveNodeItem(self.activeNodeId_, self)
    self.activeNodeId_ = nil
  end
  if self.advanceFuncUnlock_ and self.advanceNodeId_ then
    Z.RedPointMgr.RemoveNodeItem(self.advanceNodeId_, self)
    self.advanceNodeId_ = nil
  end
end

function Weapon_resonance_skill_tipsView:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  self:refreshSkillCost()
end

return Weapon_resonance_skill_tipsView
