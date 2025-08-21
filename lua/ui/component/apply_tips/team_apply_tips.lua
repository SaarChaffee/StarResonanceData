local TeamApplyTips = class("TeamApplyTips", {})

function TeamApplyTips:Init(uiBinder, data)
  self.uiBinder = uiBinder
  self.data = data
  uiBinder.lab_des = ""
  self:refresh()
end

function TeamApplyTips:refresh()
  if self.uiBinder == nil or self.data == nil then
    return
  end
  if self.data.tipsType == E.InvitationTipsType.TeamInvite then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_profession, true)
    self.uiBinder.lab_des = ""
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_profession, false)
    self.uiBinder.lab_des = ""
  end
end

function TeamApplyTips:UnInit()
end

return TeamApplyTips
