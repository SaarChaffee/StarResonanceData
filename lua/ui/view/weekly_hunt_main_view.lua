local UI = Z.UI
local super = require("ui.ui_view_base")
local Weekly_hunt_mainView = class("Weekly_hunt_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local rewardLoopItem = require("ui.component.week_hunt.week_hunt_reward_loop_item")
local towerLoopItem = require("ui.component.week_hunt.week_hunt_tower_loop_item")
local lefTowerLoopItem = require("ui.component.week_hunt.week_hunt_left_tower_loop_item")
local headPath = "ui/prefabs/new_com/com_head_34_item"

function Weekly_hunt_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weekly_hunt_main")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.weeklyHuntData_ = Z.DataMgr.Get("weekly_hunt_data")
  self.weeklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
  self.awardprevVm_ = Z.VMMgr.GetVM("awardpreview")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.teamMainVm_ = Z.VMMgr.GetVM("team_main")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.enterdungeonsceneVm_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function Weekly_hunt_mainView:initUibinder()
  self.closeBtn_ = self.uiBinder.btn_close
  self.titleLab_ = self.uiBinder.lab_title
  self.askBtn_ = self.uiBinder.btn_ask
  self.rankBtn_ = self.uiBinder.btn_rankings
  self.rewardBtn_ = self.uiBinder.btn_target_reward
  self.rewardNumLab_ = self.uiBinder.lab_target_reward_num
  self.teamBtn_ = self.uiBinder.btn_team
  self.challengeBtn_ = self.uiBinder.btn_start_challenge
  self.posBtn_ = self.uiBinder.btn_positioning
  self.curTeamLayer_ = self.uiBinder.lab_current_team_layer
  self.curTeamLayer2_ = self.uiBinder.lab_current_team_layer2
  self.curTeamLayerBg_ = self.uiBinder.img_current_team_layer_bg
  self.curLayerLab_ = self.uiBinder.lab_layer
  self.smallMonsterNode_ = self.uiBinder.node_small_monsters
  self.smallMonsterLoopList_ = self.uiBinder.node_loop_smallmossters_item
  self.eliteMonsterNode_ = self.uiBinder.node_elite_monsters
  self.eliteMonsterLoopList_ = self.uiBinder.node_loop_elite_item
  self.bossNode_ = self.uiBinder.node_boss
  self.bossMonsterLoopList_ = self.uiBinder.node_loop_boss_item
  self.affixNode_ = self.uiBinder.node_event_item
  self.eventLab_ = self.uiBinder.lab_event
  self.towerLoopList_ = self.uiBinder.node_loop_tower
  self.bottomNode_ = self.uiBinder.node_bottom
  self.loopListSucreenItem_ = self.uiBinder.loop_list_screen_item
  self.upHeadParent_ = self.uiBinder.node_head_up_34
  self.downHeadParent_ = self.uiBinder.node_head_down_34
  self.upHeadNode_ = self.uiBinder.node_have_head_up
  self.downHeadNode_ = self.uiBinder.node_have_head_down
  self.leftTowerLoop_ = self.uiBinder.node_loop_left_tower
  self.surplusTimeLab_ = self.uiBinder.lab_surplus_time
  self.anim_ = self.uiBinder.anim
  self.uiDepth_ = self.uiBinder.weekly_hunt_main
  self.rewardUiDepth_ = self.uiBinder.node_left_bottom_anim
  self.leftTowerContent_ = self.uiBinder.content
  self.upArrowImg_ = self.uiBinder.img_arrow_up
  self.downArrowImg_ = self.uiBinder.img_arrow_down
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.uiDepth_:AddChildDepth(self.rewardUiDepth_)
end

function Weekly_hunt_mainView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.weeklyHuntVm_.CloseWeekHuntView()
  end)
  self:AddClick(self.askBtn_, function()
    self.helpsysVM_.OpenFullScreenTipsView(500300)
  end)
  self:AddClick(self.rankBtn_, function()
  end)
  self:AddClick(self.rewardBtn_, function()
    self.weeklyHuntVm_.OpenTargetView()
  end)
  self:AddClick(self.teamBtn_, function()
    self.teamMainVm_.OpenTeamMainView(self.teamTargetId_)
  end)
  self:AddClick(self.posBtn_, function()
    self:moveCurrentLayer()
  end)
  self:AddAsyncClick(self.challengeBtn_, function()
    if self.climbUpLayerRow_ then
      local ret = self.weeklyHuntVm_.Enterdungeon(self.climbUpLayerRow_.DungeonId, self.cancelSource:CreateToken())
    end
  end)
end

function Weekly_hunt_mainView:initDatas()
  self.affixUnits_ = {}
  self.headUnits_ = {}
  self.layerRow_ = {}
  self.lastIndex = 0
  self.minIndex_ = 1
  self.maxIndex_ = 0
  self.enterClimbUpId_ = 0
end

function Weekly_hunt_mainView:initUi()
  self:loadHead()
  self:startAnimatedShow()
  self.commonVM_.SetLabText(self.titleLab_, {
    E.FunctionID.WeeklyHunt
  })
  local layer = Lang("WeeklyHuntTeamBeginLayer", {
    val = self.enterClimbUpId_
  })
  self.curTeamLayer_.text = layer
  self.curTeamLayer2_.text = layer
  self.rewardNumLab_.text = Z.ContainerMgr.CharSerialize.weeklyTower.maxClimbUpId
  self.smallLoopListView_ = loopListView.new(self, self.smallMonsterLoopList_, rewardLoopItem, "com_item_square_8")
  self.smallLoopListView_:Init({})
  self.eliteLoopListView_ = loopListView.new(self, self.eliteMonsterLoopList_, rewardLoopItem, "com_item_square_8")
  self.eliteLoopListView_:Init({})
  self.bossLoopListView_ = loopListView.new(self, self.bossMonsterLoopList_, rewardLoopItem, "com_item_square_8")
  self.bossLoopListView_:Init({})
  self.towerLoopListView_ = loopListView.new(self, self.towerLoopList_, towerLoopItem, "weekly_hunt_item_tpl")
  self.leftTowerLoopListView_ = loopListView.new(self, self.leftTowerLoop_, lefTowerLoopItem)
  local seasonData = Z.DataMgr.Get("season_data")
  local seasonId = seasonData.CurSeasonId
  local ruleRow = self.weeklyHuntData_:GetClimbRuleDataBySeason(seasonId)
  self.leftTowerMaxcount_ = 0
  local stageData = {}
  if ruleRow then
    stageData = ruleRow.JumpStage
    self.leftTowerMaxcount_ = #ruleRow.JumpStage
    self.surplusTimeLab_.text = Z.TimeTools.FormatToDHM(Z.TimeTools.GetTimeLeftInSpecifiedTime(ruleRow.TimerId))
  end
  self.leftTwoerTyps_ = {}
  for key, value in ipairs(stageData) do
    if key == 1 then
      self.leftTwoerTyps_[key] = 0
    elseif key ~= self.leftTowerMaxcount_ then
      self.leftTwoerTyps_[key] = 2
    end
  end
  self.leftTowerLoopListView_:SetGetPrefabNameFunc(function(stage)
    if stage == 1 then
      return "weekly_hunt_item_top_tpl"
    elseif stage == self.leftTowerMaxcount_ then
      return "weekly_hunt_item_bottom_tpl"
    elseif stage == self.leftTowerMaxcount_ / 2 then
      return "weekly_hunt_item_middle_tpl_2"
    else
      return "weekly_hunt_item_middle_tpl_" .. self.leftTwoerTyps_[stage]
    end
  end)
  self.leftTowerLoopListView_:Init(stageData)
  self.towerLoopData_ = self.weeklyHuntData_:GetClimbUpLayerDatasBySeason(seasonId)
  self.layerCount_ = #self.towerLoopData_
  self.towerLoopListView_:Init(self.towerLoopData_)
  self:moveCurrentLayer()
  self.loopListSucreenItem_:SetLoopListView(self.towerLoopList_)
  self:AddClick(self.loopListSucreenItem_, function(minIndex, maxIndex)
    self:RefreshHeadParent(minIndex + 1, maxIndex + 1)
  end)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeeklyHuntTarget, self, self.rewardBtn_.transform)
  if self.selectedClimbUpLayerData_ then
    Z.Delay(0.5, self.cancelSource:CreateToken())
    self:moveLeftContent(self.selectedClimbUpLayerData_.jumpStage)
  end
end

function Weekly_hunt_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initUibinder()
  self:initBtns()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initDatas()
    local ret = self.weeklyHuntVm_.AsyncGetTeamTowerLayerInfo(self.cancelSource:CreateToken())
    if ret then
      if ret.enterClimbUpId == 0 then
        self.enterClimbUpId_ = self.weeklyHuntData_.MaxLaler
        self.isPass_ = true
      else
        self.enterClimbUpId_ = ret.enterClimbUpId
      end
      self.climbUpLayerRow_ = Z.TableMgr.GetRow("ClimbUpLayerTableMgr", self.enterClimbUpId_)
      if self.climbUpLayerRow_ == nil then
        return
      end
      self.weeklyHuntData_.MemIdMaxClimbId = ret.memIdMaxClimbId
      self.teamTargetId_ = self.teamMainVm_.GetTargetIdByDungeonId(self.climbUpLayerRow_.DungeonId)
      self:initUi()
    end
  end)()
  Z.AudioMgr:Play("UI_Event_Tower_In")
end

function Weekly_hunt_mainView:moveCurrentLayer()
  if not self.climbUpLayerRow_ then
    return
  end
  local index = self.climbUpLayerRow_.StageId - 1
  if index == 0 then
    index = 1
  end
  self.towerLoopListView_:ClearAllSelect()
  self.selectedClimbUpLayerData_ = self.towerLoopData_[index]
  self.towerLoopListView_:MovePanelToItemIndex(index, 150)
  self.towerLoopListView_:SetSelected(self.climbUpLayerRow_.StageId)
end

function Weekly_hunt_mainView:moveLeftContent(index)
  local y = 0
  if index == 1 then
  else
    y = 888
    for key, type in ipairs(self.leftTwoerTyps_) do
      if index <= key then
        break
      end
      if type == 1 then
        y = y + 464
      elseif type == 2 then
        y = y + 1248
      end
    end
    if index == self.leftTowerMaxcount_ then
      y = y + 510 - Z.UIRoot.CurScreenSize.y
    end
  end
  self.leftTowerContent_:DoAnchorPosMove(Vector2.New(0, y), 1)
end

function Weekly_hunt_mainView:OnSelectedLayer(data)
  self:startTabPlaySelectAnim()
  self.selectedClimbUpLayerData_ = data
  if #data.climbUpLayerRows == 1 then
    self.curLayerLab_.text = data.layer .. Lang("Layer")
  else
    self.curLayerLab_.text = data.layer .. "-" .. data.climbUpLayerRows[#data.climbUpLayerRows].LayerNumber .. Lang("Layer")
  end
  self:moveLeftContent(data.jumpStage)
  local isShowBtn = self.climbUpLayerRow_.StageId == data.stageId and not self.isPass_
  self.uiBinder.Ref:SetVisible(self.bottomNode_, isShowBtn)
  self.uiBinder.Ref:SetVisible(self.curTeamLayerBg_, not isShowBtn)
  self:loadEvent()
  local awardId = self.selectedClimbUpLayerData_.awards[1]
  self.uiBinder.Ref:SetVisible(self.smallMonsterNode_, awardId ~= nil)
  if awardId then
    local awardList = self.awardprevVm_.GetAllAwardPreListByIds(awardId)
    self.smallLoopListView_:RefreshListView(awardList)
  end
  local awardId = self.selectedClimbUpLayerData_.awards[2]
  self.uiBinder.Ref:SetVisible(self.eliteMonsterNode_, awardId ~= nil)
  if awardId then
    local awardList = self.awardprevVm_.GetAllAwardPreListByIds(awardId)
    self.eliteLoopListView_:RefreshListView(awardList)
  end
  local awardId = self.selectedClimbUpLayerData_.awards[3]
  self.uiBinder.Ref:SetVisible(self.bossNode_, awardId ~= nil)
  if awardId then
    local awardList = self.awardprevVm_.GetAllAwardPreListByIds(awardId)
    self.bossLoopListView_:RefreshListView(awardList)
  end
end

function Weekly_hunt_mainView:loadEvent()
  self.uiBinder.Ref:SetVisible(self.eventLab_, false)
  self.uiBinder.Ref:SetVisible(self.affixNode_, false)
  if not self.selectedClimbUpLayerData_ or table.zcount(self.selectedClimbUpLayerData_.affixIds) == 0 then
    return
  end
  local eventItemPath = self.prefabCache_:GetString("event_item")
  if eventItemPath == "" or eventItemPath == nil then
    return
  end
  for unitName, unit in pairs(self.affixUnits_) do
    self:RemoveUiUnit(unitName)
  end
  self.uiBinder.Ref:SetVisible(self.affixNode_, true)
  self.uiBinder.Ref:SetVisible(self.eventLab_, true)
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in pairs(self.selectedClimbUpLayerData_.affixIds) do
      local name = "affix" .. value
      local unit = self:AsyncLoadUiUnit(eventItemPath, name, self.affixNode_.transform)
      if unit then
        self.affixUnits_[name] = unit
        local affixRow = Z.TableMgr.GetRow("AffixTableMgr", value)
        if affixRow then
          self:AddClick(unit.btn_affix, function()
            Z.CommonTipsVM.OpenAffixTips({value}, self.affixNode_.transform)
          end)
          unit.Ref:SetVisible(unit.img_kay, false)
          unit.Ref:SetVisible(unit.img_clock, false)
          unit.img_affix:SetImage(affixRow.Icon)
        end
      end
    end
  end)()
end

function Weekly_hunt_mainView:loadHead()
  Z.CoroUtil.create_coro_xpcall(function()
    for charId, v in pairs(self.weeklyHuntData_.MemIdMaxClimbId) do
      local name = "head" .. charId
      local unit = self:AsyncLoadUiUnit(headPath, name, self.upHeadParent_.transform)
      if unit then
        local teamMember = self.teamVm_.GetTeamMemberInfoByCharId(charId)
        local socialData
        if teamMember then
          socialData = teamMember.socialData
        else
          socialData = self.socialVm_.AsyncGetSocialData(0, charId, self.cancelSource:CreateToken())
        end
        playerPortraitHgr.InsertNewPortraitBySocialData(unit, socialData, function()
          local idCardVM = Z.VMMgr.GetVM("idcard")
          idCardVM.AsyncGetCardData(charId, self.cancelSource:CreateToken())
        end)
        self.headUnits_[charId] = unit
      end
    end
  end)()
end

function Weekly_hunt_mainView:RefreshHeadParent(minIndex, maxIndex)
  local upCount = 0
  local downCount = 0
  for charId, value in pairs(self.weeklyHuntData_.MemIdMaxClimbId) do
    local unit = self.headUnits_[charId]
    if unit then
      if value < self.weeklyHuntData_.MaxLaler then
        value = value + 1
      end
      if self.layerRow_[value] == nil then
        self.layerRow_[value] = Z.TableMgr.GetRow("ClimbUpLayerTableMgr", value, true)
      end
      if self.layerRow_[value] then
        if maxIndex >= self.layerRow_[value].StageId and minIndex <= self.layerRow_[value].StageId then
          unit.Ref.UIComp:SetVisible(false)
        else
          unit.Ref.UIComp:SetVisible(true)
          if minIndex > self.layerRow_[value].StageId then
            unit.Trans:SetParent(self.upHeadParent_.transform)
            upCount = upCount + 1
          elseif maxIndex < self.layerRow_[value].StageId then
            unit.Trans:SetParent(self.downHeadParent_.transform)
            downCount = downCount + 1
          end
        end
      end
    end
  end
  self.uiBinder.Ref:SetVisible(self.upArrowImg_, minIndex ~= 1)
  self.uiBinder.Ref:SetVisible(self.downArrowImg_, maxIndex ~= self.layerCount_)
  self.uiBinder.Ref:SetVisible(self.upHeadNode_, 0 < upCount)
  self.uiBinder.Ref:SetVisible(self.downHeadNode_, 0 < downCount)
end

function Weekly_hunt_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.smallLoopListView_ then
    self.smallLoopListView_:UnInit()
    self.smallLoopListView_ = nil
  end
  if self.eliteLoopListView_ then
    self.eliteLoopListView_:UnInit()
    self.eliteLoopListView_ = nil
  end
  if self.bossLoopListView_ then
    self.bossLoopListView_:UnInit()
    self.bossLoopListView_ = nil
  end
  if self.towerLoopListView_ then
    self.towerLoopListView_:UnInit()
    self.towerLoopListView_ = nil
  end
  if self.leftTowerLoopListView_ then
    self.leftTowerLoopListView_:UnInit()
    self.leftTowerLoopListView_ = nil
  end
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.AudioMgr:Play("UI_Event_TowerSlide_End")
end

function Weekly_hunt_mainView:OnRefresh()
end

function Weekly_hunt_mainView:startAnimatedShow()
  self.anim_:Rewind(Z.DOTweenAnimType.Open)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Weekly_hunt_mainView:startTabPlaySelectAnim()
  Z.AudioMgr:Play("UI_Event_TowerSlide_Start")
  self.anim_:Restart(Z.DOTweenAnimType.Tween_0)
end

return Weekly_hunt_mainView
