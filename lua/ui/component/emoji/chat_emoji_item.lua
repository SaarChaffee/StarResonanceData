local super = require("ui.component.loop_grid_view_item")
local ChatEmojiItem = class("ChatEmojiItem", super)

function ChatEmojiItem:OnInit()
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
end

function ChatEmojiItem:OnRefresh(data)
  self.data_ = data
  if self.data_.Res == "" or self.data_.Res == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
  local path = string.zconcat(Z.ConstValue.Emoji.EmojiPath, self.data_.Res)
  self.uiBinder.rimg_icon:SetImageWithCallback(path, function()
    if not self.uiBinder then
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_special, data.ShowCornerMark > 0)
  self:refreshLockState()
  self:onInitRed()
end

function ChatEmojiItem:OnSelected(isSelected, isClick)
  self:refreshLockState()
end

function ChatEmojiItem:OnPointerClick(go, eventData)
  if self.data_.IsDefUnlock > 0 and 0 < self.data_.UnlockItem and not self.chatMainVM_.GetChatEmojiUnlock(self.data_.Id) then
    self:showUnlockTips()
    return
  end
  local msg = string.zconcat("emojiPic=%s=%s", self.data_.Res, self.data_.Id)
  self.parent.UIView:SendMessage(msg, E.ChitChatMsgType.EChatMsgPictureEmoji, self.data_.Id)
end

function ChatEmojiItem:refreshLockState()
  if self.data_.IsDefUnlock > 0 and 0 < self.data_.UnlockItem then
    local isUnlock = self.chatMainVM_.GetChatEmojiUnlock(self.data_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not isUnlock)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected and not isUnlock)
    self.uiBinder.canvas_item.alpha = isUnlock and 1 or 0.3
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
    self.uiBinder.canvas_item.alpha = 1
  end
end

function ChatEmojiItem:OnRecycle()
  self:clearRed()
end

function ChatEmojiItem:onInitRed()
  self.red_ = string.zconcat(Z.ConstValue.Chat.ChatEmojiItem, self.data_.Id)
  Z.RedPointMgr.LoadRedDotItem(self.red_, self.parent.UIView, self.uiBinder.node_red)
end

function ChatEmojiItem:clearRed()
  Z.RedPointMgr.RemoveNodeItem(self.red_)
end

function ChatEmojiItem:showUnlockTips()
  local itemsVM = Z.VMMgr.GetVM("items")
  local enough = itemsVM.GetItemTotalCount(self.data_.UnlockItem) > 0
  local viewData = {
    rect = self.uiBinder.node_red,
    title = Lang("ChatEmojiUnlockTipsTitle"),
    content = Lang("ChatEmojiUnlockTipsContent"),
    itemDataArray = {
      {
        ItemId = self.data_.UnlockItem,
        ItemNum = 1
      }
    },
    btnContent = Lang("UnLock"),
    func = function()
      if not enough then
        Z.TipsVM.ShowTips(1000111)
      elseif self.chatMainVM_.GetChatEmojiUnlock(self.data_.UnlockItem) then
        Z.TipsVM.ShowTipsLang(1000110)
      else
        local chatMainData = Z.DataMgr.Get("chat_main_data")
        local ret = self.chatMainVM_.AsyncUnlockEmoji(self.data_.Id, chatMainData.CancelSource:CreateToken())
        if ret and self.uiBinder then
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
          self.uiBinder.canvas_item.alpha = 1
        end
      end
      Z.UIMgr:CloseView("tips_title_content_items_btn")
    end,
    enabled = true,
    isRightFirst = false,
    isCenter = true
  }
  Z.UIMgr:OpenView("tips_title_content_items_btn", viewData)
end

return ChatEmojiItem
