local super = require("ui.component.loop_list_view_item")
local CommonServerRewardLoopItem = class("CommonServerRewardLoopItem", super)
local itemBinder = require("common.item_binder")

function CommonServerRewardLoopItem:OnInit()
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonServerRewardLoopItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemData = {
    configId = data.configId,
    lab = data.count,
    isShowReceive = data.isReceived,
    labType = E.ItemLabType.Num,
    isShowZero = false,
    isShowOne = true,
    isSquareItem = true,
    PrevDropType = E.AwardPrevDropType.Definitely
  }
  self.itemBinder_:RefreshByData(itemData)
end

function CommonServerRewardLoopItem:OnUnInit()
  self.itemBinder_:UnInit()
end

return CommonServerRewardLoopItem
