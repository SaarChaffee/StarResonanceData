local super = require("ui.component.loop_list_view_item")
local ChatTabItem = class("ChatTabItem", super)

function ChatTabItem:OnRefresh(data)
  self.data_ = data
  if data.icon then
    self.uiBinder.img_off_icon:SetImage(data.icon)
    self.uiBinder.img_on_icon:SetImage(data.icon)
    self:refreshIconState(false)
  else
    self.uiBinder.rimg_off_icon:SetImage(data.raw_icon)
    self.uiBinder.rimg_on_icon:SetImage(data.raw_icon)
    self:refreshIconState(true)
  end
  self.uiBinder.lab_name.text = ""
  self:setSelect(self.IsSelected)
  self:refreshIconColor()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_special, self.data_.showSpecial and tonumber(self.data_.showSpecial) > 0)
  self:onInitRed()
end

function ChatTabItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectSecondTab(self.data_.id, self.data_.tag)
    self:onClickMoreRed()
  end
  self:setSelect(isSelected)
end

function ChatTabItem:setSelect(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelect)
end

function ChatTabItem:OnRecycle()
  self:clearRed()
end

function ChatTabItem:refreshIconColor()
  if not Z.IsPCUI then
    return
  end
  if self.data_.id == 1 and self.data_.emoji or not self.data_.emoji then
    self.uiBinder.img_on_icon.color = Color.New(0, 0, 0, 1)
  else
    self.uiBinder.img_on_icon.color = Color.New(1, 1, 1, 1)
  end
end

function ChatTabItem:refreshIconState(isRawimage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on_icon, not isRawimage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off_icon, not isRawimage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_on_icon, isRawimage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_off_icon, isRawimage)
end

function ChatTabItem:onInitRed()
  if not self.data_.emoji then
    return
  end
  self.red_ = string.zconcat(Z.ConstValue.Chat.ChatEmojiTab, self.data_.id)
  Z.RedPointMgr.AddChildNodeData(E.RedType.ChatInputBoxEmojiFunctionBtn, E.RedType.ChatInputBoxEmojiFunctionBtn, self.red_)
  Z.RedPointMgr.LoadRedDotItem(self.red_, self.parent.UIView, self.uiBinder.node_red)
end

function ChatTabItem:onClickMoreRed()
  if not self.data_.emoji then
    return
  end
  Z.RedPointMgr.OnClickRedDot(self.red_)
end

function ChatTabItem:clearRed()
  if not self.data_.emoji then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(self.red_)
end

return ChatTabItem
