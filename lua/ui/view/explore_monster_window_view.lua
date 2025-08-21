local UI = Z.UI
local loop_grid_view = require("ui/component/loop_grid_view")
local loop_list_view = require("ui/component/loop_list_view")
local monsterItem_ = require("ui/component/explore_monster/explore_monster_monster_item")
local targetItem_ = require("ui/component/explore_monster/explore_monster_target_loop_item")
local rewardItem_ = require("ui/component/explore_monster/explore_monster_reward_item")
local itemFilter = require("ui.view.item_filters_view")
local super = require("ui.ui_view_base")
local Explore_monster_windowView = class("Explore_monster_windowView", super)
local ShowPosOffset = Vector3.New(-0.26, 0, 0)
local HelpLibraryId_ = 30020
local rotation_ = Quaternion.Euler(Vector3.New(0, 160, 0))
local stringEmpty_ = ""
local expStr_ = "%s/%s"
local topTitleStr_ = Lang("RaidManual")
local typeNameList_ = {
  [1] = Lang("MonsterLevelNormal"),
  [2] = Lang("MonsterLevelElite"),
  [3] = Lang("MonsterLevelBoss"),
  [4] = Lang("MagicalCreature")
}
local typeFuntionId = {
  [1] = E.FunctionID.ExploreMonsterNormal,
  [2] = E.FunctionID.ExploreMonsterElite,
  [3] = E.FunctionID.ExploreMonsterBoss,
  [4] = E.FunctionID.MagicalCreature
}
local currencyList_ = {
  [2] = {
    Z.MonsterHunt.MonsterHuntEliteBootyKeyId
  },
  [3] = {
    Z.MonsterHunt.MonsterHuntBossBootyKeyId
  }
}
local titleStrs_ = {}
local currency_item_list = require("ui.component.currency.currency_item_list")

function Explore_monster_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "explore_monster_window")
  self.vm_ = Z.VMMgr.GetVM("explore_monster")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  titleStrs_ = {
    Lang("PlaceAndTimeOfOccurrence"),
    Lang("RegionAppearance")
  }
end

function Explore_monster_windowView:initWidget()
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(HelpLibraryId_)
  end)
  self:AddClick(self.uiBinder.btn_main_close, function()
    self.uiBinder.input_search.text = stringEmpty_
    self.vm_.CloseExploreMonsterWindow()
  end)
  self:AddClick(self.uiBinder.btn_level, function()
    self.vm_.OpenExploreMonsterGradeWindow()
  end)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MonsterHuntLevel, self, self.uiBinder.btn_level.transform)
  self:AddClick(self.uiBinder.btn_search, function()
    self:SetUIVisible(self.uiBinder.node_input_bg, true)
    self:SetUIVisible(self.uiBinder.btn_search, false)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self:SetUIVisible(self.uiBinder.node_input_bg, false)
    self:SetUIVisible(self.uiBinder.btn_search, true)
    self:onClickDeleteBtn()
  end)
  self.monster_name_label_ = self.uiBinder.lab_title
  self.monster_quest_label_ = self.uiBinder.lab_info
  self.unrealsceneTrigger_ = self.uiBinder.rayimg_unrealscene_drag
  self.mark_btn_ = self.uiBinder.btn_square_new
  self.cancel_mark_btn_ = self.uiBinder.btn_cancel
  self:AddClick(self.mark_btn_, function()
    local cfg = self.curSelectMonsterData_.ExploreData
    local commonVM = Z.VMMgr.GetVM("common")
    local funcName = commonVM.GetTitleByConfig(E.FunctionID.ExploreMonster)
    self.quickJumpVM_.DoJumpByConfigParam(cfg.QuickJumpType, cfg.QuickJumpParam, {
      DynamicFlagName = funcName,
      goalGuideSource = E.GoalGuideSource.MonsterExplore
    })
  end, nil, nil)
  self:AddClick(self.cancel_mark_btn_, function()
    local cfg = self.curSelectMonsterData_.ExploreData
    self.vm_.CancelTrackMonster(cfg.MonsterId, cfg.Scene)
    self:showBtnState()
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    guideVM.SetGuideGoals(E.GoalGuideSource.MonsterExplore, {})
  end)
  self:AddClick(self.unrealsceneTrigger_.onBeginDrag, function(go, eventData)
    self:onUnrealsceneBeginDrag(eventData)
  end)
  self:AddClick(self.unrealsceneTrigger_.onDrag, function(go, eventData)
    self:onUnrealsceneDrag(eventData)
  end)
  self:AddClick(self.unrealsceneTrigger_.onEndDrag, function(go, eventData)
    self:onUnrealsceneEndDrag(eventData)
  end)
  self.uiBinder.group_title02.togs_tab.tog_loot:AddListener(function()
    self.isBoxReward_ = true
    self:showAwardItem()
  end)
  self.uiBinder.group_title02.togs_tab.tog_drop:AddListener(function()
    self.isBoxReward_ = false
    self:showAwardItem()
  end)
  self.itemFilter_ = itemFilter.new(self)
  self:AddAsyncClick(self.uiBinder.btn_small_square_new, function()
    self:openItemFilter()
  end)
  local dataList_ = {}
  self.monsterScrollRect_ = loop_grid_view.new(self, self.uiBinder.scrollview_left, monsterItem_, "explore_monster_item_tpl", true)
  self.monsterScrollRect_:Init(dataList_)
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.scrollview_item, rewardItem_, "com_item_square_8", true)
  self.rewardScrollRect_:Init(dataList_)
  self.uiBinder.input_search:AddListener(function(text)
    self:UnSelectMonsterListItem()
    self:onEndEditChange(text)
  end, true)
  self:SetUIVisible(self.uiBinder.node_input_bg, false)
  self:SetUIVisible(self.uiBinder.btn_search, true)
  self.uiBinder.input_search.text = stringEmpty_
  self.filterName_ = stringEmpty_
end

function Explore_monster_windowView:initBaseData()
  self.filterTags_ = {
    [E.ItemFilterType.MonsterHunt] = {}
  }
  local sceneId_ = self.viewData.sceneId
  if 0 < sceneId_ then
    self.filterTags_[E.ItemFilterType.MonsterHunt][sceneId_] = sceneId_
  end
  self.rareTypes_ = {}
  local r1_ = {}
  local r_ = self.vm_.GetExploreMonsterListByFilter({}, 0, "")
  for _, value in ipairs(r_) do
    local cfg_ = value.ExploreData.Scene
    if r1_[cfg_] == nil then
      r1_[cfg_] = cfg_
      self.rareTypes_[#self.rareTypes_ + 1] = cfg_
    end
  end
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
end

function Explore_monster_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self:startAnimatedShow()
  self:initWidget()
  self:initBaseData()
  self.monsterListInit_ = true
  self.targetListInit_ = true
  self.rewardListInit_ = true
  self.targetItemTable_ = {}
  self.curShowModel_ = nil
  self.itemClassTab_ = {}
  self.toggleList_ = {}
  self.monsterTargets_ = {}
  self.monsterTargetsUnits_ = {}
  self.unitTokenDict_ = {}
  self.filterName_ = stringEmpty_
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:showTitle()
  self:initLeftToggle()
  self:RereshLevelInfo()
  self:onSelectFilter(self.filterTags_)
  local sceneId_ = self.viewData.sceneId
  if 0 < sceneId_ then
    self:openItemFilter()
  end
  self.viewData.monsterId = nil
  Z.EventMgr:Add(Z.ConstValue.GoalGuideMonsterSuccess, self.goalGuideMonsterSuccess, self)
  self:bindEvent()
end

function Explore_monster_windowView:bindEvent()
  function self.monsterExpChange_(container, dirty)
    if dirty.curExp then
      self:RereshLevelInfo()
    end
  end
  
  Z.ContainerMgr.CharSerialize.monsterHuntInfo.Watcher:RegWatcher(self.monsterExpChange_)
end

function Explore_monster_windowView:GetCacheData()
  local viewData = {
    sceneId = self.viewData.sceneId or 0,
    pageType = self.currentSelectMonsterType_,
    monsterId = self.curSelectMonsterData_.ExploreData.MonsterId
  }
  return viewData
end

function Explore_monster_windowView:OnDeActive()
  self:startAnimatedHide()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.lastLevel_ = nil
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass.cls:UnInit()
    itemClass.unit = nil
  end
  self.itemClassTab_ = nil
  self.toggleList_ = nil
  self.monsterListInit_ = nil
  self.targetListInit_ = nil
  self.rewardListInit_ = nil
  self.monsterScrollRect_:UnInit()
  self.monsterScrollRect_ = nil
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  Z.EventMgr:Remove(Z.ConstValue.ItemFilterConfirm, self.onSelectFilter, self)
  Z.ContainerMgr.CharSerialize.monsterHuntInfo.Watcher:UnregWatcher(self.monsterExpChange_)
  self.monsterExpChange_ = nil
  if self.itemFilter_ then
    self.itemFilter_:DeActive()
  end
  for index, value in ipairs(self.monsterTargets_) do
    value:UnInit()
  end
  self.monsterTargets_ = {}
  self.monsterTargetsUnits_ = {}
  Z.EventMgr:Remove(Z.ConstValue.GoalGuideMonsterSuccess, self.goalGuideMonsterSuccess, self)
end

function Explore_monster_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("explore_monster_window")
end

function Explore_monster_windowView:OnRefresh()
end

function Explore_monster_windowView:initLeftToggle()
  self.currentSelectMonsterType_ = self.viewData.pageType or 1
  local maxCount = 4
  local togGroup_ = self.uiBinder.node_tab
  for i = 1, maxCount do
    local tog_ = self.uiBinder["binder_tab_" .. i]
    local functionId = typeFuntionId[i]
    if functionId then
      local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
      local togOpen = gotoFuncVM.CheckFuncCanUse(functionId, true)
      tog_.Ref.UIComp:SetVisible(togOpen)
    end
    local component_ = tog_.tog_tab_select
    component_.group = togGroup_
    component_:AddListener(function(isOn)
      if isOn then
        self.commonVM_.CommonPlayTogAnim(tog_.anim_tog, self.cancelSource:CreateToken())
        self:onClickLeftToogle(i)
      end
    end)
    local monsterType = i
    self.toggleList_[#self.toggleList_ + 1] = component_
    local childRedId = self.vm_.GetTabRedDotId(monsterType)
    Z.RedPointMgr.LoadRedDotItem(childRedId, self, tog_.Trans)
  end
  local selectToggle_ = self.toggleList_[self.currentSelectMonsterType_]
  if selectToggle_.isOn == true then
    self:onClickLeftToogle(self.currentSelectMonsterType_)
  else
    selectToggle_.isOn = true
  end
end

function Explore_monster_windowView:onClickLeftToogle(i)
  self.currentSelectMonsterType_ = i
  local currencyId_ = currencyList_[self.currentSelectMonsterType_] or {}
  self.currencyItemList_:Init(self.uiBinder.currency_info, currencyId_)
  local monsterTypeStr = typeNameList_[self.currentSelectMonsterType_]
  self.uiBinder.lab_top_title.text = topTitleStr_ .. "/" .. monsterTypeStr
  self:UnSelectMonsterListItem()
  self:updateMonsterList()
end

function Explore_monster_windowView:openItemFilter()
  local filterTypeParam = {}
  filterTypeParam[E.ItemFilterType.MonsterHunt] = self.rareTypes_
  local viewData = {
    parentView = self,
    filterType = E.ItemFilterType.MonsterHunt,
    filterTypeParam = filterTypeParam,
    selectList = self.filterTags_
  }
  local parent = self.uiBinder.node_sift
  self.itemFilter_:Active(viewData, parent)
end

function Explore_monster_windowView:onSelectFilter(filterTags)
  self.filterTags_ = filterTags
  self:updateMonsterList()
end

function Explore_monster_windowView:updateMonsterList()
  self.monsters_ = self.vm_.GetExploreMonsterListByFilter(self.filterTags_[E.ItemFilterType.MonsterHunt], self.currentSelectMonsterType_, self.filterName_)
  self:showMonsterList()
end

function Explore_monster_windowView:showTitle()
end

function Explore_monster_windowView:showMonsterList()
  self.monsterUnits_ = {}
  self:updateMonsterItemStatus()
end

function Explore_monster_windowView:updateMonsterItemStatus()
  local itemCount_ = #self.monsters_
  local hasMonster_ = 0 < itemCount_
  self.monsterScrollRect_:ClearAllSelect()
  self.monsterScrollRect_:RefreshListView(self.monsters_)
  if hasMonster_ then
    local index = 1
    local selectMonsterId
    if self.viewData.monsterId then
      selectMonsterId = self.viewData.monsterId
    elseif self.curSelectMonsterData_ then
      selectMonsterId = self.curSelectMonsterData_.ExploreData.MonsterId
    end
    if selectMonsterId then
      for k, v in ipairs(self.monsters_) do
        if v.ExploreData.MonsterId == selectMonsterId then
          index = k
          break
        end
      end
    end
    self.monsterScrollRect_:SetSelected(index)
    self.monsterScrollRect_:MovePanelToItemIndex(index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_left, 0 < itemCount_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.com_empty_new, itemCount_ == 0)
end

function Explore_monster_windowView:updateMonsterItemMark()
  self.monsterScrollRect_:RefreshAllShownItem()
end

function Explore_monster_windowView:showTarget()
  local cfg = self.curSelectMonsterData_.ExploreData
  local monsterId_ = cfg.MonsterId
  local data = self.vm_.GetExploreMonsterTargetInfoList(monsterId_)
  local isUnlock_ = self.vm_.GetExploreMonsterTargetFinishNumById(monsterId_) > 0
  self:updateTarget(isUnlock_, cfg, data)
end

function Explore_monster_windowView:updateTarget(isUnlock, cfg, data)
  local gray = false
  local targets = {}
  local targetCfgs = Z.TableMgr.GetTable("MonsterHuntTargetTableMgr")
  for i = 1, #cfg.Target do
    local targetcfg = targetCfgs.GetRow(cfg.Target[i][2])
    if targetcfg then
      targets[cfg.Target[i][1]] = {
        index = i,
        cfg = targetcfg,
        unlock = nil,
        unlockIndex = cfg.Target[i][3],
        targetCountData = data,
        awardId = cfg.Target[i][4]
      }
    end
  end
  for _, target in ipairs(targets) do
    target.unlock = targets[target.unlockIndex]
  end
  for i = #targets, 1, -1 do
    if targets[i].cfg == nil then
      table.remove(targets, i)
    end
  end
  if data then
    table.sort(targets, function(a, b)
      local aTargetNum_, bTargetNum_ = 0, 0
      local aTargetData = data[a]
      if aTargetData then
        aTargetNum_ = aTargetData.value.targetNum
      end
      local bTargetData_ = data[b]
      if bTargetData_ then
        bTargetNum_ = bTargetData_.value.targetNum
      end
      if bTargetNum_ >= b.cfg.Num and aTargetNum_ < a.cfg.Num then
        return true
      end
      return false
    end)
  end
  local num, count = 0, #targets
  local path = self.uiBinder.prefab_cache:GetString("monster_target")
  local root = self.uiBinder.node_target
  for _, token in pairs(self.unitTokenDict_) do
    Z.CancelSource.ReleaseToken(token)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in pairs(targets) do
      local unitName = "monster_target_" .. index
      local token = self.cancelSource:CreateToken()
      self.unitTokenDict_[unitName] = token
      if self.monsterTargetsUnits_[index] == nil then
        self.monsterTargetsUnits_[index] = self:AsyncLoadUiUnit(path, unitName, root, token)
      end
      local unit = self.monsterTargetsUnits_[index]
      if self.monsterTargets_[index] == nil then
        self.monsterTargets_[index] = targetItem_.new(self)
      else
        self.monsterTargets_[index]:Recycle()
      end
      self.monsterTargets_[index]:Init(value, unit)
    end
  end)()
  local finishCount = self.vm_.GetExploreMonsterTargetFinishNumById(cfg.MonsterId)
  self.uiBinder.lab_target_title.text = Lang("MonsterHuntTargetTitle", {val1 = finishCount, val2 = count})
  self:showMonster(gray, isUnlock)
end

function Explore_monster_windowView:showAwardItem()
  local cfg = self.curSelectMonsterData_.ExploreData
  self.uiBinder.group_title02.Ref:SetVisible(self.uiBinder.group_title02.lab_tips, not self.isBoxReward_)
  local awardList_ = {}
  if self.isBoxReward_ and cfg and cfg.TreasureBoxId and cfg.TreasureBoxId ~= 0 then
    local collectionConfig = Z.TableMgr.GetTable("CollectionTableMgr").GetRow(cfg.TreasureBoxId)
    if collectionConfig then
      awardList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(collectionConfig.AwardId)
    end
  elseif cfg and cfg.Award then
    local awardId = cfg.Award
    awardList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
  end
  self.rewardScrollRect_:RefreshListView(awardList_, true)
end

function Explore_monster_windowView:showBtnState()
  local cfg = self.curSelectMonsterData_.ExploreData
  local hasMark_ = self.vm_.CheckMonsterIsMark(cfg.Scene, cfg.MonsterId)
  self.uiBinder.Ref:SetVisible(self.mark_btn_, hasMark_ == false)
  self.uiBinder.Ref:SetVisible(self.cancel_mark_btn_, hasMark_ == true)
end

function Explore_monster_windowView:showMonster(gray, isUnlock)
  local cfg = self.curSelectMonsterData_.ExploreData
  local monsterCfg = self.curSelectMonsterData_.MonsterData
  if monsterCfg then
    self.monster_name_label_.text = monsterCfg.Name
    self.monster_quest_label_.text = cfg.Condition
    self:showModel(monsterCfg.ModelID, gray)
  end
end

function Explore_monster_windowView:showModel(id, gray)
  if self.curShowModel_ then
    Z.UnrealSceneMgr:ClearModel(self.curShowModel_)
    self.curShowModel_ = nil
  end
  self.curShowModel_ = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_, id, function(model)
    local posOffset = ShowPosOffset
    if self.curSelectMonsterData_.ExploreData.ModelArray and #self.curSelectMonsterData_.ExploreData.ModelArray > 0 then
      local posOffsetAdd = Vector3.New(self.curSelectMonsterData_.ExploreData.ModelArray[1], self.curSelectMonsterData_.ExploreData.ModelArray[2], self.curSelectMonsterData_.ExploreData.ModelArray[3])
      posOffset = posOffset + posOffsetAdd
    end
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos") + posOffset)
    model:SetAttrGoRotation(rotation_)
    if self.curSelectMonsterData_.ExploreData.DefaulAction and 0 < string.len(self.curSelectMonsterData_.ExploreData.DefaulAction) then
      model:SetLuaAttrModelPreloadClip(self.curSelectMonsterData_.ExploreData.DefaulAction)
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(self.curSelectMonsterData_.ExploreData.DefaulAction))
    else
      model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
    end
    if gray then
      local darkShadow = Vector4.New(0, 0, 0, 1)
      local rimColor = Vector4.New(0.1652, 0.451, 0.7452, 1)
      model:SetLuaAttr(Z.ModelAttr.EModelDarkShadow, Panda.ZGame.ModelDarkShadowData.New(darkShadow, rimColor, false))
    else
      local darkShadow = Vector4.New(0, 0, 0, 0)
      local rimColor = Vector4.New(1, 1, 1, 1)
      model:SetLuaAttr(Z.ModelAttr.EModelDarkShadow, Panda.ZGame.ModelDarkShadowData.New(darkShadow, rimColor, true))
    end
  end, nil, nil)
  local cfg = self.curSelectMonsterData_.ExploreData
  if self.curShowModel_ and cfg and cfg.ModelRetio then
    self.curShowModel_:SetLuaAttrGoScale(cfg.ModelRetio)
  end
end

function Explore_monster_windowView:OnReceiveTargetAward()
  self.monsterScrollRect_:RefreshAllShownItem()
  self:ChangeMonster(self.curSelectMonsterData_)
end

function Explore_monster_windowView:UnSelectMonsterListItem()
  self.monsterScrollRect_:ClearAllSelect()
end

function Explore_monster_windowView:ChangeMonster(data)
  self.curSelectMonsterData_ = data
  if self.curSelectMonsterData_.ExploreData.TreasureBoxId and self.curSelectMonsterData_.ExploreData.TreasureBoxId ~= 0 then
    self.isBoxReward_ = true
    self.uiBinder.group_title02.togs_tab.tog_loot:SetIsOnWithoutCallBack(true)
    self.uiBinder.group_title02.togs_tab.tog_drop:SetIsOnWithoutCallBack(false)
    self.uiBinder.group_title02.Ref:SetVisible(self.uiBinder.group_title02.lab_title, false)
    self.uiBinder.group_title02.togs_tab.Ref.UIComp:SetVisible(true)
  else
    self.isBoxReward_ = false
    self.uiBinder.group_title02.Ref:SetVisible(self.uiBinder.group_title02.lab_title, true)
    self.uiBinder.group_title02.togs_tab.Ref.UIComp:SetVisible(false)
  end
  local level_ = self.vm_.GetMonsterLevel(data.MonsterData)
  self.uiBinder.lab_level.text = Lang("LvFormatSymbol", {val = level_})
  local titleIndex_ = data.ExploreData.Type == 3 and 1 or 2
  self:startClickAnimatedHide()
  self:showTarget()
  self:showAwardItem()
  self:showBtnState()
end

function Explore_monster_windowView:startAnimatedShow()
end

function Explore_monster_windowView:startAnimatedHide()
end

function Explore_monster_windowView:startClickAnimatedHide()
end

function Explore_monster_windowView:onUnrealsceneBeginDrag(eventData)
  self.curShowModelRotation_ = self.curShowModel_:GetAttrGoRotation().eulerAngles
end

function Explore_monster_windowView:onUnrealsceneDrag(eventData)
  self.curShowModelRotation_.y = self.curShowModelRotation_.y - eventData.delta.x
  self.curShowModel_:SetAttrGoRotation(Quaternion.Euler(self.curShowModelRotation_))
end

function Explore_monster_windowView:onUnrealsceneEndDrag(eventData)
end

function Explore_monster_windowView:onClickSearchBtn()
  self.filterName_ = self.uiBinder.input_search.text
  self:updateMonsterList()
end

function Explore_monster_windowView:onEndEditChange(text)
  self.filterName_ = text
  self:updateMonsterList()
end

function Explore_monster_windowView:onClickDeleteBtn()
  self.uiBinder.input_search.text = stringEmpty_
  self.filterName_ = stringEmpty_
  self:updateMonsterList()
end

function Explore_monster_windowView:RereshLevelInfo()
  local level_ = self.vm_.GetMonsterHuntLevel()
  local maxLevel_ = self.vm_.GetMonsterHuntMaxLevel()
  local exp_ = self.vm_.GetMonsterHuntLevelExp()
  local maxExp_ = 0
  if level_ >= maxLevel_ then
    maxExp_ = self.vm_.GetMonsterHuntLevelMaxExp(maxLevel_)
  else
    maxExp_ = self.vm_.GetMonsterHuntLevelMaxExp(level_ + 1)
  end
  local fillAmount_ = exp_ / maxExp_
  fillAmount_ = math.min(1, fillAmount_)
  self.uiBinder.img_progress.fillAmount = fillAmount_
  local showExpStr_ = string.format(expStr_, exp_, maxExp_)
  self.uiBinder.lab_schedule.text = showExpStr_
  self.uiBinder.lab_level_num.text = level_
  if self.lastLevel_ and level_ > self.lastLevel_ then
    self.vm_:OpenExploreMonsterLevelUpWindow()
  end
  self.lastLevel_ = level_
end

function Explore_monster_windowView:goalGuideMonsterSuccess(monsterID, scendID)
  local cfg = self.curSelectMonsterData_.ExploreData
  if cfg.MonsterId == monsterID and cfg.Scene == scendID then
    self.vm_.TrackMonster(cfg.MonsterId, cfg.Scene)
    self:showBtnState()
  end
end

return Explore_monster_windowView
