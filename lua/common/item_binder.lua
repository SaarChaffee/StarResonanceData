local ItemBinder = class("ItemBinder")
local itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
local itemsVm = Z.VMMgr.GetVM("items")
local MOD_DEFINE = require("ui.model.mod_define")

function ItemBinder:ctor(parent)
  self.parentView_ = parent
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function ItemBinder:Init(itemData)
  if itemData.uiBinder == nil then
    self:UnInit()
    return
  end
  self.uiBinder = itemData.uiBinder
  self.itemData_ = itemData
  self:refresh()
  if self.uiBinder.btn_temp and self.parentView_ and self.itemData_.isClickOpenTips ~= false then
    self.parentView_:AddAsyncClick(self.uiBinder.btn_temp, function()
      self:BtnTempClick()
    end)
  end
end

function ItemBinder:UnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.itemData_ = nil
  self.uiBinder = nil
end

function ItemBinder:BtnTempClick()
  if self.uiBinder.btn_temp then
    if self.itemData_.clickCallFunc then
      self.itemData_.clickCallFunc()
    else
      local extraParams = {
        itemInfo = self.itemData_.itemInfo,
        isHideSource = self.itemData_.isHideSource,
        goToCallFunc = self.itemData_.goToCallFunc,
        tipsBindPressCheckComp = self.itemData_.tipsBindPressCheckComp,
        isBind = self.itemData_.isBind
      }
      if self.tipsId_ then
        Z.TipsVM.CloseItemTipsView(self.tipsId_)
      end
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.itemData_.configId, self.itemData_.uuid, extraParams)
    end
  end
end

function ItemBinder:InitCircleItem(itemBinder, configId, itemUuid, quaity, isShowEquip, quaityBgPath)
  if itemBinder == nil then
    return
  end
  self.itemData_ = {}
  self.uiBinder = itemBinder
  self.itemData_.configId = configId
  self.itemData_.uuid = itemUuid
  local itemTableBase = itemTableMgr_.GetRow(configId)
  if itemTableBase == nil then
    return
  end
  if not quaity then
    quaity = itemTableBase.Quality
    if itemUuid then
      local itemdata = itemsVm.GetItemInfobyItemId(itemUuid, configId)
      quaity = itemdata.quality
    end
  end
  self:setImg(self.uiBinder.rimg_icon, itemsVm.GetItemIcon(configId))
  if self.uiBinder.btn_bg then
    if quaityBgPath then
      self:setImg(self.uiBinder.btn_bg, quaityBgPath .. quaity)
    else
      self:setImg(self.uiBinder.btn_bg, Z.ConstValue.QualityImgCircleBg .. quaity)
    end
  end
  if self.uiBinder.img_quality then
    if quaityBgPath then
      self:setImg(self.uiBinder.img_quality, quaityBgPath .. quaity)
    else
      self:setImg(self.uiBinder.img_quality, Z.ConstValue.QualityImgCircleBg .. quaity)
    end
  end
  if not itemBinder.img_equip then
    return
  end
  self:SetNodeVisible(self.uiBinder.img_equip, false)
  if isShowEquip and itemUuid then
    local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
    for key, value in pairs(equipList) do
      if value.itemUuid == itemUuid then
        self:SetNodeVisible(self.uiBinder.img_equip, true)
        return
      end
    end
  end
end

function ItemBinder:refresh()
  self:HideUi()
  if self.itemData_.isSquareItem and self.itemData_.ShowTag and self.itemData_.PrevDropType and self.itemData_.PrevDropType == E.AwardPrevDropType.Probability then
    self:SetNodeVisible(self.uiBinder.img_prob, true)
  end
  self:initIcon()
  self:initFlags()
  if self.itemData_.lab == nil then
    self:initItemLab()
  else
    self:refreshItemCountUi()
  end
  self:setScale()
  self:setName()
  self:refreshReceiveInfo()
  self:refreshLightInfo()
  self:setEquipInfo()
  self:SetNodeVisible(self.uiBinder.btn_temp, self.itemData_.isClickOpenTips ~= false)
end

function ItemBinder:setEquipInfo()
  if self.itemData_.itemInfo and self.itemData_.itemInfo.equipAttr then
    local equipVm = Z.VMMgr.GetVM("equip_system")
    if equipVm.CheckCanRecast(self.itemData_.uuid, self.itemData_.configId) then
      self:setEquipEffect(self.itemData_.itemInfo.quality, self.itemData_.itemInfo.equipAttr.perfectionValue >= Z.Global.GoodEquipPerfectVal)
    end
  end
end

function ItemBinder:initFlags()
  if not self.itemData_.itemInfo then
    self.itemData_.itemInfo = itemsVm.GetItemInfobyItemId(self.itemData_.uuid, self.itemData_.configId)
  end
  if not self.itemData_.itemInfo then
    return
  end
  local showTradeTag = true
  if self.itemData_.itemInfo and not self.itemData_.isHidecoolDown and self.itemData_.itemInfo.bindFlag ~= 0 then
    local serverTime = Z.ServerTime:GetServerTime() / 1000
    local coolDownTime = self.itemData_.itemInfo.coolDownExpireTime or 0
    self:SetNodeVisible(self.uiBinder.img_cold, serverTime < coolDownTime)
    showTradeTag = serverTime > coolDownTime
  end
  local tradeVm = Z.VMMgr.GetVM("trade")
  if self.itemData_.itemInfo and tradeVm:CheckItemCanExchange(self.itemData_.configId, self.itemData_.uuid) then
    self:SetNodeVisible(self.uiBinder.img_easy, showTradeTag)
  end
  if self.itemData_.isBind then
    self:SetNodeVisible(self.uiBinder.img_bind, self.itemData_.itemInfo.bindFlag == 0)
  end
end

function ItemBinder:RefreshByData(itemData)
  self.itemData_ = itemData
  self:refresh()
end

function ItemBinder:refreshReceiveInfo()
  local receive = self.itemData_.isShowReceive or false
  self:SetNodeVisible(self.uiBinder.img_receive, receive)
  self:SetNodeVisible(self.uiBinder.img_damage, receive)
  self:SetNodeVisible(self.uiBinder.img_get, receive)
end

function ItemBinder:refreshLightInfo()
  local isShowLight = self.itemData_.isShowLight or false
  if self.uiBinder.img_bpCard_unclaimed then
    self:SetNodeVisible(self.uiBinder.img_bpCard_unclaimed, isShowLight)
  end
end

function ItemBinder:HideUi()
  self:SetNodeVisible(self.uiBinder.img_quality, false)
  self:SetNodeVisible(self.uiBinder.rimg_icon, false)
  self:SetNodeVisible(self.uiBinder.img_lab_bg, false)
  self:SetNodeVisible(self.uiBinder.lab_content, false)
  self:SetNodeVisible(self.uiBinder.btn_temp, false)
  self:SetNodeVisible(self.uiBinder.img_select, false)
  self:SetNodeVisible(self.uiBinder.img_bind, false)
  self:SetNodeVisible(self.uiBinder.img_reddot, false)
  self:SetNodeVisible(self.uiBinder.img_use, false)
  self:SetNodeVisible(self.uiBinder.img_card, false)
  self:SetNodeVisible(self.uiBinder.img_job, false)
  self:SetNodeVisible(self.uiBinder.img_consume, false)
  self:SetNodeVisible(self.uiBinder.img_materials, false)
  self:SetNodeVisible(self.uiBinder.img_special, false)
  self:SetNodeVisible(self.uiBinder.img_prob, false)
  self:SetNodeVisible(self.uiBinder.img_damage, false)
  self:SetNodeVisible(self.uiBinder.img_cd, false)
  self:SetNodeVisible(self.uiBinder.img_more_selected, false)
  self:SetNodeVisible(self.uiBinder.btn_minus, false)
  self:SetNodeVisible(self.uiBinder.img_add, false)
  self:SetNodeVisible(self.uiBinder.img_outofdata, false)
  self:SetNodeVisible(self.uiBinder.img_ondata, false)
  self:SetNodeVisible(self.uiBinder.lab_exchange, false)
  self:SetNodeVisible(self.uiBinder.img_lock, false)
  self:SetNodeVisible(self.uiBinder.img_cold, false)
  self:SetNodeVisible(self.uiBinder.img_easy, false)
  self:SetNodeVisible(self.uiBinder.btn_close, false)
  self:SetNodeVisible(self.uiBinder.img_get, false)
  self:SetNodeVisible(self.uiBinder.img_empty, false)
  self:SetNodeVisible(self.uiBinder.img_new, false)
  self:SetNodeVisible(self.uiBinder.img_forbidden, false)
  self:SetNodeVisible(self.uiBinder.node_eff3, false)
  self:SetNodeVisible(self.uiBinder.node_eff4, false)
  self:SetNodeVisible(self.uiBinder.node_eff5, false)
  self:SetNodeVisible(self.uiBinder.anim_select, false)
  self:SetNodeVisible(self.uiBinder.trans_time_flags, false)
  self:SetNodeVisible(self.uiBinder.img_selected_green, false)
  self:SetNodeVisible(self.uiBinder.rayimg_btn_item, false)
  self:SetNodeVisible(self.uiBinder.img_other_puton_flag, false)
  self:SetNodeVisible(self.uiBinder.img_receive, false)
  self:SetNodeVisible(self.uiBinder.trans_effect, false)
  self:SetNodeVisible(self.uiBinder.node_effect, false)
  if self.uiBinder.anim_item then
  end
  self:SetSelected(false)
  self:hideAllQualityEffect()
end

function ItemBinder:hideAllQualityEffect()
  if self.uiBinder.node_quality_effect then
    for index, value in pairs(E.ItemQuality) do
      local unit1 = self.uiBinder.node_quality_effect["quality" .. value .. 1]
      local unit2 = self.uiBinder.node_quality_effect["quality" .. value .. 3]
      if unit1 then
        self.uiBinder.node_quality_effect.Ref:SetVisible(unit1, false)
      end
      if unit2 then
        self.uiBinder.node_quality_effect.Ref:SetVisible(unit2, false)
      end
    end
  end
end

function ItemBinder:SetNodeVisible(node, isShow)
  if node then
    self.uiBinder.Ref:SetVisible(node, isShow)
  end
end

function ItemBinder:setQuality(path)
  if path == "" or path == nil then
    return
  end
  self:SetNodeVisible(self.uiBinder.img_quality, true)
  self:setImg(self.uiBinder.img_quality, path)
end

function ItemBinder:showQualityEffect()
  if self.itemData_.configId == 0 or self.itemData_.configId == nil then
    return
  end
  if not self.uiBinder.node_quality_effect then
    return
  end
  local quality = 0
  local qualityType = 1
  if self.itemData_.itemInfo then
    if self.itemData_.itemInfo.equipAttr and self.equipVm_.CheckCanRecast(nil, self.itemData_.configId) and self.itemData_.itemInfo.equipAttr.perfectionValue >= Z.Global.GoodEquipPerfectVal then
      qualityType = 3
    end
    quality = self.itemData_.itemInfo.quality
  else
    local itemTableBase = itemTableMgr_.GetRow(self.itemData_.configId, true)
    if itemTableBase == nil then
      return
    end
    quality = itemTableBase.Quality
  end
  local unit = self.uiBinder.node_quality_effect["quality" .. quality .. qualityType]
  if unit then
    self.uiBinder.node_quality_effect.Ref:SetVisible(unit, true)
  end
end

function ItemBinder:SetRedDot(bShow)
  self:SetNodeVisible(self.uiBinder.img_reddot, bShow)
end

function ItemBinder:SetNewRedDot(bShow)
  self:SetNodeVisible(self.uiBinder.img_new, bShow)
end

function ItemBinder:initIcon()
  if self.itemData_.iconPath and self.itemData_.qualityPath then
    self:setIcon(self.itemData_.iconPath)
    self:setQuality(self.itemData_.qualityPath)
    return
  end
  if self.itemData_.configId == 0 or self.itemData_.configId == nil then
    return
  end
  local itemTableBase = itemTableMgr_.GetRow(self.itemData_.configId, true)
  if itemTableBase == nil then
    return
  end
  local quaity = itemTableBase.Quality
  local itemData = self.itemData_.itemInfo
  if itemData == nil and self.itemData_.uuid then
    itemData = itemsVm.GetItemInfobyItemId(self.itemData_.uuid, self.itemData_.configId)
  end
  if itemData then
    if itemData.quality then
      quaity = itemData.quality
    end
    local serverTime = Z.ServerTime:GetServerTime() / 1000
    local coolDownTime = itemData.coolDownExpireTime or 0
    self:SetNodeVisible(self.uiBinder.lab_cold, serverTime < coolDownTime)
  end
  local itemVm = Z.VMMgr.GetVM("items")
  self:setIcon(itemVm.GetItemIcon(self.itemData_.configId))
  local path = ""
  if self.itemData_.isSquareItem then
    path = Z.ConstValue.Item.SquareItemQualityPath .. quaity
  else
    path = Z.ConstValue.Item.ItemQualityPath .. quaity
  end
  self:setQuality(path)
  self:SetNodeVisible(self.uiBinder.img_mask, self.itemData_.isShowMask)
end

function ItemBinder:setIcon(iconPath)
  if iconPath == nil or iconPath == "" then
    return
  end
  self:SetNodeVisible(self.uiBinder.trans_info, true)
  self:SetNodeVisible(self.uiBinder.rimg_icon, true)
  self:setImg(self.uiBinder.rimg_icon, iconPath)
end

function ItemBinder:refreshEquipFlag(itemData)
  self:SetNodeVisible(self.uiBinder.img_use, false)
  self:SetNodeVisible(self.uiBinder.img_other_puton_flag, false)
  if itemsVm.CheckPackageTypeByItemUuid(itemData.uuid, E.BackPackItemPackageType.Equip) then
    local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
    for key, value in pairs(equipList) do
      if value.itemUuid == itemData.uuid then
        self:SetNodeVisible(self.uiBinder.img_use, true)
        return
      end
    end
  elseif itemsVm.CheckPackageTypeByItemUuid(itemData.uuid, E.BackPackItemPackageType.Mod) then
    local modVM = Z.VMMgr.GetVM("mod")
    local isEquip, pos = modVM.IsModEquip(itemData.uuid)
    if isEquip then
      self:SetNodeVisible(self.uiBinder.img_use, true)
      self.uiBinder.img_use:SetImage(MOD_DEFINE.ModSlotItemIconPath[pos])
    end
  end
end

function ItemBinder:RefreshModEquipFlag(isModEquipFlag)
  self:SetNodeVisible(self.uiBinder.img_use, isModEquipFlag)
end

function ItemBinder:setScale()
  self.uiBinder.Trans.localScale = Vector3.New(self.itemData_.sizeX or 1, self.itemData_.sizeY or 1, 0)
end

function ItemBinder:setName()
  if self.itemData_.isShowName and self.uiBinder.lab_content then
    local itemTableBase = itemTableMgr_.GetRow(self.itemData_.configId, true)
    if itemTableBase == nil then
      return
    end
    self:setLabText(self.uiBinder.lab_content, itemTableBase.Name)
    self:SetNodeVisible(self.uiBinder.lab_content, true)
    self:SetNodeVisible(self.uiBinder.img_lab_bg, true)
  end
end

function ItemBinder:setLabText(lab, text)
  if lab then
    lab.text = text
  end
end

function ItemBinder:refreshItemExpendCountUi(haveCount, expendCount, colorKey)
  local str
  if expendCount and haveCount < expendCount then
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
    colorKey = colorKey or E.TextStyleTag.TipsRed
  else
    colorKey = nil
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
  end
  if colorKey then
    haveCount = Z.RichTextHelper.ApplyStyleTag(haveCount, colorKey)
  end
  str = haveCount .. "/" .. expendCount
  return str
end

function ItemBinder:refreshEquipGS(str)
  if not self.itemData_ or self.uiBinder == nil then
    return
  end
  if self.itemData_.isHideGS then
    return
  end
  self:setLabText(self.uiBinder.lab_content, Lang("GSEqual", {val = str}))
  self:SetNodeVisible(self.uiBinder.lab_content, true)
  self:SetNodeVisible(self.uiBinder.img_lab_bg, true)
end

function ItemBinder:isShowEquipGs()
  local equipTabCfgData = Z.TableMgr.GetTable("EquipTableMgr")
  local equipCfgData = equipTabCfgData.GetRow(self.itemData_.configId, true)
  if equipCfgData == nil then
    return false
  end
  self:refreshEquipGS(equipCfgData.EquipGs)
end

function ItemBinder:refreshItemCountUi()
  if self.itemData_.ShowTag and self.itemData_.PrevDropType and self.itemData_.PrevDropType == E.AwardPrevDropType.Probability then
    return
  end
  local str = ""
  if self.itemData_.labType == E.ItemLabType.Str then
    str = self.itemData_.lab
  elseif self.itemData_.labType == E.ItemLabType.Expend then
    str = self:refreshItemExpendCountUi(self.itemData_.lab, self.itemData_.expendCount, self.itemData_.colorKey)
  else
    str = tonumber(self.itemData_.lab)
    if str then
      if self.itemData_.isSquareItem and str == 1 then
        str = ""
      elseif str == 0 and not self.itemData_.isShowZero then
        str = ""
      end
    else
      str = self.itemData_.lab
    end
    if self:isShowEquipGs() ~= false then
      return
    end
  end
  if str == "" then
    return
  end
  self:setLabText(self.uiBinder.lab_content, str)
  self:SetNodeVisible(self.uiBinder.img_lab_bg, true)
  self:SetNodeVisible(self.uiBinder.lab_content, true)
end

function ItemBinder:initItemLab()
  if self.itemData_.configId == 0 or self.itemData_.configId == nil then
    return
  end
  if self.itemData_.uuid == nil then
    self:isShowEquipGs()
    return
  end
  local itemData = self.itemData_.itemInfo or itemsVm.GetItemInfobyItemId(self.itemData_.uuid, self.itemData_.configId)
  if itemData == nil then
    return
  end
  local equipTabCfgData = Z.TableMgr.GetTable("EquipTableMgr")
  local equipCfgData = equipTabCfgData.GetRow(self.itemData_.configId, true)
  if equipCfgData then
    self:refreshEquipGS(equipCfgData.EquipGs)
  else
    self.itemData_.lab = itemData.count
    self:refreshItemCountUi()
  end
end

function ItemBinder:RefreshLab()
  self:initItemLab()
end

function ItemBinder:SetReceive(isShowReceive)
  self.itemData_.isShowReceive = isShowReceive
  self:refreshReceiveInfo()
end

function ItemBinder:setImg(img, path)
  if img then
    img:SetImage(path)
    self:SetNodeVisible(img, true)
  end
end

function ItemBinder:SetRolelevelIcon(iconPath, quaityPath)
  if iconPath ~= nil and iconPath ~= "" then
    self:setImg(self.uiBinder.img_rolelevel, iconPath)
  end
  if quaityPath ~= nil and quaityPath ~= "" then
    self:setImg(self.uiBinder.img_rolelevel_frame, quaityPath)
  end
  self:SetNodeVisible(self.uiBinder.img_rolelevel_frame, true)
end

function ItemBinder:SetEmptyState(state)
  self:SetNodeVisible(self.uiBinder.img_empty, state)
end

function ItemBinder:SetForbiddenState(state)
  self:SetNodeVisible(self.uiBinder.img_forbidden, state)
end

function ItemBinder:RefreshItemCdUi(cdTime, useCD)
  if cdTime and 0 < cdTime and 0 < useCD and self.uiBinder.img_cd then
    self:SetNodeVisible(self.uiBinder.img_cd, true)
    local time = Z.TimeTools.FormatCdTime(cdTime)
    if time then
      if 0 < time.day then
        self:setLabText(self.uiBinder.lab_cd, time.day .. "day")
      elseif 0 < time.hours then
        self:setLabText(self.uiBinder.lab_cd, time.hours .. "h")
      elseif 0 < time.min then
        self:setLabText(self.uiBinder.lab_cd, time.min .. "min")
      else
        self:setLabText(self.uiBinder.lab_cd, time.sec)
      end
      self.uiBinder.img_cd.fillAmount = time.sec / useCD
    else
      self:SetNodeVisible(self.uiBinder.img_cd, false)
    end
  else
    self:SetNodeVisible(self.uiBinder.img_cd, false)
  end
end

function ItemBinder:RefreshItemFlags(itemData, itemTableBase)
  if self.uiBinder.img_bind then
    if itemTableBase.TimeType == 0 then
      self:SetNodeVisible(self.uiBinder.img_outofdata, false)
      self:SetNodeVisible(self.uiBinder.img_ondata, false)
    else
      self:SetNodeVisible(self.uiBinder.img_outofdata, itemData.invalid == 1)
      self:SetNodeVisible(self.uiBinder.img_ondata, itemData.invalid == 0)
    end
  end
  self:refreshEquipFlag(itemData)
  self:RefreshItemJob(itemData)
end

function ItemBinder:RefreshItemJob(itemData)
  self:SetNodeVisible(self.uiBinder.img_job, false)
  if itemsVm.CheckPackageTypeByConfigId(itemData.configId, E.BackPackItemPackageType.Mod) then
  end
end

function ItemBinder:SetExpendCount(count, expendCount)
  self.itemData_.labType = E.ItemLabType.Expend
  self.itemData_.lab = count
  if expendCount then
    self.itemData_.expendCount = expendCount
  end
  self:refreshItemCountUi()
end

function ItemBinder:SetLab(lab)
  self.itemData_.labType = E.ItemLabType.Str
  self.itemData_.lab = lab
  self:refreshItemCountUi()
end

function ItemBinder:SetSelected(isSelected, isPlayEff)
  local isPlaySelectEff = isPlayEff == nil and true or false
  self:SetNodeVisible(self.uiBinder.img_select, isSelected)
  if self.uiBinder.anim_select then
    if isSelected then
      self.uiBinder.anim_select:PlayByTime("ui_anim_item_backpack_tpl_loop", -1)
      if not self.parentView_ or isPlaySelectEff then
      end
    else
      self.uiBinder.anim_select:ResetAniState("ui_anim_item_backpack_tpl_loop")
    end
  end
end

function ItemBinder:setEquipEffect(quality, isShow)
  self:SetNodeVisible(self.uiBinder["node_eff" .. quality], isShow)
end

function ItemBinder:SetExchangeComplete(isComplete)
  self:SetNodeVisible(self.uiBinder.lab_exchange, isComplete)
  self:SetNodeVisible(self.uiBinder.img_exchange, isComplete)
end

function ItemBinder:SetImgLockState(state)
  self:SetNodeVisible(self.uiBinder.img_lock, state)
end

function ItemBinder:AsyncPlayClickAnim(token)
  self:SetNodeVisible(self.uiBinder.trans_effect, true)
  if self.uiBinder.anim_item then
    self.uiBinder.anim_item:CoroPlayOnce("ui_anim_item_backpack_tpl_click", token, function()
      self:SetNodeVisible(self.uiBinder.trans_effect, false)
    end, function(err)
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      logError(err)
    end)
  end
end

function ItemBinder:SetSelectedGreen(isSelected)
  self:SetNodeVisible(self.uiBinder.img_selected_green, isSelected)
end

return ItemBinder
