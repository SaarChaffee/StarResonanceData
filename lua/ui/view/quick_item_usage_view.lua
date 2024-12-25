local UI = Z.UI
local super = require("ui.ui_view_base")
local Quick_item_usageView = class("Quick_item_usageView", super)
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local item = require("common.item_binder")
local itemPCScale = 0.7

function Quick_item_usageView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.quick_item_usage.PrefabPath = "quick_item_usage/quick_item_usage_window_pc"
  else
    Z.UIConfig.quick_item_usage.PrefabPath = "quick_item_usage/quick_item_usage_window"
  end
  super.ctor(self, "quick_item_usage")
  
  function self.onInputAction_(inputActionEventData)
    Z.CoroUtil.create_coro_xpcall(function()
      self:useItem()
    end)()
  end
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
  self:registerInputActions()
  self:bindEvent()
end

function Quick_item_usageView:initWidget()
  self.pc_nodeTrans = self.uiBinder.node_pc
  self.default_nodeTrans = self.uiBinder.node_default
  self.itemContainer_ = self.uiBinder.cont_item
  self.useBtn_ = self.uiBinder.btn_use
  self.closeBtn_ = self.uiBinder.btn_close
  self.imgBgTrans_ = self.uiBinder.img_bg
  self.main_icon_key_ = self.uiBinder.main_icon_key
  if Z.IsPCUI then
    self.imgBgTrans_:SetParent(self.pc_nodeTrans)
  else
    self.imgBgTrans_:SetParent(self.default_nodeTrans)
  end
  self.imgBgTrans_:SetLocalPos(0, 0, 0)
end

function Quick_item_usageView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Cutscene.CutsceneHideUI, self.onCutscentHideUI, self)
end

function Quick_item_usageView:onCutscentHideUI(isActive)
  self:SetVisible(not isActive)
end

function Quick_item_usageView:OnDeActive()
  self:unRegisterInputActions()
  self.itemClass_:UnInit()
  self.itemClass_ = nil
  self.curShowConfigId_ = nil
  self.quickItemUsageData_:Clear()
end

function Quick_item_usageView:OnRefresh()
  if not self.quickItemUsageData_:HasQuickUseItem() then
    self.quickItemUsageVm_.CloseQuickUseView()
    return
  end
  local configId = self.quickItemUsageData_:PeekItemQuickQueue()
  self.curShowConfigId_ = configId
  self:refreshUI()
end

function Quick_item_usageView:refreshUI()
  local totalCount = self.itemVm_.GetItemTotalCount(self.curShowConfigId_)
  if totalCount < 1 then
    self:closeCurItem()
  end
  local itemData = {}
  itemData.configId = self.curShowConfigId_
  itemData.uiBinder = self.itemContainer_
  itemData.isClickOpenTips = true
  itemData.isHideGS = true
  itemData.isShowOne = true
  itemData.labType = E.ItemLabType.Num
  itemData.lab = totalCount
  itemData.isSquareItem = true
  if Z.IsPCUI then
    itemData.sizeX = itemPCScale
    itemData.sizeY = itemPCScale
  end
  self.itemClass_:Init(itemData)
end

function Quick_item_usageView:useItem()
  if not self.IsVisible then
    return
  end
  self.quickItemUsageVm_.AsyncUseItem(self.curShowConfigId_, self.cancelSource:CreateToken())
  self:closeCurItem()
end

function Quick_item_usageView:closeCurItem()
  self.quickItemUsageData_:DeItemQuickQueue(self.curShowConfigId_)
  self.curShowConfigId_ = nil
  self:OnRefresh()
end

function Quick_item_usageView:registerInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.QuickItemUsage)
end

function Quick_item_usageView:unRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.QuickItemUsage)
end

function Quick_item_usageView:refreshKeyBoard()
  if not Z.IsPCUI then
    self.main_icon_key_.Ref.UIComp:SetVisible(false)
    return
  end
  self.main_icon_key_.Ref.UIComp:SetVisible(true)
  keyIconHelper.InitKeyIcon(self, self.main_icon_key_, 117)
end

return Quick_item_usageView
