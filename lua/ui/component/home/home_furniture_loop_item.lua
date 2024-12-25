local super = require("ui.component.loopscrollrectitem")
local HomeFurnitureLoopItem = class("HomeFurnitureLoopItem", super)
local itemPath = "ui/prefabs/home_editor/home_furniture_name_item_tpl"

function HomeFurnitureLoopItem:OnInit()
  self.nameLoop_ = self.uiBinder.scroll_item
  self.nameLab_ = self.uiBinder.lab_name
  self.allUnit_ = {}
end

function HomeFurnitureLoopItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  if data then
    local housingItemsTypeRow = Z.TableMgr.GetTable("HousingItemsTypeMgr").GetRow(data.typeId)
    if housingItemsTypeRow then
      self.nameLab_.text = housingItemsTypeRow.Name
      for name, value in ipairs(self.allUnit_) do
        local isHave = false
        for _, homelandData in ipairs(data.homelandData) do
          local itemName = "furniture_item" .. homelandData.clientUuid
          if itemName == name then
            isHave = true
            break
          end
        end
        if isHave == false then
          self.parent.uiView:RemoveUiUnit(name)
        end
      end
      self.allUnit_ = {}
      for index, value in pairs(data.homelandData) do
        local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.itemId)
        if itemTableRow then
          local name = "furniture_item" .. value.clientUuid
          local item = self.parent.uiView:AsyncLoadUiUnit(itemPath, name, self.nameLoop_.content.transform)
          if item then
            self.allUnit_[name] = item
            item.lab_furniture_name.text = itemTableRow.Name
            local itemsVm = Z.VMMgr.GetVM("items")
            item.img_furniture_icon:SetImage(itemsVm.GetItemIcon(value.itemId))
            self.parent.uiView:AddClick(item.btn_click, function()
              Z.DIServiceMgr.HomeService:SelectEntity(value.clientUuid, true)
              Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelectingSingle, value.clientUuid, value.itemId)
            end)
          end
        end
      end
    end
  end
end

function HomeFurnitureLoopItem:Selected(isSelected)
end

function HomeFurnitureLoopItem:UnInit()
  for name, value in ipairs(self.allUnit_) do
    self.parent.uiView:RemoveUiUnit(name)
  end
end

return HomeFurnitureLoopItem
