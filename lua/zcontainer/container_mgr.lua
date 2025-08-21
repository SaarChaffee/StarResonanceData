local ContainerMgr = {
  CharSerialize = require("zcontainer.char_serialize").New(),
  DungeonSyncData = require("zcontainer.dungeon_sync_data").New()
}

function ContainerMgr:Reset()
  self.CharSerialize = require("zcontainer.char_serialize").New()
  self.DungeonSyncData = require("zcontainer.dungeon_sync_data").New()
end

return ContainerMgr
