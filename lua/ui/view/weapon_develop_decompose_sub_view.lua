local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_develop_decompose_subView = class("Weapon_develop_decompose_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local decomposeConsumeLoopItem = require("ui.component.resonance_power.resonance_power_decomposeconsume_loop_item")
local decomposeGetLoopItem = require("ui.component.resonance_power.resonance_power_decomposeget_loop_item")

function Weapon_develop_decompose_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_develop_decompose_sub", "weapon_develop/weapon_develop_decompose_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
end

function Weapon_develop_decompose_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self.parent_:RefreshListView(true, function(dataList)
    return self:getListSelectIndex(dataList)
  end)
end

function Weapon_develop_decompose_subView:OnDeActive()
  self:unInitLoopListView()
end

function Weapon_develop_decompose_subView:OnRefresh()
end

function Weapon_develop_decompose_subView:initData()
  self.decomposeDict_ = {}
  if self.parent_.viewData and self.parent_.viewData.DecomposeParam then
    local data = self.parent_.viewData.DecomposeParam
    self.decomposeDict_[data.itemUuid] = data
    self.parent_.viewData.DecomposeParam = nil
  end
end

function Weapon_develop_decompose_subView:initComponent()
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:startDecomposeCheck()
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:cancelDecompose()
  end)
  self:AddClick(self.uiBinder.btn_one_add, function()
    self:oneKeyAddDecomposeItem()
  end)
  self:initLoopListView()
end

function Weapon_develop_decompose_subView:initLoopListView()
  self.loopViewDecomposeConsume_ = loopGridView.new(self, self.uiBinder.loop_select_list, decomposeConsumeLoopItem, "com_item_long_8")
  self.loopViewDecomposeConsume_:Init({})
  self.loopViewDecomposeGet_ = loopGridView.new(self, self.uiBinder.loop_material_list, decomposeGetLoopItem, "com_item_square_2")
  self.loopViewDecomposeGet_:Init({})
end

function Weapon_develop_decompose_subView:refreshLoopListView()
  local awardList = self.resonancePowerVM_.GetDecomposeGetAward(self.decomposeDict_)
  self.loopViewDecomposeGet_:RefreshListView(awardList)
  local decomposeList = {}
  for k, v in pairs(self.decomposeDict_) do
    decomposeList[#decomposeList + 1] = v
  end
  self.loopViewDecomposeConsume_:RefreshListView(decomposeList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #decomposeList == 0)
end

function Weapon_develop_decompose_subView:unInitLoopListView()
  self.loopViewDecomposeConsume_:UnInit()
  self.loopViewDecomposeConsume_ = nil
  self.loopViewDecomposeGet_:UnInit()
  self.loopViewDecomposeGet_ = nil
end

function Weapon_develop_decompose_subView:getListSelectIndex(dataList)
  if self.decomposeDict_ and next(self.decomposeDict_) ~= nil then
    local selectIndexList = {}
    for i, v in ipairs(dataList) do
      if self.decomposeDict_[v.itemUuid] then
        table.insert(selectIndexList, i)
      end
    end
    return selectIndexList
  end
  return nil
end

function Weapon_develop_decompose_subView:startDecompose()
  local decomposeData = {}
  for k, v in pairs(self.decomposeDict_) do
    decomposeData[k] = v.count
  end
  self.resonancePowerVM_.ReqDecomposeResonancePower(decomposeData, self.cancelSource:CreateToken())
  self.decomposeDict_ = {}
  self.parent_:RefreshListView(true)
  self:refreshLoopListView()
end

function Weapon_develop_decompose_subView:cancelDecompose()
  self.decomposeDict_ = {}
  self.parent_:RefreshListView(true)
  self:refreshLoopListView()
end

function Weapon_develop_decompose_subView:oneKeyAddDecomposeItem()
  local itemsVM = Z.VMMgr.GetVM("items")
  local dataList = self.parent_:GetCurrentDataList()
  if dataList == nil or #dataList == 0 then
    Z.TipsVM.ShowTips(150110)
    return
  end
  local tempDict = {}
  for i, v in ipairs(dataList) do
    local config = Z.TableMgr.GetRow("ItemTableMgr", v.configId)
    if config and config.Quality <= E.ItemQuality.Purple then
      local itemInfo = itemsVM.GetItemInfobyItemId(v.itemUuid, v.configId)
      if itemInfo ~= nil then
        local decomposeData = {
          itemUuid = v.itemUuid,
          configId = v.configId,
          count = itemInfo.count
        }
        tempDict[v.itemUuid] = decomposeData
      end
    end
  end
  if next(tempDict) == nil then
    Z.TipsVM.ShowTips(150110)
    return
  end
  self.decomposeDict_ = tempDict
  self.parent_:RefreshListView(true, function(dataList)
    return self:getListSelectIndex(dataList)
  end)
  self:refreshLoopListView()
end

function Weapon_develop_decompose_subView:OnSelectResonancePowerItemDecompose(isSelected, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if isSelected then
    local decomposeData = self.decomposeDict_[data.itemUuid]
    if decomposeData then
      local itemInfo = itemsVM.GetItemInfobyItemId(data.itemUuid, data.configId)
      local maxCount = itemInfo and itemInfo.count or 0
      if maxCount >= decomposeData.count + 1 then
        decomposeData.count = decomposeData.count + 1
      end
    else
      decomposeData = {
        itemUuid = data.itemUuid,
        configId = data.configId,
        count = 1
      }
      self.decomposeDict_[data.itemUuid] = decomposeData
    end
  else
    local decomposeData = self.decomposeDict_[data.itemUuid]
    if decomposeData then
      if decomposeData.count > 1 then
        decomposeData.count = decomposeData.count - 1
      else
        self.decomposeDict_[data.itemUuid] = nil
      end
    end
  end
  self:refreshLoopListView()
end

function Weapon_develop_decompose_subView:startDecomposeCheck()
  if next(self.decomposeDict_) == nil then
    Z.TipsVM.ShowTips(150102)
    return
  end
  local haveHightQuality_ = false
  for k, v in pairs(self.decomposeDict_) do
    local itemTableRow = self.itemTableMgr_.GetRow(v.configId)
    if itemTableRow and itemTableRow.Quality >= 3 then
      haveHightQuality_ = true
      break
    end
  end
  if haveHightQuality_ then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ResonancePowerDecomposeConfirm"), function()
      self:startDecompose()
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.ResonancePower_Decompose_Prompt)
  else
    self:startDecompose()
  end
end

function Weapon_develop_decompose_subView:GetDecomposeSelectCount(itemUuid)
  return self.decomposeDict_[itemUuid] and self.decomposeDict_[itemUuid].count or 0
end

return Weapon_develop_decompose_subView
