local super = require("ui.component.loop_list_view_item")
local BagSelectPackLoopItem = class("BagSelectPackLoopItem", super)
local item = require("common.item_binder")

function BagSelectPackLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self:initFunc()
  self.showItemId_ = 0
end

function BagSelectPackLoopItem:OnRefresh(data)
  self.data_ = data
  self:refreshUseNum()
  self:refreshBtnState()
  self:refreshItemLimit()
  if self.showItemId_ ~= self.data_.itemId then
    self.showItemId_ = self.data_.itemId
    local itemData = {
      uiBinder = self.uiBinder.item_square,
      configId = self.data_.itemId,
      labType = E.ItemLabType.Str,
      lab = self.data_.itemNum,
      isBind = self.data_.bindInfo == 1,
      isSquareItem = true,
      isHideSource = true
    }
    self.itemClass_:Init(itemData)
    if self.data_.isHave then
      self.uiBinder.item_square.rimg_icon:SetGray()
    else
      self.uiBinder.item_square.rimg_icon:ClearGray()
    end
  end
end

function BagSelectPackLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function BagSelectPackLoopItem:initFunc()
  self.uiBinder.btn_add:AddListener(function()
    self:changeUseNum(1)
  end)
  self.uiBinder.btn_reduce:AddListener(function()
    self:changeUseNum(-1)
  end)
  self.uiBinder.btn_num:AddListener(function()
    if self.data_.isHave then
      return
    end
    self.parent.UIView:OpenSelectItemNum(self.data_.itemId, self.data_.selectNum, self.uiBinder.node_pad, self.data_.isLimit)
  end)
end

function BagSelectPackLoopItem:changeUseNum(num)
  if self.data_.isHave then
    return
  end
  local newCount = self.data_.selectNum + num
  if newCount < 0 then
    return
  end
  if 1 < newCount and self.data_.isLimit then
    Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 122013})
    return
  end
  self.parent.UIView:ChangeSelectItemNum(self.data_.itemId, newCount)
end

function BagSelectPackLoopItem:refreshUseNum()
  self.uiBinder.lab_num.text = tostring(self.data_.selectNum)
end

function BagSelectPackLoopItem:refreshBtnState()
  if self.data_.selectNum == 0 then
    self.uiBinder.btn_reduce_alpha.alpha = 0.3
  else
    self.uiBinder.btn_reduce_alpha.alpha = 1
  end
  if self.parent.UIView:IsCanAddNum() then
    self.uiBinder.btn_add_alpha.alpha = 1
  else
    self.uiBinder.btn_add_alpha.alpha = 0.3
  end
  if self.data_.isHave then
    self.uiBinder.btn_reduce_alpha.alpha = 0.3
    self.uiBinder.btn_add_alpha.alpha = 0.3
  end
end

function BagSelectPackLoopItem:refreshItemLimit()
  self.uiBinder.btn_add.IsDisabled = self.data_.isHave
  self.uiBinder.btn_reduce.IsDisabled = self.data_.isHave
  self.uiBinder.btn_num.IsDisabled = self.data_.isHave
end

return BagSelectPackLoopItem
