local super = require("ui.model.data_base")
local BubbleData = class("BubbleData", super)

function BubbleData:ctor()
  super.ctor(self)
end

function BubbleData:Clear()
  self.curBubbleId_ = 0
  self.displayedBubbleView_ = false
end

function BubbleData:Init()
  self.curBubbleId_ = 0
  self.displayedBubbleView_ = false
end

function BubbleData:GetCurBubbleId()
  return self.curBubbleId_
end

function BubbleData:SetCurBubbleId(id)
  self.curBubbleId_ = id
end

function BubbleData:GetDisplayedBubbleView()
  return self.displayedBubbleView_
end

function BubbleData:SetDisplayedBubbleView(displayed)
  self.displayedBubbleView_ = displayed
end

return BubbleData
