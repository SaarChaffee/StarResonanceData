local SceneVM = {}

function SceneVM.IsStaticScene(sceneId)
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow == nil then
    return false
  end
  return sceneRow.SceneType == E.ESceneType.Static
end

function SceneVM.CheckSceneUnlock(sceneId, showTips)
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow == nil then
    return false
  else
    return Z.ConditionHelper.CheckCondition(sceneRow.MapEntryCondition, showTips)
  end
end

function SceneVM.CheckSceneUnlockByTrigger(sceneId, isEnter)
  if isEnter then
    if not SceneVM.CheckSceneUnlock(sceneId, false) then
      Z.UIMgr:OpenView("map_lock_main", {
        sceneId = sceneId,
        curSceneId = Z.StageMgr.GetCurrentSceneId()
      })
    end
  else
    Z.UIMgr:CloseView("map_lock_main")
  end
end

return SceneVM
