local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_warehouse_subView = class("Home_editor_warehouse_subView", super)
local loopListView = require("ui/component/loop_list_view")
local loopGridView = require("ui/component/loop_grid_view")
local wareHouseTabItem = require("ui.component.home.home_warehouse_tab_loop_item")
local wareHouseTabTypeItem = require("ui.component.home.home_warehouse_tab_type_loop_item")
local wareHouseOneItem = require("ui.component.home.home_warehouse_one_loop_item")
local wareHouseTwoItem = require("ui.component.home.home_warehouse_two_loop_item")

function Home_editor_warehouse_subView:ctor(parent)
  self.parent_ = parent
  self.uiBinder = nil
  super.ctor(self, "home_editor_warehouse_sub", "home_editor/home_editor_warehouse_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home_editor")
  self.data_ = Z.DataMgr.Get("home_editor_data")
end

function Home_editor_warehouse_subView:initBinders()
  self.imgBg_ = self.uiBinder.img_bg
  self.searchInput_ = self.uiBinder.input_search
  self.delBtn_ = self.uiBinder.btn_delete
  self.togItemLoop_ = self.uiBinder.loopscroll_tog
  self.wareHouseOneItemLoop_ = self.uiBinder.loopscroll_item_one
  self.wareHouseTwoItemLoop_ = self.uiBinder.loopscroll_item_two
  self.arrowNode_ = self.uiBinder.img_arrow
  self.changeBtn_ = self.uiBinder.btn_change
  self.viewRect_ = self.uiBinder.view_rect
  self.viewRect_:SetSizeDelta(0, 0)
  self.wareHouseOneListView_ = loopListView.new(self, self.wareHouseOneItemLoop_, wareHouseOneItem, "com_item_long_1")
  self.wareHouseOneListView_:Init({})
  self.wareHouseTwoListView_ = loopGridView.new(self, self.wareHouseTwoItemLoop_, wareHouseTwoItem, "com_item_long_1")
  self.wareHouseTwoListView_:Init({})
  self.wareHouseTabListView_ = loopListView.new(self, self.togItemLoop_)
  self.wareHouseTabListView_:SetGetItemClassFunc(function(data)
    if data.isType then
      return wareHouseTabTypeItem
    else
      return wareHouseTabItem
    end
  end)
  self.wareHouseTabListView_:SetGetPrefabNameFunc(function(data)
    if data.isType then
      return "home_furniture_btn_tpl"
    else
      return "home_btn_tpl"
    end
  end)
  self.wareHouseTabListView_:Init({})
end

function Home_editor_warehouse_subView:initBtns()
  self:AddClick(self.delBtn_, function()
    self.searchInput_.text = ""
  end)
  self:AddClick(self.searchInput_, function(str)
    if self.IsWarehouse then
      if str == "" then
        self.showData_ = self.vm_.ItemsNameMatched(self.searchInput_.text, self.wareHouseData_)
      else
        self.showData_ = self.vm_.ItemsNameMatched(self.searchInput_.text, self.allWareHouseItemList_)
      end
    else
      self.showData_ = self.vm_.HomeDatasStrMatched(self.searchInput_.text, self.wareHouseData_)
    end
    self:setData()
  end)
  self:AddClick(self.changeBtn_, function()
    self.isOneLoopList_ = not self.isOneLoopList_
    Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "HOME_EDITOR_LIST_TWO", not self.isOneLoopList_)
    self:refreshLoopListState()
    self:setData()
  end)
end

function Home_editor_warehouse_subView:initUi()
  self.homeCfgDatas_ = self:getListViewData()
  self.wareHouseTabListView_:RefreshListView(self.homeCfgDatas_)
  if self.data_.SelectedGroupId ~= 0 then
    self:refreshTabLoopList()
  else
    self.wareHouseTabListView_:SetSelected(1)
  end
  self:refreshLoopListState()
end

function Home_editor_warehouse_subView:getListViewData()
  local allData = self.data_:GetHomeCfgDatas()
  local datas = {}
  if self.data_.IsEditingItemMat then
    for _, data in ipairs(allData) do
      if data.groupId == tonumber(E.HousingItemGroupType.HousingItemGroupTypePartitionWallMat) then
        table.insert(datas, data)
      end
    end
  else
    for _, data in ipairs(allData) do
      if data.groupId ~= tonumber(E.HousingItemGroupType.HousingItemGroupTypePartitionWallMat) then
        table.insert(datas, data)
      end
    end
  end
  return datas
end

function Home_editor_warehouse_subView:initData()
  self.isOneLoopList_ = not Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "HOME_EDITOR_LIST_TWO")
  self.IsWarehouse = self.viewData and self.viewData.subType == E.EHomeRightSubType.Warehouse
  self.allWareHouseItemList_ = self.vm_.GetAllWareHouseData()
end

function Home_editor_warehouse_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshWareHouseList, self.initUi, self)
end

function Home_editor_warehouse_subView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initData()
  self:bindEvents()
  self:refreshLoopListState()
  Z.CoroUtil.create_coro_xpcall(function()
    self.vm_.AsyncHomelandFurnitureWarehouseData()
    self:initUi()
  end)()
end

function Home_editor_warehouse_subView:refreshLoopListState()
  self.imgBg_.transform:SetWidth(self.isOneLoopList_ and 416 or 560)
  self.parent_:SetBgWidth(self.isOneLoopList_ and 416 or 560)
  self.arrowNode_:SetEuler(0, 0, self.isOneLoopList_ and 0 or 180)
  self.uiBinder.Ref:SetVisible(self.wareHouseOneItemLoop_, self.isOneLoopList_)
  self.uiBinder.Ref:SetVisible(self.wareHouseTwoItemLoop_, not self.isOneLoopList_)
end

function Home_editor_warehouse_subView:OnDeActive()
  if self.wareHouseTabListView_ then
    self.wareHouseTabListView_:UnInit()
    self.wareHouseTabListView_ = nil
  end
  if self.wareHouseOneListView_ then
    self.wareHouseOneListView_:UnInit()
    self.wareHouseOneListView_ = nil
  end
  if self.wareHouseTwoListView_ then
    self.wareHouseTwoListView_:UnInit()
    self.wareHouseTwoListView_ = nil
  end
  Z.EventMgr:RemoveObjAll(self)
end

function Home_editor_warehouse_subView:SetWareHouseData(typeId, index)
  self.typeLoopItemIndex_ = index
  self.data_.SelectedTypeId = typeId
  self.showData_ = {}
  if self.IsWarehouse then
    self.wareHouseData_ = self.vm_.GetWareHouseDataByTypeId(typeId)
    if self.wareHouseData_ then
      self.showData_ = self.vm_.ItemsNameMatched(self.searchInput_.text, self.wareHouseData_)
    end
  else
    self.wareHouseData_ = self.vm_.GetHomelandDataByType(typeId)
    if self.wareHouseData_ then
      self.showData_ = self.vm_.HomeDatasStrMatched(self.searchInput_.text, self.wareHouseData_)
    end
  end
  if self.searchInput_.text ~= "" then
    self.searchInput_.text = ""
  else
    self:setData()
  end
end

function Home_editor_warehouse_subView:setData()
  if self.isOneLoopList_ then
    if self.wareHouseOneListView_ then
      self.wareHouseOneListView_:RefreshListView(self.showData_)
    end
    if self.wareHouseTwoListView_ then
      self.wareHouseTwoListView_:RefreshListView({})
    end
  else
    if self.wareHouseOneListView_ then
      self.wareHouseOneListView_:RefreshListView({})
    end
    if self.wareHouseTwoListView_ then
      self.wareHouseTwoListView_:RefreshListView(self.showData_)
    end
  end
end

function Home_editor_warehouse_subView:OnRefresh()
end

function Home_editor_warehouse_subView:SelectedTab(data)
  if self.selectedHomeCfgData_ == data then
    return
  end
  self.data_.SelectedGroupId = data.groupId
  self.selectedHomeCfgData_ = data
  self:refreshTabLoopList()
end

function Home_editor_warehouse_subView:GetSecondSelectedId()
  return self.selectedHomeCfgData_
end

function Home_editor_warehouse_subView:refreshTabLoopList()
  local datas = table.zvalues(self.homeCfgDatas_)
  local typeDatas = self.data_:GetHomeCfgItemDatasByGroup(self.data_.SelectedGroupId)
  self.typeLoopItemIndex_ = nil
  if not typeDatas then
    return
  end
  local typeDatas = table.zreverse(typeDatas)
  for i, data in ipairs(datas) do
    if data.groupId == self.data_.SelectedGroupId then
      self.typeLoopItemIndex_ = i + 1
      for index, typeData in ipairs(typeDatas) do
        table.insert(datas, i + 1, typeData)
        if typeData.typeId == self.data_.SelectedTypeId then
          self.typeLoopItemIndex_ = i + (#typeDatas - index + 1)
        end
      end
      break
    end
  end
  self.wareHouseTabListView_:RefreshListView(datas)
  self:SelectedTypeItem()
end

function Home_editor_warehouse_subView:SelectedTypeItem()
  if self.typeLoopItemIndex_ then
    self.wareHouseTabListView_:ClearAllSelect()
    self.wareHouseTabListView_:SetSelected(self.typeLoopItemIndex_)
  end
end

return Home_editor_warehouse_subView
