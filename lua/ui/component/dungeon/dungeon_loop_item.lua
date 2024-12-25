local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local DungeonItem = class("DungeonItem", super)

function DungeonItem:ctor()
end

function DungeonItem:OnInit()
end

function DungeonItem:Refresh()
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
      self.unit.img_toggle.Ref:SetVisible(false, false)
      self.unit.txt_condition.TMPLab.text = exploreInfo.Param
      self.unit.txt_process.TMPLab.text = ""
    elseif exploreInfo.Type == E.DungeonExploreType.HideTarget then
      stage = self:SetFuzzyItem(exploreInfo, targetInfo, progressStr, data.levelId)
    else
      stage = 1
      self.unit.img_toggle.Ref:SetVisible(true, false)
      self.unit.checkmark.Ref:SetVisible(false, false)
      self.unit.txt_condition.TMPLab.text = targetInfo.TargetDes
      self.unit.txt_process.TMPLab.text = progressStr
    end
  else
    stage = 3
    self.unit.img_toggle.Ref:SetVisible(true, false)
    self.unit.checkmark.Ref:SetVisible(true, false)
    self.unit.txt_condition.TMPLab.text = targetInfo.TargetDes
    self.unit.txt_process.TMPLab.text = progressStr
  end
  self.unit.parent.ZLayout:ForceRebuildLayoutImmediate()
end

function DungeonItem:SetFuzzyItem(exploreInfo, targetInfo, progressStr, levelId)
  local stage = 2
  if exploreInfo.Param ~= nil then
    local paramData = string.split(exploreInfo.Param, "=")
    local id = tonumber(paramData[2])
    stage = Z.VMMgr.GetVM("ui_enterdungeonscene").GetPreconditionStage(id, levelId)
  else
    stage = Z.VMMgr.GetVM("ui_enterdungeonscene").GetStage(exploreInfo.Id, levelId)
  end
  if stage == 2 then
    self.unit.txt_condition.TMPLab.text = Lang("ToBeExplored")
    self.unit.txt_process.TMPLab.text = ""
    self.unit.bg.Ref:SetVisible(false)
    self.unit.img_toggle.Ref:SetVisible(false, false)
    self.unit.bg_unactive.Ref:SetVisible(true, false)
  elseif stage == 1 then
    self.unit.txt_condition.TMPLab.text = targetInfo.TargetDes
    self.unit.txt_process.TMPLab.text = progressStr
    self.unit.bg.Ref:SetVisible(false, false)
    self.unit.img_toggle.Ref:SetVisible(true, false)
    self.unit.checkmark.Ref:SetVisible(false, false)
  else
    self.unit.txt_condition.TMPLab.text = targetInfo.TargetDes
    self.unit.txt_process.TMPLab.text = progressStr
    self.unit.bg.Ref:SetVisible(false, false)
    self.unit.img_toggle.Ref:SetVisible(true, false)
    self.unit.checkmark.Ref:SetVisible(true, false)
  end
  return stage
end

function DungeonItem:PlayAnim()
end

function DungeonItem:OnBeforePlayAnim()
end

function DungeonItem:OnUnInit()
end

return DungeonItem
