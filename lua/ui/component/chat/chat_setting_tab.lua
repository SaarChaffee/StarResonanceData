local super = require("ui.component.loop_list_view_item")
local ChatSettingTab = class("ChatSettingTab", super)

function ChatSettingTab:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_on.text = data.name
  self.uiBinder.lab_off.text = data.name
  self:refreshSelect()
end

function ChatSettingTab:refreshSelect()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_off, not self.IsSelected)
end

function ChatSettingTab:OnSelected(isSelected, isClick)
  self:refreshSelect()
  if isSelected then
    self.parent.UIView:OnSelectTab(self.data_)
    if isClick then
      Z.AudioMgr:Play("UI_Tab_Special")
    end
  end
end

return ChatSettingTab
