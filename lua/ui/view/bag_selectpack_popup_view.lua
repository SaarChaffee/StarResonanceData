local UI = Z.UI
local super = require("ui.ui_view_base")
local Bag_selectpack_popupView = class("Bag_selectpack_popupView", super)
local selectPack_loopItem = require("ui.component.bag.bag_selectpack_item")
local selectPackSingle_loopItem = require("ui.component.bag.bag_selectpack_single_item")
local keyPad = require("ui.view.cont_num_keyboard_view")
local padTipsMaxX = 23
local loopListView = require("ui.component.loop_list_view")

function Bag_selectpack_popupView:ctor()
  self.panel = nil
  super.ctor(self, "bag_selectpack_popup")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
end

function Bag_selectpack_popupView:OnActive()
  self:initFunc()
end

function Bag_selectpack_popupView:OnDeActive()
  self.loopList_:UnInit()
  self.keypad_:DeActive()
end

function Bag_selectpack_popupView:OnRefresh()
  self:refreshInfo()
end

function Bag_selectpack_popupView:CloseView()
  self:closeBagSelectView()
end

function Bag_selectpack_popupView:initFunc()
  self:AddClick(self.uiBinder.btn_no, function()
    self:CloseView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:useItem()
    self:CloseView()
  end)
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.keypad_ = keyPad.new(self)
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_item)
  self.loopList_:SetGetItemClassFunc(function(data)
    if self.viewData.awardNum == 1 or 1 >= self.viewData.ItemBatchCount then
      return selectPackSingle_loopItem
    else
      return selectPack_loopItem
    end
  end)
  self.loopList_:SetGetPrefabNameFunc(function(data)
    if self.viewData.awardNum == 1 or 1 >= self.viewData.ItemBatchCount then
      return "com_item_square_1"
    else
      return "bag_selectpack_item_tpl"
    end
  end)
  self.loopList_:Init({})
  if self.viewData.itemId then
    self.itemFunctionTable_ = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(self.viewData.itemId)
  end
end

function Bag_selectpack_popupView:refreshInfo()
  local itemName
  if self.viewData.itemUuid then
    local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages
    for _, package in pairs(packages) do
      local item = package.items[self.viewData.itemUuid]
      if item then
        self.viewData.itemId = item.configId
        self.viewData.awardNum = item.count
        break
      end
    end
  elseif self.viewData.awardNum == nil or self.viewData.awardNum < 1 then
    self.viewData.awardNum = 1
  end
  if self.viewData.itemId then
    local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.itemId)
    if not itemTable then
      return
    end
    itemName = itemTable.Name
  end
  if not self.viewData.awardId then
    return
  end
  self.useNum_ = math.min(self.viewData.ItemBatchCount, self.viewData.awardNum)
  self:initSelectData()
  self:refreshTitle(itemName)
  self:refreshBtnState()
  self:refreshItemUseCount()
end

function Bag_selectpack_popupView:initSelectData()
  local awardTable = self.awardPreviewVM_.GetAllAwardPreListByIds(self.viewData.awardId)
  if not awardTable then
    return
  end
  if self.viewData.itemId then
    self.itemFunctionTable_ = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(self.viewData.itemId)
  end
  self.selectNum_ = 0
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr")
  self.selectData_ = {}
  for i = 1, #awardTable do
    local itemData = {}
    local v_ = awardTable[i]
    itemData.itemId = v_.awardId
    itemData.itemNum = v_.awardNum
    itemData.bindInfo = v_.BindInfo and v_.BindInfo[i] or 0
    itemData.selectNum = 0
    itemData.index = v_.Index
    itemData.isLimit = false
    itemData.isHave = false
    itemData.showIndex = i
    if self.itemFunctionTable_ then
      local limitTypeList = self.itemFunctionTable_.RepeatLimit
      local itemTable = itemTable.GetRow(itemData.itemId)
      for i = 1, #limitTypeList do
        if itemTable.Type == limitTypeList[i] then
          local itemsVM = Z.VMMgr.GetVM("items")
          local ownNum = itemsVM.GetItemTotalCount(itemData.itemId)
          itemData.isHave = 0 < ownNum
          itemData.isLimit = true
          break
        end
      end
    end
    self.selectData_[#self.selectData_ + 1] = itemData
  end
  self.selectItemId_ = 0
  self.selectItemNumLab_ = nil
  if self.viewData.awardNum == 1 or 1 >= self.viewData.ItemBatchCount then
    self.uiBinder.loop_item_ref:SetHeight(184)
  else
    self.uiBinder.loop_item_ref:SetHeight(416)
  end
  table.sort(self.selectData_, function(left, right)
    if left.isHave then
      if right.isHave then
        return left.showIndex < right.showIndex
      else
        return false
      end
    elseif right.isHave then
      return true
    else
      return left.showIndex < right.showIndex
    end
  end)
  self.loopList_:RefreshListView(self.selectData_, false)
end

function Bag_selectpack_popupView:SetSelected(index, itemId)
  self.loopList_:SetSelected(index)
  if self.useNum_ > 1 then
    return
  end
  self.selectItemId_ = itemId
  self.selectNum_ = 1
  self:refreshBtnState()
end

function Bag_selectpack_popupView:refreshTitle(itemName)
  if not itemName then
    self.uiBinder.lab_title.text = Lang("selectPackDefaultTitle")
  else
    local param = {
      item = {name = itemName}
    }
    self.uiBinder.lab_title.text = Lang("selectPackItemTitle", param)
  end
end

function Bag_selectpack_popupView:refreshItemUseCount()
  if not self.useNum_ or self.useNum_ == 1 or 1 >= self.viewData.ItemBatchCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_usenum, false)
  else
    local param = {
      item = {
        nums = {
          self.selectNum_,
          self.useNum_
        }
      }
    }
    self.uiBinder.lab_usenum.text = Lang("selectPackUseNum", param)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_usenum, true)
  end
end

function Bag_selectpack_popupView:OpenSelectItemNum(itemId, selectNum, rect, limit)
  self.selectItemId_ = itemId
  local canInputNum = self.useNum_ - self.selectNum_ + selectNum
  if limit then
    canInputNum = 1
  end
  self.keypad_:Active({max = canInputNum}, self.uiBinder.node_pad)
  self.uiBinder.node_pad.position = rect.position
  if self.uiBinder.node_pad.anchoredPosition.x > padTipsMaxX then
    self.uiBinder.node_pad:SetAnchorPosition(padTipsMaxX, self.uiBinder.node_pad.anchoredPosition.y)
  end
end

function Bag_selectpack_popupView:InputNum(num)
  self:ChangeSelectItemNum(self.selectItemId_, num)
end

function Bag_selectpack_popupView:ChangeSelectItemNum(itemId, itemNum)
  if not itemId then
    return
  end
  local idx = 0
  local num = 0
  for i = 1, #self.selectData_ do
    if self.selectData_[i].itemId ~= itemId then
      num = num + self.selectData_[i].selectNum
    else
      idx = i
      num = num + itemNum
    end
  end
  if 0 < idx and idx <= #self.selectData_ and 0 <= num and num <= self.useNum_ then
    self.selectNum_ = num
    self.selectData_[idx].selectNum = itemNum
    self.loopList_.DataList = self.selectData_
    for i = 1, #self.selectData_ do
      self.loopList_:RefreshItemByItemIndex(i)
    end
    self:refreshItemUseCount()
    self:refreshBtnState()
  end
end

function Bag_selectpack_popupView:IsCanAddNum()
  if self.selectNum_ >= self.useNum_ then
    return false
  else
    return true
  end
end

function Bag_selectpack_popupView:GetAwardNum()
  return self.useNum_
end

function Bag_selectpack_popupView:refreshBtnState()
  if self.selectNum_ == 0 then
    self.uiBinder.btn_ok.IsDisabled = true
    self.uiBinder.btn_ok.interactable = false
  else
    self.uiBinder.btn_ok.IsDisabled = false
    self.uiBinder.btn_ok.interactable = true
  end
end

function Bag_selectpack_popupView:useItem()
  local itemsVM = Z.VMMgr.GetVM("items")
  local selectData = {}
  if self.viewData.itemId then
    if (self.viewData.awardNum == 1 or 1 >= self.viewData.ItemBatchCount) and self.selectItemId_ then
      for i = 1, #self.selectData_ do
        if self.selectData_[i].itemId == self.selectItemId_ then
          selectData[self.selectData_[i].index - 1] = 1
          break
        end
      end
    else
      for i = 1, #self.selectData_ do
        if self.selectData_[i].selectNum > 0 then
          selectData[self.selectData_[i].index - 1] = self.selectData_[i].selectNum
        end
      end
    end
    local param = {}
    param.useNum = self.selectNum_
    param.select = selectData
    if self.viewData.itemUuid ~= nil then
      param.itemUuid = self.viewData.itemUuid
    else
      local itemData = Z.DataMgr.Get("items_data")
      local uuidList = itemData:GetItemUuidsByConfigId(self.viewData.itemId)
      if uuidList and 0 < #uuidList then
        param.itemUuid = uuidList[1]
      end
    end
    itemsVM.AsyncUseItemByUuid(param, self.cancelSource:CreateToken())
  end
end

function Bag_selectpack_popupView:closeBagSelectView()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Bag_selectpack_popupView:OnInputBack()
  if self.IsResponseInput then
    self:closeBagSelectView()
  end
end

return Bag_selectpack_popupView
