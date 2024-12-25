local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_score_popup = class("Hero_dungeon_score_popup", super)
local itemClass = require("common.item")

function Hero_dungeon_score_popup:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_score_popup")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function Hero_dungeon_score_popup:OnActive()
  self:initWidgets()
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.itemClassTab_ = {}
  self.scoreAwards = {}
  self:initItem()
end

function Hero_dungeon_score_popup:initWidgets()
  self.close_ = self.uiBinder.cont_tab_popup.cont_close
  self.content_award_ = self.uiBinder.content_award
  self.btn_receive_ = self.uiBinder.btn_receive
  self.scenemask_ = self.uiBinder.cont_tab_popup.scenemask
  self.canRewards_ = self.vm_.GetCanRewards(self.viewData.DungeonId)
  self.btn_receive_.IsDisabled = #self.canRewards_ == 0
  self:AddAsyncClick(self.close_, function()
    self.vm_.CloseScorePopupView()
  end)
  self:AddAsyncClick(self.btn_receive_, function()
    if #self.canRewards_ == 0 then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      for i, v in ipairs(self.canRewards_) do
        self.vm_.AsyncGetAward(self.viewData.DungeonId, v, self.cancelSource)
      end
      self:initItem()
      self.vm_.RefreshRed(self.viewData.DungeonId)
      self.canRewards_ = self.vm_.GetCanRewards(self.viewData.DungeonId)
      self.btn_receive_.IsDisabled = #self.canRewards_ == 0
    end)()
  end)
end

function Hero_dungeon_score_popup:initItem()
  local prefabPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "item")
  if prefabPath == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.scoreItemList_ = self.scoreItemList_ or {}
    for i, v in ipairs(self.viewData.ScoreAward) do
      local item = self.scoreItemList_[i]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "scoreItem" .. i, self.content_award_)
        self.scoreItemList_[i] = item
      end
      self:refreshItem(item, v)
      item.Ref.UIComp:SetVisible(true)
    end
    for i = #self.viewData.ScoreAward + 1, #self.scoreItemList_ do
      if self.scoreItemList_[i] then
        self.scoreItemList_[i]:SetVisible(false)
      end
    end
  end)()
end

function Hero_dungeon_score_popup:refreshItem(unit, award)
  local targetInfo = Z.TableMgr.GetTable("TargetTableMgr").GetRow(award[1])
  if targetInfo then
    unit.lab_description.text = targetInfo.TargetDes
  end
  local score = self.vm_.GetHighestScore(self.viewData.DungeonId) or 0
  local awardState = 0
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[self.viewData.DungeonId]
  if dungeonInfo then
    local targetDataDic = dungeonInfo.dungeonTargetProgress[targetInfo.Id]
    if targetDataDic then
      awardState = targetDataDic.awardState
      score = targetDataDic.targetProgress
    end
  end
  local targetScore = targetInfo.Num
  unit.lab_pace.text = string.format("%d/%d", score, targetScore)
  unit.Ref:SetVisible(unit.lab_no, awardState == E.DrawState.NoDraw)
  unit.Ref:SetVisible(unit.img_reached, awardState == E.DrawState.AlreadyDraw)
  unit.Ref:SetVisible(unit.img_sah, awardState == E.DrawState.AlreadyDraw)
  unit.Ref:SetVisible(unit.btn_receive, awardState == E.DrawState.CanDraw)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(award[2])
  self:initAward(targetInfo.Id, awardList, unit.content)
  self:AddClick(unit.btn_receive, function()
    if awardState ~= E.DrawState.CanDraw then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local ret = self.vm_.AsyncGetAward(self.viewData.DungeonId, award[1], self.cancelSource)
      if ret == 0 then
        unit.Ref:SetVisible(unit.img_reached, true)
        unit.Ref:SetVisible(unit.img_sah, true)
        unit.Ref:SetVisible(unit.btn_receive, false)
        self.vm_.RefreshRed(self.viewData.DungeonId)
        self.canRewards_ = self.vm_.GetCanRewards(self.viewData.DungeonId)
        self.btn_receive_.IsDisabled = #self.canRewards_ == 0
      end
    end)()
  end)
end

function Hero_dungeon_score_popup:initAward(targetId, awardList, parent)
  local prefabPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "awardListItemPath")
  if prefabPath == nil then
    return
  end
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  Z.CoroUtil.create_coro_xpcall(function()
    self.awardItemList_ = self.awardItemList_ or {}
    if not self.awardItemList_[targetId] then
      self.awardItemList_[targetId] = {}
    end
    for i, v in ipairs(awardList) do
      self.itemClassTab_[i] = itemClass.new(self)
      local item = self.awardItemList_[targetId][i]
      if not item then
        item = self:AsyncLoadUiUnit(prefabPath, "awardItem" .. targetId .. i, parent)
        self.awardItemList_[targetId][i] = item
      end
      local itemPreviewData = {
        unit = item,
        configId = v.awardId,
        isSquareItem = true,
        PrevDropType = v.PrevDropType
      }
      itemPreviewData.labType, itemPreviewData.lab = awardPreviewVm.GetPreviewShowNum(v)
      self.itemClassTab_[i]:Init(itemPreviewData)
      item:SetVisible(true)
    end
    for i = #awardList + 1, #self.awardItemList_[targetId] do
      if self.awardItemList_[targetId][i] then
        self.awardItemList_[targetId][i]:SetVisible(false)
      end
    end
  end)()
end

function Hero_dungeon_score_popup:OnDeActive()
  self.scoreItemList_ = nil
  self.awardItemList_ = nil
  for index, value in pairs(self.itemClassTab_) do
    value:UnInit()
  end
  self.itemClassTab_ = {}
end

function Hero_dungeon_score_popup:OnRefresh()
end

return Hero_dungeon_score_popup
