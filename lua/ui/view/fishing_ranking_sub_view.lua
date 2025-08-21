local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_ranking_subView = class("Fishing_ranking_subView", super)
local loopListView = require("ui.component.loop_list_view")
local fishingRankingFishLoopItem = require("ui.component.fishing.fishing_ranking_fish_loop_item")
local fishingRankingLoopItem = require("ui.component.fishing.fishing_ranking_player_loop_item")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Fishing_ranking_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "fishing_ranking_sub", "fishing/fishing_ranking_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "fishing_ranking_sub", "fishing/fishing_ranking_sub", UI.ECacheLv.None)
  end
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.showWorld_ = true
  self.selectFishId_ = nil
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Fishing_ranking_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:onStartAnimShow()
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
  self:AddAsyncClick(self.uiBinder.node_normal.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick(Z.EntityMgr.PlayerEnt.EntId)
  end)
  self:AddAsyncClick(self.uiBinder.node_normal.btn_qqprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.node_lv.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick(Z.EntityMgr.PlayerEnt.EntId)
  end)
  self:AddAsyncClick(self.uiBinder.node_lv.btn_qqprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_ranking, function()
    self.fishingVM_.OpenRankingAwardPopup(self.selectFishId_, self.showWorld_)
  end)
  self.selectArea_ = self.viewData.areaId
  self.rankInfo_ = {}
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnion, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.LeaveUnion, self.onLeaveUnion, self)
end

function Fishing_ranking_subView:OnDeActive()
  self:unInitLoopListView()
  self.rankInfo_ = {}
  self.selectFishId_ = nil
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
  self:OnRefresh()
end

function Fishing_ranking_subView:onLeaveUnion()
  self:OnRefresh()
end

function Fishing_ranking_subView:initLoopListView()
  if Z.IsPCUI then
    self.loopListFish_ = loopListView.new(self, self.uiBinder.loop_list_fish, fishingRankingFishLoopItem, "fishing_ranking_list_tpl_pc")
  else
    self.loopListFish_ = loopListView.new(self, self.uiBinder.loop_list_fish, fishingRankingFishLoopItem, "fishing_ranking_list_tpl")
  end
  self.loopListFish_:Init({})
  if Z.IsPCUI then
    self.loopListPlayer_ = loopListView.new(self, self.uiBinder.loop_list_player, fishingRankingLoopItem, "fishing_ranking_synthesis_list_tpl_pc")
  else
    self.loopListPlayer_ = loopListView.new(self, self.uiBinder.loop_list_player, fishingRankingLoopItem, "fishing_ranking_synthesis_list_tpl")
  end
  self.loopListPlayer_:Init({})
end

function Fishing_ranking_subView:refreshLoopListView()
  if self.rankInfo_[self.selectArea_] == nil or self.rankInfo_[self.selectArea_].TopInfo == nil then
    self:getRankTopInfo()
  else
    self:refreshUI()
  end
end

function Fishing_ranking_subView:getRankTopInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  Z.CoroUtil.create_coro_xpcall(function()
    self.rankInfo_[self.selectArea_] = {}
    self.rankInfo_[self.selectArea_].TopInfo = self.fishingVM_.AsyncGetFishingRankTop(self.selectArea_, self.cancelSource:CreateToken())
    self:refreshUI()
  end)()
end

function Fishing_ranking_subView:refreshUI()
  if self.rankInfo_[self.selectArea_] == nil or self.rankInfo_[self.selectArea_].TopInfo == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
    local fishingTableMgr = Z.TableMgr.GetTable("FishingTableMgr")
    local dataList = {}
    local dataListIndex = 0
    for k, v in pairs(self.rankInfo_[self.selectArea_].TopInfo) do
      local config = fishingTableMgr.GetRow(k)
      if v.playerData ~= nil and config and config.Type ~= E.FishingFishType.Halobios then
        local data = {fishId = k, rankData = v}
        dataListIndex = dataListIndex + 1
        dataList[dataListIndex] = data
      end
    end
    if 0 < dataListIndex then
      self.loopListFish_:RefreshListView(dataList)
      self.loopListFish_:ClearAllSelect()
      self.loopListFish_:SetSelected(1)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_synthesis, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
    end
  end
end

function Fishing_ranking_subView:switchRightUnionRank()
  self.showWorld_ = false
  if self.selectFishId_ ~= nil and (self.rankInfo_[self.selectArea_][self.selectFishId_] == nil or self.rankInfo_[self.selectArea_][self.selectFishId_].UnionRankList == nil) then
    Z.CoroUtil.create_coro_xpcall(function()
      local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
      if rankInfo == nil then
        rankInfo = {}
      end
      rankInfo.UnionRankList = self.fishingVM_.AsyncGetFishingRankData(self.selectFishId_, E.FishingRankType.Union, self.cancelSource:CreateToken())
      if rankInfo.UnionRankList and rankInfo.UnionRankList.rankList then
        self.fishingData_:SortRankList(rankInfo.UnionRankList.rankList)
      end
      self.rankInfo_[self.selectArea_][self.selectFishId_] = rankInfo
      self:switchUnionRefresh()
    end)()
  else
    self:switchUnionRefresh()
  end
end

function Fishing_ranking_subView:switchUnionRefresh()
  local haveUnion_ = self.unionVM_:GetPlayerUnionId() ~= 0
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
    local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
    if rankInfo == nil or rankInfo.UnionRankList == nil or table.zcount(rankInfo.UnionRankList) == 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_union, true)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_union, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_union, false)
  end
end

function Fishing_ranking_subView:switchRightWorldRank()
  self.showWorld_ = true
  if self.selectFishId_ ~= nil and (self.rankInfo_[self.selectArea_][self.selectFishId_] == nil or self.rankInfo_[self.selectArea_][self.selectFishId_].WorldRankList == nil) then
    Z.CoroUtil.create_coro_xpcall(function()
      local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
      if rankInfo == nil then
        rankInfo = {}
      end
      rankInfo.WorldRankList = self.fishingVM_.AsyncGetFishingRankData(self.selectFishId_, E.FishingRankType.World, self.cancelSource:CreateToken())
      if rankInfo.WorldRankList and rankInfo.WorldRankList.rankList then
        self.fishingData_:SortRankList(rankInfo.WorldRankList.rankList)
      end
      self.rankInfo_[self.selectArea_][self.selectFishId_] = rankInfo
      self:refreshRightRankListUI()
      self:refreshRightPlayerUI()
      self:refreshUnionUI()
    end)()
  else
    self:refreshRightRankListUI()
    self:refreshRightPlayerUI()
    self:refreshUnionUI()
  end
end

function Fishing_ranking_subView:unInitLoopListView()
  self.loopListFish_:UnInit()
  self.loopListFish_ = nil
  self.loopListPlayer_:UnInit()
  self.loopListPlayer_ = nil
end

function Fishing_ranking_subView:OnClickRankItem(fishId)
  self.selectFishId_ = fishId
  local fishingRankAwardTableRow = Z.TableMgr.GetTable("FishingRankAwardTableMgr").GetRow(self.selectFishId_, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ranking, fishingRankAwardTableRow ~= nil)
  local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
  if self.showWorld_ then
    if rankInfo == nil or rankInfo.WorldRankList == nil then
      Z.CoroUtil.create_coro_xpcall(function()
        if rankInfo == nil then
          rankInfo = {}
        end
        rankInfo.WorldRankList = self.fishingVM_.AsyncGetFishingRankData(self.selectFishId_, E.FishingRankType.World, self.cancelSource:CreateToken())
        if rankInfo.WorldRankList and rankInfo.WorldRankList.rankList then
          self.fishingData_:SortRankList(rankInfo.WorldRankList.rankList)
        end
        self.rankInfo_[self.selectArea_][self.selectFishId_] = rankInfo
        self:refreshRightUI()
      end)()
    else
      self:refreshRightUI()
    end
  elseif rankInfo == nil or rankInfo.UnionRankList == nil then
    Z.CoroUtil.create_coro_xpcall(function()
      if rankInfo == nil then
        rankInfo = {}
      end
      rankInfo.UnionRankList = self.fishingVM_.AsyncGetFishingRankData(self.selectFishId_, E.FishingRankType.Union, self.cancelSource:CreateToken())
      if rankInfo.UnionRankList and rankInfo.UnionRankList.rankList then
        self.fishingData_:SortRankList(rankInfo.UnionRankList.rankList)
      end
      self.rankInfo_[self.selectArea_][self.selectFishId_] = rankInfo
      self:refreshRightUI()
    end)()
  else
    self:refreshRightUI()
  end
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
  local rankList = {}
  local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
  if self.showWorld_ then
    if rankInfo.WorldRankList and rankInfo.WorldRankList.rankList then
      rankList = rankInfo.WorldRankList.rankList
    end
  elseif rankInfo.UnionRankList and rankInfo.UnionRankList.rankList then
    rankList = rankInfo.UnionRankList.rankList
  end
  if rankList == nil then
    self.loopListPlayer_:RefreshListView({})
    return
  end
  local dataList = {}
  for rank, rankInfo in pairs(rankList) do
    local data_ = {rank = rank, rankData = rankInfo}
    table.insert(dataList, data_)
  end
  self.loopListPlayer_:RefreshListView(dataList)
end

function Fishing_ranking_subView:refreshRightPlayerUI()
  if self.selectFishId_ == nil then
    self.uiBinder.node_player.Ref.UIComp:SetVisible(false)
    return
  end
  local playerData
  local rankList = {}
  local rankInfo = self.rankInfo_[self.selectArea_][self.selectFishId_]
  if self.showWorld_ then
    if rankInfo and rankInfo.WorldRankList then
      playerData = rankInfo.WorldRankList.selfInfo
      rankList = rankInfo.WorldRankList.rankList
    end
  elseif rankInfo and rankInfo.UnionRankList then
    playerData = rankInfo.UnionRankList.selfInfo
    rankList = rankInfo.UnionRankList.rankList
  end
  if playerData == nil or playerData.millisecond == 0 and playerData.size == 0 then
    self.uiBinder.node_player.Ref.UIComp:SetVisible(false)
    return
  end
  self.uiBinder.node_player.Ref.UIComp:SetVisible(true)
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.node_player.com_head_46_item, playerData.playerData, nil, self.cancelSource:CreateToken())
  local rank, isTop = self:getSelfInRank(playerData, rankList)
  self.uiBinder.node_lv.Ref.UIComp:SetVisible(isTop)
  self.uiBinder.node_normal.Ref.UIComp:SetVisible(not isTop)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local canUseChat = gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, canUseChat and self.showWorld_)
  self.uiBinder.btn_share:RemoveAllListeners()
  self:AddClick(self.uiBinder.btn_share, function()
    self.fishingVM_.ShareRankToChat(self.selectFishId_, rank, playerData.size / 100)
  end)
  self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.img_bg, isTop)
  if isTop then
    self.uiBinder.node_lv.img_bg:SetImage(self.fishingData_.RankPathDict[rank])
    self.uiBinder.node_lv.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), playerData.size / 100)
    self.uiBinder.node_lv.lab_name.text = playerData.playerData.basicData.name
    self.uiBinder.node_lv.lab_digit.text = rank
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_wechatprivilege, false)
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_qqprivilege, false)
    local accountData = Z.DataMgr.Get("account_data")
    if accountData.LoginType == E.LoginType.QQ then
      self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_qqprivilege, self.sdkVM_.IsShowPrivilege())
    elseif accountData.LoginType == E.LoginType.WeChat then
      self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.btn_wechatprivilege, self.sdkVM_.IsShowPrivilege())
    end
    self.uiBinder.node_lv.Ref:SetVisible(self.uiBinder.node_lv.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(playerData.playerData.basicData.isNewbie))
  else
    self.uiBinder.node_normal.lab_size.text = string.format(Lang("FishingSettlementLengthUnit"), playerData.size / 100)
    self.uiBinder.node_normal.lab_name.text = playerData.playerData.basicData.name
    self.uiBinder.node_normal.lab_digit.text = rank
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.btn_wechatprivilege, false)
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.node_qqprivilege, false)
    local accountData = Z.DataMgr.Get("account_data")
    if accountData.LoginType == E.LoginType.QQ then
      self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.node_qqprivilege, self.sdkVM_.IsShowPrivilege())
    elseif accountData.LoginType == E.LoginType.WeChat then
      self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.btn_wechatprivilege, self.sdkVM_.IsShowPrivilege())
    end
    self.uiBinder.node_normal.Ref:SetVisible(self.uiBinder.node_normal.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(playerData.playerData.basicData.isNewbie))
  end
end

function Fishing_ranking_subView:getSelfInRank(selfPlayerData, rankList)
  local rankStr = Z.Global.FishTopN .. "+"
  local isTop = false
  if #rankList == 0 then
    return
  end
  for index, v in ipairs(rankList) do
    if v.playerData.basicData.charID == selfPlayerData.playerData.basicData.charID then
      rankStr = index
      isTop = index <= 3
      break
    end
  end
  return rankStr, isTop
end

function Fishing_ranking_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Fishing_ranking_subView
