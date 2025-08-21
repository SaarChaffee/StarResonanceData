local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_life_profession_item_right_subView = class("Map_life_profession_item_right_subView", super)
local loopListView = require("ui.component.loop_list_view")
local map_collection_product_item = require("ui.component.map.map_collection_product_item")
local currency_item_list = require("ui.component.currency.currency_item_list")
local qualityPath = "ui/atlas/permanent/com_lab_quality_"

function Map_life_profession_item_right_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_life_profession_item_right_sub", "map/map_life_profession_item_right_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Map_life_profession_item_right_subView:OnActive()
  self:InitData()
  self:InitComp()
  local config = Z.TableMgr.GetRow("LifeCollectListTableMgr", self.curCollectionId_)
  if config == nil then
    return
  end
  if config.Award > 0 and 0 < config.FreeAward then
    self.uiBinder.tog_exquisite.isOn = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.toggle_group, 0 < config.FreeAward and config.Award > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_exquisite, config.FreeAward == 0 and config.Award > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_rough, 0 < config.FreeAward and config.Award == 0)
  self.IsFree = config.Award == 0
end

function Map_life_profession_item_right_subView:OnDeActive()
  self:UnInitLoopListView()
  self:clearUnlockItem()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
end

function Map_life_profession_item_right_subView:OnRefresh()
  self:RefreshInfo()
end

function Map_life_profession_item_right_subView:InitData()
  self.flagData_ = self.viewData.flagData
  self.curCollectionId_ = self.mapData_:GetTargetCollectionId()
end

function Map_life_profession_item_right_subView:InitComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_close, function()
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.uiBinder.btn_operate, function()
    self:OnClickOperate()
  end)
  self:AddClick(self.uiBinder.btn_pathfinding, function()
    self:OnClickPathFinding()
  end)
  self.uiBinder.tog_exquisite:AddListener(function(isOn)
    if isOn then
      self.IsFree = not isOn
      self:RefreshInfo()
    end
  end, true)
  self.uiBinder.tog_rough:AddListener(function(isOn)
    if isOn then
      self.IsFree = isOn
      self:RefreshInfo()
    end
  end, true)
  self:InitLoopListView()
end

function Map_life_profession_item_right_subView:InitLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, map_collection_product_item, "com_item_square_8")
  self.loopListView_:Init({})
end

function Map_life_profession_item_right_subView:UnInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Map_life_profession_item_right_subView:RefreshInfo()
  local config = Z.TableMgr.GetRow("LifeCollectListTableMgr", self.curCollectionId_)
  if config == nil then
    return
  end
  local professionConfig = Z.TableMgr.GetRow("LifeProfessionTableMgr", config.LifeProId)
  if professionConfig == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(config.Icon)
  self.uiBinder.img_name_bg:SetImage(qualityPath .. config.Quality)
  self.uiBinder.lab_item_name.text = config.Name
  self.uiBinder.lab_info.text = config.Des
  self.uiBinder.lab_learning_level.text = Lang("CollectionProfessLv", {
    name = professionConfig.Name,
    level = self.IsFree and config.NeedLevel[2] or config.NeedLevel[1]
  })
  self:RefreshProductInfo(config)
  self:RefreshUnlockInfo(config)
  self:RefreshCostInfo(config)
  self:RefreshCurrencyInfo(config)
  local curSceneId = self.parent_:GetCurSceneId()
  local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(curSceneId, self.flagData_)
  self.uiBinder.lab_operate.text = isTracking and Lang("cancleTrace") or Lang("trace")
  local isShow = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.PathFinding, true)
  self:SetUIVisible(self.uiBinder.btn_pathfinding, isShow)
end

function Map_life_profession_item_right_subView:insertFreeAwards(config, datas)
  if config.FreeAward == 0 then
    return
  end
  local freeAwards = self.awardPreviewVM_.GetAllAwardPreListByIds(config.FreeAward)
  for k, v in pairs(freeAwards) do
    local rewardData = {}
    rewardData.data = v
    rewardData.isUnlocked = true
    rewardData.isFree = true
    table.insert(datas, rewardData)
  end
end

function Map_life_profession_item_right_subView:RefreshProductInfo(config)
  local resultProductItem = {}
  if self.IsFree then
    self:insertFreeAwards(config, resultProductItem)
  else
    local fixedAwards = self.awardPreviewVM_.GetAllAwardPreListByIds(config.Award)
    for k, v in pairs(fixedAwards) do
      local rewardData = {}
      rewardData.data = v
      rewardData.isUnlocked = true
      table.insert(resultProductItem, rewardData)
    end
    local hasSpecialUnlocked = false
    local specialAwards, firstSpecialAwards
    for k, v in pairs(config.SpecialAward) do
      if k == 1 then
        firstSpecialAwards = self.awardPreviewVM_.GetAllAwardPreListByIds(v[1])
      end
      local isSpecialAwardUnlocked = self.lifeProfessionVM_.IsSpecializationUnlocked(config.LifeProId, v[2])
      if isSpecialAwardUnlocked then
        hasSpecialUnlocked = true
        specialAwards = self.awardPreviewVM_.GetAllAwardPreListByIds(v[1])
      end
    end
    specialAwards = hasSpecialUnlocked and specialAwards or firstSpecialAwards
    if specialAwards then
      for k, award in pairs(specialAwards) do
        local rewardData = {}
        rewardData.data = award
        rewardData.isUnlocked = hasSpecialUnlocked
        rewardData.isExtra = true
        table.insert(resultProductItem, rewardData)
      end
    end
    for k, v in pairs(config.ExtraAward) do
      local specialAwards = self.awardPreviewVM_.GetAllAwardPreListByIds(v[1])
      local isSpecialAwardUnlocked = self.lifeProfessionVM_.IsSpecializationUnlocked(config.LifeProId, v[2])
      for k, award in pairs(specialAwards) do
        local rewardData = {}
        rewardData.data = award
        rewardData.isUnlocked = isSpecialAwardUnlocked
        rewardData.isExtra = true
        table.insert(resultProductItem, rewardData)
      end
    end
    self:insertFreeAwards(config, resultProductItem)
  end
  self.loopListView_:RefreshListView(resultProductItem, true)
end

function Map_life_profession_item_right_subView:RefreshUnlockInfo(config)
  local unlockConditions = config.Award > 0 and config.UnlockCondition or config.UnlockConditionZeroCost
  local isUnlock = Z.ConditionHelper.CheckCondition(unlockConditions, false)
  if isUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_cost, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_cost, false)
    local unlockDescList = Z.ConditionHelper.GetConditionDescList(unlockConditions)
    Z.CoroUtil.create_coro_xpcall(function()
      self:clearUnlockItem()
      self:createUnlockItem(unlockDescList)
    end)()
  end
end

function Map_life_profession_item_right_subView:createUnlockItem(descList)
  local unitPath = self.uiBinder.comp_ui_cache:GetString("unlock_item")
  for index, info in ipairs(descList) do
    local unitParent = self.uiBinder.node_content
    local unitName = string.zconcat("item_unlock_", index)
    local unitToken = self.cancelSource:CreateToken()
    self.unlockUnitTokenDict_[unitName] = unitToken
    local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
    self.unlockUnitDict_[unitName] = unitItem
    unitItem.lab_unlock_conditions.text = info.Desc
    unitItem.Ref:SetVisible(unitItem.img_on, info.IsUnlock)
    unitItem.Ref:SetVisible(unitItem.img_off, not info.IsUnlock)
  end
end

function Map_life_profession_item_right_subView:clearUnlockItem()
  if self.unlockUnitTokenDict_ then
    for unitName, unitToken in pairs(self.unlockUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.unlockUnitTokenDict_ = {}
  if self.unlockUnitDict_ then
    for unitName, unitItem in pairs(self.unlockUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.unlockUnitDict_ = {}
end

function Map_life_profession_item_right_subView:RefreshCostInfo(config)
  local costItemId = config.Cost[1]
  local costNum = config.Cost[2]
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", costItemId)
  if itemTableRow == nil then
    return
  end
  self.uiBinder.rimg_gold:SetImage(itemTableRow.Icon)
  self.uiBinder.lab_consumption.text = Lang("CostNum", {num = costNum})
  if self.IsFree then
    self.uiBinder.lab_consumption.text = Lang("CostNum", {num = 0})
  end
end

function Map_life_profession_item_right_subView:RefreshCurrencyInfo(config)
  if #config.Cost == 0 then
    return
  end
  if not self.currencyItemList_ then
    self.currencyItemList_ = currency_item_list.new()
  end
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    config.Cost[1]
  })
end

function Map_life_profession_item_right_subView:OnClickOperate()
  local curSceneId = self.parent_:GetCurSceneId()
  local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(curSceneId, self.flagData_)
  if isTracking then
    self.mapVM_.ClearFlagDataTrackSource(curSceneId, self.flagData_)
  else
    self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, curSceneId, self.flagData_)
  end
  self.parent_:CloseRightSubView()
end

function Map_life_profession_item_right_subView:OnClickPathFinding()
  local curSceneId = self.parent_:GetCurSceneId()
  self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, curSceneId, self.flagData_)
  local pathFindingVM = Z.VMMgr.GetVM("path_finding")
  pathFindingVM:StartPathFindingByFlagData(curSceneId, self.flagData_)
  self.parent_:CloseRightSubView()
end

return Map_life_profession_item_right_subView
