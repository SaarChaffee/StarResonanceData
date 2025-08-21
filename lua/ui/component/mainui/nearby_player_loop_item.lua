local super = require("ui.component.loop_list_view_item")
local NearbyPlayerLoopItem = class("NearbyPlayerLoopItem", super)

function NearbyPlayerLoopItem:ctor()
  self.idCardVM_ = Z.VMMgr.GetVM("idcard")
end

function NearbyPlayerLoopItem:OnInit()
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn, function()
    if self.data_.charId ~= 0 then
      self.idCardVM_.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
    end
  end)
end

function NearbyPlayerLoopItem:OnUnInit()
end

function NearbyPlayerLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_normal.text = data.name
end

return NearbyPlayerLoopItem
