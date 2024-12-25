local super = require("ui.component.loop_list_view_item")
local SceneLineLoopItem = class("SceneLineLoopItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function SceneLineLoopItem:ctor()
end

function SceneLineLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function SceneLineLoopItem:OnRefresh(data)
  self.data = data
  self.uiBinder.img_icon:SetImage(data.lineColor)
  self.uiBinder.lab_line_num.text = data.lineName
  self:setPlayerHead(self.uiBinder.node_head_1, 1)
  self:setPlayerHead(self.uiBinder.node_head_2, 2)
  self:setPlayerHead(self.uiBinder.node_head_3, 3)
  self:SelectState()
end

function SceneLineLoopItem:setPlayerHead(node_head, index)
  node_head.img_bg:RemoveAllListeners()
  if self.data.teamFriendSocialDatas[index] then
    Z.CoroUtil.create_coro_xpcall(function()
      node_head.Ref.UIComp:SetVisible(true)
      playerPortraitHgr.InsertNewPortraitBySocialData(node_head, self.data.teamFriendSocialDatas[index], function()
        self:showIdCard(index)
      end)
    end)()
  else
    node_head.Ref.UIComp:SetVisible(false)
  end
end

function SceneLineLoopItem:showIdCard(index)
  Z.CoroUtil.create_coro_xpcall(function()
    local charId = self.data.teamFriendSocialDatas[index].charId
    if charId and 0 < charId then
      Z.VMMgr.GetVM("idcard").AsyncGetCardData(charId, self.parentUIView.cancelSource:CreateToken())
    end
  end)()
end

function SceneLineLoopItem:Selected(isSelected)
  if isSelected then
    self.parentUIView:OnSceneLineSelect(self:GetCurData().sceneLineInfo.lineId)
  end
  self:SelectState()
end

function SceneLineLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function SceneLineLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function SceneLineLoopItem:OnUnInit()
end

return SceneLineLoopItem
