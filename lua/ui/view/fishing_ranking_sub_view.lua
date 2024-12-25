local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_ranking_subView = class("Fishing_ranking_subView", super)
local loopListView = require("ui.component.loop_list_view")
local fishingRankingFishLoopItem = require("ui.component.fishing.fishing_ranking_fish_loop_item")
local fishingRankingLoopItem = require("ui.component.fishing.fishing_ranking_player_loop_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Fishing_ranking_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_ranking_sub", "fishing/fishing_ranking_sub", UI.ECacheLv.None)
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.showWorld_ = true
  self.selectFishId_ = nil
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function Fishing_ranking_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:initLoopListView()
  self.uiBinder.tog_world:AddListener(function(ison)
    if ison then
      self:switchRightWorldRank()
    end
  end)
  self.uiBinder.tog_union:AddListener(function(ison)
    if ison then
      self:switchRightUnionRank()
    end
  end)
  self:AddClick(self.uiBinder.btn_union, function()
    self.unionVM_:OpenUnionMainView()
  end)
  self.selectArea_ = self.viewData.areaId
  self.reGetData_ = true
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnion, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.LeaveUnion, self.onLeaveUnion, self)
end

function Fishing_ranking_subView:OnDeActive()
  self:unInitLoopListView()
  self.rankDict_ = nil
end

function Fishing_ranking_subView:OnRefresh()
  self:resetTog()
  self:refreshLoopListView()
end

function Fishing_ranking_subView:resetTog()
  local togGroup_ = self.uiBinder.tog_union.group
  self.uiBinder.tog_union.group = nil
  self.uiBinder.tog_world.group = nil
  self.uiBinder.tog_union.isOn = false
  self.uiBinder.tog_world.isOn = false
  self.uiBinder.tog_union.isOn = not self.showWorld_
  self.uiBinder.tog_world.isOn = self.showWorld_
  self.uiBinder.tog_union.group = togGroup_
  self.uiBinder.tog_world.group = togGroup_
end

function Fishing_ranking_subView:onJoinUnion()
  self.reGetData_ = true
  self:OnRefresh()
end

function Fishing_ranking_subView:onLeaveUnion()
  self.reGetData_ = true
  self:OnRefresh()
end

function Fishing_ranking_subView:initLoopListView()
  self.loopListFish_ = loopListView.new(self, self.uiBinder.loop_list_fish, fishingRankingFishLoopItem, "fishing_ranking_list_tpl")
  self.loopListFish_:Init({})
  self.loopListPlayer_ = loopListView.new(self, self.uiBinder.loop_list_player, fishingRankingLoopItem, "fishing_ranking_synthesis_list_tpl")
  self.loopListPlayer_:Init({})
end

function Fishing_ranking_subView:refreshLoopListView()
  if self.reGetData_ then
    self:reGetRankData()
  else
    self:refreshUI()
  end
end

function Fishing_ranking_subView:reGetRankData()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  Z.CoroUtil.create_coro_xpcall(function()
    self.fishingVM_.GetFishingRankData(true, self.cancelSource:CreateToken())
    self.reGetData_ = false
    self:refreshUI()
  end)()
end

function Fishing_ranking_subView:refreshUI()
  local dataList_ = {}
  local rankDict = self.fishingData_:GetRankListByArea(self.selectArea_)
  local haveData_ = rankDict and table.zcount(rankDict) > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, haveData_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, not haveData_)
  if haveData_ then
    for k, v in pairs(rankDict) do
      local data_ = {
        fishId = k,
        rankData = v.worldRank[1]
      }
      table.insert(dataList_, data_)
    end
    self.loopListFish_:RefreshListView(dataList_)
    self.loopListFish_:ClearAllSelect()
    self.loopListFish_:SetSelected(1)
  end
end

function Fishing_ranking_subView:switchRightUnionRank()
  local haveUnion_ = self.unionVM_:GetPlayerUnionId() ~= 0
  self.showWorld_ = false
  if haveUnion_ then
    self:refreshRightRankListUI()
    self:refreshRightPlayerUI()
  else
    self.loopListPlayer_:RefreshListView({})
    self:refreshRightPlayerUI()
  end
  self:refreshUnionUI()
end

function Fishing_ranking_subView:refreshUnionUI()
  local haveUnion_ = self.unionVM_:GetPlayerUnionId() ~= 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, not self.showWorld_ and not haveUnion_)
  if self.selectFishId_ and not self.showWorld_ and haveUnion_ then
    local rankList = self.fishingData_:GetRankListByAreaAndFish(self.selectArea_, self.selectFishId_, false)
    local isEmpty = rankList == nil or table.zcount(rankList) == 0
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_union, isEmpty)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_union, false)
  end
end

function Fishing_ranking_subView:switchRightWorldRank()
  self.showWorld_ = true
  self:refreshRightRankListUI()
  self:refreshRightPlayerUI()
  self:refreshUnionUI()
end

function Fishing_ranking_subView:unInitLoopListView()
  self.loopListFish_:UnInit()
  self.loopListFish_ = nil
  self.loopListPlayer_:UnInit()
  self.loopListPlayer_ = nil
end

function Fishing_ranking_subView:OnClickRankItem(fishId)
  self.selectFishId_ = fishId
  self:refreshRightUI()
end

function Fishing_ranking_subView:refreshRightUI()
  self:refreshUnionUI()
  self:refreshRightPlayerUI()
  self:refreshRightRankListUI()
  self.uiBinder.rimg_icon:SetImage(self.fishingData_.FishRecordDict[self.selectFishId_].FishCfg.FishingIcon)
  self.uiBinder.rimg_mark:SetImage(self.fishingData_.FishRecordDict[self.selectFishId_].FishCfg.FishingIcon)
end

function Fishing_ranking_subView:refreshRightRankListUI()
  if self.selectFishId_ == nil then
    return
  end
  local rankList_ = self.fishingData_:GetRankListByAreaAndFish(self.selectArea_, self.selectFishId_, self.showWorld_)
  if rankList_ == nil then
    return
  end
  local dataList_ = {}
  for rank_, rankInfo_ in pairs(rankList_) do
    local data_ = {rank = rank_, rankData = rankInfo_}
    table.insert(dataList_, data_)
  end
  self.loopListPlayer_:RefreshListView(dataList_)
end

function Fishing_ranking_subView:refreshRightPlayerUI()
  if self.selectFishId_ == nil then
    return
  end
  local playerData_, rank_, isTop_ = self.fishingData_:GetPlayerRankByAreaAndFish(self.selectArea_, self.selectFishId_, self.showWorld_)
  self.uiBinder.node_player.Ref.UIComp:SetVisible(playerData_ ~= nil)
  if playerData_ == nil then
    return
  end
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.node_player.com_head_46_item, playerData_.playerData, nil)
  self.uiBinder.node_lv.Ref.UIComp:SetVisible(isTop_)
  self.uiBinder.node_normal.Ref.UIComp:SetVisible(not isTop_)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local canUseChat = gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, canUseChat and self.showWorld_)
  self.uiBinder.btn_share:RemoveAllListeners()
  self:AddClick(self.uiBinder.btn_share, function()
    self.fishingVM_.ShareRankToChat(self.selectFishId_, rank_, playerData_.size / 100)
  end)
  self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.img_bg, isTop_)
  if isTop_ then
    self.uiBinder.node_lv.img_bg:SetImage(self.fishingData_.RankPathDict[rank_])
    self.uiBinder.node_lv.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), playerData_.size / 100)
    self.uiBinder.node_lv.lab_name.text = playerData_.playerData.basicData.name
    self.uiBinder.node_lv.lab_digit.text = rank_
  else
    self.uiBinder.node_normal.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), playerData_.size / 100)
    self.uiBinder.node_normal.lab_name.text = playerData_.playerData.basicData.name
    self.uiBinder.node_normal.lab_digit.text = rank_
  end
end

return Fishing_ranking_subView
