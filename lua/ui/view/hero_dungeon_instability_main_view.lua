local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_instability_mainView = class("Hero_dungeon_instability_mainView", super)
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
local itemClass = require("common.item_binder")
local loopListView = require("ui.component.loop_list_view")
local affixLoopItem = require("ui.component.dungeon.dungeon_affix_loop_item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local keyItemID_ = Z.Global.HeroDungeonKeyId
local selectItemStr = {
  Lang("DungeonKeyNormal"),
  Lang("DungeonKeyDifficult"),
  Lang("DungeonKeyHard")
}
local goStr = Lang("GoCopy")
local keyStr = Lang("InsertHeroKey")

function Hero_dungeon_instability_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_instability_main")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.data_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.teamMainVm_ = Z.VMMgr.GetVM("team_main")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.matchTeamData = Z.DataMgr.Get("match_team_data")
  self.helpSysVm_ = Z.VMMgr.GetVM("helpsys")
end

function Hero_dungeon_instability_mainView:initBinders()
  self.sceneMask_ = self.uiBinder.scenemask
  self.labTitle_ = self.uiBinder.lab_title_left
  self.askBtn_ = self.uiBinder.btn_ask
  self.titleIcon_ = self.uiBinder.img_icon_left
  self.closeBtn_ = self.uiBinder.btn_close
  self.enterBtn_ = self.uiBinder.btn_go
  self.teamBtn_ = self.uiBinder.btn_team
  self.awardBtn_ = self.uiBinder.btn_box
  self.titleNmaeLab_ = self.uiBinder.lab_title_right
  self.labMark_ = self.uiBinder.lab_mark
  self.labTime_ = self.uiBinder.lab_time
  self.timeBtn_ = self.uiBinder.btn_time
  self.personLab_ = self.uiBinder.lab_person
  self.labDes_ = self.uiBinder.lab_content
  self.labAwardNum_ = self.uiBinder.lab_award_num
  self.togGrop_ = self.uiBinder.toggle_group
  self.togBinder_ = self.uiBinder.tog_uibinder
  self.digitTog_ = self.uiBinder.tog_digit
  self.teamTog_ = self.uiBinder.tog_team
  self.bgRimg_ = self.uiBinder.rimg_bg
  self.awardHintLab_ = self.uiBinder.lab_task_completion
  self.awardScrollView_ = self.uiBinder.scrollview_item
  self.affixNode_ = self.uiBinder.node_affix
  self.prefabCache_ = self.uiBinder.prefab_cache
  self.awardTitleNode_ = self.uiBinder.node_title
  self.firstNode_ = self.uiBinder.node_first
  self.firstTog_ = self.firstNode_.tog_first
  self.dropTog_ = self.firstNode_.tog_drop
  self.isLoadFinish_ = false
  local dataList = {}
  self.loopAffixList = loopListView.new(self, self.uiBinder.loop_affix, affixLoopItem, "hero_dungeon_affix_icon_tpl", true)
  self.loopAffixList:Init(dataList)
  self.matchBtn = self.uiBinder.btn_match
  self.unMatchBtn = self.uiBinder.btn_cancel_match
end

function Hero_dungeon_instability_mainView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseHeroInstabilityView()
  end)
  self:AddClick(self.matchBtn, function()
    if not self.toggleisTeam_ then
      Z.TipsVM.ShowTips(1000644)
      return
    end
    self.matchVm_.RequestBeginMatch(E.MatchType.Team, self.dungeonId_, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.unMatchBtn, function()
    self.matchVm_.AsyncCancelMatch()
  end)
  self.personNum_ = Z.Global.HeroNormalDungeonNumber
  self:AddClick(self.askBtn_, function()
    self.helpSysVm_.OpenFullScreenTipsView(30011)
  end)
  self:AddClick(self.firstTog_, function(isOn)
    if isOn and self.showFirstAward_ == false then
      self.showFirstAward_ = true
      if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
        self:createAwardItem(self.baseIsHaveAwardCount_)
      end
    end
  end)
  self:AddClick(self.dropTog_, function(isOn)
    if isOn and self.showFirstAward_ == true then
      self.showFirstAward_ = false
      if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
        self:createAwardItem(self.baseIsHaveAwardCount_)
      end
    end
  end)
  self:AddAsyncClick(self.enterBtn_, function()
    local count = table.zcount(self.teamData_.TeamInfo.members)
    local selectType = 2
    local keyUuid = 0
    local func = function()
      self.vm_.AsyncStartEnterDungeon(self.dungeonId_, self.vm_.GetAffix(self.dungeonId_), self.cancelSource, selectType, keyUuid)
    end
    if not self.data_.InstabilityIsTeam then
      local maxCount = self.maxLimit_
      if count > maxCount then
        Z.TipsVM.ShowTips(3333)
        return
      end
      if self.dungeonData_ and self.dungeonData_.SingleAiMode == 1 then
        selectType = 1
      end
    else
      local minCount = self.minLimit_
      if count < minCount then
        local str = Lang("UnionHuntMultiNumLimit")
        Z.DialogViewDataMgr:OpenNormalDialog(str, function()
          if self.teamVm_.CheckIsInTeam() then
            if self.teamVm_.GetYouIsLeader() then
              self.teamVm_.AsyncSetTeamTargetInfo(self.teamTargetId_, self.teamData_.TeamInfo.baseInfo.desc, true, self.teamData_.TeamInfo.baseInfo.hallShow, self.cancelSource:CreateToken())
            end
          else
            local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.teamTargetId_)
            if not teamTargetRow then
              return
            end
            self.matchVm_.RequestBeginMatch(E.MatchType.Team, teamTargetRow.RelativeDungeonId, self.cancelSource:CreateToken())
          end
          self.teamMainVm_.OpenTeamMainView(self.teamTargetId_)
        end)
        return
      end
    end
    func()
  end, nil, nil)
  self:AddClick(self.teamBtn_, function()
    self.teamMainVm_.OpenTeamMainView(self.teamTargetId_)
  end)
  self:AddClick(self.digitTog_, function(isOn)
    if isOn and self.toggleisTeam_ == true then
      self.toggleisTeam_ = false
      self.data_.InstabilityIsTeam = false
      self:getShowDungeonData()
      if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
        self:createAwardItem(self.baseIsHaveAwardCount_)
      end
      self:setPersonLab()
      local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
      self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
      self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch)
      self.uiBinder.Ref:SetVisible(self.unMatchBtn, false)
      self.matchBtn.IsDisabled = true
    end
  end)
  self:AddClick(self.teamTog_, function(isOn)
    if not Z.ConditionHelper.CheckCondition(self.dungeonData_.SingleAiCondition, true) then
      self.digitTog_.isOn = true
      return
    end
    if isOn then
      if self.toggleisTeam_ == false then
        self.toggleisTeam_ = true
        self.data_.InstabilityIsTeam = true
        self:getShowDungeonData()
        self:setPersonLab()
        if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
          self:createAwardItem(self.baseIsHaveAwardCount_)
        end
      end
      local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
      local isMatching = self.matchVm_.IsMatching()
      local curMatchingDungeonId = self.matchTeamData:GetCurMatchingDungeonId()
      self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
      self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and (not isMatching or curMatchingDungeonId ~= self.dungeonId_))
      self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and isMatching and curMatchingDungeonId == self.dungeonId_)
      self.matchBtn.IsDisabled = false
    end
  end)
  self:AddClick(self.uiBinder.btn_tab_02, function(isOn)
    if isOn then
      if not self.isLoadFinish_ then
        self:creatSelectItem()
      else
        self:selectedItem()
      end
    end
  end)
  self:AddClick(self.timeBtn_, function()
    local row = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
    if row then
      if row.LimitTime > 0 then
        self.helpSysVm_.OpenMinTips(30031, self.timeBtn_.transform)
      else
        self.helpSysVm_.OpenMinTips(30034, self.timeBtn_.transform)
      end
    end
  end)
end

function Hero_dungeon_instability_mainView:openKeyPopupView(limitedNum)
  local itemUuids = self.itemsData_:GetItemUuidsByConfigId(keyItemID_)
  local count = 0
  if itemUuids then
    count = table.zcount(itemUuids)
  end
  if 0 < count then
    self.vm_.OpenKeyPopupView(self.showDungeonRow_.LimitedNum)
  else
    local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(keyItemID_)
    if itemConfig then
      local param = {
        item = {
          name = itemConfig.Name
        }
      }
      Z.TipsVM.ShowTipsLang(1004106, param)
    end
    Z.TipsVM.OpenSourceTips(keyItemID_, self.enterBtn_.transform)
  end
end

function Hero_dungeon_instability_mainView:refreshUi()
  if not self.showDungeonRow_ then
    return
  end
  if self.normalHeroDungeonData_ then
    self.bgRimg_:SetImage(self.normalHeroDungeonData_.Background)
  end
  local conditionIds = self.showDungeonRow_.Condition
  local check = Z.ConditionHelper.CheckCondition(conditionIds)
  if check == false then
    local str = ""
    local r = Z.ConditionHelper.GetConditionDescList(conditionIds)
    for _, value in ipairs(r) do
      if value.IsUnlock == false then
        str = value.Desc
        break
      end
    end
    self.uiBinder.lab_locktime.text = str
  end
  self.uiBinder.Ref:SetVisible(self.enterBtn_, check)
  self.uiBinder.Ref:SetVisible(self.teamBtn_, check)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_day, not check)
end

function Hero_dungeon_instability_mainView:setLimit()
  if not self.showDungeonRow_ then
    return
  end
  local limtCount = Z.CounterHelper.GetCounterLimitCount(self.dungeonNormalCounterId_)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(self.dungeonNormalCounterId_, limtCount)
  self.labAwardNum_.text = Lang("HeroDungeonAwardTimes", {
    arrval = {normalAwardCount, limtCount}
  })
  self.isShowAward_ = 0 < normalAwardCount
end

function Hero_dungeon_instability_mainView:setPersonLab()
  local min = 0
  local max = 0
  if self.showDungeonRow_ then
    local limit = self.showDungeonRow_.LimitedNum
    min = limit[1]
    max = limit[2]
  end
  self.maxLimit_ = max
  self.minLimit_ = min
  local str = ""
  if max == min then
    str = string.format(Lang("DungeonSingelNum"), max)
  else
    str = string.format(Lang("DungeonNumber"), min, max)
  end
  self.personLab_.text = str
end

function Hero_dungeon_instability_mainView:selectedItem()
  local selectToggle = self.togItemList_[1]
  if selectToggle then
    if selectToggle.btn_select.isOn == true then
      self:OnSelectLeftItem(self.dungeonDataList_[2])
    else
      selectToggle.btn_select.isOn = true
    end
  end
end

function Hero_dungeon_instability_mainView:creatSelectItem()
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr")
  self.togItemList_ = {}
  local prefabPath = self.prefabCache_:GetString("select_item")
  if prefabPath and prefabPath ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      for key, value in pairs(self.dungeonDataList_) do
        if value.type == 2 then
          local itemName = "hero_select_item" .. key
          local item = self:AsyncLoadUiUnit(prefabPath, itemName, self.uiBinder.layout_select)
          local rowData = dungeonData.GetRow(value.dungeonID)
          local conditionIds = rowData.Condition
          local check = Z.ConditionHelper.CheckCondition(conditionIds)
          if check == false then
            local str = ""
            local r = Z.ConditionHelper.GetConditionDescList(conditionIds)
            for _, value in ipairs(r) do
              if value.IsUnlock == false then
                str = value.Desc
                break
              end
            end
            item.lab_name.text = str
          end
          item.Ref:SetVisible(item.node_lab, check == false)
          item.layout_lab.enabled = check == false
          item.lab_title.text = selectItemStr[key - 1]
          item.btn_select.group = self.uiBinder.tog_group_select
          self:AddClick(item.btn_select, function(isOn)
            if isOn then
              self:OnSelectLeftItem(value)
            end
          end)
          self.togItemList_[#self.togItemList_ + 1] = item
        end
      end
      self.isLoadFinish_ = true
      self:selectedItem()
    end)()
  end
end

function Hero_dungeon_instability_mainView:getCfgData()
  self.dungeonData_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
end

function Hero_dungeon_instability_mainView:initBaseData()
  local dungeonID = self.data_.ScenceId
  self.normalHeroDungeonData_ = Z.TableMgr.GetTable("NormalHeroDungeonTableMgr").GetRow(dungeonID)
  self.affixItemList_ = {}
  local list = {}
  local d = {type = 1, dungeonID = dungeonID}
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
  if dungeonData then
    self.dungeonNormalCounterId_ = dungeonData.CountLimit
  end
  list[#list + 1] = d
  for _, value in ipairs(self.normalHeroDungeonData_.DestinyDungeonId) do
    d = {
      type = 2,
      dungeonID = value[1]
    }
    list[#list + 1] = d
  end
  self.dungeonDataList_ = list
  self.toggleisTeam_ = true
  self:OnSelectLeftItem(self.dungeonDataList_[1])
  self.teamTog_.isOn = true
  self.showFirstAward_ = false
  self.firstTog_.isOn = false
end

function Hero_dungeon_instability_mainView:OnActive()
  self:initBinders()
  self:initBtns()
  self.itemClassTab_ = {}
  self.awardUnit_ = {}
  self.unitTokenDict_ = {}
  self.baseIsHaveAwardCount_ = true
  self:initBaseData()
  self:BindEvents()
end

function Hero_dungeon_instability_mainView:OnDeActive()
  self.data_:SetUseKeyData(0)
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.itemClassTab_ = nil
  Z.TipsVM.CloseItemTipsView(self.affixTipsId_)
  self.affixItemList_ = {}
  self.loopAffixList:UnInit()
  self.loopAffixList = nil
  self.helpSysVm_.CloseTitleContentBtn()
  self.toggleisTeam_ = true
  self.data_.InstabilityIsTeam = true
end

function Hero_dungeon_instability_mainView:OnRefresh()
end

function Hero_dungeon_instability_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.refreshMatchStatus, self)
end

function Hero_dungeon_instability_mainView:UnBindAllEvents()
  Z.EventMgr:Remove(Z.ConstValue.Match.MatchStateChange, self.refreshMatchStatus, self)
end

function Hero_dungeon_instability_mainView:refreshMatchStatus()
  local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
  local isMatching = self.matchVm_.IsMatching()
  local curMatchingDungeonId = self.matchTeamData:GetCurMatchingDungeonId()
  self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
  self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and (not isMatching or curMatchingDungeonId ~= self.dungeonId_))
  self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and isMatching and curMatchingDungeonId == self.dungeonId_)
end

function Hero_dungeon_instability_mainView:refreshTimeLab()
  local challengeCfg = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
  if challengeCfg.LimitTime <= 0 then
    self.labTime_.text = Lang("NoTimeLimit")
  else
    self.labTime_.text = Z.TimeFormatTools.FormatToDHMS(challengeCfg.LimitTime)
  end
end

function Hero_dungeon_instability_mainView:OnSelectLeftItem(data)
  self.dungeonId_ = data.dungeonID
  self:getCfgData()
  if self.dungeonData_ == nil then
    return logError("DungeonsTable is nil dungeonId = {0}", data.dungeonID)
  end
  self:getShowDungeonData()
  self:refreshTimeLab()
  self:refreshUi()
  self:setPersonLab()
  self:setLimit()
  self:createAwardItem(self.isShowAward_)
  self:createAffix()
  local isCanMatch = self.matchTeamVm_.IsShowMatchBtn(self.dungeonId_)
  local isMatching = self.matchVm_.IsMatching()
  local curMatchingDungeonID = self.matchTeamData:GetCurMatchingDungeonId()
  local curIsMatching = isMatching and curMatchingDungeonID == self.dungeonId_
  self.uiBinder.Ref:SetVisible(self.teamBtn_, not isCanMatch)
  self.uiBinder.Ref:SetVisible(self.matchBtn, isCanMatch and not curIsMatching)
  self.uiBinder.Ref:SetVisible(self.unMatchBtn, isCanMatch and curIsMatching)
end

function Hero_dungeon_instability_mainView:getShowDungeonData()
  self.showDungeonRow_ = nil
  self.showDungeonId_ = self.dungeonId_
  if not self.data_.InstabilityIsTeam and self.dungeonData_.SingleModeDungeonId ~= 0 then
    self.showDungeonId_ = self.dungeonData_.SingleModeDungeonId
  end
  self.showDungeonRow_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.showDungeonId_)
  self.teamTargetId_ = self.teamMainVm_.GetTargetIdByDungeonId(self.showDungeonId_)
  self:setLab()
  self.isComplete_ = self.vm_.CheckDungeonIsComplete(self.showDungeonId_)
  if self.isComplete_ or #self.showDungeonRow_.FirstPassAward == 0 then
    self.dropTog_.isOn = true
  end
  self.firstNode_.Ref.UIComp:SetVisible(not self.isComplete_ and 0 < #self.showDungeonRow_.FirstPassAward)
  self.uiBinder.Ref:SetVisible(self.awardTitleNode_, self.isComplete_ or #self.showDungeonRow_.FirstPassAward == 0)
end

function Hero_dungeon_instability_mainView:setLab()
  if not self.showDungeonRow_ then
    return
  end
  self.labTitle_.text = self.showDungeonRow_.Name
  if self.showDungeonRow_.RecommendFightValue == 0 then
    self.labMark_.text = Lang("GSSuggestNoLimit")
  else
    local param = {
      val = self.showDungeonRow_.RecommendFightValue
    }
    self.labMark_.text = Lang("GSSuggest", param)
  end
  self.titleNmaeLab_.text = self.showDungeonRow_.Name
  self.labDes_.text = self.showDungeonRow_.Content
end

function Hero_dungeon_instability_mainView:createAwardItem(isHaveAward)
  self.baseIsHaveAwardCount_ = isHaveAward
  local awardId
  if isHaveAward and self.showDungeonRow_ then
    awardId = self.showDungeonRow_.PassAward
    if not self.isComplete_ and self.showFirstAward_ and #self.showDungeonRow_.FirstPassAward ~= 0 then
      awardId = self.showDungeonRow_.FirstPassAward
    end
  end
  local awardList = {}
  if awardId then
    awardList = awardPreviewVm.GetAllAwardPreListByIds(awardId) or {}
  end
  if #awardList == 0 and self.showDungeonRow_.ExtraAward and self.showDungeonRow_.ExtraAward ~= 0 then
    awardList = awardPreviewVm.GetAllAwardPreListByIds(self.showDungeonRow_.ExtraAward) or {}
  end
  if not isHaveAward and self.showDungeonRow_.ExtraAward == 0 then
    self.data_.IsHaveAward = false
  else
    self.data_.IsHaveAward = true
  end
  self.uiBinder.Ref:SetVisible(self.awardHintLab_, #awardList == 0)
  for unitName, unit in pairs(self.awardUnit_) do
    self:RemoveUiUnit(unitName)
    self.itemClassTab_[unitName]:UnInit()
  end
  for unitName, unitToken in pairs(self.unitTokenDict_) do
    Z.CancelSource.ReleaseToken(unitToken)
  end
  self.awardUnit_ = {}
  self.unitTokenDict_ = {}
  self.itemClassTab_ = {}
  if 0 < #awardList then
    local prefabPath = self.prefabCache_:GetString("item")
    if prefabPath and prefabPath ~= "" then
      Z.CoroUtil.create_coro_xpcall(function()
        for key, value in ipairs(awardList) do
          local itemName = "hero_award_item" .. key
          local unitToken = self.cancelSource:CreateToken()
          self.unitTokenDict_[itemName] = unitToken
          local item = self:AsyncLoadUiUnit(prefabPath, itemName, self.awardScrollView_.content.transform, unitToken)
          self.itemClassTab_[itemName] = itemClass.new(self)
          self.awardUnit_[itemName] = item
          local itemData = {
            uiBinder = item,
            configId = value.awardId,
            isSquareItem = true,
            PrevDropType = value.PrevDropType,
            dungeonId = self.dungonId_,
            isShowFirstNode = self.showFirstAward_
          }
          itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
          self.itemClassTab_[itemName]:Init(itemData)
        end
      end)()
    end
  end
end

function Hero_dungeon_instability_mainView:createAffix()
  local dungeon_data = Z.DataMgr.Get("dungeon_data")
  local affixMgr = Z.TableMgr.GetTable("AffixTableMgr")
  local dungeonAffix = dungeon_data:GetDungeonAffixDic(self.dungeonId_)
  local affixList
  local dataList = {}
  local dataListIndex = 0
  if dungeonAffix then
    affixList = dungeonAffix.affixes
  end
  if affixList then
    for _, value in ipairs(affixList) do
      local config = affixMgr.GetRow(value)
      if config and config.IsShowUI then
        local d = {isKey = false, affixId = value}
        dataListIndex = dataListIndex + 1
        dataList[dataListIndex] = d
      end
    end
  end
  local dungeonConfig = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  if dungeonConfig then
    for _, value in ipairs(dungeonConfig.Affix) do
      local config = affixMgr.GetRow(value)
      if config and config.IsShowUI then
        local d = {isKey = false, affixId = value}
        dataListIndex = dataListIndex + 1
        dataList[dataListIndex] = d
      end
    end
  end
  local keyUuid = 0
  if keyUuid and 0 < keyUuid then
    local itemInfo = self.itemsVM_.GetItemInfo(keyUuid, E.BackPackItemPackageType.Item)
    if itemInfo then
      local affix = itemInfo.affixData.affixIds
      for _, value in ipairs(affix) do
        local config = affixMgr.GetRow(value)
        if config and config.IsShowUI then
          local d = {isKey = true, affixId = value}
          dataListIndex = dataListIndex + 1
          dataList[dataListIndex] = d
        end
      end
    end
  end
  table.sort(dataList, function(a, b)
    return a.affixId < b.affixId
  end)
  self.loopAffixList:RefreshListView(dataList, false)
end

return Hero_dungeon_instability_mainView
