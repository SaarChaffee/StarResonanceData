local super = require("ui.model.data_base")
local ExploreMonsterData = class("ExploreMonsterData", super)

function ExploreMonsterData:ctor()
  super.ctor(self)
end

function ExploreMonsterData:Init()
  self.markTable_ = {}
  self.monsterTable_ = {}
  self.exploreTimeStamp_ = 0
  local cfg = Z.Global.MosnterDiscoverConfig
  self.exploreIntervalTime_ = cfg[5] * 1000
  self.exploreAngles_ = math.floor(cfg[1] * 0.5)
  self.exploreInsightDis_ = cfg[2] * cfg[2]
  self.exploreTargetDis_ = cfg[3] * cfg[3]
  self.exploreTargetHideTime_ = cfg[4]
  self.showTargetContent_ = {}
  self.showArrowContent_ = {}
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
  else
    self.curInsightFlag_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value == 1
  end
  self.curCheckInsightTab_ = nil
  self.monsterDisTable_ = nil
  self:InitCfgData()
end

function ExploreMonsterData:InitCfgData()
  self.MonsterHuntListTableDatas = Z.TableMgr.GetTable("MonsterHuntListTableMgr").GetDatas()
  self.MonsterHuntLevelTableDatas = Z.TableMgr.GetTable("MonsterHuntLevelTableMgr").GetDatas()
end

function ExploreMonsterData:OnLanguageChange()
  self:InitCfgData()
end

function ExploreMonsterData:Clear()
  self.markTable_ = {}
  self.monsterTable_ = {}
  self.exploreTimeStamp_ = 0
  self.monsterDisTable_ = nil
  self.curCheckInsightTab_ = nil
  self.curInsightFlag_ = false
  self.showArrowContent_ = {}
  self.showTargetContent_ = {}
end

function ExploreMonsterData:UnInit()
  if self.cancelSource then
    self.cancelSource:Recycle()
  end
end

function ExploreMonsterData:GetUnrealScene()
  return Z.ConstValue.UnrealScenePaths.Backdrop_MonsterHandBook
end

function ExploreMonsterData:GetCancelToken()
  if not self.cancelSource then
    self.cancelSource = Z.CancelSource.Rent()
  end
  return self.cancelSource:CreateToken()
end

function ExploreMonsterData:SetMark(sceneId, monsterId)
  self.markTable_[sceneId] = self.markTable_[sceneId] or {}
  self.markTable_[sceneId][monsterId] = true
  self:SetMonsterUUid(monsterId, 0)
end

function ExploreMonsterData:CancelMark(sceneId, monsterId)
  if self.markTable_[sceneId] then
    self.markTable_[sceneId][monsterId] = nil
  end
end

function ExploreMonsterData:GetMarkByID(sceneId, monsterId)
  return self.markTable_[sceneId] and self.markTable_[sceneId][monsterId] or false
end

function ExploreMonsterData:GetMarkByScene(sceneId)
  return self.markTable_[sceneId]
end

function ExploreMonsterData:SetMonsterUUid(id, uuid)
  self.monsterTable_[id] = uuid
  if 0 < uuid then
    self.monsterDisTable_ = self.monsterDisTable_ or {}
    self.monsterDisTable_[id] = 0
  elseif self.monsterDisTable_ then
    self.monsterDisTable_[id] = nil
  end
end

function ExploreMonsterData:GetMonsterUUid(id)
  return self.monsterTable_[id]
end

function ExploreMonsterData:SetMonsterDis(id, dis)
  if not self.monsterDisTable_ then
    return
  end
  self.monsterDisTable_[id] = dis
end

function ExploreMonsterData:GetMonsterDisData(id)
  return self.monsterDisTable_ and self.monsterDisTable_[id]
end

function ExploreMonsterData:SetExploreTimeStamp(stamp)
  self.exploreTimeStamp_ = stamp
end

function ExploreMonsterData:GetExploreTimeStamp()
  return self.exploreTimeStamp_
end

function ExploreMonsterData:GetExploreIntervalTime()
  return self.exploreIntervalTime_
end

function ExploreMonsterData:GetExploreAngles()
  return self.exploreAngles_
end

function ExploreMonsterData:GetExploreInsightDis()
  return self.exploreInsightDis_
end

function ExploreMonsterData:GetExploreDis()
  return self.exploreTargetDis_
end

function ExploreMonsterData:GetExploreTargetHideTime()
  return self.exploreTargetHideTime_
end

function ExploreMonsterData:SetInsightFlag(flag)
  self.curInsightFlag_ = flag
end

function ExploreMonsterData:GetInsightFlag()
  return self.curInsightFlag_
end

function ExploreMonsterData:SetCheckInsightId(id, insight)
  self.curCheckInsightTab_ = self.curCheckInsightTab_ or {}
  self.curCheckInsightTab_[id] = insight
end

function ExploreMonsterData:GetCheckInsightById(id)
  return self.curCheckInsightTab_ and self.curCheckInsightTab_[id] or nil
end

function ExploreMonsterData:SetTargetShowContent(id, tarIndex, hide)
  self.showTargetContent_[id] = self.showTargetContent_[id] or {}
  for i = 1, #self.showTargetContent_[id] do
    if self.showTargetContent_[id][i] == tarIndex then
      if hide then
        table.remove(self.showTargetContent_[id], i)
      end
      return
    end
  end
  if not hide then
    if #self.showTargetContent_[id] == 0 then
      self.showTargetContent_[id][1] = tarIndex
    else
      local cfg = Z.TableMgr.GetTable("MonsterExploreTableMgr").GetRow(id)
      if cfg then
        local index = cfg.Target[tarIndex][1]
        for i = 1, #self.showTargetContent_[id] do
          if index < self.showTargetContent_[id][i] then
            table.insert(self.showTargetContent_[id], i, tarIndex)
            return
          end
        end
        self.showTargetContent_[id][#self.showTargetContent_[id] + 1] = tarIndex
      end
    end
  end
end

function ExploreMonsterData:GetTargetShowContent()
  return self.showTargetContent_
end

function ExploreMonsterData:ClearTargetShowContent()
  self.showTargetContent_ = {}
end

function ExploreMonsterData:ClearTargetShowContentById(id)
  self.showTargetContent_[id] = nil
end

function ExploreMonsterData:GetExploreArrowContent()
  return self.showArrowContent_
end

function ExploreMonsterData:SetExploreArrowContent(id)
  self.showArrowContent_ = self.showArrowContent_ or {}
  self.showArrowContent_[id] = true
end

function ExploreMonsterData:ClearExploreArrowContent()
  self.showArrowContent_ = {}
end

function ExploreMonsterData:ClearExploreArrowContnetById(id)
  if self.showArrowContent_ then
    self.showArrowContent_[id] = nil
  end
end

return ExploreMonsterData
