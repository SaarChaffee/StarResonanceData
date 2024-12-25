local super = require("ui.component.loop_list_view_item")
local UnionTaskLoopListItem = class("UnionTaskLoopListItem", super)

function UnionTaskLoopListItem:OnInit()
  self.itemList_ = {
    self.uiBinder.union_task_tpl_01,
    self.uiBinder.union_task_tpl_02,
    self.uiBinder.union_task_tpl_03,
    self.uiBinder.union_task_tpl_04
  }
  self.quickJumpVm_ = Z.VMMgr.GetVM("quick_jump")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.parentUIView_ = self.parent.UIView
  for k, v in pairs(self.itemList_) do
    v.btn_item:AddListener(function()
      local data = self.itemDataList_[k]
      self.parentUIView_:OpenItemTips(nil, data.itemTableData.Id)
      self.parentUIView_:OnClickItem(data, self.Index)
    end)
  end
end

function UnionTaskLoopListItem:OnRefresh(data)
  self.itemDataList_ = data.Data
  self:refreshItemList()
end

function UnionTaskLoopListItem:refreshItemList()
  for k, v in pairs(self.itemList_) do
    if k > #self.itemDataList_ then
      self.uiBinder.Ref:SetVisible(v.Trans, false)
    else
      self.uiBinder.Ref:SetVisible(v.Trans, true)
      self:setItemData(self.itemDataList_[k], v)
    end
  end
end

function UnionTaskLoopListItem:setItemData(data, item)
  local itemData = data.itemTableData
  local resloveData = data.resolveData
  item.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(itemData.Id))
  local haveCount = self.itemsVM_.GetItemTotalCount(itemData.Id)
  item.lab_num.text = Z.NumTools.NumberToK(haveCount)
  local offsetNum = self.parentUIView_:GetPriceOffsetNum(data.offsetType)
  local truePrice = resloveData.SingleValue * offsetNum
  item.lab_count.text = string.format("%.0f", truePrice)
  local quaity = itemData.Quality
  item.img_panel:SetImage(Z.ConstValue.Item.ShopItemQualityImage .. quaity)
  local isSelect = resloveData.Id == self.parentUIView_:CheckItemIsSelect()
  item.Ref:SetVisible(item.img_on, isSelect)
end

function UnionTaskLoopListItem:resetItemState(item)
  item.Ref:SetVisible(item.img_update, false)
  item.Ref:SetVisible(item.img_finish, false)
end

function UnionTaskLoopListItem:OnUnInit()
  self.itemList_ = {}
end

return UnionTaskLoopListItem
