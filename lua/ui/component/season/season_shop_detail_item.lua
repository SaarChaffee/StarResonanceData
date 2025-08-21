local super = require("ui.component.loop_grid_view_item")
local SeasonShopDetailItem = class("SeasonShopDetailItem", super)
local item = require("common.item_binder")

function SeasonShopDetailItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function SeasonShopDetailItem:OnUnInit()
  self.itemClass_:UnInit()
end

function SeasonShopDetailItem:OnRefresh(data)
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder
  itemData.awardNum = data.awardNum
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, false)
  self.uiBinder.canvas_detail.alpha = 0
  self.uiBinder.lab_detail.text = ""
  if data.tagData and data.tagData.type == 1 then
    self.uiBinder.lab_detail.text = Lang(data.tagData.param)
    self.uiBinder.canvas_detail.alpha = 1
  end
end

return SeasonShopDetailItem
