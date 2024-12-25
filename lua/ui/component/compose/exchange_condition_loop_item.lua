local super = require("ui.component.loop_list_view_item")
local ExchangeConditionLoopItem = class("ExchangeConditionLoopItem", super)

function ExchangeConditionLoopItem:ctor()
end

function ExchangeConditionLoopItem:OnInit()
end

function ExchangeConditionLoopItem:Refresh(data)
  if data then
    local path
    if data.bResult then
      self.uiBinder.img_icon.transform:SetSizeDelta(26, 22)
      path = self.uiBinder.prefab_cache:GetString("unlock")
    else
      self.uiBinder.img_icon.transform:SetSizeDelta(23.4, 28.6)
      path = self.uiBinder.prefab_cache:GetString("lock")
    end
    self.uiBinder.img_icon:SetImage(path)
    self.uiBinder.lab_condition.text = Z.RichTextHelper.ApplyStyleTag(data.tips, "ItemQuality_0")
  end
end

function ExchangeConditionLoopItem:OnUnInit()
end

return ExchangeConditionLoopItem
