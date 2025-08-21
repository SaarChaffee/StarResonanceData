local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleApply = class("ChatBubbleApply", super)

function ChatBubbleApply:ctor()
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.view_ = self.parent.UIView
end

function ChatBubbleApply:OnInit()
  super.OnInit(self)
  self.view_:AddAsyncClick(self.uiBinder.btn_go, function()
    self.teamVm_.AsyncApplyJoinTeam({})
  end)
end

function ChatBubbleApply:OnRefresh(data)
  super.OnRefresh(self, data)
end

return ChatBubbleApply
