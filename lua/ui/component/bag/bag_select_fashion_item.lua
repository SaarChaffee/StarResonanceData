local super = require("ui.component.loop_list_view_item")
local BagSelectFashionItem = class("BagSelectFashionItem", super)
local imagePath = "ui/textures/gift_package/gift_item_prop_"

function BagSelectFashionItem:OnInit()
  self.uiBinder.btn_select:AddListener(function()
    if self.data_.isHave then
      Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 122012})
      return
    end
    self.parent.UIView:SetSelected(self.Index, self.data_.index)
  end)
  self.uiBinder.btn_check:AddListener(function()
    local item_preview = Z.VMMgr.GetVM("item_preview")
    item_preview.GotoPreview(self.data_.itemId)
  end)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function BagSelectFashionItem:OnUnInit()
end

function BagSelectFashionItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(data.itemId))
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.itemId)
  if itemRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_quality, itemRow.Quality >= 3)
    if itemRow.Quality >= 3 then
      self.uiBinder.rimg_quality:SetImage(imagePath .. itemRow.Quality)
    end
  end
  if data.isHave then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, true)
    self.uiBinder.rimg_icon:SetGray()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lab, true)
    self.uiBinder.lab_num.text = Lang("FashionShopHave")
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, false)
    self.uiBinder.rimg_icon:ClearGray()
    if data.itemNum > 1 then
      self.uiBinder.lab_num.text = data.itemNum
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lab, data.itemNum > 1)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function BagSelectFashionItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return BagSelectFashionItem
