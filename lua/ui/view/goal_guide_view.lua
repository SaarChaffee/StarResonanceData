local UI = Z.UI
local super = require("ui.ui_subview_base")
local GoalGuideView = class("GoalGuideView", super)
local GUIDE_FLAG_PATH = "ui/prefabs/guide/guide_flag_tpl"

function GoalGuideView:ctor()
  self.uiBinder = nil
  super.ctor(self, "guide_tpl", "guide/guide_tpl", UI.ECacheLv.None)
  self.guideData_ = Z.DataMgr.Get("goal_guide_data")
  self.questData_ = Z.DataMgr.Get("quest_data")
end

function GoalGuideView:OnActive()
  self.effectTimer_ = nil
  self.flagUnitNameDict_ = {}
  self.flagUnits_ = {}
  self:initAllGuideFlag()
  self:bindEvents()
end

function GoalGuideView:OnRefresh()
end

function GoalGuideView:OnDeActive()
  self.effectTimer_ = nil
  self.flagUnitNameDict_ = nil
end

function GoalGuideView:initAllGuideFlag()
  local dict = self.guideData_:GetAllGuideGoalsDict()
  for src, _ in pairs(dict) do
    self:initFlagUnitsBySource(src)
  end
end

function GoalGuideView:onRefreshFlagPos(src, info)
  local name = src * 100 + info.Uid .. tostring(info.PosType)
  if self.flagUnits_[name] then
    self.flagUnits_[name].node_flag_comp:SetGoalPosInfo(info)
  end
end

function GoalGuideView:initFlagUnitsBySource(src)
  local trackRow = Z.TableMgr.GetTable("TargetTrackTableMgr").GetRow(src)
  if not trackRow or trackRow.SceneTrack == 0 then
    return
  end
  self:clearFlagUnitsBySource(src)
  local goalList = self.guideData_:GetGuideGoalsBySource(src)
  if not goalList then
    return
  end
  self.flagUnitNameDict_[src] = {}
  Z.CoroUtil.create_coro_xpcall(function()
    for idx, info in ipairs(goalList) do
      if info.IsShowTrackFlagUI then
        local name = src * 100 + info.Uid .. tostring(info.PosType)
        table.insert(self.flagUnitNameDict_[src], name)
        local unit = self:AsyncLoadUiUnit(GUIDE_FLAG_PATH, name, self.uiBinder.Trans)
        if unit then
          self.flagUnits_[name] = unit
          unit.node_flag_comp:SetGoalPosInfo(info)
          local path = trackRow.Icon
          if path and path ~= "" then
            unit.img_icon:SetImage(path)
          end
        end
      end
    end
    if src == E.GoalGuideSource.Quest then
      self:refreshQuestGuideIcon()
    end
  end)()
end

function GoalGuideView:clearFlagUnitsBySource(src)
  if not self.flagUnitNameDict_[src] then
    return
  end
  for _, name in ipairs(self.flagUnitNameDict_[src]) do
    self:RemoveUiUnit(name)
  end
  self.flagUnitNameDict_[src] = nil
end

function GoalGuideView:refreshQuestGuideIcon(isHideEffect)
  if not self.flagUnitNameDict_[E.GoalGuideSource.Quest] then
    return
  end
  local nameList = table.zclone(self.flagUnitNameDict_[E.GoalGuideSource.Quest])
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local path = questIconVM.GetStateIconByQuestId(self.questData_:GetQuestTrackingId())
  if path and path ~= "" then
    for _, name in ipairs(nameList) do
      local unit = self.units[name]
      if unit then
        unit.img_icon:SetImage(path)
      end
    end
    if not isHideEffect then
      self.timerMgr:StopTimer(self.effectTimer_)
      for _, name in ipairs(nameList) do
        local unit = self.units[name]
        if unit then
          unit.effect:SetEffectGoVisible(true)
          unit.audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_1)
        end
      end
      self.effectTimer_ = self.timerMgr:StartTimer(function()
        for _, name in ipairs(nameList) do
          local unit = self.units[name]
          if unit then
            unit.effect:SetEffectGoVisible(false)
          end
        end
      end, 1)
    end
  else
    self.timerMgr:StopTimer(self.effectTimer_)
    for _, name in ipairs(nameList) do
      local unit = self.units[name]
      if unit then
        unit.effect:SetEffectGoVisible(false)
        unit.audio:Stop()
      end
    end
  end
end

function GoalGuideView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
  Z.EventMgr:Add(Z.ConstValue.OnRefreshGuidePos, self.onRefreshFlagPos, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StateChange, self.onQuestStateChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.ClickTrackBar, self.onClickTrackBar, self)
end

function GoalGuideView:onGoalGuideChange(src, oldGoalList)
  self:initFlagUnitsBySource(src)
end

function GoalGuideView:onClickTrackBar(questId)
  self:refreshQuestGuideIcon()
end

function GoalGuideView:onQuestStateChange(questId)
  if self.questData_:GetQuestTrackingId() ~= questId then
    return
  end
  self:refreshQuestGuideIcon()
end

return GoalGuideView
