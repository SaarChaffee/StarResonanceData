local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_hunt_subView = class("Union_hunt_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local huntRewardItem = require("ui.component.union.union_hunt_reward_item")
local huntActivityItem = require("ui.component.union.union_activity_hunt_item")
local huntScheduleItem = require("ui.component.union.union_schedule_item")

function Union_hunt_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_hunt_sub", "union/union_hunt_sub", UI.ECacheLv.None)
end

function Union_hunt_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self:InitBinders()
  self:initBtnFunc()
  self:initLoopView()
  self:InitActivityData()
end

function Union_hunt_subView:OnDeActive()
  self.unionVM_ = nil
  self.currentSelectData_ = nil
  self.itemUnit = nil
  for index, value in ipairs(self.itemClassTab_) do
    value:UnInit()
  end
  self.itemClassTab_ = nil
  self.maxNum = nil
  self:unInitLoopView()
  self:unLoadUnionRedDotItem()
end

function Union_hunt_subView:OnRefresh()
  self:RefreshActivityData()
end

function Union_hunt_subView:InitBinders()
  self.labTitle_ = self.uiBinder.lab_title_name
  self.labCompanion_ = self.uiBinder.lab_companion
  self.labInfo_ = self.uiBinder.lab_info
  self.labTime_ = self.uiBinder.lab_time
  self.labAwardNum_ = self.uiBinder.lab_award_num
  self.labNum_ = self.uiBinder.lab_num
  self.imgBG = self.uiBinder.rimg_bg
  self.imgScore = self.uiBinder.img_scoreline
  self.btnInfo_ = self.uiBinder.btn_info
  self.btnRank_ = self.uiBinder.btn_active
  self.btnCustomTime_ = self.uiBinder.btn_custom_time
  self.btnGo_ = self.uiBinder.btn_go
  self.nodeReward_ = self.uiBinder.node_reward_item
  self.nodeProgress_ = self.uiBinder.node_schedule_item
  self.nodeHunt_ = self.uiBinder.node_hunt_item
  self.tipsRelativeTo_ = self.imgBG.transform
end

function Union_hunt_subView:initLoopView()
  self.isFirstInit = true
  self.loopRewardView_ = loopGridView.new(self, self.uiBinder.loopscroll_reward, huntRewardItem, "com_item_square_8")
  self.loopHuntView_ = loopListView.new(self, self.uiBinder.loopscroll_hunt, huntActivityItem, "seasonact_list_item_tpl_union")
end

function Union_hunt_subView:initBtnFunc()
  self:AddClick(self.btnGo_, function()
    Z.CoroUtil.create_coro_xpcall(function()
      local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
      quickJumpVm.DoJumpByConfigParam(self.currentSelectData_.QuickJumpType, self.currentSelectData_.QuickJumpParam)
      local unionVM = Z.VMMgr.GetVM("union")
      unionVM:CloseAllUnionView()
    end)()
  end)
  self:AddClick(self.btnRank_, function()
    local viewData_ = self.currentSelectData_.Id
    self.unionVM_:OpenHuntRankView(viewData_)
  end)
  self:AddClick(self.btnCustomTime_, function()
  end)
  self:AddClick(self.btnInfo_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(self.currentSelectData_.HelpId)
  end)
end

function Union_hunt_subView:unInitLoopView()
  if self.loopRewardView_.DataList then
    self.loopRewardView_:UnInit()
  end
  self.loopHuntView_:UnInit()
  self.loopRewardView_ = nil
  self.loopHuntView_ = nil
  self.isFirstInit = nil
end

function Union_hunt_subView:InitActivityData()
  self.itemClassTab_ = {}
  self.unionVM_ = Z.VMMgr.GetVM("union")
  local datas_ = self.unionVM_:GetUnionHuntData()
  self.awardVM_ = Z.VMMgr.GetVM("awardpreview")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.loopHuntView_:Init(datas_)
  if self.viewData and self.viewData.OpenFuncId then
    local selectIndex = 1
    for i, data in ipairs(datas_) do
      if data.FunctionId == self.viewData.OpenFuncId then
        selectIndex = i
      end
    end
    self.loopHuntView_:SetSelected(selectIndex)
  else
    self.loopHuntView_:SetSelected(1)
  end
  self.itemUnit = {}
  self.maxNum = 0
end

function Union_hunt_subView:RefreshActivityData()
  local datas_ = self.unionVM_:GetUnionHuntData()
  self.loopHuntView_:RefreshListView(datas_)
end

function Union_hunt_subView:RefreshRightInfo(currentData, isUnLock)
  self.currentSelectData_ = currentData
  self.labTitle_.text = currentData.Name
  self.labCompanion_.text = currentData.RecommendNum
  self.labInfo_.text = currentData.ActDes
  self.labTime_.text = Lang("HuntActivityTime", {
    val = currentData.Time
  })
  self.imgBG:SetImage(currentData.BackGroundPic)
  self.uiBinder.Ref:SetVisible(self.btnRank_, currentData.Id == E.UnionActivityType.Hunt and isUnLock ~= false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, isUnLock ~= false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_schedule, isUnLock ~= false)
  local unionSceneIsUnlock = self.unionVM_:GetUnionSceneIsUnlock()
  self.uiBinder.Ref:SetVisible(self.btnGo_, isUnLock ~= false and unionSceneIsUnlock)
  self:SetUIVisible(self.uiBinder.node_tips, unionSceneIsUnlock == false)
  local awardId_ = 0
  if isUnLock ~= false then
    awardId_ = currentData.PreviewAward
  end
  self:RefreshRewardList(awardId_)
  if isUnLock == true then
    Z.CoroUtil.create_coro_xpcall(function()
      self:showAwardUnit()
      self:AsyncGetUnionHuntAwardList()
      self:RefreshGetRewardNum()
    end)()
  end
  self:unLoadUnionRedDotItem()
  local unionRed_ = require("rednode.union_red")
  if currentData.Id == E.UnionActivityType.UnionHunt then
    self:loadUnionHuntRedDotItem()
    if Z.RedPointMgr.GetRedState(E.RedType.UnionHuntCount) then
      local unionData = Z.DataMgr.Get("union_data")
      unionData:SetHuntRecommendRedChecked(true)
      unionRed_.RefreshUnionHuntRed()
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionHuntRedRefresh)
    end
  elseif currentData.Id == E.UnionActivityType.UnionDance then
    self:loadUnionDanceRedDotItem()
    if Z.RedPointMgr.GetRedState(E.RedType.UnionDanceCount) then
      local unionWarDanceData = Z.DataMgr.Get("union_wardance_data")
      unionWarDanceData:SetRecommendRedChecked(true)
      unionRed_.RefreshUnionWarDanceRed()
      Z.EventMgr:Dispatch(Z.ConstValue.Union.UnionWarDanceRedRefresh)
    end
  else
    self:unLoadUnionRedDotItem()
  end
end

function Union_hunt_subView:RefreshGetRewardNum()
  local countLimit = self.currentSelectData_.CounterId
  local maxLimitNum = 0
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countLimit)
  local normalAwardCount = 0
  local nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  local langString = Lang("UnionHuntAwardTotalCount")
  self.labAwardNum_.text = langString .. normalAwardCount .. "/" .. maxLimitNum
end

function Union_hunt_subView:RefreshRewardList(rewardID)
  local awardList_ = {}
  if 0 < rewardID then
    awardList_ = self.awardVM_.GetAllAwardPreListByIds(rewardID)
  end
  if self.isFirstInit then
    self.isFirstInit = false
    self.loopRewardView_:Init(awardList_)
  else
    self.loopRewardView_:RefreshListView(awardList_)
  end
end

function Union_hunt_subView:AsyncGetUnionHuntAwardList()
  local activityId_ = self.currentSelectData_.Id
  local reply = self.unionVM_:AsyncGetUnionHuntProgressInfo(activityId_, self.cancelSource:CreateToken())
  if not reply.errCode or reply.errCode == 0 then
  end
  self:RefreshUnionHuntAwardList()
end

function Union_hunt_subView:RefreshUnionHuntAwardList()
  local activityID_ = self.currentSelectData_.Id
  local activityData_ = self.unionData_:GetUnionHuntProgressInfo(activityID_)
  local scoreNum = activityData_ == nil and 0 or activityData_.progress
  local awardList = {}
  if activityData_ then
    local list_ = activityData_.award
    for _, value in pairs(list_) do
      awardList[value] = true
    end
  end
  local count = 0
  for _, value in pairs(self.itemClassTab_) do
    local isGet = awardList[value.param_.scoreNum] == true
    value:SetState(scoreNum, isGet)
    if isGet then
      count = count + 1
    end
  end
  if count == table.zcount(awardList) then
    Z.RedPointMgr.AsyncCancelRedDot(E.RedType.UnionHuntPorgress)
    Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionHuntPorgress, 0)
  end
  self.labNum_.text = scoreNum .. "/" .. self.maxNum
  local fillNum_ = self.maxNum == 0 and 0 or scoreNum / self.maxNum
  self.imgScore.fillAmount = fillNum_
end

function Union_hunt_subView:showAwardUnit()
  local rowData_ = self.unionVM_:GetAwardData(self.currentSelectData_.TreasureChest)
  self:loadAwardUnit(rowData_, self.uiBinder.node_progress_item)
end

function Union_hunt_subView:loadAwardUnit(awards, rootTrans)
  self.maxNum = 0
  for _, value in ipairs(awards) do
    local scoreNum = value[1]
    self.maxNum = math.max(self.maxNum, scoreNum)
  end
  local awardCount_ = #awards
  local lineWidth_, lineHeight_ = 0, 0
  lineWidth_, lineHeight_ = self.uiBinder.node_progress_item:GetSize(lineWidth_, lineHeight_)
  if awards == nil or awardCount_ < 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_schedule, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_schedule, true)
  local offsetNum_ = lineWidth_ / awardCount_
  local itemPath = self:GetPrefabCacheData("schedule_item")
  for k, v in ipairs(awards) do
    local scoreNum = v[1]
    local awardId = v[2]
    if self.itemClassTab_[k] == nil then
      self.cancelToken_ = self.cancelSource:CreateToken()
      local name = string.format("awardItem_%s_%s", scoreNum, awardId)
      local item = self:AsyncLoadUiUnit(itemPath, name, rootTrans, self.cancelToken_)
      self.itemClassTab_[k] = huntScheduleItem.new(self)
      local itemData = {scoreNum = scoreNum, awardID = awardId}
      self.itemClassTab_[k]:Init(self, item, itemData)
    end
    local posX = lineWidth_ * (scoreNum / self.maxNum)
    local posY = 0
    self.itemClassTab_[k]:SetRootPos(posX, posY)
  end
end

function Union_hunt_subView:SendGetUnionHuntAward(scoreNum)
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncGetUnionHuntAward(scoreNum)
  end)()
end

function Union_hunt_subView:AsyncGetUnionHuntAward(scoreNum)
  local activityId_ = self.currentSelectData_.Id
  local token_ = self.cancelSource:CreateToken()
  self.unionVM_:AsyncGetUnionHuntProgressAward(activityId_, scoreNum, token_)
  self:RefreshUnionHuntAwardList()
end

function Union_hunt_subView:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  return self.uiBinder.prefabcache_root:GetString(key)
end

function Union_hunt_subView:loadUnionHuntRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionHuntCount, self, self.uiBinder.btn_go_rect)
end

function Union_hunt_subView:loadUnionDanceRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionDanceCount, self, self.uiBinder.btn_go_rect)
end

function Union_hunt_subView:unLoadUnionRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionHuntCount)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionDanceCount)
end

function Union_hunt_subView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

return Union_hunt_subView
