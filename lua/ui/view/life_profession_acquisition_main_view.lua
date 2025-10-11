local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_acquisition_mainView = class("Life_profession_acquisition_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local leftTogItem = require("ui.component.life_profession.life_profession_left_tog_item")
local gradeItem = require("ui.component.life_profession.life_profession_grade_item")
local LifeProfessionCollectionRightSubView = require("ui.view.life_profession_collection_right_sub_view")
local LifeProfessionManufactureRightSubView = require("ui.view.life_profession_manufacture_right_sub_view")
local LifeProfessionScreeningRightSubView = require("ui.view.life_profession_screening_right_sub_view")
local LifeProfessionspecializationRightSubView = require("ui.view.life_profession_specialization_right_sub_view")
local lifeInfoGridItem = require("ui.component.life_profession.life_profession_info_grid_item")
local lifeInfoListGridItem = require("ui.component.life_profession.life_profession_info_list_grid_item")
local currency_item_list = require("ui.component.currency.currency_item_list")
local SpecTreePrefabPath = "ui/prefabs/life_profession/life_career_%s"
local COLOR_NORMAL = Color.New(1, 1, 1, 1)
local COLOR_LOCK = Color.New(1, 1, 1, 0.2)

function Life_profession_acquisition_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_acquisition_main")
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.lifeMenufactureData_ = Z.DataMgr.Get("life_menufacture_data")
  self.Profession2SubView = {
    [E.ELifeProfessionMainType.Collection] = {infoSubView = LifeProfessionCollectionRightSubView},
    [E.ELifeProfessionMainType.Manufacture] = {infoSubView = LifeProfessionManufactureRightSubView},
    [E.ELifeProfessionMainType.Cook] = {infoSubView = LifeProfessionManufactureRightSubView}
  }
end

function Life_profession_acquisition_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.lifeMenufactureData_:ResetSelectProductions(true)
  self.screeningRightSubView_ = LifeProfessionScreeningRightSubView.new(self)
  self.specializationRightSubView_ = LifeProfessionspecializationRightSubView.new(self)
  self:InitBinder()
  self.proDataList = self.lifeProfessionVM.GetAllSortedProfessions()
  if self.viewData then
    self.curProID = self.viewData.proID
  else
    self.curProID = self.proDataList[1].ProId
  end
  self:Init()
  self:InitBtnClick()
  self:bindEvents()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  self:resetSearchName()
end

function Life_profession_acquisition_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecChanged, self.lifeProfessionSpecChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, self.refreshRP, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetLevelChanged, self.refreshRP, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionTargetStateChanged, self.refreshRP, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionUnlocked, self.lifeProfessionUnlocked, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSubFormulaChanged, self.lifeProfessionSubFormulaChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionSpecLevelUp, self.LifeProfessionSpecLevelUp, self)
end

function Life_profession_acquisition_mainView:lifeProfessionSubFormulaChanged()
  if self.curList then
    local curIndex = self.curList:GetSelectedIndex()
    self.curList:RefreshItemByItemIndex(curIndex)
  end
end

function Life_profession_acquisition_mainView:lifeProfessionSpecChanged(proID)
  if self.curProID == proID and self.treeUnit then
    self:refreshSpecializationTree(self.treeUnit)
    self:refreshRP()
  end
end

function Life_profession_acquisition_mainView:LifeProfessionSpecLevelUp(speID)
  if self.curSelectedPointUnit then
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.curSelectedPointUnit.node_effect)
    self.curSelectedPointUnit.node_effect:CreatEFFGO("ui/uieffect/prefab/ui_sfx_life_profession_cast_main/ui_sfx_group_life_profession_hit_001", Vector3.zero)
    self.curSelectedPointUnit.node_effect:SetEffectGoVisible(true)
    Z.AudioMgr:Play("UI_Event_Career_Active")
  end
end

function Life_profession_acquisition_mainView:lifeProfessionUnlocked(proID)
  local index = 1
  for i = 1, #self.proDataList do
    if self.proDataList[i].ProId == proID then
      index = i
      break
    end
  end
  self.leftToggleListView_:ClearAllSelect()
  self.leftToggleListView_:MovePanelToItemIndex(index - 1)
  self.leftToggleListView_:SelectIndex(index - 1)
  self:refreshRP()
end

function Life_profession_acquisition_mainView:RefreshFirstOpen()
  if not self.viewData.selectToggle then
    self.viewData.selectToggle = 1
  end
  if self.viewData.isConsume == false then
    self.viewData.selectToggle = 2
  end
  self.uiBinder.btn_info:SetIsOnWithoutCallBack(self.viewData.selectToggle == 1)
  self.uiBinder.btn_info_noconsume:SetIsOnWithoutCallBack(self.viewData.selectToggle == 2)
  self.uiBinder.btn_specialization:SetIsOnWithoutCallBack(self.viewData.selectToggle == 3)
  self.uiBinder.btn_reward:SetIsOnWithoutCallBack(self.viewData.selectToggle == 4)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, self.viewData.selectToggle == 1 or self.viewData.selectToggle == 2)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization, self.viewData.selectToggle == 3)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization_btn, self.viewData.selectToggle == 3)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_target, self.viewData.selectToggle == 4)
end

function Life_profession_acquisition_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curInfoSubView_ then
    self.curInfoSubView_:DeActive()
    self.curInfoSubView_ = nil
  end
  if self.screeningRightSubView_ then
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    self.screeningRightSubView_ = nil
  end
  if self.specializationRightSubView_ then
    self.specializationRightSubView_:DeActive()
    self.specializationRightSubView_ = nil
  end
  if self.infoGridView then
    self.infoGridView:UnInit()
    self.infoGridView = nil
  end
  if self.infoListGridView then
    self.infoListGridView:UnInit()
    self.infoListGridView = nil
  end
  self.leftToggleListView_:UnInit()
  self.leftToggleListView_ = nil
  self.lifeProfessionData_:ClearFilterDatas()
  self:ClearAllUnits()
  self:unLoadSpecializationTree()
  self.rewardListView_:UnInit()
  Z.EventMgr:RemoveObjAll(self)
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  self.viewData.proID = self.curProID
  self.lifeProfessionData_:ClearFilterName()
end

function Life_profession_acquisition_mainView:resetSearchName()
  local filterName = self.lifeProfessionData_:GetFilterName(self.curProID)
  self:SetUIVisible(self.uiBinder.img_input_bg, filterName ~= nil and filterName ~= "")
  self:SetUIVisible(self.uiBinder.btn_search, filterName == nil or filterName == "")
  if filterName ~= nil and filterName ~= "" then
    self.uiBinder.input_search.text = filterName
  end
end

function Life_profession_acquisition_mainView:OnRefresh()
  if self.curProID then
    if self.treeUnit and self.treeUnit.manager then
      self.treeUnit.manager:UnInit()
    end
    self:RemoveUiUnit(tostring(self.curProID))
    self.treeUnit = nil
  end
  self:RefreshFirstOpen()
  self:RefreshLeft()
  self.uiBinder.tog_list.isOn = false
end

function Life_profession_acquisition_mainView:InitBinder()
  self.toggleList = {
    self.uiBinder.btn_info,
    self.uiBinder.btn_info_noconsume,
    self.uiBinder.btn_specialization,
    self.uiBinder.btn_reward
  }
end

function Life_profession_acquisition_mainView:InitBtnClick()
  self:AddClick(self.uiBinder.btn_ask, function()
    local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.curProID)
    if not lifeProfessionTableRow then
      return
    end
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(lifeProfessionTableRow.HelpId)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.lifeProfessionVM.CloseLifeProfessionInfoView()
  end)
  
  function self.screenCloseFunc()
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    self:RefreshInfo()
  end
  
  self.uiBinder.tog_screening:RemoveAllListeners()
  self.uiBinder.tog_screening:AddListener(function(isOn)
    if isOn then
      if self.curInfoSubView_ then
        self.curInfoSubView_:DeActive()
        self.curInfoSubView_ = nil
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, false)
      self.screeningRightSubView_:Active({
        proID = self.curProID,
        closeFunc = self.screenCloseFunc
      }, self.uiBinder.node_right_sub, self)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    else
      self.screeningRightSubView_:DeActive()
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      self:RefreshInfo()
      local hasFilter = self.lifeProfessionData_:HasFilterChanged(self.curProID)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
    end
  end)
  self.uiBinder.btn_info:RemoveAllListeners()
  self.uiBinder.btn_info:AddListener(function(isOn)
    if not isOn then
      self.uiBinder.btn_info:SetIsOnWithoutCallBack(true)
      return
    end
    self.isConsume = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization_btn, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_target, not isOn)
    if isOn then
      Z.AudioMgr:Play("sys_general_toggle")
      self:RefreshInfo()
      if self.specializationRightSubView_ then
        self.specializationRightSubView_:DeActive()
      end
      self:SetSpecializationOpen(false)
    end
    self.uiBinder.btn_specialization:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_reward:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_info_noconsume:SetIsOnWithoutCallBack(false)
    self.currencyItemList_:Init(self.uiBinder.currency_info, {})
    self.viewData.selectToggle = 1
  end)
  self.uiBinder.btn_info_noconsume:RemoveAllListeners()
  self.uiBinder.btn_info_noconsume:AddListener(function(isOn)
    if not isOn then
      self.uiBinder.btn_info_noconsume:SetIsOnWithoutCallBack(true)
      return
    end
    self.isConsume = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization_btn, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_target, not isOn)
    if isOn then
      Z.AudioMgr:Play("sys_general_toggle")
      self:RefreshInfo()
      if self.specializationRightSubView_ then
        self.specializationRightSubView_:DeActive()
      end
      self:SetSpecializationOpen(false)
    end
    self.uiBinder.btn_specialization:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_reward:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_info:SetIsOnWithoutCallBack(false)
    self.currencyItemList_:Init(self.uiBinder.currency_info, {})
    self.viewData.selectToggle = 2
  end)
  self.uiBinder.btn_specialization:RemoveAllListeners()
  self.uiBinder.btn_specialization:AddListener(function(isOn)
    if not isOn then
      self.uiBinder.btn_specialization:SetIsOnWithoutCallBack(true)
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization, isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization_btn, isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_target, not isOn)
    if isOn then
      Z.AudioMgr:Play("sys_general_toggle")
      self:RefreshSpecialization()
      if self.curInfoSubView_ then
        self.curInfoSubView_:DeActive()
        self.curInfoSubView_ = nil
      end
      self.screeningRightSubView_:DeActive()
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      if self.specializationRightSubView_ then
        self.specializationRightSubView_:DeActive()
      end
      self:SetSpecializationOpen(false)
      if not self.currencyItemList_ then
        self.currencyItemList_ = currency_item_list.new()
      end
      self.currencyItemList_:Init(self.uiBinder.currency_info, {
        Z.SystemItem.VigourItemId,
        self.lifeProfessionVM.GetSpcItemIDByProId()
      })
    end
    self.uiBinder.btn_info:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_reward:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_info_noconsume:SetIsOnWithoutCallBack(false)
    self.viewData.selectToggle = 2
  end)
  self.uiBinder.btn_reward:RemoveAllListeners()
  self.uiBinder.btn_reward:AddListener(function(isOn)
    if not isOn then
      self.uiBinder.btn_reward:SetIsOnWithoutCallBack(true)
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_specialization_btn, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_target, isOn)
    if isOn then
      Z.AudioMgr:Play("sys_general_toggle")
      self:RefreshReward()
      if self.curInfoSubView_ then
        self.curInfoSubView_:DeActive()
        self.curInfoSubView_ = nil
      end
      self.screeningRightSubView_:DeActive()
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
      if self.specializationRightSubView_ then
        self.specializationRightSubView_:DeActive()
      end
      self:SetSpecializationOpen(false)
    end
    self.uiBinder.btn_info:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_specialization:SetIsOnWithoutCallBack(false)
    self.uiBinder.btn_info_noconsume:SetIsOnWithoutCallBack(false)
    self.currencyItemList_:Init(self.uiBinder.currency_info, {})
    self.viewData.selectToggle = 3
  end)
  self.uiBinder.tog_list:AddListener(function(isOn)
    self.lifeProfessionData_:SetIsSimpleList(isOn)
    self:RefreshInfo()
  end, true)
  self:AddClick(self.uiBinder.btn_search, function()
    self:SetUIVisible(self.uiBinder.img_input_bg, true)
    self:SetUIVisible(self.uiBinder.btn_search, false)
    self.uiBinder.input_search.text = self.lifeProfessionData_:GetFilterName(self.curProID)
  end)
  self:AddClick(self.uiBinder.btn_close_search, function()
    self:SetUIVisible(self.uiBinder.img_input_bg, false)
    self:SetUIVisible(self.uiBinder.btn_search, true)
    self.uiBinder.input_search.text = ""
  end)
  self.uiBinder.input_search:AddListener(function(text)
    self.lifeProfessionData_:SetFilterName(self.curProID, text)
    self:RefreshInfo()
  end, true)
  self:AddAsyncClick(self.uiBinder.btn_reset_spec, function()
    local specializationGroupTable = self.lifeProfessionData_:GetSpe2GroupTable(self.curProID)
    local hasSpe = false
    for id, groupId in pairs(specializationGroupTable) do
      local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.curProID, id)
      if 0 < curLevel then
        hasSpe = true
      end
    end
    if not hasSpe then
      Z.TipsVM.ShowTips(1002059)
      return
    end
    self.lifeProfessionVM.AsyncResetSpec(self.curProID, self.cancelSource:CreateToken())
  end)
end

function Life_profession_acquisition_mainView:Init()
  local data = {}
  if Z.IsPCUI then
    self.leftToggleListView_ = loopListView.new(self, self.uiBinder.left_tog_scrollview, leftTogItem, "life_profession_left_tog_tpl_pc")
  else
    self.leftToggleListView_ = loopListView.new(self, self.uiBinder.left_tog_scrollview, leftTogItem, "life_profession_left_tog_tpl")
  end
  self.leftToggleListView_:Init(data)
  self:InitReward()
  self:InitInfoList()
end

function Life_profession_acquisition_mainView:RefreshLeft()
  self.proDataList = self.lifeProfessionVM.GetAllSortedProfessions()
  self.leftToggleListView_:RefreshListView(self.proDataList)
  if self.viewData then
    self.curProID = self.viewData.proID
  else
    self.curProID = self.proDataList[1].ProId
  end
  local index = 1
  for i = 1, #self.proDataList do
    if self.proDataList[i].ProId == self.curProID then
      index = i
      break
    end
  end
  self.leftToggleListView_:ClearAllSelect()
  self.leftToggleListView_:MovePanelToItemIndex(index - 1)
  self.leftToggleListView_:SelectIndex(index - 1)
end

function Life_profession_acquisition_mainView:refreshRP()
  local hasReward = self.lifeProfessionVM.GetRewardCanGainCnt(self.curProID) > 0
  local hasSpecRed = 0 < self.lifeProfessionVM.GetSpecCanUnlockCnt(self.curProID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot_spec, hasSpecRed)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot_reward, hasReward)
end

function Life_profession_acquisition_mainView:OnTogSelect(data)
  self:unLoadSpecializationTree()
  self.lastProID = self.curProID
  self.curProID = data.ProId
  if self.uiBinder.btn_info.isOn then
    self.isConsume = true
    self:RefreshInfo()
  end
  if self.uiBinder.btn_info_noconsume.isOn then
    self.isConsume = false
    self:RefreshInfo()
  end
  if self.uiBinder.btn_specialization.isOn then
    self:RefreshSpecialization()
  end
  if self.uiBinder.btn_reward.isOn then
    self:RefreshReward()
  end
  self.uiBinder.lab_name_1_consume.text = Lang("LifeProfessionInfoTitleConsume" .. self.curProID)
  self.uiBinder.lab_name_2_consume.text = Lang("LifeProfessionInfoTitleConsume" .. self.curProID)
  self.uiBinder.lab_name_1_noconsume.text = Lang("LifeProfessionInfoTitleNoConsume" .. self.curProID)
  self.uiBinder.lab_name_2_noconsume.text = Lang("LifeProfessionInfoTitleNoConsume" .. self.curProID)
  self:refreshRP()
  self:resetSearchName()
end

function Life_profession_acquisition_mainView:InitInfoList()
  local infoItem = Z.IsPCUI and "com_item_square_1_8" or "com_item_square_1"
  local infoListItem = Z.IsPCUI and "life_profession_acquisition_item_tpl_pc" or "life_profession_acquisition_item_tpl"
  local data = {}
  self.infoGridView = loopGridView.new(self, self.uiBinder.info_scrollview, lifeInfoGridItem, infoItem)
  self.infoListGridView = loopGridView.new(self, self.uiBinder.info_scrollView_long, lifeInfoListGridItem, infoListItem)
  self.infoGridView:Init(data)
  self.infoListGridView:Init(data)
end

function Life_profession_acquisition_mainView:RefreshInfo()
  local hasFilter = self.lifeProfessionData_:HasFilterChanged(self.curProID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
  local isSimpleList = self.lifeProfessionData_:GetIsSimpleList()
  self.uiBinder.tog_list:SetIsOnWithoutCallBack(isSimpleList)
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.curProID)
  if not lifeProfessionTableRow then
    self:refreshEmpty()
    return
  end
  if not table.zcontainsKey(self.Profession2SubView, lifeProfessionTableRow.Type) then
    self:refreshEmpty()
    return
  end
  self.productionList = self.lifeProfessionVM.GetLifeProfessionProductnfo(self.curProID, self.isConsume)
  if self.productionList == nil then
    self:refreshEmpty()
    return
  end
  if #self.productionList == 0 then
    self:refreshEmpty()
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.info_scrollview, isSimpleList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.info_scrollView_long, not isSimpleList)
  self.infoGridView:ClearAllSelect()
  self.infoListGridView:ClearAllSelect()
  self.curList = isSimpleList and self.infoGridView or self.infoListGridView
  self.curList:RefreshListView(self.productionList)
  self:refreshSelect()
end

function Life_profession_acquisition_mainView:refreshEmpty()
  if self.curInfoSubView_ then
    self.curInfoSubView_:DeActive()
    self.curInfoSubView_ = nil
  end
  self.screeningRightSubView_:DeActive()
  self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.info_scrollview, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.info_scrollView_long, false)
end

function Life_profession_acquisition_mainView:refreshSelect()
  if self.viewData.productionID then
    self.curItemData = nil
  end
  if self.curItemData == nil then
    if self.viewData and self.viewData.productionID then
      for k, v in pairs(self.productionList) do
        local configData
        if v.lifeType == E.ELifeProfessionMainType.Collection then
          configData = Z.TableMgr.GetRow("LifeCollectListTableMgr", v.productId)
          if configData.Id == self.viewData.productionID then
            self.curList:SelectIndex(k - 1)
            self.curList:MovePanelToItemIndex(k - 1)
          end
        else
          configData = Z.TableMgr.GetRow("LifeProductionListTableMgr", v.productId)
          local curConfigData = Z.TableMgr.GetRow("LifeProductionListTableMgr", self.viewData.productionID)
          local productId = self.viewData.productionID
          if curConfigData.ParentId > 0 then
            productId = curConfigData.ParentId
          end
          if productId == v.productId then
            self.viewData.productionID = nil
            self.curList:SelectIndex(k - 1)
            self.curList:MovePanelToItemIndex(k - 1)
            return
          end
        end
      end
    else
      self.curList:SelectIndex(0)
    end
    self.viewData.productionID = nil
    return
  end
  for k, v in pairs(self.productionList) do
    local configData
    if v.lifeType == E.ELifeProfessionMainType.Collection then
      configData = Z.TableMgr.GetRow("LifeCollectListTableMgr", v.productId)
    else
      configData = Z.TableMgr.GetRow("LifeProductionListTableMgr", v.productId)
    end
    if configData.Id == self.curItemData.Id then
      self.curList:SelectIndex(k - 1)
      self.curList:MovePanelToItemIndex(k - 1)
      return
    end
  end
  self.curList:MovePanelToItemIndex(0)
  self.curList:SelectIndex(0)
end

function Life_profession_acquisition_mainView:OnSelectItem(data)
  if data.lifeType == E.ELifeProfessionMainType.Collection then
    self.curItemData = Z.TableMgr.GetRow("LifeCollectListTableMgr", data.productId)
  else
    self.curItemData = Z.TableMgr.GetRow("LifeProductionListTableMgr", data.productId)
  end
  if self.curInfoSubView_ then
    self.curInfoSubView_:DeActive()
    self.curInfoSubView_ = nil
  end
  if self.uiBinder.tog_screening.isOn then
    self.screeningRightSubView_:DeActive()
    self.uiBinder.tog_screening:SetIsOnWithoutCallBack(false)
    local hasFilter = self.lifeProfessionData_:HasFilterChanged(self.curProID)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_has_change, hasFilter)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not hasFilter)
    if self.lifeProfessionData_:HasFilterChanged(self.curProID) then
      self.uiBinder.tog_screening:SetIsOnWithoutCallBack(true)
    end
  end
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.curProID)
  if not lifeProfessionTableRow then
    return
  end
  self.curInfoSubView_ = self.Profession2SubView[lifeProfessionTableRow.Type].infoSubView.new(self)
  if self.curInfoSubView_ then
    if data.lifeType == E.ELifeProfessionMainType.Collection then
      self.curInfoSubView_:Active({
        data = self.curItemData,
        isConsume = self.isConsume
      }, self.uiBinder.node_right_sub)
    else
      self.curInfoSubView_:Active({
        data = data,
        productionID = self.viewData.productionID
      }, self.uiBinder.node_right_sub)
    end
    self.viewData.productionID = nil
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
  end
end

function Life_profession_acquisition_mainView:RefreshSpecialization()
  if self.specializationRightSubView_ then
    self.specializationRightSubView_:DeActive()
    self.currencyItemList_:Init(self.uiBinder.currency_info, {
      Z.SystemItem.VigourItemId,
      self.lifeProfessionVM.GetSpcItemIDByProId()
    })
  end
  self:SetSpecializationOpen(false)
  self:loadSpecializationTree()
end

function Life_profession_acquisition_mainView:loadSpecializationTree()
  self:unLoadSpecializationTree()
  Z.CoroUtil.create_coro_xpcall(function()
    local treePath = string.format(SpecTreePrefabPath, self.curProID)
    local treeName = tostring(self.curProID)
    local treeUnit = self:AsyncLoadUiUnit(treePath, treeName, self.uiBinder.specialization_root)
    if treeUnit then
      self.treeUnit = treeUnit
      if self.treeUnit.manager then
        self.treeUnit.manager:InitByLua(E.SysDevelopTreeActiveType.Start)
      end
      treeUnit.Trans:SetAnchorPosition(140, 60)
      self.uiBinder.specialization_root:SetWidth(treeUnit.Trans.sizeDelta.x + 270)
      self.uiBinder.specialization_root:SetHeight(treeUnit.Trans.sizeDelta.y + 310)
      self:refreshSpecializationTree(treeUnit)
    end
  end)()
end

function Life_profession_acquisition_mainView:refreshSpecializationTree(treeUnit)
  self.specID2UnitTable = {}
  local activeNodes = {}
  local activeNodesCount = 0
  local specializationGroupTable = self.lifeProfessionData_:GetSpe2GroupTable(self.curProID)
  local isHaveManager = self.treeUnit.manager ~= nil
  local lifeFormulaTableMgr = Z.TableMgr.GetTable("LifeFormulaTableMgr")
  for id, groupId in pairs(specializationGroupTable) do
    local pointUnit = treeUnit[tostring(id)]
    if pointUnit then
      self.specID2UnitTable[id] = pointUnit
      self:refreshSpecializationPoint(id, groupId, pointUnit)
    end
    if isHaveManager then
      local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.curProID, id)
      local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.curProID, groupId)
      if curLevel >= maxLevel then
        activeNodesCount = activeNodesCount + 1
        activeNodes[activeNodesCount] = id
      end
    else
      local speConfig = lifeFormulaTableMgr.GetRow(id)
      local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.curProID, id)
      local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.curProID, groupId)
      local isActive = curLevel >= maxLevel
      for i = 1, #speConfig.NextNodes do
        local nextNode = speConfig.NextNodes[i]
        local lineUnit = treeUnit[string.zconcat(id, "_", nextNode)]
        if lineUnit ~= nil then
          lineUnit.Ref:SetVisible(lineUnit.img_line, isActive)
        end
      end
    end
  end
  if self.treeUnit.manager then
    self.treeUnit.manager:SetActiveNodes(activeNodes)
  end
end

function Life_profession_acquisition_mainView:refreshSpecializationPoint(id, groupId, pointUnit)
  local isActive = self.lifeProfessionVM.IsSpecializationUnlocked(self.curProID, id)
  local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.curProID, id)
  local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.curProID, groupId)
  pointUnit.Ref:SetVisible(pointUnit.img_active, isActive and curLevel == maxLevel)
  pointUnit.Ref:SetVisible(pointUnit.img_bg, isActive and curLevel ~= maxLevel)
  local ColorInactive = Color.New(0.6274509803921569, 0.6274509803921569, 0.6274509803921569, 1)
  local ColorActive = Color.New(0.807843137254902, 0.6588235294117647, 0.5058823529411764, 1)
  pointUnit.img_frame_pc.color = isActive and ColorActive or ColorInactive
  pointUnit.img_frame_not_pc.color = isActive and ColorActive or ColorInactive
  pointUnit.Ref:SetVisible(pointUnit.img_unlock, not isActive)
  pointUnit.Ref:SetVisible(pointUnit.img_select, self.curSelectSpecializationID ~= nil and id == self.curSelectSpecializationID)
  local curSpeConfig = self.lifeProfessionVM.GetCurSpecialization(self.curProID, id, groupId)
  if curSpeConfig == nil then
    return
  end
  pointUnit.img_icon:SetImage(curSpeConfig.Icon)
  local curLevel = self.lifeProfessionVM.GetSpecializationLv(self.curProID, id)
  local maxLevel = self.lifeProfessionData_:GetSpecializationMaxLevel(self.curProID, groupId)
  pointUnit.Ref:SetVisible(pointUnit.img_lock, not isActive)
  pointUnit.Ref:SetVisible(pointUnit.img_unlock, not isActive)
  pointUnit.Ref:SetVisible(pointUnit.img_icon, true)
  pointUnit.img_icon.color = isActive and COLOR_NORMAL or COLOR_LOCK
  local nextLevelConfig
  if curLevel == 0 then
    nextLevelConfig = curSpeConfig
  elseif curLevel < maxLevel then
    nextLevelConfig = self.lifeProfessionData_:GetSpecializationRow(groupId, curLevel + 1)
    if nextLevelConfig == nil then
      nextLevelConfig = curSpeConfig or nextLevelConfig
    end
  else
    nextLevelConfig = curSpeConfig
  end
  pointUnit.lab_progress.text = string.zconcat(curLevel, "/", maxLevel)
  pointUnit.lab_name.text = curSpeConfig.Name
  pointUnit.lab_progress_pc.text = string.zconcat(curLevel, "/", maxLevel)
  pointUnit.lab_name_pc.text = curSpeConfig.Name
  pointUnit.Ref:SetVisible(pointUnit.pc, Z.IsPCUI)
  pointUnit.Ref:SetVisible(pointUnit.not_pc, not Z.IsPCUI)
  pointUnit.btn_click:RemoveAllListeners()
  pointUnit.btn_click:AddListener(function()
    self:unLoadSpecEffect()
    self.curSelectedPointUnit = pointUnit
    self.curSelectSpecializationID = nextLevelConfig.Id
    for k, v in pairs(self.specID2UnitTable) do
      v.Ref:SetVisible(v.img_select, k == id)
    end
    self:openCurSpecializationSubView()
  end)
end

function Life_profession_acquisition_mainView:unLoadSpecEffect()
  if self.curSelectedPointUnit then
    self.curSelectedPointUnit.node_effect:SetEffectGoVisible(false)
    self.curSelectedPointUnit.node_effect:ReleseEffGo()
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.curSelectedPointUnit.node_effect)
    self.curSelectedPointUnit = nil
  end
end

function Life_profession_acquisition_mainView:unLoadSpecializationTree()
  self:unLoadSpecEffect()
  if self.lastProID then
    if self.treeUnit and self.treeUnit.manager then
      self.treeUnit.manager:UnInit()
    end
    self:RemoveUiUnit(tostring(self.lastProID))
    self.treeUnit = nil
    self.curSelectSpecializationID = nil
  end
end

function Life_profession_acquisition_mainView:openCurSpecializationSubView()
  if self.specializationRightSubView_ then
    self.specializationRightSubView_:DeActive()
  end
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self.specializationRightSubView_:Active({
    proID = self.curProID,
    specID = self.curSelectSpecializationID,
    closeFunc = function()
      if self.specializationRightSubView_ then
        self.specializationRightSubView_:DeActive()
        local curUnit = self.specID2UnitTable[self.curSelectSpecializationID]
        if curUnit == nil then
          return
        end
        curUnit.Ref:SetVisible(curUnit.img_select, false)
        self.currencyItemList_:Init(self.uiBinder.currency_info, {
          Z.SystemItem.VigourItemId,
          self.lifeProfessionVM.GetSpcItemIDByProId()
        })
        self:SetSpecializationOpen(false)
      end
    end
  }, self.uiBinder.node_right_sub, self)
  self:SetSpecializationOpen(true)
  self:adjustTreePosiotin(self.specID2UnitTable[self.curSelectSpecializationID])
end

function Life_profession_acquisition_mainView:adjustTreePosiotin(curUnit)
  local curUnitPositionx = curUnit.Trans.anchoredPosition.x
  local curContentWidth = self.uiBinder.specialization_root.sizeDelta.x - 270
  local scrollerWidth = self.uiBinder.node_specialization.sizeDelta.x
  local leftEdgePos = -curContentWidth / 2 - curUnitPositionx
  local rightEdgePos = -curContentWidth / 2 - curUnitPositionx - scrollerWidth
  local contentPos = self.uiBinder.specialization_root.anchoredPosition
  if rightEdgePos < contentPos.x then
    self.uiBinder.specialization_dotween:DoAnchorPosMove(Vector2.New(rightEdgePos, contentPos.y), 0.2)
  end
  if leftEdgePos > contentPos.x then
    self.uiBinder.specialization_dotween:DoAnchorPosMove(Vector2.New(leftEdgePos, contentPos.y), 0.2)
  end
end

function Life_profession_acquisition_mainView:SetSpecializationOpen(isOpen)
  if isOpen then
    if Z.IsPCUI then
      self.uiBinder.node_specialization:SetOffsetMax(-486, -106)
    else
      self.uiBinder.node_specialization:SetOffsetMax(-616, -106)
    end
  else
    self.uiBinder.node_specialization:SetOffsetMax(-50, -106)
  end
end

function Life_profession_acquisition_mainView:InitReward()
  if Z.IsPCUI then
    self.rewardListView_ = loopListView.new(self, self.uiBinder.scrollview_target_item, gradeItem, "life_profession_grade_list_tpl_pc")
  else
    self.rewardListView_ = loopListView.new(self, self.uiBinder.scrollview_target_item, gradeItem, "life_profession_grade_list_tpl")
  end
  self.rewardListView_:Init({})
end

function Life_profession_acquisition_mainView:RefreshReward()
  local rewardDatas = self.lifeProfessionData_:GetRewardDatas(self.curProID)
  self.rewardListView_:RefreshListView(rewardDatas)
end

return Life_profession_acquisition_mainView
