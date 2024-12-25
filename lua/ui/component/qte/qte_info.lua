local qteInfo = class("qteInfo")
local QteUIPath = {
  [1] = {
    [1] = "ui/prefabs/qte/qte_weapon_sf_tpl",
    [2] = "ui/prefabs/qte/qte_weapon_knife_tpl",
    [3] = "ui/prefabs/qte/qte_weapon_knife_1_tpl",
    [4] = "ui/prefabs/qte/qte_parkour_jump_tpl",
    [5] = "ui/prefabs/qte/qte_parkour_shadow_dash_tpl"
  },
  [2] = {
    [1] = "ui/prefabs/qte/qte_weapon_sf_tpl",
    [2] = "ui/prefabs/qte/qte_weapon_knife_tpl",
    [3] = "ui/prefabs/qte/qte_weapon_knife_1_tpl",
    [4] = "ui/prefabs/qte/qte_parkour_jump_pc_tpl",
    [5] = "ui/prefabs/qte/qte_parkour_shadow_dash_pc_tpl"
  }
}

function qteInfo:ctor(qteId)
  self.Id_ = qteId
  self.maxTime_ = 0
  self.duration_ = 0
  self.curIndex_ = -1
  self.isStop_ = false
  self.curTriggerCount_ = 0
  self.sucessNeedCount_ = 0
  self.maxTriggerCount_ = 0
  self.sucessful_ = false
  self.qteAreaList = {}
  self.qteSuccessIdxList_ = {}
  self.UIPath = ""
  self.qteRow = nil
  self.maxDotCount = 0
  self:init()
end

function qteInfo:init()
  self.qteRow = Z.TableMgr.GetTable("QteTableMgr").GetRow(self.Id_)
  if self.qteRow == nil then
    return
  end
  if not self:parse(self.qteRow) then
    logGreen("qteInfo parse failed !")
    return
  end
end

function qteInfo:parse(qteRow)
  self.maxTime_ = qteRow.maxTime
  local idx = 0
  for _, group in ipairs(qteRow.triggerTime) do
    idx = idx + 1
    local qteArea = {}
    local rangeStartTime = group[1]
    local rangeEndTime = group[2]
    local areaLen = group[3]
    qteArea.areaLen = areaLen
    if areaLen > self.maxTime_ then
      return false
    end
    local rangeTime = rangeEndTime + 5.0E-6 - rangeStartTime
    if areaLen > rangeTime then
      return false
    elseif rangeTime == areaLen then
      qteArea.startTime = rangeStartTime
      qteArea.endTime = rangeEndTime
    else
      math.randomseed(os.time())
      local n = rangeEndTime - areaLen - rangeStartTime
      qteArea.startTime = math.random() * n + rangeStartTime
      local endTime = qteArea.startTime + areaLen
      qteArea.endTime = rangeEndTime >= endTime and endTime or rangeEndTime
    end
    for _, v in ipairs(qteRow.timeQuantum) do
      local tbegin = v[1]
      local tend = v[2]
      if rangeEndTime <= tend and rangeEndTime > tbegin then
        qteArea.maxTime = tend - tbegin
        break
      end
    end
    table.insert(self.qteAreaList, qteArea)
  end
  self.maxTriggerCount_ = qteRow.triggerCount[1]
  self.sucessNeedCount_ = qteRow.triggerCount[2]
  self.maxDotCount = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrMaxShimmyJumpPac")).Value
  self.UIPath = Z.IsPCUI and QteUIPath[2][qteRow.UIType] or QteUIPath[1][qteRow.UIType]
  return true
end

function qteInfo:GetAreaInfo(idx)
  return self.qteAreaList[idx]
end

function qteInfo:getAreaIndex(curTime)
  for k, v in ipairs(self.qteAreaList) do
    if curTime <= v.endTime and curTime >= v.startTime then
      return k - 1
    end
  end
  return -1
end

function qteInfo:OnTrigger(curTime)
  self.curTriggerCount_ = self.curTriggerCount_ + 1
  local idx = self:getAreaIndex(curTime)
  if 0 <= idx then
    table.insert(self.qteSuccessIdxList_, idx)
  end
  if #self.qteSuccessIdxList_ >= self.sucessNeedCount_ then
    self.isStop_ = true
    self.sucessful_ = true
  end
  if self.curTriggerCount_ >= self.maxTriggerCount_ then
    self.isStop_ = true
  end
end

function qteInfo:CheckDot()
  local enegryCount = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EParkourQTEEnergyBean).Value
  if enegryCount >= self.maxDotCount then
    Z.EntityMgr.PlayerEnt:SetLuaIntAttr(Z.LocalAttr.EParkourQTEEnergyBean, 0)
  end
end

function qteInfo:SyncRes()
  local worldProxy = require("zproxy.world_proxy")
  worldProxy.QteEnd(self.Id_, self.qteSuccessIdxList_, self.sucessful_)
  if self.sucessful_ then
    if self.qteRow.QTEType == 0 then
      for _, v in ipairs(self.qteSuccessIdxList_) do
        local skillId = 0
        if 0 < #self.qteRow.playSkill then
          skillId = self.qteRow.playSkill[v + 1][1]
        end
        Z.PlayerInputController:QteSkillUsedEvent(self.Id_, skillId)
        local eventParam
        if 0 < #self.qteRow.EventParams then
          eventParam = self.qteRow.EventParams[v + 1][1]
        end
        local actionRow = Z.TableMgr.GetTable("ParkourStyleActionTableMgr").GetRow(eventParam)
        if actionRow ~= nil then
          local enegryCount = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EParkourQTEEnergyBean).Value + actionRow.Dot
          if enegryCount >= self.maxDotCount then
            enegryCount = self.maxDotCount
          end
          Z.EntityMgr.PlayerEnt:SetLuaIntAttr(Z.LocalAttr.EParkourQTEEnergyBean, enegryCount)
        end
        Z.EventMgr:Dispatch("OnQteSucess", self.Id_, eventParam)
      end
    else
    end
  else
    Z.EntityMgr.PlayerEnt:SetLuaIntAttr(Z.LocalAttr.EParkourQTEEnergyBean, 0)
  end
end

return qteInfo
