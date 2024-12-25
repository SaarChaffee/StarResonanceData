local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local HistoryItem = class("HistoryItem", super)
local data = Z.DataMgr.Get("gm_data")

function HistoryItem:ctor()
  self.data = nil
end

function HistoryItem:OnInit()
end

function HistoryItem:OnRefresh(data)
  self.data = data
  self.uiBinder.history.text = self.data
end

function HistoryItem:OnPointerClick(go, eventData)
  Z.VMMgr.GetVM("gm").RefreshInputField(self.data)
  data.HIndex = 1
end

function HistoryItem:OnUnInit()
end

return HistoryItem
