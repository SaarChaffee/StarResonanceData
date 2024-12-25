local UI = Z.UI
local super = require("ui.ui_subview_base")
local TipsItemInfoPopupView = class("TipsItemInfoPopupView", super)
local itemClass = require("common.item_binder")
local itemFunctionTable = Z.TableMgr.GetTable("ItemFunctionTableMgr")
local MAX_LOAD_ITEM_COUNT = 30
local MOD_DEFINE = require("ui.model.mod_define")
local fightTableMgr = Z.TableMgr.GetTable("FightAttrTableMgr")
local ModItemCardTplItem = require("ui.component.mod.mod_item_card_tpl_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local warehouseTplView = require("ui.view.tips_warehouse_tpl_view")
local equipLockView = require("ui.view.equip_lock_popup_view")
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")
local ModFabtassyDotTplItem = require("ui.component.mod.mod_fabtassy_dot_tpl_item")
local Vitality = E.CurrencyType.Vitality

function TipsItemInfoPopupView:ctor(parent)
  super.ctor(self, "tips_item_info_popup", "common_tips/tips_item_info_popup", UI.ECacheLv.None)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.equipSystemVM_ = Z.VMMgr.GetVM("equip_system")
  self.equipAttrParseVM_ = Z.VMMgr.GetVM("equip_attr_parse")
  self.buffAttrParseVM_ = Z.VMMgr.GetVM("buff_attr_parse")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.cookVM_ = Z.VMMgr.GetVM("cook")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.warehouseVm_ = Z.VMMgr.GetVM("warehouse")
  self.socialVM_ = Z.VMMgr.GetVM("social")
  self.tradeVM_ = Z.VMMgr.GetVM("trade")
  self.equipRefineVm_ = Z.VMMgr.GetVM("equip_refine")
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
end

function TipsItemInfoPopupView:initUi()
  self.uiBinder.Ref:SetVisible(self.warehouseHeadNode_, false)
  self.uiBinder.Ref:SetVisible(self.warehouseDepositBtn_, false)
  self.uiBinder.Ref:SetVisible(self.warehouseTakeOutBtn_, false)
  self.uiBinder.Ref:SetVisible(self.wareBtnNode_, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_gs, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.img_bind, false)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.layout_cook, false)
  self.uiBinder.Ref:SetVisible(self.cont_cook_time, false)
  self:setEquipNodeState(false)
  self.honourNode_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.refineLevelLab_, false)
  self.uiBinder.Ref:SetVisible(self.refineLevelNode_, false)
  self.uiBinder.Ref:SetVisible(self.refineNode_, false)
end

function TipsItemInfoPopupView:initBtns()
  self:AddClick(self.previewBtn_, function()
    self.preview_.GotoPreview(self.viewData.configId)
    if self.viewData.goToCallFunc then
      self.viewData.goToCallFunc()
    end
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
  local containGoEvent = self.uiBinder.press_check.ContainGoEvent
  self:EventAddAsyncListener(containGoEvent, function(isContainer)
    if not isContainer then
      Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
    end
  end, nil, nil)
end

function TipsItemInfoPopupView:OnActive()
  self:initBinders()
  self:initBtns()
  self.isGetBtnDotShow_ = false
  self.equipUnits_ = {}
  self.times_ = {}
  self.itemClassTab_ = {}
  self:bindParentPressPointCheck()
end

function TipsItemInfoPopupView:onShowGoOrHide()
  self.uiBinder.Ref:SetVisible(self.uiBinder.sizeFilter_scroll, not self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goLeft, self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_goRight, not self.isGetBtnDotShow_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scroll_source, self.isGetBtnDotShow_)
end

function TipsItemInfoPopupView:OnDeActive()
  self:ClearAllUnits()
  self:unBindParentPressPointCheck()
  for _, itemClass in pairs(self.itemClassTab_) do
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
  if self.viewData.isPlay == nil then
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

function TipsItemInfoPopupView:OnRefresh()
  self.isGetBtnDotShow_ = false
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_fixed, false)
    self:initUi()
    self:setProperty()
    self:setUIStyle()
    self:getItemSource()
    self:onShowGoOrHide()
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
  self.uiBinder.anim_trans.anchoredPosition = Vector3.zero
  if self.viewData.posType == E.EItemTipsPopType.Parent then
    self.uiBinder.Trans:SetSizeDelta(0, 0)
    self.uiBinder.Trans:SetAnchorPosition(0, 0)
    self.uiBinder.img_bg.rectTransform:SetAnchorPosition(0, 0)
  elseif self.viewData.posType == E.EItemTipsPopType.Bounds then
    self.uiBinder.adapt_pos:UpdatePosition(self.viewData.parentTrans, true, false, isUseOriginalPos)
  elseif self.viewData.posType == E.EItemTipsPopType.WorldPosition then
    self.uiBinder.adapt_pos:UpdatePosition(self.viewData.parentTrans.position)
  end
  if self.viewData.posOffset then
    local posSource = self.uiBinder.img_bg.rectTransform.anchoredPosition
    local posResult = posSource + self.viewData.posOffset
    local size = self.uiBinder.img_bg.rectTransform.sizeDelta
    local pivot = self.uiBinder.img_bg.rectTransform.pivot
    local width = size.x * pivot.x
    local height = size.y * pivot.y
    if posResult.x < -(Z.UIRoot.CurCanvasSafeSize.x - width) * 0.5 then
      posResult.x = posSource.x - self.viewData.posOffset.x
    end
    if posResult.y < -(Z.UIRoot.CurCanvasSafeSize.y - height) * 0.5 then
      posResult.y = posSource.y - self.viewData.posOffset.y
    end
    self.uiBinder.img_bg.rectTransform:SetAnchorPosition(posResult.x, posResult.y)
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
  self.uiBinder.img_BgQuality:SetImage(Z.ConstValue.QualityImgTipsBg .. self.itemTableRow_.Quality)
  self.uiBinder.img_modbg_quality:SetImage(Z.ConstValue.QualityImgTipsBg .. self.itemTableRow_.Quality)
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
    self.uiBinder.tmp_Desc.text = string.zreplace(self.itemTableRow_.Description, "<br>", "\n") .. affixStr .. des
    self.uiBinder.tmp_Desc2.text = self.itemTableRow_.Description2
  end
  self.uiBinder.tmp_Desc:AddListener(function(key)
    local index = tonumber(key)
    local linkData = linkDatas[index]
    if linkData then
      Z.CommonTipsVM.OpenAffixTips({linkData}, self.uiBinder.transform)
    end
  end, true)
  if self.viewData.haveTime then
    self.uiBinder.tmp_time.text = Lang("UnlockRecipe") .. Z.TimeTools.FormatTimeToYMD(self.viewData.haveTime * 1000)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_time, true)
  end
  local CookMaterialTableRow = Z.TableMgr.GetTable("CookMaterialTableMgr").GetRow(self.viewData.configId, true)
  if CookMaterialTableRow then
    self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.layout_cook, true)
    local typeATableRow = Z.TableMgr.GetRow("CookMaterialTypeTableMgr", CookMaterialTableRow.TypeA)
    if typeATableRow then
      self.equipInfoNode_.lab_aname.text = typeATableRow.Name
      self.equipInfoNode_.img_colour1:SetColorByHex(typeATableRow.TagColor)
    end
    local typeBTableRow = Z.TableMgr.GetRow("CookMaterialTypeTableMgr", CookMaterialTableRow.TypeB)
    if typeBTableRow then
      self.equipInfoNode_.lab_bname.text = typeBTableRow.Name
      self.equipInfoNode_.img_colour2:SetColorByHex(typeBTableRow.TagColor)
    end
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
      local text = string.format(Lang("tips_exchange_coolDown"), Z.TimeTools.S2HM(itemInfo.coolDownExpireTime - serverTime))
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
  else
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
    local timeStrYMD = Z.TimeTools.FormatTimeToYMD(creatTime)
    local timeStrHMS = Z.TimeTools.FormatTimeToHMS(creatTime)
    local timeStr = string.format("%s %s", timeStrYMD, timeStrHMS)
    self.uiBinder.lab_boss_rank.text = Lang("WorldBossRankTips", {
      val = rank,
      num = score,
      time = timeStr
    })
    local expireTime = itemInfo.expireTime
    local timeStrYMD1 = Z.TimeTools.FormatTimeToYMD(expireTime)
    local timeStrHMS1 = Z.TimeTools.FormatTimeToHMS(expireTime)
    local timeStr1 = string.format("%s %s", timeStrYMD1, timeStrHMS1)
    self.uiBinder.lab_boss_time.text = Lang("WorldBossExpireTips", {time = timeStr1})
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
  end
  self:SetUIVisible(self.uiBinder.cont_boss_rank, bossData ~= nil)
  self:SetUIVisible(self.uiBinder.cont_boss_time, bossData ~= nil and 0 < itemInfo.expireTime)
end

function TipsItemInfoPopupView:loadQualityEffect()
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.node_effect_quality, false)
  if self.itemTableRow_ then
    local path = Z.ConstValue.ItemEffect[self.itemTableRow_.Quality]
    if not path then
      return
    end
    local effectType = 3
    local itemInfo = self.viewData.itemInfo
    if itemInfo and itemInfo.equipAttr and self.equipSystemVM_.CheckCanRecast(nil, self.viewData.configId) and itemInfo.equipAttr.perfectionValue >= Z.Global.GoodEquipPerfectVal then
      Z.CoroUtil.create_coro_xpcall(function()
        local unit = self:AsyncLoadUiUnit(path .. effectType, "quality_effect" .. self.viewData.configId, self.equipInfoNode_.node_effect_quality.transform)
        if unit then
          self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.node_effect_quality, true)
          unit.Trans:SetRot(0, 0, 180)
        end
      end)()
    end
  end
end

function TipsItemInfoPopupView:refreshItemInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ItemTip, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_TimeLimit, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_UseLimit, false)
  local isOwnItem = not self.viewData.showType or self.viewData.showType == E.EItemTipsShowType.Default or self.viewData.itemInfo
  if isOwnItem then
    self:setOwnItemInfo()
  end
  local itemFunctionTableRow = itemFunctionTable.GetRow(self.viewData.configId, true)
  if itemFunctionTableRow and itemFunctionTableRow.Type == E.ItemFunctionType.Gift then
    self:setGiftInfo(itemFunctionTableRow)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_useGetItem, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
  end
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
    local expireTime = math.ceil(itemInfo.expireTime / 1000)
    local param = {date = expireTime}
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
      self.itemClassTab_[itemName] = itemClass.new(self)
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
      self.itemClassTab_[itemName]:Init(itemClassData)
    end
  end
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
  self.itemSourceVm_.SetPanelItemSource(self, self.viewData.configId, self.viewData.tipsId, self.itemSourceTab_, self.viewData.isResident, self.viewData.goToCallFunc)
  self:rebuildLayout()
  self:setPanelPos(true)
end

function TipsItemInfoPopupView:setEquipNodeState(state)
  self.uiBinder.Ref:SetVisible(self.equipPerfectLockBtn_, state)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tmp_count, state)
  local isCanRecast = self.equipSystemVM_.CheckCanRecast(self.viewData.itemUuid, self.viewData.configId)
  self.uiBinder.Ref:SetVisible(self.perfectNode_, isCanRecast)
  self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_recast_count, isCanRecast)
end

function TipsItemInfoPopupView:refreshEquipInfo()
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
  if equipRow then
    self.equipInfoNode_.Ref:SetVisible(self.equipInfoNode_.lab_gs, true)
    self.equipInfoNode_.lab_gs.text = Lang("GSEqual", {
      val = equipRow.EquipGs
    })
  end
  self:setRefineInfo()
  if isOwnEquip then
    self:setOwnEquipInfo()
  else
    self.equipInfoNode_.lab_recast_count.text = Lang("RecastCount", {val = 0})
    self.uiBinder.lab_perfection_num.text = Lang("EquipNoRecastingState")
    self.uiBinder.Ref:SetVisible(self.equipPerfectLockBtn_, false)
    self.uiBinder.img_progress.fillAmount = 0
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
  local equipAttr = itemInfo.equipAttr
  self.equipInfoNode_.lab_recast_count.text = Lang("RecastCount", {
    val = equipAttr.totalRecastCount
  })
  self:setEquipNodeState(true)
  self.uiBinder.tmp_count.text = ""
  self.uiBinder.lab_perfection_num.text = Lang("EquipPerfaceLab") .. equipAttr.perfectionValue
  self.uiBinder.img_progress.fillAmount = equipAttr.perfectionValue / 100
  local minAttrValue = self.equipSystemVM_.GetEquipMinPerfectByLevel(itemInfo.configId, equipAttr.perfectionLevel)
  local equipRecastVm = Z.VMMgr.GetVM("equip_recast")
  local x = 0
  local width = self.uiBinder.img_progress.rectTransform.rect.width
  local tableRow = equipRecastVm.GetEquipPerfectRow(itemInfo.configId, equipAttr.perfectionLevel)
  if tableRow then
    local maxLevel = self.equipCfgData_.RecastMaxLevleTab[tableRow.PerfectLibId]
    local isMaxLevel = maxLevel == equipAttr.perfectionLevel
    if tableRow.PerfectType[1] == 1 then
      self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = minAttrValue}) or ""
      x = width / 100 * (minAttrValue - 1)
    elseif tableRow.PerfectType[1] == 2 then
      local maxAttrValue = tableRow.PerfectPart[2]
      self.equipLockTips_ = Lang("EquipPerfectvalExplainTips", {val = maxAttrValue}) or ""
      if isMaxLevel then
        x = width * (equipAttr.perfectionLevel / 100)
      else
        x = width * (maxAttrValue / 100)
      end
    end
  end
  self.uiBinder.rect_lock:SetAnchorPosition(x, -20)
  local partEquipInfo = self.equipSystemVM_.GetSamePartEquipAttr(self.viewData.configId)
  local isPartEquiped = partEquipInfo and partEquipInfo.itemUuid == self.viewData.itemUuid
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_equiped, isPartEquiped)
  self:setEquipAttr(equipAttr)
end

function TipsItemInfoPopupView:setEquipAttr(equipAttr, isPreview)
  self:loadEquipAttrUnit(equipAttr.basicAttr, self.uiBinder.node_BasicItem, "baseAttrInfo", true, isPreview)
  if isPreview then
    local externAttrArray = self.equipAttrParseVM_.GetEquipExternAttrData(self.viewData.configId)
    self:loadEquipAttrUnit(externAttrArray, self.uiBinder.node_SpecialItem, "advanceAttrInfo", false, isPreview)
  else
    self:loadEquipAttrUnit(equipAttr.advanceAttr, self.uiBinder.node_SpecialItem, "advanceAttrInfo", false, isPreview)
  end
  if self.equipSystemVM_.CheckCanRecast(nil, self.viewData.configId) then
    self:loadEquipAttrUnit(equipAttr.recastAttr, self.uiBinder.node_SpecialItem, "recastAttrInfo", false, isPreview, true)
  end
end

function TipsItemInfoPopupView:loadEquipAttrUnit(attrArray, attrWidget, unitName, isBaseAttr, isPreview, isRecastAttr)
  if not isRecastAttr and (attrArray == nil or next(attrArray) == nil) then
    self.uiBinder.Ref:SetVisible(attrWidget, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipSpecial, false)
    if isBaseAttr then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_equipBasics, false)
    end
    return
  end
  local utilPath = Z.ConstValue.Unit_equip_arr_tpl
  local attrData = {}
  if not isPreview then
    attrData = self.equipAttrParseVM_.GetEquipAttrEffectByAttrDic(attrArray)
  else
    if not isBaseAttr then
      utilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
    end
    attrData = attrArray
  end
  local contrastAttrData
  if not isPreview and self.viewData.data then
    if isRecastAttr then
      contrastAttrData = self.viewData.data.RecastAttrEffectDatas
    elseif isBaseAttr then
      contrastAttrData = self.viewData.data.BasicAttrEffectDatas
    else
      contrastAttrData = self.viewData.data.AdvanceAttrEffectDatas
    end
  end
  if isRecastAttr then
    if attrData and 0 < #attrData then
      for key, value in ipairs(attrData) do
        local name = table.zconcat({
          unitName,
          self.viewData.tipsId,
          key
        }, "recastAttr")
        local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
        if unit then
          self.equipUnits_[name] = unit
          local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(value.attrId)
          if fightAttrData then
            unit.Ref:SetVisible(unit.img_bg, true)
            self:setAttrDifference(contrastAttrData, value.attrId, value.attrValue, unit)
            local nameText = fightAttrData.OfficialName
            local num = value.attrValue
            if not value.IsFitProfessionAttr then
              nameText = Z.RichTextHelper.ApplyColorTag(nameText, Z.Global.EquipAttColourNotSuitable)
              num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
            end
            unit.lab_name.text = nameText
            unit.lab_num.text = num
            local itemFunctionTableRow = fightTableMgr.GetRow(fightAttrData.Id, true)
            unit.img_icon:SetImage(itemFunctionTableRow.Icon)
          end
        end
      end
    else
      utilPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
      local name = table.zconcat({
        unitName,
        self.viewData.tipsId,
        "recastAttr"
      }, "_")
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
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
  else
    for key, value in pairs(attrData) do
      local name = table.zconcat({
        unitName,
        self.viewData.tipsId,
        key
      }, "_")
      local unit = self:AsyncLoadUiUnit(utilPath, name, attrWidget.transform)
      if unit then
        self.equipUnits_[name] = unit
        if isPreview and not isBaseAttr then
          unit.Ref:SetVisible(unit.img_bg, false)
          unit.tmp_Desc.text = Lang("EquipNoRecastingState")
        else
          local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(value.attrId)
          if fightAttrData then
            local name = fightAttrData.OfficialName
            local num = isPreview and Lang("EquipNoRecastingState") or value.attrValue
            unit.Ref:SetVisible(unit.img_bg, false)
            self:setAttrDifference(contrastAttrData, value.attrId, value.attrValue, unit)
            local itemFunctionTableRow = fightTableMgr.GetRow(fightAttrData.Id, true)
            unit.img_icon:SetImage(itemFunctionTableRow.Icon)
            if not value.IsFitProfessionAttr then
              name = Z.RichTextHelper.ApplyColorTag(name, Z.Global.EquipAttColourNotSuitable)
              num = Z.RichTextHelper.ApplyColorTag(num, Z.Global.EquipAttColourNotSuitable)
            end
            unit.lab_name.text = name
            unit.lab_num.text = num
          end
        end
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
    item.img_up_or_down:SetImage("ui/atlas/tips/tips_img_down")
  elseif type == -1 then
    item.img_up_or_down:SetImage("ui/atlas/tips/tips_img_up")
  end
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
  local tab = self.equipRefineVm_.GetBasicAttrInfo(equipRow.EquipPart, currentLevel, currentProfessionId)
  if tab and 0 < #tab then
    for k, v in ipairs(tab) do
      local name = "refine_basic" .. k
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.refineItemNode_.transform)
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
      local unit = self:AsyncLoadUiUnit(unitPath, name, self.refineLevelNode_.transform)
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
  self.uiBinder.img_CardBg:SetImage(MOD_DEFINE.QualityCornerPath[itemConfig.Quality])
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
    local unitPath = GetLoadAssetPath("ModTipsEffectItem")
    for i, v in ipairs(attrDescList) do
      local unitName = "attrBuffUnit_" .. i
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_mod_item.transform)
      if unit then
        ModGlossaryItemTplItem.RefreshTpl(unit.mod_glossary_item_tpl, v.id, v.level)
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
                    ModFabtassyDotTplItem.RefreshTpl(starUnit, false, true, nil)
                  else
                    ModFabtassyDotTplItem.RefreshTpl(starUnit, false, false, nil)
                  end
                else
                  ModFabtassyDotTplItem.RefreshTpl(starUnit, true, false, nil)
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
    local unitPath = GetLoadAssetPath(Z.ConstValue.Unit_Multi_Line_Labe_Addr)
    for i, v in ipairs(effectIds) do
      local unitName = "attrBuffUnit_" .. i
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_SpecialItem.transform)
      if unit then
        unit.Ref:SetVisible(unit.img_bg, false)
        local modData = Z.DataMgr.Get("mod_data")
        local modEffectConfig = modData:GetEffectTableConfig(v.id, 0)
        unit.tmp_Desc.text = modEffectConfig.EffectName .. Lang("Lv") .. v.level
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
            playerPortraitHgr.InsertNewPortraitBySocialData(self.wareHeadBinder_, socialData)
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
  Z.Delay(0.01, self.cancelSource:CreateToken())
  self:rebuildLayout()
end

function TipsItemInfoPopupView:craftEnergy()
  if self.viewData.configId == Vitality then
    local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
    if craftEnergyTableRow then
      do
        local curCount = self.itemsVM_.GetItemTotalCount(self.viewData.configId)
        if curCount < craftEnergyTableRow.UpLimit then
          local b = (craftEnergyTableRow.UpLimit - curCount) / craftEnergyTableRow.RefreshAmount
          local _, time = Z.TimeTools.GetTimeLeftInSpecifiedTime(craftEnergyTableRow.Refresh)
          time = math.floor(time)
          local fullIime = time + math.floor(b) * 86400
          local func = function()
            self.lab_next_recovery.text = Lang("EnergyNextRecover") .. Z.TimeTools.FormatToHMS(time)
            self.lab_full_recovery.text = Lang("EnergyFullRecover") .. Z.TimeTools.FormatToDHM(fullIime)
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
                time = Z.TimeTools.GetTimeLeftInSpecifiedTime(craftEnergyTableRow.Refresh)
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
end

return TipsItemInfoPopupView
