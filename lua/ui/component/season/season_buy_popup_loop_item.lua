local super = require("ui.component.loop_list_view_item")
local SeasonBuyPopupLoopItem = class("SeasonBuyPopupLoopItem", super)
local iClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function SeasonBuyPopupLoopItem:ctor()
end

function SeasonBuyPopupLoopItem:OnInit()
  if self.initTag_ then
    return
  end
  self.initTag_ = true
  self.itemClass_ = iClass.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function SeasonBuyPopupLoopItem:Refresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.awardId,
    isSquareItem = true,
    PrevDropType = data.PrevDropType
  }
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
  self.itemClass_:RefreshByData(itemData)
end

function SeasonBuyPopupLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return SeasonBuyPopupLoopItem
