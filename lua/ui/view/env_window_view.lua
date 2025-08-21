local UI = Z.UI
local super = require("ui.ui_subview_base")
local Env_windowView = class("Env_windowView", super)
local envSkillItem = require("ui.component.environment_resonance.env_skill_item")
local SkillState = E.EnvResonanceSkillState
local DEFAULT_SCENE_RIMG = "ui/textures/env_textures/env_scene_"
local MAX_SCENE_COUNT = 2
local COLOR_TYPE = {
  NORMAL = Color.New(1, 1, 1, 1),
  EXPRIED = Color.New(0.9686274509803922, 0.7411764705882353, 0.7019607843137254, 1)
}
local STATE_INFO = {
  [SkillState.Lock] = {
    Lab = Lang("EnvSkillStateLock"),
    Color = COLOR_TYPE.NORMAL
  },
  [SkillState.NotActive] = {
    Lab = Lang("EnvSkillStateNotActive"),
    Color = COLOR_TYPE.NORMAL
  },
  [SkillState.Active] = {
    Lab = Lang("EnvSkillStateActive"),
    Color = COLOR_TYPE.NORMAL
  },
  [SkillState.Equip] = {
    Lab = Lang("EnvSkillStateEquiped"),
    Color = COLOR_TYPE.NORMAL
  },
  [SkillState.Expired] = {
    Lab = Lang("EnvSkillStateExpired"),
    Color = COLOR_TYPE.EXPRIED
  }
}

function Env_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "env_window", "environment/env_window", UI.ECacheLv.None, true)
  self.envTipsView_ = require("ui.view.tips_env_info_view").new(self)
  self.parent_ = parent
end

function Env_windowView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:startAnimatedShow()
  self.envVm_ = Z.VMMgr.GetVM("env")
  self.pivotVm_ = Z.VMMgr.GetVM("pivot")
  self.envTbl_ = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr")
  self.skillVm_ = Z.VMMgr.GetVM("skill")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.pivotTableMgr_ = Z.TableMgr.GetTable("PivotTableMgr")
  self.skillTableMgr_ = Z.TableMgr.GetTable("SkillTableMgr")
  self.sceneTableMgr_ = Z.TableMgr.GetTable("SceneTableMgr")
  self.cont_leftUIBinder = self.uiBinder.node_info.cont_left
  self.cont_rightUIBinder = self.uiBinder.node_info.cont_right
  self:AddAsyncClick(self.cont_rightUIBinder.btn_track, function()
    self:onClickTrack()
  end)
  self.cont_skill_left = self.cont_leftUIBinder.cont_skill_grade_tpl_1
  self.cont_skill_right = self.cont_leftUIBinder.cont_skill_grade_tpl_2
  self.copyItem_ = self.cont_leftUIBinder.cont_skill_grade_tpl
  self.cont_leftUIBinder.Ref:SetVisible(self.copyItem_.Ref, false)
  self.skillDistance_ = Z.Global.EnvironmentSkillDistance
  for i = 1, MAX_SCENE_COUNT do
    local cont_scene_item = self.cont_leftUIBinder["cont_item_scene_" .. i]
    if cont_scene_item then
      for j = 1, 2 do
        local skillItem = cont_scene_item["cont_skill_grade_tpl_" .. j]
        if skillItem then
          local func = function()
            self:onBeginDrag(i, j)
          end
          local endFunc = function()
            self:onEndDrag()
          end
          self:initDraw(skillItem, func, endFunc)
        end
      end
    end
    local cont_skill_item = self.cont_leftUIBinder["cont_skill_grade_tpl_" .. i]
    if cont_skill_item then
      local func = function()
        self:onSkillBeginDrag(i)
      end
      local endFunc = function()
        self:onSkillEndDrag()
      end
      self:initDraw(cont_skill_item, func, endFunc)
    end
  end
  self.envSkillItemList_ = {}
  self.envEquipSKillItemDic_ = {}
  self.copySkillItem_ = nil
  self.SelectScenePos_ = 0
  self.SelectResonanceId_ = 0
  self.IsEquipSkillItem_ = false
  self:initEnvSkillItem()
  self:initEquipSkillItem()
  self:initEnvSceneItem()
  self:refreshEnvSceneItem()
  self:BindEvents()
end

function Env_windowView:onBeginDrag(sceneIdx, index)
  self.isDraw_ = false
  local envSkillItemList = self.envSkillItemList_[sceneIdx]
  if envSkillItemList then
    local config = self.envTbl_.GetRow(envSkillItemList.lstResonances[index])
    if config then
      local state = self.envVm_.GetSkillState(config.Id)
      if state == E.EnvResonanceSkillState.Lock or state == E.EnvResonanceSkillState.NotActive then
        return
      end
      if state == E.EnvResonanceSkillState.Expired then
        Z.TipsVM.ShowTipsLang(1381003)
        return
      end
      local env_skill_item = envSkillItem.new()
      env_skill_item:InitItem(self.copyItem_, config, self.skillTableMgr_.GetRow(envSkillItemList.lstSkillIds[index]), self, nil, self.SelectScenePos_)
      env_skill_item:RefreshItem()
      self:clearDragItem()
      self.copySkillItem_ = env_skill_item
      self.isDraw_ = true
      self:RefreshSelectSkill(config.Id, false)
      local resonanceLeftId = self.envVm_.GetEquipResonance(1)
      local resonanceRightId = self.envVm_.GetEquipResonance(2)
      if 0 < resonanceLeftId and resonanceLeftId ~= config.Id then
        self.envEquipSKillItemDic_[1]:setBtnChange(true)
      end
      if 0 < resonanceRightId and resonanceRightId ~= config.Id then
        self.envEquipSKillItemDic_[2]:setBtnChange(true)
      end
    end
  end
end

function Env_windowView:onEndDrag()
  self:clearDragItem()
  local leftDis = self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_left.Trans)
  local rightDis = self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_right.Trans)
  if leftDis <= rightDis then
    if leftDis <= self.skillDistance_ then
      self.envEquipSKillItemDic_[1]:AsyncChangeResonanceSkill()
    end
  elseif rightDis <= self.skillDistance_ then
    self.envEquipSKillItemDic_[2]:AsyncChangeResonanceSkill()
  end
end

function Env_windowView:onSkillBeginDrag(index)
  self.isDraw_ = false
  local resonanceId = self.envVm_.GetEquipResonance(index)
  if resonanceId then
    local config = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(resonanceId)
    if config then
      local state = self.envVm_.GetSkillState(config.Id)
      if state == E.EnvResonanceSkillState.Expired then
        Z.TipsVM.ShowTipsLang(1381003)
        return
      end
      local skillId = self.envVm_.GetSkillIdByResonance(resonanceId)
      if 0 < skillId then
        local configSkill = self.skillTableMgr_.GetRow(skillId)
        if configSkill then
          local env_skill_item = envSkillItem.new()
          env_skill_item:InitItem(self.copyItem_, config, configSkill, self, nil, self.SelectScenePos_)
          env_skill_item:RefreshItem()
          self:clearDragItem()
          self.copySkillItem_ = env_skill_item
          self.isDraw_ = true
          self.curSelectSkillIdx_ = index
          self.envEquipSKillItemDic_[1]:setBtnChange(index == 2)
          self.envEquipSKillItemDic_[2]:setBtnChange(index == 1)
        end
      end
    end
  end
end

function Env_windowView:onSkillEndDrag()
  self:clearDragItem()
  local resonanceLeftId = self.envVm_.GetEquipResonance(1)
  local resonanceRightId = self.envVm_.GetEquipResonance(2)
  if self.curSelectSkillIdx_ == 1 then
    if self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_right.Trans) <= self.skillDistance_ then
      if 0 < resonanceRightId then
        self.envVm_.AsyncChangeResonanceSkill(1, resonanceRightId, self.cancelSource:CreateToken())
        self.envEquipSKillItemDic_[2]:setBtnChangeEff(true)
      else
        self.envVm_.AsyncChangeResonanceSkill(2, resonanceLeftId, self.cancelSource:CreateToken())
      end
    elseif self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_left.Trans) > self.skillDistance_ then
      self.envVm_.AsyncChangeResonanceSkill(1, 0, self.cancelSource:CreateToken())
    end
  elseif self.curSelectSkillIdx_ == 2 then
    if self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_left.Trans) <= self.skillDistance_ then
      if 0 < resonanceLeftId then
        self.envVm_.AsyncChangeResonanceSkill(2, resonanceLeftId, self.cancelSource:CreateToken())
        self.envEquipSKillItemDic_[1]:setBtnChangeEff(true)
      else
        self.envVm_.AsyncChangeResonanceSkill(1, resonanceRightId, self.cancelSource:CreateToken())
      end
    elseif self.envVm_.GetScreenDistance(self.copyItem_.Trans, self.cont_skill_right.Trans) > self.skillDistance_ then
      self.envVm_.AsyncChangeResonanceSkill(2, 0, self.cancelSource:CreateToken())
    end
  end
end

function Env_windowView:initDraw(skillItem, initDataFunc, endDragFunc)
  skillItem.trigger_icon.onBeginDrag:AddListener(function(go, pointerData)
    if initDataFunc then
      Z.CoroUtil.create_coro_xpcall(function()
        initDataFunc()
      end)()
    end
    if not self.isDraw_ then
      return
    end
    self.copyItem_.Trans:SetParent(skillItem.Trans)
    self.copyItem_.Trans.localScale = Vector3.one
    self.copyItem_.Trans.localPosition = Vector3.zero
    self.copyItem_.Trans.localRotation = Quaternion.identity
    self.copyItem_.Trans:SetParent(self.cont_leftUIBinder.Trans)
    self.cont_leftUIBinder.Ref:SetVisible(self.copyItem_.Ref, true)
    local resonanceLeftId = self.envVm_.GetEquipResonance(1)
    local resonanceRightId = self.envVm_.GetEquipResonance(2)
    self.envEquipSKillItemDic_[1]:setImageActivate(resonanceLeftId == 0)
    self.envEquipSKillItemDic_[2]:setImageActivate(resonanceRightId == 0)
  end)
  skillItem.trigger_icon.onDrag:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    local trans_ = self.copyItem_.Trans
    local ison, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(trans_, pointerData.position, nil)
    local posX, posY = trans_:GetAnchorPosition(nil, nil)
    posX = posX + uiPos.x
    posY = posY + uiPos.y
    trans_:SetAnchorPosition(posX, posY)
  end)
  skillItem.trigger_icon.onEndDrag:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    self.cont_leftUIBinder.Ref:SetVisible(self.copyItem_.Ref, false)
    self.isDraw_ = false
    self.envEquipSKillItemDic_[1]:setImageActivate(false)
    self.envEquipSKillItemDic_[2]:setImageActivate(false)
    self.envEquipSKillItemDic_[1]:setBtnChange(false)
    self.envEquipSKillItemDic_[2]:setBtnChange(false)
    if endDragFunc then
      Z.CoroUtil.create_coro_xpcall(function()
        endDragFunc()
      end)()
    end
  end)
end

function Env_windowView:OnDeActive()
  Z.ContainerMgr.CharSerialize.resonance.Watcher:UnregWatcher(self.onContainerChanged)
  self:closeSkillTips()
  self:clearSkillItem()
end

function Env_windowView:BindEvents()
  function self.onContainerChanged(container, dirty)
    if dirty.installed then
      self:refreshAllItem()
      
      Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSkill)
    end
  end
  
  Z.ContainerMgr.CharSerialize.resonance.Watcher:RegWatcher(self.onContainerChanged)
end

function Env_windowView:initEnvSkillItem()
  local envItemsDataDic = {}
  local envDataDic = self.envTbl_.GetDatas()
  for _, value in pairs(envDataDic) do
    local pivotTbl = self.pivotTableMgr_.GetRow(value.PivotId)
    if pivotTbl then
      if envItemsDataDic[pivotTbl.MapID] == nil then
        envItemsDataDic[pivotTbl.MapID] = {}
      end
      if #value.skill > 0 then
        table.insert(envItemsDataDic[pivotTbl.MapID], {
          config = value,
          skillId = value.skill[1]
        })
      end
    end
  end
  local scenePicDic = {}
  for key, value in pairs(Z.Global.EnvironmentResonanceScenePic) do
    scenePicDic[key] = value
  end
  local count = 0
  for sceneId, lstSKills in pairs(envItemsDataDic) do
    count = count + 1
    local cont_scene_item = self.cont_leftUIBinder["cont_item_scene_" .. count]
    if cont_scene_item then
      local lstSkillItems = {}
      local lstResonances = {}
      local lstSkillIds = {}
      for index, value in ipairs(lstSKills) do
        local cont_skill_item = cont_scene_item["cont_skill_grade_tpl_" .. index]
        if cont_skill_item then
          local skillItem = envSkillItem.new()
          skillItem:InitItem(cont_skill_item, value.config, self.skillTableMgr_.GetRow(value.skillId), self, nil, count)
          table.insert(lstSkillItems, skillItem)
          table.insert(lstResonances, value.config.Id)
          table.insert(lstSkillIds, value.skillId)
        end
      end
      local sceneTableRow = self.sceneTableMgr_.GetRow(sceneId)
      if sceneTableRow then
        local data = {
          sceneId = sceneId,
          sceneConfig = sceneTableRow,
          sceneImgPath = scenePicDic[sceneId],
          lstSkillItems = lstSkillItems,
          lstResonances = lstResonances,
          lstSkillIds = lstSkillIds
        }
        table.insert(self.envSkillItemList_, data)
      end
    end
  end
  self:switchSelectScene(1, true)
end

function Env_windowView:initEnvSceneItem()
  for i = 1, MAX_SCENE_COUNT do
    local cont_scene_item = self.cont_leftUIBinder["cont_item_scene_" .. i]
    if cont_scene_item then
      local sceneSkillData = self.envSkillItemList_[i]
      if sceneSkillData then
        cont_scene_item.rimg_scene:ClearGray()
        cont_scene_item.lab_scene_name.text = sceneSkillData.sceneConfig.Name
      else
        cont_scene_item.rimg_scene:SetGray()
        cont_scene_item.lab_scene_name.text = Lang("EnvSceneLock")
      end
      cont_scene_item.rimg_scene:SetImage(DEFAULT_SCENE_RIMG .. i)
      self:AddAsyncClick(cont_scene_item.btn_scene, function()
        if sceneSkillData == nil then
          Z.TipsVM.ShowTipsLang(1381006)
        end
        do return end
        self:switchSelectScene(i)
      end)
    end
  end
end

function Env_windowView:initEquipSkillItem()
  for i = 1, 2 do
    local cont_skill_item = self.cont_leftUIBinder["cont_skill_grade_tpl_" .. i]
    if cont_skill_item then
      local skillItem = envSkillItem.new()
      skillItem:InitItem(cont_skill_item, nil, nil, self, i, nil)
      self.envEquipSKillItemDic_[i] = skillItem
    end
    self:refreshEnvEquipSkillItems(i)
  end
end

function Env_windowView:clearSkillItem()
  for k, itemData in pairs(self.envSkillItemList_) do
    for _, skillItem in ipairs(itemData.lstSkillItems) do
      skillItem:DestroyItem()
    end
  end
  self.envSkillItemList_ = {}
  for k, skillItem in pairs(self.envEquipSKillItemDic_) do
    skillItem:DestroyItem()
  end
  self.envEquipSKillItemDic_ = {}
  self:clearDragItem()
end

function Env_windowView:clearDragItem()
  if self.copySkillItem_ then
    self.copySkillItem_:DestroyItem()
    self.copySkillItem_ = nil
  end
end

function Env_windowView:refreshEnvSkillItems(scenePos)
  scenePos = scenePos or self.SelectScenePos_
  local itemData = self.envSkillItemList_[scenePos]
  if itemData == nil then
    return
  end
  for i, skillItem in ipairs(itemData.lstSkillItems) do
    skillItem:RefreshItem()
  end
end

function Env_windowView:refreshAllItem()
  self:refreshEnvSceneItem()
  self:refreshEnvEquipSkillItems(1)
  self:refreshEnvEquipSkillItems(2)
  self:refreshSkillTips()
end

function Env_windowView:refreshEnvSceneItem()
  for i = 1, MAX_SCENE_COUNT do
    local cont_scene_item = self.cont_leftUIBinder["cont_item_scene_" .. i]
    if cont_scene_item then
      local scale = self.SelectScenePos_ == i and 1 or 0.5
      cont_scene_item.Trans:SetScale(scale, scale, 1)
    end
  end
  self:refreshEnvSkillItems()
end

function Env_windowView:refreshEnvEquipSkillItems(slotPos)
  local skillItem = self.envEquipSKillItemDic_[slotPos]
  if skillItem == nil then
    return
  end
  skillItem:RefreshEquipItem()
end

function Env_windowView:switchSelectScene(scenePos, isInit)
  if self.SelectScenePos_ == scenePos then
    return
  end
  self.SelectScenePos_ = scenePos
  self:refreshEnvSceneItem()
  if isInit then
    local itemData = self.envSkillItemList_[scenePos]
    self:RefreshSelectSkill(itemData.lstResonances[1])
  else
    self:RefreshSelectSkill(0)
  end
end

function Env_windowView:RefreshSelectSkill(resonanceId, isSkillItem)
  isSkillItem = isSkillItem or false
  if self.SelectResonanceId_ == resonanceId and self.IsEquipSkillItem_ == isSkillItem then
    return
  end
  self.SelectResonanceId_ = resonanceId
  self.IsEquipSkillItem_ = isSkillItem
  self:refreshSkillTips(resonanceId)
  self:playSelectAnim()
  Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSelectFinish)
end

function Env_windowView:RefreshSelectEquipSkill(slot)
  self.SelectResonanceId_ = 0
  self:refreshEnvEquipSkillItems(slot)
  local resonanceId = self.envVm_.GetEquipResonance(slot)
  self:refreshSkillTips(resonanceId)
  Z.EventMgr:Dispatch(Z.ConstValue.OnResonanceSelectFinish)
end

function Env_windowView:refreshSkillTips()
  self:closeSkillTips()
  if self.SelectResonanceId_ == 0 then
    return
  end
  local funcName = self.commonVm_.GetTitleByConfig(E.FunctionID.EnvResonance)
  local sceneConfig = self.envSkillItemList_[self.SelectScenePos_].sceneConfig
  local state = self.envVm_.GetSkillState(self.SelectResonanceId_)
  local stateInfo = STATE_INFO[state]
  local tipsViewData = {
    state = state,
    title = Lang("unknownSkill"),
    funcName = funcName,
    areaName = sceneConfig.Name,
    stateDesc = stateInfo.Lab,
    stateColor = stateInfo.Color,
    effectTime = "",
    currentDesc = "",
    nextDesc = "",
    skillDesc = "",
    itemName = ""
  }
  if state ~= SkillState.Lock then
    local envConfig = self.envTbl_.GetRow(self.SelectResonanceId_)
    local skillId = self.envVm_.GetSkillIdByResonance(self.SelectResonanceId_)
    local skillConfig = self.skillTableMgr_.GetRow(skillId)
    local skillInfo = self.skillVm_.GetPlayerCommonSkillInfo()
    local skillFightData = self.skillVm_.GetSkillFightDataListById(skillId)
    local skillLv = skillInfo[skillId] and skillInfo[skillId].skillLv or 1
    local skillFightLevelId = skillFightData[skillLv].Id
    local skillDesc = self.skillVm_.GetEffectDescNotParse(skillFightLevelId)
    local nextSkillData = self.skillVm_.GetNextSkillFightData(skillFightLevelId)
    local isMax = self.skillVm_.CheckSkillMaxByFightId(skillFightLevelId)
    local curSkillEffectDesc = ""
    local nextSkillEffectDesc = ""
    if isMax or nextSkillData == nil then
      curSkillEffectDesc = string.zconcat(Lang("EnvSkillEffectMax"), "<br>", skillDesc)
    else
      local nextSkillDesc = self.skillVm_.GetEffectDescNotParse(nextSkillData.Id)
      curSkillEffectDesc = string.zconcat("<br>", Lang("EnvSkillEffect"), "<br>", skillDesc, "<br>")
      nextSkillEffectDesc = string.zconcat("<br>", Lang("EnvSkillEffectNext"), "<br>", nextSkillDesc)
    end
    local durationTimeDesc = 0 < envConfig.Time and Lang("resonanceDurationTime") .. Z.TimeFormatTools.FormatToDHMS(envConfig.Time) or ""
    local remainTime = self.envVm_.GetResonanceRemainTime(self.SelectResonanceId_)
    tipsViewData.iconPath = skillConfig.Icon
    tipsViewData.title = skillConfig.Name
    tipsViewData.effectTime = durationTimeDesc
    tipsViewData.currentDesc = curSkillEffectDesc
    tipsViewData.nextDesc = nextSkillEffectDesc
    tipsViewData.itemName = envConfig.Name
    tipsViewData.skillDesc = Z.TableMgr.DecodeLineBreak(skillConfig.Desc)
    if state ~= SkillState.NotActive and state ~= SkillState.Expired and 0 < remainTime then
      tipsViewData.showTime = remainTime
    end
  end
  self.cont_rightUIBinder.lab_title.text = tipsViewData.title
  self.envTipsView_:Active(tipsViewData, self.cont_rightUIBinder.cont_info.Trans)
  self.cont_rightUIBinder.Ref:SetVisible(self.cont_rightUIBinder.btn_track, state == SkillState.Lock or state == SkillState.NotActive or state == SkillState.Expired)
end

function Env_windowView:closeSkillTips()
  self.envTipsView_:DeActive()
  self.cont_rightUIBinder.Ref:SetVisible(self.cont_rightUIBinder.btn_track, false)
end

function Env_windowView:onClickTrack()
  if self.SelectResonanceId_ == 0 then
    return
  end
  local envConfig = self.envTbl_.GetRow(self.SelectResonanceId_)
  if envConfig == nil then
    return
  end
  local pivotConfig = self.pivotTableMgr_.GetRow(envConfig.PivotId)
  if pivotConfig == nil then
    return
  end
  local sceneId = pivotConfig.MapID
  local traceId = envConfig.PivotId
  traceId = self.SelectResonanceId_
  local curUid = 0
  curUid = envConfig.position
  local mapVm = Z.VMMgr.GetVM("map")
  mapVm.SetTraceEntity(E.GoalGuideSource.Env, sceneId, curUid, Z.GoalPosType.SceneObject, true)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId)
end

function Env_windowView:playSelectAnim()
  self.uiBinder.anim_env:Rewind(Z.DOTweenAnimType.Tween_0)
  self.uiBinder.anim_env:Restart(Z.DOTweenAnimType.Tween_0)
end

function Env_windowView:startAnimatedShow()
  self.uiBinder.anim_env_uiAnim:PlayOnce("ui_anim_env_window_ui_sfx_lizi_fade_in")
  self.uiBinder.anim_env:Rewind(Z.DOTweenAnimType.Open)
  self.uiBinder.anim_env:Restart(Z.DOTweenAnimType.Open)
end

function Env_windowView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim_env.CoroPlay)
  coro(self.uiBinder.anim_env, Z.DOTweenAnimType.Close)
end

function Env_windowView:CustomClose()
end

return Env_windowView
