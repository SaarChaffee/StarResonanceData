local checkIsSameGroup = function(sceneId)
  if sceneId == nil then
    return true
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  if curSceneId == sceneId then
    return true
  end
  local curMapInfoRow = Z.TableMgr.GetRow("MapInfoTableMgr", curSceneId)
  local targetMapInfoRow = Z.TableMgr.GetRow("MapInfoTableMgr", sceneId)
  if curMapInfoRow and targetMapInfoRow and curMapInfoRow.GroupId ~= 0 and curMapInfoRow.GroupId == targetMapInfoRow.GroupId then
    return true
  end
  return false
end
local checekSceneID = function(sceneId)
  local mainvm = Z.VMMgr.GetVM("mainui")
  if not mainvm.CheckSceneShowMainMap() then
    Z.TipsVM.ShowTipsLang(121002)
    return false
  elseif not checkIsSameGroup(sceneId) then
    Z.TipsVM.ShowTipsLang(121004)
    return false
  else
    return true
  end
  return true
end
local openEnlargedminimap = function(sceneId, callback)
  if checekSceneID(sceneId) == true then
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
  ChecekSceneID = checekSceneID
}
return ret
