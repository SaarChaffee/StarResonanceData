local DungeonConditionItem = class("DungeonConditionItem", require("ui.component.loopscrollrectitem"))
local ColorDark = Color.New(0.8509803921568627, 0.8549019607843137, 0.8549019607843137, 1)
local ColorGreen = Color.New(0.807843137254902, 0.9137254901960784, 0.5529411764705883, 1)

function DungeonConditionItem:ctor()
end

function DungeonConditionItem:OnInit()
end

function DungeonConditionItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  local exploreInfo, targetInfo = Z.VMMgr.GetVM("target").GetExploreTarget(data.id)
  if exploreInfo == nil or targetInfo == nil then
    return
  end
  local progressStr = data.num .. "/" .. targetInfo.Num
  if targetInfo.Num ~= data.num then
    if exploreInfo.Type == E.DungeonExploreType.VagueTarget and data.num == 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, false)
      self.uiBinder.lab_condition.text = exploreInfo.Param
      self.uiBinder.lab_process.text = ""
    elseif exploreInfo.Type == E.DungeonExploreType.HideTarget then
      if data.num > 0 then
        self.uiBinder.lab_condition.text = targetInfo.TargetDes
        self.uiBinder.lab_process.text = progressStr
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, false)
      else
        self:SetFuzzyItem(exploreInfo, targetInfo, progressStr, data.levelId)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, false)
      self.uiBinder.lab_condition.text = targetInfo.TargetDes
      self.uiBinder.lab_process.text = progressStr
    end
    self.uiBinder.lab_condition.color = ColorDark
    self.uiBinder.lab_process.color = ColorDark
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, true)
    self.uiBinder.lab_condition.text = targetInfo.TargetDes
    self.uiBinder.lab_process.text = progressStr
    self.uiBinder.lab_condition.color = ColorGreen
    self.uiBinder.lab_process.color = ColorGreen
  end
end

function DungeonConditionItem:SetFuzzyItem(exploreInfo, targetInfo, progressStr, levelId)
  local stage = 2
  if exploreInfo.Param ~= nil then
    local paramData = string.split(exploreInfo.Param, "=")
    local id = tonumber(paramData[2])
    stage = Z.VMMgr.GetVM("ui_enterdungeonscene").GetPreconditionStage(id, levelId)
  else
    stage = Z.VMMgr.GetVM("ui_enterdungeonscene").GetStage(exploreInfo.Id, levelId)
  end
  if stage == 2 then
    self.uiBinder.lab_condition.text = Lang("ToBeExplored")
    self.uiBinder.lab_process.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, false)
  elseif stage == 1 then
    self.uiBinder.lab_condition.text = targetInfo.TargetDes
    self.uiBinder.lab_process.text = progressStr
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, false)
  else
    self.uiBinder.lab_condition.text = targetInfo.TargetDes
    self.uiBinder.lab_process.text = progressStr
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_toggle, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.checkmark, true)
  end
  return stage
end

function DungeonConditionItem:PlayAnim()
end

function DungeonConditionItem:OnBeforePlayAnim()
end

function DungeonConditionItem:OnUnInit()
end

return DungeonConditionItem
