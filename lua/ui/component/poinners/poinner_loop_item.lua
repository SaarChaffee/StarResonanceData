local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local PoinnerItem = class("PoinnerItem", super)

function PoinnerItem:ctor()
end

function PoinnerItem:OnInit()
  self.unit.exploreingContainer.Go:SetActive(false)
  self.unit.waitContainer.Go:SetActive(false)
  self.unit.overContainer.Go:SetActive(false)
end

function PoinnerItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  local exploreInfo, targetInfo = Z.VMMgr.GetVM("target").GetExploreTarget(data.id)
  if exploreInfo == nil or targetInfo == nil then
    return
  end
  local stage = 0
  local progressStr = data.num .. "/" .. targetInfo.Num
  if targetInfo.Num ~= data.num then
    if exploreInfo.Type == E.DungeonExploreType.VagueTarget and data.num == 0 then
      stage = 2
      self.unit.waitContainer.content_lab.TMPLab.text = exploreInfo.Param
      self.unit.waitContainer.progress_lab.TMPLab.text = ""
    elseif exploreInfo.Type == E.DungeonExploreType.HideTarget then
      stage = self:SetFuzzyItem(exploreInfo, targetInfo, progressStr, data.levelId)
    else
      stage = 1
      self.unit.exploreingContainer.content_lab.TMPLab.text = targetInfo.TargetDes
      self.unit.exploreingContainer.progress_lab.TMPLab.text = progressStr
    end
  else
    stage = 3
    self.unit.overContainer.content_lab.TMPLab.text = targetInfo.TargetDes
    self.unit.overContainer.progress_lab.TMPLab.text = progressStr
  end
  self.unit.exploreingContainer.Go:SetActive(stage == 1)
  self.unit.waitContainer.Go:SetActive(stage == 2)
  self.unit.overContainer.Go:SetActive(stage == 3)
end

function PoinnerItem:SetFuzzyItem(exploreInfo, targetInfo, progressStr, levelId)
  local preconditionId = tonumber(exploreInfo.Param)
  local stage = 2
  if preconditionId ~= nil then
    stage = Z.VMMgr.GetVM("ui_enterdungeonscene").GetPredecessorsStage(preconditionId, levelId)
  end
  if stage == 2 then
    self.unit.waitContainer.content_lab.TMPLab.text = Lang("ToBeExplored")
    self.unit.waitContainer.progress_lab.TMPLab.text = ""
  else
    self.unit.exploreingContainer.content_lab.TMPLab.text = targetInfo.TargetDes
    self.unit.exploreingContainer.progress_lab.TMPLab.text = progressStr
  end
  return stage
end

function PoinnerItem:PlayAnim()
end

function PoinnerItem:OnBeforePlayAnim()
end

function PoinnerItem:OnUnInit()
end

return PoinnerItem
