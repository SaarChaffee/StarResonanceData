local super = require("ui.model.data_base")
local SceneLayerData = class("SceneLayerData", super)

function SceneLayerData:ctor()
  super.ctor(self)
  self.SceneLayerCount = 0
end

function SceneLayerData:SetSceneLayerCount(layer)
  self.SceneLayerCount = layer
end

function SceneLayerData:GetSceneLayerCount()
  return self.SceneLayerCount
end

return SceneLayerData
