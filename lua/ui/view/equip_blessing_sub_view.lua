local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_blessing_subView = class("Equip_blessing_subView", super)
local loop_list = require("ui.component.loop_list_view")
local loop_item = require("ui.component.equip.equip_blessing_loop_item")

function Equip_blessing_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "equip_blessing_sub", "equip/equip_blessing_sub", UI.ECacheLv.None)
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
end

function Equip_blessing_subView:initBinders()
  self.closeBnt_ = self.uiBinder.btn_return
  self.itemList_ = self.uiBinder.loop_item
  self.press_ = self.uiBinder.node_press
end

function Equip_blessing_subView:initBtns()
  self:AddClick(self.closeBnt_, function()
    self:DeActive()
  end)
  self:EventAddAsyncListener(self.press_.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:DeActive()
    end
  end, nil, nil)
end

function Equip_blessing_subView:initDatas()
  self.ItemCount = {}
end

function Equip_blessing_subView:StartCheck()
  self.press_:StartCheck()
end

function Equip_blessing_subView:StopCheck()
  self.press_:StopCheck()
end

function Equip_blessing_subView:initUi()
  local part = self.viewData.part
  local congfigs = self.equipCfgData_.RefineBlessingTableData[part] or {}
  self.loopListView_ = loop_list.new(self, self.itemList_, loop_item, "equip_blessing_item_tpl")
  self.loopListView_:Init(congfigs)
  self:StartCheck()
end

function Equip_blessing_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initBinders()
  self:initBtns()
  self:initDatas()
  self:initUi()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, true)
end

function Equip_blessing_subView:OnDeActive()
  self:StopCheck()
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.IsHideLeftView, false)
end

function Equip_blessing_subView:OnSelectedItem(congfigId, count, successRate)
  self.ItemCount[congfigId] = count
  Z.EventMgr:Dispatch("selectedBlessingItem", congfigId, count, successRate)
end

function Equip_blessing_subView:OnChangeNum(congfigId, count, successRate)
  self.ItemCount[congfigId] = count
  Z.EventMgr:Dispatch("blessingItemCountChange", congfigId, count, successRate)
end

function Equip_blessing_subView:GetSelectedCount(congfigId)
  return self.ItemCount[congfigId]
end

function Equip_blessing_subView:OnRefresh()
end

return Equip_blessing_subView
