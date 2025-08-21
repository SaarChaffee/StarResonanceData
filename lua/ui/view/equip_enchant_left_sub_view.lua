local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_enchant_left_subView = class("Equip_enchant_left_subView", super)
local loopListView = require("ui/component/loop_list_view")
local loopItem = require("ui.component.equip.equip_enchant_left_loop_item")

function Equip_enchant_left_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_enchant_left_sub", "equip/equip_enchant_left_sub", UI.ECacheLv.None, true)
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
end

function Equip_enchant_left_subView:initBinders()
  self.closeBnt_ = self.uiBinder.btn_return
  self.itemList_ = self.uiBinder.loop_item
  self.PressComp = self.uiBinder.node_press
  self.emptyLab_ = self.uiBinder.lab_empty
  self.getBtn_ = self.uiBinder.btn_get
end

function Equip_enchant_left_subView:initBtns()
  self:AddClick(self.closeBnt_, function()
    self:DeActive()
  end)
  self:EventAddAsyncListener(self.PressComp.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
  self:AddClick(self.getBtn_, function()
    Z.VMMgr.GetVM("gotofunc").GoToFunc(E.FunctionID.LifeProfessionJinXie)
  end)
end

function Equip_enchant_left_subView:initUi()
  local itemPath
  if Z.IsPCUI then
    itemPath = "equip_enchant_list_item_tpl_pc"
  else
    itemPath = "equip_enchant_list_item_tpl"
  end
  self.loopGridView_ = loopListView.new(self, self.itemList_, loopItem, itemPath)
  self.items_ = {}
  local row = self.viewData or {}
  self.uiBinder.Ref:SetVisible(self.emptyLab_, #row == 0)
  self.uiBinder.Ref:SetVisible(self.getBtn_, #row == 0)
  self.loopGridView_:Init(row)
  self:StartCheck()
end

function Equip_enchant_left_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self:initBtns()
  self:initUi()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, true)
end

function Equip_enchant_left_subView:StartCheck()
  self.PressComp:StartCheck()
end

function Equip_enchant_left_subView:StopCheck()
  self.PressComp:StopCheck()
end

function Equip_enchant_left_subView:ClearSelected()
  self.loopGridView_:ClearAllSelect()
end

function Equip_enchant_left_subView:OnSelectedItem(data)
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.SelectedEnchantItem, data)
end

function Equip_enchant_left_subView:OnDeActive()
  self:StopCheck()
  if self.loopGridView_ then
    self.loopGridView_:UnInit()
    self.loopGridView_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, false)
end

function Equip_enchant_left_subView:OnRefresh()
end

return Equip_enchant_left_subView
