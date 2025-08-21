local super = require("ui.component.loop_list_view_item")
local UnionBuildBuffItem = class("UnionBuildBuffItem", super)
local POS_TIME_X = 40
local POS_EFFECT_X = 95

function UnionBuildBuffItem:OnInit()
end

function UnionBuildBuffItem:OnRefresh(data)
  if data.Type == "Time" then
    local buffTime = data.Value
    self.uiBinder.lab_desc.text = Lang("UnionBuffTimeTipsDesc", {
      time = Z.TimeFormatTools.FormatToDHMS(buffTime, true)
    })
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
    self.uiBinder.trans_desc:SetAnchorPosition(POS_TIME_X, 0)
  elseif data.Type == "Effect" then
    local buffConfig = data.Value
    self.uiBinder.img_icon:SetImage(buffConfig.Icon)
    self.uiBinder.lab_desc.text = buffConfig.Desc
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
    self.uiBinder.trans_desc:SetAnchorPosition(POS_EFFECT_X, 0)
  end
end

function UnionBuildBuffItem:OnUnInit()
end

return UnionBuildBuffItem
