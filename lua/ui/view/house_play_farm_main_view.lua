local UI = Z.UI
local super = require("ui.ui_view_base")
local House_play_farm_mainView = class("House_play_farm_mainView", super)
local loopList = require("ui.component.loop_list_view")
local seedLoopItem = require("ui.component.house.house_farm_seed_loop_item")
local plantType = {
  None = 0,
  Seed = 1,
  Pollination = 2,
  Manure = 3
}

function House_play_farm_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_play_farm_main")
  self.housePlantData_ = Z.DataMgr.Get("house_plant_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.homeEditorData_ = Z.DataMgr.Get("home_editor_data")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
end

function House_play_farm_mainView:initBinders()
  self.itemList_ = self.uiBinder.scrollview
  self.emptyImg_ = self.uiBinder.img_empty
  self.emptyLab_ = self.uiBinder.lab_empty
  self.loopListView_ = loopList.new(self, self.itemList_, seedLoopItem, "house_play_farm_item_tpl1")
  self.loopListView_:Init({})
end

function House_play_farm_mainView:initData()
  self.curPlantType_ = tonumber(self.viewData[2][1])
  self.curStructureUid_ = self.viewData[1]
end

function House_play_farm_mainView:initBtns()
end

function House_play_farm_mainView:getSeedItems()
  local seedList = {}
  local level = self.houseData_:GetHouseLevel()
  local homeLevelRow = Z.TableMgr.GetRow("HomeLevelTableMgr", level)
  if homeLevelRow then
    local items = self.housePlantData_:GetSeedListByTypes(homeLevelRow.PlanType)
    for index, row in ipairs(items) do
      table.zmerge(seedList, self.homeEditorData_:GetFurnitureWarehouseItem(row.Id, true))
    end
  end
  return seedList
end

function House_play_farm_mainView:getPollinationItems()
  local pollinationList = {}
  local list = self.housePlantData_.PollenMap[self.curFlowerType_] or {}
  for index, row in ipairs(list) do
    pollinationList = table.zmerge(pollinationList, self.homeEditorData_:GetFurnitureWarehouseItem(row.Id, true))
  end
  return pollinationList
end

function House_play_farm_mainView:getManureItems()
  local manureList = {}
  local index = 1
  local homePlantRuleRow = Z.TableMgr.GetRow("HomePlantRuleTableMgr", self.curFlowerType_)
  if homePlantRuleRow then
    local desexFertilizeId = homePlantRuleRow.DesexFertilize
    if desexFertilizeId ~= 0 then
      local isShowDesexFertilize = true
      for i = 0, self.curStructure_.farmlandInfo.fertilizes.count - 1 do
        if self.curStructure_.farmlandInfo.fertilizes[i] == desexFertilizeId then
          isShowDesexFertilize = false
          break
        end
      end
      if isShowDesexFertilize and 0 < self.itemsVm_.GetItemTotalCount(desexFertilizeId) then
        manureList[index] = desexFertilizeId
        index = index + 1
      end
    end
    for _, value in ipairs(homePlantRuleRow.Fertilize) do
      if 0 < self.itemsVm_.GetItemTotalCount(value[1]) then
        manureList[index] = value[1]
        index = index + 1
      end
    end
  end
  return manureList
end

function House_play_farm_mainView:initUi()
  self.curStructure_ = Z.DIServiceMgr.HomeService:GetHouseItemStructure(self.curStructureUid_)
  if self.curStructure_.farmlandInfo then
    local homeSeedRow = Z.TableMgr.GetRow("HomeSeedTableMgr", self.curStructure_.farmlandInfo.seedInstance.configId)
    self.curFlowerType_ = homeSeedRow.Type
    local farmState = self.curStructure_.farmlandInfo.farmlandState:ToInt()
    if farmState <= E.HomeEFarmlandState.EFarmlandStateEmpty then
      self.curPlantType_ = plantType.Seed
    elseif farmState == E.HomeEFarmlandState.EFarmlandStateGrow then
      self.curPlantType_ = plantType.Manure
    elseif farmState == E.HomeEFarmlandState.EFarmlandStatePollen then
      self.curPlantType_ = plantType.Pollination
    else
      self.curPlantType_ = plantType.None
    end
  else
    self.curPlantType_ = plantType.Seed
  end
  self:refreshList()
end

function House_play_farm_mainView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.OnClickFarmBtnAction, self.onClockEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntityStructureUpdate, self.structureUpdate, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CommunityItemUpdate, self.refreshList, self)
end

function House_play_farm_mainView:OnActive()
  self:initBinders()
  self:initBtns()
  self:bindEvent()
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.LowRight, self.viewConfigKey, true)
end

function House_play_farm_mainView:GetIsManureState()
  return self.curPlantType_ == plantType.Manure
end

function House_play_farm_mainView:refreshList()
  local data = {}
  self.emptyMessageId_ = 0
  if self.curPlantType_ == plantType.Seed then
    data = self:getSeedItems()
    self.emptyMessageId_ = 1044019
    self.emptyLab_.text = Lang("SeedEmpty")
    self.loopListView_:RefreshListView(data)
  elseif self.curPlantType_ == plantType.Pollination then
    data = self:getPollinationItems()
    self.emptyMessageId_ = 1044021
    self.emptyLab_.text = Lang("PollinationEmpty")
    self.loopListView_:RefreshListView(data)
  elseif self.curPlantType_ == plantType.Manure then
    data = self:getManureItems()
    self.emptyMessageId_ = 1044020
    self.emptyLab_.text = Lang("ManureEmpty")
    self.loopListView_:RefreshListView(data)
  end
  local hasData = 0 < #data
  self.uiBinder.Ref:SetVisible(self.emptyImg_, not hasData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, hasData)
  local index = 1
  if (self.curPlantType_ == plantType.Seed or self.curPlantType_ == plantType.Pollination) and type(self.homeLandItemInstance_) == "table" then
    for index, value in ipairs(data) do
      if self.homeLandItemInstance_.InstanceId ~= value.InstanceId then
        goto lbl_98
      end
      do break end
      ::lbl_98::
    end
  end
  self.homeLandItemInstance_ = nil
  self.loopListView_:ClearAllSelect()
  self.loopListView_:SetSelected(index)
end

function House_play_farm_mainView:structureUpdate(uuid)
  if self.curStructureUid_ == uuid then
    self.curStructure_ = Z.DIServiceMgr.HomeService:GetHouseItemStructure(self.curStructureUid_)
    self:initUi()
    if self.curPlantType_ == plantType.None then
      self.houseVm_.CloseHousePlayFarmMainView()
    end
  end
end

function House_play_farm_mainView:OnDeActive()
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.LowRight, self.viewConfigKey, false)
end

function House_play_farm_mainView:OnSelectedItem(data)
  self.homeLandItemInstance_ = data
end

function House_play_farm_mainView:onClockEvent()
  if not self.homeLandItemInstance_ then
    if self.emptyMessageId_ and self.emptyMessageId_ ~= 0 then
      Z.TipsVM.ShowTips(self.emptyMessageId_)
    end
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local request = {}
    request.homeId = Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId
    request.op = {
      uuid = self.curStructureUid_,
      opType = E.HomeStructureOpType.StructureOpTypeUpdate
    }
    if self.curPlantType_ == plantType.Seed then
      request.itemInstance = self.homeLandItemInstance_
      logGreen("geneSequence = {0}", table.ztostring(request.itemInstance.ownerToStackMap[Z.ContainerMgr.CharSerialize.charBase.charId].geneSequence))
      self.houseVm_.AsyncSeedingUpdateStructure(request, self.cancelSource:CreateToken())
    elseif self.curPlantType_ == plantType.Pollination then
      request.pollenInstance = self.homeLandItemInstance_
      self.houseVm_.AsyncPollenUpdateStructure(request, self.cancelSource:CreateToken())
    elseif self.curPlantType_ == plantType.Manure then
      request.itemId = self.homeLandItemInstance_
      self.houseVm_.AsyncFertilizerUpdateStructure(request, self.cancelSource:CreateToken())
    end
  end)()
end

function House_play_farm_mainView:OnRefresh()
  self:initData()
  self:initUi()
end

return House_play_farm_mainView
