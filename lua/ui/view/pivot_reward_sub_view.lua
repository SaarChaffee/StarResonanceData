local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pivot_reward_subView = class("Pivot_reward_subView", super)

function Pivot_reward_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "pivot_reward_sub", "pivot/pivot_reward_sub", UI.ECacheLv.None)
  self.parent_ = parent
end

function Pivot_reward_subView:OnActive()
  self:startAnimatedShow()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.pivotVm_ = Z.VMMgr.GetVM("pivot")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self:AddAsyncClick(self.uiBinder.cont_panel.group_bg.cont_map_title_top.cont_btn_return.btn, function()
    if self.isMap_ then
      if self.viewData.extraParams and self.viewData.extraParams.IsBackToProgress then
        local sceneId = self.parent_:GetCurSceneId()
        self.pivotVm_.OpenPivotProgressView(sceneId)
      else
        self.parent_:CloseRightSubview()
      end
    else
      self.pivotVm_.ClosePivotRewardView()
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.cont_panel.btn_teleport, function()
    local mapVM = Z.VMMgr.GetVM("map")
    mapVM.CheckTeleport(function()
      local sceneId = self.parent_:GetCurSceneId()
      mapVM.AsyncUserTp(sceneId, self.flagData_.TpPointId)
      Z.UIMgr:GotoMainView()
    end)
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.cont_panel.btn_trace, function()
    local mapVM = Z.VMMgr.GetVM("map")
    mapVM.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, self.parent_:GetCurSceneId(), self.viewData.flagData)
    self.parent_:CloseRightSubview()
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.cont_panel.btn_trace_no, function()
    local mapVM = Z.VMMgr.GetVM("map")
    mapVM.ClearFlagDataTrackSource(self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubview()
  end, nil, nil)
  self.rewardUnits = {
    [1] = self.uiBinder.cont_panel.cont_pivot_reward_tpl_1,
    [2] = self.uiBinder.cont_panel.cont_pivot_reward_tpl_2,
    [3] = self.uiBinder.cont_panel.cont_pivot_reward_tpl_3
  }
  self.pivotUnits_ = {
    [1] = self.uiBinder.cont_panel.node_progress_1,
    [2] = self.uiBinder.cont_panel.node_progress_2,
    [3] = self.uiBinder.cont_panel.node_progress_3
  }
  for i, v in ipairs(self.rewardUnits) do
    self:AddAsyncClick(v.btn_treasure, function()
      self:onClickReward(i)
    end)
  end
  Z.EventMgr:Add(Z.ConstValue.GetPivotReward, self.refreshRewardUnit, self)
  self:AddAsyncClick(self.uiBinder.cont_panel.btn_illustrate, function()
    local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
    helpsysVM_.OpenFullScreenTipsView(30006)
  end, nil, nil)
  self.isMap_ = self.viewData.isMap
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function Pivot_reward_subView:OnDeActive()
end

function Pivot_reward_subView:OnRefresh()
  local sceneObjType = self.viewData.sceneObjType or E.SceneObjType.Pivot
  self.isMap_ = self.viewData.isMap
  self.pivotId_ = self.viewData.pivotId
  self.pivotUUid_ = self.viewData.uuid
  self.flagData_ = self.viewData.flagData
  self.portsCount_ = self.pivotVm_.GetPivotPortUnlockCount(self.pivotId_)
  self.allPorts_ = self.pivotVm_.GetPivotAllPort(self.pivotId_)
  local contPanel_ = self.uiBinder.cont_panel
  contPanel_.Ref:SetVisible(contPanel_.btn_teleport, self.isMap_)
  if sceneObjType == E.SceneObjType.Pivot then
    self.pivotTbl_ = Z.TableMgr.GetTable("PivotTableMgr").GetRow(self.pivotId_)
    local transferTableRow = Z.TableMgr.GetTable("TransferTableMgr").GetRow(self.pivotId_)
    if self.pivotTbl_ and transferTableRow then
      contPanel_.group_bg.cont_map_title_top.lab_title.text = self.pivotTbl_.Name
      contPanel_.lab_content.text = transferTableRow.TransferDec
    end
  else
    local envTbl = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr").GetRow(self.pivotId_)
    contPanel_.group_bg.cont_map_title_top.lab_title.text = envTbl.Name
    contPanel_.lab_content.text = envTbl.Desc
  end
  contPanel_.Ref:SetVisible(contPanel_.group_content, false)
  contPanel_.Ref:SetVisible(contPanel_.group_progress, false)
  contPanel_.Ref:SetVisible(contPanel_.group_description, true)
  if sceneObjType == E.SceneObjType.Pivot and self.pivotVm_.CheckPivotUnlock(self.pivotId_) then
    contPanel_.Ref:SetVisible(contPanel_.btn_trace, false)
    contPanel_.Ref:SetVisible(contPanel_.btn_trace_no, false)
    contPanel_.Ref:SetVisible(contPanel_.btn_teleport, self.isMap_)
    self:refreshRewardIcon()
    self:refreshRewardUnit()
  else
    contPanel_.Ref:SetVisible(contPanel_.btn_trace, true)
    contPanel_.Ref:SetVisible(contPanel_.btn_trace_no, true)
    contPanel_.Ref:SetVisible(contPanel_.btn_teleport, false)
    local mapVM = Z.VMMgr.GetVM("map")
    local isTracking = mapVM.CheckIsTracingFlagByFlagData(self.parent_:GetCurSceneId(), self.flagData_)
    self:refreshTraceBtn(isTracking)
  end
end

function Pivot_reward_subView:refreshRewardIcon()
  local colorTag = E.TextStyleTag.EmphRb
  local allPortCount = #self.allPorts_
  if allPortCount <= self.portsCount_ then
    colorTag = E.TextStyleTag.AccentGreen
  end
  local strProgress = string.zconcat(self.portsCount_, "/", allPortCount)
  self.uiBinder.cont_panel.lab_quantity.text = Z.RichTextHelper.ApplyStyleTag(strProgress, colorTag)
  local state = 0
  for i = #self.pivotTbl_.SettingOffNum, 1, -1 do
    if self.portsCount_ >= self.pivotTbl_.SettingOffNum[i] then
      state = i
      break
    end
  end
  for index, value in ipairs(self.pivotUnits_) do
    value.Ref:SetVisible(value.node_on, index <= state)
  end
  self.uiBinder.cont_panel.img_bar.fillAmount = state / #self.pivotUnits_
end

function Pivot_reward_subView:refreshRewardUnit()
  self.pivotRewardState_ = self.pivotVm_.GetPivotRewardState(self.pivotId_)
  for index, value in ipairs(self.rewardUnits) do
    local allCount = self.pivotTbl_.SettingOffNum[index]
    local colorTag = E.TextStyleTag.EmphRb
    if allCount <= self.portsCount_ then
      colorTag = E.TextStyleTag.AccentGreen
    end
    value.lab_progress.text = Z.RichTextHelper.ApplyStyleTag(self.portsCount_ .. "/" .. allCount, colorTag)
    value.Ref:SetVisible(value.img_treasure_off, allCount > self.portsCount_)
    value.Ref:SetVisible(value.img_treasure_on, allCount <= self.portsCount_ and not self.pivotRewardState_[index])
    value.Ref:SetVisible(value.img_treasure_open, allCount <= self.portsCount_ and self.pivotRewardState_[index])
  end
end

function Pivot_reward_subView:refreshTraceBtn(isTrace)
  local contPanel_ = self.uiBinder.cont_panel
  if not isTrace then
    contPanel_.Ref:SetVisible(contPanel_.btn_trace, true)
    contPanel_.Ref:SetVisible(contPanel_.btn_trace_no, false)
  else
    contPanel_.Ref:SetVisible(contPanel_.btn_trace, false)
    contPanel_.Ref:SetVisible(contPanel_.btn_trace_no, true)
  end
end

function Pivot_reward_subView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Pivot_reward_subView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
end

function Pivot_reward_subView:onClickReward(index)
  if not self.pivotVm_.IsCanGetPivotAward(self.pivotId_, index) then
    local awardId = self.pivotVm_.GetCurPivotAwardId(self.pivotId_, index)
    if awardId then
      local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
      local awardList = awardPreviewVm.GetAllAwardPreListByIds(awardId)
      awardPreviewVm.OpenRewardDetailViewByListData(awardList)
    end
  else
    if self.isMap_ then
      Z.TipsVM.ShowTipsLang(130015)
      return
    end
    self.pivotVm_.AsyncGetPivotReward(self.pivotUUid_, index, self.cancelSource:CreateToken())
  end
end

return Pivot_reward_subView
