local super = require("ui.component.loop_list_view_item")
local WeekHuntTowerdLoopItem = class("WeekHuntTowerdLoopItem", super)
local itemPath = "ui/prefabs/weekly_hunt/weekly_hunt_reward_item_tpl"
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local headPath = "ui/prefabs/new_com/com_head_34_item"

function WeekHuntTowerdLoopItem:ctor()
  self.uiBinder = nil
  self.weeklyHuntData_ = Z.DataMgr.Get("weekly_hunt_data")
  self.seasonData_ = Z.DataMgr.Get("season_data")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function WeekHuntTowerdLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.units_ = {}
  self.headUnits_ = {}
  self.weeklyTower_ = Z.ContainerMgr.CharSerialize.weeklyTower
  self.ruleRow_ = self.weeklyHuntData_:GetClimbRuleDataBySeason(self.seasonData_.CurSeasonId)
end

function WeekHuntTowerdLoopItem:OnRefresh(data)
  if not self.ruleRow_ then
    return
  end
  self.data_ = data
  local rowCount = #self.data_.climbUpLayerRows
  self.isUnLock_ = self.data_.layer <= self.weeklyTower_.maxClimbUpId + 1
  self.isEnterLayer_ = self.data_.layer == self.uiView_.enterClimbUpId_
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot_positioning, self.isEnterLayer_)
  local layer = 0
  if rowCount == 1 then
    layer = self.data_.climbUpLayerRows[1].LayerNumber
  else
    layer = self.data_.climbUpLayerRows[1].LayerNumber .. "-" .. self.data_.climbUpLayerRows[rowCount].LayerNumber
  end
  if not self.isEnterLayer_ then
    layer = Z.RichTextHelper.ApplyColorTag(layer, "#b5b5b4")
  end
  self.uiBinder.lab_layer_num.text = layer
  Z.CoroUtil.create_coro_xpcall(function()
    self:loadLayers()
    self:loadHead()
  end)()
  self:setUnitSelectedState(self.IsSelected, true)
end

function WeekHuntTowerdLoopItem:loadLayers()
  for index, value in ipairs(self.data_.climbUpLayerRows) do
    local unitName = "layer" .. value.LayerNumber .. self.Index
    local unit = self.uiView_:AsyncLoadUiUnit(itemPath, unitName, self.uiBinder.node_compact.transform)
    if unit then
      self.units_[unitName] = unit
      local path = self.ruleRow_.Icon[value.LayarType][2]
      if path and path ~= "" then
        unit.img_bg:SetImage(path)
      end
      local isHave = self.weeklyTower_.maxClimbUpId >= value.LayerNumber
      unit.Ref:SetVisible(unit.img_have, isHave)
    end
  end
end

function WeekHuntTowerdLoopItem:loadHead()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left_middle, false)
  for charId, value in pairs(self.weeklyHuntData_.MemIdMaxClimbId) do
    if value < self.weeklyHuntData_.MaxLaler then
      value = value + 1
    end
    local climbUpLayerRow = Z.TableMgr.GetRow("ClimbUpLayerTableMgr", value, true)
    if climbUpLayerRow and climbUpLayerRow.StageId == self.Index then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_left_middle, true)
      local name = "item_head" .. charId .. self.Index
      local unit = self.uiView_:AsyncLoadUiUnit(headPath, name, self.uiBinder.node_head_34.transform)
      if unit then
        local teamMember = self.teamVm_.GetTeamMemberInfoByCharId(charId)
        local socialData
        if teamMember then
          socialData = teamMember.socialData
        else
          socialData = self.socialVm_.AsyncGetSocialData(0, charId, self.uiView_.cancelSource:CreateToken())
        end
        playerPortraitHgr.InsertNewPortraitBySocialData(unit, socialData, function()
          local idCardVM = Z.VMMgr.GetVM("idcard")
          idCardVM.AsyncGetCardData(charId, self.uiView_.cancelSource:CreateToken())
        end)
        self.headUnits_[name] = unit
      end
    end
  end
end

function WeekHuntTowerdLoopItem:OnRecycle()
  self:removeUnits()
end

function WeekHuntTowerdLoopItem:OnPointerClick()
end

function WeekHuntTowerdLoopItem:setUnitSelectedState(isSelected, isHideAnim)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_selected, isSelected)
  if not isHideAnim then
    if isSelected then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
    else
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Close)
    end
  end
end

function WeekHuntTowerdLoopItem:OnSelected(isSelected)
  if isSelected then
    self.uiView_:OnSelectedLayer(self.data_)
  end
  self:setUnitSelectedState(isSelected)
end

function WeekHuntTowerdLoopItem:OnUnInit()
  self:removeUnits()
end

function WeekHuntTowerdLoopItem:removeUnits()
  for unitName, v in pairs(self.units_) do
    self.uiView_:RemoveUiUnit(unitName)
  end
  for unitName, v in pairs(self.headUnits_) do
    self.uiView_:RemoveUiUnit(unitName)
  end
  self.headUnits_ = {}
  self.units_ = {}
end

return WeekHuntTowerdLoopItem
