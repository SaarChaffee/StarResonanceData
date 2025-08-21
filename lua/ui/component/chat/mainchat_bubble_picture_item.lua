local super = require("ui.component.loop_list_view_item")
local MainChatBubblePictureItem = class("MainChatBubblePictureItem", super)

function MainChatBubblePictureItem:OnInit()
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.idCardVm_ = Z.VMMgr.GetVM("idcard")
  self.uiBinder.btn_card:AddListener(function()
    self:showCardView()
  end)
end

function MainChatBubblePictureItem:showCardView()
  Z.CoroUtil.create_coro_xpcall(function()
    local charId = Z.ChatMsgHelper.GetCharId(self.data_)
    if charId and type(charId) == "number" and 0 < charId then
      self.idCardVm_.AsyncGetCardData(charId, self.parent.UIView.cancelSource:CreateToken())
    end
  end)()
end

function MainChatBubblePictureItem:OnRefresh(data)
  self.data_ = data
  local name = Z.ChatMsgHelper.GetPlayerName(data)
  self.uiBinder.lab_name.text = name
  local size = self.uiBinder.lab_name:GetPreferredValues(name)
  self.uiBinder.btn_card_ref:SetWidth(size.x + 22)
  self.uiBinder.img_icon:SetImage(Z.ChatMsgHelper.GetMainChatBubbleIcon(data))
  local emojiName = self.chatMainVm_.GetEmojiName(Z.ChatMsgHelper.GetEmojiConfigId(data))
  if emojiName == "" or emojiName == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_pic, false)
  self.uiBinder.rimg_pic:SetImageWithCallback(emojiName, function()
    if not self.uiBinder then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_pic, true)
  end)
end

return MainChatBubblePictureItem
