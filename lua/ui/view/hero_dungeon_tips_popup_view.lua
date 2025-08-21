local UI = Z.UI
local super = require("ui.ui_subview_base")
local Hero_dungeon_tips_popupView = class("Hero_dungeon_tips_popupView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local itemClass = require("common.item")
local TimeSliderColor = {
  [1] = Color.New(1, 1, 1, 1),
  [2] = Color.New(1, 0.7803921568627451, 0.4666666666666667, 1),
  [3] = Color.New(1, 0.592156862745098, 0.4666666666666667, 1)
}
local HeroKeyRollTypeGiveup = Z.PbEnum("EHeroKeyRollType", "HeroKeyRollTypeGiveup")
local HeroKeyRollTypeRoll = Z.PbEnum("EHeroKeyRollType", "HeroKeyRollTypeRoll")
local HeroKeyRollTypeGet = Z.PbEnum("EHeroKeyRollType", "HeroKeyRollTypeGet")
local HeroKeyRollTypeRollGet = Z.PbEnum("EHeroKeyRollType", "HeroKeyRollTypeRollGet")
local HeroKeyRollTypeCountFull = Z.PbEnum("EHeroKeyRollType", "HeroKeyRollTypeCountFull")

function Hero_dungeon_tips_popupView:ctor(parent)
  self.uiBinder = nil
  self.parent_ = parent
  super.ctor(self, "hero_dungeon_tips_popup", "hero_dungeon/hero_dungeon_tips_popup", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  
  function self.rollInfoFun_(container, dirtys)
    self:rollInfoChangeFunc(container, dirtys)
  end
  
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function Hero_dungeon_tips_popupView:initZWidget()
  self.labTitle_ = self.uiBinder.lab_name
  self.btnShrink_ = self.uiBinder.btn_shrink
  self.labSurplus_ = self.uiBinder.lab_surplus
  self.nodeContent_ = self.uiBinder.node_content
  self.labContent_ = self.uiBinder.lab_info_content
  self.nodeItem_ = self.uiBinder.node_item
  self.itemParent_ = self.uiBinder.layout_item
  self.nodeSelectedBtn_ = self.uiBinder.node_btn
  self.nodeRoll_ = self.uiBinder.node_roll
  self.leftRoll_ = self.uiBinder.cont_roll
  self.rightRoll_ = self.uiBinder.node_right
  self.nodeSlider_ = self.uiBinder.node_slider
  self.slider_ = self.uiBinder.slider_temp
  self.btnAbandon_ = self.uiBinder.btn_abandon
  self.btnNeed_ = self.uiBinder.btn_need
  self.btnTips_ = self.uiBinder.lab_tips
  self.nodeAbandon_ = self.uiBinder.lab_abandon
  self.rollInfoParent_ = self.uiBinder.node_strip
  self.surplusNode_ = self.uiBinder.node_surplus
end

function Hero_dungeon_tips_popupView:initBtn()
  self:AddClick(self.btnShrink_, function()
    if self.parent_ then
      self.parent_:CloseRollView()
    end
  end)
  self:AddAsyncClick(self.btnAbandon_.btn, function()
    self.vm_.AsyncDungeonRoll(self.viewData, true, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btnNeed_.btn, function()
    self.isPlayRoll_ = true
    self.vm_.AsyncDungeonRoll(self.viewData, false, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.leftRoll_, function(isStop)
    if isStop then
      self.leftRollIsStop_ = true
      self:stopRoll()
    end
  end)
  self:AddAsyncClick(self.rightRoll_, function(isStop)
    if isStop then
      self.rightRollIsStop_ = true
      self:stopRoll()
    end
  end)
end

function Hero_dungeon_tips_popupView:OnActive()
  self:initZWidget()
  self:initBtn()
  self.uiBinder.Ref:SetVisible(self.nodeRoll_, false)
  self.heroKeyContainer_ = Z.ContainerMgr.DungeonSyncData.heroKey.keyInfo[self.viewData]
  if self.heroKeyContainer_ then
    self:initData()
    self.items_ = {}
    self.heroKeyContainer_.Watcher:RegWatcher(self.rollInfoFun_)
    for key, value in pairs(self.heroKeyContainer_.rollInfo) do
      self:loadRollInfo(value)
    end
  end
end

function Hero_dungeon_tips_popupView:isShowRollInfo(isHide)
  self.uiBinder.Ref:SetVisible(self.rollInfoParent_, isHide)
  self.uiBinder.Ref:SetVisible(self.nodeItem_, not isHide)
  self.uiBinder.Ref:SetVisible(self.nodeContent_, not isHide)
  self.uiBinder.Ref:SetVisible(self.nodeSelectedBtn_, not isHide)
  self.uiBinder.Ref:SetVisible(self.nodeSlider_, not isHide)
  self.uiBinder.Ref:SetVisible(self.surplusNode_, not isHide)
end

function Hero_dungeon_tips_popupView:isHaveAwardCount(isHaveRemainCount)
  self.uiBinder.Ref:SetVisible(self.btnTips_, not isHaveRemainCount)
  self.btnAbandon_.Ref.UIComp:SetVisible(isHaveRemainCount)
  self.btnNeed_.Ref.UIComp:SetVisible(isHaveRemainCount)
  if isHaveRemainCount == false then
    self:startRollEndTime()
  end
end

function Hero_dungeon_tips_popupView:isSelectRoll(isSelect)
  self.parent_:StopTime(self.viewData)
  self.timerMgr:StopFrameTimer(self.time_)
  self.uiBinder.Ref:SetVisible(self.nodeAbandon_, not isSelect)
  self.btnAbandon_.Ref.UIComp:SetVisible(false)
  self.btnNeed_.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.nodeSlider_, false)
end

function Hero_dungeon_tips_popupView:initData()
  self.isPlayRoll_ = false
  self.charId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  self.limitTime_ = Z.Global.RollLimitTime
  self.rollChangeDelayTime_ = Z.Global.RollChangeDelayTime
  local remainCount = self.vm_.GetWeekAwardCount(E.ECounterType.HeroRollCount)
  self.labSurplus_.text = Lang("HeroRollLastAwardCount") .. remainCount
  local isHaveRemainCount = 0 < remainCount
  self:isHaveAwardCount(isHaveRemainCount)
  if isHaveRemainCount then
    self:startSliderTime()
  end
  local member = self.teamData_.TeamInfo.members[Z.ContainerMgr.DungeonSyncData.heroKey.charId]
  if member then
    local player = {}
    player.name = member.socialData and member.socialData.basicData.name or ""
    self.labContent_.text = Lang("HeroRollKeyOwnerTips", {player = player})
  end
  if self.charId_ == Z.ContainerMgr.DungeonSyncData.heroKey.charId then
    self:isShowRollInfo(true)
  else
    self:loadItem(self.heroKeyContainer_.item)
    self:isShowRollInfo(false)
  end
end

function Hero_dungeon_tips_popupView:startRollEndTime()
  self.timerMgr:StartTimer(function()
    self.isRolling_ = false
    self.uiBinder.Ref:SetVisible(self.nodeRoll_, false)
    self:isShowRollInfo(true)
  end, self.rollChangeDelayTime_, 1)
end

function Hero_dungeon_tips_popupView:stopRoll()
  if self.rightRollIsStop_ and self.leftRollIsStop_ then
    self:startRollEndTime()
  end
end

function Hero_dungeon_tips_popupView:roll(rollDot, num)
  rollDot:SetStopNum(num)
  rollDot:SetSpeed(10)
  rollDot:Play()
end

function Hero_dungeon_tips_popupView:beginRoll()
  self.isRolling_ = true
  self.isPlayRoll_ = false
  self.uiBinder.Ref:SetVisible(self.nodeSelectedBtn_, false)
  self.uiBinder.Ref:SetVisible(self.nodeRoll_, true)
  self.leftRollIsStop_ = false
  self.rightRollIsStop_ = false
  self:roll(self.leftRoll_, math.floor(self.stopNum_ / 10))
  self:roll(self.rightRoll_, math.floor(self.stopNum_ % 10))
  self.timerMgr:StartTimer(function()
    self.leftRoll_:SetSpeed(5)
    self.rightRoll_:SetSpeed(5)
    self.leftRoll_:Stop()
    self.rightRoll_:Stop()
  end, 1, 1)
end

function Hero_dungeon_tips_popupView:Hide()
  self.uiBinder.Ref.UIComp:SetVisible(false)
end

function Hero_dungeon_tips_popupView:Show()
  self.uiBinder.Ref.UIComp:SetVisible(true)
end

function Hero_dungeon_tips_popupView:OnDeActive()
  if self.heroKeyContainer_ then
    self.heroKeyContainer_.Watcher:UnregWatcher(self.rollInfoFun_)
  end
  if self.tagTimer_ then
    self.timerMgr:StopFrameTimer(self.tagTimer_)
    self.tagTimer_ = nil
  end
end

function Hero_dungeon_tips_popupView:OnRefresh()
end

function Hero_dungeon_tips_popupView:rollInfoChangeFunc(container, dirtys)
  for key, value in pairs(container.rollInfo) do
    self:loadRollInfo(value)
  end
end

function Hero_dungeon_tips_popupView:loadItem(itemData)
  self.itemClass_ = itemClass.new(self)
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item")
  if itemPath then
    Z.CoroUtil.create_coro_xpcall(function()
      local item = self:AsyncLoadUiUnit(itemPath, itemData.configId, self.itemParent_)
      local data = {}
      data.configId = itemData.configId
      data.unit = item
      data.isSquareItem = true
      self.itemClass_:Init(data)
      self.itemClass_:SetLab(itemData.count)
    end)()
  end
end

function Hero_dungeon_tips_popupView:loadRollInfo(rollInfo)
  if rollInfo.type == 0 then
    return
  end
  local rollInfoPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "rollInfo")
  if rollInfoPath then
    Z.CoroUtil.create_coro_xpcall(function()
      local name = rollInfo.type .. "rollInfo" .. rollInfo.charId
      if self.items_[name] then
        return
      end
      self.items_[name] = true
      local rollItem = self:AsyncLoadUiUnit(rollInfoPath, name, self.rollInfoParent_)
      if rollItem then
        self:setItem(rollItem, rollInfo)
      end
    end)()
  end
end

function Hero_dungeon_tips_popupView:setItem(rollItem, rollInfo)
  local headStr = ""
  local player = {}
  rollItem.Ref:SetVisible(rollItem.node_item, false)
  player.name = Z.RichTextHelper.ApplyStyleTag(rollInfo.name, E.TextStyleTag.PlayerName)
  if rollInfo.type == HeroKeyRollTypeGiveup then
    headStr = Lang("HeroRollAbaddonTips", {player = player})
    if rollInfo.charId == self.charId_ then
      self:isSelectRoll(false)
      self:startRollEndTime()
    end
  elseif rollInfo.type == HeroKeyRollTypeRoll then
    local rollNum = Z.RichTextHelper.ApplyStyleTag(rollInfo.rollValue, E.TextStyleTag.RollNum)
    headStr = string.format(Lang("HeroRollTips", {player = player}), rollNum)
    self:isBeginRoll(rollInfo)
  elseif rollInfo.type == HeroKeyRollTypeGet then
    self:loadAward(rollItem, Z.ContainerMgr.DungeonSyncData.heroKey.heroKeyAwardItem, rollInfo.charId)
    headStr = Lang("HeroRollKeyAwardTipsInChat", {player = player})
  elseif rollInfo.type == HeroKeyRollTypeCountFull then
    headStr = Lang("HeroRollNotAllowRoll", {player = player})
    if rollInfo.charId == self.charId_ then
      self:isHaveAwardCount(false)
    end
  elseif rollInfo.type == HeroKeyRollTypeRollGet then
    self:loadAward(rollItem, {
      self.heroKeyContainer_.item
    }, rollInfo.charId)
    headStr = Lang("HeroRollMaxInChat", {player = player})
    self:isBeginRoll(rollInfo, true)
  end
  rollItem.lab_info_content.text = headStr
  local socialData = self.socialVm_.AsyncGetSocialData(0, rollInfo.charId, self.cancelSource:CreateToken())
  playerPortraitHgr.InsertNewPortraitBySocialData(rollItem.cont_head_30_item, socialData, nil, self.cancelSource:CreateToken())
end

function Hero_dungeon_tips_popupView:isBeginRoll(rollInfo, isGet)
  if rollInfo.charId == self.charId_ then
    self.stopNum_ = rollInfo.rollValue
    self:isSelectRoll(true)
    if isGet and not self.isRolling_ then
      self:isShowRollInfo(true)
    elseif not self.isRolling_ then
      self:beginRoll()
    end
  end
end

function Hero_dungeon_tips_popupView:loadAward(rollItem, items, charId)
  local awardItemPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "awardItem")
  if awardItemPath == "" or awardItemPath == nil then
    return
  end
  for _, item in ipairs(items) do
    local keyTtemCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
    if keyTtemCfgData then
      local unit = self:AsyncLoadUiUnit(awardItemPath, _ .. charId .. item.configId, rollItem.node_item)
      rollItem.Ref:SetVisible(rollItem.node_item, true)
      local itemsVM = Z.VMMgr.GetVM("items")
      unit.rimg_source:SetImage(itemsVM.GetItemIcon(item.configId))
      unit.lab_source.text = Z.VMMgr.GetVM("items").ApplyItemNameWithQualityTag(item.configId)
      unit.lab_content.text = Lang("x", {
        val = item.count
      })
    end
  end
  if self.tagTimer_ then
    self.timerMgr:StopFrameTimer(self.tagTimer_)
    self.tagTimer_ = nil
  end
  self.tagTimer_ = self.timerMgr:StartFrameTimer(function()
    rollItem.node_item_layout:SetLayoutGroup()
  end, 1, 1)
end

function Hero_dungeon_tips_popupView:startSliderTime()
  self.slider_.fillAmount = 1
  local time = 0
  local nowColorIndex = 0
  self.time_ = self.timerMgr:StartFrameTimer(function()
    if self.slider_ then
      if time == 0 and nowColorIndex ~= 1 then
        nowColorIndex = 1
        self.slider_:SetColor(TimeSliderColor[1])
      elseif time >= self.limitTime_ / 2 and nowColorIndex ~= 2 and time < self.limitTime_ / 4 * 3 then
        nowColorIndex = 2
        self.slider_:SetColor(TimeSliderColor[2])
      elseif time >= self.limitTime_ / 4 * 3 and nowColorIndex ~= 3 then
        nowColorIndex = 3
        self.slider_:SetColor(TimeSliderColor[3])
      end
      time = time + Time.deltaTime
      self.slider_.fillAmount = 1 - time / self.limitTime_
      if time >= self.limitTime_ then
        self.parent_:StopTime(self.viewData)
        self.timerMgr:StopFrameTimer(self.time_)
        self.slider_.fillAmount = 0
        if not self.isRolling_ then
          self:isShowRollInfo(true)
        end
      end
    end
  end, 1, -1)
end

return Hero_dungeon_tips_popupView
