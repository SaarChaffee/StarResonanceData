local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_refining_subView = class("Equip_refining_subView", super)
local listSubView = require("ui.view.equip_refining_list_sub_view")
local blessingSubView = require("ui.view.equip_blessing_sub_view")
local consumeItem = require("ui.component.equip.equip_refine_consume_item")
local blessingItem = require("ui.component.equip.equip_refine_blessing_loop_item")
local addBtnItem = require("ui.component.equip.equip_refine_add_loop_item")
local loop_list = require("ui.component.loop_list_view")
local addItemData = {IsAddBtn = true}

function Equip_refining_subView:ctor(parent)
  self.parent_ = parent
  self.uiBinder = nil
  super.ctor(self, "equip_refining_sub", "equip/equip_refining_sub", UI.ECacheLv.None, true)
  self.listSubView_ = listSubView.new(self)
  self.blessingSubView_ = blessingSubView.new(self)
  self.equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.equipRefineData_ = Z.DataMgr.Get("equip_refine_data")
  self.equipRefineVm_ = Z.VMMgr.GetVM("equip_refine")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Equip_refining_subView:initBinders()
  self.stateLab_ = self.uiBinder.lab_state
  self.stateDepth_ = self.uiBinder.lab_state_depth
  self.anim_ = self.uiBinder.anim
  self.partIcon_ = self.uiBinder.part_icon
  self.partLab_ = self.uiBinder.part_lab
  self.equipNameLab_ = self.uiBinder.lab_equip_assembly
  self.levelLab_ = self.uiBinder.lab_refining_level
  self.currentLevelLab_ = self.uiBinder.lab_current_level
  self.nextLevelLab_ = self.uiBinder.lab_next_level
  self.nextLevelArrowNode_ = self.uiBinder.img_arrow
  self.desLab_ = self.uiBinder.lab_des
  self.successRateLab_ = self.uiBinder.lab_success_rate
  self.baseRate_ = self.uiBinder.lab_original
  self.refineBtnNode_ = self.uiBinder.node_refine
  self.loopItem_ = self.uiBinder.loop_item
  self.professionIcon_ = self.uiBinder.img_profession_icon
  self.listSubParent_ = self.uiBinder.node_list_sub
  self.blessingSubParent_ = self.uiBinder.node_blessing_sub
  self.basicsItemNode_ = self.uiBinder.node_basics_item
  self.specialItemNode_ = self.uiBinder.node_special_item
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.refinepopupBtn_ = self.uiBinder.refinepopup_btn
  self.rightBottomNode_ = self.uiBinder.node_right_bottom
  self.pressNode_ = self.uiBinder.node_press
  self.failEffect_ = self.uiBinder.effect_fail
  self.successEffect_ = self.uiBinder.effect_succeed
  self.maxLevelNode_ = self.uiBinder.lab_high_level
  self.mask_ = self.uiBinder.mask
  self.pressNode_:StopCheck()
  self.blessingLoopItem_ = self.uiBinder.loop_blessing_item
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.failEffect_)
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.successEffect_)
  self.parent_.uiBinder.ui_depth:AddChildDepth(self.stateDepth_)
end

function Equip_refining_subView:initBtns()
  self:EventAddAsyncListener(self.pressNode_.ContainGoEvent, function(isCheck)
    self.uiBinder.Ref:SetVisible(self.stateLab_, false)
    if self.successEffectTimer_ then
      self.timerMgr:StopTimer(self.successEffectTimer_)
      self.successEffectTimer_ = nil
      self.anim_:ResetAniState("anim_equip_refining_sub_succeed_open")
    end
    if self.failEffectTimer_ then
      self.timerMgr:StopTimer(self.failEffectTimer_)
      self.failEffectTimer_ = nil
      self.anim_:ResetAniState("anim_equip_refining_sub_fail_open")
    end
    self.uiBinder.Ref:SetVisible(self.mask_, false)
    self.pressNode_:StopCheck()
    if self.isSuccess_ then
      Z.TipsVM.ShowTips(150016)
    else
      Z.TipsVM.ShowTips(150017)
    end
  end)
  self:AddAsyncClick(self.refineBtnNode_.btn, function()
    if not self.refineIsUnlock_ then
      return
    end
    if self.nextRefineRow_ then
      for k, v in ipairs(self.nextRefineRow_.RefineConsume) do
        local totalCount = self.itemsVM_.GetItemTotalCount(v[1])
        if totalCount < v[2] then
          local itemRow = Z.TableMgr.GetRow("ItemTableMgr", v[1])
          if itemRow then
            Z.TipsVM.ShowTips(150015, {
              val = itemRow.Name
            })
          end
          if self.sourceTipsId_ then
            Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
            self.sourceTipsId_ = nil
          end
          self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(v[1], self.refineBtnNode_.Trans)
          return
        end
      end
    end
    local func = function(...)
      self.uiBinder.Ref:SetVisible(self.mask_, true)
      Z.AudioMgr:Play("UI_Equipment_Rebuild")
      local itemCostList = {}
      local index = 1
      for key, value in pairs(self.equipRefineData_.CurSelBlessingData) do
        itemCostList[index] = {
          itemConfigId = value.configId,
          itemCount = value.num
        }
        index = index + 1
      end
      self.uiBinder.Ref:SetVisible(self.successRateLab_, false)
      self.isSuccess_ = self.equipRefineVm_.AsyncRefining(self.selectedPart_, itemCostList, self.cancelSource:CreateToken())
      self.pressNode_:StartCheck()
      self.uiBinder.Ref:SetVisible(self.stateLab_, true)
      if self.isSuccess_ then
        self.stateLab_.text = Lang("RefineSuccess")
        self.anim_:PlayOnce("anim_equip_refining_sub_succeed_open")
        Z.AudioMgr:Play("UI_Equipment_Rebuild_Success")
        self.successEffectTimer_ = self.timerMgr:StartTimer(function()
          self.pressNode_:StopCheck()
          self.uiBinder.Ref:SetVisible(self.mask_, false)
          Z.TipsVM.ShowTips(150016)
        end, 3, 1, nil, function()
          self.uiBinder.Ref:SetVisible(self.successRateLab_, true)
        end)
      else
        self.stateLab_.text = Lang("RefineFail")
        self.anim_:PlayOnce("anim_equip_refining_sub_fail_open")
        Z.AudioMgr:Play("UI_Equipment_Rebuild_Fail")
        self.failEffect_:Play()
        self.failEffectTimer_ = self.timerMgr:StartTimer(function()
          self.pressNode_:StopCheck()
          self.uiBinder.Ref:SetVisible(self.mask_, false)
          Z.TipsVM.ShowTips(150017)
        end, 3, 1, nil, function()
          self.uiBinder.Ref:SetVisible(self.successRateLab_, true)
        end)
      end
      self:refreshEquipInfo()
    end
    if self.equipRefineData_.CurrentSuccessRate < 100 then
      local val2 = self.curRefineRow_ and math.floor(self.curRefineRow_.FailCompensateRate / 100) or 0
      local labContent = ""
      if val2 == 0 then
        labContent = Lang("EquipRefineSuccessRateZeroTips", {
          val = self.equipRefineData_.CurrentSuccessRate
        })
      else
        labContent = Lang("EquipRefineSuccessRateTips", {
          val1 = self.equipRefineData_.CurrentSuccessRate,
          val2 = val2
        })
      end
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(labContent, function()
        func()
      end, nil, E.DlgPreferencesType.Login, Z.ConstValue.Equip.EquipRefineSuccessRateTips)
    else
      func()
    end
  end)
  self:AddClick(self.desLab_, function()
    self.equipRefineVm_.OpenRefinePopup(self.selectedPart_)
  end)
  self:AddClick(self.equipNameLab_, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    if self.partItem_ then
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.partLab_.transform, self.partItem_.configId, self.partItem_.uuid)
    end
  end)
end

function Equip_refining_subView:OpenBlessingSubView()
  if self.equipRefineData_.CurrentSuccessRate >= 100 then
    Z.TipsVM.ShowTips(150018)
    return
  end
  self.blessingSubView_:Active({
    part = self.selectedPart_
  }, self.blessingSubParent_.transform)
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
end

function Equip_refining_subView:initUi()
  self.uiBinder.Ref:SetVisible(self.mask_, false)
  self.uiBinder.Ref:SetVisible(self.stateLab_, false)
  self.selectedPart_ = E.EquipPart.Weapon
  if self.viewData and self.viewData.configId then
    local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.configId, true)
    if equipRow then
      self.selectedPart_ = equipRow.EquipPart
    end
  end
  local assetItemPath
  if Z.IsPCUI then
    assetItemPath = "com_item_square_2_8_pc"
  else
    assetItemPath = "equip_item_tpl_3_8"
  end
  self.loopListView_ = loop_list.new(self, self.loopItem_, consumeItem, assetItemPath)
  self.blessingListView_ = loop_list.new(self, self.blessingLoopItem_)
  self.blessingListView_:SetGetItemClassFunc(function(data)
    if data.IsAddBtn then
      return addBtnItem
    else
      return blessingItem
    end
  end)
  self.blessingListView_:SetGetPrefabNameFunc(function(data)
    local assetBlessingItemPath
    if data.IsAddBtn then
      assetBlessingItemPath = "equip_add_btn_tpl"
    else
      assetBlessingItemPath = assetItemPath
    end
    return assetBlessingItemPath
  end)
  self.blessingListView_:Init({})
  self.loopListView_:Init({})
  if self.listSubView_ then
    self.listSubView_:Active({
      part = self.selectedPart_,
      itemSelectedFunc = function(part)
        self:selectedPart(part)
      end
    }, self.listSubParent_.transform)
  end
  self.desLab_.text = Lang("EquipRefineNoteTips")
end

function Equip_refining_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self:onStartAnimShow()
  self:initBtns()
  self.equipRefineData_.CurSelBlessingData = {}
  self:initUi()
  self:refreshEquipInfo()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.RefreshEmptyState, true, "")
  Z.EventMgr:Add(Z.ConstValue.Equip.EquipRefreshSelBlessingData, self.refreshBlessingInfo, self)
end

function Equip_refining_subView:refreshBlessingInfo()
  local data = {}
  local index = 0
  local successRatet = 0
  for key, value in pairs(self.equipRefineData_.CurSelBlessingData) do
    index = index + 1
    data[index] = value
    successRatet = successRatet + value.rate
  end
  self:refreshBlessingList(data)
  self:setSuccessRateLab(self.successRate_, successRatet)
end

function Equip_refining_subView:refreshBlessingList(data)
  if #data < Z.Global.MaxEquipEnchantItemNum then
    data[#data + 1] = addItemData
  end
  self.blessingListView_:RefreshListView(data)
end

function Equip_refining_subView:refreshEquipInfo()
  self.equipPartRow_ = Z.TableMgr.GetRow("EquipPartTableMgr", self.selectedPart_)
  if self.equipPartRow_ then
    self.partIcon_:SetImage(self.equipPartRow_.PartIcon)
    self.partLab_.text = self.equipPartRow_.PartName
  end
  self.partItem_ = self.equipSystemVm_.GetItemByPartId(self.selectedPart_)
  if self.partItem_ then
    self.equipNameLab_.text = string.zconcat(Lang("EquipCurrentAssembly"), "<link>", self.itemsVM_.ApplyItemNameWithQualityTag(self.partItem_.configId), "</link>")
  else
    self.equipNameLab_.text = Lang("NotWearing")
  end
  self:refreshRefineInfo()
  self:refreshRefineBtnRed()
  self:refreshBlessingList({})
end

function Equip_refining_subView:setSuccessRateLab(baseRate, addRate)
  addRate = addRate and addRate or 0
  self.equipRefineData_:SetCurrentSuccessRate(baseRate + addRate)
  local str = Lang("UpgradeRate", {val = baseRate})
  self.uiBinder.Ref:SetVisible(self.baseRate_, addRate ~= 0)
  if addRate ~= 0 then
    local rateStr = Z.RichTextHelper.ApplyColorTag("+" .. addRate .. "%", "#FFC000")
    str = str .. Z.RichTextHelper.ApplySizeTag(rateStr, 30)
  end
  self.successRateLab_.text = str
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.RefineRateChange)
end

function Equip_refining_subView:loadBasicAttr()
  if self.basicUnits_ then
    for k, v in pairs(self.basicUnits_) do
      self:RemoveUiUnit(k)
    end
    self.basicUnits_ = {}
  end
  local basicItemPath = self.prefabCache_:GetString("basic_item")
  if basicItemPath == nil or basicItemPath == "" then
    return
  end
  self.basicUnits_ = {}
  local tab = self.equipRefineVm_.GetBasicAttrInfo(self.selectedPart_, self.currentLevel_, self.currentProfessionId_)
  if tab == nil or #tab == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(tab) do
      local unitName = "basic" .. k
      local unit = self:AsyncLoadUiUnit(basicItemPath, unitName, self.basicsItemNode_.transform)
      if unit then
        self.basicUnits_[unitName] = unit
        unit.lab_name.text = v.attrName
        unit.lab_current_level.text = v.nowValue or ""
        if v.nextValue then
          unit.lab_last_level.text = v.nextValue
        end
        unit.Ref:SetVisible(unit.lab_last_level, v.nextValue ~= nil)
        unit.Ref:SetVisible(unit.img_arrow, v.nextValue ~= nil)
      end
    end
  end)()
end

function Equip_refining_subView:refreshRefineInfo()
  self.currentLevel_ = 0
  if Z.ContainerMgr.CharSerialize.equip.equipList[self.selectedPart_] then
    self.currentLevel_ = Z.ContainerMgr.CharSerialize.equip.equipList[self.selectedPart_].equipSlotRefineLevel or 0
  end
  self.levelLab_.text = Lang("LevelReminderTips", {
    val = self.currentLevel_
  })
  self.currentLevelLab_.text = Lang("Level", {
    val = self.currentLevel_
  })
  self.currentProfessionId_ = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local professionSystemRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", self.currentProfessionId_)
  if professionSystemRow then
    self.professionIcon_:SetImage(professionSystemRow.Icon)
  end
  local currentLevelRefineId = self.equipRefineVm_.GetCurRefineIdByPart(self.selectedPart_, self.currentProfessionId_)
  if currentLevelRefineId == nil then
    return
  end
  local data = self.equipCfgData_.RefineTableData[currentLevelRefineId]
  if data then
    self.nextRefineRow_ = data[self.currentLevel_ + 1]
    self.curRefineRow_ = data[self.currentLevel_]
    self.uiBinder.Ref:SetVisible(self.nextLevelArrowNode_, self.nextRefineRow_ ~= nil)
    if self.nextRefineRow_ then
      self.uiBinder.Ref:SetVisible(self.rightBottomNode_, true)
      local descList = Z.ConditionHelper.GetConditionDescList(self.nextRefineRow_.Condition)
      self.refineIsUnlock_ = true
      local descData
      for i, v in ipairs(descList) do
        if not v.IsUnlock then
          self.refineIsUnlock_ = false
          descData = v
          break
        end
      end
      if not self.refineIsUnlock_ then
        if descData.tipsId == 1500001 then
          self.refineBtnNode_.lab_normal.text = Lang("RefineLevleInsufficientTips", descData.tipsParam)
        else
          self.refineBtnNode_.lab_normal.text = descData.Desc
        end
      else
        self.refineBtnNode_.lab_normal.text = Lang("EquipRefining")
      end
      self.nextLevelLab_.text = Lang("Level", {
        val = self.nextRefineRow_.RefineLevel
      })
      self.loopListView_:RefreshListView(self.nextRefineRow_.RefineConsume)
      self:refreshBasicRate()
      self.uiBinder.Ref:SetVisible(self.maxLevelNode_, false)
    else
      self.uiBinder.Ref:SetVisible(self.rightBottomNode_, false)
      self.maxLevelNode_.text = Lang("EquipRefineHighestLevel")
      self.uiBinder.Ref:SetVisible(self.maxLevelNode_, true)
    end
  end
  self:loadBasicAttr()
  self:loadLevleEffect()
end

function Equip_refining_subView:refreshBasicRate()
  if not self.nextRefineRow_ then
    return
  end
  local failedCount = 0
  if Z.ContainerMgr.CharSerialize.equip.equipList[self.selectedPart_] then
    failedCount = Z.ContainerMgr.CharSerialize.equip.equipList[self.selectedPart_].equipSlotRefineFailedCount or 0
  end
  self.successRate_ = math.floor((self.nextRefineRow_.SuccessRate + self.nextRefineRow_.FailCompensateRate * failedCount) / 100)
  self.baseRate_.text = math.floor(self.nextRefineRow_.SuccessRate / 100) .. Lang("PercentSigns")
  self.equipRefineData_:SetBaseSuccessRate(self.successRate_)
  self:setSuccessRateLab(self.successRate_, 0)
end

function Equip_refining_subView:loadLevleEffect()
  if self.effectUnits_ then
    for k, v in pairs(self.effectUnits_) do
      self:RemoveUiUnit(k)
    end
    self.effectUnits_ = {}
  end
  local refiningItemPath = self.prefabCache_:GetString("refining_item")
  if refiningItemPath == nil or refiningItemPath == "" then
    return
  end
  self.effectUnits_ = {}
  local tab = self.equipRefineVm_.GetRefineLevelEffect(self.selectedPart_, self.currentProfessionId_)
  if tab == nil or #tab == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(tab) do
      local unitName = "effect" .. k
      local unit = self:AsyncLoadUiUnit(refiningItemPath, unitName, self.specialItemNode_.transform)
      if unit then
        self.effectUnits_[unitName] = unit
        local str = Lang("EquipRefineLevle", {
          val = v.level
        }) .. ": " .. v.attrName
        if v.level > self.currentLevel_ then
          str = Z.RichTextHelper.ApplyColorTag(str, "#cdcdca")
        else
          str = Z.RichTextHelper.ApplyColorTag(str, "#EFC892")
        end
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.lab_name, str)
      end
    end
  end)()
end

function Equip_refining_subView:OnDeActive()
  self.failEffect_:Stop()
  if self.listSubView_ then
    self.listSubView_:DeActive()
  end
  if self.blessingSubView_ then
    self.blessingSubView_:DeActive()
  end
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  if self.blessingListView_ then
    self.blessingListView_:UnInit()
    self.blessingListView_ = nil
  end
  self.pressNode_:StopCheck()
  self.parent_.uiBinder.ui_depth:RemoveChildDepth(self.failEffect_)
  self.parent_.uiBinder.ui_depth:RemoveChildDepth(self.failEffect_)
  Z.CommonTipsVM.CloseRichText()
end

function Equip_refining_subView:selectedPart(part)
  if self.selectedPart_ == part then
    return
  end
  self.equipRefineData_.CurSelBlessingData = {}
  self.selectedPart_ = part
  self:refreshEquipInfo()
end

function Equip_refining_subView:refreshRefineBtnRed()
  local partRed = self.equipRefineVm_.GetRefinePartRedName(self.selectedPart_)
  self.refineBtnNode_.Ref:SetVisible(self.refineBtnNode_.c_com_reddot, Z.RedPointMgr.GetRedState(partRed))
end

function Equip_refining_subView:OnRefresh()
end

function Equip_refining_subView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Equip_refining_subView
