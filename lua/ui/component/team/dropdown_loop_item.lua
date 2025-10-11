local DropDownItem = class("DropDownItem")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local heroDungeonVm = Z.VMMgr.GetVM("hero_dungeon_main")
local dungeonVm = Z.VMMgr.GetVM("dungeon")

function DropDownItem:ctor(uiView, parent, dropDowunAddress, targetItemAddress)
  self.uiView_ = uiView
  self.parent_ = parent
  self.dropDowunAddress_ = dropDowunAddress
  self.targetItemAddress_ = targetItemAddress
  self.unitNames_ = {}
end

function DropDownItem:OnInit()
end

function DropDownItem:createTargetItem(isHideAll)
  self.selectedUnit = nil
  local teamData = Z.DataMgr.Get("team_data")
  self.unitDict = {}
  local targetList = {}
  for k, v in pairs(teamData.TeamTargetTableDatas) do
    if not v.HasFatherType then
      if v.FunctionID ~= 0 then
        if funcVM.CheckFuncCanUse(v.FunctionID, true) then
          targetList[#targetList + 1] = v
        end
      elseif v.Id ~= E.TeamTargetId.All or not isHideAll then
        targetList[#targetList + 1] = v
      end
    end
  end
  local temaVm = Z.VMMgr.GetVM("team_main")
  targetList = temaVm.TargetSort(targetList)
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, #targetList do
      local targetId = targetList[i].Id
      local name = targetList[i].Name
      local targetName = "target" .. targetId
      local unit = self.uiView_:AsyncLoadUiUnit(self.dropDowunAddress_, targetName, self.parent_)
      if unit == nil then
        return
      end
      self.unitDict[targetName] = unit
      unit.lab_name2.text = name
      unit.lab_name1.text = name
      if self.uiView_.targetId_ == targetId then
        self.selectedUnit = unit
        unit.Ref:SetVisible(unit.img_on, true)
        if unit.node_adorn then
          unit.node_adorn:Restart(Z.DOTweenAnimType.Open)
        end
        unit.Ref:SetVisible(unit.img_off, false)
      else
        unit.Ref:SetVisible(unit.img_on, false)
        unit.Ref:SetVisible(unit.img_off, true)
      end
      unit.Ref:SetVisible(unit.layout_list, false)
      local childTargetList = {}
      local isHaveChildrenNode = false
      for k, v in pairs(teamData.TeamTargetTableDatas) do
        if v.BelongType == targetId then
          isHaveChildrenNode = true
          local isUnlock = true
          if targetList[i].FunctionID == E.FunctionID.HeroNormalDungeon then
            isUnlock = dungeonVm.GetDungeonIsUnlock(v.RelativeDungeonId)
          elseif targetList[i].FunctionID == E.FunctionID.HeroChallengeDungeon then
            isUnlock = heroDungeonVm.IsUnlockDungeonId(v.RelativeDungeonId)
          end
          if isUnlock then
            local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(v.RelativeDungeonId, true)
            if dungeonRow and Z.ConditionHelper.CheckCondition(dungeonRow.Condition) then
              childTargetList[#childTargetList + 1] = v
            end
          end
        end
      end
      if isHaveChildrenNode and #childTargetList == 0 then
        unit.Ref.UIComp:SetVisible(false)
      else
        unit.Ref.UIComp:SetVisible(true)
      end
      table.sort(childTargetList, function(a, b)
        return a.Sort < b.Sort
      end)
      unit.isOpen = false
      for j = 1, #childTargetList do
        local childTargetId = childTargetList[j].Id
        if self.uiView_.targetId_ == childTargetId then
          unit.isOpen = true
          break
        end
      end
      local isHaveChild = 0 < #childTargetList
      if unit.isOpen then
        unit.Ref:SetVisible(unit.layout_list, isHaveChild)
        self:targetItemActive(unit, childTargetList)
      end
      if unit.lab_team1 then
        unit.Ref:SetVisible(unit.lab_team1, not isHaveChild)
        unit.Ref:SetVisible(unit.lab_team2, not isHaveChild)
        if not isHaveChild then
          local teamTargetRow = Z.TableMgr.GetRow("TeamTargetTableMgr", targetId)
          if teamTargetRow then
            local teamMemberStr = teamTargetRow.TeamType == 0 and 5 or 20
            unit.lab_team1.text = Lang("TeamMemberNum", {val = teamMemberStr})
            unit.lab_team2.text = Lang("TeamMemberNum", {val = teamMemberStr})
          end
        end
      end
      local rotateAngle = unit.isOpen and 0 or 180
      unit.img_arrow.transform:SetRot(rotateAngle, 0, 0)
      unit.Ref:SetVisible(unit.img_arrow, isHaveChild)
      self.uiView_:AddAsyncClick(unit.btn_more, function()
        if isHaveChild then
          unit.isOpen = not unit.isOpen
          unit.Ref:SetVisible(unit.layout_list, unit.isOpen)
          local rotateAngle = unit.isOpen and 0 or 180
          unit.img_arrow.transform:SetRot(rotateAngle, 0, 0)
          self:targetItemActive(unit, childTargetList)
        else
          unit.Ref:SetVisible(unit.layout_list, false)
          if self.uiView_.targetId_ == targetId then
            return
          end
          self.uiView_:SetTargetid(targetId)
          unit.Ref:SetVisible(unit.img_on, true)
          if unit.node_adorn then
            unit.node_adorn:Restart(Z.DOTweenAnimType.Open)
          end
          unit.Ref:SetVisible(unit.img_off, false)
          if self.selectedUnit then
            self.selectedUnit.Ref:SetVisible(self.selectedUnit.img_on, false)
            self.selectedUnit.Ref:SetVisible(self.selectedUnit.img_off, true)
          end
          self.selectedUnit = unit
        end
      end)
    end
  end)()
end

function DropDownItem:targetItemActive(parentUnit, childTargetList)
  if parentUnit.isOpen then
    for j = 1, #childTargetList do
      local childTargetId = childTargetList[j].Id
      local childUnitName = "target" .. childTargetId
      if not self.unitDict[childUnitName] then
        do
          local childTargetName = childTargetList[j].Name
          local childUnit = self.uiView_:AsyncLoadUiUnit(self.targetItemAddress_, childUnitName, parentUnit.layout_list.transform)
          if childUnit == nil then
            return
          end
          childUnit.lab_name1.text = childTargetName
          childUnit.lab_name2.text = childTargetName
          local isSelect = self.uiView_.targetId_ == childTargetId
          childUnit.Ref:SetVisible(childUnit.img_on, isSelect)
          if isSelect and childUnit.node_adorn then
            childUnit.node_adorn:Restart(Z.DOTweenAnimType.Open)
          end
          childUnit.Ref:SetVisible(childUnit.img_off, not isSelect)
          if childUnit.lab_team1 then
            local teamTargetRow = Z.TableMgr.GetRow("TeamTargetTableMgr", childTargetId)
            if teamTargetRow then
              local teamMemberStr = teamTargetRow.TeamType == 0 and 5 or 20
              childUnit.lab_team1.text = Lang("TeamMemberNum", {val = teamMemberStr})
              childUnit.lab_team2.text = Lang("TeamMemberNum", {val = teamMemberStr})
            end
          end
          if isSelect then
            self.uiView_.lastSelectUnit = childUnit
            self.selectedUnit = childUnit
          end
          self.unitDict[childUnitName] = childUnit
          self.uiView_:AddAsyncClick(childUnit.btn_more, function()
            if self.uiView_.targetId_ == childTargetId then
              return
            end
            childUnit.Ref:SetVisible(childUnit.img_on, true)
            if childUnit.node_adorn then
              childUnit.node_adorn:Restart(Z.DOTweenAnimType.Open)
            end
            childUnit.Ref:SetVisible(childUnit.img_off, false)
            if self.selectedUnit then
              self.selectedUnit.Ref:SetVisible(self.selectedUnit.img_on, false)
              self.selectedUnit.Ref:SetVisible(self.selectedUnit.img_off, true)
            end
            self.selectedUnit = childUnit
            self.uiView_:SetTargetid(childTargetId)
          end)
        end
      end
    end
  else
    for k, v in pairs(childTargetList) do
      local childTargetId = v.Id
      local childUnitName = "target" .. childTargetId
      if self.uiView_.units[childUnitName] then
        self.uiView_:RemoveUiUnit(childUnitName)
        self.uiView_.units[childUnitName] = nil
        self.unitDict[childUnitName] = nil
      end
    end
  end
end

function DropDownItem:ClearUnit()
  self.selectedUnit = nil
  for k, v in pairs(self.unitDict) do
    self.uiView_:RemoveUiUnit(k)
  end
end

return DropDownItem
