local UI = Z.UI
local super = require("ui.ui_subview_base")
local Equip_blessing_subView = class("Equip_blessing_subView", super)
local loop_list = require("ui.component.loop_list_view")
local loop_item = require("ui.component.equip.equip_blessing_loop_item")

function Equip_blessing_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath
  if Z.IsPCUI then
    assetPath = "equip/equip_blessing_sub_pc"
  else
    assetPath = "equip/equip_blessing_sub"
  end
  super.ctor(self, "equip_blessing_sub", assetPath, UI.ECacheLv.None)
  self.equipCfgData_ = Z.DataMgr.Get("equip_config_data")
  self.equipRefineData_ = Z.DataMgr.Get("equip_refine_data")
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
  local loadItem
  if Z.IsPCUI then
    loadItem = "equip_blessing_item_tpl_pc"
  else
    loadItem = "equip_blessing_item_tpl"
  end
  self.loopListView_ = loop_list.new(self, self.itemList_, loop_item, loadItem)
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

function Equip_blessing_subView:OnSelectedItem(configId, count, successRate)
  self.equipRefineData_.CurSelBlessingData[configId] = {
    configId = configId,
    num = count,
    rate = successRate
  }
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipRefreshSelBlessingData)
end

function Equip_blessing_subView:OnChangeNum(configId, count, successRate)
  local data = self.equipRefineData_.CurSelBlessingData[configId]
  if data and data.num ~= count then
    self.equipRefineData_.CurSelBlessingData[configId].num = count
    self.equipRefineData_.CurSelBlessingData[configId].rate = successRate
    Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipRefreshSelBlessingData)
  end
end

function Equip_blessing_subView:GetSelectedInfo(configId)
  return self.equipRefineData_.CurSelBlessingData[configId]
end

function Equip_blessing_subView:OnRefresh()
end

return Equip_blessing_subView
