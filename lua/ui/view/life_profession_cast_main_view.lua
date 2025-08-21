local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_cast_mainView = class("Life_profession_cast_mainView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local item = require("common.item_binder")
local lifeProfessionInfoGridItem = require("ui.component.life_profession.life_profession_info_grid_item")
local menufactureProductionItem = require("ui.component.life_profession.menufacture_production_item")
local currency_item_list = require("ui.component.currency.currency_item_list")
local LifeProfessionScreeningRightSubView = require("ui.view.life_profession_screening_right_sub_view")
local DefaultCameraId = 4000

function Life_profession_cast_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_cast_main")
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.lifeMenufactorData_ = Z.DataMgr.Get("life_menufacture_data")
  self.itemClass_ = item.new(self)
end

function Life_profession_cast_mainView:OnActive()
  self.lifeMenufactorData_:ResetSelectProductions(false)
  self.screeningRightSubView_ = LifeProfessionScreeningRightSubView.new(self)
  Z.UIMgr:FadeIn({IsInstant = true, TimeOut = 0.3})
  self.proID = self.viewData.proID
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.isCasting = false
  self:SetALLBtnEnable(self.isCasting)
  self:initBinders()
  self:init()
  self:initBtnClick()
  self:refreshLeft()
  self:refreshTop()
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = ""
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId
  })
  if not self.viewData or not self.viewData.camID then
    self:openCamera(DefaultCameraId)
  else
    self:openCamera(self.viewData.slowCam and self.viewData.camID + 1 or self.viewData.camID + 3)
  end
  
  function self.onCountChange_()
    self:refreshMiddle()
    if not self.isCasting then
      self:refreshNotCasting()
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onCountChange_, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSubFormulaChanged, self.lifeProfessionSubFormulaChanged, self)
  self.lifeProfessionVM.SwitchEntityShow(false)
  self:refreshTitle()
  self.uiBinder.lab_ing.text = Lang("LifeManufactureIng_" .. self.proID)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast)
  self.uiBinder.effect_cast:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast_pre)
  self.uiBinder.effect_cast_pre:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cast_end)
  self.uiBinder.effect_cast_end:Stop()
end

function Life_profession_cast_mainView:lifeProfessionLevelChanged(proID)
  if self.proID == proID then
    self:refreshTop()
  end
end

function Life_profession_cast_mainView:lifeProfessionSubFormulaChanged()
  local curSelectProduct = self.lifeMenufactorData_:GetCurSelectProductID(self.curProductData_.productId)
  self.curData = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(curSelectProduct)
  if self.infoGridView then
    local curIndex = self.infoGridView:GetSelectedIndex()
    self.infoGridView:RefreshItemByItemIndex(curIndex)
  end
  self:refreshMiddle()
  self:refreshRight()
end

function Life_profession_cast_mainView:RefreshInfo()
  self:refreshLeft()
end

function Life_profession_cast_mainView:refreshTitle()
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.proID)
  if not lifeProfessionTableRow then
    return
  end
  local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(lifeProfessionTableRow.FunctionId)
  if funcRow == nil then
    return
  end
  self.uiBinder.img_icon_profession:SetImage(funcRow.Icon)
  self.uiBinder.lab_title_profession.text = lifeProfessionTableRow.Name
  self.uiBinder.img_on_tog1:SetImage(funcRow.Icon)
  self.uiBinder.img_off_tog1:SetImage(funcRow.Icon)
  self.uiBinder.lab_name_profession.text = Lang("MenufactureLevelTitle" .. self.proID)
  self.uiBinder.lab_content_start_btn.text = Lang("MenufactureStart" .. self.proID)
  self.uiBinder.lab_content_stop_btn.text = Lang("MenufactureEnd" .. self.proID)
end

function Life_profession_cast_mainView:openCamera(id)
  local idList = ZUtil.Pool.Collections.ZList_int.Rent()
  idList:Add(id)
  Z.CameraMgr:CameraInvokeByList(E.CameraState.Cooking, true, idList)
  ZUtil.Pool.Collections.ZList_int.Return(idList)
end

function Life_profession_cast_mainView:closeCamera()
  Z.CameraMgr:CameraInvoke(E.CameraState.Cooking, false)
end

function Life_profession_cast_mainView:initBinders()
  self.numbModuleBinder_ = self.uiBinder.node_num_module
  self.selectedNumLab_ = self.numbModuleBinder_.lab_num
  self.maxBtn_ = self.numbModuleBinder_.btn_max
  self.minusBtn_ = self.numbModuleBinder_.btn_reduce
  self.addBtn_ = self.numbModuleBinder_.btn_add
  self.slider_ = self.numbModuleBinder_.slider_temp
end

function Life_profession_cast_mainView:refreshLeft()
  local hasFilter = self.lifeProfessionData_:HasFilterChanged(self.proID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
  local productionList = self.lifeProfessionVM.GetLifeProfessionProductnfo(self.proID)
  local unlockedProductionList = {}
  for k, v in pairs(productionList) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    if self.lifeProfessionVM.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id) then
      if self.viewData.isHouseCast and lifeProductionListTableRow.Type == E.ManufactureProductType.House then
        table.insert(unlockedProductionList, v)
      end
      if not self.viewData.isHouseCast and lifeProductionListTableRow.Type ~= E.ManufactureProductType.House then
        table.insert(unlockedProductionList, v)
      end
    end
  end
  self.infoGridView:ClearAllSelect()
  self.infoGridView:RefreshListView(unlockedProductionList)
  if 0 < #unlockedProductionList then
    self.infoGridView:SelectIndex(0)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #unlockedProductionList <= 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_middle, 0 < #unlockedProductionList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, 0 < #unlockedProductionList)
  self.uiBinder.lab_empty.text = Lang("NoUnlockRecipe")
end

function Life_profession_cast_mainView:refreshTop()
  self.uiBinder.lab_level_num.text = self.lifeProfessionVM.GetLifeProfessionLv(self.proID)
end

function Life_profession_cast_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.isCasting = false
  if self.infoGridView then
    self.infoGridView:UnInit()
  end
  if self.formulaOneView then
    self.formulaOneView:UnInit()
  end
  if self.formulaMultiView then
    self.formulaMultiView:UnInit()
  end
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
  end
  if self.castingTimer then
    self.timerMgr:StopTimer(self.castingTimer)
  end
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  Z.EventMgr:RemoveObjAll(self)
  self.lifeProfessionVM.SwitchEntityShow(true)
  self:closeCamera()
  self.viewData.slowCam = false
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast_pre)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cast_end)
  self.slider_:RemoveAllListeners()
  self.itemClass_:UnInit()
  if self.screeningRightSubView_ then
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    self.screeningRightSubView_ = nil
  end
  self.uiBinder.input_search.text = ""
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.lifeProfessionData_:ClearFilterDatas()
  self.lifeProfessionVM.CloseSwicthFormulaPopUp()
end

function Life_profession_cast_mainView:OnRefresh()
end

function Life_profession_cast_mainView:initBtnClick()
  self:AddClick(self.maxBtn_, function()
    self.slider_.value = self.sliderMaxValue_
  end)
  self:AddClick(self.addBtn_, function()
    if self.curValue_ < self.sliderMaxValue_ then
      self.slider_.value = self.curValue_ + 1
    end
  end)
  self:AddClick(self.minusBtn_, function()
    if self.curValue_ > 1 then
      self.slider_.value = self.curValue_ - 1
    end
  end)
  self:AddClick(self.uiBinder.btn_money, function()
    self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.btn_money.transform, self.curData.Cost[1])
  end)
  self:AddClick(self.uiBinder.btn_start, function()
    if not self.lifeProfessionVM.IsProductUnlocked(self.curData.LifeProId, self.curData.Id) then
      Z.TipsVM.ShowTipsLang(3616)
      return
    end
    local maxCount = self:GetMatCanMakeMaxCount()
    if maxCount == 0 then
      Z.TipsVM.ShowTipsLang(self:getLackMaterialMessage())
      return
    end
    local costItemID = self.curData.Cost[1]
    local costCnt = self.curData.Cost[2]
    self.uiBinder.rimg_money_icon:SetImage(self.itemsVM_.GetItemIcon(costItemID))
    local haveCount = self.itemsVM_.GetItemTotalCount(costItemID)
    local totalCost = costCnt * self.curValue_
    if haveCount < totalCost then
      Z.TipsVM.ShowTipsLang(self:getLackVigourMessage())
      return
    end
    self.isCasting = true
    self:refreshCastState(true)
  end)
  self:AddClick(self.uiBinder.btn_stop, function()
    Z.TipsVM.ShowTipsLang(self:getStopMessage())
    self.isCasting = false
    self:refreshCastState()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    for k, v in pairs(Z.Global.LifeProductionProHelpId) do
      if v[1] == self.proID then
        Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(v[2])
        return
      end
    end
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.lifeProfessionVM.CloseCastMainView()
  end)
  self:AddClick(self.uiBinder.btn_level, function()
    self.lifeProfessionVM.OpenLifeProfessionInfoView(self.proID)
  end)
  self:AddClick(self.uiBinder.btn_switch, function()
    self.lifeProfessionVM.OpenSwicthFormulaPopUp(self.curProductData_, self.uiBinder.node_formula_tips)
  end)
  self.uiBinder.tog_screening:RemoveAllListeners()
  
  function self.screenCloseFunc()
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening.isOn = false
    self:refreshLeft()
  end
  
  self.uiBinder.tog_screening:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
      self.screeningRightSubView_:Active({
        proID = self.proID,
        closeFunc = self.screenCloseFunc
      }, self.uiBinder.node_right_sub, self)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    else
      self.screeningRightSubView_:DeActive()
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      self:refreshLeft()
      local hasFilter = self.lifeProfessionData_:HasFilterChanged(self.proID)
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
    self.lifeProfessionData_:SetFilterName(self.proID, text)
    self:refreshLeft()
  end, true)
end

function Life_profession_cast_mainView:getLackMaterialMessage()
  return self:getMessage(Z.Global.LifeManufactureLackMatMessages)
end

function Life_profession_cast_mainView:getLackVigourMessage()
  return self:getMessage(Z.Global.LifeManufactureLackVigourMessages)
end

function Life_profession_cast_mainView:getStopMessage()
  return self:getMessage(Z.Global.LifeManufactureStopMessages)
end

function Life_profession_cast_mainView:getMessage(messageTable)
  if not messageTable then
    return 0
  end
  for k, v in pairs(messageTable) do
    if v[1] == self.proID then
      return v[2]
    end
  end
  return 0
end

function Life_profession_cast_mainView:init()
  self.infoGridView = loopGridView.new(self, self.uiBinder.loop_item, lifeProfessionInfoGridItem, "com_item_square_1")
  self.formulaOneView = loopListView.new(self, self.uiBinder.loop_list_one_formula, menufactureProductionItem, "com_item_square_1_8")
  self.formulaMultiView = loopListView.new(self, self.uiBinder.loop_list_multi_formula, menufactureProductionItem, "com_item_square_1_8")
  self.infoGridView:Init({})
  self.formulaOneView:Init({})
  self.formulaMultiView:Init({})
end

function Life_profession_cast_mainView:OnSelectItem(data)
  self.curProductData_ = data
  self.curValue_ = 1
  local curSelectProduct = self.lifeMenufactorData_:GetCurSelectProductID(data.productId)
  self.curData = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(curSelectProduct)
  self:refreshMiddle()
  self:refreshRight()
end

function Life_profession_cast_mainView:refreshMiddle()
  self:refreshMiddleItem()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_multi_formula, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_one_formula, false)
  local datas = self.lifeProfessionVM.GetProductionMaterials(self.curData)
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
  local isCurUnlocked = self.lifeProfessionVM.IsProductUnlocked(self.curData.LifeProId, self.curData.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, not isCurUnlocked)
end

function Life_profession_cast_mainView:refreshMiddleItem()
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_production
  })
  local itemData = {}
  itemData.configId = self.curData.RelatedItemId
  itemData.uiBinder = self.uiBinder.item_production
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
  local isProductionUnlocked = self.lifeProfessionVM.IsProductUnlocked(self.curData.LifeProId, self.curData.Id)
  self.itemClass_:SetImgLockState(not isProductionUnlocked)
  local isProductionHasCost = self.lifeProfessionVM.IsProductHasCost(self.curData.LifeProId, self.curData.Id)
  self.itemClass_:SetImgTradeState(isProductionHasCost)
  self.uiBinder.lab_production.text = self.curData.Name
end

function Life_profession_cast_mainView:setSlot(itemRound, costLab, cost)
  if self.curValue_ == nil then
    self.curValue_ = 0
  end
  local configId = cost[1]
  local haveCount = self.itemsVM_.GetItemTotalCount(configId)
  local consumeCount = self.curValue_ * cost[2]
  if self.curValue_ == 0 then
    consumeCount = cost[2]
  end
  if haveCount < consumeCount then
    costLab.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsRed) .. "/" .. math.ceil(consumeCount)
  else
    costLab.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsGreen) .. "/" .. math.ceil(consumeCount)
  end
  if configId then
    local itemTableBase = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if itemTableBase then
      local itemsVm = Z.VMMgr.GetVM("items")
      itemRound.rimg_icon:SetImage(itemsVm.GetItemIcon(configId))
      itemRound.img_quality:SetImage(Z.ConstValue.QualityImgCircleBg .. itemTableBase.Quality)
      itemRound.Ref:SetVisible(itemRound.lab_content, false)
      self:AddClick(itemRound.btn_temp, function()
        self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(itemRound.Trans, configId)
      end)
    end
  end
end

function Life_profession_cast_mainView:refreshRight()
  self.uiBinder.img_bg_quality:SetColor(Z.ConstValue.QualityBgColor[self.curData.Quality])
  self.uiBinder.lab_name.text = self.curData.Name
  self.uiBinder.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(self.curData.RelatedItemId))
  self.uiBinder.lab_info.text = self.curData.Des
  self:refreshFixedOutput()
  self:refreshExtraOutput()
  self:refreshCastState()
end

function Life_profession_cast_mainView:refreshFixedOutput()
  local path = self.uiBinder.prefab_cache:GetString("output_item_tpl")
  local root = self.uiBinder.content_output
  if self.outputUnits_ then
    for _, value in pairs(self.outputUnits_) do
      self:RemoveUiUnit(value)
    end
  end
  self.outputUnits_ = {}
  local awardTable = self.lifeProfessionVM.GetCastFixedAwards(self.curData)
  if not awardTable then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, value in pairs(awardTable) do
      local name = "output_tpl_" .. k
      table.insert(self.outputUnits_, name)
      local unit = self:AsyncLoadUiUnit(path, name, root)
      if unit ~= nil then
        unit.lab.text = Lang("LifeCastCntProb", {
          count = value.count,
          prob = string.format("%0.1f", value.prob * 100)
        })
      end
    end
  end)()
end

function Life_profession_cast_mainView:refreshExtraOutput()
  if self.curData.ExtraAward[1] == nil or #self.curData.ExtraAward[1] ~= 2 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra, false)
    return
  end
  local spcID = self.curData.ExtraAward[1][2]
  if not self.lifeProfessionVM.IsSpecializationUnlocked(self.proID, spcID) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra, false)
    return
  end
  local rewardPackID = self.curData.ExtraAward[1][1]
  local awardPackageTableRow = Z.TableMgr.GetTable("AwardPackageTableMgr").GetRow(rewardPackID)
  if not awardPackageTableRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra, false)
    return
  end
  local rewardId = awardPackageTableRow.PackContent[1][1]
  local awardTableRow = Z.TableMgr.GetTable("AwardTableMgr").GetRow(rewardId)
  if not awardTableRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_extra, true)
  local extraItemID = awardTableRow.GroupContent[1][1]
  local extraItemCount = awardTableRow.GroupContent[1][2]
  local extraItemProb = awardTableRow.GroupWeight[1] and awardTableRow.GroupWeight[1] / 10000 or 0
  self.uiBinder.extra_rimg_icon:SetImage(self.itemsVM_.GetItemIcon(extraItemID))
  self.uiBinder.extra_lab_quantity.text = Lang("x", {val = extraItemCount})
  self.uiBinder.extra_lab_chance.text = string.format("%0.1f", extraItemProb * 100) .. "%"
end

function Life_profession_cast_mainView:refreshCastState(showEffect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_start, not self.isCasting)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_stop, self.isCasting)
  self:SetALLBtnEnable(self.isCasting)
  if self.isCasting then
    if showEffect then
      self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
      self.uiBinder.effect_cast:SetEffectGoVisible(false)
      self.uiBinder.effect_cast_pre:SetEffectGoVisible(true)
      self.uiBinder.effect_cast_pre:Play()
    end
    self:refreshCasting()
  else
    self.uiBinder.effect_cast_pre:SetEffectGoVisible(false)
    self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
    self.uiBinder.effect_cast:SetEffectGoVisible(false)
    self:refreshNotCasting()
  end
end

function Life_profession_cast_mainView:refreshCasting()
  self.uiBinder.lab_num.text = math.ceil(self.curValue_)
  if self.castingTimer then
    self.timerMgr:StopTimer(self.castingTimer)
  end
  local castingTime = self.lifeProfessionVM.GetLifeManufactureCost(self.proID)
  local totalTime = self.lifeProfessionVM.GetLifeManufactureCost(self.proID)
  self.castingTimer = self.timerMgr:StartTimer(function()
    castingTime = castingTime - 0.05
    if 0 < castingTime then
      self.uiBinder.lab_seconds.text = Lang("Second", {
        val = string.format("%0.1f", castingTime)
      })
      self.uiBinder.img_ing.fillAmount = castingTime / totalTime
    elseif self.curValue_ > 1 then
      self.curValue_ = self.curValue_ - 1
      self.uiBinder.lab_num.text = math.ceil(self.curValue_)
      castingTime = self.lifeProfessionVM.GetLifeManufactureCost(self.proID)
      Z.CoroUtil.create_coro_xpcall(function()
        self.lifeProfessionVM.AsyncRequestLifeProfessionBuild(self.curData.Id, 1, self.cancelSource:CreateToken())
        self.uiBinder.effect_cast:SetEffectGoVisible(true)
        self.uiBinder.effect_cast:Play()
        local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
        coro(0.1, self.cancelSource:CreateToken())
        self.uiBinder.effect_cast_pre:SetEffectGoVisible(false)
        self.uiBinder.effect_cast_end:SetEffectGoVisible(false)
        coro(2.5, self.cancelSource:CreateToken())
        self.uiBinder.effect_cast:SetEffectGoVisible(false)
        self.uiBinder.effect_cast_pre:SetEffectGoVisible(true)
        self.uiBinder.effect_cast_pre:Play()
      end)()
    else
      Z.CoroUtil.create_coro_xpcall(function()
        self.lifeProfessionVM.AsyncRequestLifeProfessionBuild(self.curData.Id, 1, self.cancelSource:CreateToken())
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
      end)()
      if self.castingTimer then
        self.timerMgr:StopTimer(self.castingTimer)
      end
      self.isCasting = false
      self:refreshCastState()
    end
  end, 0.05, -1)
end

function Life_profession_cast_mainView:SetALLBtnEnable(enable)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_click_mask, enable)
end

function Life_profession_cast_mainView:initNumSlider()
  self.slider_.maxValue = self.sliderMaxValue_
  self.slider_.minValue = 1
  if self.curValue_ == nil then
    self.curValue_ = 1
  end
  self.selectedNumLab_.text = math.floor(self.curValue_)
  self.slider_:RemoveAllListeners()
  self:AddClick(self.slider_, function(value)
    self.selectedNumLab_.text = math.floor(value)
    self.curValue_ = tonumber(value)
    self:refreshMiddle()
    self:refreshCost()
  end)
  self.slider_.value = self.curValue_
  self:refreshCost()
end

function Life_profession_cast_mainView:refreshNotCasting()
  if self.castingTimer then
    self.timerMgr:StopTimer(self.castingTimer)
  end
  local maxCount = self:GetCanMakeMaxCount()
  self.sliderMaxValue_ = maxCount == 0 and 1 or maxCount
  self:initNumSlider()
  self.uiBinder.Ref:SetVisible(self.uiBinder.can_cast_btn, 0 < maxCount)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cannot_cast_btn, maxCount == 0)
end

function Life_profession_cast_mainView:refreshCost()
  local costItemID = self.curData.Cost[1]
  local costCnt = self.curData.Cost[2]
  self.uiBinder.rimg_money_icon:SetImage(self.itemsVM_.GetItemIcon(costItemID))
  local haveCount = self.itemsVM_.GetItemTotalCount(costItemID)
  local totalCost = costCnt * self.curValue_
  if haveCount >= totalCost then
    self.uiBinder.lab_money_num.text = Z.RichTextHelper.ApplyStyleTag(math.ceil(totalCost), E.TextStyleTag.TipsGreen)
  else
    self.uiBinder.lab_money_num.text = Z.RichTextHelper.ApplyStyleTag(math.ceil(totalCost), E.TextStyleTag.TipsRed)
  end
end

function Life_profession_cast_mainView:GetCanMakeMaxCount()
  local maxCount = self:GetMatCanMakeMaxCount()
  local maxCostCount = math.floor(self.itemsVM_.GetItemTotalCount(self.curData.Cost[1]) / self.curData.Cost[2])
  maxCount = math.min(maxCount, maxCostCount)
  return math.min(maxCount, Z.Global.LifeCastMaxCnt)
end

function Life_profession_cast_mainView:GetMatCanMakeMaxCount()
  local maxCount
  for k, v in pairs(self.curData.NeedMaterial) do
    local haveCount = self.itemsVM_.GetItemTotalCount(v[1])
    local consumeCount = v[2]
    local canMakeCount = math.floor(haveCount / consumeCount)
    if maxCount == nil then
      maxCount = canMakeCount
    else
      maxCount = math.min(maxCount, canMakeCount)
    end
  end
  return maxCount == nil and 0 or maxCount
end

return Life_profession_cast_mainView
