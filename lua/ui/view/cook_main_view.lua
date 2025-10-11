local UI = Z.UI
local super = require("ui.ui_view_base")
local Cook_mainView = class("Cook_mainView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local randIconPath = "ui/atlas/cook/cook_prob_"
local cookItemLoopItem = require("ui.component.cook.cook_item_loop_item")
local lifeProfessionInfoGridItem = require("ui.component.life_profession.life_profession_info_grid_item")
local lifeManufacturePreviewItem = require("ui.component.life_profession.life_manufacture_preview_item")
local ResearchRecipeCraftEnergyConsume = Z.Global.ResearchRecipeCraftEnergyConsume[1]
local cook_replace_sub_view = require("ui.view.cook_replace_sub_view")
local scheduleSub = require("ui.view.node_schedule_sub_view")
local DefaultCameraId = 4000
local buffId = Z.Global.CookBuff
local currency_item_list = require("ui.component.currency.currency_item_list")
local LifeProfessionScreeningRightSubView = require("ui.view.life_profession_screening_right_sub_view")
local pagesType = {FastCook = 1, DevelopCookBook = 2}
local foodMaterialsSlotType = {
  pMaterials1 = 1,
  pMaterials2 = 2,
  aMaterials1 = 3,
  aMaterials2 = 4
}

function Cook_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cook_main")
  self.vm_ = Z.VMMgr.GetVM("cook")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemTipsView_ = require("ui.view.tips_item_info_popup_view").new()
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.cook_replace_sub_view = cook_replace_sub_view.new(self)
  self.scheduleSubView_ = scheduleSub.new(self)
  self.lifeMenufactorData_ = Z.DataMgr.Get("life_menufacture_data")
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
  self.tipsContent_ = self.node_right_.tips_content
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
    [foodMaterialsSlotType.pMaterials2] = self.food_node_item_.node_item_2,
    [foodMaterialsSlotType.aMaterials1] = self.food_node_item_.node_item_3,
    [foodMaterialsSlotType.aMaterials2] = self.food_node_item_.node_item_4
  }
  self.recipeSlotNode_ = {
    [foodMaterialsSlotType.pMaterials1] = self.recipe_node_item_.node_item_1,
    [foodMaterialsSlotType.pMaterials2] = self.recipe_node_item_.node_item_2,
    [foodMaterialsSlotType.aMaterials1] = self.recipe_node_item_.node_item_3,
    [foodMaterialsSlotType.aMaterials2] = self.recipe_node_item_.node_item_4
  }
  self.cookFoodTypeMax_ = Z.Global.CookLimit[1]
  self.cookFoodNumMax_ = Z.Global.CookLimit[2]
  self.cookLevelLab_ = self.uiBinder.lab_level_num
  self.levelBtn_ = self.uiBinder.btn_level
  self.scheduleNode_ = self.uiBinder.node_schedule
  self.moduleNode_ = self.node_right_.node_num_module
  self.moneyNode_ = self.node_right_.img_money
  self.maskNode_ = self.uiBinder.node_click_mask
  self.loop_preview = self.uiBinder.node_right.loop_list_item
end

function Cook_mainView:initBtns()
  self.slider_progress_:AddListener(function(value)
    self.curValue_ = math.floor(value + 0.1)
    self:onRefreshNum()
  end)
  self:AddClick(self.levelBtn_, function()
    self.lifeProfessionVM_.OpenLifeProfessionInfoView(E.ELifeProfession.Cook)
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
    local lifeProfessionRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(E.ELifeProfession.Cook)
    if lifeProfessionRow then
      Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(lifeProfessionRow.HelpId)
    end
  end)
  self:AddAsyncClick(self.fast_cook_btn_, function()
    if self.maxNum_ == 0 then
      if self.curSelectConfig_.Cost[2] > self.itemsVM_.GetItemTotalCount(E.CurrencyType.Vitality) or self.craftEnergyConsume_ > self.itemsVM_.GetItemTotalCount(E.CurrencyType.Vitality) then
        Z.TipsVM.ShowTips(7201)
        return
      end
      if not self.isCanCooking_ then
        Z.TipsVM.ShowTips(1002000)
        return
      end
      return
    end
    if not self.curSelectConfig_ or self.curValue_ == 0 then
      return
    end
    for index, configId in pairs(self.recipeSlotData_) do
      local cookMaterialRow = Z.TableMgr.GetRow("CookMaterialTableMgr", configId)
      if cookMaterialRow then
        local isUnlcok = Z.ConditionHelper.CheckCondition({
          cookMaterialRow.UseCondition
        }, true)
        if not isUnlcok then
          return
        end
      end
    end
    if self.entity_ then
      Z.LuaBridge.AddZEntityClientBuff(self.entity_, buffId)
      self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.cookClipPath_))
    end
    local func = function(isFinish)
      Z.CoroUtil.create_coro_xpcall(function()
        local mainMaterials = {
          self.recipeSlotData_[foodMaterialsSlotType.pMaterials1],
          self.recipeSlotData_[foodMaterialsSlotType.pMaterials2]
        }
        local cookMethods = {
          self.recipeSlotData_[foodMaterialsSlotType.aMaterials1],
          self.recipeSlotData_[foodMaterialsSlotType.aMaterials2]
        }
        local errId = self.vm_.AsyncFastCook(self.curSelectConfig_.Id, 1, mainMaterials, cookMethods, self.cancelSource:CreateToken())
        if errId ~= 0 then
          self.scheduleSubView_:StopTime()
        else
          self:refreshMiddleInfo()
        end
        Z.AudioMgr:Play("UI_Event_LifeProfession_Success")
        if isFinish then
          self.uiBinder.effect_cook_pre:SetEffectGoVisible(false)
          self.uiBinder.effect_cook:SetEffectGoVisible(false)
          self.uiBinder.effect_cook_end:SetEffectGoVisible(true)
          self.uiBinder.effect_cook_end:Play()
        else
          Z.AudioMgr:Play("UI_Event_LifeProfession_Success")
        end
      end)()
    end
    local everyTimeFinishFunc = function()
      self.curValue_ = self.curValue_ - 1
      func(false)
      self.slider_progress_.value = self.curValue_
      Z.LuaBridge.AddZEntityClientBuff(self.entity_, buffId)
    end
    local stopFunc = function()
      self:setCookState(false)
      if self.entity_ then
        Z.LuaBridge.DeleteZEntityClientBuff(self.entity_, buffId)
        self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.idelClipPath_))
      end
      self:refreshMiddleInfo()
    end
    local finishFunc = function()
      func(true)
      stopFunc()
    end
    self.scheduleSubView_:Active({
      num = self.curValue_,
      des = Lang("Cooking"),
      everyTimeFinishFunc = everyTimeFinishFunc,
      finishFunc = finishFunc,
      stopFunc = stopFunc,
      stopLabContent = Lang("StopCook"),
      time = self.lifeProfessionVM_.GetLifeManufactureCost(E.ELifeProfession.Cook)
    }, self.scheduleNode_.transform)
    self:setCookState(true)
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
      self.foodSlotData_[foodMaterialsSlotType.pMaterials1],
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials2]
    })
    local cookMethods = table.zvalues({
      self.foodSlotData_[foodMaterialsSlotType.aMaterials1],
      self.foodSlotData_[foodMaterialsSlotType.aMaterials2]
    })
    self.vm_.AsyncRdCook(mainMaterials, cookMethods, self.cancelSource:CreateToken())
  end)
  
  function self.packageWatcherFunc_(package, dirtyKeys)
    self:refreshLoopGridView()
    self:refreshNumComp()
  end
  
  function self.cookListWatcherFunc_(package, dirtyKeys)
    if self.curPages_ == pagesType.FastCook then
      self:initFastCookItem()
    end
  end
  
  function self.lifeProfessionWatcherFunc_(package, dirtyKeys)
    if dirtyKeys.professionInfo then
      self:refreshLevelLab()
    end
  end
  
  Z.ContainerMgr.CharSerialize.lifeProfession.Watcher:RegWatcher(self.lifeProfessionWatcherFunc_)
  Z.ContainerMgr.CharSerialize.cookList.Watcher:RegWatcher(self.cookListWatcherFunc_)
  Z.ItemEventMgr.Register(E.ItemChangeType.Change, E.ItemAddEventType.ItemId, E.CurrencyType.Vitality, self.packageWatcherFunc_)
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
  self:AddClick(self.recipeSlotNode_[foodMaterialsSlotType.pMaterials2].btn_refresh, function()
    if #self.materialBRefreshData_ > 0 then
      self.cook_replace_sub_view:Active({
        type = foodMaterialsSlotType.pMaterials2,
        data = self.materialBRefreshData_
      }, self.recipeSlotNode_[foodMaterialsSlotType.pMaterials2].node_tips.transform)
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
    self.lifeProfessionData_:SetFilterName(E.ELifeProfession.Cook, text)
    self:refreshLoopGridView()
  end, true)
  
  function self.screenCloseFunc()
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening.isOn = false
    self:refreshLoopGridView()
  end
  
  self.uiBinder.tog_screening:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right.Trans, false)
      self.screeningRightSubView_:Active({
        proID = E.ELifeProfession.Cook,
        closeFunc = self.screenCloseFunc
      }, self.uiBinder.node_right_sub, self)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    else
      self.screeningRightSubView_:DeActive()
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right.Trans, true)
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      local hasFilter = self.lifeProfessionData_:HasFilterChanged(E.ELifeProfession.Cook)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
    end
  end)
end

function Cook_mainView:RefreshInfo()
  self:refreshLoopGridView()
end

function Cook_mainView:setCookState(isCooking)
  self.isCooking_ = isCooking
  if self.isCooking_ then
    Z.AudioMgr:Play("UI_Event_LifeProfession_Cook_Start")
    self.uiBinder.effect_cook_end:SetEffectGoVisible(false)
    self.uiBinder.effect_cook_pre:SetEffectGoVisible(false)
    self.uiBinder.effect_cook:SetEffectGoVisible(true)
    self.uiBinder.effect_cook:Play()
  else
    self.uiBinder.effect_cook_pre:SetEffectGoVisible(false)
    self.uiBinder.effect_cook_end:SetEffectGoVisible(false)
    self.uiBinder.effect_cook:SetEffectGoVisible(false)
  end
  self.uiBinder.Ref:SetVisible(self.maskNode_, isCooking)
  self.uiBinder.Ref:SetVisible(self.scheduleNode_, isCooking)
  self.node_right_.Ref:SetVisible(self.moneyNode_, not isCooking)
  self.moduleNode_.Ref.UIComp:SetVisible(not isCooking)
  self.node_right_.Ref:SetVisible(self.fast_cook_btn_, not isCooking)
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
  if self.viewData.camID ~= DefaultCameraId then
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
  self.unitTokens_ = {}
  self.buffUnits_ = {}
  self.isCooking_ = false
  self.isRefreshSelected_ = true
  self.curPages_ = 0
  local cameraId = DefaultCameraId
  if self.viewData and self.viewData.camID then
    cameraId = self.viewData.camID
  end
  self.cameraInvokeId_ = {
    [pagesType.FastCook] = self.viewData.slowCam and cameraId + 2 or cameraId + 4,
    [pagesType.DevelopCookBook] = self.viewData.slowCam and cameraId + 1 or cameraId + 3
  }
end

function Cook_mainView:initUi()
  self:setCookState(false)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId
  })
  self:clearFoodSlotData()
  self:clearRecipeSlotData()
  if Z.IsPCUI then
    self.foodLoopRect_ = loopGridView.new(self, self.loop_food_item_, cookItemLoopItem, "cook_item_long_pc")
    self.recipeLoopRect_ = loopGridView.new(self, self.loop_recipe_item, lifeProfessionInfoGridItem, "com_item_square_1_8")
    self.previewList = loopListView.new(self, self.loop_preview, lifeManufacturePreviewItem, "cook_main_probability_item_tpl_pc")
  else
    self.foodLoopRect_ = loopGridView.new(self, self.loop_food_item_, cookItemLoopItem, "cook_item_long")
    self.recipeLoopRect_ = loopGridView.new(self, self.loop_recipe_item, lifeProfessionInfoGridItem, "com_item_square_1")
    self.previewList = loopListView.new(self, self.loop_preview, lifeManufacturePreviewItem, "cook_main_probability_item_tpl")
  end
  self.foodLoopRect_:Init({})
  self.foodLoopRect_:SetCanMultiSelected(true)
  self.previewList:Init({})
  self.recipeLoopRect_:Init({})
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", E.CurrencyType.Vitality)
  if itemRow then
    local itemsVm = Z.VMMgr.GetVM("items")
    self.rimg_money_icon_:SetImage(itemsVm.GetItemIcon(itemRow.Id))
    self.food_ring_icon_:SetImage(itemsVm.GetItemIcon(itemRow.Id))
  end
  self.food_lab_num_.text = ResearchRecipeCraftEnergyConsume
  self:refreshLevelLab()
end

function Cook_mainView:OnActive()
  self.screeningRightSubView_ = LifeProfessionScreeningRightSubView.new(self)
  self.lifeMenufactorData_:ResetSelectProductions(false)
  Z.UIMgr:FadeIn({IsInstant = true, TimeOut = 0.3})
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.vm_.SwitchEntityShow(false)
  self:initData()
  self:initWidget()
  self:initBtns()
  self:initAnimClip()
  self:getEntity()
  local cameraId = DefaultCameraId
  if self.viewData and self.viewData.camID then
    cameraId = self.viewData.camID
  end
  self:openCamera(cameraId)
  self:initUi()
  self:initPages()
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = ""
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cook)
  self.uiBinder.effect_cook:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cook_pre)
  self.uiBinder.effect_cook_pre:Stop()
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.effect_cook_end)
  self.uiBinder.effect_cook_end:Stop()
end

function Cook_mainView:refreshLevelLab()
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfession.professionInfo
  if not professionInfo[E.ELifeProfession.Cook] then
    self.cookLevelLab_.text = 0
    return
  end
  self.cookLevelLab_.text = professionInfo[E.ELifeProfession.Cook].level
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
  self:SetUIVisible(self.uiBinder.node_filter_root, not DevelopCookBook)
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = ""
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
  local hasFilter = self.lifeProfessionData_:HasFilterChanged(E.ELifeProfession.Cook)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
  self.loopItemDatas_ = self.vm_.GetUnLockCookBookList()
  local isHaveBookItem = #self.loopItemDatas_ > 0
  self.node_right_.Ref.UIComp:SetVisible(isHaveBookItem)
  self.uiBinder.Ref:SetVisible(self.cont_tips_, isHaveBookItem)
  self.cont_empty_.Ref.UIComp:SetVisible(#self.loopItemDatas_ == 0)
  self.recipeLoopRect_:RefreshListView(self.loopItemDatas_)
  if not self.isCooking_ and self.isRefreshSelected_ then
    self.isRefreshSelected_ = false
    self.recipeLoopRect_:ClearAllSelect()
    self:clearRecipeSlotData()
    if self.selectedRecipeIndex_ == 0 or self.selectedRecipeIndex_ == nil then
      self.selectedRecipeIndex_ = 1
    end
    self.recipeLoopRect_:SetSelected(self.selectedRecipeIndex_)
  end
end

function Cook_mainView:initDevelopCookBoolItem()
  self.loopItemDatas_ = self.vm_.GetCookFoodItems()
  self.cont_empty_.Ref.UIComp:SetVisible(#self.loopItemDatas_ == 0)
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
    if self.foodSlotData_[foodMaterialsSlotType.pMaterials1] and self.foodSlotData_[foodMaterialsSlotType.pMaterials2] then
      Z.TipsVM.ShowTips(1002002)
      return false
    end
    if self.foodSlotData_[foodMaterialsSlotType.pMaterials1] then
      slotIndex = foodMaterialsSlotType.pMaterials2
    else
      slotIndex = foodMaterialsSlotType.pMaterials1
    end
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
  if not self.foodSlotData_[foodMaterialsSlotType.pMaterials1] and not self.foodSlotData_[foodMaterialsSlotType.pMaterials2] then
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
  local bind2 = self.recipeSlotNode_[foodMaterialsSlotType.pMaterials2]
  bind1.Ref:SetVisible(bind1.btn_refresh, false)
  bind2.Ref:SetVisible(bind2.btn_refresh, false)
  self.mainMaterialA_ = nil
  self.mainMaterialB_ = nil
  for k, v in ipairs(self.recipeSlotNode_) do
    self:setSlotNode(v)
    self.recipeSlotData_[k] = nil
    v.Ref:SetVisible(v.lab_amount, false)
  end
  self.recipeSlotData_ = {}
end

function Cook_mainView:getMainMaterialRefreshData()
  local bind1 = self.recipeSlotNode_[foodMaterialsSlotType.pMaterials1]
  local bind2 = self.recipeSlotNode_[foodMaterialsSlotType.pMaterials2]
  if self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] and self.mainMaterialA_ then
    self.materialARefreshData_ = self.vm_.GetFilterCookMaterialData(self.mainMaterialA_, self.recipeSlotData_[foodMaterialsSlotType.pMaterials1])
    bind1.Ref:SetVisible(bind1.btn_refresh, #self.materialARefreshData_ > 0)
  else
    bind1.Ref:SetVisible(bind1.btn_refresh, false)
  end
  if self.recipeSlotData_[foodMaterialsSlotType.pMaterials2] and self.mainMaterialB_ then
    self.materialBRefreshData_ = self.vm_.GetFilterCookMaterialData(self.mainMaterialB_, self.recipeSlotData_[foodMaterialsSlotType.pMaterials2])
    bind2.Ref:SetVisible(bind2.btn_refresh, 0 < #self.materialBRefreshData_)
  else
    bind2.Ref:SetVisible(bind2.btn_refresh, false)
  end
end

function Cook_mainView:OnSelectItem(menufactureProductData, index)
  local lifeMenufactureData = Z.DataMgr.Get("life_menufacture_data")
  local curSelectProduct = lifeMenufactureData:GetCurSelectProductID(menufactureProductData.productId)
  local data = Z.TableMgr.GetRow("LifeProductionListTableMgr", curSelectProduct)
  self:clearRecipeSlotData()
  local isPrincipal = data.NeedMaterialType == 1
  self.selectedRecipeIndex_ = index
  if isPrincipal then
    if data.NeedMaterial[1] and data.NeedMaterial[1][1] and data.NeedMaterial[1][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = data.NeedMaterial[1][1]
    end
    if data.NeedMaterial[2] and data.NeedMaterial[2][1] and data.NeedMaterial[2][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials2] = data.NeedMaterial[2][1]
    end
    if data.NeedMaterial[3] and data.NeedMaterial[3][1] and data.NeedMaterial[3][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials1] = data.NeedMaterial[3][1]
    end
    if data.NeedMaterial[4] and data.NeedMaterial[4][1] and data.NeedMaterial[4][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials2] = data.NeedMaterial[4][1]
    end
  else
    if data.NeedMaterial[1] and data.NeedMaterial[1][1] and data.NeedMaterial[1][1] ~= 0 then
      self.mainMaterialA_ = data.NeedMaterial[1][1]
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = self.vm_.GetRecipeIdByTypeId(data.NeedMaterial[1][1])
    end
    if data.NeedMaterial[2] and data.NeedMaterial[2][1] and data.NeedMaterial[2][1] ~= 0 then
      self.mainMaterialB_ = data.NeedMaterial[2][1]
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials2] = self.vm_.GetRecipeIdByTypeId(data.NeedMaterial[2][1])
    end
    if data.NeedMaterial[3] and data.NeedMaterial[3][1] and data.NeedMaterial[3][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials1] = self.vm_.GetRecipeIdByTypeId(data.NeedMaterial[3][1])
    end
    if data.NeedMaterial[4] and data.NeedMaterial[4][1] and data.NeedMaterial[4][1] ~= 0 then
      self.recipeSlotData_[foodMaterialsSlotType.aMaterials2] = self.vm_.GetRecipeIdByTypeId(data.NeedMaterial[4][1])
    end
  end
  self:getMainMaterialRefreshData()
  self:onSelectCookItem(data)
  self:refreshRightTips()
  self:refreshMiddleInfo()
end

function Cook_mainView:refreshMiddleInfo()
  for k, value in ipairs(self.recipeSlotNode_) do
    self:setSlotNode(value, self.recipeSlotData_[k])
    self:setSlotLab(value, k)
    value.Ref:SetVisible(value.lab_amount, self.recipeSlotData_[k] ~= nil)
  end
  self:refreshNumComp()
end

function Cook_mainView:refreshNumComp()
  self.maxNum_ = self.vm_.GetExchangeNum(self.recipeSlotData_[foodMaterialsSlotType.pMaterials1], self.recipeSlotData_[foodMaterialsSlotType.pMaterials2], self.recipeSlotData_[foodMaterialsSlotType.aMaterials1], self.recipeSlotData_[foodMaterialsSlotType.aMaterials2], self.curSelectConfig_)
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
  self.tipsName_.text = self.curSelectConfig_.Name
  self.tipsIcon_:SetImage(self.curSelectConfig_.Icon)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.lab_info_, self.curSelectConfig_.Des)
  self.img_bg_quality_:SetColor(Z.ConstValue.QualityBgColor[self.curSelectConfig_.Quality])
  local configRow = Z.TableMgr.GetRow("ItemTableMgr", self.curSelectConfig_.RelatedItemId)
  if configRow then
    local typeRow = Z.TableMgr.GetRow("ItemTypeTableMgr", configRow.Type)
    if typeRow then
      self.labType_.text = typeRow.Name
    end
  end
  for name, unit in pairs(self.buffUnits_) do
    self:RemoveUiUnit(name)
  end
  local path = Z.IsPCUI and "ui/prefabs/cook/cook_main_buffdesc_item_tpl_pc" or "ui/prefabs/cook/cook_main_buffdesc_item_tpl"
  local buffDatas = self.vm_.GetBuffDesById(self.curSelectConfig_.RelatedItemId)
  if buffDatas and buffDatas ~= "" then
    for index, token in pairs(self.unitTokens_) do
      Z.CancelSource.ReleaseToken(token)
    end
    self.unitTokens_ = {}
    Z.CoroUtil.create_coro_xpcall(function()
      local unitName = "buffDes"
      local token = self.cancelSource:CreateToken()
      self.unitTokens_[unitName] = token
      local unit = self:AsyncLoadUiUnit(path, unitName, self.tipsContent_.transform, token)
      if unit then
        self.buffUnits_[unitName] = unit
        Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(unit.lab_info, buffDatas)
        self.lab_info_.transform:SetSiblingIndex(1)
        self.unitTokens_[unitName] = nil
      end
    end)()
  end
  local allRewards = {}
  local fixedAwardPackage = self.curSelectConfig_.Award
  for k, v in pairs(fixedAwardPackage) do
    table.insert(allRewards, v)
  end
  local specialRewardID
  for k, v in pairs(self.curSelectConfig_.SpecialAward) do
    if self.lifeProfessionVM_.IsSpecializationUnlocked(E.ELifeProfession.Cook, v[2]) then
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

function Cook_mainView:setSlotLab(slot, index)
  local configId = self.recipeSlotData_[index]
  if configId == nil or configId == 0 then
    return
  end
  local haveCount = self.itemsVM_.GetItemTotalCount(configId)
  local consumeCount = self.curValue_ * (self.curSelectConfig_.NeedMaterial[index][2] or 0)
  if self.curValue_ == 0 then
    consumeCount = self.curSelectConfig_.NeedMaterial[index][2] or 0
  end
  if haveCount < consumeCount then
    slot.lab_amount.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsRed) .. "/" .. consumeCount
  else
    slot.lab_amount.text = Z.RichTextHelper.ApplyStyleTag(haveCount, E.TextStyleTag.TipsGreen) .. "/" .. consumeCount
  end
  self.craftEnergyConsume_ = self.curValue_ * self.curSelectConfig_.Cost[2]
  self.lab_money_num_.text = self.craftEnergyConsume_
end

function Cook_mainView:setSlotNode(slot, configId)
  if slot == nil then
    return
  end
  slot.Ref:SetVisible(slot.group_item, configId ~= nil and configId ~= 0)
  if configId and configId ~= 0 then
    local cookMaterialRow = Z.TableMgr.GetRow("CookMaterialTableMgr", configId)
    if cookMaterialRow then
      do
        local conditionDescList = Z.ConditionHelper.GetConditionDescList({
          cookMaterialRow.UseCondition
        })
        if conditionDescList and 0 < #conditionDescList and conditionDescList[1].IsUnlock == false then
          slot.Ref:SetVisible(slot.btn_nature, true)
        else
          slot.Ref:SetVisible(slot.btn_nature, false)
        end
        slot.btn_nature:AddListener(function()
          Z.ConditionHelper.CheckCondition({
            cookMaterialRow.UseCondition
          }, true)
        end, true)
        local itemTableBase = Z.TableMgr.GetRow("ItemTableMgr", configId)
        if itemTableBase then
          local itemsVm = Z.VMMgr.GetVM("items")
          slot.rimg_icon:SetImage(itemsVm.GetItemIcon(configId))
          slot.img_mask:SetImage(Z.ConstValue.QualityImgCircleBg .. itemTableBase.Quality)
        end
      end
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
  if type == foodMaterialsSlotType.pMaterials1 then
    local p2ConfigId = self.recipeSlotData_[foodMaterialsSlotType.pMaterials2]
    if data.Id == p2ConfigId then
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials2] = lastConfigId
    end
  elseif type == foodMaterialsSlotType.pMaterials2 then
    local p1ConfigId = self.recipeSlotData_[foodMaterialsSlotType.pMaterials1]
    if data.Id == p1ConfigId then
      self.recipeSlotData_[foodMaterialsSlotType.pMaterials1] = lastConfigId
    end
  end
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
  Z.CameraMgr:CameraInvoke(E.CameraState.Cooking, false)
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
  self.scheduleSubView_:DeActive()
  if self.entity_ then
    Z.LuaBridge.DeleteZEntityClientBuff(self.entity_, buffId)
    self.entity_.Model:SetLuaAttr(Z.ModelAttr.EModelAnimObjState, Z.AnimObjData.Rent(self.idelClipPath_))
  end
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
  if self.previewList then
    self.previewList:UnInit()
    self.previewList = nil
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.itemViewList_ = {}
  if self.itemPackage_ then
    self.itemPackage_.Watcher:UnregWatcher(self.packageWatcherFunc_)
  end
  if self.cookListWatcherFunc_ then
    Z.ContainerMgr.CharSerialize.cookList.Watcher:UnregWatcher(self.cookListWatcherFunc_)
    Z.ItemEventMgr.Remove(E.ItemChangeType.Change, E.ItemAddEventType.ItemId, E.CurrencyType.Vitality, self.packageWatcherFunc_)
    self.cookListWatcherFunc_ = nil
  end
  if self.lifeProfessionWatcherFunc_ then
    Z.ContainerMgr.CharSerialize.lifeProfession.Watcher:UnregWatcher(self.lifeProfessionWatcherFunc_)
    self.lifeProfessionWatcherFunc_ = nil
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
  self.viewData.slowCam = false
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  self:SetUIVisible(self.uiBinder.img_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  if self.screeningRightSubView_ then
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    self.screeningRightSubView_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_right.Trans, true)
  self.lifeProfessionData_:ClearFilterDatas()
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cook)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cook_end)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.effect_cook_pre)
end

return Cook_mainView
