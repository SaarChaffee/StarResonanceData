local checkIsSameGroup = function(sceneId)
  if sceneId == nil then
    return true
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  if curSceneId == sceneId then
    return true
  end
  local curMapInfoRow = Z.TableMgr.GetRow("MapInfoTableMgr", curSceneId, true)
  local targetMapInfoRow = Z.TableMgr.GetRow("MapInfoTableMgr", sceneId, true)
  if curMapInfoRow and targetMapInfoRow and curMapInfoRow.GroupId ~= 0 and curMapInfoRow.GroupId == targetMapInfoRow.GroupId then
    return true
  end
  return false
end
local checkSceneID = function(sceneId, isIgnoreTips)
  local mainVM = Z.VMMgr.GetVM("mainui")
  if not mainVM.CheckSceneShowMainMap() then
    if not isIgnoreTips then
      Z.TipsVM.ShowTipsLang(121002)
    end
    return false
  elseif not checkIsSameGroup(sceneId) then
    if not isIgnoreTips then
      Z.TipsVM.ShowTipsLang(121004)
    end
    return false
  else
    return true
  end
end
local openEnlargedminimap = function(sceneId, callback)
  if sceneId ~= nil then
    sceneId = tonumber(sceneId)
    if sceneId == nil or sceneId == 0 then
      logError("[OpenEnlargedminimap] error, sceneId is nil or 0")
      return
    end
  end
  if checkSceneID(sceneId) == true then
    local viewData = {}
    viewData.sceneId = sceneId
    viewData.callback = callback
    Z.UIMgr:OpenView("map_main", viewData)
  end
end
local openDungeonMainWindow = function()
  Z.UIMgr:OpenView("dungeon_main_window", Z.StageMgr.GetCurrentDungeonId())
end
local ret = {
  OpenEnlargedminimap = openEnlargedminimap,
  OpenDungeonMainWindow = openDungeonMainWindow,
  CheckIsSameGroup = checkIsSameGroup,
  CheckSceneID = checkSceneID
}
return ret
