local super = require("ui.component.loopscrollrectitem")
local item = require("common.item")
local ComRewardDetailLoopItem = class("ComRewardDetailLoopItem", super)

function ComRewardDetailLoopItem:ctor()
end

function ComRewardDetailLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function ComRewardDetailLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function ComRewardDetailLoopItem:OnPointerClick(go, eventData)
  Z.TipsVM.ShowItemTipsView(self.unit.Trans, self.mailData_.configId)
end

function ComRewardDetailLoopItem:Refresh()
  local index = self.component.Index + 1
  self.mailData_ = self.parent:GetDataByIndex(index)
  self.itemClass_:Init({
    unit = self.unit,
    configId = self.mailData_.configId,
    uuid = self.mailData_.uuid,
    lab = self.mailData_.count,
    itemInfo = self.mailData_,
    isSquareItem = true,
    goToCallFunc = function()
      Z.UIMgr:CloseView("reward_preview_popup")
    end
  })
end

function ComRewardDetailLoopItem:Selected(isSelected)
end

return ComRewardDetailLoopItem
