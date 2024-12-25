local super = require("ui.component.loop_list_view_item")
local item = require("common.item_binder")
local MailReawardLoopItem = class("MailReawardLoopItem", super)

function MailReawardLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function MailReawardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function MailReawardLoopItem:OnPointerClick(go, eventData)
  Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.mailData_.configId)
end

function MailReawardLoopItem:OnRefresh(data)
  data.uiBinder = self.uiBinder
  self.mailData_ = data
  self.itemClass_:Init(data)
end

return MailReawardLoopItem
