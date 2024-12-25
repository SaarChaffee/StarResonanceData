local super = require("ui.service.service_base")
local InsightService = class("InsightService", super)

function InsightService:OnInit()
end

function InsightService:OnUnInit()
end

function InsightService:OnLogin()
end

function InsightService:OnLogout()
end

function InsightService:OnEnterScene()
  if Z.StageMgr.GetIsInGameScene() then
    self.insightToken = Z.EntityMgr:BindEntityLuaAttrWatcher(Z.EntityMgr.PlayerUuid, {
      Z.PbAttrEnum("AttrInsightFlag")
    }, function()
      local curInsightState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
      if curInsightState == 1 then
        self.dongXiEffect = Panda.ZEffect.ZEffectManager.Instance:AddScreenEffect("common_new/screen/p_fx_dongxi", 0, -1.608, 5.49)
      elseif self.dongXiEffect then
        Panda.ZEffect.ZEffectManager.Instance:RemoveEffect(self.dongXiEffect)
        self.dongXiEffect = nil
      end
    end)
    self.originEnergyToken = Z.EntityMgr:BindEntityLuaAttrWatcher(Z.EntityMgr.PlayerUuid, {
      Z.AttrCreator.ToIndex(Z.LocalAttr.EOriginEnergy)
    }, function()
      local curInsightState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
      if curInsightState == 1 then
        local isEnergyClose = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EOriginEnergy).Value == 0
        if isEnergyClose then
          Z.CoroUtil.create_coro_xpcall(function()
            local inSightVM = Z.VMMgr.GetVM("insight")
            local inSightData = Z.DataMgr.Get("insight_data")
            inSightVM.CloseInsight(inSightData.CancelSource:CreateToken())
          end)()
        end
      end
    end)
  end
end

function InsightService:OnLeaveScene()
  if self.insightToken then
    Z.EntityMgr:UnbindEntityLuaAttrWater(Z.EntityMgr.PlayerUuid, self.insightToken)
  end
  if self.originEnergyToken then
    Z.EntityMgr:UnbindEntityLuaAttrWater(Z.EntityMgr.PlayerUuid, self.originEnergyToken)
  end
end

return InsightService
