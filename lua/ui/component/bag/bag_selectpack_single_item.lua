local super = require("ui.component.loop_list_view_item")
local BagSelectPackSingleLoopItem = class("BagSelectPackSingleLoopItem", super)
local item = require("common.item_binder")

function BagSelectPackSingleLoopItem:OnInit()
  self.showItemId_ = 0
  self.itemClass_ = item.new(self.parent.UIView)
  self.uiBinder.btn_temp:AddListener(function()
    if self.IsSelected or self.data_.isHave then
      if self.data_.isHave then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 122012})
      end
      self:openTips()
    else
      self.parent.UIView:SetSelected(self.Index, self.data_.itemId)
    end
  end)
end

function BagSelectPackSingleLoopItem:OnRefresh(data)
  self.data_ = data
  if self.showItemId_ ~= self.data_.itemId then
    self.showItemId_ = self.data_.itemId
    local itemData = {
      uiBinder = self.uiBinder,
      configId = self.data_.itemId,
      labType = E.ItemLabType.Str,
      lab = self.data_.itemNum,
      isBind = self.data_.bindInfo == 1,
      isSquareItem = true,
      isClickOpenTips = false,
      isHideSource = true
    }
    self.itemClass_:Init(itemData)
  end
  if self.data_.isHave then
    self.uiBinder.rimg_icon:SetGray()
    self.uiBinder.lab_content.text = Lang("FashionShopHave")
  else
    self.uiBinder.rimg_icon:ClearGray()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_temp, true)
  self.itemClass_:SetSelected(self.IsSelected)
  self.itemClass_:SetSelectedGreen(self.IsSelected)
end

function BagSelectPackSingleLoopItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected)
  self.itemClass_:SetSelectedGreen(isSelected)
  if isSelected then
    self:openTips()
  end
end

function BagSelectPackSingleLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function BagSelectPackSingleLoopItem:openTips()
  self.itemClass_:BtnTempClick()
end

return BagSelectPackSingleLoopItem
