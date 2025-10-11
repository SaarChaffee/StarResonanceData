local AutoCheckCondition = {}

function AutoCheckCondition.CheckCondition1(param)
  local rides = Z.ContainerMgr.CharSerialize.rideList.rides
  if rides then
    for key, value in pairs(rides) do
      if value.rideId ~= 0 then
        return true
      end
    end
  end
  return false
end

function AutoCheckCondition.CheckCondition2()
  return Z.EntityMgr.PlayerEnt.IsRiding
end

return AutoCheckCondition
