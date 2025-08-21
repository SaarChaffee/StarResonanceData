local super = require("ui.component.loop_grid_view_item")
local HomeSelectedLoopItem = class("HomeSelectedLoopItem", super)
local groupPath = "home_combination"

function HomeSelectedLoopItem:ctor()
end

function HomeSelectedLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.homeEditorData_ = Z.DataMgr.Get("home_editor_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.uiView_:AddClick(self.uiBinder.btn_minus, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Home.CancelSelectedItem, self.data_)
  end)
end

function HomeSelectedLoopItem:OnRefresh(data)
  self.data_ = data
  if data.IsGroup then
    self.uiBinder.rimg_icon:SetImage(groupPath)
  else
    local configId = self.homeEditorData_.HouseItemUUidMap[data.EntityUid]
    if configId then
      local path = self.itemsVm_.GetItemIcon(configId)
      self.uiBinder.rimg_icon:SetImage(path)
    end
  end
end

function HomeSelectedLoopItem:OnPointerClick(go, eventData)
end

function HomeSelectedLoopItem:OnRecycle()
end

function HomeSelectedLoopItem:OnUnInit()
end

return HomeSelectedLoopItem
