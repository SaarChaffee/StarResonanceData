function Z.DIServiceMgr.ContainerSyncService.OnSync(data, count)
  local watcherList = {}
  
  local buffer = {
    data,
    0,
    count
  }
  Z.ContainerMgr.CharSerialize:MergeData(buffer, watcherList)
  local count = table.zcount(watcherList)
  for i = 1, count do
    local watcher = watcherList[i]
    watcher:UpdateWatcher()
  end
  Z.LuaBridge.ContainerDataChanged()
  Z.EventMgr:Dispatch("NotifyPoinnersChange")
end
