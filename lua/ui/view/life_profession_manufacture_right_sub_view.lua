local UI = Z.UI
local super = require("ui.ui_subview_base")
local Life_profession_manufacture_right_subView = class("Life_profession_manufacture_right_subView", super)
local menufactureProductionItem = require("ui.component.life_profession.menufacture_production_item")
local loopListView = require("ui.component.loop_list_view")
local currency_item_list = require("ui.component.currency.currency_item_list")
local item = require("common.item_binder")

function Life_profession_manufacture_right_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "life_profession_manufacture_right_sub", "life_profession/life_profession_manufacture_right_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "life_profession_manufacture_right_sub", "life_profession/life_profession_manufacture_right_sub", UI.ECacheLv.None)
  end
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.cookVm_ = Z.VMMgr.GetVM("cook")
  self.awardVm_ = Z.VMMgr.GetVM("awardpreview")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  self.cookVm_ = Z.VMMgr.GetVM("cook")
  self.chemistryVm_ = Z.VMMgr.GetVM("chemistry")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.lifeMenufactorData_ = Z.DataMgr.Get("life_menufacture_data")
  self.itemClass_ = item.new(self)
  self.itemTraceVM_ = Z.VMMgr.GetVM("item_trace")
end

function Life_profession_manufacture_right_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:InitBinders()
  self:initBtnFunc()
  self:initLoopView()
  self:bindEvents()
  self.buffUnits_ = {}
end

function Life_profession_manufacture_right_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, self.lifeProfessionSpecChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSubFormulaChanged, self.lifeProfessionSubFormulaChanged, self)
end

function Life_profession_manufacture_right_subView:lifeProfessionLevelChanged(proID)
  if self.data_.LifeProId == proID then
    self:OnRefresh()
  end
end

function Life_profession_manufacture_right_subView:lifeProfessionSpecChanged(proID)
  if self.data_.LifeProId == proID then
    self:OnRefresh()
  end
end

function Life_profession_manufacture_right_subView:lifeProfessionSubFormulaChanged()
  self:refreshInfo()
end

function Life_profession_manufacture_right_subView:OnDeActive()
  Z.EventMgr:RemoveObjAll(self)
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  self.formulaOneView:UnInit()
  self.formulaMultiView:UnInit()
  self.itemClass_:UnInit()
  self.lifeProfessionVM.CloseSwicthFormulaPopUp()
end

function Life_profession_manufacture_right_subView:OnRefresh()
  self.menufactureProductData = self.viewData.data
  if self.viewData.productionID then
    for k, v in pairs(self.menufactureProductData.subProductList) do
      if v == self.viewData.productionID then
        self.menufactureProductData.curSelectProduct = self.viewData.productionID
        self.menufactureProductData.curSelectProductIndex = k
      end
    end
  end
  if not self.currencyItemList_ then
    self.currencyItemList_ = currency_item_list.new()
  end
  self:refreshInfo()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    self.data_.Cost[1],
    self.lifeProfessionVM.GetSpcItemIDByProId()
  })
  self.lifeProfessionVM.CloseSwicthFormulaPopUp()
end

function Life_profession_manufacture_right_subView:refreshInfo()
  local curSelectProduct = self.lifeMenufactorData_:GetCurSelectProductID(self.menufactureProductData.productId)
  self.data_ = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(curSelectProduct)
  self:refreshMiddleItem()
  self.isProductionUnlocked_ = self.lifeProfessionVM.IsProductUnlocked(self.data_.LifeProId, self.data_.Id)
  local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", self.data_.LifeProId)
  if config == nil then
    return
  end
  self.levelLab_.text = Lang("NeedProfessionLevel", {
    professionName = config.Name,
    needLevel = self.data_.NeedLevel
  })
  local showLevel = self.data_.NeedLevel > 0
  self.uiBinder.Ref:SetVisible(self.levelLab_, showLevel)
  self.labInfoTitle_.text = Lang("LifeProfessionInfoTitle" .. self.data_.LifeProId)
  self:refreshBuffers()
  self.descLab_.text = self.data_.Des
  self:refreshMaterials()
  self.uiBinder.Ref:SetVisible(self.nodeUnlocked_, self.isProductionUnlocked_)
  self.uiBinder.Ref:SetVisible(self.nodeLocked_, not self.isProductionUnlocked_)
  if not self.isProductionUnlocked_ then
    self:refreshConditions()
  else
    self:refreshCost()
  end
end

function Life_profession_manufacture_right_subView:refreshMiddleItem()
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_production
  })
  local itemData = {}
  itemData.configId = self.data_.RelatedItemId
  itemData.uiBinder = self.uiBinder.item_production
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
  self.isProductionUnlocked_ = self.lifeProfessionVM.IsProductUnlocked(self.data_.LifeProId, self.data_.Id)
  self.itemClass_:SetImgLockState(not self.isProductionUnlocked_)
  local isProductionHasCost = self.lifeProfessionVM.IsProductHasCost(self.data_.LifeProId, self.data_.Id)
  self.itemClass_:SetImgTradeState(isProductionHasCost)
  self.uiBinder.lab_production.text = self.data_.Name
end

function Life_profession_manufacture_right_subView:refreshConditions()
  local conditionDatas = {}
  if self.data_.LifeProId == E.ELifeProfession.Chemistry then
    for _, v in pairs(self.data_.UnlockCondition) do
      local _, _, _, _, _, showPreview = Z.ConditionHelper.GetSingleConditionDesc(v[1], v[2], v[3])
      if showPreview ~= nil then
        local conditionData = {}
        conditionData.isUnlocked = false
        conditionData.showPurview = showPreview
        table.insert(conditionDatas, conditionData)
      end
    end
  else
    conditionDatas = Z.ConditionHelper.GetConditionDescList(self.data_.UnlockCondition)
  end
  for k, v in pairs(self.data_.UnlockCondition) do
    if v[1] == E.ConditionType.Item then
      local conditionData = conditionDatas[k]
      local item = Z.TableMgr.GetTable("ItemTableMgr").GetRow(v[2])
      local name = ""
      if item == nil then
        name = ""
      end
      local name = string.zconcat("<u>", item.Name, "</u>")
      conditionData.showPurview = string.zconcat(Lang("GotItem:"), "<link>", name, "</link>", 1 < v[3] and "*" .. v[3] or "")
      conditionData.itemId = v[2]
    end
  end
  if self.conditionDict ~= nil then
    for _, v in pairs(self.conditionDict) do
      self:RemoveUiUnit(v)
    end
  end
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
      self:AddClick(condition.lab_unlock_conditions, function()
        if v.itemId then
          if self.tipsId_ then
            Z.TipsVM.CloseItemTipsView(self.tipsId_)
            self.tipsId_ = nil
          end
          self.tipsId_ = Z.TipsVM.ShowItemTipsView(condition.lab_unlock_conditions.transform, v.itemId)
        end
      end)
      condition.Ref:SetVisible(condition.img_off, not v.IsUnlock)
      condition.Ref:SetVisible(condition.img_on, v.IsUnlock)
    end
  end)()
end

function Life_profession_manufacture_right_subView:refreshBuffers()
  if self.data_.RelatedItemId then
    local cookCuisineRandomTableRow = Z.TableMgr.GetTable("CookCuisineRandomTableMgr").GetRow(self.data_.RelatedItemId, true)
    if cookCuisineRandomTableRow then
      if self.data_.LifeProId == E.ELifeProfession.Chemistry then
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.buff_item.lab_info, self.chemistryVm_.GetBuffDesById(self.data_.RelatedItemId))
      end
      self.uiBinder.buff_item.Ref.UIComp:SetVisible(true)
    else
      self.uiBinder.buff_item.Ref.UIComp:SetVisible(false)
    end
  else
    self.uiBinder.buff_item.Ref.UIComp:SetVisible(false)
  end
  if self.data_.LifeProId == 201 then
    self:refreshCookBuffers()
  end
end

function Life_profession_manufacture_right_subView:refreshCookBuffers()
  for name, unit in pairs(self.buffUnits_) do
    self:RemoveUiUnit(name)
  end
  local buffDatas = self.lifeProfessionVM.GetMenufactureBuffDatas(self.data_)
  if not buffDatas then
    return
  end
  local itemPath = "ui/prefabs/life_profession/life_profession_cook_buffdesc_item_tpl"
  if Z.IsPCUI then
    itemPath = "ui/prefabs/life_profession/life_profession_cook_buffdesc_item_tpl_pc"
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(buffDatas) do
      local unitName = "buff" .. index
      local unit = self:AsyncLoadUiUnit(itemPath, unitName, self.buffContent_.transform)
      if unit then
        self.buffUnits_[unitName] = unit
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.lab_info, value)
      end
    end
    self.descLab_.transform:SetSiblingIndex(#buffDatas)
  end)()
end

function Life_profession_manufacture_right_subView:refreshCost()
  if #self.data_.Cost ~= 2 then
    self.uiBinder.Ref:SetVisible(self.nodeCost_, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.nodeCost_, true)
  local costItem = self.data_.Cost[1]
  local costCnt = self.data_.Cost[2]
  local itemsVm = Z.VMMgr.GetVM("items")
  local haveCount = self.itemsVM_.GetItemTotalCount(costItem)
  local cntText = tostring(costCnt)
  if costCnt > haveCount then
    cntText = Z.RichTextHelper.ApplyStyleTag(math.ceil(costCnt), E.TextStyleTag.TipsRed)
  end
  self.labCost_.text = Lang("CollectionCost" .. self.data_.LifeProId, {val = cntText})
  self.rimgCost_:SetImage(itemsVm.GetItemIcon(costItem))
  self.uiBinder.layout_glod:ForceRebuildLayoutImmediate()
  self.uiBinder.layout_glod:MarkLayoutForRebuild()
  if self.data_.Type == E.ManufactureProductType.House then
    self.labBtn_.text = Lang("LifeProfessionInfoBtnGoFurniture")
  else
    self.labBtn_.text = Lang("LifeProfessionInfoBtnGo" .. self.data_.LifeProId)
  end
end

function Life_profession_manufacture_right_subView:refreshMaterials()
  local datas = self.lifeProfessionVM.GetProductionMaterials(self.data_)
  if table.zcount(self.menufactureProductData.subProductList) > 0 then
    self.uiBinder.lab_formula.text = Lang("LifeManufactureFormuaIndex" .. self.menufactureProductData.curSelectProductIndex)
    self.uiBinder.lab_formula_lock.text = Lang("LifeManufactureFormuaIndex" .. self.menufactureProductData.curSelectProductIndex)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_formula_lock, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_multi_formula, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_one_formula, false)
    self.formulaMultiView:RefreshListView(datas)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_multi_formula, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_one_formula, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_formula_lock, false)
    self.formulaOneView:RefreshListView(datas)
  end
  local isCurUnlocked = self.lifeProfessionVM.IsProductUnlocked(self.data_.LifeProId, self.data_.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock_formula, not isCurUnlocked)
end

function Life_profession_manufacture_right_subView:InitBinders()
  self.rimgIconLocked_ = self.uiBinder.rimg_icon_mark
  self.levelLab_ = self.uiBinder.lab_learning_level
  self.levelInfoTitle_ = self.uiBinder.lab_info_title
  self.descLab_ = self.uiBinder.lab_info
  self.nodeProduct_ = self.uiBinder.node_product
  self.nodeLocked_ = self.uiBinder.node_unlock
  self.nodeUnlocked_ = self.uiBinder.node_tracking
  self.labCost_ = self.uiBinder.lab_consumption
  self.rimgCost_ = self.uiBinder.rimg_gold
  self.trackBtn_ = self.uiBinder.btn_square_new
  self.nodeCost_ = self.uiBinder.node_cost
  self.buffContent_ = self.uiBinder.content_buff
  self.labBtn_ = self.uiBinder.lab_btn_name
  self.labInfoTitle_ = self.uiBinder.lab_info_title
end

function Life_profession_manufacture_right_subView:initBtnFunc()
  self:AddAsyncClick(self.trackBtn_, function()
    if self.data_.Type == E.ManufactureProductType.House then
      self:openHouseManufactureDialog()
    else
      self.quickJumpVM_.DoJumpByConfigParam(self.data_.QuickJumpType, self.data_.QuickJump)
    end
  end)
  self:AddClick(self.uiBinder.btn_switch, function()
    self.lifeProfessionVM.OpenSwicthFormulaPopUp(self.menufactureProductData, self.uiBinder.node_formula_tips, true)
  end)
  self:AddClick(self.uiBinder.btn_material_tracking, function()
    local consumeList = {}
    for i, v in ipairs(self.data_.NeedMaterial) do
      if v[1] ~= 0 and v[2] ~= 0 then
        if self.data_.NeedMaterialType == 1 then
          consumeList[#consumeList + 1] = {
            ItemId = v[1],
            ItemNum = v[2],
            LabType = E.ItemLabType.Expend
          }
        elseif self.data_.NeedMaterialType == 2 then
          local materials = self.cookVm_.GetAllCookMaterialData(v[1])
          if 0 < #materials then
            consumeList[#consumeList + 1] = {
              ItemId = materials[1].Id,
              ItemNum = v[2],
              LabType = E.ItemLabType.Expend
            }
          end
        end
      end
    end
    self.itemTraceVM_.ShowTraceView(self.data_.RelatedItemId, consumeList)
  end)
end

function Life_profession_manufacture_right_subView:openHouseManufactureDialog()
  local itemList = {}
  for k, v in pairs(Z.Global.HouseManufactureDialogShowItem) do
    local itemData = {
      ItemId = v[1],
      ItemNum = v[2]
    }
    table.insert(itemList, itemData)
  end
  local dialogViewData = {
    dlgType = E.DlgType.OK,
    labTitle = Lang("HouseManufactureDialogTitle"),
    labDesc = Lang("HouseManufactureDialogDesc"),
    itemList = itemList
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
end

function Life_profession_manufacture_right_subView:initLoopView()
  self.formulaOneView = loopListView.new(self, self.uiBinder.loop_list_one_formula, menufactureProductionItem, "com_item_square_1_8")
  self.formulaMultiView = loopListView.new(self, self.uiBinder.loop_list_multi_formula, menufactureProductionItem, "com_item_square_1_8")
  self.formulaOneView:Init({})
  self.formulaMultiView:Init({})
end

return Life_profession_manufacture_right_subView
