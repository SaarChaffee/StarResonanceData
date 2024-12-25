local UnionTaskItem = class("UnionTaskItem")

function UnionTaskItem:ctor(parent)
  self.parentView_ = parent
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function UnionTaskItem:Init(itemData)
  if itemData.uiBinder == nil then
    self:UnInit()
    return
  end
  self.data = itemData
  self.uiBinder = itemData.uiBinder
  if not self.hasInit_ then
    self.hasInit_ = true
    self.uiBinder.img_panel:AddListener(function()
      self:ClickFunction()
    end)
  end
  self.uiBinder.rimg_icon:SetImage("")
  local itemId_ = 0
  local count_ = self.itemsVm_.GetItemTotalCount(itemId_)
  self.uiBinder.lab_count.text = count_
  local price = 0
  self.uiBinder.lab_num.text = price
  self.canClick_ = itemData.canClick
end

function UnionTaskItem:UnInit()
  self.itemData_ = nil
  self.uiBinder = nil
  self.hasInit_ = nil
end

function UnionTaskItem:ClickFunction()
  if self.canClick_ == true then
    self.parentView_:ClickLeftItem(self.data)
  end
end

return UnionTaskItem
