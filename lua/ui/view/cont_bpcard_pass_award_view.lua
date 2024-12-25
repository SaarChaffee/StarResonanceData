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
  super.ctor(self, "cont_bpcard_pass_award", "bpcard/cont_bpcard_pass_award", UI.ECacheLv.High)
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
end

function Cont_bpcard_pass_awardView:OnDeActive()
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
  self.itemsScrollRect_ = loopScrollRect_.new(self, self.loopscroll_item, battle_pass_loop_item_, "bpcard_pass_award_tpl")
  self.itemsScrollRect_:Init(dataList)
  self.battlePassContainer_ = self.battlePassVM_.GetBattlePassContainer()
  self.itemUnit_ = {}
  self.uiBinder.scroll_item.onValueChangedEvent:AddListener(function()
    self:updateLeftShowItem()
  end)
  self.fashionZlist_ = nil
  self.currentShowIndex_ = -1
  self.currentItemIndex_ = -1
  self.rightAwardShowIndex_ = -1
  self.showAwardData_ = self.battlePassVM_.GetBattlePassShowData(self.battlePassContainer_.id)
  self.modelPosition_ = self.model_node.position
  local playerGender = Z.ContainerMgr.CharSerialize.charBase.gender
  self.timelineId_ = timelineQueue[playerGender]
  self.curRotation_ = 100
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
      self.battlePassVM_.AsyncGetBattlePassAwardRequest(true, nil, nil, self.cancelSource:CreateToken())
    end
  end)
end

function Cont_bpcard_pass_awardView:bindWatchers()
  function self.battlePassDataUpDateFunc_(container, dirtys)
    if dirtys and (dirtys.level or dirtys.award or dirtys.isUnlock) then
      self:setViewInfo(false)
    end
    self:setBattlePassLevelInfo()
  end
  
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:RegWatcher(self.battlePassDataUpDateFunc_)
end

function Cont_bpcard_pass_awardView:setViewInfo(isShowDisplayOffset)
  self.uiBinder.Ref:SetVisible(self.left_lock, not self.battlePassContainer_.isUnlock)
  self.uiBinder.Ref:SetVisible(self.right_lock, not self.battlePassContainer_.isUnlock)
  self:initLoopScroll(isShowDisplayOffset)
  self:updateLeftShowItem()
end

function Cont_bpcard_pass_awardView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.Watcher:UnregWatcher(self.battlePassDataUpDateFunc_)
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
  if not self.battlePassContainer_ then
    return
  end
  lastIndex = 0 < lastIndex and lastIndex or self.battlePassContainer_.level
  local showData = self.showAwardData_
  if 0 >= table.zcount(showData) then
    return
  end
  if lastIndex >= showData[#showData].configData.Id then
    showIndex = showData[#showData].configData.Id
  else
    for _, v in pairs(showData) do
      if lastIndex < v.configData.SeasonLevel then
        showIndex = v.configData.Id
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
  local level = self.battlePassContainer_.level + 1
  if level > #self.battlePassCardData_ then
    level = #self.battlePassCardData_
  end
  local bpCardData = self.battlePassVM_.GetBattlePassCardDataByLevel(level)
  local seasonExp = 0
  if bpCardData then
    seasonExp = bpCardData.SeasonExp
  end
  local bpCardGlobalInfo = self.battlePassVM_.GetBattlePassGlobalTableInfo(self.battlePassContainer_.id)
  self.top_lab_grade.text = self.battlePassContainer_.level
  self.top_progress_lab.text = string.format("%s/%s", self.battlePassContainer_.curexp, seasonExp)
  self.top_slider_temp.maxValue = seasonExp
  self.top_slider_temp.value = self.battlePassContainer_.curexp
  self.top_week_lab_manage.text = string.format("%s/%s", self.battlePassContainer_.weekExp, bpCardGlobalInfo.WeeklyExpLimit)
  self.get_lab.text = Lang("PassFashionTips", {
    val = bpCardGlobalInfo.FashionLevel
  })
  self.name_lab.text = self.battlePassVM_.GetFashionName(self.battlePassContainer_.id)
  self.free_bpcard_name_.text = bpCardGlobalInfo.FreePassName
  self.pro_bpcard_name_.text = bpCardGlobalInfo.NormalPassName
  self:setReceiveAllBtnState()
end

function Cont_bpcard_pass_awardView:createPlayerModel()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.Delay(0.1, ZUtil.ZCancelSource.NeverCancelToken)
    local rootCanvas = Z.UIRoot.RootCanvas.transform
    local rate = rootCanvas.localScale.x / 0.00925
    local pos = Z.UnrealSceneMgr:GetTransPos("pos")
    local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.modelPosition_)
    local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
    local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
    local clipName = ""
    if Z.ContainerMgr.CharSerialize.charBase.gender ~= Z.PbEnum("EGender", "GenderMale") then
      clipName = "as_m_base_idle"
    else
      clipName = "as_f_base_idle"
    end
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetLuaAttr(Z.ModelAttr.EModelAnimOverrideByName, Z.AnimBaseData.Rent(clipName, Panda.ZAnim.EAnimBase.EIdle))
      model:SetAttrGoPosition(worldPosition)
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
    end)
    Z.UITimelineDisplay:ClearTimeLine()
    Z.UITimelineDisplay:BindModel(0, self.playerModel_)
    self:playTimeline(worldPosition)
  end)()
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
  self.fashionZlist_ = self.battlePassVM_.SetPlayerFashion(self.battlePassContainer_.id)
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
