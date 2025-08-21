local Scene = {}

function Scene:InitScene(sceneId)
  self:InitEvents()
end

function Scene:LoadComplete()
end

Scene.Seasons = {2}

function Scene:InitEvents()
  self.EventItems = {}
end

return Scene
