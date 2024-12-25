local super = require("ui.component.loopscrollrectitem")
local itemPath = "ui/prefabs/home_editor/home_furniture_btn_tpl"
local HomeWarehouseTabLoopItem = class("HomeWarehouseTabLoopItem", super)

function HomeWarehouseTabLoopItem:OnInit()
  self.tabLoop_ = self.uiBinder.scroll_child
  self.onIconImg_ = self.uiBinder.img_adsorb_on
  self.offIconImg_ = self.uiBinder.img_adsorb_off
  self.onNode_ = self.uiBinder.on_node
  self.offNode_ = self.uiBinder.off_node
  self.content_ = self.uiBinder.node_content
  self.toggleGroup = self.uiBinder.tog_group
end

function HomeWarehouseTabLoopItem:Refresh()
  self.allUnit_ = {}
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  if self.data_ then
    self.onIconImg_:SetImage(self.data_.iconPath)
    self.offIconImg_:SetImage(self.data_.iconPath)
    for index, value in ipairs(self.data_.homeTypes) do
      local name = "warthouse_tab" .. self.data_.groupId .. index
      local item = self.parent.uiView:AsyncLoadUiUnit(itemPath, name, self.content_.transform)
      if item then
        item.toggle.isOn = false
        item.toggle.group = self.toggleGroup
        self.allUnit_[name] = item
        item.img_select:SetImage(value.iconPath)
        item.img_unselected:SetImage(value.iconPath)
        self.parent.uiView:AddClick(item.toggle, function(isOn)
          if isOn then
            self:setWareHouseData(index)
          end
        end)
      end
    end
    self:setState(false)
  end
end

function HomeWarehouseTabLoopItem:setWareHouseData(key)
  if self.data_.homeTypes[key] then
    self.parent.uiView:SetWareHouseData(self.data_.homeTypes[key].typeId)
  end
end

function HomeWarehouseTabLoopItem:onClickTog()
  if self.data_.groupId == -1 then
    self.parent.uiView:SetWareHouseData(self.data_.groupId)
  else
    local item = self.allUnit_["warthouse_tab" .. self.data_.groupId .. "1"]
    if item then
      item.toggle.isOn = true
    end
    self:setWareHouseData(1)
  end
end

function HomeWarehouseTabLoopItem:unClockTog()
end

function HomeWarehouseTabLoopItem:setState(isOn)
  self.uiBinder.Ref:SetVisible(self.tabLoop_, isOn)
  self.uiBinder.Ref:SetVisible(self.onNode_, isOn)
  self.uiBinder.Ref:SetVisible(self.offNode_, not isOn)
end

function HomeWarehouseTabLoopItem:Selected(isSelected)
  self:setState(isSelected)
  if isSelected then
    self:onClickTog()
  else
    self:unClockTog()
  end
end

function HomeWarehouseTabLoopItem:UnInit()
  for name, value in ipairs(self.allUnit_) do
    self.parent.uiView:RemoveUiUnit(name)
  end
  self.allUnit_ = nil
end

return HomeWarehouseTabLoopItem
