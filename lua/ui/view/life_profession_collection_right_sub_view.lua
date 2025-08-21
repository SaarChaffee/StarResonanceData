local UI = Z.UI
local super = require("ui.ui_subview_base")
local Life_profession_collection_right_subView = class("Life_profession_collection_right_subView", super)
local collectProductionItem = require("ui.component.life_profession.collect_production_item")
local loopListView = require("ui.component.loop_list_view")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Life_profession_collection_right_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "life_profession_collection_right_sub", "life_profession/life_profession_collection_right_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "life_profession_collection_right_sub", "life_profession/life_profession_collection_right_sub", UI.ECacheLv.None)
  end
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.awardVm_ = Z.VMMgr.GetVM("awardpreview")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Life_profession_collection_right_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:InitBinders()
  self:initBtnFunc()
  self:initLoopView()
  self:bindEvents()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId,
    self.lifeProfessionVM.GetSpcItemIDByProId()
  })
  self.data_ = self.viewData.data
  self.isConsume = self.viewData.isConsume
  self.IsFree = not self.isConsume
end

function Life_profession_collection_right_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, self.lifeProfessionSpecChanged, self)
end

function Life_profession_collection_right_subView:lifeProfessionLevelChanged(proID)
  if self.data_.LifeProId == proID then
    self:OnRefresh()
  end
end

function Life_profession_collection_right_subView:lifeProfessionSpecChanged(proID)
  if self.data_.LifeProId == proID then
    self:OnRefresh()
  end
end

function Life_profession_collection_right_subView:OnDeActive()
  self.loopProductView_:UnInit()
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function Life_profession_collection_right_subView:OnRefresh()
  if self.data_.Award > 0 and 0 < self.data_.FreeAward then
    self.toggleCost.isOn = true
  end
  self.rimgIcon_:SetImage(self.data_.Icon)
  self.nameLab_.text = self.data_.Name
  self.uiBinder.Ref:SetVisible(self.toggleGroup, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_exquisite, self.isConsume)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_rough, not self.isConsume)
  self:refreshInfo()
end

function Life_profession_collection_right_subView:refreshInfo()
  local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", self.data_.LifeProId)
  if config == nil then
    return
  end
  self.levelLab_.text = Lang("NeedProfessionLevel", {
    professionName = config.Name,
    needLevel = self.IsFree and self.data_.NeedLevel[2] or self.data_.NeedLevel[1]
  })
  self.descLab_.text = self.data_.Des
  if self.data_.ProduceArea ~= "" then
    self.sceneNameLab_.text = Lang("CollectionProductionSceneName", {
      val = self.data_.ProduceArea
    })
  end
  self.uiBinder.Ref:SetVisible(self.sceneNameLab_, self.data_.ProduceArea ~= "")
  self:refreshAwards()
  local isProductionUnlocked = self.lifeProfessionVM.IsProductUnlocked(self.data_.LifeProId, self.data_.Id, self.isConsume)
  self.uiBinder.Ref:SetVisible(self.nodeUnlocked_, isProductionUnlocked)
  self.uiBinder.Ref:SetVisible(self.nodeLocked_, not isProductionUnlocked)
  if not isProductionUnlocked then
    self:refreshConditions()
  else
    self:refreshCost()
  end
end

function Life_profession_collection_right_subView:refreshConditions()
  if self.conditionDict ~= nil then
    for _, v in pairs(self.conditionDict) do
      self:RemoveUiUnit(v)
    end
  end
  local unlockConditions = self.IsFree and self.data_.UnlockConditionZeroCost or self.data_.UnlockCondition
  local conditionDatas = Z.ConditionHelper.GetConditionDescList(unlockConditions)
  self.conditionDict = {}
  for k, v in pairs(conditionDatas) do
    self.conditionDict[k] = "cond_" .. k
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local path_ = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "condition_tpl")
    for k, v in pairs(conditionDatas) do
      local name_ = self.conditionDict[k]
      local condition = self:AsyncLoadUiUnit(path_, name_, self.uiBinder.node_conditions)
      condition.lab_unlock_conditions.text = v.showPurview
      condition.Ref:SetVisible(condition.img_off, not v.IsUnlock)
      condition.Ref:SetVisible(condition.img_on, v.IsUnlock)
    end
  end)()
end

function Life_profession_collection_right_subView:refreshCost()
  if #self.data_.Cost ~= 2 then
    self.uiBinder.Ref:SetVisible(self.nodeCost_, false)
    return
  end
  local costItem = self.data_.Cost[1]
  local costCnt = self.data_.Cost[2]
  local itemsVm = Z.VMMgr.GetVM("items")
  local haveCount = self.itemsVM_.GetItemTotalCount(costItem)
  local cntText = tostring(costCnt)
  if costCnt > haveCount then
    cntText = Z.RichTextHelper.ApplyStyleTag(math.ceil(costCnt), E.TextStyleTag.TipsRed)
  end
  self.labCost_.text = Lang("CollectionCost", {val = cntText})
  if self.IsFree then
    self.labCost_.text = Lang("CollectionCost", {val = 0})
  end
  self.rimgCost_:SetImage(itemsVm.GetItemIcon(costItem))
  self.uiBinder.layout_glod:ForceRebuildLayoutImmediate()
  self.uiBinder.layout_glod:MarkLayoutForRebuild()
end

function Life_profession_collection_right_subView:refreshAwards()
  local datas = {}
  if self.IsFree then
    self:insertFreeAwards(datas)
    self.loopProductView_:RefreshListView(datas)
  else
    local fixedAwards = self.awardVm_.GetAllAwardPreListByIds(self.data_.Award)
    for k, v in pairs(fixedAwards) do
      local rewardData = {}
      rewardData.data = v
      rewardData.isUnlocked = true
      table.insert(datas, rewardData)
    end
    local hasSpecialUnlocked = false
    local specialAwards, firstSpecialAwards
    for k, v in pairs(self.data_.SpecialAward) do
      if k == 1 then
        firstSpecialAwards = self.awardVm_.GetAllAwardPreListByIds(v[1])
      end
      local isSpecialAwardUnlocked = self.lifeProfessionVM.IsSpecializationUnlocked(self.data_.LifeProId, v[2])
      if isSpecialAwardUnlocked then
        hasSpecialUnlocked = true
        specialAwards = self.awardVm_.GetAllAwardPreListByIds(v[1])
      end
    end
    specialAwards = hasSpecialUnlocked and specialAwards or firstSpecialAwards
    if specialAwards then
      for k, award in pairs(specialAwards) do
        local rewardData = {}
        rewardData.data = award
        rewardData.isUnlocked = hasSpecialUnlocked
        rewardData.isExtra = true
        table.insert(datas, rewardData)
      end
    end
    for k, v in pairs(self.data_.ExtraAward) do
      local specialAwards = self.awardVm_.GetAllAwardPreListByIds(v[1])
      local isSpecialAwardUnlocked = self.lifeProfessionVM.IsSpecializationUnlocked(self.data_.LifeProId, v[2])
      for k, award in pairs(specialAwards) do
        local rewardData = {}
        rewardData.data = award
        rewardData.isUnlocked = isSpecialAwardUnlocked
        rewardData.isExtra = true
        table.insert(datas, rewardData)
      end
    end
    self:insertFreeAwards(datas)
  end
  self.loopProductView_:RefreshListView(datas)
end

function Life_profession_collection_right_subView:insertFreeAwards(datas)
  local freeAwards = self.awardVm_.GetAllAwardPreListByIds(self.data_.FreeAward)
  for k, v in pairs(freeAwards) do
    local rewardData = {}
    rewardData.data = v
    rewardData.isUnlocked = true
    rewardData.isFree = true
    table.insert(datas, rewardData)
  end
end

function Life_profession_collection_right_subView:InitBinders()
  self.rimgIcon_ = self.uiBinder.rimg_icon
  self.nameLab_ = self.uiBinder.lab_item_name
  self.levelLab_ = self.uiBinder.lab_learning_level
  self.descLab_ = self.uiBinder.lab_info
  self.sceneNameLab_ = self.uiBinder.lab_scene_name
  self.nodeProduct_ = self.uiBinder.node_product
  self.productLoopView_ = self.uiBinder.scrollview_item
  self.nodeLocked_ = self.uiBinder.node_unlock
  self.nodeUnlocked_ = self.uiBinder.node_tracking
  self.labCost_ = self.uiBinder.lab_consumption
  self.rimgCost_ = self.uiBinder.rimg_gold
  self.trackBtn_ = self.uiBinder.btn_square_new
  self.nodeCost_ = self.uiBinder.node_cost
  self.toggleCost = self.uiBinder.toggleCost
  self.toggleFree = self.uiBinder.toggerFree
  self.toggleGroup = self.uiBinder.toggle_group
end

function Life_profession_collection_right_subView:initBtnFunc()
  self:AddAsyncClick(self.trackBtn_, function()
    self.quickJumpVM_.DoJumpByConfigParam(self.data_.QuickJumpType, self.data_.QuickJump)
  end)
  self.toggleCost:AddListener(function(isOn)
    if isOn then
      self.IsFree = not isOn
      self:refreshInfo()
    end
  end, true)
  self.toggleFree:AddListener(function(isOn)
    if isOn then
      self.IsFree = isOn
      self:refreshInfo()
    end
  end, true)
end

function Life_profession_collection_right_subView:initLoopView()
  local data = {}
  if Z.IsPCUI then
    self.loopProductView_ = loopListView.new(self, self.productLoopView_, collectProductionItem, "com_item_square_3_8_pc")
  else
    self.loopProductView_ = loopListView.new(self, self.productLoopView_, collectProductionItem, "com_item_square_3_8")
  end
  self.loopProductView_:Init(data)
end

return Life_profession_collection_right_subView
