local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleUnion = class("ChatBubbleUnion", super)

function ChatBubbleUnion:OnInit()
  super.OnInit(self)
  self.uiBinder.btn_go:AddListener(function()
    if self.data_ then
      local unionBuild = Z.ChatMsgHelper.GetUnionBuild(self.data_)
      if unionBuild then
        local quickjumpVm_ = Z.VMMgr.GetVM("quick_jump")
        quickjumpVm_.DoJumpByConfigParam(unionBuild.QuickJumpType, unionBuild.QuickJumpParam)
      end
    end
  end)
end

function ChatBubbleUnion:OnRefresh(data)
  super.OnRefresh(self, data)
  self:refreshUnionInfo()
end

function ChatBubbleUnion:refreshUnionInfo()
  local content = self.chatMainVm_.GetShowMsg(self.data_)
  self.uiBinder.lab_content.text = content
  local size = self.uiBinder.lab_content:GetPreferredValues(content, 208, 32)
  local height = math.max(size.y, 120)
  self.uiBinder.lab_content_ref:SetHeight(height)
  self.uiBinder.img_bg_ref:SetHeight(height + 120)
  local unionBuild = Z.ChatMsgHelper.GetUnionBuild(self.data_)
  if unionBuild then
    self.uiBinder.img_icon:SetImage(unionBuild.SmallPicture)
  end
  if self.isShowChannelOrName_ then
    self.uiBinder.img_bg_ref:SetAnchorPosition(143, -65)
    self.uiBinder.Trans:SetHeight(height + 190)
  else
    self.uiBinder.img_bg_ref:SetAnchorPosition(143, -31.7)
    self.uiBinder.Trans:SetHeight(height + 156.7)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

return ChatBubbleUnion
