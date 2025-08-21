local super = require("ui.component.loop_list_view_item")
local FriendGroupItemPC = class("FriendGroupItemPC", super)

function FriendGroupItemPC:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
end

function FriendGroupItemPC:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_group_on.text = self.data_.GroupName
  self.uiBinder.lab_group_off.text = self.data_.GroupName
  self:refreshOnlineNum()
  self:refreshSelectState()
end

function FriendGroupItemPC:OnSelected(isSelected, isClick)
  self:onSelectedGroup()
  self:refreshSelectState()
end

function FriendGroupItemPC:onSelectedGroup()
  self.parent.UIView:OnSelectFriendGroup(self.data_.GroupId, self.IsSelected, self.data_.IsDefault)
end

function FriendGroupItemPC:refreshSelectState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
end

function FriendGroupItemPC:refreshOnlineNum()
  local friendList = self.friendMainData_:GetGroupAndFriendData(self.data_.GroupId)
  local totalNum = table.zcount(friendList)
  local onLineNum = 0
  for _, friend in pairs(friendList) do
    if friend:GetPlayerOffLineTime() == 0 then
      onLineNum = onLineNum + 1
    end
  end
  self.uiBinder.lab_num_on.text = onLineNum .. "/" .. totalNum
  self.uiBinder.lab_num_off.text = onLineNum .. "/" .. totalNum
end

return FriendGroupItemPC
