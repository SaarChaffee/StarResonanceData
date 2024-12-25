local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

function Scene:InitEvents()
  self.EventItems = {}
end

return Scene
