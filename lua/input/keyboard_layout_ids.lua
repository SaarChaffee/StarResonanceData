local ret = {}
ret.KeyboardLayoutMapRegion = {
  [1036] = "FrenchKeyboard",
  [1031] = "GermanKeyboard",
  [11274] = "SpanishKeyboard",
  [1049] = "RussianKeyboard",
  [1045] = "PolishKeyboard",
  [2070] = "PortugueseKeyboard"
}

function ret.GetKeyboardLayoutById(id)
  if id == nil or id == "nil" then
    return "Keyboard"
  end
  return ret.KeyboardLayoutMapRegion[id] or "Keyboard"
end

return ret
