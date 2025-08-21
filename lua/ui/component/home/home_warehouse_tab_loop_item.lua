local super = require("ui.component.loop_list_view_item")
local HomeWarehouseTabLoopItem = class("HomeWarehouseTabLoopItem", super)

function HomeWarehouseTabLoopItem:OnInit()
  self.onNode_ = self.uiBinder.on_node
  self.offNode_ = self.uiBinder.off_node
  self.offLab_ = self.uiBinder.lab_all_off
  self.onLab_ = self.uiBinder.lab_all_on
  self.offTabNode_ = self.uiBinder.node_tab_off
  self.onTabNode_ = self.uiBinder.node_tab_on
  self.uiView_ = self.parent.UIView
end

function HomeWarehouseTabLoopItem:OnRefresh(data)
  self.data_ = data
  self.offLab_.text = self.data_.groupName
  self.onLab_.text = self.data_.groupName
  local isSelected = self.uiView_:GetSecondSelectedId() == self.data_
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer, E.DynamicSteerType.HomeEditorTogId, self.data_.groupId)
  self:setState(isSelected)
end

function HomeWarehouseTabLoopItem:setState(isOn)
  self.uiBinder.Ref:SetVisible(self.onNode_, isOn)
  self.uiBinder.Ref:SetVisible(self.offNode_, not isOn)
end

function HomeWarehouseTabLoopItem:OnSelected(isSelected)
  local isSel = self.uiView_:GetSecondSelectedId() == self.data_
  if isSel then
    if isSelected then
      self.uiView_:SelectedTypeItem()
    end
    return
  end
  self:setState(isSelected)
  if isSelected then
    self.uiView_:SelectedTab(self.data_)
  end
end

function HomeWarehouseTabLoopItem:OnUnInit()
  self.uiBinder.steer:ClearSteerList()
end

return HomeWarehouseTabLoopItem
