local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_bonus_points_popupView = class("World_boss_bonus_points_popupView", super)
local rewardItem = require("ui.component.world_boss.world_boss_score_loop_item")

function World_boss_bonus_points_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_bonus_points_popup")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  
  function self.onContainerChanged_(container, dirtyKeys)
    self:RefreshAwardList()
  end
end

function World_boss_bonus_points_popupView:OnActive()
  self:initBinders()
  self:initBaseData()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initAwardItem(Z.WorldBoss.WorldBossPersonalScoreAward)
    self:RefreshAwardList()
    if Z.ContainerMgr.CharSerialize.personalWorldBossInfo ~= nil then
      Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:RegWatcher(self.onContainerChanged_)
    end
  end)()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
end

function World_boss_bonus_points_popupView:OnDeActive()
  if Z.ContainerMgr.CharSerialize.personalWorldBossInfo ~= nil then
    Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:UnregWatcher(self.onContainerChanged_)
  end
  for _, value in ipairs(self.itemClassTab_) do
    value:UnInit()
  end
end

function World_boss_bonus_points_popupView:OnRefresh()
end

function World_boss_bonus_points_popupView:initBinders()
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30102)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.worldBossVM_:CloseWorldBossScoreView()
  end)
end

function World_boss_bonus_points_popupView:initBaseData()
  self.itemClassTab_ = {}
  local t = Z.WorldBoss.WorldBossPersonalScoreAward
  self.maxScore_ = 1
  self.minScore_ = nil
  local count = 0
  for _, value in ipairs(t) do
    local score = value[1]
    self.maxScore_ = math.max(self.maxScore_, score)
    if self.minScore_ == nil then
      self.minScore_ = score
    else
      self.minScore_ = math.min(self.minScore_, score)
    end
    count = count + 1
  end
  local worldBossInfo = Z.ContainerMgr.CharSerialize.personalWorldBossInfo
  local myScore = worldBossInfo.score
  local fillAmount = 0
  if myScore > self.minScore_ then
    fillAmount = (myScore - self.minScore_) / (self.maxScore_ - self.minScore_)
  end
  self.uiBinder.img_bar.fillAmount = fillAmount
  self.uiBinder.lab_credits.text = myScore
end

function World_boss_bonus_points_popupView:initAwardItem(awards)
  local awardPreviewVM = Z.VMMgr.GetVM("awardpreview")
  local awardCount_ = #awards
  local lineWidth_, lineHeight_ = 0, 0
  lineWidth_, lineHeight_ = self.uiBinder.node_bar:GetSize(lineWidth_, lineHeight_)
  for _, value in ipairs(self.itemClassTab_) do
    local itemUIBinder = value.uiBinder
    value:SetVisible(itemUIBinder.node_root, false)
    value:ClearData()
  end
  if awards == nil or awardCount_ < 1 then
    return
  end
  local offsetNum_ = lineWidth_ / (awardCount_ - 1)
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.prefabcache_root, "award")
  for k, v in ipairs(awards) do
    local scoreNum = v[1]
    local awardId = v[2]
    local awardList = awardPreviewVM.GetAllAwardPreListByIds(awardId)
    local previewData = awardList[1]
    if self.itemClassTab_[k] == nil then
      self.cancelToken_ = self.cancelSource:CreateToken()
      local name = string.format("awardItem_%s_%s", scoreNum, awardId)
      local item = self:AsyncLoadUiUnit(itemPath, name, self.uiBinder.node_content, self.cancelToken_)
      self.itemClassTab_[k] = rewardItem.new(self)
      self.itemClassTab_[k]:Init(self, item)
    end
    local curItem = self.itemClassTab_[k]
    local itemData = {
      scoreNum = scoreNum,
      awardID = previewData.awardId,
      awardData = previewData,
      stateID = k
    }
    local itemUIBinder = curItem.uiBinder
    curItem:SetVisible(itemUIBinder.node_root, true)
    local posX = (k - 1) * offsetNum_
    local posY = 0
    curItem:SetRootPos(posX, posY)
    curItem:Refresh(itemData)
  end
end

function World_boss_bonus_points_popupView:RefreshAwardList()
  local d = Z.ContainerMgr.CharSerialize.personalWorldBossInfo
  local score = d.score
  local receiveData = d.scoreAwardInfo
  for _, value in ipairs(self.itemClassTab_) do
    local hasReceive = false
    local d = value:GetData()
    if d then
      local stateID = d.stateID
      if receiveData then
        local status = receiveData[stateID]
        if status then
          hasReceive = status.awardStatus == E.ReceiveRewardStatus.Received
        end
      end
      value:SetState(score, hasReceive)
    end
  end
end

return World_boss_bonus_points_popupView
