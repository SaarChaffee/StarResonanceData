local fighterBattleResBase = class("fighterBattleResBase")
local battleResDisplay = require("ui.fighter_battle_res.battle_res_ui_show_process")
local RES_MAX_ID_OFFSET = 6

function fighterBattleResBase:ctor(root, viewParent)
  self.viewParent_ = viewParent
  self.root = root
  self.timerMgr = Z.TimerMgr.new()
  self.IsLoaded = false
  self.IsAvtive = false
end

function fighterBattleResBase:Active(fightResTemplateRow_)
  self.IsLoaded = false
  self.IsAvtive = true
  self.fightResTemplateRow_ = fightResTemplateRow_
  self.fightVm_ = Z.VMMgr.GetVM("fighterbtns")
  self.ResValue = {}
  self.DisplayEffectType = {}
  self.LastTypeOpen = {}
  if self.BattleResDisplay == nil then
    self.BattleResDisplay = battleResDisplay.new()
    self.BattleResDisplay:Init()
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local name = "battle_res_uibinder_" .. self.fightResTemplateRow_.Id
    self.uibinder_ = self.viewParent_:AsyncLoadUiUnit(self.fightResTemplateRow_.PrefabPath, name, self.root)
    self.IsLoaded = true
    self:OnActive()
    self:OnRefresh()
  end)()
end

function fighterBattleResBase:OnActive()
end

function fighterBattleResBase:Refresh()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    local resId = value
    local maxResId = value + RES_MAX_ID_OFFSET
    local progressNow = self.fightVm_:GetBattleResValue(resId)
    local progressMax = self.fightVm_:GetBattleResValue(maxResId)
    local fightResAttrRow = Z.TableMgr.GetTable("FightResAttrTableMgr").GetRow(resId)
    local fightResAttrRowMax = Z.TableMgr.GetTable("FightResAttrTableMgr").GetRow(maxResId)
    if fightResAttrRow and fightResAttrRowMax then
      if fightResAttrRow.ExactValue > 1 then
        progressNow = math.floor(progressNow / fightResAttrRow.ExactValue)
      end
      if fightResAttrRowMax.ExactValue > 1 then
        progressMax = math.floor(progressMax / fightResAttrRowMax.ExactValue)
      end
    end
    if self.ResValue[resId] == nil then
      self.ResValue[resId] = {}
    end
    self.ResValue[resId].nowNum = progressNow
    self.ResValue[resId].maxNum = progressMax
  end
  if self.IsLoaded then
    self:OnRefresh()
  end
end

function fighterBattleResBase:OnRefresh()
end

function fighterBattleResBase:OnBuffChange()
  self.ResIdOpen = {}
  self.ENowBuffList = {}
  self.TypeOpen = {}
  self.DisplayEffectType = {}
  local newTypeOpen = false
  self:cacheBuff()
  for index, value in ipairs(self.fightResTemplateRow_.ResIDs) do
    local showBuffId = self.fightResTemplateRow_.OpenBuff[index]
    local type = self.fightResTemplateRow_.UIType[index]
    local isOpen = self:checkContainBuff(showBuffId)
    if self.LastTypeOpen[type] == nil or self.LastTypeOpen[type] ~= isOpen then
      newTypeOpen = true
    end
    if isOpen then
      self.TypeOpen[type] = isOpen
    end
    self.ResIdOpen[value] = isOpen
  end
  self.LastTypeOpen = self.TypeOpen
  for index, value in ipairs(self.fightResTemplateRow_.EffectShowBuff) do
    local isContain = self:checkContainBuff(tonumber(value[2]))
    local type = tonumber(value[1])
    if self.DisplayEffectType[type] == nil or not self.DisplayEffectType[type].isOpen then
      self.DisplayEffectType[type] = {
        type = type,
        isOpen = isContain,
        param = value,
        buffItem = self.ENowBuffList[tonumber(value[2])],
        effPath = value[4]
      }
    end
  end
  if newTypeOpen and self.IsLoaded then
    self:OnRefresh()
  end
end

function fighterBattleResBase:checkContainBuff(checkBuffId)
  if checkBuffId == nil or checkBuffId == 0 then
    return true
  end
  return self.ENowBuffList[checkBuffId] ~= nil
end

function fighterBattleResBase:cacheBuff()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local buffDataList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if buffDataList then
    buffDataList = buffDataList.Value
    for i = 0, buffDataList.count - 1 do
      self.ENowBuffList[buffDataList[i].BuffBaseId] = buffDataList[i]
    end
  end
end

function fighterBattleResBase:OnBattleResCdChange(resId, fightResCd)
end

function fighterBattleResBase:DeActive()
  self.viewParent_:RemoveUiUnit("battle_res_uibinder_" .. self.fightResTemplateRow_.Id)
  self.uibinder_ = nil
  self.fightResTemplateRow_ = nil
  self.timerMgr:Clear()
  self.IsAvtive = false
  self.IsLoaded = false
  if self.BattleResDisplay then
    self.BattleResDisplay:Clear()
    self.BattleResDisplay = nil
  end
  self.ResValue = {}
  self.TypeOpen = {}
  if not self.IsLoaded then
    return
  end
  self:OnDeActive()
end

function fighterBattleResBase:OnDeActive()
end

return fighterBattleResBase
