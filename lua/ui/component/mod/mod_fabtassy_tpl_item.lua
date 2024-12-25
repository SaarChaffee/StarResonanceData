local super = require("ui.component.loop_list_view_item")
local ModFabtassyTplItem = class("ModFabtassyTplItem", super)
local MOD_DEFINE = require("ui.model.mod_define")
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")
local ModFabtassyDotTplItem = require("ui.component.mod.mod_fabtassy_dot_tpl_item")

function ModFabtassyTplItem:OnInit()
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_tips, function()
    local viewData = {
      parent = self.parent.UIView.uiBinder.node_tips,
      effectId = self.effectId_,
      config = self.curConfig_
    }
    Z.UIMgr:OpenView("mod_item_popup", viewData)
  end)
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_dot, function()
    local text = ""
    if self.curConfig_ then
      if self.successsTimes_ > self.maxSuccessTimes_ then
        text = Lang("ModMaximumOpenLevelTips")
      elseif self.curUnlockConfig_ and self.successsTimes_ > self.curUnlockConfig_.EnhancementNum then
        text = Lang("ModCurrentOpenLevelTips", {
          val1 = self.curConfig_.Level,
          val2 = self.curConfig_.EnhancementNum
        })
      end
    end
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.rect_dot, text)
  end)
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_clock, function()
    Z.TipsVM.ShowTipsLang(1500001, {
      val = self.unlockConfig_.PlayerLevel
    })
  end)
end

function ModFabtassyTplItem:OnRefresh(data)
  self.data_ = data
  self:RefreshTpl(self.uiBinder, self.data_.effectId, self.data_.successTimes, self.parent.UIView, self.data_.isOnEffect)
end

function ModFabtassyTplItem:OnUnInit()
end

function ModFabtassyTplItem:RefreshTpl(uibinder, effectId, successsTime, view, isOnEffect)
  local effectConfigs = self.modData_:GetEffectTableConfigList(effectId)
  local tempEffectConfigCount = #effectConfigs
  self.effectId_ = effectId
  self.successsTimes_ = successsTime
  self.maxSuccessTimes_ = effectConfigs[tempEffectConfigCount].EnhancementNum
  local levelUnit = {}
  self.curConfig_ = nil
  self.curUnlockConfig_ = nil
  self.unlockConfig_ = nil
  local nextLevelConfig
  for _, config in ipairs(effectConfigs) do
    if self.successsTimes_ >= config.EnhancementNum and Z.ContainerMgr.CharSerialize.roleLevel.level >= config.PlayerLevel then
      self.curConfig_ = config
    elseif nextLevelConfig == nil then
      nextLevelConfig = config
    end
    levelUnit[config.EnhancementNum] = config.Level
    if Z.ContainerMgr.CharSerialize.roleLevel.level >= config.PlayerLevel then
      self.curUnlockConfig_ = config
    end
    if self.unlockConfig_ == nil and Z.ContainerMgr.CharSerialize.roleLevel.level < config.PlayerLevel then
      self.unlockConfig_ = config
    end
  end
  if nextLevelConfig == nil then
    nextLevelConfig = effectConfigs[#effectConfigs]
  end
  local showLevelIndex = self.curConfig_.EnhancementNum
  if Z.ContainerMgr.CharSerialize.roleLevel.level >= nextLevelConfig.PlayerLevel then
    showLevelIndex = nextLevelConfig.EnhancementNum
  end
  if self.curConfig_ then
    local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
    local text = ""
    if self.successsTimes_ > 0 then
      for _, addAttr in ipairs(self.curConfig_.AddAttribute) do
        local maxValue = math.min(self.successsTimes_, addAttr[3])
        text = text .. " " .. fightAttrParseVm.ParseFightAttrTips(addAttr[1], addAttr[2] * maxValue)
      end
    else
      text = Lang("ModCoreLinkEffectNotActivated", {
        val = effectConfigs[2].EnhancementNum
      })
    end
    uibinder.lab_lv.text = self.curConfig_.EffectName .. " " .. Lang("Grade", {
      val = self.curConfig_.Level
    })
    uibinder.lab_numerical.text = self.modVM_.ParseModEffectDesc(effectId, self.curConfig_.Level) .. " " .. text
    ModGlossaryItemTplItem.RefreshTpl(uibinder.mod_glossary_item_tpl, effectId, self.curConfig_.Level)
    if self.curConfig_.IsNegative then
      uibinder.img_base:SetImage(MOD_DEFINE.ModEffectIsNegative[2])
    else
      uibinder.img_base:SetImage(MOD_DEFINE.ModEffectIsNegative[1])
    end
    if self.successsTimes_ > self.maxSuccessTimes_ then
      uibinder.Ref:SetVisible(uibinder.img_dot, true)
      uibinder.img_dot:SetImage(MOD_DEFINE.ModEffectLevelTipsIcon.Over)
    elseif self.curUnlockConfig_ and self.successsTimes_ > self.curUnlockConfig_.EnhancementNum then
      uibinder.Ref:SetVisible(uibinder.img_dot, true)
      uibinder.img_dot:SetImage(MOD_DEFINE.ModEffectLevelTipsIcon.Warning)
    else
      uibinder.Ref:SetVisible(uibinder.img_dot, false)
    end
  end
  uibinder.lab_number.text = "+" .. self.successsTimes_
  if self.curUnlockConfig_.EnhancementNum < self.maxSuccessTimes_ then
    uibinder.Ref:SetVisible(uibinder.node_clock, true)
    local width = 4.3 + (self.maxSuccessTimes_ - self.curUnlockConfig_.EnhancementNum - 1) * 32.3 + 30 + (effectConfigs[tempEffectConfigCount].Level - self.curUnlockConfig_.Level) * 20
    uibinder.node_clock:SetWidth(width)
  else
    uibinder.Ref:SetVisible(uibinder.node_clock, false)
  end
  for i = 1, self.maxSuccessTimes_ do
    local unit = uibinder["mod_dot_tpl_" .. i]
    if unit then
      local isUnlock = true
      if self.curUnlockConfig_ then
        isUnlock = i <= self.curUnlockConfig_.EnhancementNum
      end
      if isUnlock then
        local empty = i > self.successsTimes_
        ModFabtassyDotTplItem.RefreshTpl(unit, empty, not empty, levelUnit[i], i == showLevelIndex)
      else
        ModFabtassyDotTplItem.RefreshTpl(unit, true, false, levelUnit[i], isUnlock)
      end
    end
  end
  uibinder.Ref:SetVisible(uibinder.img_mask, not isOnEffect)
end

return ModFabtassyTplItem
