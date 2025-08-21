local super = require("ui.ui_subview_base")
local SeasonCultivateCore = class("SeasonCultivateCore", super)
local ConditionUnitPath
if Z.IsPCUI then
  ConditionUnitPath = GetLoadAssetPath("SeasonCultivateConditionUnit_PC")
else
  ConditionUnitPath = GetLoadAssetPath("SeasonCultivateConditionUnit")
end
local ItemClass = require("common.item_binder")

function SeasonCultivateCore:ctor()
  super.ctor(self, "season_cultivate_core", "season_cultivate/season_cultivate_core_sub", Z.UI.ECacheLv.None, true)
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
  self.itemVM_ = Z.VMMgr.GetVM("items")
end

function SeasonCultivateCore:initBinder()
  self.levelLab_ = self.uiBinder.lab_level
  self.contentLab_ = self.uiBinder.lab_content
  self.randomLab_ = self.uiBinder.lab_random
end

function SeasonCultivateCore:initBtns()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SeasonCultivateCoreBtnRed, self, self.uiBinder.btn_levelup.transform)
  self:AddAsyncClick(self.uiBinder.btn_levelup, function()
    if self.canUpgradeState_ == 1 then
      if self.errFunc_ then
        self.errFunc_()
      end
      return
    end
    if self.canUpgradeState_ ~= 0 then
      local curLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
      local itemName = self.itemVM_.ApplyItemNameWithQualityTag(self.canUpgradeState_)
      Z.TipsVM.ShowTips(0 < curLevel and 124015 or 124016, {val = itemName})
      self:closeSourceTip()
      self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(self.canUpgradeState_, self.uiBinder.btn_levelup.transform)
      return
    end
    self.seasonCultivateVM_.AsyncUpgradeSeasonCoreMedalHole(self.cancelSource:CreateToken())
  end)
end

function SeasonCultivateCore:closeSourceTip()
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
end

function SeasonCultivateCore:initData()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.attrUnit_ = {}
  self.conditionUnit_ = {}
  self.itemUnit_ = {}
  self.itemClass_ = {}
  self.canUpgradeState_ = 0
end

function SeasonCultivateCore:initUi()
  self.uiBinder.trans_attr.localPosition = Vector2.New(0, 0)
end

function SeasonCultivateCore:OnActive()
  self:initBinder()
  self:initBtns()
  self:initData()
  self:initUi()
  self:addWatcher()
end

function SeasonCultivateCore:addWatcher()
  function self.refreshCoreUI(container, dirtys)
    if dirtys then
      if dirtys.coreHoleNodeInfos then
        for k, _ in pairs(dirtys.coreHoleNodeInfos) do
          self.upgradeHoleNodeId_ = k
          
          local config = Z.TableMgr.GetTable("SeasonNodeDataTableMgr").GetRow(k * 1000 + 1)
          local current = self.seasonCultivateVM_.GetCoreNodeLevel()
          if config and 1 < current then
            Z.TipsVM.ShowTips(124025, {
              val = config.NodeName
            })
          end
          Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnUpgradeHole, E.SeasonCultivateHole.Core)
        end
      end
      self:OnRefresh()
    end
  end
  
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:RegWatcher(self.refreshCoreUI)
end

function SeasonCultivateCore:removeWatcher()
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:UnregWatcher(self.refreshCoreUI)
end

function SeasonCultivateCore:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.canUpgradeState_ = 0
    self:resetCondition()
    self:resetItem()
    self:resetAttr()
  end)()
end

function SeasonCultivateCore:OnDeActive()
  self:removeWatcher()
  self.attrUnit_ = nil
  self.conditionUnit_ = nil
  self.itemUnit_ = nil
  self.canUpgradeState_ = nil
  for _, v in pairs(self.itemClass_) do
    v:UnInit()
  end
  self.itemClass_ = nil
  self:closeSourceTip()
  Z.CommonTipsVM.CloseRichText()
  if self.errFunc_ then
    self.errFunc_ = nil
  end
end

function SeasonCultivateCore:resetAttr()
  for name, _ in pairs(self.attrUnit_) do
    self:RemoveUiUnit(name)
  end
  self.attrUnit_ = {}
  local infos = self.seasonCultivateVM_.GetCoreNodeInfo()
  if not next(infos) then
    local holeConfig = self.seasonCultivateVM_.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, 1)
    for _, v in pairs(holeConfig.NodeId) do
      local attrConfig = self.seasonCultivateVM_.GetAttributeConfigByLevel(v, 1)
      table.insert(infos, {choose = false, attrConfig = attrConfig})
    end
  end
  if self.upgradeHoleNodeId_ then
    local index
    for key, value in ipairs(infos) do
      if self.upgradeHoleNodeId_ == value.attrConfig.NodeId then
        index = key
      end
    end
    if index then
      local tmp_ = infos[index]
      table.remove(infos, index)
      table.insert(infos, 1, tmp_)
    end
    self.upgradeHoleNodeId_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_attr, false)
  local CoreAttributeUnitPath
  if Z.IsPCUI then
    CoreAttributeUnitPath = GetLoadAssetPath("SeasonCultivateCoreAttributeUnit_PC")
  else
    CoreAttributeUnitPath = GetLoadAssetPath("SeasonCultivateCoreAttributeUnit")
  end
  for _, info in ipairs(infos) do
    local name = _formatStr("attribute_{0}", info.attrConfig.NodeId)
    local unit = self:AsyncLoadUiUnit(CoreAttributeUnitPath, name, self.uiBinder.trans_attr.transform, self.cancelSource:CreateToken())
    if unit then
      self.attrUnit_[name] = unit
      unit.img_icon:SetImage(info.attrConfig.NodeIcon)
      local config = Z.TableMgr.GetTable("SeasonNodeDataTableMgr").GetRow(info.attrConfig.Id)
      local name = config and config.NodeName .. ": " or ""
      Z.RichTextHelper.SetBinderTmpLabTextWithCommonLink(unit.lab_info, name .. self.seasonCultivateVM_.GetAttributeDes(info.attrConfig.Id))
      unit.lab_level.text = info.nodeLevel
      local isChoose = self.seasonCultivateVM_.CheckCoreAttrIsChooseByNodeId(info.attrConfig.NodeId)
      unit.Ref:SetVisible(unit.img_select, isChoose)
      unit.Ref:SetVisible(unit.img_use, isChoose)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_attr, true)
end

function SeasonCultivateCore:resetCondition()
  for name, _ in pairs(self.conditionUnit_) do
    self:RemoveUiUnit(name)
  end
  self.conditionUnit_ = {}
  local max = self.seasonCultivateVM_.GetHoleMaxLevel(E.SeasonCultivateHole.Core)
  local current = self.seasonCultivateVM_.GetCoreNodeLevel()
  local hasNext = max > current
  self.levelLab_.text = Lang("LvFormat", {val = current})
  if current == 0 then
    self.uiBinder.lab_condition.text = Lang("SeasonCultivateCoreNum", {
      val = self.seasonCultivateVM_.GetCoreAttrCanChooseCount(1)
    })
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_active_tip, current == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_levelup, hasNext)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, hasNext)
  self.uiBinder.Ref:SetVisible(self.randomLab_, 0 < current and hasNext)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_max_state, not hasNext)
  local height = hasNext and 420 or 740
  self.uiBinder.scrollview_item_trans:SetHeight(height)
  self.contentLab_.text = current == 0 and Lang("Activation") or Lang("levelUp")
  if not hasNext then
    return
  end
  local tempHole = self.seasonCultivateVM_.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, current + 1)
  self:addNodeCondition(tempHole.NodeCondition)
  self:addCondition(tempHole.Condition)
end

function SeasonCultivateCore:addNodeCondition(condition)
  for i, v in pairs(condition) do
    local name = _formatStr("node_condition_{0}", i)
    local unit = self:AsyncLoadUiUnit(ConditionUnitPath, name, self.uiBinder.trans_condition.transform, self.cancelSource:CreateToken())
    if unit then
      self.conditionUnit_[name] = unit
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
      else
        function self.errFunc_()
          Z.TipsVM.ShowTips(124013, {val = need})
        end
        
        self.canUpgradeState_ = 1
      end
      unit.lab_condition.text = text
      unit.lab_condition_schedule.text = numText
    end
  end
end

function SeasonCultivateCore:addCondition(condition)
  local results = self.seasonCultivateVM_.GetConditionDesc(condition)
  for i, result in pairs(results) do
    local name = _formatStr("condition_{0}", i)
    local unit = self:AsyncLoadUiUnit(ConditionUnitPath, name, self.uiBinder.trans_condition.transform, self.cancelSource:CreateToken())
    if unit then
      self.conditionUnit_[name] = unit
      local text = result.Desc
      local numText = result.Progress
      if result.IsUnlock then
        text = Z.RichTextHelper.ApplyStyleTag(text, E.TextStyleTag.GreenTextColor2)
        numText = Z.RichTextHelper.ApplyStyleTag(numText, E.TextStyleTag.GreenTextColor2)
      else
        function self.errFunc_()
          Z.ConditionHelper.CheckCondition(condition, true)
        end
        
        self.canUpgradeState_ = 1
      end
      unit.lab_condition.text = text
      unit.lab_condition_schedule.text = numText
    end
  end
end

function SeasonCultivateCore:resetItem()
  self.uiBinder.btn_levelup.IsDisabled = true
  for name, _ in pairs(self.itemUnit_) do
    self:RemoveUiUnit(name)
  end
  self.itemUnit_ = {}
  local max = self.seasonCultivateVM_.GetHoleMaxLevel(E.SeasonCultivateHole.Core)
  local current = self.seasonCultivateVM_.GetCoreNodeLevel() + 1
  local hasNext = max > current
  if not hasNext then
    return
  end
  local tempHole = self.seasonCultivateVM_.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, current + 1)
  local moneyId = tempHole.NumberConsume[1][1]
  local needMoney = tempHole.NumberConsume[1][2]
  local hasMoney = self.itemVM_.GetItemTotalCount(moneyId)
  local needMoneyText = tostring(needMoney)
  if needMoney > hasMoney then
    self.canUpgradeState_ = moneyId
    needMoneyText = Z.RichTextHelper.ApplyStyleTag(needMoneyText, E.TextStyleTag.TipsRed)
  end
  local moneyItem = Z.TableMgr.GetTable("ItemTableMgr").GetRow(moneyId)
  if moneyItem then
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_gold:SetImage(itemsVM.GetItemIcon(moneyId))
  end
  self.uiBinder.lab_digit.text = needMoneyText
  local ItemUnitPath
  if Z.IsPCUI then
    ItemUnitPath = GetLoadAssetPath("BackPack_Item_Unit_Addr2_8_New_PC")
  else
    ItemUnitPath = GetLoadAssetPath("BackPack_Item_Unit_Addr2_8_New")
  end
  for i, v in pairs(tempHole.NumberConsume) do
    if i ~= 1 then
      local itemId = v[1]
      local needCount = v[2]
      local name = "item_" .. itemId
      local unit = self:AsyncLoadUiUnit(ItemUnitPath, name, self.uiBinder.node_item_parent.transform, self.cancelSource:CreateToken())
      if unit then
        self.itemUnit_[name] = unit
        local count = self.itemVM_.GetItemTotalCount(itemId)
        local datas = {
          uiBinder = unit,
          configId = itemId,
          isShowZero = true,
          lab = count,
          HideTag = false,
          isSquareItem = true,
          isShowOne = true
        }
        local instance = self.itemClass_[itemId]
        if not instance then
          instance = ItemClass.new(self)
          self.itemClass_[itemId] = instance
        end
        instance:Init(datas)
        instance:SetExpendCount(count, needCount)
        if needCount > count and (self.canUpgradeState_ == nil or 1 >= self.canUpgradeState_) then
          self.canUpgradeState_ = itemId
        end
      end
    end
  end
  self.uiBinder.btn_levelup.IsDisabled = self.canUpgradeState_ > 0
end

return SeasonCultivateCore
