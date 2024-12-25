local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local CamSetFrameItem = class("CamSetFrameItem", super)
local itemPath = "ui/atlas/expression/tab_btn_emoji_icon"
local worldproxy = require("zproxy.world_proxy")
local filterPath = "ui/atlas/photograph_decoration/frame/"

function CamSetFrameItem:ctor()
end

function CamSetFrameItem:OnInit()
end

function CamSetFrameItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  self.unit.icon.Tog.group = self.parent.uiView.content.TogGroup
  self.unit.icon.Img:SetImage(string.format("%s%s", filterPath, data.Res))
  self.unit.icon.Tog:AddListener(function()
    if self.unit.icon.Tog.isOn then
    end
  end)
end

function CamSetFrameItem:Selected(isSelected)
end

function CamSetFrameItem:OnBeforePlayAnim()
end

function CamSetFrameItem:OnUnInit()
end

return CamSetFrameItem
