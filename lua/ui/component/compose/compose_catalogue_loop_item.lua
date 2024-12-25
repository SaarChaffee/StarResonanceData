local super = require("ui.component.loopscrollrectitem")
local ComposeCatalogueLoopItem = class("ComposeCatalogueLoopItem", super)
local item = require("common.item")

function ComposeCatalogueLoopItem:ctor()
end

function ComposeCatalogueLoopItem:OnInit()
  self.composeView_ = self.parent.uiView
  self.itemClass_ = item.new(self.composeView_)
  self.unit.btn_icon.Btn:AddListener(function()
    self.parent:ClearSelected()
    self.parent:SetSelected(self.component.Index)
    self.composeView_:ShowConsumeItemTips(self.itemData_.configId)
  end)
end

function ComposeCatalogueLoopItem:Refresh()
  self.isSelected = false
  local index_ = self.component.Index + 1
  self.itemData_ = self.parent:GetDataByIndex(index_)
  Z.CoroUtil.create_coro_xpcall(function()
    self.composeView_:AsyncLoadUiUnit("ui/prefabs/new_common/c_com_item_backpack_tpl", self, self.unit.pos_icon.Trans)
    local itemUnit_ = self.composeView_.units[self]
    self.itemClass_:Init({
      unit = itemUnit_,
      configId = self.itemData_.configId,
      lab = self.itemData_.num,
      labType = E.ItemLabType.Str
    })
  end)()
  local itemTblData_ = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.configId)
  if itemTblData_ == nil then
    return
  end
  self.unit.lab_name.TMPLab.text = itemTblData_.Name
end

function ComposeCatalogueLoopItem:Selected(isSelected)
  self.unit.img_selected:SetVisible(isSelected)
  if self.isSelected == isSelected then
    return
  end
  self.isSelected = isSelected
  if isSelected then
    self.composeView_:SwitchItemByConsumeId(self.itemData_.configId)
  end
end

function ComposeCatalogueLoopItem:OnUnInit()
  self.isSelected = false
  self.itemClass_:UnInit()
end

function ComposeCatalogueLoopItem:OnReset()
  self.isSelected = false
end

return ComposeCatalogueLoopItem
