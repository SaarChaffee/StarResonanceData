local PubMixologyVm = {}
local proxy = require("zproxy.world_proxy")
local curShowQuestId = 0

function PubMixologyVm.OpenMixolopyView()
  Z.UIMgr:OpenView("pub_mixology_main")
end

function PubMixologyVm.PlayFlowNode(flowId, flowType, flowNodeName)
  Z.EPFlowBridge.StartFailFlow(flowId, flowType, flowNodeName)
end

function PubMixologyVm.CloseMixolopyView()
  Z.UIMgr:CloseView("pub_mixology_main")
end

function PubMixologyVm.OpenRecipeTips()
  Z.TipsVM.ShowTips(50120002)
end

function PubMixologyVm.GetCocktailRecipeData()
  local pubData = Z.DataMgr.Get("pub_mixology_data")
  local tab = {}
  local index = 1
  for _, cfgData in pairs(pubData.CocktailRecipeTableDatas) do
    if cfgData.IsVisible then
      tab[index] = cfgData
      index = index + 1
    end
  end
  return tab
end

function PubMixologyVm.GetRecipeData()
  local pubData = Z.DataMgr.Get("pub_mixology_data")
  local type1 = {}
  local type2 = {}
  for _, cfgData in pairs(pubData.RecipeTableDatas) do
    if cfgData.RecipeType == 1 then
      table.insert(type1, cfgData)
    elseif cfgData.RecipeType == 2 then
      table.insert(type2, cfgData)
    end
  end
  table.sort(type1, function(a, b)
    return a.Id < b.Id
  end)
  table.sort(type2, function(a, b)
    return a.Id < b.Id
  end)
  return type1, type2
end

function PubMixologyVm.CheckPubRecipe()
  local pubData = Z.DataMgr.Get("pub_mixology_data")
  local data = pubData:GetSelectData()
  local recipeData
  for _, cfgData in pairs(pubData.CocktailRecipeTableDatas) do
    local dataCount = table.zcount(data)
    local recipeCount = table.zcount(cfgData.Recipe)
    if dataCount == recipeCount then
      local isFlag = true
      for __, recipeData in ipairs(cfgData.Recipe) do
        local recipeCfgId = recipeData[1]
        if not data[recipeCfgId] or data[recipeCfgId] ~= recipeData[2] then
          isFlag = false
          break
        end
      end
      if isFlag then
        recipeData = cfgData
        break
      end
    end
  end
  return recipeData
end

function PubMixologyVm.GetCurRecipeIds()
  local recipeIds = {}
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if not quest then
    return recipeIds
  end
  local stepId = quest.stepId
  local cfg = questData:GetStepConfigByStepId(stepId)
  if not cfg then
    return recipeIds
  end
  for _, goalParam in ipairs(cfg.StepParam) do
    table.insert(recipeIds, tonumber(goalParam[4]))
  end
  return recipeIds
end

function PubMixologyVm.CheckCurRecipeID(id)
  for _, recipeID in ipairs(PubMixologyVm.GetCurRecipeIds()) do
    if recipeID == id then
      return true
    end
  end
  return false
end

function PubMixologyVm.CheckEspeciallyOpen()
  return curShowQuestId == 0
end

function PubMixologyVm.AsyncBartending(recipeId, cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    proxy.Bartending(recipeId, cancelToken)
  end)()
end

function PubMixologyVm.BeginMixilogy(flowId)
  local pubData = Z.DataMgr.Get("pub_mixology_data")
  pubData:SetFlowId(flowId)
  pubData:PlayMixologyFlow()
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if quest == nil then
    PubMixologyVm.CloseMixolopyView()
    return
  end
  local id = quest.stepId
  Z.EPFlowBridge.StartFailFlow(tonumber(flowId), Z.EPFlowEventType.Mixology, "queststep" .. id)
end

function PubMixologyVm.OpenRecipeView()
  Z.UIMgr:OpenView("pub_mixology_recipe_main")
end

function PubMixologyVm.CloseRecipeView()
  Z.UIMgr:CloseView("pub_mixology_recipe_main")
end

function PubMixologyVm.SetCurShowQuestId()
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if quest and Z.Global.MixologyTipsTriggerStepId == quest.stepId then
    curShowQuestId = quest.stepId
  end
end

function PubMixologyVm.OpenEspeciallyItemWindow()
  PubMixologyVm.SetCurShowQuestId()
  PubMixologyVm.OpenRecipeTips()
end

function PubMixologyVm.MixFail()
  local pubData = Z.DataMgr.Get("pub_mixology_data")
  local maxFailCount = Z.Global.MixMaxFailureNum
  if maxFailCount and maxFailCount <= pubData.FailCount then
    local ids = PubMixologyVm.GetCurRecipeIds()
    local id = ids[1]
    PubMixologyVm.AsyncBartending(id, pubData.CancelSource:CreateToken())
    pubData.FailCount = 0
    if id then
      if id == 1003 then
        PubMixologyVm.PlayFlowNode(pubData.FlowId, Z.EPFlowEventType.Mixology, "auto_success_huiya")
      else
        PubMixologyVm.PlayFlowNode(pubData.FlowId, Z.EPFlowEventType.Mixology, "auto_success")
      end
      PubMixologyVm.RemoveFailEvent()
    end
  end
end

function PubMixologyVm.RemoveFailEvent()
  Z.EventMgr:Remove(Z.ConstValue.Mixology.MixFail, PubMixologyVm.MixFail)
end

function PubMixologyVm.AddFailEvent()
  Z.EventMgr:Add(Z.ConstValue.Mixology.MixFail, PubMixologyVm.MixFail)
end

return PubMixologyVm
