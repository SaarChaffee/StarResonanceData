local super = require("ui/component/color_palette/color_item_handler_base")
local ColorPaletteHandler = class("ColorPaletteHandler", super)

function ColorPaletteHandler:GetItemAddress()
  local colorItem = Z.IsPCUI and "FaceColorItemPC" or "FaceColorItem"
  return GetLoadAssetPath(colorItem)
end

function ColorPaletteHandler:GetToggleWidget(container)
  return container.tog_color
end

function ColorPaletteHandler:SetColor(container, color)
  container.img_color:SetColor(color)
end

function ColorPaletteHandler:SetColorItemIsOnWithoutNotify(container, itemIndex, isOn)
  container.tog_color:SetIsOnWithoutNotify(isOn)
end

function ColorPaletteHandler:GetColorItemIsUnlocked(itemIndex)
  return true
end

function ColorPaletteHandler:SetColorItemIsUnlocked(container, isUnlocked)
  container.Ref:SetVisible(container.img_lock, not isUnlocked)
end

return ColorPaletteHandler
