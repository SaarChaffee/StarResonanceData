local mouseElementIdentifiers = {
  {
    id = 0,
    name = "Mouse Horizontal",
    positiveName = "Mouse Right",
    negativeName = "Mouse Left",
    type = 0
  },
  {
    id = 1,
    name = "Mouse Vertical",
    positiveName = "Mouse Up",
    negativeName = "Mouse Down",
    type = 0
  },
  {
    id = 2,
    name = "Mouse Wheel",
    positiveName = "Mouse Wheel Up",
    negativeName = "Mouse Wheel Down",
    type = 0,
    keyId = 325
  },
  {
    id = 3,
    name = "Left Mouse Button",
    positiveName = "Left Mouse Button",
    negativeName = "Left Mouse Button",
    type = 1,
    keyId = 323
  },
  {
    id = 4,
    name = "Right Mouse Button",
    positiveName = "Right Mouse Button",
    negativeName = "Right Mouse Button",
    type = 1,
    keyId = 324
  },
  {
    id = 5,
    name = "Mouse Button 3",
    positiveName = "Mouse Button 3",
    negativeName = "Mouse Button 3",
    type = 1,
    keyId = 325
  },
  {
    id = 6,
    name = "Mouse Button 4",
    positiveName = "Mouse Button 4",
    negativeName = "Mouse Button 4",
    type = 1,
    keyId = 326
  },
  {
    id = 7,
    name = "Mouse Button 5",
    positiveName = "Mouse Button 5",
    negativeName = "Mouse Button 5",
    type = 1,
    keyId = 327
  },
  {
    id = 8,
    name = "Mouse Button 6",
    positiveName = "Mouse Button 6",
    negativeName = "Mouse Button 6",
    type = 1,
    keyId = 328
  },
  {
    id = 9,
    name = "Mouse Button 7",
    positiveName = "Mouse Button 7",
    negativeName = "Mouse Button 7",
    type = 1,
    keyId = 329
  },
  {
    id = 10,
    name = "Mouse Wheel Horizontal",
    positiveName = "Mouse Wheel Right",
    negativeName = "Mouse Wheel Left",
    type = 0
  }
}
local getMouseKeyIdByElementId = function(elementId)
  for _, element in ipairs(mouseElementIdentifiers) do
    if element.id == elementId then
      return element.keyId
    end
  end
  return nil
end
local getMouseKeyIdByElementName = function(elementName)
  for _, element in ipairs(mouseElementIdentifiers) do
    if element.name == elementName then
      return element.keyId
    end
  end
  return nil
end
local ret = {GetMouseKeyIdByElementId = getMouseKeyIdByElementId, GetMouseKeyIdByElementName = getMouseKeyIdByElementName}
return ret
