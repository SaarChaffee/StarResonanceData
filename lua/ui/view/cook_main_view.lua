local UI = Z.UI
local super = require("ui.ui_view_base")
local Cook_mainView = class("Cook_mainView", super)
local loopGridView = require("ui.component.loop_grid_view")
local randIconPath = "ui/atlas/cook/cook_prob_"
local cookItemLoopItem = require("ui.component.cook.cook_item_loop_item")
local cookRecipeItemLoopItem = require("ui.component.cook.cook_recipe_loop_item")
local ResearchRecipeCraftEnergyConsume = Z.Global.ResearchRecipeCraftEnergyConsume
local CookCuisineCraftEnergyConsume = Z.Global.CookCuisineCraftEnergyConsume
local cook_replace_sub_view = require("ui.view.cook_replace_sub_view")
local DefaultCameraId = 4000
local buffId = Z.Global.CookBuff
local pagesType = {FastCook = 1, DevelopCookBook = 2}
local foodMaterialsSlotType = {
  pMaterials1 = 1,
  aMaterials1 = 2,
  aMaterials2 = 3
}

function Cook_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cook_main")
  self.vm_ = Z.VMMgr.GetVM("cook")
  self.cookData_ = Z.DataMgr.Get("cook_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemTipsView_ = require("ui.view.tips_item_info_popup_view").new()
  self.cook_replace_sub_view = cook_replace_sub_view.new(self)
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
end

function Cook_mainView:initWidget()
  self.title_label_ = self.uiBinder.lab_title
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("cook_main")
  end)
  self.page_toggle_group_ = self.uiBinder.toggle_group
  self.page_toggle_list_ = {
    self.uiBinder.tog_fast,
    self.uiBinder.tog_develop
  }
  self.loop_food_item_ = self.uiBinder.loop_food_item
  self.loop_recipe_item = self.uiBinder.loop_recipe_item
  self.cont_empty_ = self.uiBinder.node_empty
  self.lab_empty_ = self.uiBinder.lab_empty
  self.node_right_ = self.uiBinder.node_right
  self.cook_node_bottom_ = self.uiBinder.node_btn_self_develop
  self.cont_tips_ = self.uiBinder.node_item_tips
  self.labType_ = self.node_right_.lab_type
  self.tipsName_ = self.node_right_.lab_name
  self.tipsIcon_ = self.node_right_.rimg_icon
  self.img_bg_quality_ = self.node_right_.img_bg_quality
  self.img_bg_quality_ = self.node_right_.img_bg_quality
  self.lab_info_ = self.node_right_.lab_info
  self.rimg_money_icon_ = self.node_right_.rimg_money_icon
  self.lab_money_num_ = self.node_right_.lab_money_num
  self.lab_item_num_ = self.node_right_.lab_num
  self.slider_progress_ = self.node_right_.slider_temp
  self.btn_minus_ = self.node_right_.btn_reduce
  self.btn_add_ = self.node_right_.btn_add
  self.btn_max_ = self.node_right_.btn_max
  self.fast_cook_btn_ = self.node_right_.btn_confirm_cook
  self.btn_develop_cook_ = self.cook_node_bottom_.btn_confirm_cook
  self.btn_delete_ = self.cook_node_bottom_.btn_delete
  self.btn_ask_ = self.uiBinder.btn_ask
  self.food_ring_icon_ = self.cook_node_bottom_.rimg_icon
  self.food_lab_num_ = self.cook_node_bottom_.lab_num
  self.food_node_item_ = self.uiBinder.node_item_2
  self.recipe_node_item_ = self.uiBinder.node_item
  self.currencyParent_ = self.uiBinder.layout_content_currency
  self.foodSlotNode_ = {
    [foodMaterialsSlotType.pMaterials1] = self.food_node_item_.node_item_1,
    [foodMaterialsSlotType.aMaterials1] = self.food_node_item_.node_item_3,
    [foodMaterialsSlotType.aMaterials2] = self.food_node_item_.node_item_4
  }
  self.recipeSlotNode_ = {
    [foodMaterialsSlotType.pMaterials1] = self.recipe_node_item_.node_item_1,
    [foodMaterialsSlotType.aMaterials1] = self.recipe_node_item_.node_item_3,
    [foodMaterialsSlotType.aMaterials2] = self.recipe_node_item_.node_item_4
  }
  self.cookFoodTypeMax_ = Z.Global.CookLimit[1]
  self.cookFoodNumMax_ = Z.Global.CookLimit[2]
end

function Cook_mainView:initBtns()
  self.slider_progress_:AddListener(function(value)
    self.curValue_ = math.floor(value + 0.1)
    self:onRefreshNum()
  end)
  self:AddClick(self.btn_add_, function()
    self:add()
  end)
  self:AddClick(self.btn_minus_, function()
    self:reduce()
  end)
  self:AddPressListener(self.btn_add_, function()
    self:add()
  end)
  self:AddPressListener(self.btn_minus_, function()
    self:reduce()
  end)
  self:AddClick(self.btn_max_, function()
    self:setMax()
  end)
  self:AddClick(self.btn_ask_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(5050)
  end)
  self:AddAsyncClick(self.fast_cook_btn_, function()
    if not self.isCanCooking_ then
      Z.TipsVM.ShowTips(1002000)
      return
    end
    if self.craftEnergyConsume_ > self.itemsVM_.GetItemTotalCount(E.CurrencyType.Vitality) then
      Z.TipsVM.ShowTips(7201)
      return
    end
    if not self.curSelectConfig_ or self.curValue_ == 0 then
      return
    end
    self.uiBinder.Ref.UIComp:SetVisible(false)
    if self.entity_ then
      Z.LuaBridge.AddZEntityClientBuff(self.entity_, buffId)
      self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.cookClipPath_))
    end
    Z.Delay(self.clipLength_, self.cancelSource:CreateToken())
    if self.entity_ then
      self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.idelClipPath_))
    end
    self.uiBinder.Ref.UIComp:SetVisible(true)
    local mainMaterials = {
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials1]
    }
    local cookMethods = {
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials1],
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials2]
    }
    self.vm_.AsyncFastCook(self.curSelectConfig_.Id, self.curValue_, mainMaterials, cookMethods, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btn_develop_cook_, function()
    if self.DevelopErrorId_ ~= 0 then
      Z.TipsVM.ShowTips(self.DevelopErrorId_)
      return
    end
    if ResearchRecipeCraftEnergyConsume > self.itemsVM_.GetItemTotalCount(E.CurrencyType.Vitality) then
      Z.TipsVM.ShowTips(7201)
      return
    end
    self.uiBinder.Ref.UIComp:SetVisible(false)
    self:openCamera(4002)
    if self.entity_ then
      Z.LuaBridge.AddZEntityClientBuff(self.entity_, buffId)
      self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.cookClipPath_))
    end
    Z.Delay(self.clipLength_, self.cancelSource:CreateToken())
    if self.entity_ then
      self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.idelClipPath_))
    end
    self.uiBinder.Ref.UIComp:SetVisible(true)
    self:openCamera(4001)
    local mainMaterials = table.zvalues({
      self.foodSlotData_[foodMaterialsSlotType.pMaterials1]
    })
    local cookMethods = table.zvalues({
      self.foodSlotData_[foodMaterialsSlotType.aMaterials1],
      self.foodSlotData_[foodMaterialsSlotType.aMaterials2]
    })
    self.vm_.AsyncRdCook(mainMaterials, cookMethods, self.cancelSource:CreateToken())
  end)
  
  function self.packageWatcherFunc_(package, dirtyKeys)
    self.curSelectConfig_ = nil
    self:refreshLoopGridView()
  end
  
  function self.cookListWatcherFunc_(package, dirtyKeys)
    if self.curPages_ == pagesType.FastCook then
      self:initFastCookItem()
    end
  end
  
  Z.ContainerMgr.CharSerialize.cookList.Watcher:RegWatcher(self.cookListWatcherFunc_)
  self.itemPackage_ = Z.ContainerMgr.CharSerialize.itemPackage.packages[1]
  if self.itemPackage_ then
    self.itemPackage_.Watcher:RegWatcher(self.packageWatcherFunc_)
  end
  self:AddClick(self.btn_delete_, function()
    if table.zcount(self.foodSlotData_) == 0 then
      Z.TipsVM.ShowTips(1002004)
      return
    end
    self:clearFoodSlotData()
    self:refreshFoodBtsState()
    self:initDevelopCookBoolItem()
  end)
  self:AddClick(self.recipeSlotNode_[foodMaterialsSlotType.pMaterials1].btn_refresh, function()
    if #self.materialARefreshData_ > 0 then
      self.cook_replace_sub_view:Active({
        type = foodMaterialsSlotType.pMaterials1,
        data = self.materialARefreshData_
      }, self.recipeSlotNode_[foodMaterialsSlotType.pMaterials1].node_tips.transform)
    end
  end)
  for k, v in ipairs(self.recipeSlotNode_) do
    self:AddClick(v.btn_icon, function()
      local viewData = {}
      viewData.configId = self.recipeSlotData_[k]
      viewData.posTrans = v.Ref.transform
      viewData.parentTrans = v.Ref.transform
      viewData.isShowBg = true
      viewData.posType = E.EItemTipsPopType.Bounds
      if self.tipsId_ then
        Z.TipsVM.CloseItemTipsView(self.tipsId_)
        self.tipsId_ = nil
      end
      self.tipsId_ = Z.TipsVM.OpenItemTipsView(viewData)
    end)
  end
end

function Cook_mainView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function Cook_mainView:initAnimClip()
  self.clipLength_ = 0
  self.cookClipPath_ = "anim/env/cookcty001/as_env_cookcty001_cook"
  Z.LuaBridge.LoadAnimClip(self.cookClipPath_, self.cancelSource, function(clip)
    if clip then
      self.clipLength_ = Panda.ZAnim.ZAnimClipManager.Instance:GetClipLength(self.cookClipPath_)
    end
  end, function()
  end)
  self.idelClipPath_ = "anim/env/cookcty001/as_env_cookcty001_idle"
end

function Cook_mainView:getEntity()
  local entId = 1079
  if self.viewData ~= DefaultCameraId then
    entId = 105
  end
  local uuid = Z.EntityMgr:GetUuid(Z.PbEnum("EEntityType", "EntSceneObject"), entId, false, true)
  self.entity_ = Z.EntityMgr:GetEntity(uuid)
end

function Cook_mainView:initData()
  self.itemViewList_ = {}
  self.selectId_ = 0
  self.currentItem_ = nil
  self.isDelete_ = false
  self.curSelectConfig_ = nil
  self.loopItemDatas_ = {}
  self.recipeSlotData_ = {}
  self.foodSlotData_ = {}
  self.curPages_ = 0
  local cameraId = self.viewData or DefaultCameraId
  self.cameraInvokeId_ = {
    [pagesType.FastCook] = cameraId + 2,
    [pagesType.DevelopCookBook] = cameraId + 1
  }
  self.vm_.SetCookMaterialData()
end

function Cook_mainView:initUi()
  self.currencyVm_.OpenCurrencyView({
    E.CurrencyType.Vitality
  }, self.currencyParent_, self)
  self:clearFoodSlotData()
  self:clearRecipeSlotData()
  self.foodLoopRect_ = loopGridView.new(self, self.loop_food_item_, cookItemLoopItem, "cook_item_long")
  self.foodLoopRect_:Init({})
  self.foodLoopRect_:SetCanMultiSelected(true)
  self.recipeLoopRect_ = loopGridView.new(self, self.loop_recipe_item, cookRecipeItemLoopItem, "cook_item_long")
  self.recipeLoopRect_:Init({})
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", E.CurrencyType.Vitality)
  if itemRow then
    local itemsVm = Z.VMMgr.GetVM("items")
    self.rimg_money_icon_:SetImage(itemsVm.GetItemIcon(itemRow.Id))
    self.food_ring_icon_:SetImage(itemsVm.GetItemIcon(itemRow.Id))
  end
  self.food_lab_num_.text = ResearchRecipeCraftEnergyConsume
end

function Cook_mainView:OnActive()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.vm_.SwitchEntityShow(false)
  self:initData()
  self:initWidget()
  self:initBtns()
  self:initAnimClip()
  self:getEntity()
  self:openCamera(self.viewData or DefaultCameraId)
  self:initUi()
  self:initPages()
end

function Cook_mainView:initPages()
  for i = 1, 2 do
    local toggle = self.page_toggle_list_[i]
    toggle.group = self.page_toggle_group_
    toggle:AddListener(function(ison)
      if ison then
        if self.curPages_ == i then
          return
        end
        self:onPageToggleIsOn(i)
      end
    end)
    if 1 == i then
      toggle.isOn = true
      self:onPageToggleIsOn(i)
    end
  end
end

function Cook_mainView:onPageToggleIsOn(index)
  if self.curPages_ == index then
    return
  end
  self.curPages_ = index
  self:openCamera(self.cameraInvokeId_[self.curPages_])
  local FastCook, DevelopCookBook
  if self.curPages_ == pagesType.FastCook then
    FastCook = true
    self.selectedRecipeIndex_ = 0
    self:startClickTogAnimatedShow()
  else
    DevelopCookBook = true
  end
  self.node_right_.Ref.UIComp:SetVisible(false)
  self.cook_node_bottom_.Ref.UIComp:SetVisible(false)
  self.food_node_item_.Ref.UIComp:SetVisible(not FastCook)
  self.recipe_node_item_.Ref.UIComp:SetVisible(not DevelopCookBook)
  self.uiBinder.Ref:SetVisible(self.cont_tips_, false)
  self.uiBinder.Ref:SetVisible(self.loop_food_item_, not FastCook)
  self.uiBinder.Ref:SetVisible(self.loop_recipe_item, not DevelopCookBook)
  self.lab_empty_.text = FastCook and Lang("NotUnlockCookBook") or Lang("NoCookItem")
  self.title_label_.text = FastCook and Lang("FastCook") or Lang("DevelopCookBook")
  self:refreshLoopGridView()
end

function Cook_mainView:refreshLoopGridView()
  if self.curPages_ == pagesType.FastCook then
    self:initFastCookItem()
  else
    self:initDevelopCookBoolItem()
  end
end

function Cook_mainView:initFastCookItem()
  self.loopItemDatas_ = self.vm_.GetUnLockCookBookList()
  local isHaveBookItem = #self.loopItemDatas_ > 0
  self.node_right_.Ref.UIComp:SetVisible(isHaveBookItem)
  self.uiBinder.Ref:SetVisible(self.cont_tips_, isHaveBookItem)
  self.uiBinder.Ref:SetVisible(self.cont_empty_, #self.loopItemDatas_ == 0)
  self.recipeLoopRect_:RefreshListView(self.loopItemDatas_)
  self.recipeLoopRect_:ClearAllSelect()
  if self.selectedRecipeIndex_ == 0 then
    self.selectedRecipeIndex_ = 1
  end
  self.recipeLoopRect_:SetSelected(self.selectedRecipeIndex_)
end

function Cook_mainView:initDevelopCookBoolItem()
  self.loopItemDatas_ = self.vm_.GetCookFoodItems()
  self.uiBinder.Ref:SetVisible(self.cont_empty_, #self.loopItemDatas_ == 0)
  self.cook_node_bottom_.Ref.UIComp:SetVisible(true)
  self.foodLoopRect_:RefreshListView(self.loopItemDatas_)
  self:refreshFoodSlotData()
  self:refreshFoodBtsState()
end

function Cook_mainView:UnSelected(data)
  for slotIndex, configId in pairs(self.foodSlotData_) do
    if configId == data.configId then
      self.foodSlotData_[slotIndex] = nil
      self:setSlotNode(self.foodSlotNode_[slotIndex])
      self:refreshFoodBtsState()
      return
    end
  end
end

function Cook_mainView:OnSelectedFood(data)
  for slotIndex, configId in pairs(self.foodSlotData_) do
    if configId == data.configId then
      return false
    end
  end
  local cookMaterialTableRow = Z.TableMgr.GetTable("CookMaterialTableMgr").GetRow(data.configId)
  if not cookMaterialTableRow then
    return false
  end
  local isPrincipal = cookMaterialTableRow.TypeA == 1
  local slotIndex = 0
  if isPrincipal then
    if self.foodSlotData_[foodMaterialsSlotType.pMaterials1] then
      Z.TipsVM.ShowTips(1002002)
      return false
    end
    slotIndex = foodMaterialsSlotType.pMaterials1
  else
    if self.foodSlotData_[foodMaterialsSlotType.aMaterials1] and self.foodSlotData_[foodMaterialsSlotType.aMaterials2] then
      Z.TipsVM.ShowTips(1002003)
      return false
    end
    if self.foodSlotData_[foodMaterialsSlotType.aMaterials1] then
      slotIndex = foodMaterialsSlotType.aMaterials2
    else
      slotIndex = foodMaterialsSlotType.aMaterials1
    end
  end
  self.foodSlotData_[slotIndex] = data.configId
  self:setSlotNode(self.foodSlotNode_[slotIndex], data.configId)
  self:refreshFoodBtsState()
  return true
end

function Cook_mainView:refreshFoodBtsState()
  self.DevelopErrorId_ = 0
  if not self.foodSlotData_[foodMaterialsSlotType.pMaterials1] then
    self.DevelopErrorId_ = 1002005
    if not self.foodSlotData_[foodMaterialsSlotType.aMaterials1] and not self.foodSlotData_[foodMaterialsSlotType.aMaterials2] then
      self.DevelopErrorId_ = 1002004
    end
  end
  self.btn_delete_.IsDisabled = self.DevelopErrorId_ == 1002004
  self.btn_develop_cook_.IsDisabled = self.DevelopErrorId_ ~= 0
end

function Cook_mainView:clearFoodSlotData()
  for k, v in pairs(self.foodSlotNode_) do
    self:setSlotNode(v)
    self.foodSlotData_[k] = nil
  end
end

function Cook_mainView:refreshFoodSlotData()
  for slotIndex, configId in pairs(self.foodSlotData_) do
    if self.itemsVM_.GetItemTotalCount(configId) == 0 then
      self.foodSlotData_[slotIndex] = nil
      self:setSlotNode(self.foodSlotNode_[slotIndex])
    end
  end
end

function Cook_mainView:IsNeedSelected(data)
  for k, configId in pairs(self.foodSlotData_) do
    if configId == data then
      return true
    end
  end
  return false
end

function Cook_mainView:clearRecipeSlotData()
  local bind1 = self.recipeSlotNode_[foodMaterialsSlotType.pMaterials1]
  bind1.Ref:SetVisible(bind1.btn_refresh, false)
  self.mainMaterialA_ = nil
  for k, v in ipairs(self.recipeSlotNode_) do
    self:setSlotNode(v)
    self.recipeSlotData_[k] = nil
    v.Ref:SetVisible(v.lab_amount, false)
  end
  self.recipeSlotData_ = {}
end

function Cook_mainView:getMainMaterialRefreshData()
  local bind1 = self.recipeSlotNode_[foodMaterialsSlotType.pMaterials1]
  if self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] and self.mainMaterialA_ then
    self.materialARefreshData_ = self.vm_.GetFilterCookMaterialData(self.mainMaterialA_, self.recipeSlotData_[foodMaterialsSlotType.pMaterials1])
    bind1.Ref:SetVisible(bind1.btn_refresh, #self.materialARefreshData_ > 0)
  else
    bind1.Ref:SetVisible(bind1.btn_refresh, false)
  end
end

function Cook_mainView:OnSelectedRecipe(data, index)
  self:clearRecipeSlotData()
  local isPrincipal = data.RecipeRecognitionTpye == 1
  self.selectedRecipeIndex_ = index
  if isPrincipal then
    if data.MainMaterialA ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = data.MainMaterialA
    end
  elseif data.MainMaterialA ~= 0 then
    self.mainMaterialA_ = data.MainMaterialA
    self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = self.vm_.GetRecipeIdByTypeId(data.MainMaterialA)
  end
  if data.SuppleMaterialA ~= 0 then
    self.recipeSlotData_[foodMaterialsSlotType.aMaterials1] = self.vm_.GetRecipeIdByTypeId(data.SuppleMaterialA)
  end
  if data.SuppleMaterialB ~= 0 then
    self.recipeSlotData_[foodMaterialsSlotType.aMaterials2] = self.vm_.GetRecipeIdByTypeId(data.SuppleMaterialB)
  end
  self:getMainMaterialRefreshData()
  self:onSelectCookItem(data)
  self:refreshRightTips()
  for k, value in ipairs(self.recipeSlotNode_) do
    self:setSlotNode(value, self.recipeSlotData_[k])
    self:setSlotLab(value, k)
    value.Ref:SetVisible(value.lab_amount, self.recipeSlotData_[k] ~= nil)
  end
end

function Cook_mainView:refreshNumComp()
  self.maxNum_ = self.vm_.GetExchangeNum(self.recipeSlotData_[foodMaterialsSlotType.pMaterials1], self.recipeSlotData_[foodMaterialsSlotType.aMaterials1], self.recipeSlotData_[foodMaterialsSlotType.aMaterials2], self.curSelectConfig_)
  local canExchange = self.maxNum_ > 0 and true or false
  self.curValue_ = canExchange and 1 or 0
  self.slider_progress_.minValue = canExchange and 1 or 0
  self.slider_progress_.maxValue = canExchange and self.maxNum_ or 1
  self.slider_progress_.value = self.curValue_
  self.slider_progress_.interactable = canExchange
  self.isCanCooking_ = canExchange
  self.fast_cook_btn_.IsDisabled = not self.isCanCooking_
  self:onRefreshNum()
end

function Cook_mainView:onSelectCookItem(config)
  if self.curSelectConfig_ and self.curSelectConfig_ == config.Id then
    return
  end
  self.curSelectConfig_ = config
  self:startClickAnimatedShow()
  self:refreshNumComp()
end

function Cook_mainView:refreshRightTips()
  if not self.curSelectConfig_ then
    return
  end
  self.tipsName_.text = self.curSelectConfig_.RecipeName
  self.tipsIcon_:SetImage(self.curSelectConfig_.Icon)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.lab_info_, self.vm_.GetBuffDesById(self.curSelectConfig_.Level01CuisineId) .. self.curSelectConfig_.Description)
  self.img_bg_quality_:SetImage(Z.ConstValue.QualityImgTipsBg .. self.curSelectConfig_.Quality)
  local randomTab = self.vm_.GetCuisineRandom(self.curSelectConfig_.Quality)
  for i = 1, 3 do
    if randomTab[i] and 0 < randomTab[i] then
      self.node_right_.Ref:SetVisible(self.node_right_["img_" .. i], true)
      self.node_right_["lab_chance" .. i].text = randomTab[i] .. "%"
    else
      self.node_right_.Ref:SetVisible(self.node_right_["img_" .. i], false)
    end
  end
  self:setRandImage(self.curSelectConfig_.Level01CuisineId, 1)
  self:setRandImage(self.curSelectConfig_.Level02CuisineId, 2)
  self:setRandImage(self.curSelectConfig_.Level03CuisineId, 3)
  local configRow = Z.TableMgr.GetRow("ItemTableMgr", self.curSelectConfig_.Level00CuisineId)
  if configRow then
    local typeRow = Z.TableMgr.GetRow("ItemTypeTableMgr", configRow.Type)
    if typeRow then
      self.labType_.text = typeRow.Name
    end
  end
end

function Cook_mainView:setRandImage(configId, index)
  if configId == 0 then
    return
  end
  local configRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if configRow then
    self.node_right_["img_" .. index]:SetImage(randIconPath .. configRow.Quality)
  end
end

function Cook_mainView:setSlotLab(slot, index)
  local configId = self.recipeSlotData_[index]
  local haveCount = self.itemsVM_.GetItemTotalCount(configId)
  local consumeCount = self.curValue_ * (self.curSelectConfig_.QuickMakeMaterialExpend[index] or 0)
  if self.curValue_ == 0 then
    consumeCount = self.curSelectConfig_.QuickMakeMaterialExpend[index] or 0
  end
  if haveCount < consumeCount then
    slot.lab_amount.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsRed) .. "/" .. consumeCount
  else
    slot.lab_amount.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsGreen) .. "/" .. consumeCount
  end
  self.craftEnergyConsume_ = self.curValue_ * CookCuisineCraftEnergyConsume
  self.lab_money_num_.text = self.craftEnergyConsume_
end

function Cook_mainView:setSlotNode(slot, configId)
  if slot == nil then
    return
  end
  slot.Ref:SetVisible(slot.group_item, configId ~= nil)
  if configId then
    local itemTableBase = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if itemTableBase then
      local itemsVm = Z.VMMgr.GetVM("items")
      slot.rimg_icon:SetImage(itemsVm.GetItemIcon(configId))
      slot.img_mask:SetImage(Z.ConstValue.QualityImgCircleBg .. itemTableBase.Quality)
    end
  end
end

function Cook_mainView:SetMainMaterial(type, data)
  local lastConfigId = self.recipeSlotData_[type]
  if lastConfigId == nil then
    return
  end
  self.recipeSlotData_[type] = data.Id
  self:setSlotNode(self.recipeSlotNode_[type], self.recipeSlotData_[type])
  self:setSlotLab(self.recipeSlotNode_[type], type)
  self:getMainMaterialRefreshData()
  self:refreshNumComp()
  self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = lastConfigId
end

function Cook_mainView:onRefreshNum()
  self.lab_item_num_.text = self.curValue_
  for k, value in ipairs(self.recipeSlotNode_) do
    self:setSlotLab(value, k)
  end
end

function Cook_mainView:add()
  if self.maxNum_ == 0 then
    return
  end
  if self.curValue_ >= self.maxNum_ then
    return
  end
  self.curValue_ = self.curValue_ + 1
  self.slider_progress_.value = self.curValue_
  self:onRefreshNum()
end

function Cook_mainView:reduce()
  if self.maxNum_ == 0 then
    return
  end
  if self.curValue_ <= 1 then
    return
  end
  self.curValue_ = self.curValue_ - 1
  self.slider_progress_.value = self.curValue_
  self:onRefreshNum()
end

function Cook_mainView:setMax()
  if self.curValue_ >= self.slider_progress_.maxValue then
    return
  end
  self.curValue_ = self.maxNum_
  self.slider_progress_.value = self.curValue_
  self:onRefreshNum()
end

function Cook_mainView:openCamera(id)
  local idList = ZUtil.Pool.Collections.ZList_int.Rent()
  idList:Add(id)
  Z.CameraMgr:CameraInvokeByList(E.CameraState.Cooking, true, idList)
  ZUtil.Pool.Collections.ZList_int.Return(idList)
end

function Cook_mainView:closeCamera()
  local idList = ZUtil.Pool.Collections.ZList_int.Rent()
  Z.CameraMgr:CameraInvokeByList(E.CameraState.Cooking, false, idList)
  ZUtil.Pool.Collections.ZList_int.Return(idList)
end

function Cook_mainView:startClickAnimatedShow()
end

function Cook_mainView:startClickTogAnimatedShow()
end

function Cook_mainView:startLineTogAnimatedShow(isPlay)
  if isPlay then
  end
end

function Cook_mainView:startAnimatedShow()
end

function Cook_mainView:startAnimatedHide()
end

function Cook_mainView:OnDeActive()
  self:closeCamera()
  self:startAnimatedHide()
  self.vm_.SwitchEntityShow(true)
  self.cook_replace_sub_view:DeActive()
  self.selectId_ = 0
  self.currentItem_ = nil
  self.isDelete_ = false
  if self.foodLoopRect_ then
    self.foodLoopRect_:UnInit()
    self.foodLoopRect_ = nil
  end
  if self.recipeLoopRect_ then
    self.recipeLoopRect_:UnInit()
    self.recipeLoopRect_ = nil
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.itemViewList_ = {}
  if self.itemPackage_ then
    self.itemPackage_.Watcher:UnregWatcher(self.packageWatcherFunc_)
  end
  if self.cookListWatcherFunc_ then
    Z.ContainerMgr.CharSerialize.cookList.Watcher:UnregWatcher(self.cookListWatcherFunc_)
    self.cookListWatcherFunc_ = nil
  end
  Z.CommonTipsVM.CloseRichText()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.curSelectConfig_ = nil
  self.itemPackage_ = nil
  self.itemTipsView_:DeActive()
  self.packageWatcherFunc_ = nil
  self.currencyVm_.CloseCurrencyView(self)
end

return Cook_mainView
