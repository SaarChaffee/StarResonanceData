local UnionPowerEditItem = class("UnionPowerEditItem")

function UnionPowerEditItem:ctor()
end

function UnionPowerEditItem:Init(uiBinder)
  self.uiBinder = uiBinder
end

function UnionPowerEditItem:UnInit()
  self.uiBinder = nil
end

function UnionPowerEditItem:GetLayoutTrans()
  return self.uiBinder.trans_adjustment
end

function UnionPowerEditItem:SetData(positionName)
  self.uiBinder.lab_status.text = positionName
end

return UnionPowerEditItem
