local super = require("ui.ui_subview_base")
local SeasonCultivateNode = class("SeasonCultivateNode", super)
local ItemClass = require("common.item_binder")

function SeasonCultivateNode:ctor()
  super.ctor(self, "season_cultivate_node", "season_cultivate/season_cultivate_node_sub", Z.UI.ECacheLv.None, true)
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
  self.itemVM_ = Z.VMMgr.GetVM("items")
end

function SeasonCultivateNode:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.currentLevel_ = 0
  self.conditionUnit_ = {}
  self.itemUnit_ = {}
  self.itemClass_ = {}
  self.expItemOffered_ = {}
  local items = Z.Global.ProgressValueItem
  local season = self.seasonVM_.GetCurrentSeasonId()
  for _, v in pairs(items) do
    if v[1] == season then
      self.expItemOffered_[v[2]] = v[3]
    end
  end
  self.expNeedMoneyID_ = 0
  self.expNeedMoneyNum_ = 0
  local money = Z.Global.ProgressMoneyNum
  if money[1] == season then
    self.expNeedMoneyID_ = money[2]
    self.expNeedMoneyNum_ = money[3]
  else
    logError("\232\181\155\229\173\163\230\149\176\230\141\174\228\184\141\229\140\185\233\133\141: money:" .. money[1] .. " season:" .. season)
  end
  self.addItem_ = {}
  self.isMaxLevel_ = false
  self:AddClick(self.uiBinder.btn_clear, function()
    if self.seasonCultivateVM_.TryClick() then
      for itemId, _ in pairs(self.addItem_) do
        self.addItem_[itemId] = 0
      end
      self:setAddExp(self:calculateAddExp())
    end
  end)
  self:AddClick(self.uiBinder.btn_join, function()
    if self.seasonCultivateVM_.TryClick() then
      if not self:checkAddEnoughTip(self.uiBinder.btn_join.transform) then
        return
      end
      self:autoAdd()
      self:setAddExp(self:calculateAddExp(true))
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_small_square_new, function()
    if self.viewData.holeConfig.HoleLevel <= 1 then
      Z.TipsVM.ShowTips(124010)
      return
    end
    local temp = Z.Global.NodeResetConsumption
    local configId = temp[1]
    local expendCount = temp[2]
    local itemData = {
      ItemId = configId,
      ItemNum = expendCount,
      LabType = E.ItemLabType.Expend
    }
    Z.DialogViewDataMgr:OpenNormalItemsDialog(Lang("SeasonNodeResetTipProp"), function()
      local count = self.itemVM_.GetItemTotalCount(configId)
      if count >= expendCount then
        self:onConfirmReset()
      end
    end, nil, {itemData})
  end)
  self:AddAsyncClick(self.uiBinder.btn_square_new, function()
    if not self:checkAddEnoughTip(self.uiBinder.btn_square_new.transform) then
      return
    end
    local exp = self:calculateAddExp(false)
    local totalCanAddExp = self.seasonCultivateVM_.GetHoleExpTotalCanAdd(self.viewData.holeConfig.HoleId)
    local canAddExp = Mathf.Max(totalCanAddExp - self.seasonCultivateVM_.GetHoleExpTotalCurrent(self.viewData.holeConfig.HoleId), 0)
    if exp <= 0 then
      Z.TipsVM.ShowTips(124014)
      return
    end
    local confirmFunc = function()
      local item = {}
      for id, num in pairs(self.addItem_) do
        if 0 < num then
          item[id] = num
        end
      end
      local success = self.seasonCultivateVM_.AsyncUpgradeSeasonNormalHole(self.viewData.holeConfig.HoleId, item, self.cancelSource:CreateToken())
      if success then
        local all = self.seasonCultivateVM_.GetAllNormalNodeInfo()
        self.viewData = all[self.viewData.holeConfig.HoleId]
        self:OnRefresh()
        Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnUpgradeHole, self.viewData.holeConfig.HoleId)
      end
    end
    local canUpdateMax = self.seasonCultivateVM_.GetMaxLevelCanAddTo(self.viewData.holeConfig.HoleId)
    local level, _, _ = self.seasonCultivateVM_.GetHoleExpInfo(self.viewData.holeConfig.HoleId, exp)
    local maxLevel = self.seasonCultivateVM_.GetHoleMaxLevel(self.viewData.holeConfig.HoleId)
    if exp > canAddExp and maxLevel ~= level then
      local dialogViewData = {
        dlgType = E.DlgType.YesNo,
        onConfirm = confirmFunc,
        labDesc = Lang("SeasonNodeMoreTips", {val = canUpdateMax})
      }
      Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
    else
      confirmFunc()
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnConfirmReset, self.onConfirmReset, self)
end

function SeasonCultivateNode:getIsPcPre()
  local ConditionUnitPath
  if Z.IsPCUI then
    ConditionUnitPath = GetLoadAssetPath("SeasonCultivateConditionUnit_PC")
  else
    ConditionUnitPath = GetLoadAssetPath("SeasonCultivateConditionUnit")
  end
  return ConditionUnitPath
end

function SeasonCultivateNode:OnRefresh()
  local moneyItem = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.expNeedMoneyID_)
  if moneyItem then
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_gold:SetImage(itemsVM.GetItemIcon(self.expNeedMoneyID_))
  end
  self.uiBinder.btn_small_square_new.IsDisabled = self.viewData.holeConfig.HoleLevel <= 1
  self.uiBinder.lab_name.text = self.viewData.attrConfig.NodeName
  self.uiBinder.lab_money.text = "0"
  self.addItem_ = {}
  self:setAddExp(0)
  self:setConsumeItem()
end

function SeasonCultivateNode:OnDeActive()
  self.currentLevel_ = nil
  self.conditionUnit_ = nil
  self.expItemOffered_ = nil
  self.expNeedMoneyID_ = nil
  self.expNeedMoneyNum_ = nil
  for _, v in pairs(self.itemClass_) do
    v:UnInit()
  end
  self.itemClass_ = nil
  self.addItem_ = nil
  self.isMaxLevel_ = nil
  self:closeSourceTip()
  Z.EventMgr:RemoveObjAll(self)
end

function SeasonCultivateNode:autoAdd()
  for itemId, _ in pairs(self.addItem_) do
    self.addItem_[itemId] = 0
  end
  local totalMoney = self.itemVM_.GetItemTotalCount(self.expNeedMoneyID_)
  local totalCanAddExp = self.seasonCultivateVM_.GetHoleExpTotalCanAdd(self.viewData.holeConfig.HoleId)
  local canAddExp = Mathf.Max(totalCanAddExp - self.seasonCultivateVM_.GetHoleExpTotalCurrent(self.viewData.holeConfig.HoleId), 0)
  for itemId, perExp in pairs(self.expItemOffered_) do
    local hasCount = self.itemVM_.GetItemTotalCount(itemId)
    local needCount = Mathf.Floor(canAddExp / perExp)
    local canAddCount = Mathf.Floor(canAddExp / perExp)
    local moneyEnoughCount = Mathf.Ceil(totalMoney / (perExp * self.expNeedMoneyNum_))
    local addCount = Mathf.Min(hasCount, canAddCount, moneyEnoughCount)
    self.addItem_[itemId] = addCount
    if needCount <= addCount then
      break
    end
    totalMoney = totalMoney - perExp * self.expNeedMoneyNum_ * addCount
    canAddExp = canAddExp - perExp * addCount
  end
end

function SeasonCultivateNode:setConsumeItem()
  local ItemUnitPath
  if Z.IsPCUI then
    ItemUnitPath = GetLoadAssetPath("BackPack_Item_Unit_Addr2_8_New_PC")
  else
    ItemUnitPath = GetLoadAssetPath("BackPack_Item_Unit_Addr2_8_New")
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, v in pairs(self.itemUnit_) do
      self:RemoveUiUnit(v)
    end
    self.itemUnit_ = {}
    for itemId, _ in pairs(self.expItemOffered_) do
      local name = "item_" .. itemId
      local unit = self:AsyncLoadUiUnit(ItemUnitPath, name, self.uiBinder.node_item.transform, self.cancelSource:CreateToken())
      if unit then
        self.itemUnit_[itemId] = name
        local count = self.itemVM_.GetItemTotalCount(itemId)
        local datas = {
          uiBinder = unit,
          configId = itemId,
          isShowZero = true,
          lab = count,
          isSquareItem = true,
          isShowOne = true
        }
        if 0 < count then
          function datas.clickCallFunc()
            if self.seasonCultivateVM_.TryClick(0) and self:tryChangeItem(itemId, true) then
              self:setAddExp(self:calculateAddExp())
              
              self:refreshItemRed(itemId)
            end
          end
        end
        local instance = self.itemClass_[itemId]
        if not instance then
          instance = ItemClass.new(self)
          self.itemClass_[itemId] = instance
        end
        instance:Init(datas)
        self:refreshItemRed(itemId)
        self:AddClick(unit.btn_minus, function()
          if self.seasonCultivateVM_.TryClick(0) and self:tryChangeItem(itemId, false) then
            self:setAddExp(self:calculateAddExp())
          end
        end)
      end
    end
  end)()
end

function SeasonCultivateNode:refreshItemRed(itemId)
  local itemClass = self.itemClass_[itemId]
  if itemClass then
    local count = self.addItem_[itemId] or 0
    local hasMoney = self.itemVM_.GetItemTotalCount(self.expNeedMoneyID_)
    local isShowAdd = false
    if self.addItem_ and self.addItem_[itemId] and self.addItem_[itemId] > 0 then
      isShowAdd = true
    end
    itemClass:SetRedDot(self:checkAddItemRed(itemId) and hasMoney >= self.expNeedMoneyNum_ * (count + 1) and not isShowAdd)
  end
end

function SeasonCultivateNode:checkAddItemRed(itemId)
  if not self.addItem_[itemId] then
    self.addItem_[itemId] = 0
  end
  if self.isMaxLevel_ then
    return false
  end
  local currentAddExp = self:calculateAddExp(false)
  local canAddExp = Mathf.Max(self.seasonCultivateVM_.GetHoleExpTotalCanAdd(self.viewData.holeConfig.HoleId) - self.seasonCultivateVM_.GetHoleExpTotalCurrent(self.viewData.holeConfig.HoleId), 0)
  if currentAddExp >= canAddExp then
    return false
  end
  local addExp = self.expItemOffered_[itemId]
  if canAddExp < addExp + currentAddExp then
    return false
  end
  local count = self.itemVM_.GetItemTotalCount(itemId)
  if count <= self.addItem_[itemId] then
    return false
  end
  return true
end

function SeasonCultivateNode:checkAddItem(itemId, isShowError)
  if not self.addItem_[itemId] then
    self.addItem_[itemId] = 0
  end
  if self.isMaxLevel_ then
    return false
  end
  local currentAddExp = self:calculateAddExp(false)
  local canAddExp = Mathf.Max(self.seasonCultivateVM_.GetHoleExpTotalCanAdd(self.viewData.holeConfig.HoleId) - self.seasonCultivateVM_.GetHoleExpTotalCurrent(self.viewData.holeConfig.HoleId), 0)
  if currentAddExp >= canAddExp then
    Z.TipsVM.ShowTips(150037)
    return false
  end
  local count = self.itemVM_.GetItemTotalCount(itemId)
  if count <= self.addItem_[itemId] then
    return false
  end
  return true
end

function SeasonCultivateNode:checkAddEnoughTip(targetTrans)
  local lackingItemId
  for itemId, perExp in pairs(self.expItemOffered_) do
    local haveCount = self.itemVM_.GetItemTotalCount(itemId)
    if 0 < haveCount then
      lackingItemId = nil
      break
    elseif lackingItemId == nil then
      lackingItemId = itemId
    end
  end
  if lackingItemId then
    local itemName = self.itemVM_.ApplyItemNameWithQualityTag(lackingItemId)
    Z.TipsVM.ShowTips(124015, {val = itemName})
    self:closeSourceTip()
    self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(lackingItemId, targetTrans)
  end
  return lackingItemId == nil
end

function SeasonCultivateNode:closeSourceTip()
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
end

function SeasonCultivateNode:tryChangeItem(itemId, add)
  if not self.addItem_[itemId] then
    self.addItem_[itemId] = 0
  end
  if add then
    local isAdd = self:checkAddItem(itemId, true)
    if isAdd then
      self.addItem_[itemId] = self.addItem_[itemId] + 1
    else
      return false
    end
  else
    if self.addItem_[itemId] <= 0 then
      return false
    end
    self.addItem_[itemId] = self.addItem_[itemId] - 1
  end
  return true
end

function SeasonCultivateNode:calculateAddExp(needRefreshItem)
  if needRefreshItem == nil then
    needRefreshItem = true
  end
  local addExp = 0
  for id, num in pairs(self.addItem_) do
    if self.expItemOffered_[id] then
      addExp = addExp + self.expItemOffered_[id] * num
    end
    if needRefreshItem then
      local itemUnitName = self.itemUnit_[id]
      if itemUnitName then
        local itemUnit = self.units[itemUnitName]
        itemUnit.Ref:SetVisible(itemUnit.btn_minus, 0 < num)
      end
      local instance = self.itemClass_[id]
      if instance then
        local totalCount = self.itemVM_.GetItemTotalCount(id)
        if 0 < num then
          instance:SetSelected(true, false)
          instance:SetExpendCount(totalCount, self.addItem_[id])
        else
          instance:SetSelected(false, false)
          instance:SetLab(totalCount)
        end
        self:refreshItemRed(id)
      end
    end
  end
  return addExp
end

function SeasonCultivateNode:setAddExp(addExp)
  local holeId = self.viewData.holeConfig.HoleId
  local attrId = self.viewData.attrConfig.NodeId
  local level, remainExp, needExp = self.seasonCultivateVM_.GetHoleExpInfo(holeId, addExp)
  self.needMoney_ = addExp * self.expNeedMoneyNum_
  local hasMoney = self.itemVM_.GetItemTotalCount(self.expNeedMoneyID_)
  local needMoneyText = tostring(self.needMoney_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_gold, self.needMoney_ > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_gold_bg, self.needMoney_ > 0)
  if hasMoney < self.needMoney_ then
    needMoneyText = Z.RichTextHelper.ApplyStyleTag(needMoneyText, E.TextStyleTag.TipsRed)
  end
  self.uiBinder.lab_money.text = needMoneyText
  self.uiBinder.lab_schedule.text = _formatStr("{0}/{1}", remainExp, needExp)
  self.uiBinder.slider_temp.value = remainExp / needExp
  local currentAttr = self.seasonCultivateVM_.GetAttributeConfigByLevel(attrId, level)
  self.uiBinder.lab_current_effect.text = self.seasonCultivateVM_.GetAttributeDes(currentAttr.Id)
  local maxLevel = self.seasonCultivateVM_.GetHoleMaxLevel(holeId)
  self.isMaxLevel_ = level >= maxLevel
  if addExp == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_level, not self.isMaxLevel_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, not self.isMaxLevel_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_gold, not self.isMaxLevel_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_max_state, self.isMaxLevel_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_square_new, not self.isMaxLevel_)
  end
  self.uiBinder.lab_level_num.text = _formatStr("{0}/{1}", level, maxLevel)
  if level < maxLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_next_effect, true)
    local tempNextAttr = self.seasonCultivateVM_.GetAttributeConfigByLevel(attrId, level + 1)
    self.uiBinder.lab_next_effect.text = self.seasonCultivateVM_.GetAttributeDes(tempNextAttr.Id)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_next_effect, false)
  end
  if level ~= self.currentLevel_ then
    self.currentLevel_ = level
    for i, v in pairs(self.conditionUnit_) do
      self:RemoveUiUnit(v)
    end
    self.conditionUnit_ = {}
    if level <= maxLevel then
      Z.CoroUtil.create_coro_xpcall(function()
        local lv = level + 1 > maxLevel and maxLevel or level + 1
        local tempHole = self.seasonCultivateVM_.GetHoleConfigByLevel(holeId, lv)
        self:addNodeCondition(tempHole.NodeCondition)
        self:addCondition(tempHole.Condition)
      end)()
    end
  end
  local exp = self:calculateAddExp(false)
  self.uiBinder.btn_square_new.IsDisabled = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, true)
  if exp <= 0 or hasMoney < self.needMoney_ then
    self.uiBinder.btn_square_new.IsDisabled = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, false)
  end
end

function SeasonCultivateNode:addNodeCondition(condition)
  local ConditionUnitPath = self:getIsPcPre()
  for i, v in pairs(condition) do
    local name = _formatStr("node_condition_{0}", i)
    local unit = self:AsyncLoadUiUnit(ConditionUnitPath, name, self.uiBinder.node_condition.transform, self.cancelSource:CreateToken())
    if unit then
      self.conditionUnit_[#self.conditionUnit_ + 1] = name
      local type = v[1]
      local need = v[2]
      local current = 0
      if type == 1 then
        current = self.seasonCultivateVM_.GetNormalNodeTotalLevel()
      else
        current = self.seasonCultivateVM_.GetCoreNodeLevel()
      end
      local text = type == 1 and Lang("NormalNodeLevel") or Lang("CoreNodeLevel")
      local numText = _formatStr("{0}/{1}", current, need)
      if need <= current then
        text = Z.RichTextHelper.ApplyStyleTag(text, E.TextStyleTag.GreenTextColor2)
        numText = Z.RichTextHelper.ApplyStyleTag(numText, E.TextStyleTag.GreenTextColor2)
      end
      unit.lab_condition.text = text
      unit.lab_condition_schedule.text = numText
    end
  end
end

function SeasonCultivateNode:addCondition(condition)
  if Z.ConditionHelper.CheckCondition(condition) then
    return
  end
  local results = self.seasonCultivateVM_.GetConditionDesc(condition)
  local ConditionUnitPath = self:getIsPcPre()
  for i, result in pairs(results) do
    local name = _formatStr("condition_{0}", i)
    local unit = self:AsyncLoadUiUnit(ConditionUnitPath, name, self.uiBinder.node_condition.transform, self.cancelSource:CreateToken())
    if unit then
      self.conditionUnit_[#self.conditionUnit_ + 1] = name
      local text = result.Desc
      local numText = result.Progress
      if result.IsUnlock then
        text = Z.RichTextHelper.ApplyStyleTag(text, E.TextStyleTag.RoloLabAttr)
        numText = Z.RichTextHelper.ApplyStyleTag(numText, E.TextStyleTag.RoloLabAttr)
      end
      unit.lab_condition.text = text
      unit.lab_condition_schedule.text = numText
    end
  end
end

function SeasonCultivateNode:onConfirmReset()
  Z.CoroUtil.create_coro_xpcall(function()
    local success = self.seasonCultivateVM_.AsyncResetNormalSeasonHoles(self.viewData.holeConfig.HoleId, self.cancelSource:CreateToken())
    if success then
      local all = self.seasonCultivateVM_.GetAllNormalNodeInfo()
      self.viewData = all[self.viewData.holeConfig.HoleId]
      self:OnRefresh()
      Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnResetHole, self.viewData.holeConfig.HoleId)
    end
  end)()
end

return SeasonCultivateNode
