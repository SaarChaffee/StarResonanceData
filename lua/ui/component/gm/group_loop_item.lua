local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local GroupItem = class("GroupItem", super)
local notSelectIcon = "ui/atlas/gm/yijiyeqian"
local selectIcon = "ui/atlas/gm/yijiyeqianxuanzhong"
local gmData = Z.DataMgr.Get("gm_data")

function GroupItem:ctor()
end

function GroupItem:OnInit()
end

function GroupItem:OnRefresh(data)
  self.data_ = data
  local tIndex = gmData.GIndex
  local tex_color = Color.New(1, 1, 1, 1)
  self.uiBinder.groupName.color = tex_color
  self.uiBinder.groupName.text = Lang(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.arrowicon, false)
  self.uiBinder.checkmark:SetImage(notSelectIcon)
end

function GroupItem:OnSelected(isSelected, isClick)
  if isSelected then
    Z.VMMgr.GetVM("gm").RefreshGmBtn(self.Index)
    gmData.GIndex = 1
    self.uiBinder.checkmark:SetImage(selectIcon)
    self.uiBinder.groupName.color = Color.New(0, 0, 0, 1)
    self.uiBinder.Ref:SetVisible(self.uiBinder.arrowicon, true)
  else
    self.uiBinder.checkmark:SetImage(notSelectIcon)
    self.uiBinder.groupName.color = Color.New(1, 1, 1, 1)
    self.uiBinder.Ref:SetVisible(self.uiBinder.arrowicon, false)
  end
end

function GroupItem:OnUnInit()
end

return GroupItem
