local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pivot_progress_subView = class("Pivot_progress_subView", super)
local Reward_State = {
  Not_Get = 1,
  Can_Get = 2,
  Had_Get = 3
}

function Pivot_progress_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "pivot_progress_sub", "pivot/pivot_progress_sub", UI.ECacheLv.None)
  self.parent_ = parent
end

function Pivot_progress_subView:OnActive()
  self:bindEvents()
  self:startAnimatedShow()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.pivotData_ = {}
  self.pivotVm_ = Z.VMMgr.GetVM("pivot")
  self.sceneId_ = self.parent_:GetCurSceneId()
  self.pivotRedDotNodeList_ = {}
  self.pointRedDotNodeList_ = {}
  self:AddAsyncClick(self.uiBinder.cont_panel.group_bg.cont_map_title_top.cont_btn_return.btn, function()
    self.parent_:CloseRightSubview()
  end)
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(self.sceneId_)
  if sceneRow == nil then
    return
  end
  self.uiBinder.cont_panel.group_bg.cont_map_title_top.lab_title.text = Lang("pivot") .. "-" .. sceneRow.Name
  self:initPivotAreaData()
end

function Pivot_progress_subView:OnDeActive()
  self:unbindEvents()
  self:closeCommonTips()
  self:removeAllPivotRedDot()
  self:removeAllPointRedDot()
end

function Pivot_progress_subView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshArea()
    self:refreshAreaProgress()
  end)()
end

function Pivot_progress_subView:initPivotAreaData()
  local pivotTbl = Z.TableMgr.GetTable("PivotTableMgr").GetDatas()
  for index, value in pairs(pivotTbl) do
    if value.MapID == self.sceneId_ then
      table.insert(self.pivotData_, value)
    end
  end
end

function Pivot_progress_subView:refreshArea()
  self:removeAllPivotRedDot()
  local unitPath = self:GetPrefabCacheData("region_tpl")
  for _, value in pairs(self.pivotData_) do
    local unit = self:AsyncLoadUiUnit(unitPath, value.AreaName, self.uiBinder.cont_panel.node_content)
    local bUnlock = self.pivotVm_.CheckPivotUnlock(value.Id)
    local pivotCount = #self.pivotVm_.GetPivotAllPort(value.Id)
    local unlockPivotCount = self.pivotVm_.GetPivotPortUnlockCount(value.Id)
    unit.lab_name.text = value.AreaName
    unit.img_areabg:SetImage(value.PivotPic)
    unit.btn_bg:AddListener(function()
      self:onClickArea(value.Id)
    end)
    if bUnlock then
      local colorTag = E.TextStyleTag.EmphRb
      if pivotCount <= unlockPivotCount then
        colorTag = E.TextStyleTag.AccentGreen
      end
      unit.lab_progress.text = Z.RichTextHelper.ApplyStyleTag(unlockPivotCount .. "/" .. pivotCount, colorTag)
      unit.Ref:SetVisible(unit.img_finish, pivotCount <= unlockPivotCount)
      unit.img_areabg:ClearGray()
    else
      unit.Ref:SetVisible(unit.img_finish, false)
      unit.img_areabg:SetGray()
      local colorTag = E.TextStyleTag.EmphRb
      unit.lab_progress.text = ""
    end
    local nodeId = self.pivotVm_.GetPivotRedId(self.sceneId_, value.Id)
    Z.RedPointMgr.LoadRedDotItem(nodeId, self, unit.node_red)
    table.insert(self.pivotRedDotNodeList_, nodeId)
  end
end

function Pivot_progress_subView:refreshAreaProgress()
  self:removeAllPointRedDot()
  local totalCount, unlockCount = self.pivotVm_.GetScenePivotPortCountInfo(self.sceneId_)
  local curProgress = unlockCount / totalCount
  self.uiBinder.cont_panel.lab_progress.text = math.floor(curProgress * 100)
  self.uiBinder.cont_panel.img_slider:SetFillAmount(curProgress)
  local pivotAwardTableMgr = Z.TableMgr.GetTable("PivotAwardTableMgr")
  local pivotAwardTableRow = pivotAwardTableMgr.GetRow(self.sceneId_)
  if pivotAwardTableRow == nil then
    return
  end
  local rewardStateDict = self.pivotVm_.GetScenePivotRewardState(self.sceneId_)
  local count = #pivotAwardTableRow.AwardId
  for i, v in ipairs(pivotAwardTableRow.AwardId) do
    local unitPath = self:GetPrefabCacheData("progress_tpl")
    local unitName = "progress_" .. i
    local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.cont_panel.layout_progress)
    if unit then
      local progressNum = math.floor(100 / count * i)
      local progress = progressNum * 0.01
      local state = Reward_State.Not_Get
      if curProgress >= progress then
        if rewardStateDict[i] then
          state = Reward_State.Had_Get
        else
          state = Reward_State.Can_Get
        end
      end
      unit.lab_percentage.text = progressNum .. "%"
      unit.Ref:SetVisible(unit.img_not_get, state == Reward_State.Not_Get)
      unit.Ref:SetVisible(unit.img_can_get, state == Reward_State.Can_Get)
      unit.Ref:SetVisible(unit.img_had_get, state == Reward_State.Had_Get)
      unit.Ref:SetVisible(unit.img_on, curProgress >= progress)
      unit.Ref:SetVisible(unit.img_off, curProgress < progress)
      local nodeId = self.pivotVm_.GetProgressRedId(self.sceneId_, v)
      unit.btn_treasure:AddListener(function()
        self:onClickTreasure(i, v, state)
        Z.RedPointMgr.OnClickRedDot(nodeId)
      end)
      Z.RedPointMgr.LoadRedDotItem(nodeId, self, unit.node_red)
      table.insert(self.pointRedDotNodeList_, nodeId)
    end
  end
end

function Pivot_progress_subView:removeAllPivotRedDot()
  for i, v in ipairs(self.pivotRedDotNodeList_) do
    Z.RedPointMgr.RemoveNodeItem(v)
  end
  self.pivotRedDotNodeList_ = {}
end

function Pivot_progress_subView:removeAllPointRedDot()
  for i, v in ipairs(self.pointRedDotNodeList_) do
    Z.RedPointMgr.RemoveNodeItem(v)
  end
  self.pointRedDotNodeList_ = {}
end

function Pivot_progress_subView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Pivot_progress_subView:startAnimatedHide()
end

function Pivot_progress_subView:onClickArea(pivotId)
  local uid = self.pivotVm_.FindPivotUidInSceneTable(pivotId, self.sceneId_)
  if uid then
    local entSceneObjType = Z.PbEnum("EEntityType", "EntSceneObject")
    local subType = E.SceneObjType.Pivot
    local flagData = self.parent_.mapFlagsComp_:GetFalgData(uid, entSceneObjType, subType)
    if flagData == nil then
      return
    end
    self.parent_.mapFlagsComp_:SetUnitSelectByFlagData(flagData)
    self.parent_:openSubView(flagData, {IsBackToProgress = true})
  end
end

function Pivot_progress_subView:onClickTreasure(index, awardId, state)
  if state == Reward_State.Can_Get then
    Z.CoroUtil.create_coro_xpcall(function()
      self.pivotVm_.AsyncGetTotalPivotReward(self.sceneId_, index, self.cancelSource:CreateToken())
    end)()
  else
    self:openCommonTips(state, awardId)
  end
end

function Pivot_progress_subView:openCommonTips(state, awardId)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardDataList = awardPreviewVm.GetAllAwardPreListByIds(awardId)
  if awardDataList == nil then
    return
  end
  Z.CommonTipsVM.OpenTitleContentItems(self.uiBinder.cont_panel.node_tips_pos, Lang("ItemReward"), "", awardDataList)
end

function Pivot_progress_subView:closeCommonTips()
  Z.CommonTipsVM.CloseTitleContentItems()
end

function Pivot_progress_subView:onGetPivotReward()
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshAreaProgress()
  end)()
end

function Pivot_progress_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.GetPivotReward, self.onGetPivotReward, self)
end

function Pivot_progress_subView:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.GetPivotReward, self.onGetPivotReward, self)
end

function Pivot_progress_subView:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root:GetString(key)
end

return Pivot_progress_subView
