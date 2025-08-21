local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chemistry_refine_subView = class("Chemistry_refine_subView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui/component/loop_grid_view")
local lifeProfessionInfoGridItem = require("ui.component.life_profession.life_profession_info_grid_item")
local LifeProfessionScreeningRightSubView = require("ui.view.life_profession_screening_right_sub_view")
local scheduleSub = require("ui.view.node_schedule_sub_view")
local item = require("common.item_binder")
local menufactureProductionItem = require("ui.component.life_profession.menufacture_production_item")
local lifeManufacturePreviewItem = require("ui.component.life_profession.life_manufacture_preview_item")

function Chemistry_refine_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "chemistry_refine_sub", "chemistry/chemistry_refine_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "chemistry_refine_sub", "chemistry/chemistry_refine_sub", UI.ECacheLv.None)
  end
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.chemistryVm_ = Z.VMMgr.GetVM("chemistry")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.scheduleSubView_ = scheduleSub.new(self)
  self.chemistryData_ = Z.DataMgr.Get("chemistry_data")
  self.itemClass_ = item.new(self)
  self.lifeMenufactorData_ = Z.DataMgr.Get("life_menufacture_data")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
end

function Chemistry_refine_subView:OnActive()
  self.lifeMenufactorData_:ResetSelectProductions(false)
  self.screeningRightSubView_ = LifeProfessionScreeningRightSubView.new(self)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:setRefineState(false)
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = ""
  self.isRefining_ = false
  self.isRefreshSelected_ = true
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast)
  self.uiBinder.effect_cast:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast_pre)
  self.uiBinder.effect_cast_pre:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast_end)
  self.uiBinder.effect_cast_end:Stop()
  self:AddAsyncClick(self.uiBinder.node_right.btn_confirm_cook, function()
    local lifeProductionListConfig = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.selectProductId_)
    local oneCost = 0
    if lifeProductionListConfig.Cost and lifeProductionListConfig.Cost[2] then
      oneCost = lifeProductionListConfig.Cost[2]
    end
    local costCount = oneCost * self.refineCount_
    if costCount > self.itemVm_.GetItemTotalCount(Z.SystemItem.VigourItemId) then
      Z.TipsVM.ShowTipsLang(1001903)
      return
    end
    if self.refineCount_ > self.maxRefineCount then
      Z.TipsVM.ShowTipsLang(100002)
      return
    end
    if 0 >= self.refineCount_ then
      return
    end
    local refineCount = self.refineCount_
    local func = function(isFinish)
      Z.CoroUtil.create_coro_xpcall(function()
        self.lifeProfessionVM_.AsyncRequestLifeProfessionAlchemy(self.selectProductId_, 1, self.cancelSource:CreateToken())
        if isFinish then
          self:OnSelectItem(self.curProductData_)
          self.uiBinder.effect_cast:SetEffectGoVisible(true)
          self.uiBinder.effect_cast:Play()
          local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
          coro(0.1, self.cancelSource:CreateToken())
          self.uiBinder.effect_cast_pre:SetEffectGoVisible(false)
          self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
          coro(2.5, self.cancelSource:CreateToken())
          self.uiBinder.effect_cast:SetEffectGoVisible(false)
          self.uiBinder.effect_cast_end:SetEffectGoVisible(true)
          self.uiBinder.effect_cast_end:Play()
        else
          local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
          self.uiBinder.effect_cast:SetEffectGoVisible(true)
          self.uiBinder.effect_cast:Play()
          coro(0.1, self.cancelSource:CreateToken())
          self.uiBinder.effect_cast_pre:SetEffectGoVisible(false)
          self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
          coro(2.5, self.cancelSource:CreateToken())
          self.uiBinder.effect_cast:SetEffectGoVisible(false)
          self.uiBinder.effect_cast_pre:SetEffectGoVisible(true)
          self.uiBinder.effect_cast_pre:Play()
          self.refineCount_ = self.refineCount_ - 1
          self:refreshMidUI()
        end
      end)()
    end
    local everyTimeFinishFunc = function()
      func(false)
    end
    local finishFunc = function()
      func(true)
      self:setRefineState(false)
    end
    local stopFunc = function()
      self:setRefineState(false)
    end
    self.scheduleSubView_:Active({
      num = self.refineCount_,
      des = Lang("ChemistryRefineing"),
      everyTimeFinishFunc = everyTimeFinishFunc,
      finishFunc = finishFunc,
      stopFunc = stopFunc,
      stopLabContent = Lang("StopRefining"),
      time = self.lifeProfessionVM_.GetLifeManufactureCost(E.ELifeProfession.Chemistry)
    }, self.uiBinder.node_right.node_schedule.transform)
    self:setRefineState(true)
  end)
  self:AddClick(self.uiBinder.node_right.btn_add, function()
    self:add()
  end)
  self:AddClick(self.uiBinder.node_right.btn_reduce, function()
    self:reduce()
  end)
  self.uiBinder.node_right.slider_temp:AddListener(function(value)
    self.refineCount_ = math.floor(value + 0.1)
    self:refreshCostUI()
  end)
  self:AddClick(self.uiBinder.node_right.btn_max, function()
    if self.maxRefineCount == 0 then
      return
    end
    self.refineCount_ = self.maxRefineCount
    self:refreshCostUI()
  end)
  self:AddClick(self.uiBinder.btn_switch, function()
    self.lifeProfessionVM_.OpenSwicthFormulaPopUp(self.curProductData_, self.uiBinder.node_formula_tips)
  end)
  self.uiBinder.tog_screening:RemoveAllListeners()
  
  function self.screenCloseFunc()
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening.isOn = false
    self:refineRefresh()
  end
  
  self.uiBinder.tog_screening:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right.Trans, false)
      self.screeningRightSubView_:Active({
        proID = E.ELifeProfession.Chemistry,
        closeFunc = self.screenCloseFunc
      }, self.uiBinder.node_right_sub, self)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right.Trans, true)
      self.screeningRightSubView_:DeActive()
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      self:refineRefresh()
      local hasFilter = self.lifeProfessionData_:HasFilterChanged(E.ELifeProfession.Chemistry)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
    end
  end)
  self:AddClick(self.uiBinder.btn_search, function()
    self:SetUIVisible(self.uiBinder.img_input_bg, true)
    self:SetUIVisible(self.uiBinder.btn_search, false)
  end)
  self:AddClick(self.uiBinder.btn_close_search, function()
    self:SetUIVisible(self.uiBinder.img_input_bg, false)
    self:SetUIVisible(self.uiBinder.btn_search, true)
    self.uiBinder.input_search.text = ""
  end)
  self.uiBinder.input_search:AddListener(function(text)
    self.lifeProfessionData_:SetFilterName(E.ELifeProfession.Chemistry, text)
    self:refineRefresh()
  end, true)
  if Z.IsPCUI then
    self.refineGridLoops_ = loopGridView.new(self, self.uiBinder.loop_recipe_item, lifeProfessionInfoGridItem, "com_item_square_1_8")
    self.previewList = loopListView.new(self, self.uiBinder.node_right.loop_list_item, lifeManufacturePreviewItem, "cook_main_probability_item_tpl_pc")
  else
    self.refineGridLoops_ = loopGridView.new(self, self.uiBinder.loop_recipe_item, lifeProfessionInfoGridItem, "com_item_square_1")
    self.previewList = loopListView.new(self, self.uiBinder.node_right.loop_list_item, lifeManufacturePreviewItem, "cook_main_probability_item_tpl")
  end
  self.formulaOneView = loopListView.new(self, self.uiBinder.loop_list_one_formula, menufactureProductionItem, "com_item_square_1_8")
  self.formulaMultiView = loopListView.new(self, self.uiBinder.loop_list_multi_formula, menufactureProductionItem, "com_item_square_1_8")
  self.formulaOneView:Init({})
  self.formulaMultiView:Init({})
  self.refineGridLoops_:Init({})
  self.previewList:Init({})
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionBuildRefresh, self.refineRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSubFormulaChanged, self.lifeProfessionSubFormulaChanged, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.ItemCountChange, self)
  Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, Z.SystemItem.VigourItemId, self.refineRefresh, self)
end

function Chemistry_refine_subView:lifeProfessionSubFormulaChanged()
  self:refreshCostUI()
  if self.refineGridLoops_ then
    local curIndex = self.refineGridLoops_:GetSelectedIndex()
    self.refineGridLoops_:RefreshItemByItemIndex(curIndex)
  end
end

function Chemistry_refine_subView:ItemCountChange()
  self:OnSelectItem(self.curProductData_)
end

function Chemistry_refine_subView:OnDeActive()
  self.scheduleSubView_:DeActive()
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionBuildRefresh, self.refineRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.ItemCountChange, self)
  Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemAddEventType.ItemId, Z.SystemItem.VigourItemId, self.refineRefresh, self)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.refineGridLoops_:UnInit()
  self.itemClass_:UnInit()
  if self.formulaOneView then
    self.formulaOneView:UnInit()
  end
  if self.formulaMultiView then
    self.formulaMultiView:UnInit()
  end
  if self.screeningRightSubView_ then
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    self.screeningRightSubView_ = nil
  end
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = ""
  if self.previewList then
    self.previewList:UnInit()
    self.previewList = nil
  end
  self.lifeProfessionVM_.CloseSwicthFormulaPopUp()
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast_end)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast_pre)
end

function Chemistry_refine_subView:setRefineState(isRefine)
  self.isRefining_ = isRefine
  if self.isRefining_ then
    self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
    self.uiBinder.effect_cast:SetEffectGoVisible(false)
    self.uiBinder.effect_cast_pre:SetEffectGoVisible(true)
    self.uiBinder.effect_cast_pre:Play()
  else
    self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
    self.uiBinder.effect_cast:SetEffectGoVisible(false)
    self.uiBinder.effect_cast_pre:SetEffectGoVisible(false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_click_mask, isRefine)
  self.uiBinder.node_right.Ref:SetVisible(self.uiBinder.node_right.node_schedule, isRefine)
  self.uiBinder.node_right.Ref:SetVisible(self.uiBinder.node_right.img_money, not isRefine)
  self.uiBinder.node_right.node_num_module.Ref.UIComp:SetVisible(not isRefine)
  self.uiBinder.node_right.Ref:SetVisible(self.uiBinder.node_right.btn_confirm_cook, not isRefine)
end

function Chemistry_refine_subView:OnRefresh()
  self:refineRefresh()
end

function Chemistry_refine_subView:RefreshInfo()
  self:refineRefresh()
end

function Chemistry_refine_subView:getGridLoopItems()
  local datas = {}
  local dataIndex = 0
  local productionList = self.lifeProfessionVM_.GetLifeProfessionProductnfo(E.ELifeProfession.Chemistry)
  for k, v in pairs(productionList) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    if self.lifeProfessionVM_.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id) then
      if self.viewData.isHouseCast and lifeProductionListTableRow.Type == E.ManufactureProductType.House then
        dataIndex = dataIndex + 1
        datas[dataIndex] = v
      end
      if not self.viewData.isHouseCast and lifeProductionListTableRow.Type ~= E.ManufactureProductType.House then
        dataIndex = dataIndex + 1
        datas[dataIndex] = v
      end
    end
  end
  return datas
end

function Chemistry_refine_subView:refineRefresh()
  local datas = self:getGridLoopItems()
  self.refineGridLoops_:RefreshListView(datas)
  if 0 < #datas then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
    if not self.isRefining_ and self.isRefreshSelected_ then
      self.isRefreshSelected_ = false
      self.refineGridLoops_:SetSelected(1)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, true)
    self.selectProductId_ = nil
    self.refineCount_ = 1
    self:refreshRightInfo()
  end
end

function Chemistry_refine_subView:OnSelectItem(data)
  self.curProductData_ = data
  self.selectProductId_ = self.lifeMenufactorData_:GetCurSelectProductID(data.productId)
  self.curData = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.selectProductId_)
  self.maxRefineCount = self:calMaxRefineCount()
  local canExchange = self.maxRefineCount > 0
  self.uiBinder.node_right.slider_temp.minValue = canExchange and 1 or 0
  self.uiBinder.node_right.slider_temp.maxValue = canExchange and self.maxRefineCount or 1
  self.uiBinder.node_right.slider_temp.interactable = canExchange
  self.refineCount_ = 1
  self:refreshRightInfo()
end

function Chemistry_refine_subView:refreshMidUI()
  self:refreshMiddleItem()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_multi_formula, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_one_formula, false)
  local datas = self.lifeProfessionVM_.GetProductionMaterials(self.curData)
  if table.zcount(self.curProductData_.subProductList) > 0 then
    self.uiBinder.lab_formula.text = Lang("LifeManufactureFormuaIndex" .. self.curProductData_.curSelectProductIndex)
    self.uiBinder.lab_formula_lock.text = Lang("LifeManufactureFormuaIndex" .. self.curProductData_.curSelectProductIndex)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_formula_lock, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_multi_formula, true)
    self.formulaMultiView:RefreshListView(datas)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_one_formula, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_formula_lock, false)
    self.formulaOneView:RefreshListView(datas)
  end
  local isCurUnlocked = self.lifeProfessionVM_.IsProductUnlocked(self.curData.LifeProId, self.curData.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, not isCurUnlocked)
end

function Chemistry_refine_subView:refreshMiddleItem()
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_production
  })
  local itemData = {}
  itemData.configId = self.curData.RelatedItemId
  itemData.uiBinder = self.uiBinder.item_production
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
  local isProductionUnlocked = self.lifeProfessionVM_.IsProductUnlocked(self.curData.LifeProId, self.curData.Id)
  self.itemClass_:SetImgLockState(not isProductionUnlocked)
  local isProductionHasCost = self.lifeProfessionVM_.IsProductHasCost(self.curData.LifeProId, self.curData.Id)
  self.itemClass_:SetImgTradeState(isProductionHasCost)
  self.uiBinder.lab_production.text = self.curData.Name
end

function Chemistry_refine_subView:refreshRightInfo()
  self.maxRefineCount = self:calMaxRefineCount()
  local canExchange = self.maxRefineCount > 0
  self.uiBinder.node_right.slider_temp.minValue = canExchange and 1 or 0
  self.uiBinder.node_right.slider_temp.maxValue = canExchange and self.maxRefineCount or 1
  self.uiBinder.node_right.slider_temp.interactable = canExchange
  self.refineCount_ = math.min(self.refineCount_, self.maxRefineCount)
  self.refineCount_ = math.max(self.refineCount_, 1)
  if self.selectProductId_ == nil then
    self.uiBinder.node_right.Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_middle, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_middle, true)
    self.uiBinder.node_right.Ref.UIComp:SetVisible(true)
    local lifeProductionListConfig = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.selectProductId_)
    if lifeProductionListConfig == nil then
      return
    end
    self.uiBinder.node_right.lab_name.text = lifeProductionListConfig.Name
    self.uiBinder.node_right.rimg_icon:SetImage(lifeProductionListConfig.Icon)
    self.uiBinder.node_right.img_bg_quality:SetColor(Z.ConstValue.QualityBgColor[lifeProductionListConfig.Quality])
    local costItemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(lifeProductionListConfig.Cost[1])
    if costItemConfig then
      self.uiBinder.node_right.rimg_money_icon:SetImage(costItemConfig.Icon)
    end
    if lifeProductionListConfig.RelatedItemId then
      local cookCuisineRandomTableRow = Z.TableMgr.GetTable("CookCuisineRandomTableMgr").GetRow(lifeProductionListConfig.RelatedItemId, true)
      if cookCuisineRandomTableRow == nil then
        self.uiBinder.node_right.buff_item.Ref.UIComp:SetVisible(false)
      else
        self.uiBinder.node_right.buff_item.Ref.UIComp:SetVisible(true)
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.node_right.buff_item.lab_info, self.chemistryVm_.GetBuffDesById(lifeProductionListConfig.RelatedItemId))
      end
    else
      self.uiBinder.node_right.buff_item.Ref.UIComp:SetVisible(false)
    end
    self.uiBinder.node_right.lab_info.text = lifeProductionListConfig.Des
    self:refreshCostUI()
    local allRewards = {}
    local fixedAwardPackage = lifeProductionListConfig.Award
    for k, v in pairs(fixedAwardPackage) do
      table.insert(allRewards, v)
    end
    local specialRewardID
    for k, v in pairs(lifeProductionListConfig.SpecialAward) do
      if self.lifeProfessionVM_.IsSpecializationUnlocked(E.ELifeProfession.Chemistry, v[2]) then
        specialRewardID = v[1]
      end
    end
    if specialRewardID then
      table.insert(allRewards, specialRewardID)
    end
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local previewDataList = awardPreviewVm.GetAllAwardPreListByIds(allRewards)
    self.previewList:RefreshListView(previewDataList)
  end
end

function Chemistry_refine_subView:calMaxRefineCount()
  if self.selectProductId_ == nil then
    return 0
  end
  local lifeProductionListConfig = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.selectProductId_)
  if lifeProductionListConfig == nil then
    return 0
  end
  local maxCount = math.floor(self.itemVm_.GetItemTotalCount(lifeProductionListConfig.Cost[1]) / lifeProductionListConfig.Cost[2])
  local materialMgr = Z.TableMgr.GetTable("ChemistryMaterialTableMgr")
  for _, material in ipairs(lifeProductionListConfig.NeedMaterial) do
    local materialConfig = materialMgr.GetRow(material[1])
    local canUse = true
    if materialConfig and materialConfig.UseCondition and next(materialConfig.UseCondition) then
      canUse, _, _ = Z.ConditionHelper.GetSingleConditionDesc(materialConfig.UseCondition[1], materialConfig.UseCondition[2], materialConfig.UseCondition[3])
    end
    if canUse then
      local tempCount = math.floor(self.itemVm_.GetItemTotalCount(material[1]) / material[2])
      maxCount = math.min(tempCount, maxCount)
    else
      maxCount = 0
      break
    end
  end
  return math.min(maxCount, Z.Global.LifeCastMaxCnt)
end

function Chemistry_refine_subView:add()
  if self.maxRefineCount == 0 then
    return
  end
  self.refineCount_ = math.min(self.maxRefineCount, self.refineCount_ + 1)
  self:refreshCostUI()
end

function Chemistry_refine_subView:reduce()
  self.refineCount_ = math.max(self.refineCount_ - 1, 1)
  self:refreshCostUI()
end

function Chemistry_refine_subView:refreshCostUI()
  if self.selectProductId_ == nil then
    return
  end
  local lifeProductionListConfig = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(self.selectProductId_)
  local oneCost = 0
  if lifeProductionListConfig.Cost and lifeProductionListConfig.Cost[2] then
    oneCost = lifeProductionListConfig.Cost[2]
  end
  local costCount = oneCost * self.refineCount_
  if costCount <= self.itemVm_.GetItemTotalCount(lifeProductionListConfig.Cost[1]) then
    self.uiBinder.node_right.lab_money_num.text = Z.RichTextHelper.ApplyStyleTag(costCount, E.TextStyleTag.White)
  else
    self.uiBinder.node_right.lab_money_num.text = Z.RichTextHelper.ApplyStyleTag(costCount, E.TextStyleTag.TipsRed)
  end
  if self.refineCount_ <= self.maxRefineCount then
    self.uiBinder.node_right.lab_num.text = Z.RichTextHelper.ApplyStyleTag(self.refineCount_, E.TextStyleTag.White)
  else
    self.uiBinder.node_right.lab_num.text = Z.RichTextHelper.ApplyStyleTag(self.refineCount_, E.TextStyleTag.TipsRed)
  end
  self:refreshMidUI()
  self.uiBinder.node_right.btn_confirm_cook.IsDisabled = self.maxRefineCount == 0
  self.uiBinder.node_right.slider_temp.value = self.refineCount_
end

return Chemistry_refine_subView
