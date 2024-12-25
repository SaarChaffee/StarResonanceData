local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local EmojiSmallItem = class("EmojiSmallItem", super)
local worldproxy = require("zproxy.world_proxy")

function EmojiSmallItem:ctor()
end

function EmojiSmallItem:OnInit()
end

function EmojiSmallItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
end

function EmojiSmallItem:Selected(isSelected)
end

function EmojiSmallItem:PlayAnim()
end

function EmojiSmallItem:OnBeforePlayAnim()
end

function EmojiSmallItem:OnUnInit()
end

return EmojiSmallItem
