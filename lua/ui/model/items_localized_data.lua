local super = require("ui.model.data_base")
local ItemsLocalizedData = class("ItemsLocalizedData", super)

function ItemsLocalizedData:ctor()
  super.ctor(self)
end

function ItemsLocalizedData:Init()
  self.ItemLocalizedDatas = {201}
end

function ItemsLocalizedData:UnInit()
  self.ItemLocalizedDatas = {}
end

function ItemsLocalizedData:GetItemIcon(itemConfigId, itemAddress)
  if not table.zcontains(self.ItemLocalizedDatas, itemConfigId) then
    return itemAddress
  end
  local lanType = Z.LocalizationMgr:GetCurrentLanguageType()
  if lanType == "chinese" then
    return itemAddress
  end
  return string.zconcat("ui/localizetextures/", lanType, "/item/", itemAddress)
end

return ItemsLocalizedData
