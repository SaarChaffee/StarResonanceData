local super = require("ui.component.loop_grid_view_item")
local ChatFuncItem = class("ChatFuncItem", super)

function ChatFuncItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_on:SetImage(self.data_.funcRow.Icon)
  self.uiBinder.img_off:SetImage(self.data_.funcRow.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
  self:onInitRed()
end

function ChatFuncItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectFuncTab(self.data_.funcType, self.data_.funcRow.Id)
    self:onClickMoreRed()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
end

function ChatFuncItem:OnPointerClick(go, eventData)
  if not self.IsSelected then
    return
  end
  self.parent.UIView:OnPointerClickSelectFuncTab(self.data_.funcType, self.data_.funcRow.Id)
end

function ChatFuncItem:OnRecycle()
  self:clearRed()
end

function ChatFuncItem:onInitRed()
  if self.data_.funcRow.Id ~= E.ChatFuncId.Expression then
    return
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.ChatInputBoxEmojiFunctionBtn, self.parent.UIView, self.uiBinder.Trans)
end

function ChatFuncItem:onClickMoreRed()
  if self.data_.funcRow.Id ~= E.ChatFuncId.Expression then
    return
  end
  Z.RedPointMgr.OnClickRedDot(E.RedType.ChatInputBoxEmojiFunctionBtn)
end

function ChatFuncItem:clearRed()
  if self.data_.funcRow.Id ~= E.ChatFuncId.Expression then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(E.RedType.ChatInputBoxEmojiFunctionBtn)
end

return ChatFuncItem
