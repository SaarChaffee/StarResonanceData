local mouseElementIdentifiers = {
  {
    id = 0,
    name = "Left Mouse Button",
    keyId = 323
  },
  {
    id = 1,
    name = "Right Mouse Button",
    keyId = 324
  },
  {
    id = 2,
    name = "Middle Button",
    keyId = 325
  },
  {
    id = 3,
    name = "Mouse Button 3",
    keyId = 326
  },
  {
    id = 4,
    name = "Mouse Button 4",
    keyId = 327
  },
  {
    id = 5,
    name = "Mouse Button 5",
    keyId = 328
  },
  {
    id = 6,
    name = "Mouse Button 6",
    keyId = 329
  },
  {
    id = 7,
    name = "ScrollWheel",
    keyId = 330
  },
  {
    id = 8,
    name = "ScrollWheel Horizontal",
    keyId = 331
  },
  {
    id = 9,
    name = "Mouse Horizontal",
    keyId = 332
  },
  {
    id = 10,
    name = "Mouse Vertical",
    keyId = 333
  }
}
local gamePadElementIdentifiers = {
  {
    id = 1,
    name = "LeftStickX",
    keyId = {PS5 = 1001, XBox = 2001}
  },
  {
    id = 2,
    name = "LeftStickY",
    keyId = {PS5 = 1002, XBox = 2002}
  },
  {
    id = 3,
    name = "RightStickX",
    keyId = {PS5 = 1003, XBox = 2003}
  },
  {
    id = 4,
    name = "RightStickY",
    keyId = {PS5 = 1004, XBox = 2004}
  },
  {
    id = 5,
    name = "LeftTrigger",
    keyId = {PS5 = 1005, XBox = 2005}
  },
  {
    id = 6,
    name = "RightTrigger",
    keyId = {PS5 = 1006, XBox = 2006}
  },
  {
    id = 7,
    name = "ActionBottomRow1",
    keyId = {PS5 = 1007, XBox = 2007}
  },
  {
    id = 8,
    name = "ActionBottomRow2",
    keyId = {PS5 = 1008, XBox = 2008}
  },
  {
    id = 9,
    name = "ActionBottomRow3",
    keyId = {PS5 = 1009, XBox = 2009}
  },
  {
    id = 10,
    name = "ActionTopRow1",
    keyId = {PS5 = 1010, XBox = 2010}
  },
  {
    id = 11,
    name = "ActionTopRow2",
    keyId = {PS5 = 1011, XBox = 2011}
  },
  {
    id = 12,
    name = "ActionTopRow3",
    keyId = {PS5 = 1012, XBox = 2012}
  },
  {
    id = 13,
    name = "Center1",
    keyId = {PS5 = 1013, XBox = 2013}
  },
  {
    id = 14,
    name = "Center2",
    keyId = {PS5 = 1014, XBox = 2014}
  },
  {
    id = 15,
    name = "Center3",
    keyId = {PS5 = 1015, XBox = 2015}
  },
  {
    id = 16,
    name = "Center4",
    keyId = {PS5 = 1016, XBox = 2016}
  },
  {
    id = 17,
    name = "LeftShoulder",
    keyId = {PS5 = 1017, XBox = 2017}
  },
  {
    id = 18,
    name = "RightShoulder",
    keyId = {PS5 = 1018, XBox = 2018}
  },
  {
    id = 19,
    name = "LeftStickButton",
    keyId = {PS5 = 1019, XBox = 2019}
  },
  {
    id = 20,
    name = "RightStickButton",
    keyId = {PS5 = 1020, XBox = 2020}
  },
  {
    id = 21,
    name = "LeftStick",
    keyId = {PS5 = 1021, XBox = 2021}
  },
  {
    id = 22,
    name = "RightStick",
    keyId = {PS5 = 1022, XBox = 2022}
  },
  {
    id = 23,
    name = "DPadUp",
    keyId = {PS5 = 1023, XBox = 2023}
  },
  {
    id = 24,
    name = "DPadDown",
    keyId = {PS5 = 1024, XBox = 2024}
  },
  {
    id = 25,
    name = "DPadLeft",
    keyId = {PS5 = 1025, XBox = 2025}
  },
  {
    id = 26,
    name = "DPadRight",
    keyId = {PS5 = 1026, XBox = 2026}
  }
}
local mouseModifierKeyMap = {
  [1] = 306
}
local gamePadModifierKeyMap = {
  [1] = 17,
  [2] = 18,
  [4] = 5,
  [8] = 6
}
local getMouseKeyIdByElementId = function(elementId)
  for _, element in ipairs(mouseElementIdentifiers) do
    if element.id == elementId then
      return element.keyId
    end
  end
  return nil
end
local getGamePadKeyIdByElementId = function(elementId, gamePadType)
  for _, element in ipairs(gamePadElementIdentifiers) do
    if element.id == elementId then
      if Panda.ZInput.EGamepadType.XBOX == gamePadType then
        return element.keyId.XBox
      else
        return element.keyId.PS5
      end
    end
  end
  return nil
end
local getMouseModifierKeyId = function(modifierId)
  return mouseModifierKeyMap[modifierId]
end
local getGamePadModifierKeyId = function(modifierId)
  local modifierKeyId = Z.InputMgr:GetGamePadModifierIdByIndex(modifierId)
  if not modifierKeyId then
    return nil
  end
  return gamePadModifierKeyMap[modifierKeyId]
end
local getGamePadModifierByElementId = function(elementId)
  return gamePadModifierKeyMap[elementId]
end
local ret = {
  GetMouseKeyIdByElementId = getMouseKeyIdByElementId,
  GetMouseModifierKeyId = getMouseModifierKeyId,
  GetGamePadModifierKeyId = getGamePadModifierKeyId,
  GetGamePadKeyIdByElementId = getGamePadKeyIdByElementId,
  GetGamePadModifierByElementId = getGamePadModifierByElementId
}
return ret
