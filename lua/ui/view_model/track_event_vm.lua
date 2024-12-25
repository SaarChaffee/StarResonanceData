local TrackEventVM = {}
local DifficultIconPath = "TrackEventDifficultIcon_"

function TrackEventVM.GetEventTargetIcon(eventId, targetId)
  local eventCfg = TrackEventVM.GetEventConfig(eventId)
  if eventCfg and eventCfg.Difficult == 1 then
    local difficult = 0
    for index, id in ipairs(eventCfg.TargetList) do
      if targetId == id then
        difficult = index
      end
    end
    local iconPath = GetLoadAssetPath(DifficultIconPath .. difficult)
    return iconPath
  else
    return nil
  end
end

function TrackEventVM.GetEventConfig(eventId)
  local cfg = Z.TableMgr.GetTable("SceneEventTableMgr").GetRow(eventId)
  return cfg
end

return TrackEventVM
