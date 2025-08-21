local super = require("ui.service.service_base")
local ConditionService = class("ConditionService", super)
local conditionType2EventTable = {
  [E.ConditionType.LifeProfessionLevel] = Z.ConstValue.LifeProfession.LifeProfessionLevelChanged,
  [E.ConditionType.LifeProfessionSpecializationLevel] = Z.ConstValue.LifeProfession.LifeProfessionSpecChanged,
  [E.ConditionType.RecipeIsUnlock] = Z.ConstValue.LifeProfession.LifeProfessionRecipeChanged
}

function ConditionService:OnInit()
  for k, v in pairs(conditionType2EventTable) do
    Z.EventMgr:Add(v, function()
      Z.EventMgr:Dispatch(Z.ConstValue.OnConditionChanged, k)
    end, self)
  end
end

function ConditionService:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function ConditionService:OnLogin()
end

function ConditionService:OnLogout()
end

function ConditionService:OnReconnect()
end

function ConditionService:OnEnterScene()
end

function ConditionService:OnSyncAllContainerData()
end

return ConditionService
