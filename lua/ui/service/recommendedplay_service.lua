local super = require("ui.service.service_base")
local RecommendedPlayService = class("RecommendedPlayService", super)

function RecommendedPlayService:OnInit()
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  self.enterDungeonSceneVM_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
end

function RecommendedPlayService:OnUnInit()
end

function RecommendedPlayService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.FunctionRed, self.functionRed, self)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.DungeonRed, self.dungeonIdRed, self)
end

function RecommendedPlayService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.FunctionRed, self.functionRed, self)
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.DungeonRed, self.dungeonIdRed, self)
end

function RecommendedPlayService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:checkRedDot()
  end
end

function RecommendedPlayService:checkRedDot()
  Z.CoroUtil.create_coro_xpcall(function()
    local config1 = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.EntranceDiNa)
    if config1 then
      self:asynRefreshPioneerInfoRed(config1)
    end
    local config2 = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.EntranceJuTaYiJi)
    if config2 then
      self:asynRefreshPioneerInfoRed(config2)
    end
    self:refreshRedState()
  end)()
end

function RecommendedPlayService:refreshRedState()
  local redDots = false
  for _, seconds in pairs(self.recommendedPlayData_.AllRedDots) do
    for _, thirds in pairs(seconds) do
      if type(thirds) == "boolean" then
        if thirds then
          redDots = true
          break
        end
      else
        for _, isRed in pairs(thirds) do
          if isRed then
            redDots = true
            break
          end
        end
      end
    end
  end
  if redDots then
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.RecommendedPlayRed, 1)
  else
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.RecommendedPlayRed, 0)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.ViewRedRefresh)
end

function RecommendedPlayService:setRedDotByConfig(config, isRed)
  if config == nil then
    return
  end
  if config.ParentId and config.ParentId ~= 0 then
    if self.recommendedPlayData_.AllRedDots[config.Type[1]] == nil then
      self.recommendedPlayData_.AllRedDots[config.Type[1]] = {}
    end
    if self.recommendedPlayData_.AllRedDots[config.Type[1]][config.ParentId] == nil then
      self.recommendedPlayData_.AllRedDots[config.Type[1]][config.ParentId] = {}
    end
    self.recommendedPlayData_.AllRedDots[config.Type[1]][config.ParentId][config.Id] = isRed
    if config.Type[2] then
      if self.recommendedPlayData_.AllRedDots[config.Type[2]] == nil then
        self.recommendedPlayData_.AllRedDots[config.Type[2]] = {}
      end
      if self.recommendedPlayData_.AllRedDots[config.Type[2]][config.ParentId] == nil then
        self.recommendedPlayData_.AllRedDots[config.Type[2]][config.ParentId] = {}
      end
      self.recommendedPlayData_.AllRedDots[config.Type[2]][config.ParentId][config.Id] = isRed
    end
  else
    if self.recommendedPlayData_.AllRedDots[config.Type[1]] == nil then
      self.recommendedPlayData_.AllRedDots[config.Type[1]] = {}
    end
    self.recommendedPlayData_.AllRedDots[config.Type[1]][config.Id] = isRed
    if config.Type[2] then
      if self.recommendedPlayData_.AllRedDots[config.Type[2]] == nil then
        self.recommendedPlayData_.AllRedDots[config.Type[2]] = {}
      end
      self.recommendedPlayData_.AllRedDots[config.Type[2]][config.Id] = isRed
    end
  end
end

function RecommendedPlayService:asynRefreshPioneerInfoRed(config)
  self.enterDungeonSceneVM_.AsyncGetPioneerInfo(config.RelatedDungeonId)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local pioneerInfo = dungeonData.PioneerInfos[config.RelatedDungeonId]
  local cfgData = dungeonData:GetChestIntroductionById(config.RelatedDungeonId)
  for index, data in ipairs(cfgData) do
    local chestStateTpe = E.ChestStateTpe.NotOpen
    if pioneerInfo.progress >= data.preValue then
      chestStateTpe = E.ChestStateTpe.CanOpen
    end
    if pioneerInfo.awards[data.rewardId] then
      chestStateTpe = E.ChestStateTpe.AlreadyOpen
    end
    if chestStateTpe == E.ChestStateTpe.CanOpen then
      self:setRedDotByConfig(config, true)
      return
    end
  end
  self:setRedDotByConfig(config, false)
end

function RecommendedPlayService:functionRed(functionId, isRed)
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(functionId)
  if config then
    self:setRedDotByConfig(config, isRed)
  end
  self:refreshRedState()
end

function RecommendedPlayService:dungeonIdRed(dungeonId, isRed)
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByDungeonId(dungeonId)
  self:setRedDotByConfig(config, isRed)
  self:refreshRedState()
end

return RecommendedPlayService
