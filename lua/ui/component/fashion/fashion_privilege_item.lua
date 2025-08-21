local super = require("ui.component.loop_list_view_item")
local FashionPrivilegeItem = class("FashionCollectionItem", super)

function FashionPrivilegeItem:OnRefresh(data)
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.lab_name_on.text = data.row.Name
  self.uiBinder.lab_name_off.text = data.row.Name
  self.uiBinder.lab_num.text = data.row.Level
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_num, data.unlock and data.row.Level > 0)
  self.uiBinder.img_on:SetImage(data.row.Icon)
  self.uiBinder.img_off:SetImage(data.row.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, data.unlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not data.unlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not data.unlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, false)
  if data.row.Type == E.FashionPrivilegeType.MoonGift then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_red, Z.RedPointMgr.GetRedState(E.RedType.FashionCollectionWindowPrivilegeRed) and data.unlock)
  end
  self.uiBinder.btn_item:AddListener(function()
    self.parent.UIView:OnSelectPrivilege(data.row)
  end)
end

function FashionPrivilegeItem:OnUnInit()
end

return FashionPrivilegeItem
