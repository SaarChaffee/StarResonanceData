local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_hunt_enter_into_mainView = class("Union_hunt_enter_into_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local huntRewardItem = require("ui.component.union.union_hunt_reward_item")
local huntScheduleItem = require("ui.component.union.union_schedule_item")
local difficulty = {normal = 1, hard = 2}

function Union_hunt_enter_into_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_hunt_enter_into_main")
end

function Union_hunt_enter_into_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, Z.UnionActivityConfig.HuntCameraID, false)
  self:initBaseData()
  self:initBinders()
  self:initBtnFunc()
  self:initLoopView()
  if self.togBinders_[self.difficulty_].isOn then
    self:refreshRightInfo()
  else
    self.togBinders_[self.difficulty_].isOn = true
  end
end

function Union_hunt_enter_into_mainView:OnDeActive()
  self.unionVM_ = nil
  self.awardVM_ = nil
  self.dungeonVM_ = nil
  self.dataMgr = nil
  self.rowData_ = nil
  self.loopRewardView_:UnInit()
  self.loopRewardView_ = nil
  self.itemClassTab_ = {}
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, Z.UnionActivityConfig.HuntCameraID, false)
end

function Union_hunt_enter_into_mainView:OnRefresh()
end

function Union_hunt_enter_into_mainView:GetCacheData()
  local viewData = {
    difficulty = self.difficulty_
  }
  return viewData
end

function Union_hunt_enter_into_mainView:initBaseData()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.awardVM_ = Z.VMMgr.GetVM("awardpreview")
  self.dungeonVM_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.teamMianVM_ = Z.VMMgr.GetVM("team_main")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.dataMgr = Z.DataMgr.Get("hero_dungeon_main_data")
  self.difficulty_ = self.viewData.difficulty
  if self.difficulty_ == nil then
    self.difficulty_ = difficulty.normal
  end
  self.huntActDunDonIds_ = {}
  for _, value in ipairs(Z.UnionActivityConfig.HuntActivityId) do
    if value[2] == E.UnionActivityType.UnionHunt then
      table.insert(self.huntActDunDonIds_, value[1])
    end
  end
  self.dungonId_ = self.huntActDunDonIds_[self.difficulty_]
  self.itemClassTab_ = {}
end

function Union_hunt_enter_into_mainView:initBinders()
  self.lab_people_num_ = self.uiBinder.lab_people_num
  self.lab_title_ = self.uiBinder.lab_title
  self.lab_content_ = self.uiBinder.lab_content
  self.lab_award_num_ = self.uiBinder.lab_all_reward
  self.lab_gs_ = self.uiBinder.lab_gs
  self.lab_dungon_award_ = self.uiBinder.lab_current
  self.img_person_ = self.uiBinder.img_person
  self.btn_close_ = self.uiBinder.btn_close
  self.btn_ask_ = self.uiBinder.btn_ask
  self.btn_go_ = self.uiBinder.btn_go
  self.btn_team_ = self.uiBinder.btn_team
  self.btnRank_ = self.uiBinder.btn_rank
  self.prefabcache_root_ = self.uiBinder.prefabcache_root
  self.loopscroll_award_ = self.uiBinder.loopscroll_award
  self.node_progress_root = self.uiBinder.node_reward_item
  self.normalToggle_ = self.uiBinder.node_normal
  self.difficulty_Toggle_ = self.uiBinder.node_difficulty
  self.toggleGroup_ = self.uiBinder.layout_tab
  self.labNum = self.uiBinder.lab_num
  self.imgScore = self.uiBinder.img_line_finished
end

function Union_hunt_enter_into_mainView:initBtnFunc()
  self:AddClick(self.btn_close_, function()
    self.unionVM_:CloseHuntEnterView()
  end)
  self:AddClick(self.btnRank_, function()
    self.unionVM_:OpenHuntRankView(E.UnionActivityType.UnionHunt)
  end)
  self:AddClick(self.btn_team_, function()
    local teamMain = Z.VMMgr.GetVM("team_main")
    teamMain.OpenTeamMainView()
  end)
  self:AddClick(self.btn_ask_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30060)
  end)
  self:AddAsyncClick(self.btn_go_, function()
    local func = function()
      local funcVM = Z.VMMgr.GetVM("gotofunc")
      if not funcVM.FuncIsOn(E.UnionFuncId.Hunt) then
        return
      end
      if not self.hasHuntAward then
        Z.TipsVM.ShowTipsLang(1004012)
      elseif not self.hasDungeonAward then
        Z.TipsVM.ShowTipsLang(1004011, {
          val = self.dungeonShowNum
        })
      end
      local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungonId_)
      if dungeonData == nil then
        return
      end
      self.unionVM_:AsyncStartEnterDungeon(dungeonData.FunctionID, self.dungonId_, self.dungeonVM_.GetAffix(self.dungonId_), self.cancelSource)
    end
    local limitCount = self.dataMgr.MinCount
    if 1 < limitCount then
      local isInTeam = self.teamVM_:CheckIsInTeam()
      if not isInTeam then
        Z.TipsVM.ShowTips(3322)
        return
      end
      local isLeader = self.teamVM_.GetYouIsLeader()
      if not isLeader then
        Z.TipsVM.ShowTips(2906)
        return
      end
    end
    local m = self.teamVM_:GetNotMyUnionMemberInTeam()
    if 0 < #m then
      local playerParm = {
        player = {name = ""}
      }
      local nameList_ = {}
      for _, value in ipairs(m) do
        table.insert(nameList_, value.socialData.basicData.name)
      end
      local names = table.zconcat(nameList_, ",")
      playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
      Z.TipsVM.ShowTips(1004004, playerParm)
      return
    end
    func()
  end)
  self.togBinders_ = {
    [1] = self.normalToggle_,
    [2] = self.difficulty_Toggle_
  }
  for index, value in ipairs(self.togBinders_) do
    value.group = self.toggleGroup_
    value:RemoveAllListeners()
    value.isOn = false
    value:AddListener(function(isOn)
      if isOn then
        self.difficulty_ = index
        self.dungonId_ = self.huntActDunDonIds_[index]
        self:refreshRightInfo()
      end
    end)
  end
end

function Union_hunt_enter_into_mainView:initLoopView()
  self.loopInit_ = false
  self.loopRewardView_ = loopListView.new(self, self.loopscroll_award_, huntRewardItem, "com_item_square_8")
end

function Union_hunt_enter_into_mainView:refreshRightInfo()
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungonId_)
  if dungeonData == nil then
    return
  end
  local counterTableMgr_ = Z.TableMgr.GetTable("CounterTableMgr")
  local huntDungeonCounterId_ = self.unionVM_:GetDungeonCounterID(self.dungonId_)
  local countLimit = huntDungeonCounterId_
  local counterCfgData = counterTableMgr_.GetRow(countLimit)
  local normalAwardCount = 0
  local nowAwardCount = 0
  local maxLimitNum = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  self.dungeonShowNum = maxLimitNum
  self.hasDungeonAward = 0 < normalAwardCount
  self.lab_award_num_.text = Lang("UnionHuntAwardCount") .. normalAwardCount .. "/" .. maxLimitNum
  local items = dungeonData.PassAward
  local awardList_ = self.awardVM_.GetAllAwardPreListByIds(items[1])
  if self.loopInit_ == false then
    self.loopRewardView_:Init(awardList_)
    self.loopInit_ = true
  else
    self.loopRewardView_:RefreshListView(awardList_)
  end
  local countLimit = 4
  maxLimitNum = 0
  local counterCfgData = counterTableMgr_.GetRow(countLimit)
  normalAwardCount = 0
  nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  self.hasHuntAward = 0 < normalAwardCount
  local langString = Lang("UnionHuntAwardTotalCount")
  self.lab_dungon_award_.text = langString .. normalAwardCount .. "/" .. maxLimitNum
  self.lab_title_.text = dungeonData.Name
  self.lab_content_.text = dungeonData.Content
  self.dungeonVM_.DungeonPeopleCount(self.dungonId_)
  self.lab_gs_.text = Lang("GSSuggest", {
    val = dungeonData.RecommendFightValue
  })
  local min = self.dataMgr.MinCount
  local max = self.dataMgr.MaxCount
  if min == max then
    self.lab_people_num_.text = string.format(Lang("SetPeopleOnScreenNum", {val = min}))
  else
    self.lab_people_num_.text = string.format(Lang("DungeonNumber"), min, max)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:loadAwardUnit()
    self:RefreshUnionHuntAwardList()
  end)()
end

function Union_hunt_enter_into_mainView:loadAwardUnit()
  local awards = self.unionVM_:GetUnionHuntAwardData()
  local rootTrans = self.node_progress_root
  self.maxNum_ = 0
  for _, value in ipairs(awards) do
    local scoreNum = value[1]
    self.maxNum_ = math.max(self.maxNum_, scoreNum)
  end
  local awardCount_ = #awards
  local lineWidth_, lineHeight_ = 0, 0
  lineWidth_, lineHeight_ = self.node_progress_root:GetSize(lineWidth_, lineHeight_)
  if awards == nil or awardCount_ < 1 then
    return
  end
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
    local posX = lineWidth_ * (scoreNum / self.maxNum_)
    local posY = 0
    self.itemClassTab_[k]:SetRootPos(posX, posY)
  end
end

function Union_hunt_enter_into_mainView:RefreshUnionHuntAwardList()
  self.unionVM_:AsyncGetUnionHuntProgressInfo(E.UnionActivityType.UnionHunt, self.cancelSource:CreateToken())
  local activityData_ = self.unionData_:GetUnionHuntProgressInfo(E.UnionActivityType.UnionHunt)
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
  local isRed = Z.RedPointMgr.GetRedState(E.RedType.UnionHuntTab)
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.UnionFuncId.Hunt, isRed)
  self.labNum.text = scoreNum .. "/" .. self.maxNum_
  local fillNum_ = scoreNum / self.maxNum_
  self.imgScore.fillAmount = fillNum_
end

function Union_hunt_enter_into_mainView:GetPrefabCacheData(key)
  if self.prefabcache_root_ == nil then
    return nil
  end
  return self.prefabcache_root_:GetString(key)
end

function Union_hunt_enter_into_mainView:SendGetUnionHuntAward(scoreNum)
  Z.CoroUtil.create_coro_xpcall(function()
    self.unionVM_:AsyncGetUnionHuntProgressAward(E.UnionActivityType.UnionHunt, scoreNum, self.cancelSource:CreateToken())
    self:RefreshUnionHuntAwardList()
  end)()
end

return Union_hunt_enter_into_mainView
