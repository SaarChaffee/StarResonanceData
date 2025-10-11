local UI = Z.UI
local super = require("ui.ui_view_base")
local Quick_item_usageView = class("Quick_item_usageView", super)
local inputKeyDescComp = require("input.input_key_desc_comp")
local item = require("common.item_binder")

function Quick_item_usageView:ctor()
  self.uiBinder = nil
  super.ctor(self, "quick_item_usage")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Quick_item_usageView:OnActive()
  self.quickItemUsageVm_ = Z.VMMgr.GetVM("quick_item_usage")
  self.quickItemUsageData_ = Z.DataMgr.Get("quick_item_usage_data")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self)
  self:initWidget()
  self:AddAsyncClick(self.useBtn_, function()
    self:useItem()
  end)
  self:AddClick(self.closeBtn_, function()
    self:closeCurItem()
  end)
  self:refreshKeyBoard()
  self:bindEvent()
end

function Quick_item_usageView:initWidget()
  self.itemContainer_ = self.uiBinder.cont_item
  self.useBtn_ = self.uiBinder.btn_use
  self.closeBtn_ = self.uiBinder.btn_close
end

function Quick_item_usageView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Cutscene.CutsceneHideUI, self.onCutscentHideUI, self)
end

function Quick_item_usageView:onCutscentHideUI(isActive)
  self:SetVisible(not isActive)
end

function Quick_item_usageView:OnDeActive()
  self.itemClass_:UnInit()
  self.itemClass_ = nil
  self.curItemInfo_ = nil
  self.quickItemUsageData_:Clear()
  self.inputKeyDescComp_:UnInit()
end

function Quick_item_usageView:OnRefresh()
  if not self.quickItemUsageData_:HasQuickUseItem() then
    self.quickItemUsageVm_.CloseQuickUseView()
    return
  end
  self.curItemInfo_ = self.quickItemUsageData_:PeekItemQuickQueue()
  self:refreshUI()
end

function Quick_item_usageView:refreshUI()
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", self.curItemInfo_.configId)
  if itemRow == nil then
    return
  end
  local itemInfo = self.itemVm_.GetItemInfobyItemId(self.curItemInfo_.uuid, self.curItemInfo_.configId)
  if itemInfo == nil then
    return
  end
  local totalCount = itemInfo.count
  if totalCount < 1 then
    self:closeCurItem()
  end
  local itemData = {}
  itemData.configId = self.curItemInfo_.configId
  itemData.uiBinder = self.itemContainer_
  itemData.isClickOpenTips = true
  itemData.isHideGS = true
  itemData.isShowOne = true
  itemData.labType = E.ItemLabType.Num
  itemData.lab = totalCount
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  if Z.IsPCUI then
    self.uiBinder.lab_show.text = itemRow.Name
  end
end

function Quick_item_usageView:useItem()
  if not self.IsVisible then
    return
  end
  self.quickItemUsageVm_.AsyncUseItem(self.curItemInfo_.configId, self.cancelSource:CreateToken(), self.curItemInfo_.uuid)
  self:closeCurItem()
end

function Quick_item_usageView:closeCurItem()
  self.quickItemUsageData_:DeItemQuickQueue(self.curItemInfo_.configId, self.curItemInfo_.uuid)
  self.curItemInfo_ = nil
  self:OnRefresh()
end

function Quick_item_usageView:refreshKeyBoard()
  if not Z.IsPCUI then
    return
  end
  self.inputKeyDescComp_:Init(117, self.uiBinder.main_icon_key)
end

function Quick_item_usageView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.QuickItemUsage then
    Z.CoroUtil.create_coro_xpcall(function()
      self:useItem()
    end)()
  end
end

return Quick_item_usageView
