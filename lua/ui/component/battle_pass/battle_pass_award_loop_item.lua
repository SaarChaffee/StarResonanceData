local super = require("ui.component.loopscrollrectitem")
local BattlePassAwardLoopItem = class("BattlePassAwardLoopItem", super)
local iClass = require("common.item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function BattlePassAwardLoopItem:ctor()
end

function BattlePassAwardLoopItem:OnInit()
  if self.initTag_ then
    return
  end
  self.initTag_ = true
  self.itemClass_ = iClass.new(self.parent.uiView)
end

function BattlePassAwardLoopItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  local awardInfo = awardPreviewVm.GetAllAwardPreListByIds(data)
  for k, v in pairs(awardInfo) do
    local itemData = {
      unit = self.unit,
      configId = v.awardId,
      isSquareItem = true,
      PrevDropType = v.PrevDropType
    }
    itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(v)
    self.itemClass_:Init(itemData)
    self.itemClass_:SetRedDot(false)
  end
end

function BattlePassAwardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return BattlePassAwardLoopItem
