local UI = Z.UI
local super = require("ui.ui_subview_base")
local TipsItemInfoPopupView = class("TipsItemInfoPopupView", super)
local itemClass = require("common.item_binder")
local itemFunctionTable = Z.TableMgr.GetTable("ItemFunctionTableMgr")
local MAX_LOAD_ITEM_COUNT = 30
local MOD_DEFINE = require("ui.model.mod_define")
local ModItemCardTplItem = require("ui.component.mod.mod_item_card_tpl_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local warehouseTplView = require("ui.view.tips_warehouse_tpl_view")
local equipLockView = require("ui.view.equip_lock_popup_view")
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")
local ModFabtassyDotTplItem = require("ui.component.mod.mod_fabtassy_dot_tpl_item")
local Vitality = E.CurrencyType.Vitality
local equipAttrType = {equipAttrLib = 1, equipAttrSchoolLib = 2}

function TipsItemInfoPopupView:ctor(parent)
  super.ctor(self, "tips_item_info_popup", "common_tips/tips_item_info_popup", UI.ECacheLv.None, true)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.equipSystemVM_ = Z.VMMgr.GetVM("equip_system")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.buffAttrParseVM_ = Z.VMMgr.GetVM("buff_attr_parse")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.cookVM_ = Z.VMMgr.GetVM("cook")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.itemMaterialVm_ = Z.VMMgr.GetVM("item_material")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.warehouseVm_ = Z.VMMgr.GetVM("warehouse")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.tradeVM_ = Z.VMMgr.GetVM("trade")
  self.equipRefineVm_ = Z.VMMgr.GetVM("equip_refine")
  self.enchantVm_ = Z.VMMgr.GetVM("equip_enchant")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.preview_ = Z.VMMgr.GetVM("item_preview")
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.warehouseView_ = warehouseTplView.new(self)
  self.equipLockView_ = equipLockView.new(self)
end

function TipsItemInfoPopupView:initBinders()
  self.previewBtn_ = self.uiBinder.btn_preview
  self.prefabCacheData_ = self.uiBinder.prefab
  self.node_shared = self.uiBinder.node_shared
  self.warehouseParent_ = self.uiBinder.node_warehouse
  self.warehouseHeadNode_ = self.uiBinder.node_head
  self.warehouseHeadNameLab_ = self.uiBinder.lab_head_name
  self.warehouseTakeOutBtn_ = self.uiBinder.btn_take
  self.warehouseDepositBtn_ = self.uiBinder.btn_deposit
  self.wareHeadBinder_ = self.uiBinder.head
  self.wareBtnNode_ = self.uiBinder.node_warehousebtn
  self.equipInfoNode_ = self.uiBinder.equip_tips_icon_tpl
  self.equipPerfectLockBtn_ = self.uiBinder.btn_lock
  self.perfectNode_ = self.uiBinder.node_perfect
  self.uiBinder.Ref:SetVisible(self.previewBtn_, self.preview_.GetIsHavePreview(self.viewData.configId))
  self.cont_cook_time = self.uiBinder.cont_cook_time
  self.lab_next_recovery = self.uiBinder.lab_next_recovery
  self.lab_full_recovery = self.uiBinder.lab_full_recovery
  self.honourNode_ = self.uiBinder.cont_tips_honour
  self.refineNode_ = self.uiBinder.node_equip_refining
  self.refineItemNode_ = self.uiBinder.node_refining_item
  self.refineEmptyLab_ = self.uiBinder.lab_refining_empty
  self.refineLevelLab_ = self.uiBinder.lab_refine_level_special
  self.refineLevelNode_ = self.uiBinder.node_refining_level
  self.equipEnchantItemParent_ = self.uiBinder.node_enchant_item
  self.itemEnchantNode_ = self.uiBinder.node_item_enchant
  self.itemEnchantItemParent_ = self.uiBinder.node_item_enchant_parent
  self.equipSuitNode_ = self.uiBinder.node_equip_suit
  self.equipSuitLab_ = self.uiBinder.lab_suit_info
  self.contDesc3 = self.uiBinder.cont_tips_desc3
end

function TipsItemInfoPopupView:initUi()
  self.uiBinder.Ref:SetVisible(self.warehouseHeadNode_, false)
  self.uiBinder.Ref:SetVisible(self.warehouseDepositBtn_, false)
  self.uiBinder.Ref:SetVisible(self.warehouseTakeOutBtn_, false)
  self.uiBinder.Ref:SetVisible(self.wareBtnNode_, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_gs, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_equip_lv, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.img_bind, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.layout_cook, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_lv, false)
  self.uiBinder.Ref:SetVisible(self.cont_cook_time, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_count, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_school_dpd, false)
  self.uiBinder.Ref:SetVisible(self.equipSuitNode_, false)
  self.uiBinder.Ref:SetVisible(self.contDesc3, false)
  self:setEquipNodeState(false)
  self.honourNode_.Ref.UIComp:SetVisible(false)
  self.uiBinder.cont_tips_activitycounter.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.refineLevelLab_, false)
  self.uiBinder.Ref:SetVisible(self.refineLevelNode_, false)
  self.uiBinder.Ref:SetVisible(self.refineNode_, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip_enchant, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_TimeLimit, false)
  self.uiBinder.Ref:SetVisible(self.itemEnchantNode_, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_lv, false)
end

function TipsItemInfoPopupView:initBtns()
  self:AddClick(self.previewBtn_, function()
    self.preview_.GotoPreview(self.viewData.configId)
    if self.viewData.goToCallFunc then
      self.viewData.goToCallFunc()
    end
  end)
  self:AddClick(self.uiBinder.btn_school_des, function()
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.btn_school_des.transform, Lang("EquipSchoolTalentDes"))
  end)
  self:AddClick(self.equipPerfectLockBtn_, function()
    local text = self.equipLockTips_ or ""
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.node_perfect_tips.transform, text)
  end)
  self:AddAsyncClick(self.warehouseTakeOutBtn_, function()
    self.warehouseView_:TakeOutWarehouse()
  end, nil, nil)
  self:AddAsyncClick(self.warehouseDepositBtn_, function()
    self.warehouseView_:DepositWarehouse()
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_info, function()
    if self.isGetBtnDotShow_ then
      self.isGetBtnDotShow_ = false
      self:onShowGoOrHide()
    else
      self.isGetBtnDotShow_ = true
      self:onShowGoOrHide()
      self:setItemSource()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_material_use, function()
    if self.isShowUseMaterial_ then
      self.isShowUseMaterial_ = false
    else
      self.isShowUseMaterial_ = true
      self:setItemMaterial()
    end
    self:refreshUseMaterialState()
  end)
  local containGoEvent = self.uiBinder.press_check.ContainGoEvent
  self:EventAddAsyncListener(containGoEvent, function(isContainer)
    if not isContainer then
      Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
    end
  end, nil, nil)
end

function TipsItemInfoPopupView:OnActive()
  self:SetAsLastSibling()
  self:initBinders()
  self:initBtns()
  self.isGetBtnDotShow_ = false
  self.isShowUseMaterial_ = false
  self.equipUnits_ = {}
  self.equipUnitTokens_ = {}
  self.times_ = {}
  self.ItemClassTab = {}
  self.unitTokenDict_ = {}
  self:bindParentPressPointCheck()
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onCountChange, self)
end

function TipsItemInfoPopupView:onCountChange()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setItemSource()
  end)()
end

function TipsItemInfoPopupView:onShowGoOrHide()
  self.uiBinder.Ref:SetVisible(self.uiBinder.sizeFilter_scroll, not self.isGetBtnDotShow_ and not self.isShowUseMaterial_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goLeft, self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goRight, not self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scroll_source, self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_material_use, not self.isGetBtnDotShow_ and self.useMaterialList_ and #self.useMaterialList_ > 0)
end

function TipsItemInfoPopupView:refreshUseMaterialState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.sizeFilter_scroll, not self.isShowUseMaterial_ and not self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_material, self.isShowUseMaterial_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use_left, self.isShowUseMaterial_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use_right, not self.isShowUseMaterial_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, not self.isShowUseMaterial_ and not self.viewData.isHideSource and #self.itemSourceTab_ > 0)
end

function TipsItemInfoPopupView:OnDeActive()
  self:ClearAllUnits()
  self:unBindParentPressPointCheck()
  for _, itemClass in pairs(self.ItemClassTab) do
    itemClass:UnInit()
  end
  Z.CommonTipsVM.CloseRichText()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.CommonTipsVM.CloseTipsContent()
  Z.TipsVM.CloseItemTipsView()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.warehouseView_:DeActive()
  self.equipLockView_:DeActive()
  if self.viewData.parentTrans then
    self.uiBinder.press_check:RemoveGameObject(self.viewData.parentTrans.gameObject)
  end
  self.uiBinder.press_check:StopCheck()
  if Z.UIMgr:IsActive("mod_item_popup") then
    Z.UIMgr:CloseView("mod_item_popup")
  end
  if self.viewData.closeCallBack then
    self.viewData.closeCallBack()
    self.viewData.closeCallBack = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onCountChange, self)
end

function TipsItemInfoPopupView:bindParentPressPointCheck()
  if self.viewData.tipsBindPressCheckComp ~= nil then
    self.viewData.tipsBindPressCheckComp:AddChildPointPressCheck(self.uiBinder.press_check)
  end
end

function TipsItemInfoPopupView:unBindParentPressPointCheck()
  if self.viewData.tipsBindPressCheckComp ~= nil then
    self.viewData.tipsBindPressCheckComp:RemoveChildPointPressCheck(self.uiBinder.press_check)
  end
end

function TipsItemInfoPopupView:startAnimatedShow()
  self.uiBinder.uiAnima_anima:ResetAniState("anim_iteminfo_tips_002")
  if self.viewData.isPlay == nil then
    self.viewData.isPlay = true
  end
  if self.viewData.isPlay then
    self.uiBinder.uiAnima_anima:PlayOnce("anim_iteminfo_tips_001")
  end
end

function TipsItemInfoPopupView:startAnimatedHide()
  self.uiBinder.uiAnima_anima:PlayOnce("anim_iteminfo_tips_002")
end

function TipsItemInfoPopupView:getItemSource()
  self.itemSourceTab_ = self.itemSourceVm_.GetItemSource(self.viewData.configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, not self.viewData.isHideSource and #self.itemSourceTab_ > 0)
  if self.viewData.isOpenSource then
    self.isGetBtnDotShow_ = true
    self:setItemSource()
  end
end

function TipsItemInfoPopupView:getItemUseMaterial()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_material_use, false)
  if self.viewData.isHideMaterial then
    return
  end
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.viewData.configId)
  if not itemRow then
    return
  end
  local isShow = false
  for index, value in ipairs(Z.Global.ConsumableItemType) do
    if value == itemRow.Type then
      isShow = true
      break
    end
  end
  if not isShow then
    return
  end
  self.useMaterialList_ = self.itemMaterialVm_.GetItemMaterialData(self.viewData.configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_material_use, self.useMaterialList_ and #self.useMaterialList_ > 0)
end

function TipsItemInfoPopupView:OnRefresh()
  self.isGetBtnDotShow_ = false
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_fixed, false)
    self:initUi()
    self:setProperty()
    self:setUIStyle()
    self:getItemSource()
    self:getItemUseMaterial()
    self:onShowGoOrHide()
    self:refreshUseMaterialState()
    self:rebuildLayout()
    self:setPanelPos(false)
    self:initWarehouseItem()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_fixed, true)
    self:startAnimatedShow()
  end)()
end

function TipsItemInfoPopupView:setProperty()
  if self.viewData.isResident then
    self.uiBinder.press_check:StopCheck()
  else
    if self.viewData.parentTrans then
      self.uiBinder.press_check:AddGameObject(self.viewData.parentTrans.gameObject)
    end
    self.uiBinder.press_check:StartCheck()
  end
end

function TipsItemInfoPopupView:setUIStyle()
  self.uiBinder.img_bg.enabled = self.viewData.isShowBg and not self.viewData.isShowFixBg
  self.uiBinder.img_bg_fixed.enabled = self.viewData.isShowBg and self.viewData.isShowFixBg
  self:setContMaxHigh(self.viewData.isShowBg, self.viewData.isShowFixBg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equiped, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_time, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ModTip, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ItemTip, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_warehouse, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_shared, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_boss_rank, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_boss_time, false)
  self:refreshBaseInfo()
  self:craftEnergy()
  if self.itemsVM_.CheckPackageTypeByConfigId(self.viewData.configId, E.BackPackItemPackageType.Equip) then
    self:refreshEquipInfo()
  elseif self.itemsVM_.CheckPackageTypeByConfigId(self.viewData.configId, E.BackPackItemPackageType.Mod) then
    self:refreshModInfo()
  elseif self.itemsVM_.CheckPackageTypeByConfigId(self.viewData.configId, E.BackPackItemPackageType.ResonanceSkill) then
    self:refreshResonanceSkillInfo()
  else
    self:refreshItemInfo()
  end
  self:loadQualityEffect()
end

function TipsItemInfoPopupView:rebuildLayout()
  self.uiBinder.layout_rebuild:ForceRebuildLayoutImmediate()
end

function TipsItemInfoPopupView:setContMaxHigh(isShowBg, isShowFixBg)
  local maxHigh = 400
  if not isShowBg then
    maxHigh = 410
  end
  self.itemSourceTab_ = self.itemSourceVm_.GetItemSource(self.viewData.configId)
  local showSource = not self.viewData.isHideSource and #self.itemSourceTab_ > 0
  if isShowBg and isShowFixBg then
    maxHigh = showSource and 430 or 480
  end
  if self.viewData.maxHeight then
    maxHigh = self.viewData.maxHeight
  end
  self.uiBinder.node_viewport_source.MaxHeight = self.viewData.maxHeight or 396
  self.uiBinder.sizeFilter_viewPort.MaxHeight = maxHigh
  self.uiBinder.sizeFilter_scroll.MaxHeight = maxHigh
end

function TipsItemInfoPopupView:setPanelPos(isUseOriginalPos)
  local transBg = self.uiBinder.img_bg.rectTransform
  self.uiBinder.anim_trans:SetAnchorPosition(0, 0)
  if self.viewData.posType == E.EItemTipsPopType.Parent then
    self.uiBinder.Trans:SetSizeDelta(0, 0)
    self.uiBinder.Trans:SetAnchorPosition(0, 0)
    transBg:SetAnchorPosition(0, 0)
  elseif self.viewData.posType == E.EItemTipsPopType.Bounds then
    self.uiBinder.adapt_pos:UpdatePosition(self.viewData.parentTrans, true, false, isUseOriginalPos)
  elseif self.viewData.posType == E.EItemTipsPopType.WorldPosition then
    self.uiBinder.adapt_pos:UpdatePosition(self.viewData.parentTrans.position)
  elseif self.viewData.posType == E.EItemTipsPopType.ScreenPosition then
    local worldPos = ZTransformUtility.ScreenToWorldPoint(self.viewData.screenPosition, true)
    self.uiBinder.adapt_pos:UpdatePosition(worldPos, true)
  end
  if self.viewData.posOffset then
    local posSourceX, posSourceY = transBg:GetAnchorPosition(nil, nil)
    local posResult = Vector2.New(self.viewData.posOffset.x + posSourceX, self.viewData.posOffset.y + posSourceY)
    local sizeX, sizeY = transBg:GetSizeDelta(nil, nil)
    local pivot = transBg.pivot
    local width = sizeX * pivot.x
    local height = sizeY * pivot.y
    if posResult.x < -(Z.UIRoot.CurCanvasSafeSize.x - width) * 0.5 then
      posResult.x = posSourceX - self.viewData.posOffset.x
    end
    if posResult.y < -(Z.UIRoot.CurCanvasSafeSize.y - height) * 0.5 then
      posResult.y = posSourceY - self.viewData.posOffset.y
    end
    transBg:SetAnchorPosition(posResult.x, posResult.y)
  end
end

function TipsItemInfoPopupView:refreshBaseInfo()
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr")
  self.itemTableRow_ = itemTable.GetRow(self.viewData.configId)
  if self.itemTableRow_ == nil then
    logError("ItemTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", self.viewData.configId)
    return
  end
  local itemTypeTable = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local itemTypeTableRow = itemTypeTable.GetRow(self.itemTableRow_.Type)
  self.uiBinder.tmp_name.text = self.itemsVM_.ApplyItemNameWithQualityTag(self.viewData.configId)
  self.uiBinder.tmp_Type.text = itemTypeTableRow and itemTypeTableRow.Name or ""
  self.uiBinder.imp_Icon:SetImage(self.itemsVM_.GetItemIcon(self.viewData.configId))
  self.uiBinder.img_BgQuality:SetColor(Z.ConstValue.QualityBgColor[self.itemTableRow_.Quality])
  self.uiBinder.img_modbg_quality:SetColor(Z.ConstValue.QualityBgColor[self.itemTableRow_.Quality])
  local linkDatas = {}
  local affixStr = ""
  if self.itemsVM_.CheckItemIsKey(self.viewData.configId) then
    local itemUuid = self.viewData.itemUuid
    affixStr = self.itemsVM_.GetKeyAffixStr(itemUuid, E.BackPackItemPackageType.Item)
    local itemInfo = self.itemsVM_.GetItemInfo(itemUuid, E.BackPackItemPackageType.Item)
    if itemInfo then
      linkDatas = itemInfo.affixData.affixIds
    end
    if string.len(affixStr) > 0 then
      affixStr = "\n" .. Lang("KeyItemAffixInfo") .. affixStr
    end
  end
  local des = self.cookVM_.GetBuffDesById(self.viewData.configId)
  if des ~= "" then
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.tmp_Desc, string.zreplace(self.itemTableRow_.Description, "<br>", "\n") .. affixStr .. des)
    self.uiBinder.tmp_Desc2.text = self.itemTableRow_.Description2
  else
    self:refreshItemDesc(affixStr, des)
  end
  self.uiBinder.tmp_Desc:AddListener(function(key)
    local index = tonumber(key)
    local linkData = linkDatas[index]
    if linkData then
      Z.CommonTipsVM.OpenAffixTips({linkData}, self.uiBinder.transform)
    end
  end, true)
  if self.viewData.haveTime then
    self.uiBinder.tmp_time.text = Lang("UnlockRecipe") .. Z.TimeFormatTools.TicksFormatTime(self.viewData.haveTime * 1000, E.TimeFormatType.YMD)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_time, true)
  end
  if self.viewData.itemInfo == nil then
    self.viewData.itemInfo = self.itemsVM_.GetItemInfobyItemId(self.viewData.itemUuid, self.viewData.configId)
  end
  local itemInfo = self.viewData.itemInfo
  local canTrade = self.tradeVM_:CheckItemCanExchange(self.viewData.configId, self.viewData.itemUuid)
  if canTrade then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tips_exchange, true)
    local serverTime = Z.ServerTime:GetServerTime() / 1000
    if serverTime < itemInfo.coolDownExpireTime then
      local text = Lang("tips_exchange_coolDown", {
        time = Z.TimeFormatTools.FormatToDHMS(math.floor(itemInfo.coolDownExpireTime - serverTime), true)
      })
      self.uiBinder.lab_tips_exchange.text = text
    else
      self.uiBinder.lab_tips_exchange.text = Lang("Tradable")
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_tips_exchange, false)
  end
  local isBind = self.viewData.isBind or false
  if itemInfo then
    isBind = isBind or false
  end
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.img_bind, isBind)
  if isBind then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_shared, false)
  elseif self.viewData.itemUuid then
    local isWarehouseItem = self.warehouseVm_.CheckConfigIdIsGotoWarehouse(self.viewData.configId)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_shared, isWarehouseItem)
  end
  local bossExtendData = {}
  if itemInfo and itemInfo.extendAttr then
    for _, value in pairs(itemInfo.extendAttr) do
      local extendData = value
      local key = extendData.id
      bossExtendData[key] = extendData.value
    end
  end
  local bossData = bossExtendData[E.ItemExtendType.Rank]
  if bossData ~= nil then
    local rank = bossData
    local score = bossExtendData[E.ItemExtendType.BossValue]
    local creatTime = itemInfo.createTime
    local timeStrYMDHMS = Z.TimeFormatTools.TicksFormatTime(creatTime, E.TimeFormatType.YMDHMS)
    self.uiBinder.lab_boss_rank.text = Lang("WorldBossRankTips", {
      val = rank,
      num = score,
      time = timeStrYMDHMS
    })
    local expireTime = itemInfo.expireTime
    local timeStrYMDHMS1 = Z.TimeFormatTools.TicksFormatTime(expireTime, E.TimeFormatType.YMDHMS)
    self.uiBinder.lab_boss_time.text = Lang("WorldBossExpireTips", {time = timeStrYMDHMS1})
  end
  if self.viewData.configId == E.CurrencyType.Honour then
    local counterId
    for k, v in ipairs(Z.Global.ItemGainLimit) do
      local configId = v[1]
      if configId == E.CurrencyType.Honour then
        counterId = v[2]
      end
    end
    if counterId then
      self.honourNode_.Ref.UIComp:SetVisible(true)
      local limitCount = Z.CounterHelper.GetCounterLimitCount(counterId)
      local ownCount = Z.CounterHelper.GetOwnCount(counterId)
      self.honourNode_.lab_current_get.text = Lang("WeekGain", {
        val = ownCount .. "/" .. limitCount
      })
      local timerDes = Z.CounterHelper.GetCounterTimerDes(counterId)
      self.honourNode_.lab_refresh_time.text = Lang("HonorRefreshTime", {val = timerDes})
    end
  elseif self.viewData.configId == E.CurrencyType.Friendship then
    self.honourNode_.Ref.UIComp:SetVisible(true)
    local limitCount = Z.CounterHelper.GetCounterLimitCount(Z.Global.AssitRefresh)
    local currentNum = Z.CounterHelper.GetOwnCount(Z.Global.AssitRefresh)
    self.honourNode_.lab_current_get.text = Lang("AssistFightShopTips", {val1 = currentNum, val2 = limitCount})
    local timerDes = Z.CounterHelper.GetCounterTimerDes(Z.Global.AssitRefresh)
    self.honourNode_.lab_refresh_time.text = Lang("FriendshipRefreshTime", {val = timerDes})
    local activeCounterId
    for k, v in ipairs(Z.Global.RelaxGainLimit) do
      local configId = v[1]
      if configId == E.CurrencyType.Friendship then
        activeCounterId = v[2]
      end
    end
    if activeCounterId then
      self.uiBinder.cont_tips_activitycounter.Ref.UIComp:SetVisible(true)
      limitCount = Z.CounterHelper.GetCounterLimitCount(activeCounterId)
      currentNum = Z.CounterHelper.GetOwnCount(activeCounterId)
      self.uiBinder.cont_tips_activitycounter.lab_current_get.text = Lang("ActivityWeekGain", {val1 = currentNum, val2 = limitCount})
      timerDes = Z.CounterHelper.GetCounterTimerDes(activeCounterId)
      self.uiBinder.cont_tips_activitycounter.lab_refresh_time.text = Lang("FriendshipActivityRefreshTime", {val = timerDes})
    end
  end
  self:SetUIVisible(self.uiBinder.cont_boss_rank, bossData ~= nil)
  self:SetUIVisible(self.uiBinder.cont_boss_time, bossData ~= nil and 0 < itemInfo.expireTime)
end

function TipsItemInfoPopupView:refreshItemDesc(affixStr, des)
  if self.itemTableRow_.Id == Z.SystemItem.CompensationPoint then
    local compensationData = Z.ContainerMgr.CharSerialize.compenstionStatistics
    local param = {val1 = 0, val2 = 0}
    if compensationData then
      param.val1 = compensationData.curPoint
      param.val2 = compensationData.maxPoint
    end
    local desc = Z.Placeholder.Placeholder(self.itemTableRow_.Description, param)
    self.uiBinder.tmp_Desc.text = string.zreplace(desc, "<br>", "\n") .. affixStr .. des
    self.uiBinder.tmp_Desc2.text = self.itemTableRow_.Description2
  else
    self.uiBinder.tmp_Desc.text = string.zreplace(self.itemTableRow_.Description, "<br>", "\n") .. affixStr .. des
    self.uiBinder.tmp_Desc2.text = self.itemTableRow_.Description2
  end
end

function TipsItemInfoPopupView:loadQualityEffect()
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.node_effect_quality, false)
  local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.viewData.configId, true)
  if self.itemTableRow_ and equipRow then
    local path = "ui/prefabs/item_eff/item_tips_light_tpl_perfect"
    if equipRow.QualitychiIdType ~= 0 then
      Z.CoroUtil.create_coro_xpcall(function()
        local unit = self:AsyncLoadUiUnit(path, "quality_effect" .. self.viewData.configId, self.equipInfoNode_.node_effect_quality.transform)
        if unit then
          unit.Trans:SetOffsetMax(0, 0)
          unit.Trans:SetOffsetMin(0, 0)
          self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.node_effect_quality, true)
          local animName = Z.ConstValue.ItemTipsPerfectEffAnimName[self.itemTableRow_.Quality]
          if animName then
            unit.anim:PlayByTime(animName, -1)
          end
        end
      end)()
    end
  end
end

function TipsItemInfoPopupView:refreshItemInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ItemTip, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_UseLimit, false)
  local isOwnItem = not self.viewData.showType or self.viewData.showType == E.EItemTipsShowType.Default or self.viewData.itemInfo
  if isOwnItem then
    self:setOwnItemInfo()
  end
  local itemFunctionTableRow = itemFunctionTable.GetRow(self.viewData.configId, true)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.viewData.configId, true)
  if itemFunctionTableRow and itemFunctionTableRow.Type == E.ItemFunctionType.Gift then
    self:setGiftInfo(itemFunctionTableRow)
  elseif itemRow and itemRow.Type == E.ItemType.Blueprint then
    self:setBlueprintInfo()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_useGetItem, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  end
  self:setEnchantItemInfo()
end

function TipsItemInfoPopupView:setOwnItemInfo()
  if self.viewData.itemInfo == nil then
    self.viewData.itemInfo = self.itemsVM_.GetItemInfobyItemId(self.viewData.itemUuid, self.viewData.configId)
  end
  local itemInfo = self.viewData.itemInfo
  if itemInfo == nil then
    return
  end
  local count = itemInfo.count or 0
  self.uiBinder.tmp_count.text = Lang("Count") .. ": " .. count
  self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_count, true)
  if self.itemTableRow_.TimeType ~= 4 and itemInfo.expireTime and 0 < itemInfo.expireTime then
    local param = {
      str = Z.TimeFormatTools.TicksFormatTime(itemInfo.expireTime, E.TimeFormatType.YMDHMS)
    }
    local timeDesc = itemInfo.invalid and itemInfo.invalid == 1 and Lang("Tips_TimeLimit_InValid", param) or Lang("Tips_TimeLimit_Valid", param)
    self.uiBinder.tmp_TimeLimit.text = timeDesc
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_TimeLimit, true)
  end
end

function TipsItemInfoPopupView:setGiftInfo(itemFunctionTableRow)
  local awardId = tonumber(itemFunctionTableRow.Parameter[1])
  local awardTable = Z.TableMgr.GetTable("AwardPackageTableMgr")
  local awardTableRow = awardTable.GetRow(awardId)
  if awardTableRow == nil then
    logError("AwardPackageTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", awardId)
    return
  end
  if awardTableRow.HidePreview == 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_useGetItem, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  else
    local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(awardId)
    self:loadItemUnit(awardList, self.uiBinder.node_useGetItem, self.uiBinder.node_ListFixed, "itemFixed")
    self:setItemTitle(awardTableRow, awardList)
  end
end

function TipsItemInfoPopupView:loadItemUnit(itemArray, groupWidget, itemWidget, unitName)
  if itemArray == nil or next(itemArray) == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.Ref:SetVisible(groupWidget, false)
    return
  end
  local utilPath = self.prefabCacheData_:GetString("item")
  for index, itemData in ipairs(itemArray) do
    if index > MAX_LOAD_ITEM_COUNT then
      break
    end
    local itemName = table.zconcat({
      unitName,
      self.viewData.tipsId,
      index
    }, "_")
    local unit = self:AsyncLoadUiUnit(utilPath, itemName, itemWidget.transform)
    if unit ~= nil then
      self.ItemClassTab[itemName] = itemClass.new(self)
      local isBind = self.viewData.isBind or false
      if not isBind then
        local itemInfo = self.viewData.itemInfo
        if itemInfo == nil then
          itemInfo = self.itemsVM_.GetItemInfobyItemId(self.viewData.itemUuid, self.viewData.configId)
        end
        if itemInfo then
          isBind = itemInfo.bindFlag == 0
        end
      end
      local itemClassData = {}
      itemClassData.uiBinder = unit
      itemClassData.configId = itemData.awardId
      local press_check
      if not self.viewData.isResident then
        press_check = self.uiBinder.press_check
      end
      if not self.viewData.isIgnoreItemClick then
        function itemClassData.clickCallFunc()
          local posX_ = self.uiBinder.img_bg_recttrans.anchoredPosition.x
          
          local offset_
          if posX_ < 0 then
            offset_ = Vector2.New(580, 0)
          else
            offset_ = Vector2.New(-580, 0)
          end
          local extraParams = {
            posType = E.EItemTipsPopType.WorldPosition,
            posOffset = offset_,
            isIgnoreItemClick = true,
            goToCallFunc = self.viewData.goToCallFunc,
            tipsBindPressCheckComp = press_check,
            isBind = isBind
          }
          if self.tipsId_ then
            Z.TipsVM.CloseItemTipsView(self.tipsId_)
          end
          self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.img_bg.transform, itemData.awardId, nil, extraParams)
        end
      end
      itemClassData.labType, itemClassData.lab = self.awardPreviewVM_.GetPreviewShowNum(itemData)
      itemClassData.isSquareItem = true
      itemClassData.isShowZero = false
      itemClassData.PrevDropType = itemData.PrevDropType
      if not self.viewData.isResident then
        itemClassData.tipsBindPressCheckComp = press_check
      end
      itemClassData.isBind = isBind
      self.ItemClassTab[itemName]:Init(itemClassData)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
  self.uiBinder.Ref:SetVisible(groupWidget, true)
end

function TipsItemInfoPopupView:setBlueprintInfo()
  local consumeList = self.itemMaterialVm_.GetItemConsumeList(self.viewData.configId)
  if consumeList then
    self:loadBlueprintItemUnit(consumeList, self.uiBinder.node_useGetItem, self.uiBinder.node_ListFixed, "item_consume")
  end
end

function TipsItemInfoPopupView:loadBlueprintItemUnit(itemList, groupWidget, itemWidget, unitName)
  if itemList == nil or next(itemList) == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.Ref:SetVisible(groupWidget, false)
    return
  end
  for unitName, unitToken in pairs(self.unitTokenDict_) do
    Z.CancelSource.ReleaseToken(unitToken)
  end
  self.unitTokenDict_ = {}
  local utilPath = self.prefabCacheData_:GetString("item")
  for index, itemData in ipairs(itemList) do
    if index > MAX_LOAD_ITEM_COUNT then
      break
    end
    local configId = itemData[1]
    local consumeNum = itemData[2]
    local itemName = table.zconcat({
      unitName,
      self.viewData.tipsId,
      index
    }, "_")
    local token = self.cancelSource:CreateToken()
    self.unitTokenDict_[itemName] = token
    local unit = self:AsyncLoadUiUnit(utilPath, itemName, itemWidget.transform, token)
    if unit ~= nil then
      self.ItemClassTab[itemName] = itemClass.new(self)
      do
        local itemClassData = {}
        itemClassData.uiBinder = unit
        itemClassData.configId = configId
        local press_check
        if not self.viewData.isResident then
          press_check = self.uiBinder.press_check
        end
        if not self.viewData.isIgnoreItemClick then
          function itemClassData.clickCallFunc()
            local posX_ = self.uiBinder.img_bg_recttrans.anchoredPosition.x
            
            local offset_
            if posX_ < 0 then
              offset_ = Vector2.New(580, 0)
            else
              offset_ = Vector2.New(-580, 0)
            end
            local extraParams = {
              posType = E.EItemTipsPopType.WorldPosition,
              posOffset = offset_,
              isIgnoreItemClick = true,
              goToCallFunc = self.viewData.goToCallFunc,
              tipsBindPressCheckComp = press_check
            }
            if self.tipsId_ then
              Z.TipsVM.CloseItemTipsView(self.tipsId_)
            end
            self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.img_bg.transform, configId, nil, extraParams)
          end
        end
        itemClassData.labType = E.ItemLabType.Expend
        itemClassData.isSquareItem = true
        itemClassData.lab = self.itemsVM_.GetItemTotalCount(configId)
        itemClassData.expendCount = consumeNum
        if not self.viewData.isResident then
          itemClassData.tipsBindPressCheckComp = press_check
        end
        self.ItemClassTab[itemName]:Init(itemClassData)
      end
    end
  end
  self.uiBinder.tmp_fixedTitle.text = Lang("MakeNeedItem")
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
  self.uiBinder.Ref:SetVisible(groupWidget, true)
end

function TipsItemInfoPopupView:setItemTitle(awardTableRow, awardList)
  if awardList == nil or next(awardList) == nil then
    return
  end
  local isProbability = false
  for i, v in ipairs(awardList) do
    if v.PrevDropType == E.AwardPrevDropType.Probability then
      isProbability = true
      break
    end
  end
  if awardTableRow.PackType == Z.PbEnum("EAwardType", "EAwardTypeSelect") then
    self.uiBinder.tmp_fixedTitle.text = Lang("tipsItemInfoPopupSelectFixedTitle")
  elseif isProbability then
    self.uiBinder.tmp_fixedTitle.text = Lang("tipsItemInfoPopupProbabilityTitle")
  else
    self.uiBinder.tmp_fixedTitle.text = Lang("tipsItemInfoPopupDefaultFixedTitle")
  end
end

function TipsItemInfoPopupView:setItemSource()
  self.itemSourceVm_.SetPanelItemSource(self, self.viewData.configId, self.viewData.tipsId, self.itemSourceTab_, self.viewData.isResident, self.viewData.goToCallFunc, Z.IsPCUI)
  self:rebuildLayout()
  self:setPanelPos(true)
end

function TipsItemInfoPopupView:setItemMaterial()
  if self.useMaterialList_ then
    self.itemMaterialVm_.LoadMaterialItem(self, self.uiBinder.material_content, self.useMaterialList_, self.viewData.isResident, self.viewData.goToCallFunc, self.uiBinder.press_check)
  end
  self:rebuildLayout()
  self:setPanelPos(true)
end

function TipsItemInfoPopupView:setEnchantItemInfo()
  local row = Z.TableMgr.GetRow("EquipEnchantItemTableMgr", self.viewData.configId, true)
  if row then
    self.uiBinder.Ref:SetVisible(self.itemEnchantNode_, true)
    self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_lv, true)
    self.equipInfoNode_.lab_lv.text = Lang("LvFormatSymbol", {
      val = row.EnchantItemLevel
    })
    local path = self.prefabCacheData_:GetString("enchant_item")
    if path == "" or path == nil then
      return
    end
    local nowEnchantAttr = self.enchantVm_.GetAttrByEnchantItemRow(row)
    for k, data in ipairs(nowEnchantAttr) do
      local unitName = "item_enchant" .. k
      local token = self.cancelSource:CreateToken()
      self.equipUnitTokens_[unitName] = token
      local unit = self:AsyncLoadUiUnit(path, unitName, self.itemEnchantItemParent_.transform, token)
      if unit then
        local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
        unit.Ref:SetVisible(unit.lab_content, isBuffAttr)
        unit.Ref:SetVisible(unit.node_lab_01, not isBuffAttr)
        if isBuffAttr then
          unit.lab_content.text = data.buffInfo
        else
          unit.lab_nature.text = data.attrName
          unit.lab_number.text = "+" .. data.attrValue
        end
        self.equipUnits_[unitName] = unit
      end
    end
  end
end

function TipsItemInfoPopupView:setEquipNodeState(state)
  self.uiBinder.Ref:SetVisible(self.equipPerfectLockBtn_, state)
  self.isCanRecast_ = self.equipSystemVM_.CheckCanRecast(self.viewData.itemUuid, self.viewData.configId)
  self.uiBinder.Ref:SetVisible(self.perfectNode_, self.isCanRecast_)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_recast_count, self.isCanRecast_)
end

function TipsItemInfoPopupView:refreshEquipInfo()
  for key, token in pairs(self.equipUnitTokens_) do
    Z.CancelSource.ReleaseToken(token)
  end
  self.equipUnitTokens_ = {}
  for name, nuit in pairs(self.equipUnits_) do
    self:RemoveUiUnit(name)
  end
  self.equipUnits_ = {}
  local isOwnEquip = not self.viewData.showType or self.viewData.showType == E.EItemTipsShowType.Default or self.viewData.itemInfo
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipBasics, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ItemTip, true)
  local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.viewData.configId)
  if not equipRow then
    return
  end
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_gs, true)
  self.equipInfoNode_.lab_gs.text = Lang("GSEqual", {
    val = equipRow.EquipGs
  })
  if #equipRow.WearCondition > 0 then
    local conditionType = equipRow.WearCondition[1][1]
    local conditionValue = equipRow.WearCondition[1][2]
    if conditionType == E.ConditionType.Level then
      self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_equip_lv, true)
      self.equipInfoNode_.lab_equip_lv.text = Lang("EquipPutLevel", {val = conditionValue})
    end
  end
  self:setRefineInfo()
  self:setEnchantInfo()
  if isOwnEquip then
    self:setOwnEquipInfo()
  else
    self.equipInfoNode_.lab_recast_count.text = Lang("RecastCount", {val = 0})
    self.uiBinder.lab_perfection_num.text = Lang("EquipNoRecastingState")
    self.uiBinder.Ref:SetVisible(self.equipPerfectLockBtn_, false)
    self.equipInfoNode_.img_progress.fillAmount = 0
    self.equipInfoNode_.img_progress_02.fillAmount = 0
    local basicAttrTab = self.equipAttrParseVM_.GetEquipBasicAttrData(self.viewData.configId)
    self:setEquipAttr({
      basicAttr = basicAttrTab,
      recastAttr = {}
    }, true)
  end
end

function TipsItemInfoPopupView:setOwnEquipInfo()
  local itemInfo = self.viewData.itemInfo
  if itemInfo == nil then
    itemInfo = self.itemsVM_.GetItemInfobyItemId(self.viewData.itemUuid, self.viewData.configId)
  end
  if itemInfo == nil then
    return
  end
  local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.viewData.configId]
  if levels then
    local rowId = levels[itemInfo.equipAttr.breakThroughTime]
    if rowId then
      local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
      if breakThroughRow then
        self.equipInfoNode_.lab_gs.text = Lang("GSEqual", {
          val = breakThroughRow.EquipGs
        })
      end
    end
  end
  self:setEquipNodeState(true)
  self.equipAttr_ = itemInfo.equipAttr
  self.equipInfoNode_.lab_recast_count.text = Lang("RecastCount", {
    val = self.equipAttr_.totalRecastCount
  })
  self.uiBinder.Ref:SetVisible(self.perfectNode_, self.equipAttr_.perfectionValue ~= 0)
  local maxPerfectionValue = self.equipAttr_.maxPerfectionValue == 0 and 100 or self.equipAttr_.maxPerfectionValue
  self.uiBinder.lab_perfection_num.text = Lang("EquipPerfaceLab") .. Lang("season_achievement_progress", {
    val1 = self.equipAttr_.perfectionValue,
    val2 = maxPerfectionValue
  })
  self.equipInfoNode_.img_progress.fillAmount = self.equipAttr_.perfectionValue / 100
  self.equipInfoNode_.img_progress_02.fillAmount = (100 - maxPerfectionValue) / 100
  local width = self.equipInfoNode_.img_progress_02.rectTransform.rect.width
  self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = maxPerfectionValue}) or ""
  local x = width * (maxPerfectionValue / 100)
  self.equipInfoNode_.rect_lock:SetAnchorPosition(x - self.equipInfoNode_.rect_lock.rect.width / 2, -20)
  local partEquipInfo = self.equipSystemVM_.GetSamePartEquipAttr(self.viewData.configId)
  local isPartEquiped = partEquipInfo and partEquipInfo.itemUuid == self.viewData.itemUuid
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equiped, isPartEquiped)
  self:setEquipAttr(self.equipAttr_)
end

function TipsItemInfoPopupView:getAttrData(attrArray, isPreview)
  local attrData = {}
  if not isPreview then
    attrData = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrArray)
  else
    attrData = attrArray
  end
  return attrData
end

function TipsItemInfoPopupView:setEquipAttr(equipAttr, isPreview)
  self.isPreview_ = isPreview
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  if curProfessionId then
    local talentSchoolId = self.equipCfgData_.TalentSchoolMap[self.talentSkillVm_.GetProfressionTalentStage(curProfessionId)]
    self:setSuitInfo(talentSchoolId)
  end
  local equipTableRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.configId)
  if not equipTableRow then
    return
  end
  if equipTableRow.BasicAttrLibId[1] == equipAttrType.equipAttrSchoolLib or equipTableRow.AdvancedAttrLibId[1] == equipAttrType.equipAttrSchoolLib or self.equipCfgData_.EquipBreakIdLevelMap[self.viewData.configId] then
    self:initBreakEquipAttrs()
  end
  if equipTableRow.BasicAttrLibId[1] ~= equipAttrType.equipAttrSchoolLib then
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.basicAttr, isPreview), self.uiBinder.node_BasicItem, "baseAttrInfo", true, isPreview)
  else
    self:loadSchoolAttrUnits(1, true, isPreview)
  end
  if equipTableRow.AdvancedAttrLibId[1] == equipAttrType.equipAttrSchoolLib then
    self:loadSchoolAttrUnits(1, false, isPreview)
  elseif isPreview then
    local externAttrArray = self.equipAttrParseVM_.GetEquipExternAttrData(self.viewData.configId)
    self:loadEquipAttrUnit(self:getAttrData(externAttrArray, isPreview), self.uiBinder.node_SpecialItem, "advanceAttrInfo", false, isPreview)
  else
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.rareQualityAttr, isPreview), self.uiBinder.node_SpecialItem, "rareQualityAttrInfo", false, isPreview, false, true)
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.advanceAttr, isPreview), self.uiBinder.node_SpecialItem, "advanceAttrInfo", false, isPreview)
  end
  if self.equipSystemVM_.CheckCanRecast(nil, self.viewData.configId) then
    self:loadEquipAttrUnit(self:getAttrData(equipAttr.recastAttr, isPreview), self.uiBinder.node_SpecialItem, "recastAttrInfo", false, isPreview, true)
  end
end

function TipsItemInfoPopupView:loadEquipAttrUnit(attrData, attrWidget, unitName, isBaseAttr, isPreview, isRecastAttr, isRare)
  if not isRecastAttr and (attrData == nil or table.zcount(attrData) == 0) then
    self.uiBinder.Ref:SetVisible(attrWidget, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, false)
    if isBaseAttr then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipBasics, false)
    end
    return
  end
  local equipRow
  if isRare then
    equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.configId)
    if not equipRow or equipRow.QualitychiIdType == 0 then
      return
    end
  end
  local utilPath = Z.ConstValue.Unit_equip_arr_tpl
  if isPreview then
    utilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
  end
  if Z.IsPCUI then
    utilPath = utilPath .. "_pc"
  end
  local contrastAttrData
  if not isPreview and self.viewData.data then
    if isRecastAttr then
      contrastAttrData = self.viewData.data.RecastAttrEffectDatas
    elseif isBaseAttr then
      contrastAttrData = self.viewData.data.BasicAttrEffectDatas
    elseif isRare then
      contrastAttrData = self.viewData.data.RareAttrEffectDatas
    else
      contrastAttrData = self.viewData.data.AdvanceAttrEffectDatas
    end
  end
  if attrData and 0 < #attrData then
    local recommendAttrs, recommendDescAttrs = self.fightAttrParseVm_.GetRecommendFightAttrId()
    for key, value in ipairs(attrData) do
      local name = table.zconcat({
        unitName,
        self.viewData.tipsId,
        key
      }, isRecastAttr and "recastAttr" or "_")
      local token = self.cancelSource:CreateToken()
      self.equipUnitTokens_[name] = token
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform, token)
      if unit then
        self.equipUnits_[name] = unit
        if isPreview then
          unit.Ref:SetVisible(unit.img_bg, false)
          unit.tmp_Desc.text = Lang("EquipNoRecastingState")
        else
          unit.Ref:SetVisible(unit.img_bg, isRecastAttr)
          self:setAttrDifference(contrastAttrData, value.attrId, value.attrValue, unit)
          self:setAttrRecommendIcon(value.attrId, recommendAttrs, recommendDescAttrs, unit)
          local name = isPreview and Lang("EquipNoRecastingState") or value.des
          local num = isPreview and "" or value.attrValue
          if isRare then
            name = Z.RichTextHelper.ApplyColorTag(name, E.EquipRareQualityColor[equipRow.QualitychiIdType])
            num = Z.RichTextHelper.ApplyColorTag(num, E.EquipRareQualityColor[equipRow.QualitychiIdType])
            unit.img_icon:SetColorByHex(E.EquipRareQualityColor[equipRow.QualitychiIdType])
          else
            if not value.IsFitProfessionAttr then
              name = Z.RichTextHelper.ApplyColorTag(name, Z.Global.EquipAttColourNotSuitable)
              num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
            end
            unit.img_icon:SetColorByHex(E.ColorHexValues.White)
          end
          unit.lab_name.text = name
          unit.lab_num.text = num
          unit.img_icon:SetImage(value.iconPath)
        end
      end
    end
  elseif isRecastAttr then
    utilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
    if Z.IsPCUI then
      utilPath = utilPath .. "_pc"
    end
    local name = table.zconcat({
      unitName,
      self.viewData.tipsId,
      "recastAttr"
    }, "_")
    local token = self.cancelSource:CreateToken()
    self.equipUnitTokens_[name] = token
    local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform, token)
    if unit then
      unit.Ref:SetVisible(unit.img_bg, true)
      self.equipUnits_[name] = unit
      if isPreview then
        unit.tmp_Desc.text = Lang("EquipNoRecastingState")
      else
        unit.tmp_Desc.text = Z.RichTextHelper.ApplyColorTag(Lang("EquipNoRecastingState") .. Lang("RecastUnLock"), Z.Global.EquipAttColourNotActive)
      end
    end
  end
  if isBaseAttr then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipBasics, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, true)
  self.uiBinder.Ref:SetVisible(attrWidget, true)
end

function TipsItemInfoPopupView:setAttrDifference(curPutAttrs, attrId, attrValue, item)
  local type = 0
  if curPutAttrs then
    type = self.equipAttrParseVM_.CheckAttrEffectDataDiff(attrId, attrValue, curPutAttrs)
  end
  item.Ref:SetVisible(item.img_up_or_down, type ~= 0)
  if type == 1 then
    item.img_up_or_down:SetImage("ui/atlas/new_com/com_tips_img_down")
  elseif type == -1 then
    item.img_up_or_down:SetImage("ui/atlas/new_com/com_tips_img_up")
  end
end

function TipsItemInfoPopupView:setAttrRecommendIcon(attrId, recommendAttrs, recommendDescAttrs, item)
  item.Ref:SetVisible(item.img_praise, table.zcontains(recommendAttrs, attrId))
  self:AddAsyncClick(item.node_btn, function()
    self.fightAttrParseVm_.ShowRecommendAttrsTips(item.Trans, recommendDescAttrs)
  end)
end

function TipsItemInfoPopupView:setRefineInfo()
  if not self.funcVM_.CheckFuncCanUse(E.EquipFuncId.EquipRefine, true) then
    self.uiBinder.Ref:SetVisible(self.refineNode_, false)
    return
  end
  local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.viewData.configId, false)
  if not equipRow then
    return
  end
  self.uiBinder.Ref:SetVisible(self.refineNode_, true)
  local currentLevel = 0
  if Z.ContainerMgr.CharSerialize.equip.equipList[equipRow.EquipPart] then
    currentLevel = Z.ContainerMgr.CharSerialize.equip.equipList[equipRow.EquipPart].equipSlotRefineLevel or 0
  end
  if currentLevel == 0 then
    self.uiBinder.Ref:SetVisible(self.refineEmptyLab_, true)
    self.refineEmptyLab_.text = Z.RichTextHelper.ApplyColorTag(Lang("EquipPartunrefinedTips"), Z.Global.EquipAttColourNotActive)
    return
  end
  self.uiBinder.Ref:SetVisible(self.refineEmptyLab_, false)
  local currentProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  if currentProfessionId == 0 then
    return
  end
  local unitPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
  if Z.IsPCUI then
    unitPath = string.zconcat(unitPath, "_pc")
  end
  local tab = self.equipRefineVm_.GetBasicAttrInfo(equipRow.EquipPart, currentLevel, currentProfessionId)
  if tab and 0 < #tab then
    for k, v in ipairs(tab) do
      local name = "refine_basic" .. k
      local token = self.cancelSource:CreateToken()
      self.equipUnitTokens_[name] = token
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.refineItemNode_.transform, token)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, false)
        self.equipUnits_[name] = unit
        unit.tmp_Desc.text = v.attrName .. "+" .. v.nowValue
      end
    end
  end
  local tab = self.equipRefineVm_.GetRefineLevelEffect(equipRow.EquipPart, currentProfessionId)
  if tab and 0 < #tab then
    self.uiBinder.Ref:SetVisible(self.refineLevelLab_, true)
    self.uiBinder.Ref:SetVisible(self.refineLevelNode_, true)
    for k, v in ipairs(tab) do
      local name = "refine_effect" .. k
      local token = self.cancelSource:CreateToken()
      self.equipUnitTokens_[name] = token
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.refineLevelNode_.transform, token)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, false)
        self.equipUnits_[name] = unit
        local str = Lang("EquipRefineLevle", {
          val = v.level
        }) .. ": " .. v.attrName
        if currentLevel >= v.level then
          str = Z.RichTextHelper.ApplyColorTag(str, "#EFC892")
        else
          str = Z.RichTextHelper.ApplyColorTag(str, Z.Global.EquipAttColourNotActive)
        end
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.tmp_Desc, str)
      end
    end
  end
end

function TipsItemInfoPopupView:setEnchantInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip_enchant, false)
  if not self.funcVM_.CheckFuncCanUse(E.EquipFuncId.EquipEnchant, true) or not self.equipSystemVM_.CheckCanEnchant(self.viewData.itemUuid, self.viewData.configId) then
    return
  end
  local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.viewData.configId, false)
  if not equipRow or equipRow.EnchantId == 0 then
    return
  end
  local path = self.prefabCacheData_:GetString("enchant_item")
  if path == "" or path == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip_enchant, true)
  local equipEnchantInfo = Z.ContainerMgr.CharSerialize.equip.equipEnchant[self.viewData.itemUuid]
  if equipEnchantInfo then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_enchant_empty, false)
    local curEnchantRow = self.enchantVm_.GetEnchantItemByTypeAndLevel(equipEnchantInfo.enchantItemTypeId, equipEnchantInfo.enchantLevel)
    if curEnchantRow then
      local nowEnchantAttr = self.enchantVm_.GetAttrByEnchantItemRow(curEnchantRow)
      for k, data in ipairs(nowEnchantAttr) do
        local unitName = "enchant" .. k
        local token = self.cancelSource:CreateToken()
        self.equipUnitTokens_[unitName] = token
        local unit = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.node_enchant_item.transform, token)
        if unit then
          local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
          unit.Ref:SetVisible(unit.lab_content, isBuffAttr)
          unit.Ref:SetVisible(unit.node_lab_01, not isBuffAttr)
          if isBuffAttr then
            unit.lab_content.text = data.buffInfo
          else
            unit.lab_nature.text = data.attrName
            unit.lab_number.text = "+" .. data.attrValue
          end
          self.equipUnits_[unitName] = unit
        end
      end
      local itemRow = Z.TableMgr.GetRow("ItemTableMgr", curEnchantRow.Id)
      if itemRow then
        self.uiBinder.Ref:SetVisible(self.uiBinder.gem_title_root, true)
        self.uiBinder.gem_rimg_icon:SetImage(itemRow.Icon)
        self.uiBinder.lab_enchant_use.text = itemRow.Name
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.gem_title_root, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_enchant_empty, true)
  end
end

function TipsItemInfoPopupView:initBreakEquipAttrs()
  local equipRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(self.viewData.configId)
  if not equipRow then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_school_dpd, true)
  local curBreakCount = 0
  if self.equipAttr_ then
    curBreakCount = self.equipAttr_.breakThroughTime or 0
  end
  self.qualityChildAttrLibIds_ = equipRow.QualityChildAttrLibId
  if curBreakCount == 0 then
    self.advancedAttrLibIds_ = equipRow.AdvancedAttrLibId
    self.basicAttrLibIds_ = equipRow.BasicAttrLibId
  else
    local levels = self.equipCfgData_.EquipBreakIdLevelMap[self.viewData.configId]
    if levels then
      local rowId = levels[curBreakCount]
      if rowId then
        local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
        if breakThroughRow then
          self.advancedAttrLibIds_ = breakThroughRow.AdvancedAttrLibId
          self.basicAttrLibIds_ = breakThroughRow.BasicAttrLibId
        end
      end
    end
  end
  local attrIds = {}
  for index, value in ipairs(self.basicAttrLibIds_) do
    if 1 < index then
      attrIds[value] = value
    end
  end
  for index, value in ipairs(self.qualityChildAttrLibIds_) do
    if 1 < index then
      attrIds[value] = value
    end
  end
  for index, value in ipairs(self.advancedAttrLibIds_) do
    if 1 < index then
      attrIds[value] = value
    end
  end
  self:setSchoolDpd(attrIds)
end

function TipsItemInfoPopupView:getBreakAttrByLibIds(attrLibIds, randomValue, talentSchoolId)
  local attrType = 0
  local basicAttr = {}
  for index, value in ipairs(attrLibIds) do
    if index == 1 then
      attrType = value
    elseif attrType == 1 then
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataByAttrLibId(value, randomValue))
    else
      table.zmerge(basicAttr, self.equipAttrParseVM_.GetEquipAttrDataBySchoolAttrLibId(value, talentSchoolId, index - 1, randomValue))
    end
  end
  return basicAttr
end

function TipsItemInfoPopupView:loadSchoolAttrUnits(attrIndex, isBasicAttr, isPreview)
  local talentSchoolId = self.talentIds_[attrIndex]
  local randomValue = self.equipAttr_ and self.equipAttr_.perfectionValue or 100
  if isBasicAttr then
    local basicAttr = {}
    if self.equipAttr_ == nil or table.zcount(self.equipAttr_.equipAttrSet.basicAttr) == 0 then
      basicAttr = self:getBreakAttrByLibIds(self.basicAttrLibIds_, randomValue, talentSchoolId)
    else
      basicAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.equipAttr_.equipAttrSet.basicAttr, talentSchoolId)
    end
    self:loadEquipAttrUnit(basicAttr, self.uiBinder.node_BasicItem, "baseAttrInfo", true, isPreview)
  else
    local advancedAttr = {}
    if self.equipAttr_ == nil or table.zcount(self.equipAttr_.equipAttrSet.advanceAttr) == 0 then
      advancedAttr = self:getBreakAttrByLibIds(self.advancedAttrLibIds_, randomValue, talentSchoolId)
    else
      advancedAttr = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(self.equipAttr_.equipAttrSet.advanceAttr, talentSchoolId)
    end
    self:loadEquipAttrUnit(advancedAttr, self.uiBinder.node_SpecialItem, "advanceAttrInfo", false, isPreview)
  end
end

function TipsItemInfoPopupView:setSchoolDpd(attrIds)
  self.talentIds_ = {}
  local equipTableRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.configId)
  if not equipTableRow then
    return
  end
  local schoolIds = self.equipCfgData_:GetTalentSchoolIdsByAttrLibIds(attrIds)
  local talentOptions = {}
  local talentSchoolRowMap = {}
  local index = 1
  for key, id in pairs(schoolIds) do
    local talentSchoolDatas = Z.TableMgr.GetRow("TalentSchoolTableMgr", id)
    if talentSchoolDatas then
      self.talentIds_[index] = id
      talentSchoolRowMap[id] = talentSchoolDatas
      index = index + 1
    end
  end
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local talentSchoolId = self.equipCfgData_.TalentSchoolMap[self.talentSkillVm_.GetProfressionTalentStage(curProfessionId)]
  table.sort(self.talentIds_, function(left, right)
    if left == talentSchoolId and right ~= talentSchoolId then
      return true
    elseif left ~= talentSchoolId and right == talentSchoolId then
      return false
    end
    return left < right
  end)
  for i, v in ipairs(self.talentIds_) do
    talentOptions[i] = talentSchoolId == v and talentSchoolRowMap[v].SchoolName .. Lang("EquipSchoolTalentNow") or talentSchoolRowMap[v].SchoolName
  end
  if self.talentIds_[1] and self.talentIds_[1] ~= talentSchoolId then
    talentOptions[1] = talentOptions[1] .. Lang("EquipSchoolTalentDefault")
  end
  self.uiBinder.node_dpd.dpd:ClearAll()
  self.uiBinder.node_dpd.dpd:AddListener(function(index)
    Z.CoroUtil.create_coro_xpcall(function()
      if equipTableRow.BasicAttrLibId[1] == equipAttrType.equipAttrSchoolLib then
        self:loadSchoolAttrUnits(index + 1, true, self.isPreview_)
      end
      if equipTableRow.AdvancedAttrLibId[1] == equipAttrType.equipAttrSchoolLib then
        self:loadSchoolAttrUnits(index + 1, false, self.isPreview_)
      end
      self:setSuitInfo(self.talentIds_[index + 1])
    end)()
  end, true)
  self.uiBinder.node_dpd.dpd:AddOptions(talentOptions)
end

function TipsItemInfoPopupView:setSuitInfo(talentSchoolId)
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", self.viewData.configId)
  local suitInfos = Z.ContainerMgr.CharSerialize.equip.suitInfoDict or {}
  if equipRow and equipRow.SuitId ~= 0 then
    self.uiBinder.Ref:SetVisible(self.equipSuitNode_, true)
    local suitMap = self.equipCfgData_.EquipSuitMap[equipRow.SuitId]
    local attrs = {}
    for index, id in pairs(suitMap) do
      local suitInfo = suitInfos[id]
      if suitInfo then
        if suitInfo.attrType == 1 then
          attrs[id] = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(suitInfo.suitAttr)
        else
          attrs[id] = self.equipAttrParseVM_.GetEquipShoolAttrByAttrDic(suitInfo.suitAttr, talentSchoolId)
        end
      else
        local equipSuitRow = Z.TableMgr.GetRow("EquipSuitTableMgr", id)
        if equipSuitRow then
          attrs[id] = self:getBreakAttrByLibIds(equipSuitRow.SuitAttrLibId, 100, talentSchoolId)
        end
      end
    end
    self.equipSuitLab_.text = ""
    local str = ""
    local curPutNum = self.equipSystemVM_.GetCurPutSuitCountBySuitId(equipRow.SuitId)
    for id, value in pairs(attrs) do
      local equipSuitRow = Z.TableMgr.GetRow("EquipSuitTableMgr", id)
      if equipSuitRow then
        str = string.zconcat(str, equipSuitRow.SuitName, curPutNum, "/", equipSuitRow.LimitNum, ": ")
        for index, value in ipairs(value) do
          if value.attrValue ~= "" then
            str = string.zconcat(str, value.des, "+", value.attrValue)
          else
            str = string.zconcat(str, value.des)
          end
        end
        if suitInfos[id] then
          str = Z.RichTextHelper.ApplyColorTag(str, "#b6d85c")
        else
          str = Z.RichTextHelper.ApplyColorTag(str, "#c7c7c7")
        end
        str = str .. "\n"
      end
    end
    self.equipSuitLab_.text = str
  end
end

function TipsItemInfoPopupView:refreshModInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ModTip, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equip, true)
  self:ClearAllUnits()
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemConfig = itemTableMgr.GetRow(self.viewData.configId)
  local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(self.viewData.configId)
  if itemConfig == nil or modConfig == nil then
    return
  end
  local modTypeConfig = Z.TableMgr.GetTable("ModTypeTableMgr").GetRow(modConfig.ModType)
  self.uiBinder.tmp_name.text = self.itemsVM_.ApplyItemNameWithQualityTag(self.viewData.configId)
  self.uiBinder.img_CardBg:SetColor(MOD_DEFINE.QualityCornerPath[itemConfig.Quality])
  self.uiBinder.img_ModIcon:SetImage(modTypeConfig.TypeTips)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_OnlyBg, modConfig.IsOnly)
  self.itemSourceTab_ = self.itemSourceVm_.GetItemSource(self.viewData.configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_info, #self.itemSourceTab_ > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goLeft, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goRight, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_Info, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_Source, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_gsub, self.viewData.data and 0 < self.viewData.data.GsState)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_gsdown, self.viewData.data and 0 > self.viewData.data.GsState)
  self.uiBinder.Ref:SetVisible(self.refineNode_, false)
  if self.viewData.modInfo then
    self.uiBinder.tmp_ModGs.text = ""
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_ModGs, self.viewData.modInfo ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equiped, self.viewData.modInfo and 0 < self.viewData.modInfo.ModSlotId)
  local effectIds = {}
  local itemInfo = self.viewData.itemInfo
  if itemInfo == nil then
    itemInfo = self.itemsVM_.GetItemInfo(self.viewData.itemUuid, E.BackPackItemPackageType.Mod)
  end
  if itemInfo then
    effectIds = itemInfo.modNewAttr.modParts
  end
  ModItemCardTplItem.RefreshTpl(self.uiBinder.mod_gloaryItem, self.viewData.configId, true, nil, effectIds)
  local modVM = Z.VMMgr.GetVM("mod")
  self:asyncLoadAttrItem(modVM.GetModEffectIdAndSuccessTimesDetail(self.viewData.itemUuid, itemInfo), itemConfig.Quality)
  self:asyncLoadBuffItem({})
end

function TipsItemInfoPopupView:asyncLoadAttrItem(attrDescList, quality)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipBasics, false)
  if 0 < #attrDescList then
    local titlePath = self.uiBinder.prefab:GetString("mod_effect_title")
    local titleName = "title"
    local titleUnit = self:AsyncLoadUiUnit(titlePath, titleName, self.uiBinder.node_mod_item.transform)
    if titleUnit then
      titleUnit.btn_icon:AddListener(function()
        local modVM = Z.VMMgr.GetVM("mod")
        modVM.EnterModView()
        if self.viewData and self.viewData.closeTipsOnOpenMode then
          Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
        end
      end)
    end
    local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(self.viewData.configId)
    local unitPath
    if Z.IsPCUI then
      unitPath = GetLoadAssetPath("ModTipsEffectItemPC")
    else
      unitPath = GetLoadAssetPath("ModTipsEffectItem")
    end
    for i, v in ipairs(attrDescList) do
      local unitName = "attrBuffUnit_" .. i
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_mod_item.transform)
      if unit then
        ModGlossaryItemTplItem.RefreshTpl(unit.mod_glossary_item_tpl, v.id)
        local modVM = Z.VMMgr.GetVM("mod")
        local successTimes, level, nextSuccessTimes = modVM.GetEquipEffectSuccessTimesAndLevelAndNextLevelSuccessTimes(v.id)
        local modData = Z.DataMgr.Get("mod_data")
        local modEffectConfig = modData:GetEffectTableConfig(v.id, level)
        unit.lab_des.text = modEffectConfig.EffectName .. "+" .. v.level
        self:AddAsyncClick(unit.btn_tips, function()
          local viewData = {
            parent = self.uiBinder.mod_gloaryItem.Trans,
            effectId = v.id,
            config = modEffectConfig
          }
          Z.UIMgr:OpenView("mod_item_popup", viewData)
        end)
        local qualityConfig = modData:GetQualityConfig(quality)
        if qualityConfig then
          do
            local enhancementHoleNum = qualityConfig.enhancementHoleNum
            local starPath = unit.uiprefab_cache:GetString("mod_effect")
            local logsCount = #v.logs
            for k = 1, enhancementHoleNum do
              local starName = "star_" .. v.id .. "_" .. k
              local starUnit = self:AsyncLoadUiUnit(starPath, starName, unit.node_basics_item)
              if starUnit then
                if k <= logsCount then
                  if v.logs[k] then
                    ModFabtassyDotTplItem.RefreshTpl(starUnit, false, true, nil, false, true)
                  else
                    ModFabtassyDotTplItem.RefreshTpl(starUnit, false, false, nil, false, true)
                  end
                elseif modConfig and modConfig.IsCanLink then
                  ModFabtassyDotTplItem.RefreshTpl(starUnit, true, false, nil, false, true)
                else
                  ModFabtassyDotTplItem.RefreshTpl(starUnit, false, false, nil, false, true)
                end
              end
            end
          end
        end
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mod_item, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mod_item, false)
  end
end

function TipsItemInfoPopupView:asyncLoadBuffItem(effectIds)
  if 0 < #effectIds then
    local itemLabPath
    if Z.IsPCUI then
      itemLabPath = Z.ConstValue.Unit_Multi_Line_Labe_Addr_PC
    else
      itemLabPath = Z.ConstValue.Unit_Multi_Line_Labe_Addr
    end
    local unitPath = GetLoadAssetPath(itemLabPath)
    for i, v in ipairs(effectIds) do
      local unitName = "attrBuffUnit_" .. i
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_SpecialItem.transform)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, false)
        local modData = Z.DataMgr.Get("mod_data")
        local modEffectConfig = modData:GetEffectTableConfig(v.id, 0)
        unit.tmp_Desc.text = modEffectConfig.EffectName .. Lang("Level", {
          val = v.level
        })
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_SpecialItem, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_SpecialItem, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, false)
  end
end

function TipsItemInfoPopupView:refreshResonanceSkillInfo()
  self:refreshItemInfo()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.configId)
  if itemRow.Type == E.ResonanceSkillItemType.Prop then
    local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
    local descList = {}
    local skillAoyiItemRow = Z.TableMgr.GetRow("SkillAoyiItemTableMgr", self.viewData.configId)
    if skillAoyiItemRow then
      table.insert(descList, Lang("ActiveEffectColor"))
      table.insert(descList, "\n")
      local activeEffectDesc = weaponSkillVM:ParseResonanceSkillBaseDesc(skillAoyiItemRow.SkillId)
      table.insert(descList, activeEffectDesc)
      table.insert(descList, [[


]])
      table.insert(descList, Lang("PassiveEffectColor"))
      table.insert(descList, "\n")
      local attrDescList, buffDescList = weaponSkillVM:ParseResonanceSkillDesc(skillAoyiItemRow.SkillId, 0, true)
      for i, info in ipairs(attrDescList) do
        table.insert(descList, info.desc)
        table.insert(descList, "\n")
      end
      for i, info in ipairs(buffDescList) do
        table.insert(descList, info.desc)
        table.insert(descList, "\n")
      end
      Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.tmp_Desc, table.concat(descList))
    end
  end
end

function TipsItemInfoPopupView:initWarehouseItem()
  if self.viewData.isWarehouse then
    self.uiBinder.Ref:SetVisible(self.warehouseParent_, true)
    self.uiBinder.Ref:SetVisible(self.wareBtnNode_, true)
    self.warehouseView_:Active(self.viewData, self.warehouseParent_.transform)
    self.uiBinder.sizeFilter_viewPort.MaxHeight = 200
    self.uiBinder.sizeFilter_scroll.MaxHeight = 200
    self.uiBinder.Ref:SetVisible(self.warehouseDepositBtn_, self.viewData.warehouseGrid == nil)
    self.uiBinder.Ref:SetVisible(self.warehouseTakeOutBtn_, self.viewData.warehouseGrid ~= nil)
    if self.viewData.warehouseGrid then
      self.uiBinder.img_bg_sizeFilte.MaxHeight = 890
      if self.viewData.warehouseGrid.ownerCharId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
        self.uiBinder.Ref:SetVisible(self.warehouseHeadNode_, true)
        Z.CoroUtil.create_coro_xpcall(function()
          local socialData = self.socialVM_.AsyncGetSocialData(0, self.viewData.warehouseGrid.ownerCharId, self.cancelSource:CreateToken())
          if socialData then
            playerPortraitHgr.InsertNewPortraitBySocialData(self.wareHeadBinder_, socialData, nil, self.cancelSource:CreateToken())
            self.warehouseHeadNameLab_.text = socialData.basicData.name
          end
        end)()
      else
        self.uiBinder.img_bg_sizeFilte.MaxHeight = 840
      end
    else
      self.uiBinder.img_bg_sizeFilte.MaxHeight = 840
    end
  else
    self.uiBinder.img_bg_sizeFilte.MaxHeight = 840
    self.uiBinder.Ref:SetVisible(self.warehouseParent_, false)
    self.warehouseView_:DeActive()
  end
  self:rebuildLayout()
end

function TipsItemInfoPopupView:craftEnergy()
  self.uiBinder.Ref:SetVisible(self.cont_cook_time, false)
  if self.viewData.configId == Vitality then
    local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
    if craftEnergyTableRow then
      do
        local curCount = self.itemsVM_.GetItemTotalCount(self.viewData.configId)
        if curCount < craftEnergyTableRow.UpLimit then
          local b = (craftEnergyTableRow.UpLimit - curCount) / craftEnergyTableRow.RefreshAmount
          local _, time = Z.TimeTools.GetLeftTimeByTimerId(craftEnergyTableRow.Refresh)
          time = math.floor(time)
          local fullIime = time + math.floor(b) * 86400
          local func = function()
            self.lab_next_recovery.text = Lang("EnergyNextRecover") .. Z.TimeFormatTools.FormatToDHMS(time)
            self.lab_full_recovery.text = Lang("EnergyFullRecover") .. Z.TimeFormatTools.FormatToDHMS(fullIime)
          end
          func()
          if self.times_[Vitality] == nil then
            self.times_[Vitality] = self.timerMgr:StartTimer(function()
              time = time - 1
              fullIime = fullIime - 1
              func()
              if fullIime <= 0 then
                self.uiBinder.Ref:SetVisible(self.cont_cook_time, false)
              end
              if time <= 1 then
                time = Z.TimeTools.GetLeftTimeByTimerId(craftEnergyTableRow.Refresh)
              end
            end, 1, fullIime)
          end
          self.uiBinder.Ref:SetVisible(self.cont_cook_time, true)
        end
      end
    end
  else
    self.timerMgr:StopTimer(self.times_[Vitality])
  end
  self.uiBinder.Ref:SetVisible(self.contDesc3, false)
  if self.viewData.configId == Z.SystemItem.LifeProfessionPointItem then
    local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
    self.uiBinder.Ref:SetVisible(self.contDesc3, true)
    local remainVitality, cnt = lifeProfessionVM.GetNextGainVitalityConsume()
    self.uiBinder.lab_desc3.text = Lang("LifeProfessionSpeGet", {
      val = math.floor(remainVitality),
      cnt = cnt
    })
  end
end

return TipsItemInfoPopupView
