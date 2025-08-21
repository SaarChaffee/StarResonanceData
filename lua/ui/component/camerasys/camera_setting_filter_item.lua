local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local CamSetFilterItem = class("CamSetFilterItem", super)
local itemPath = "ui/atlas/expression/tab_btn_emoji_icon"
local worldproxy = require("zproxy.world_proxy")
local filterPath = "ui/textures/photograph_decoration/filters/"

function CamSetFilterItem:ctor()
end

function CamSetFilterItem:OnInit()
end

function CamSetFilterItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  self.unit.icon.Tog.group = self.parent.uiView.content.TogGroup
  local splData = string.split(data.Res, "=")
  local icon = splData[1]
  local path = splData[2]
  self.unit.icon.Img:SetImage(string.format("%s%s", filterPath, icon))
  self.unit.icon.Tog:AddListener(function()
    if self.unit.icon.Tog.isOn then
      Z.CameraFrameCtrl:SetFilterAsync(path)
    end
  end)
end

function CamSetFilterItem:Selected(isSelected)
end

function CamSetFilterItem:OnBeforePlayAnim()
end

function CamSetFilterItem:OnUnInit()
end

return CamSetFilterItem
