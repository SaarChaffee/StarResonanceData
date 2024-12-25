local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleUnionNew = class("ChatBubbleUnionNew", super)

function ChatBubbleUnionNew:OnInit()
  super.OnInit(self)
  self.uiBinder.btn_go:AddListener(function()
    Z.UIMgr:OpenView("union_unlockscene_main")
  end)
end

function ChatBubbleUnionNew:OnRefresh(data)
  super.OnRefresh(self, data)
  self:refreshUnionInfo()
end

function ChatBubbleUnionNew:refreshUnionInfo()
  local content, param = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = content
  if param then
    local val1 = 0
    local val2 = 1
    if param.arrVal then
      val1 = param.arrVal[1] or 0
      val2 = param.arrVal[2] or 1
    end
    self.uiBinder.lab_num.text = string.format("%s/%s", val1, val2)
    if val1 < val2 then
      self.uiBinder.lab_btn.text = Lang("Participatecrowdfunding")
    else
      self.uiBinder.lab_btn.text = Lang("Participatecrowdjioning")
    end
  end
  local x = self.uiBinder.img_bg_ref:GetAnchorPosition(nil, nil)
  if self.isShowChannelOrName_ then
    self.uiBinder.img_bg_ref:SetAnchorPosition(x, -50)
    self.uiBinder.Trans:SetHeight(365)
  else
    self.uiBinder.img_bg_ref:SetAnchorPosition(x, -15)
    self.uiBinder.Trans:SetHeight(330)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

return ChatBubbleUnionNew
