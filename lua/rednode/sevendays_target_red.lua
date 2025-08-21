local SevenDaysTargetRed = {}
local sevendaysTargetKeyCache = {}

function SevenDaysTargetRed.RefreshOrInitSevenDaysTargetRed(task)
  local switchVm = Z.VMMgr.GetVM("switch")
  local pageFuncOpen = switchVm.CheckFuncSwitch(E.FunctionID.SevendayTargetTitlePage)
  if pageFuncOpen then
    SevenDaysTargetRed.InitOrRefreshTitlePageRed(task)
  end
  local manualFuncOpen = switchVm.CheckFuncSwitch(E.FunctionID.SevendayTargetManual)
  if manualFuncOpen then
    SevenDaysTargetRed.InitOrRefreshManualRed(task)
  end
end

function SevenDaysTargetRed.InitOrRefreshTitlePageRed(tasks_)
  sevendaysTargetKeyCache[E.RedType.SevenDaysTargetTitlePageTab] = true
  local vm = Z.VMMgr.GetVM("season_quest_sub")
  local taskCfgs = vm.GetAllTaskConfig()
  for _, cfg in pairs(taskCfgs) do
    if tasks_[cfg.OpenDay] and tasks_[cfg.OpenDay][cfg.TargetId] then
      local taskData_ = tasks_[cfg.OpenDay][cfg.TargetId]
      if cfg and cfg.tab == E.SevenDayStargetType.TitlePage then
        local titlePageKey_ = "SevenDaysTargetTitlePageBtn_" .. cfg.OpenDay
        sevendaysTargetKeyCache[titlePageKey_] = true
        Z.RedPointMgr.AddChildNodeData(E.RedType.SevenDaysTargetTitlePageTab, E.RedType.SevenDaysTargetTitlePageBtn, titlePageKey_)
        local count_ = 0
        if taskData_.award == vm.AwardState.canGet then
          count_ = 1
        end
        Z.RedPointMgr.UpdateNodeCount(titlePageKey_, count_)
      end
    end
  end
end

function SevenDaysTargetRed.LoadTitlePageTabItem(view, parentTrans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SevenDaysTargetTitlePageTab, view, parentTrans)
end

function SevenDaysTargetRed.LoadTitlePageBtnItem(day, view, parentTrans)
  local titlePageKey_ = "SevenDaysTargetTitlePageBtn_" .. day
  Z.RedPointMgr.LoadRedDotItem(titlePageKey_, view, parentTrans)
end

function SevenDaysTargetRed.InitOrRefreshManualRed(tasks_)
  sevendaysTargetKeyCache[E.RedType.SevenDaysTargetManualTab] = true
  local vm = Z.VMMgr.GetVM("season_quest_sub")
  local taskCfgs = vm.GetAllTaskConfig()
  for key, v in ipairs(tasks_) do
    local manualQuestTabKey_ = "SevenDaysTargetManualQuestTab_" .. key
    sevendaysTargetKeyCache[manualQuestTabKey_] = true
    Z.RedPointMgr.AddChildNodeData(E.RedType.SevenDaysTargetManualTab, E.RedType.SevenDaysTargetManualQuestTab, manualQuestTabKey_)
    local count_ = 0
    for _, cfg in pairs(taskCfgs) do
      if cfg.OpenDay == key and tasks_[cfg.OpenDay] and tasks_[cfg.OpenDay][cfg.TargetId] then
        local taskData_ = tasks_[cfg.OpenDay][cfg.TargetId]
        if cfg and cfg.tab == E.SevenDayStargetType.Manual then
          local isUnlock_ = vm.GetCurDay() >= cfg.OpenDay
          if isUnlock_ and taskData_.award == vm.AwardState.canGet then
            count_ = count_ + 1
          end
        end
      end
    end
    Z.RedPointMgr.UpdateNodeCount(manualQuestTabKey_, count_)
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.SevenDaysTargetManualQuestBtn, 0)
end

function SevenDaysTargetRed.RemoveAllRedItem(view)
  for key, v in pairs(sevendaysTargetKeyCache) do
    Z.RedPointMgr.RemoveNodeItem(key, view)
  end
end

function SevenDaysTargetRed.LoadManualTabRedItem(view, parentTrans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SevenDaysTargetManualTab, view, parentTrans)
end

function SevenDaysTargetRed.LoadManualTQuestabRedItem(day, view, parentTrans)
  local manualQuestTabeKey_ = "SevenDaysTargetManualQuestTab_" .. day
  Z.RedPointMgr.LoadRedDotItem(manualQuestTabeKey_, view, parentTrans)
end

function SevenDaysTargetRed.InitOrRefreshFuncPreviewRed(init)
  local funcPreviewData = Z.DataMgr.Get("function_preview_data")
  local totalCount = 0
  for k, v in pairs(funcPreviewData:GetStateDict()) do
    local key = "function_preview_" .. k
    Z.RedPointMgr.AddChildNodeData(E.RedType.SevenDaysTargetFuncPreviewTab, E.RedType.SevenDaysTargetFuncPreviewItem, key)
    sevendaysTargetKeyCache[key] = true
    local count = v == E.FuncPreviewAwardState.CanGet and 1 or 0
    Z.RedPointMgr.UpdateNodeCount(key, count)
    if 0 < count then
      totalCount = totalCount + 1
    end
  end
  local showPreviewMain = 3 <= totalCount and 1 or 0
  Z.RedPointMgr.UpdateNodeCount(E.RedType.SevenDaysTargetFuncPreviewAwardMain, showPreviewMain)
end

function SevenDaysTargetRed.LoadFuncPreviewRedItem(funcId, view, parentTrans)
  local key = "function_preview_" .. funcId
  Z.RedPointMgr.LoadRedDotItem(key, view, parentTrans)
end

function SevenDaysTargetRed.RemoveFuncPreviewRedItem(funcId, view)
  if funcId then
    local key = "function_preview_" .. funcId
    Z.RedPointMgr.RemoveNodeItem(key, view)
  end
end

function SevenDaysTargetRed.LoadFuncPreviewTabRedItem(view, parentTrans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SevenDaysTargetFuncPreviewTab, view, parentTrans)
end

return SevenDaysTargetRed
