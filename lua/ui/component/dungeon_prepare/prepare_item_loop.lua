local super = require("ui.component.loop_list_view_item")
local PrepareLoopItem = class("PrepareLoopItem", super)

function PrepareLoopItem:ctor()
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function PrepareLoopItem:OnInit()
end

function PrepareLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_right, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_wrong, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, data.itemNum == 0)
  self.uiBinder.lab_content.text = data.itemNum
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.itemId)
  if itemRow then
    local iconPath = self.itemsVm_.GetItemIcon(data.itemId)
    self.uiBinder.rimg_icon:SetImage(iconPath)
    local qualityIconPath = Z.ConstValue.Item.SquareItemQualityPath .. itemRow.Quality
    self.uiBinder.img_quality:SetImage(qualityIconPath)
  end
end

function PrepareLoopItem:OnPointerClick()
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.data_.itemId)
end

function PrepareLoopItem:OnUnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

return PrepareLoopItem
