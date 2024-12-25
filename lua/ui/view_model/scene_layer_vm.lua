local setSceneLayerCount = function(layer)
  local sceneLayerData_ = Z.DataMgr.Get("scene_layer_data")
  sceneLayerData_:SetSceneLayerCount(layer)
end
local ret = {SetSceneLayerCount = setSceneLayerCount}
return ret
