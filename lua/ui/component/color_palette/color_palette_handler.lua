local super = require("ui/component/color_palette/color_item_handler_base")
local FashionColorItemHandler = class("FashionColorItemHandler", super)

function FashionColorItemHandler:ctor(parentView)
  super.ctor(self)
  self.parentView_ = parentView
end

function FashionColorItemHandler:GetItemAddress()
  return GetLoadAssetPath("FaceColorItem")
end

function FashionColorItemHandler:GetToggleWidget(container)
  return container.tog_color
end

function FashionColorItemHandler:SetColor(container, color)
  container.img_color:SetColor(color)
end

function FashionColorItemHandler:SetColorItemIsOnWithoutNotify(container, itemIndex, isOn)
  container.tog_color:SetIsOnWithoutNotify(isOn)
  self.parentView_:OnSelectColorItem(itemIndex)
end

function FashionColorItemHandler:GetColorItemIsUnlocked(itemIndex)
  local fashionId = self.parentView_:GetCurFashionId()
  local fashionData = Z.DataMgr.Get("fashion_data")
  return fashionData:GetColorIsUnlocked(fashionId, itemIndex - 1)
end

function FashionColorItemHandler:SetColorItemIsUnlocked(container, isUnlocked)
  container.img_lock:SetVisible(not isUnlocked)
end

return FashionColorItemHandler
