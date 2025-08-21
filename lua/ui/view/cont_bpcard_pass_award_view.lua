local UI = Z.UI
local super = require("ui.ui_subview_base")
local Cont_bpcard_pass_awardView = class("Cont_bpcard_pass_awardView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local battle_pass_loop_item_ = require("ui/component/battle_pass/battle_pass_content_loop_item")
local itemClass = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local timelineQueue = {
  [Z.PbEnum("EGender", "GenderFemale")] = 50000032,
  [Z.PbEnum("EGender", "GenderMale")] = 50000033
}

function Cont_bpcard_pass_awardView:ctor(parent)
  self.parentView_ = parent
  self.uiBinder = nil
  super.ctor(self, "cont_bpcard_pass_award", "bpcard/cont_bpcard_pass_award", UI.ECacheLv.High, true)
  self.battlePassCardData_ = nil
end

function Cont_bpcard_pass_awardView:OnActive()
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff_diancang)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff_zhizheng)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_pass_eff)
  self:initBinders()
  self:initParam()
  self:initBtnClick()
  self:bindWatchers()
  self:createPlayerModel()
  self:startAnimShow()
  Z.AudioMgr:Play("UI_Event_SeasonPassport")
  self:refreshBpCardTime()
end

function Cont_bpcard_pass_awardView:refreshBpCardTime()
  if next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassData_.CurBattlePassData.id)
  if not bpCardGlobalInfo or not bpCardGlobalInfo.Timer then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplus_time, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplus_time, true)
  local time = Z.TimeTools.GetLeftTimeByTimerId(bpCardGlobalInfo.Timer)
  if time <= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplus_time, false)
  end
  self.uiBinder.lab_surplus_time.text = Lang("BpCardLimitTime") .. Z.TimeFormatTools.FormatToDHMS(time)
  if self.timer == nil then
    self.timer = self.timerMgr:StartTimer(function()
      time = time - 1
      if time <= 0 then
        time = Z.TimeTools.GetLeftTimeByTimerId(bpCardGlobalInfo.Timer)
      end
      if time <= 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_surplus_time, false)
        self.timerMgr:StopTimer(self.timer)
        self.timer = nil
        return
      end
      self.uiBinder.lab_surplus_time.text = Lang("BpCardLimitTime") .. Z.TimeFormatTools.FormatToDHMS(time)
    end, 1, -1)
  end
end

function Cont_bpcard_pass_awardView:OnDeActive()
  self:clearPosCheckTimer()
  Z.UITimelineDisplay:ClearTimeLine()
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff_diancang)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff_diancang)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_pass_eff)
  if self.fashionZlist_ then
    self.fashionZlist_:Recycle()
    self.fashionZlist_ = nil
  end
  if self.playerModel_ then
    Z.ModelHelper.SetAlpha(self.playerModel_, Z.ModelRenderMask.All, 1, Panda.ZGame.EModelAlphaSourceType.EUI, false)
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  self:unBindWatchers()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.battlePassCardData_ = nil
  self:removeShowAwardItem()
  self.itemsScrollRect_:UnInit()
  self.itemsScrollRect_ = nil
  self.currentShowIndex_ = -1
  self.currentItemIndex_ = -1
  self.rightAwardShowIndex_ = -1
  self.showAwardData_ = nil
  if self.timer then
    self.timerMgr:StopTimer(self.timer)
    self.timer = nil
  end
end

function Cont_bpcard_pass_awardView:OnRefresh()
  self:setViewInfo(true)
  self:setBattlePassLevelInfo()
  self:setReceiveAllBtnState()
end

function Cont_bpcard_pass_awardView:initBinders()
  self.right_lock = self.uiBinder.right_img_lock
  self.left_lock = self.uiBinder.img_lock
  self.left_level_label = self.uiBinder.lab_grade
  self.top_item_node = self.uiBinder.top_node_item
  self.bottom_item_node = self.uiBinder.bottom_node_item
  self.advanced_btn = self.uiBinder.btn_advanced
  self.loopscroll_item = self.uiBinder.loopscroll
  self.prefabcache_root = self.uiBinder.prefabcache_root
  self.top_btn_buy = self.uiBinder.btn_buy_level
  self.top_progress_lab = self.uiBinder.lab_num
  self.top_lab_grade = self.uiBinder.lab_level
  self.top_week_lab_manage = self.uiBinder.lab_manage
  self.top_slider_temp = self.uiBinder.slider_temp
  self.btn_unlock = self.uiBinder.btn_unlock
  self.btn_get = self.uiBinder.btn_get
  self.get_lab = self.uiBinder.lab_bug_get
  self.name_lab = self.uiBinder.lab_name
  self.model_node = self.uiBinder.node_model_position
  self.unrealSceneDrag_node = self.uiBinder.rayimg_unrealscene_drag
  self.free_bpcard_name_ = self.uiBinder.lab_free_bpcard_name
  self.pro_bpcard_name_ = self.uiBinder.lab_pro_bpcard_name
end

function Cont_bpcard_pass_awardView:initParam()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self.itemClassTab_ = {}
  local dataList = {}
  self.itemsScrollRect_ = loopScrollRect_.new(self, self.loopscroll_item, battle_pass_loop_item_, "bpcard_pass_award_tpl", true)
  self.itemsScrollRect_:Init(dataList)
  self.itemUnit_ = {}
  self.uiBinder.scroll_item.onValueChangedEvent:AddListener(function()
    self:updateLeftShowItem()
  end)
  self.fashionZlist_ = nil
  self.currentShowIndex_ = -1
  self.currentItemIndex_ = -1
  self.rightAwardShowIndex_ = -1
  self.showAwardData_ = self.battlePassVM_.GetBattlePassShowData(self.battlePassData_.CurBattlePassData)
  self.modelPosition_ = self.model_node.position
  local playerGender = Z.ContainerMgr.CharSerialize.charBase.gender
  self.timelineId_ = timelineQueue[playerGender]
  self.curRotation_ = 100
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  local funcIsOn = funcVM.CheckFuncCanUse(E.FunctionID.SeasonBpUnlockUpgrade, true)
  self.uiBinder.Ref:SetVisible(self.btn_unlock, funcIsOn)
  Z.UITimelineDisplay:AsyncPreLoadTimeline(self.timelineId_, self.cancelSource:CreateToken())
end

function Cont_bpcard_pass_awardView:initBtnClick()
  self:AddClick(self.advanced_btn, function()
    self.battlePassVM_.OpenBattlePassBuyView()
  end)
  self:AddAsyncClick(self.btn_unlock, function()
    self.battlePassVM_.OpenBattlePassBuyView()
  end)
  self:AddAsyncClick(self.top_btn_buy, function()
    self.battlePassVM_.OpenBattlePassPurchaseView()
  end)
  self.unrealSceneDrag_node.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
  self:AddAsyncClick(self.btn_get, function()
    if self.curChoosePage_ == E.EBattlePassViewType.Task then
      self.battlePassVM_.AsyncGetBattlePassQuestRequest(0, self.cancelSource:CreateToken())
    else
      if table.zcount(self.battlePassData_.CurBattlePassData) == 0 then
        return
      end
      self.battlePassVM_.AsyncGetBattlePassAwardRequest(self.battlePassData_.CurBattlePassData.id, true, nil, nil, self.cancelSource:CreateToken())
    end
  end)
end

function Cont_bpcard_pass_awardView:bindWatchers()
  Z.EventMgr:Add(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function Cont_bpcard_pass_awardView:onBattlePassDataUpDateFunc(dirtyTable)
  if not dirtyTable or next(dirtyTable) == nil then
    return
  end
  self:setViewInfo(false)
  self:setBattlePassLevelInfo()
  if dirtyTable.id then
    self:setReceiveAllBtnState()
    self:refreshBpCardTime()
  end
end

function Cont_bpcard_pass_awardView:setViewInfo(isShowDisplayOffset)
  if not self.battlePassData_.CurBattlePassData or table.zcount(self.battlePassData_.CurBattlePassData) == 0 then
    return
  end
  local curBattleData = self.battlePassData_.CurBattlePassData
  self.uiBinder.Ref:SetVisible(self.left_lock, not curBattleData.isUnlock)
  self.uiBinder.Ref:SetVisible(self.right_lock, not curBattleData.isUnlock)
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(curBattleData.id)
  self.uiBinder.lab_entrance.text = bpCardGlobalInfo.PassTitleName
  self.uiBinder.rimg_bpcard:SetImage(bpCardGlobalInfo.PassTag)
  local passPicture = string.split(bpCardGlobalInfo.PassPicture, "=")
  self.uiBinder.img_icon_basics:SetImage(passPicture[1])
  self.uiBinder.img_icon_noble:SetImage(passPicture[2])
  self:initLoopScroll(isShowDisplayOffset)
  self:updateLeftShowItem()
end

function Cont_bpcard_pass_awardView:unBindWatchers()
  Z.EventMgr:Remove(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function Cont_bpcard_pass_awardView:initLoopScroll(isShowDisplayOffset)
  self.battlePassCardData_ = self.battlePassVM_.AssemblyData()
  local index = 1
  self.itemsScrollRect_:RefreshListView(self.battlePassCardData_, false)
  if isShowDisplayOffset then
    index = self.battlePassVM_.GetBattlePassShowLocation()
    self.itemsScrollRect_:MovePanelToItemIndex(index)
  end
  local dataCount = table.zcount(self.battlePassCardData_)
  self.currentShowIndex_ = math.min(index + 4, dataCount)
end

function Cont_bpcard_pass_awardView:SetCurrentMaxShowIndex(itemIndex)
  local offset = itemIndex < self.currentItemIndex_ and 6 or -1
  self.currentItemIndex_ = itemIndex
  self.currentShowIndex_ = self.currentItemIndex_ + offset
end

function Cont_bpcard_pass_awardView:updateLeftShowItem()
  local showIndex = 1
  local lastIndex = self.currentShowIndex_
  if not self.battlePassData_.CurBattlePassData or next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  lastIndex = 0 < lastIndex and lastIndex or self.battlePassData_.CurBattlePassData.level
  local showData = self.showAwardData_
  if not showData or next(showData) == nil then
    return
  end
  if lastIndex >= showData[#showData].configData.SeasonLevel then
    showIndex = showData[#showData].configData.SeasonLevel
  else
    for _, v in pairs(showData) do
      if lastIndex < v.configData.SeasonLevel then
        showIndex = v.configData.SeasonLevel
        break
      end
    end
  end
  if self.rightAwardShowIndex_ == showIndex then
    return
  end
  self.rightAwardShowIndex_ = showIndex
  local itemData = self.battlePassCardData_[showIndex]
  if not itemData then
    return
  end
  self.left_level_label.text = itemData.configData.SeasonLevel
  self:initAward(itemData)
end

function Cont_bpcard_pass_awardView:initAward(itemData)
  local freeAwards = awardPreviewVm.GetAllAwardPreListByIds(itemData.configData.FreeAward)
  local paidAwards = awardPreviewVm.GetAllAwardPreListByIds(itemData.configData.PaidAward)
  if self.cancelToken_ then
    self.cancelSource:CancelToken(self.cancelToken_)
  end
  self:loadAwardUnit(freeAwards, self.top_item_node, E.EBattlePassAwardType.Free)
  self:loadAwardUnit(paidAwards, self.bottom_item_node, E.EBattlePassAwardType.Payment)
end

function Cont_bpcard_pass_awardView:loadAwardUnit(awards, rootTrans, awardType)
  if awards == nil or #awards < 1 then
    return
  end
  local itemPath = self:GetPrefabCacheData("itemPath")
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in ipairs(awards) do
      self.cancelToken_ = self.cancelSource:CreateToken()
      local name = string.format("contentAwardItem_%s_%s", k, awardType)
      local item = self:AsyncLoadUiUnit(itemPath, name, rootTrans, self.cancelToken_)
      table.insert(self.itemUnit_, name)
      local data = v
      self.itemClassTab_[name] = itemClass.new(self)
      local itemData = {
        uiBinder = item,
        configId = data.awardId,
        isSquareItem = true,
        PrevDropType = data.PrevDropType,
        isClickOpenTips = true,
        isShowReceive = false
      }
      itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
      self.itemClassTab_[name]:Init(itemData)
      self.itemClassTab_[name]:SetRedDot(false)
    end
  end)()
end

function Cont_bpcard_pass_awardView:removeShowAwardItem()
  for _, v in pairs(self.itemUnit_) do
    self:RemoveUiUnit(v)
  end
  self.itemUnit_ = {}
end

function Cont_bpcard_pass_awardView:GetPrefabCacheData(key)
  if self.prefabcache_root == nil then
    return nil
  end
  return self.prefabcache_root:GetString(key)
end

function Cont_bpcard_pass_awardView:setReceiveAllBtnState()
  local canReceive = self.battlePassVM_.CheckHasRewardCanReceive(E.EBattlePassViewType.BattlePassCard)
  self.btn_get.interactable = canReceive
  self.btn_get.IsDisabled = not canReceive
end

function Cont_bpcard_pass_awardView:setBattlePassLevelInfo()
  if not self.battlePassData_.CurBattlePassData or table.zcount(self.battlePassData_.CurBattlePassData) == 0 then
    return
  end
  local level = self.battlePassData_.CurBattlePassData.level + 1
  if level > #self.battlePassCardData_ then
    level = #self.battlePassCardData_
  end
  local bpCardData = self.battlePassVM_.GetBattlePassCardDataByLevel(level)
  local seasonExp = 0
  if bpCardData then
    seasonExp = bpCardData.SeasonExp
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassData_.CurBattlePassData.id)
  self.top_lab_grade.text = self.battlePassData_.CurBattlePassData.level
  self.top_slider_temp.maxValue = seasonExp
  local curSliderVal = self.battlePassData_.CurBattlePassData.curexp
  if level > #self.battlePassCardData_ then
    curSliderVal = seasonExp
  end
  self.top_slider_temp.value = curSliderVal
  self.top_progress_lab.text = string.format("%s/%s", curSliderVal, seasonExp)
  self.top_week_lab_manage.text = string.format("%s/%s", self.battlePassData_.CurBattlePassData.weekExp, bpCardGlobalInfo.WeeklyExpLimit)
  self.get_lab.text = Lang("PassFashionTips", {
    val = bpCardGlobalInfo.FashionLevel
  })
  self.name_lab.text = self.battlePassVM_.GetFashionName(self.battlePassData_.CurBattlePassData.id)
  self.free_bpcard_name_.text = bpCardGlobalInfo.FreePassName
  self.pro_bpcard_name_.text = bpCardGlobalInfo.NormalPassName
  self:setReceiveAllBtnState()
end

function Cont_bpcard_pass_awardView:createPlayerModel()
  Z.CoroUtil.create_coro_xpcall(function()
    local rootCanvas = Z.UIRoot.RootCanvas.transform
    local rate = rootCanvas.localScale.x / 0.00925
    self:calcModelPos()
    local clipName = ""
    if Z.ContainerMgr.CharSerialize.charBase.gender ~= Z.PbEnum("EGender", "GenderMale") then
      clipName = "as_m_base_idle"
    else
      clipName = "as_f_base_idle"
    end
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetLuaAttr(Z.ModelAttr.EModelAnimOverrideByName, Z.AnimBaseData.Rent(clipName, Panda.ZAnim.EAnimBase.EIdle))
      model:SetAttrGoPosition(self.worldPosition_)
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
      local modelScale = model:GetLuaAttrGoScale()
      model:SetLuaAttrGoScale(modelScale * rate)
      local equipZList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
      model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
      equipZList:Recycle()
      self:initFashion(model)
      model:SetLuaAttr(Z.LocalAttr.EWearSetting, "")
      model:SetLuaAttrLookAtEnable(true)
    end, function(model)
      Z.ModelHelper.SetAlpha(model, Z.ModelRenderMask.All, 0, Panda.ZGame.EModelAlphaSourceType.EUI, false)
      Z.UITimelineDisplay:ClearTimeLine()
      Z.UITimelineDisplay:BindModel(0, model)
      local cameraPosition = Z.CameraMgr.MainCamera.transform.position
      self:createPosCheckTimer(cameraPosition)
      local fashionVm = Z.VMMgr.GetVM("fashion")
      fashionVm.SetModelAutoLookatCamera(model)
    end)
  end)()
end

function Cont_bpcard_pass_awardView:calcModelPos()
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.modelPosition_)
  local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
  self.worldPosition_ = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
end

function Cont_bpcard_pass_awardView:clearPosCheckTimer()
  if self.posCheckTimer_ then
    self.posCheckTimer_:Stop()
    self.posCheckTimer_ = nil
  end
end

function Cont_bpcard_pass_awardView:createPosCheckTimer(lastCameraPos)
  self:clearPosCheckTimer()
  self.posCheckTimer_ = self.timerMgr:StartTimer(function()
    local curCameraPos = Z.CameraMgr.MainCamera.transform.position
    if self.playerModel_ and curCameraPos ~= lastCameraPos then
      self:calcModelPos()
      self.playerModel_:SetAttrGoPosition(self.worldPosition_)
    end
    Z.ModelHelper.SetAlpha(self.playerModel_, Z.ModelRenderMask.All, 1, Panda.ZGame.EModelAlphaSourceType.EUI, false)
    self:playTimeline(self.worldPosition_)
  end, 0.9, 1)
end

function Cont_bpcard_pass_awardView:playTimeline(worldPosition)
  Z.UITimelineDisplay:Play(self.timelineId_)
  Z.UITimelineDisplay:SetGoPosByCutsceneId(self.timelineId_, worldPosition)
  local rotation = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.timelineId_, rotation.x, rotation.y, rotation.z, rotation.w)
end

function Cont_bpcard_pass_awardView:onModelDrag(eventData)
  self.curRotation_ = self.curRotation_ - eventData.delta.x
  if self.timelineId_ then
    Z.UITimelineDisplay:SetTimelineRot(self.timelineId_, 0, self.curRotation_, 0)
  elseif self.playerModel_ then
    self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
  end
end

function Cont_bpcard_pass_awardView:setAllModelAttr(model, funcName, ...)
  local arg = {
    ...
  }
  model[funcName](model, table.unpack(arg))
end

function Cont_bpcard_pass_awardView:initFashion(model)
  if table.zcount(self.battlePassData_.CurBattlePassData) == 0 then
    return
  end
  self.fashionZlist_ = self.battlePassVM_.SetPlayerFashion(self.battlePassData_.CurBattlePassData.id)
  if not self.fashionZlist_ then
    return
  end
  self:setAllModelAttr(model, "SetLuaAttr", Z.LocalAttr.EWearFashion, table.unpack({
    self.fashionZlist_
  }))
  self.fashionZlist_:Recycle()
  self.fashionZlist_ = nil
end

function Cont_bpcard_pass_awardView:startAnimShow()
  self.uiBinder.node_middle.alpha = 0
  self.uiBinder.node_anim:Restart(Z.DOTweenAnimType.Open)
end

return Cont_bpcard_pass_awardView
