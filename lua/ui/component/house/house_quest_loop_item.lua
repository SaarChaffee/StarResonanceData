local HouseQuestLoopItem = class("HouseQuestLoopItem")
local houseLevelAwardLoopItem = require("ui.component.house.house_level_reward_loop_item")
local loopListView = require("ui.component.loop_list_view")

function HouseQuestLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.awardprevVm_ = Z.VMMgr.GetVM("awardpreview")
  self.homeData_ = Z.DataMgr.Get("home_editor_data")
  self.houseData_ = Z.DataMgr.Get("house_data")
  Z.EventMgr:Add(Z.ConstValue.House.HouseQuestFinished, self.HouseQuestFinished, self)
  Z.EventMgr:Add(Z.ConstValue.Home.CommunityItemUpdate, self.onCommunityItemUpdateChanged, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onCommunityItemUpdateChanged, self)
  self.rewardListView_ = loopListView.new(self.parent, self.uiBinder.scrollview_item, houseLevelAwardLoopItem, "com_item_square_1_8")
  self.rewardListView_:Init({})
end

function HouseQuestLoopItem:ctor(parent, uiBinder)
  self.parent = parent
  self.uiBinder = uiBinder
end

function HouseQuestLoopItem:HouseQuestFinished(id)
  if self.taskData.id == id then
    self.taskData.isFinished = true
    self:OnRefresh(self.taskData)
  end
end

function HouseQuestLoopItem:onCommunityItemUpdateChanged(id)
  self:OnRefresh(self.taskData)
end

function HouseQuestLoopItem:OnRefresh(data)
  self.taskData = data
  local taskID = self.taskData.id
  local homeTaskTableRow = Z.TableMgr.GetRow("HomeTaskTableMgr", taskID)
  self:refreshTaskInfo(homeTaskTableRow)
  self:refreshBtnState(homeTaskTableRow)
  local awardList = self.awardprevVm_.GetAllAwardPreListByIds(homeTaskTableRow.AwardId)
  self.rewardListView_:RefreshListView(awardList)
end

function HouseQuestLoopItem:refreshTaskInfo(homeTaskTableRow)
  local path = self.uiBinder.pcd:GetString("house_quest_item_child_tpl")
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in pairs(homeTaskTableRow.ConsumeParams) do
      local name = "quest_item_" .. self.taskData.id .. "_" .. k
      local costItemId = v[1]
      local count = v[2]
      local unit = self.parent:AsyncLoadUiUnit(path, name, self.uiBinder.layout_consume, self.parent.cancelSource:CreateToken())
      if unit == nil then
        return
      end
      unit.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(costItemId))
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
      if itemConfig == nil then
        return
      end
      unit.lab_name.text = itemConfig.Name
      local itemCurCount = 0
      if self.homeData_:GetItemIsHouseWarehouseItem(costItemId) then
        itemCurCount = self.homeData_:GetSelfFurnitureWarehouseItemCount(costItemId)
      else
        itemCurCount = self.itemsVM_.GetItemTotalCount(costItemId)
      end
      local enough = count <= itemCurCount
      if enough then
        unit.lab_num.text = Lang("HoueeQusetConsumeEnough", {value1 = count, value2 = count})
      else
        unit.lab_num.text = Lang("HoueeQusetConsumeNotEnough", {value1 = itemCurCount, value2 = count})
      end
      local isFinished = self.taskData.isFinished
      if isFinished then
        unit.lab_num.text = ""
      end
      unit.btn:AddListener(function()
        if self.tipsId_ then
          Z.TipsVM.CloseItemTipsView(self.tipsId_)
        end
        self.tipsId_ = Z.TipsVM.ShowItemTipsView(unit.btn.transform, costItemId)
      end, true)
    end
  end)()
end

function HouseQuestLoopItem:refreshBtnState(homeTaskTableRow)
  local isFinished = self.taskData.isFinished
  local isEnough = true
  for k, v in pairs(homeTaskTableRow.ConsumeParams) do
    local costItemId = v[1]
    local count = v[2]
    local itemCurCount = 0
    if self.homeData_:GetItemIsHouseWarehouseItem(costItemId) then
      itemCurCount = self.homeData_:GetSelfFurnitureWarehouseItemCount(costItemId)
    else
      itemCurCount = self.itemsVM_.GetItemTotalCount(costItemId)
    end
    local enough = count <= itemCurCount
    if not enough then
      isEnough = false
      break
    end
  end
  local remainCount = 0
  local questTaskInfo = self.houseData_:GetTaskInfo()
  if questTaskInfo ~= nil then
    remainCount = questTaskInfo.curLeftTimes
  end
  local isLimited = remainCount <= 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_submit, not isFinished)
  self.uiBinder.btn_submit.IsDisabled = not isEnough or isLimited
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_complete, isFinished)
  self.uiBinder.lab_content.text = isLimited and Lang("HouseQuestLimit") or Lang("Submit")
  self.uiBinder.btn_submit:AddListener(function()
    if not isEnough or isLimited then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      self.houseVm_.AsyncCommitHouseQuest(self.taskData.id, self.parent.cancelSource:CreateToken())
    end)()
  end, true)
end

function HouseQuestLoopItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.House.HouseQuestFinished, self.HouseQuestFinished, self)
  Z.EventMgr:Remove(Z.ConstValue.Home.CommunityItemUpdate, self.onCommunityItemUpdateChanged, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onCommunityItemUpdateChanged, self)
  self.rewardListView_:UnInit()
  self.rewardListView_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

return HouseQuestLoopItem
