local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local EmojiBigItem = class("EmojiBigItem", super)
local worldproxy = require("zproxy.world_proxy")

function EmojiBigItem:ctor()
end

function EmojiBigItem:OnInit()
end

function EmojiBigItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
end

function EmojiBigItem:Selected(isSelected)
end

function EmojiBigItem:PlayAnim()
end

function EmojiBigItem:OnBeforePlayAnim()
end

function EmojiBigItem:OnUnInit()
end

return EmojiBigItem
