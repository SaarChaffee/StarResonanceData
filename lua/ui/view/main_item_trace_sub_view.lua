local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_item_trace_subView = class("Main_item_trace_subView", super)
local pos = {
  [E.ItemTracePosType.Top] = Vector3.New(0, 77, 0),
  [E.ItemTracePosType.Right] = Vector3.New(77, 0, 0)
}
local rotateZ = {
  [E.ItemTracePosType.Top] = 0,
  [E.ItemTracePosType.Right] = -90
}

function Main_item_trace_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_item_trace_sub", "main/main_item_trace_sub", UI.ECacheLv.None)
  self.itemTraceData_ = Z.DataMgr.Get("item_trace_data")
  self.itemTraceVm_ = Z.VMMgr.GetVM("item_trace")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function Main_item_trace_subView:initBinders()
  self.btn_ = self.uiBinder.btn
  self.iconRImg_ = self.uiBinder.rimg_icon
  self.qualityImg_ = self.uiBinder.img_quality
  self.arrowImg_ = self.uiBinder.img_arrow
end

function Main_item_trace_subView:initBtns()
  self:AddClick(self.btn_, function()
    self.itemTraceVm_.OpenTracePopup()
  end)
end

function Main_item_trace_subView:initUi()
  self.eventIds_ = {}
  local rotateValue = 0
  local pos = pos[E.ItemTracePosType.Top]
  self.arrowImg_.transform:SetAnchorPosition(pos.x, pos.y)
  self.arrowImg_.transform:SetLocalEuler(0, 0, rotateValue)
  self:refreshUi()
end

function Main_item_trace_subView:refreshUi()
  local configId = self.itemTraceData_.CurTraceItemId
  local materialIds = self.itemTraceData_.CurTraceMaterialList
  if configId and configId ~= 0 then
    local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if not itemRow then
      return
    end
    local path = self.itemVm_.GetItemIcon(configId)
    if path ~= "" then
      self.iconRImg_:SetImage(path)
    end
    self.qualityImg_:SetImage(Z.ConstValue.QualityImgCircleBg .. itemRow.Quality)
    self.uiBinder.Ref.UIComp:SetVisible(true)
    self:bindEvent()
  else
    self.uiBinder.Ref.UIComp:SetVisible(false)
    self:removeEvent()
  end
end

function Main_item_trace_subView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initUi()
  Z.EventMgr:Add(Z.ConstValue.RefreshItemTrace, self.refreshUi, self)
end

function Main_item_trace_subView:checkItem()
  for index, value in ipairs(self.itemTraceData_.CurTraceMaterialList) do
    local count = self.itemVm_.GetItemTotalCount(value.ItemId)
    if count < value.ItemNum then
      return
    end
  end
  self:removeEvent()
  Z.TipsVM.ShowTips(122025)
end

function Main_item_trace_subView:removeEvent()
  for index, value in ipairs(self.eventIds_) do
    Z.ItemEventMgr.Remove(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, value, self.checkItem, self)
  end
  self.eventIds_ = {}
end

function Main_item_trace_subView:bindEvent()
  for index, value in ipairs(self.itemTraceData_.CurTraceMaterialList) do
    self.eventIds_[index] = value.ItemId
    Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, value.ItemId, self.checkItem, self)
  end
end

function Main_item_trace_subView:OnDeActive()
  self.qualityImg_:ClearAll()
  self:removeEvent()
end

function Main_item_trace_subView:OnRefresh()
end

return Main_item_trace_subView
