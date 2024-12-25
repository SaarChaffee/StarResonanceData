local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_develop_attribute_subView = class("Weapon_develop_attribute_subView", super)
local itemClass = require("common.item")
local LEFT_ITEM_COUNT = 4

function Weapon_develop_attribute_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_attribute_sub", "weapon_develop/weapon_develop_attribute_sub", UI.ECacheLv.None)
end

function Weapon_develop_attribute_subView:OnActive()
  self:startAnimatedShow()
  self:BindLuaAttrWatchers()
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.vm_ = Z.VMMgr.GetVM("weapon")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.roleVm_ = Z.VMMgr.GetVM("role_info_attr_detail")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.upGradeMat_ = {}
  self.itemClassTab_ = {}
  self.itemUnits_ = {}
  self.levelItem_ = {}
  local costItemIDs = {}
  local materials = Z.Global.WeaponLevelUpItem
  for _, info in ipairs(materials) do
    local item = {}
    item.itemID = info[1]
    item.effect = info[2]
    item.costItemID = info[3]
    item.costItemCnt = info[4]
    table.insert(self.levelItem_, item)
    table.insert(costItemIDs, info[3])
    self.upGradeMat_[info[1]] = 0
  end
  self.recordExp_ = 0
  self.recordLv_ = 1
  self.recordCoin_ = {}
  self.maxLv_ = table.zcount(Z.TableMgr.GetTable("WeaponLevelTableMgr").GetDatas())
  self.attrUnits_ = {}
  self:AddClick(self.uiBinder.btn_clear, function()
    self:clearRecordItem()
    self:refreshDefalutAttr()
    self:refreshItemCost()
  end)
  self:AddClick(self.uiBinder.btn_join, function()
    self:oneKeyAdd()
    self:refreshItemCost()
  end)
  local currencyVm = Z.VMMgr.GetVM("currency")
  currencyVm.OpenCurrencyView(costItemIDs, self.uiBinder.anim_tran, self)
end

function Weapon_develop_attribute_subView:OnDeActive()
  self:UnBindLuaAttrWatchers()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  for _, value in ipairs(self.attrUnits_) do
    self:RemoveUiUnit(value)
  end
  Z.CommonTipsVM.CloseTipsTitleContent()
  local currencyVm = Z.VMMgr.GetVM("currency")
  currencyVm.CloseCurrencyView(self)
end

function Weapon_develop_attribute_subView:BindLuaAttrWatchers()
  function self.onContainerChanged(container, dirty)
    if dirty.weaponList then
      if self.cacheLv_ ~= self.weapon_.level then
        local viewData = {
          viewType = self.upGradeType,
          
          preLevel = self.cacheLv_,
          weaponId = self.weapon_.weaponId
        }
        self.vm_.OpenUpgradeView(viewData)
      end
      Z.CoroUtil.create_coro_xpcall(function()
        self:clearRecordItem()
        self:refreshBaseInfo()
      end)()
    end
  end
  
  Z.ContainerMgr.CharSerialize.professionList.Watcher:RegWatcher(self.onContainerChanged)
  
  function self.onCostItemChanged()
    if not self.levelConfig_.Broke or self.weapon_.experience < self.levelConfig_.Exp then
      self:refreshItemMat()
    end
  end
  
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:RegWatcher(self.onCostItemChanged)
end

function Weapon_develop_attribute_subView:UnBindLuaAttrWatchers()
  if self.onContainerChanged ~= nil then
    Z.ContainerMgr.CharSerialize.professionList.Watcher:UnregWatcher(self.onContainerChanged)
    self.onContainerChanged = nil
  end
  if self.onCostItemChanged ~= nil then
    Z.ContainerMgr.CharSerialize.itemPackage.Watcher:UnregWatcher(self.onCostItemChanged)
    self.onCostItemChanged = nil
  end
end

function Weapon_develop_attribute_subView:OnRefresh()
  self.weapon_ = self.vm_.GetWeaponInfo(self.viewData.weaponId)
  if self.weapon_ == nil then
    return
  end
  self:clearRecordItem()
  self:refreshBaseInfo()
end

function Weapon_develop_attribute_subView:refreshBaseInfo()
  self.levelConfig_ = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(self.weapon_.level)
  local weaponCfg = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.viewData.weaponId)
  if weaponCfg == nil then
    return
  end
  self.uiBinder.lab_name.text = weaponCfg.Name
  if self.levelConfig_ == nil then
    return
  end
  self.uiBinder.btn_job_image:SetImage(GetLoadAssetPath("WepaonElementIconPath_" .. weaponCfg.Element))
  self:AddClick(self.uiBinder.btn_job, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(10014)
  end)
  self:refreshDefalutAttr()
  if self.weapon_.level < self.maxLv_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.upgrade_group, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ok, true)
    if self.levelConfig_.Broke and self.weapon_.experience >= self.levelConfig_.Exp then
      self:refreshOverStep()
    else
      self:refreshLevelUpGrade()
      self:refreshItemCost()
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.upgrade_group, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ok, false)
  end
end

function Weapon_develop_attribute_subView:refreshDefalutAttr()
  local exp = self.weapon_.experience
  local level = self.weapon_.level
  self.uiBinder.lab_level.text = Lang("Lv") .. level
  self.uiBinder.lab_level_limit.text = "/" .. self.maxLv_
  if self.weapon_.level == self.maxLv_ then
    local config = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(self.maxLv_ - 1)
    if config == nil then
      return
    end
    self.uiBinder.exp_slider.value = 1
    self.uiBinder.lab_exp.text = config.Exp .. "/" .. config.Exp
  else
    self.uiBinder.exp_slider.value = exp / self.levelConfig_.Exp
    self.uiBinder.lab_exp.text = exp .. "/" .. self.levelConfig_.Exp
  end
  self.uiBinder.record_img.fillAmount = 0
  local talentTags = {
    [1] = self.uiBinder.btn_choose01,
    [2] = self.uiBinder.btn_choose02,
    [3] = self.uiBinder.btn_choose03
  }
  for _, value in ipairs(talentTags) do
    value.Ref:SetVisible(value.img_on, false)
    value.Ref:SetVisible(value.img_off, false)
    self.uiBinder.Ref:SetVisible(value.Ref, false)
  end
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.weapon_.weaponId)
  for index, value in ipairs(weaponConfig.Talent) do
    local talentConfig = Z.TableMgr.GetTable("TalentTagTableMgr").GetRow(value)
    if talentConfig then
      do
        local container = talentTags[index]
        self.uiBinder.Ref:SetVisible(container.Ref, true)
        container.Ref:SetVisible(container.img_off, true)
        container.img_icon_on:SetImage(talentConfig.TagIconMark)
        container.img_icon_off:SetImage(talentConfig.TagIconMark)
        self:AddClick(container.btn, function()
          Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, talentConfig.TagName, talentConfig.DetailsDes)
        end)
      end
    end
  end
  talentTags[1].Ref:SetVisible(talentTags[1].img_on, true)
  local attr = self.vm_.GetAttrPreview(self.weapon_.weaponId, self.weapon_.level, true)
  local path = self.uiBinder.prefab_cache:GetString("attr_unit")
  local root = self.uiBinder.numerical_group
  for _, value in ipairs(self.attrUnits_) do
    self:RemoveUiUnit(value)
  end
  self.attrUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for _, value in ipairs(attr) do
      local name = "attr_" .. value.attrId
      table.insert(self.attrUnits_, name)
      local unit = self:AsyncLoadUiUnit(path, name, root)
      local str = self.fightAttrParseVm_.ParseFightAttrNumber(value.attrId, value.number, true)
      self:refreshAttrUnit(unit, value.attrId, str)
    end
  end)()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_gold, false)
end

function Weapon_develop_attribute_subView:refreshAttrUnit(uibinder, id, str)
  if uibinder == nil then
    return
  end
  local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(id)
  if fightAttrData == nil then
    return
  end
  uibinder.lab_number.text = str
  uibinder.lab_name.text = fightAttrData.OfficialName
  local path = Z.ConstValue.AttrIcon[id]
  if path == nil then
    path = Z.ConstValue.AttrIcon[fightAttrData.Id]
  end
  local iconPath = GetLoadAssetPath(path or Z.ConstValue.WeaponSpecialAttrIcon)
  uibinder.img_icon:SetImage(iconPath)
  uibinder.btn:RemoveAllListeners()
  self:AddAsyncClick(uibinder.btn, function()
    self:showAttrDetails(id)
  end)
end

function Weapon_develop_attribute_subView:showAttrDetails(id)
  local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(id)
  if fightAttrData then
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, fightAttrData.OfficialName, fightAttrData)
  end
end

function Weapon_develop_attribute_subView:refreshLevelUpGrade()
  self.uiBinder.lab_title.text = Lang("levelUp")
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_clear_group, true)
  self.uiBinder.btn_ok_binder.lab_content.text = Lang("levelUp")
  self.uiBinder.lab_digit.text = Z.RichTextHelper.ApplyStyleTag(0, E.TextStyleTag.White)
  self:refreshItemMat()
  if #self.levelItem_ >= LEFT_ITEM_COUNT then
    self.uiBinder.group_item_Hlayoutgroup.childAlignment = UnityEngine.TextAnchor.UpperLeft
  else
    self.uiBinder.group_item_Hlayoutgroup.childAlignment = UnityEngine.TextAnchor.UpperCenter
  end
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    local matEnough = false
    for _, value in pairs(self.upGradeMat_) do
      if 0 < value then
        matEnough = true
      end
    end
    if not matEnough then
      Z.TipsVM.ShowTipsLang(130018)
      return
    end
    local coinEnough = true
    for itemid, count in pairs(self.recordCoin_) do
      local totalCount = self.itemVm_.GetItemTotalCount(itemid)
      if count > totalCount then
        coinEnough = false
        break
      end
    end
    if coinEnough == false then
      local coinId = self.levelItem_[1].costItemID
      local coinConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(coinId)
      if coinConfig then
        local param = {
          val = coinConfig.Name
        }
        Z.TipsVM.ShowTipsLang(130019, param)
      end
      return
    end
    self.upGradeType = E.UpgradeType.WeaponHeroLevel
    self.cacheLv_ = self.weapon_.level
    self.vm_.AsyncWeaponLevelUp(self.weapon_.weaponId, self.upGradeMat_, self.cancelSource:CreateToken())
  end)
end

function Weapon_develop_attribute_subView:refreshItemMat()
  local parent = self.uiBinder.group_item
  for name, _ in pairs(self.itemUnits_) do
    self:RemoveUiUnit(name)
  end
  for _, value in ipairs(self.levelItem_) do
    local uiUnitName = value.itemID
    if self.cancelTokens[uiUnitName] then
      Z.CancelSource.ReleaseToken(self.cancelTokens[uiUnitName])
      self.cancelTokens[uiUnitName] = nil
    end
  end
  self.itemUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for _, value in ipairs(self.levelItem_) do
      local totalCount = self.itemVm_.GetItemTotalCount(value.itemID)
      local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.Item_Unit_Addr), value.itemID, parent)
      self.itemUnits_[value.itemID] = unit
      self.itemClassTab_[value.itemID] = itemClass.new(self)
      local itemClassData = {
        unit = unit,
        configId = value.itemID,
        isShowZero = true,
        lab = totalCount
      }
      if totalCount ~= 0 then
        function itemClassData.clickCallFunc()
          self:calculateExpItem(value, true)
        end
      end
      self.itemClassTab_[value.itemID]:Init(itemClassData)
      self:AddClick(unit.cont_info.btn_close.Btn, function()
        self:calculateExpItem(value, false)
      end)
    end
  end)()
end

function Weapon_develop_attribute_subView:calculateExpItem(item, add)
  local heroLvConfig = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(self.recordLv_)
  if not heroLvConfig then
    return
  end
  if add and self.recordExp_ >= self:getLevelUpMaxExp() and (heroLvConfig.Broke or self.recordLv_ >= self.maxLv_) then
    Z.TipsVM.ShowTipsLang(130020)
    return
  end
  if self.upGradeMat_[item.itemID] == 0 and add == false then
    return
  end
  local totalCount = self.itemVm_.GetItemTotalCount(item.itemID)
  if totalCount <= self.upGradeMat_[item.itemID] and add then
    return
  end
  if add then
    self.recordExp_ = self.recordExp_ + item.effect
    self.upGradeMat_[item.itemID] = self.upGradeMat_[item.itemID] + 1
  else
    self.recordExp_ = self.recordExp_ - item.effect
    self.upGradeMat_[item.itemID] = self.upGradeMat_[item.itemID] - 1
  end
  local allExp = self.weapon_.experience + self.recordExp_
  local recordLv = self.weapon_.level
  for lv = self.weapon_.level, self.maxLv_ do
    local recordconfig = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(lv)
    if allExp < recordconfig.Exp or recordconfig.Broke then
      recordLv = lv
      break
    end
    if lv == self.maxLv_ then
      recordLv = lv
      break
    end
    allExp = allExp - recordconfig.Exp
  end
  self.recordLv_ = recordLv
  self:refreshItemCost()
  self:refreshRecordAttr(recordLv, allExp)
end

function Weapon_develop_attribute_subView:clearRecordItem()
  self.recordExp_ = 0
  self.recordLv_ = self.weapon_.level
  self.recordCoin_ = {}
  for key, _ in pairs(self.upGradeMat_) do
    self.upGradeMat_[key] = 0
  end
end

function Weapon_develop_attribute_subView:oneKeyAdd()
  self:clearRecordItem()
  local allExp = self:getLevelUpMaxExp()
  local empty = true
  local levelItem = table.zdeepCopy(self.levelItem_)
  table.sort(levelItem, function(a, b)
    return a.effect > b.effect
  end)
  local totalCoinCount = self.itemVm_.GetItemTotalCount(self.levelItem_[1].costItemID)
  for _, item in ipairs(levelItem) do
    local needCount = math.ceil(allExp / item.effect)
    local totalItemCount = self.itemVm_.GetItemTotalCount(item.itemID)
    if 0 < totalItemCount then
      empty = false
    end
    local maxAddCount = math.floor(totalCoinCount / item.costItemCnt)
    if totalItemCount < maxAddCount then
      maxAddCount = totalItemCount
    end
    totalCoinCount = totalCoinCount - maxAddCount * item.costItemCnt
    if needCount <= maxAddCount then
      allExp = allExp - needCount * item.effect
      self.upGradeMat_[item.itemID] = needCount
      break
    end
    allExp = allExp - maxAddCount * item.effect
    self.upGradeMat_[item.itemID] = maxAddCount
  end
  if empty then
    Z.TipsVM.ShowTipsLang(130021)
    return
  end
  local emptyCoin = true
  for _, value in pairs(self.upGradeMat_) do
    if value ~= 0 then
      emptyCoin = false
    end
  end
  if emptyCoin then
    local coinId = self.levelItem_[1].costItemID
    local coinConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(coinId)
    if coinConfig then
      local param = {
        val = coinConfig.Name
      }
      Z.TipsVM.ShowTipsLang(130019, param)
    end
    return
  end
  self.recordExp_ = 0
  for _, item in ipairs(levelItem) do
    local count = self.upGradeMat_[item.itemID]
    if count and 0 < count then
      local exp = count * item.effect
      self.recordExp_ = self.recordExp_ + exp
    end
  end
  local exp = self.recordExp_ + self.weapon_.experience
  for lv = self.weapon_.level, self.maxLv_ do
    local config = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(lv)
    if exp < config.Exp or config.Broke then
      self.recordLv_ = lv
      break
    end
    if lv == self.maxLv_ then
      self.recordLv_ = lv
      break
    end
    exp = exp - config.Exp
  end
  self:refreshRecordAttr(self.recordLv_, exp)
end

function Weapon_develop_attribute_subView:refreshItemCost()
  for name, unit in pairs(self.itemUnits_) do
    local itemID = tonumber(name)
    local totalCount = self.itemVm_.GetItemTotalCount(itemID)
    if self.upGradeMat_[itemID] > 0 then
      unit.cont_info.btn_close:SetVisible(true)
      self.itemClassTab_[name]:SetSelected(true, false)
      self.itemClassTab_[name]:SetExpendCount(totalCount, self.upGradeMat_[itemID])
    else
      unit.cont_info.btn_close:SetVisible(false)
      self.itemClassTab_[name]:SetSelected(false, false)
      self.itemClassTab_[name]:SetLab(totalCount)
    end
  end
  self.recordCoin_ = {}
  for _, value in ipairs(self.levelItem_) do
    if self.upGradeMat_[value.itemID] ~= 0 then
      if self.recordCoin_[value.costItemID] == nil then
        self.recordCoin_[value.costItemID] = 0
      end
      self.recordCoin_[value.costItemID] = self.upGradeMat_[value.itemID] * value.costItemCnt + self.recordCoin_[value.costItemID]
    end
  end
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.levelItem_[1].costItemID)
  if itemConfig == nil then
    return
  end
  self.uiBinder.rimg_gold:SetImage(self.itemVm_.GetItemIcon(self.levelItem_[1].costItemID))
  if self.recordCoin_[self.levelItem_[1].costItemID] == nil then
    self.recordCoin_[self.levelItem_[1].costItemID] = 0
  end
  local count = self.recordCoin_[self.levelItem_[1].costItemID]
  local totalCount = self.itemVm_.GetItemTotalCount(self.levelItem_[1].costItemID)
  self.uiBinder.btn_ok.IsDisabled = true
  if count == 0 then
    for _, value in pairs(self.upGradeMat_) do
      if value ~= 0 then
        self.uiBinder.btn_ok.IsDisabled = false
        break
      end
    end
  else
    self.uiBinder.btn_ok.IsDisabled = count > totalCount
  end
  if count == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_gold, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_gold, true)
    if count <= totalCount then
      self.uiBinder.lab_digit.text = Z.RichTextHelper.ApplyStyleTag(count, E.TextStyleTag.White)
    else
      self.uiBinder.lab_digit.text = Z.RichTextHelper.ApplyStyleTag(count, E.TextStyleTag.ItemNotEnough)
    end
  end
end

function Weapon_develop_attribute_subView:getLevelUpMaxExp()
  local allexp = 0 - self.weapon_.experience
  for lv = self.weapon_.level, self.maxLv_ - 1 do
    local config = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(lv)
    allexp = allexp + config.Exp
    if config.Broke then
      break
    end
  end
  return allexp
end

function Weapon_develop_attribute_subView:refreshOverStep()
  local weaponTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.viewData.weaponId)
  if weaponTableRow == nil then
    return
  end
  self.uiBinder.lab_title.text = Lang("Breach")
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_clear_group, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_gold, false)
  self.uiBinder.btn_ok_binder.lab_content.text = Lang("Breach")
  local costMat = {}
  for _, value in pairs(self.levelConfig_.ItemPrice) do
    local temp = {}
    temp.itemID = value[1]
    temp.itemCount = value[2]
    table.insert(costMat, temp)
  end
  for _, value in pairs(self.levelConfig_.ExtrCost) do
    local temp = {}
    temp.itemID = weaponTableRow.ProfessionBrokeExtraItem[1][value[1]]
    temp.itemCount = value[2]
    table.insert(costMat, temp)
  end
  local itemCountEnough = true
  local parent = self.uiBinder.group_item
  for name, value in pairs(self.itemUnits_) do
    self:RemoveUiUnit(name)
  end
  self.itemUnits_ = {}
  for _, value in ipairs(costMat) do
    local uiUnitName = value.itemID
    if self.cancelTokens[uiUnitName] then
      Z.CancelSource.ReleaseToken(self.cancelTokens[uiUnitName])
      self.cancelTokens[uiUnitName] = nil
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, value in ipairs(costMat) do
      local totalCount = self.itemVm_.GetItemTotalCount(value.itemID)
      if totalCount < value.itemCount then
        itemCountEnough = false
      end
      local unit = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Backpack.Item_Unit_Addr), value.itemID, parent)
      self.itemUnits_[value.itemID] = unit
      self.itemClassTab_[value.itemID] = itemClass.new(self)
      self.itemClassTab_[value.itemID]:Init({
        unit = unit,
        configId = value.itemID,
        labType = E.ItemLabType.Expend,
        lab = totalCount,
        expendCount = value.itemCount
      })
    end
    if #costMat >= LEFT_ITEM_COUNT then
      self.uiBinder.group_item_Hlayoutgroup.childAlignment = UnityEngine.TextAnchor.UpperLeft
    else
      self.uiBinder.group_item_Hlayoutgroup.childAlignment = UnityEngine.TextAnchor.UpperCenter
    end
    self.uiBinder.lab_exp.text = self.weapon_.experience .. "/" .. self.levelConfig_.Exp
    self.uiBinder.btn_ok.IsDisabled = not itemCountEnough
    self:AddAsyncClick(self.uiBinder.btn_ok, function()
      if itemCountEnough then
        self.upGradeType = E.UpgradeType.WeaponHeroOverstep
        self.cacheLv_ = self.weapon_.level
        self.vm_.AsyncWeaponOverStep(self.weapon_.weaponId, self.cancelSource:CreateToken())
      else
        Z.TipsVM.ShowTipsLang(130022)
      end
    end)
  end)()
end

function Weapon_develop_attribute_subView:refreshRecordAttr(recordLv, extraExp)
  if recordLv == self.weapon_.level and extraExp == self.weapon_.experience then
    self:refreshDefalutAttr()
    return
  end
  local recordconfig = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(recordLv)
  if not recordconfig then
    return
  end
  if extraExp < 0 then
    extraExp = 0
  end
  self.uiBinder.lab_level.text = Lang("LvFormat", {val = recordLv})
  self.uiBinder.lab_level_limit.text = "/" .. self.maxLv_
  if recordLv == self.maxLv_ then
    local config = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(self.maxLv_ - 1)
    if config == nil then
      return
    end
    self.uiBinder.record_img.fillAmount = 0
    self.uiBinder.exp_slider.value = 1
    self.uiBinder.lab_exp.text = extraExp + config.Exp .. "/" .. config.Exp
  else
    self.uiBinder.record_img.fillAmount = extraExp / recordconfig.Exp
    self.uiBinder.lab_exp.text = extraExp .. "/" .. recordconfig.Exp
    if recordLv == self.weapon_.level then
      self.uiBinder.exp_slider.value = self.weapon_.experience / self.levelConfig_.Exp
    else
      self.uiBinder.exp_slider.value = 0
    end
  end
  local nowAttr = self.vm_.GetAttrPreview(self.weapon_.weaponId, self.weapon_.level)
  local nextAttr = self.vm_.GetAttrPreview(self.weapon_.weaponId, recordLv, true)
  local attr = {}
  for index, value in ipairs(nextAttr) do
    if nowAttr[value.attrId] == nil then
      nowAttr[value.attrId] = 0
    end
    attr[index] = {}
    attr[index].attrId = value.attrId
    attr[index].number = value.number - nowAttr[value.attrId]
  end
  local path = self.uiBinder.prefab_cache:GetString("attr_unit")
  local root = self.uiBinder.numerical_group
  for _, value in ipairs(self.attrUnits_) do
    self:RemoveUiUnit(value)
  end
  self.attrUnits_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(attr) do
      local name = "attr_" .. value.attrId
      table.insert(self.attrUnits_, name)
      local unit = self:AsyncLoadUiUnit(path, name, root)
      local nowvalue = self.fightAttrParseVm_.ParseFightAttrNumber(value.attrId, nowAttr[value.attrId], true)
      local diffValue = self.fightAttrParseVm_.ParseFightAttrNumber(value.attrId, value.number, true)
      local str = nowvalue
      if value.number > 0 then
        str = nowvalue .. Z.Placeholder.SetTextSize(Z.RichTextHelper.ApplyStyleTag("+" .. diffValue, E.TextStyleTag.AttrUp))
      end
      self:refreshAttrUnit(unit, value.attrId, str)
    end
  end)()
end

function Weapon_develop_attribute_subView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

return Weapon_develop_attribute_subView
