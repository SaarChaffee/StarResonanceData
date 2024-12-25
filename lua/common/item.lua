local ItemClass = class("ItemClass")
local qualityPathPre = "ui/atlas/item/prop/fashion_img_quality_"
local itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
local itemsVm = Z.VMMgr.GetVM("items")

function ItemClass:ctor(parent)
  self.parentView_ = parent
end

function ItemClass:Init(itemData)
  if itemData.unit == nil then
    self:UnInit()
    return
  end
  self.itemData_ = itemData
  self:refresh()
  self.itemData_.unit.cont_info.btn_temp:SetVisible(self.itemData_.isClickOpenTips ~= false)
  if self.itemData_.isClickOpenTips ~= false then
    self.parentView_:AddAsyncClick(self.itemData_.unit.cont_info.btn_temp.Btn, function()
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
        self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.itemData_.unit.Trans, self.itemData_.configId, self.itemData_.uuid, extraParams)
      end
    end)
  end
end

function ItemClass:UnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.itemData_ = nil
end

function ItemClass:InitCircleItem(itemUnit, configId, itemUuid, quaity, isShowEquip)
  if itemUnit == nil then
    return
  end
  self.itemData_ = {}
  self.itemData_.unit = itemUnit
  self.itemData_.configId = configId
  self.itemData_.uuid = itemUuid
  local itemTableRow = itemTableMgr_.GetRow(configId)
  if itemTableRow == nil then
    return
  end
  if not quaity then
    quaity = itemTableRow.Quality
    if itemUuid then
      local itemdata = itemsVm.GetItemInfobyItemId(itemUuid, configId)
      quaity = itemdata.quality
    end
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  itemUnit.rimg_icon.RImg:SetImage(itemsVm.GetItemIcon(configId))
  itemUnit.btn_bg.Img:SetImage(Z.ConstValue.QualityImgCircleBg .. quaity)
  if not itemUnit.img_equip then
    return
  end
  itemUnit.img_equip:SetVisible(false)
  if isShowEquip and itemUuid then
    local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
    for key, value in pairs(equipList) do
      if value.itemUuid == itemUuid then
        itemUnit.img_equip:SetVisible(true)
        return
      end
    end
  end
end

function ItemClass:refresh()
  if self.itemData_.isSquareItem then
    self:HideSquareUi()
    if not self.itemData_.HideTag and self.itemData_.PrevDropType and self.itemData_.PrevDropType == E.AwardPrevDropType.Probability then
      self.itemData_.unit.cont_info.img_prob_bg:SetVisible(true)
    end
  else
    self:HideUi()
    self:setBind()
  end
  self:initIcon()
  if self.itemData_.lab == nil then
    self:initItemLab()
  else
    self:refreshItemCountUi()
  end
  self:setScale()
  self:setName()
  self:refreshReceiveInfo()
  self:refreshLightInfo()
end

function ItemClass:refreshReceiveInfo()
  local receive = self.itemData_.isShowReceive or false
  self.itemData_.unit.cont_info.img_damaged:SetVisible(receive)
  self.itemData_.unit.cont_info.img_receive:SetVisible(receive)
end

function ItemClass:refreshLightInfo()
  local isShowLight = self.itemData_.isShowLight or false
  if self.itemData_.unit.cont_info.img_bpcard_unclaimed then
    self.itemData_.unit.cont_info.img_bpcard_unclaimed:SetVisible(isShowLight)
  end
end

function ItemClass:HideUi()
  self.itemData_.unit.cont_info.img_add:SetVisible(false)
  self.itemData_.unit.cont_info.img_quality:SetVisible(false)
  self.itemData_.unit.cont_info.rimg_icon:SetVisible(false)
  self.itemData_.unit.cont_info.group_time_flags:SetVisible(false)
  self.itemData_.unit.cont_info.img_bind:SetVisible(false)
  self.itemData_.unit.cont_info.img_cd:SetVisible(false)
  self.itemData_.unit.cont_info.img_selected_green:SetVisible(false)
  self.itemData_.unit.cont_info.rayimg_btn_item:SetVisible(false)
  self.itemData_.unit.cont_info.btn_close:SetVisible(false)
  self.itemData_.unit.cont_info.btn_temp:SetVisible(false)
  self.itemData_.unit.cont_info.img_puton_flag:SetVisible(false)
  self.itemData_.unit.cont_info.img_other_puton_flag:SetVisible(false)
  self.itemData_.unit.cont_info.img_receive:SetVisible(false)
  self.itemData_.unit.cont_info.lab_gs:SetVisible(false)
  self.itemData_.unit.cont_info.lab_level:SetVisible(false)
  self.itemData_.unit.cont_info.lab_count:SetVisible(false)
  self.itemData_.unit.cont_info.img_reddot:SetVisible(false)
  self.itemData_.unit.cont_info.img_mask:SetVisible(false)
  self.itemData_.unit.cont_info.img_damaged:SetVisible(false)
  if self.itemData_.unit.cont_info.img_damaged_icon then
    self.itemData_.unit.cont_info.img_damaged_icon:SetVisible(false)
  end
  self.itemData_.unit.cont_info.img_lab_bg:SetVisible(false)
  self.itemData_.unit.cont_info.node_effect:SetVisible(false)
  self.itemData_.unit.cont_info.img_job:SetVisible(false)
  self.itemData_.unit.cont_info.img_mask:SetVisible(false)
  if self.itemData_.unit.lab_name then
    self.itemData_.unit.lab_name:SetVisible(false)
  end
  self:SetSelected(false)
end

function ItemClass:HideSquareUi()
  self.itemData_.unit.cont_info.img_quality:SetVisible(false)
  self.itemData_.unit.cont_info.rimg_icon:SetVisible(false)
  self.itemData_.unit.cont_info.anim_select:SetVisible(false)
  self.itemData_.unit.cont_info.img_selected_green:SetVisible(false)
  self.itemData_.unit.cont_info.btn_temp:SetVisible(false)
  self.itemData_.unit.cont_info.img_puton_flag:SetVisible(false)
  self.itemData_.unit.cont_info.img_other_puton_flag:SetVisible(false)
  self.itemData_.unit.cont_info.img_prob_bg:SetVisible(false)
  self.itemData_.unit.cont_info.lab_gs:SetVisible(false)
  self.itemData_.unit.cont_info.lab_level:SetVisible(false)
  self.itemData_.unit.cont_info.lab_count:SetVisible(false)
  self.itemData_.unit.cont_info.img_damaged:SetVisible(false)
  self.itemData_.unit.cont_info.node_effect:SetVisible(false)
  self.itemData_.unit.cont_info.img_lab_bg:SetVisible(false)
  self.itemData_.unit.cont_info.img_job:SetVisible(false)
  self.itemData_.unit.cont_info.img_mask:SetVisible(false)
  self.itemData_.unit.anim_item.anim:ResetAniState("ui_anim_item_backpack_tpl_click")
  if self.itemData_.unit.lab_name then
    self.itemData_.unit.lab_name:SetVisible(false)
  end
  self:SetSelected(false)
end

function ItemClass:setBind()
  local bind = self.itemData_.isBind or false
  self.itemData_.unit.cont_info.img_bind:SetVisible(bind)
end

function ItemClass:setQuality(path)
  if path == "" or path == nil then
    return
  end
  self.itemData_.unit.cont_info.img_quality:SetVisible(true)
  self.itemData_.unit.cont_info.img_quality.Img:SetImage(path)
end

function ItemClass:SetRedDot(bShow)
  self.itemData_.unit.cont_info.img_reddot:SetVisible(bShow)
end

function ItemClass:initIcon()
  if self.itemData_.iconPath and self.itemData_.qualityPath then
    self:setIcon(self.itemData_.iconPath)
    self:setQuality(self.itemData_.qualityPath)
    return
  end
  if self.itemData_.configId == 0 or self.itemData_.configId == nil then
    return
  end
  local itemTableRow = itemTableMgr_.GetRow(self.itemData_.configId, true)
  if itemTableRow == nil then
    return
  end
  local quaity = itemTableRow.Quality
  if self.itemData_.uuid then
    local itemdata = itemsVm.GetItemInfobyItemId(self.itemData_.uuid, self.itemData_.configId)
    if itemdata then
      quaity = itemdata.quality
    end
  end
  self:setIcon(itemsVm.GetItemIcon(self.itemData_.configId))
  local path = ""
  if self.itemData_.isSquareItem then
    path = qualityPathPre .. quaity
  else
    path = Z.ConstValue.QualityImgBg .. quaity
  end
  self:setQuality(path)
  self.itemData_.unit.cont_info.img_mask:SetVisible(self.itemData_.isShowMask)
end

function ItemClass:setIcon(iconPath)
  if iconPath == nil or iconPath == "" then
    return
  end
  self.itemData_.unit.cont_info:SetVisible(true)
  self.itemData_.unit.cont_info.rimg_icon:SetVisible(true)
  self.itemData_.unit.cont_info.rimg_icon.RImg:SetImage(iconPath)
end

function ItemClass:refreshEquipFlag(itemData)
  self.itemData_.unit.cont_info.img_puton_flag:SetVisible(false)
  self.itemData_.unit.cont_info.img_other_puton_flag:SetVisible(false)
  if itemsVm.CheckPackageTypeByItemUuid(itemData.uuid, E.BackPackItemPackageType.Equip) then
    local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
    for key, value in pairs(equipList) do
      if value.itemUuid == itemData.uuid then
        self.itemData_.unit.cont_info.img_puton_flag:SetVisible(true)
        return
      end
    end
  end
end

function ItemClass:RefreshModEquipFlag(isModEquipFlag)
  self.itemData_.unit.cont_info.img_puton_flag:SetVisible(isModEquipFlag)
end

function ItemClass:setScale()
  self.itemData_.unit.Ref:SetScale(self.itemData_.sizeX or 1, self.itemData_.sizeY or 1)
end

function ItemClass:setName()
  if self.itemData_.isShowName and self.itemData_.unit.lab_name then
    local itemTableRow = itemTableMgr_.GetRow(self.itemData_.configId, true)
    if itemTableRow == nil then
      return
    end
    self.itemData_.unit.lab_name.TMPLab.text = itemTableRow.Name
    self.itemData_.unit.lab_name:SetVisible(true)
  end
end

function ItemClass:refreshItemExpendCountUi(haveCount, expendCount, colorKey)
  local str
  if expendCount and haveCount < expendCount then
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
    colorKey = colorKey or E.TextStyleTag.TipsRed
  else
    colorKey = "test_green"
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
  end
  if colorKey then
    haveCount = Z.RichTextHelper.ApplyStyleTag(haveCount, colorKey)
  end
  str = haveCount .. "/" .. expendCount
  return str
end

function ItemClass:refreshEquipGS(str)
  if not self.itemData_ or self.itemData_.unit == nil then
    return
  end
  if self.itemData_.isHideGS then
    return
  end
  self.itemData_.unit.cont_info.img_lab_bg:SetVisible(true)
  self.itemData_.unit.cont_info.lab_count.TMPLab.text = str
  self.itemData_.unit.cont_info.lab_level:SetVisible(false)
  self.itemData_.unit.cont_info.lab_gs:SetVisible(true)
  self.itemData_.unit.cont_info.lab_count:SetVisible(true)
  self.itemData_.unit.cont_info.lab_level:SetVisible(false)
end

function ItemClass:isShowEquipGs()
  local equipTabCfgData = Z.TableMgr.GetTable("EquipTableMgr")
  local equipCfgData = equipTabCfgData.GetRow(self.itemData_.configId, true)
  if equipCfgData == nil then
    return false
  end
  self:refreshEquipGS(equipCfgData.EquipGs)
end

function ItemClass:refreshItemCountUi()
  local str = ""
  if self.itemData_.labType == E.ItemLabType.Str then
    str = self.itemData_.lab
  elseif self.itemData_.labType == E.ItemLabType.Expend then
    str = self:refreshItemExpendCountUi(self.itemData_.lab, self.itemData_.expendCount, self.itemData_.colorKey)
  else
    str = tonumber(self.itemData_.lab)
    if str then
      if self.itemData_.isShowOne == false and str == 1 then
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
  self.itemData_.unit.cont_info.img_lab_bg:SetVisible(true)
  self.itemData_.unit.cont_info.lab_level.TMPLab.text = str
  self.itemData_.unit.cont_info.lab_level:SetVisible(true)
  self.itemData_.unit.cont_info.lab_gs:SetVisible(false)
  self.itemData_.unit.cont_info.lab_count:SetVisible(false)
end

function ItemClass:initItemLab()
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

function ItemClass:SetReceive(isShowReceive)
  self.itemData_.isShowReceive = isShowReceive
  self:refreshReceiveInfo()
end

function ItemClass:SetRolelevelIcon(iconPath, quaityPath)
  if iconPath ~= nil and iconPath ~= "" then
    self.itemData_.unit.cont_info.img_rolelevel.Img:SetImage(iconPath)
  end
  if quaityPath ~= nil and quaityPath ~= "" then
    self.itemData_.unit.cont_info.img_rolelevel_frame.Img:SetImage(quaityPath)
  end
  self.itemData_.unit.cont_info.img_rolelevel_frame:SetVisible(true)
end

function ItemClass:RefreshItemCdUi(cdTime, useCD)
  if cdTime and 0 < cdTime and 0 < useCD then
    self.itemData_.unit.cont_info.img_cd:SetVisible(true)
    local time = Z.TimeTools.FormatCdTime(cdTime)
    if time then
      if 0 < time.day then
        self.itemData_.unit.cont_info.lab_cd.TMPLab.text = time.day .. "day"
      elseif 0 < time.hours then
        self.itemData_.unit.cont_info.lab_cd.TMPLab.text = time.hours .. "h"
      elseif 0 < time.min then
        self.itemData_.unit.cont_info.lab_cd.TMPLab.text = time.min .. "min"
      else
        self.itemData_.unit.cont_info.lab_cd.TMPLab.text = time.sec
      end
      self.itemData_.unit.cont_info.img_cd.Img.fillAmount = time.sec / useCD
    else
      self.itemData_.unit.cont_info.img_cd:SetVisible(false)
    end
  else
    self.itemData_.unit.cont_info.img_cd:SetVisible(false)
  end
end

function ItemClass:RefreshItemFlags(itemData, itemTableRow)
  if self.itemData_.unit.cont_info.img_bind then
    self.itemData_.unit.cont_info.img_bind:SetVisible(itemData.bindFlag == 0)
    if itemTableRow.TimeType == 0 then
      self.itemData_.unit.cont_info.img_outofdata:SetVisible(false)
      self.itemData_.unit.cont_info.img_ondata:SetVisible(false)
    else
      self.itemData_.unit.cont_info.img_outofdata:SetVisible(itemData.invalid == 1)
      self.itemData_.unit.cont_info.img_ondata:SetVisible(itemData.invalid == 0)
    end
  end
  self:refreshEquipFlag(itemData)
  self:RefreshItemJob(itemData)
end

function ItemClass:RefreshItemJob(itemData)
  self.itemData_.unit.cont_info.img_job:SetVisible(false)
  if itemsVm.CheckPackageTypeByConfigId(itemData.configId, E.BackPackItemPackageType.Mod) then
  end
end

function ItemClass:SetExpendCount(count, expendCount)
  self.itemData_.labType = E.ItemLabType.Expend
  self.itemData_.lab = count
  if expendCount then
    self.itemData_.expendCount = expendCount
  end
  self:refreshItemCountUi()
end

function ItemClass:SetLab(lab)
  self.itemData_.labType = E.ItemLabType.Str
  self.itemData_.lab = lab
  self:refreshItemCountUi()
end

function ItemClass:SetSelected(isSelected, isPlayEff)
  local isPlaySelectEff = isPlayEff == nil and true or false
  self.itemData_.unit.cont_info.img_select:SetVisible(isSelected)
  if isSelected then
    self.itemData_.unit.cont_info.anim_select.anim:PlayByTime("ui_anim_item_backpack_tpl_loop", -1)
    if not self.parentView_ or isPlaySelectEff then
    end
  else
    self.itemData_.unit.cont_info.anim_select.anim:ResetAniState("ui_anim_item_backpack_tpl_loop")
  end
end

function ItemClass:SetExchangeComplete(isComplete)
  self.itemData_.unit.cont_info.img_exchange_complete:SetVisible(isComplete)
end

function ItemClass:AsyncPlayClickAnim(token)
  self.itemData_.unit.cont_info.node_effect:SetVisible(true)
  self.itemData_.unit.anim_item.anim:CoroPlayOnce("ui_anim_item_backpack_tpl_click", token, function()
    self.itemData_.unit.cont_info.node_effect:SetVisible(false)
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

function ItemClass:SetSelectedGreen(isSelected)
  self.itemData_.unit.cont_info.img_selected_green:SetVisible(isSelected)
end

return ItemClass
