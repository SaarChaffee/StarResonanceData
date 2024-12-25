local ColorItemHandlerBase = class("ColorItemHandlerBase")

function ColorItemHandlerBase:GetItemAddress()
  error("func must be override!")
end

function ColorItemHandlerBase:GetToggleWidget(container)
  error("func must be override!")
end

function ColorItemHandlerBase:SetColor(container, color)
  error("func must be override!")
end

function ColorItemHandlerBase:SetColorItemIsOnWithoutNotify(container, itemIndex, isOn)
  error("func must be override!")
end

function ColorItemHandlerBase:GetColorItemIsUnlocked(itemIndex)
  error("func must be override!")
end

function ColorItemHandlerBase:SetColorItemIsUnlocked(container, isUnlocked)
  error("func must be override!")
end

return ColorItemHandlerBase
