local rotateModel = function(model, pointerData)
  if not model then
    return
  end
  local rotVector = model:GetAttrGoRotation().eulerAngles
  local velocity = 0.12
  local delta = pointerData.delta.x * velocity
  rotVector.y = (rotVector.y - delta) % 360
  local temp = Quaternion.identity
  temp.eulerAngles = rotVector
  model:SetAttrGoRotation(temp)
end
local ret = {RotateModel = rotateModel}
return ret
