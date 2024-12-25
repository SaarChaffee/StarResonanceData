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
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemsData_ = Z.DataMgr.Get("items_data")
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
  self.isBase_ = true
  self.isLoadFinish_ = false
  local dataList = {}
  self.loopAffixList = loopListView.new(self, self.uiBinder.loop_affix, affixLoopItem, "hero_dungeon_affix_icon_tpl")
  self.loopAffixList:Init(dataList)
end

function Hero_dungeon_instability_mainView:initBtns()
  self.personNum_ = Z.Global.HeroNormalDungeonNumber
  self:AddClick(self.askBtn_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30011)
  end)
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseHeroInstabilityView()
  end)
  self:AddAsyncClick(self.enterBtn_, function()
    if self.canUseKey_ and self.hasUseKey_ == false then
      self:openKeyPopupView(self.dungeonData_.LimitedNum)
      return
    end
    local count = table.zcount(self.teamData_.TeamInfo.members)
    local selectType = 2
    local keyUuid = 0
    if self.canUseKey_ then
      keyUuid = self.data_:GetUseKeyData()
    end
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
        local str = self.canUseKey_ == true and Lang("HeroKeyTeamMemberLimit") or Lang("UnionHuntMultiNumLimit")
        Z.DialogViewDataMgr:OpenNormalDialog(str, function()
          Z.CoroUtil.create_coro_xpcall(function()
            if self.teamVm_.CheckIsInTeam() then
              if self.teamVm_.GetYouIsLeader() then
                self.teamVm_.AsyncSetTeamTargetInfo(self.teamTargetId_, self.teamData_.TeamInfo.baseInfo.desc, true, self.teamData_.TeamInfo.baseInfo.hallShow, self.cancelSource:CreateToken())
              end
            else
              local requestParam = {}
              requestParam.targetId = self.teamTargetId_
              requestParam.checkTags = {}
              requestParam.wantLeader = 1
              self.matchVm_.AsyncBeginMatchNew(E.MatchType.Team, requestParam, false, self.cancelSource:CreateToken())
              self.matchVm_.SetSelfMatchData(self.teamTargetId_, "targetId")
            end
            self.teamMainVm_.OpenTeamMainView(self.teamTargetId_)
          end)()
          Z.DialogViewDataMgr:CloseDialogView()
        end)
        return
      end
    end
    if self.canUseKey_ then
      local limitID = Z.Global.KeyRewardLimitId
      local limtCount = Z.CounterHelper.GetCounterLimitCount(limitID)
      local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(limitID, limtCount)
      if normalAwardCount <= 0 then
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("HeroRollKeyAwardLimit"), function()
          func()
          Z.DialogViewDataMgr:CloseDialogView()
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
    if isOn then
      self.toggleisTeam_ = false
      self.data_.InstabilityIsTeam = false
      if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
        self:setLab(self.dungeonData_.SingleModeDungeonId)
        self:creatAwardItem(self.baseIsHaveAwardCount_)
      end
      self:setPersonLab()
    end
  end)
  self:AddClick(self.teamTog_, function(isOn)
    if isOn then
      self.toggleisTeam_ = true
      self.data_.InstabilityIsTeam = true
      self:setLab(self.dungeonId_)
      self:setPersonLab()
      if self.dungeonData_ and self.dungeonData_.SingleModeDungeonId ~= 0 then
        self:creatAwardItem(self.baseIsHaveAwardCount_)
      end
    end
  end)
  self.uiBinder.btn_tab_01.group = self.uiBinder.group_tab
  self.uiBinder.btn_tab_02.group = self.uiBinder.group_tab
  self:AddClick(self.uiBinder.btn_tab_01, function(isOn)
    if isOn then
      self.isBase_ = true
      self:OnSelectLeftItem(self.dungeonDataList_[1])
    else
      self.isBase_ = false
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
        Z.VMMgr.GetVM("helpsys").OpenMinTips(30031, self.timeBtn_.transform)
      else
        Z.VMMgr.GetVM("helpsys").OpenMinTips(30034, self.timeBtn_.transform)
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
    self.vm_.OpenKeyPopupView(self.dungeonData_.LimitedNum)
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

function Hero_dungeon_instability_mainView:setLab(dungeeonid)
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeeonid)
  self.teamTargetId_ = self.teamMainVm_.GetTargetIdByDungeonId(dungeeonid)
  if not dungeonData then
    return
  end
  self.labTitle_.text = dungeonData.Name
  if dungeonData.RecommendFightValue == 0 then
    self.labMark_.text = Lang("GSSuggestNoLimit")
  else
    local param = {
      val = dungeonData.RecommendFightValue
    }
    self.labMark_.text = Lang("GSSuggest", param)
  end
  self.titleNmaeLab_.text = dungeonData.Name
  self.labDes_.text = dungeonData.Content
end

function Hero_dungeon_instability_mainView:initUi()
  if not self.dungeonData_ then
    return
  end
  self:setLab(self.dungeonId_)
  if self.normalHeroDungeonData_ then
    self.bgRimg_:SetImage(self.normalHeroDungeonData_.Background)
  end
  local conditionIds = self.dungeonData_.Condition
  local check = Z.ConditionHelper.CheckCondition(conditionIds)
  local progress = 0
  if check == false then
    local str = ""
    local r = Z.ConditionHelper.GetConditionDescList(conditionIds)
    for _, value in ipairs(r) do
      if value.IsUnlock == false then
        str = value.Desc
        progress = value.Progress
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
  if not self.dungeonData_ then
    return
  end
  local limtCount = Z.CounterHelper.GetCounterLimitCount(self.dungeonNormalCounterId_)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(self.dungeonNormalCounterId_, limtCount)
  self.labAwardNum_.text = Lang("HeroDungeonAwardTimes", {
    arrval = {normalAwardCount, limtCount}
  })
  self:creatAwardItem(0 < normalAwardCount)
  local limitID = Z.Global.KeyRewardLimitId
  limtCount = Z.CounterHelper.GetCounterLimitCount(limitID)
  normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(limitID, limtCount)
  limitID = Z.Global.RollRewardLimitId
  limtCount = Z.CounterHelper.GetCounterLimitCount(limitID)
  normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(limitID, limtCount)
end

function Hero_dungeon_instability_mainView:setPersonLab()
  local min = 0
  local max = 0
  if self.canUseKey_ == false then
    if self.personNum_ then
      if self.data_.InstabilityIsTeam then
        min = self.personNum_[2][1]
        max = self.personNum_[2][2]
      else
        min = self.personNum_[1][1]
        max = self.personNum_[1][2]
      end
    end
  elseif self.dungeonData_ then
    local limit = self.dungeonData_.LimitedNum
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

function Hero_dungeon_instability_mainView:creatAwardItem(isHaveAward)
  self.baseIsHaveAwardCount_ = isHaveAward
  local awardId
  if not self.isBase_ then
    local destinyDungeonAwardRow = Z.TableMgr.GetRow("NormalHeroDestinyDungeonAwardMgr", self.dungeonId_)
    if destinyDungeonAwardRow then
      awardId = destinyDungeonAwardRow.KeyReward[1] or {}
    end
  elseif isHaveAward then
    if not self.data_.InstabilityIsTeam and self.dungeonData_.SingleModeDungeonId ~= 0 then
      local dungeonRow = Z.TableMgr.GetRow("DungeonsTableMgr", self.dungeonData_.SingleModeDungeonId)
      if dungeonRow then
        awardId = dungeonRow.PassAward[1]
      end
    else
      awardId = self.dungeonData_.PassAward[1]
    end
  end
  local awardList = {}
  if awardId then
    awardList = awardPreviewVm.GetAllAwardPreListByIds(awardId) or {}
  end
  if self.isBase_ and #awardList == 0 and self.dungeonData_.ExtraAward and self.dungeonData_.ExtraAward ~= 0 then
    awardList = awardPreviewVm.GetAllAwardPreListByIds(self.dungeonData_.ExtraAward) or {}
  end
  if not isHaveAward and self.isBase_ and self.dungeonData_.ExtraAward == 0 then
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
            dungeonId = self.dungonId_
          }
          itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(value)
          self.itemClassTab_[itemName]:Init(itemData)
        end
      end)()
    end
  end
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

function Hero_dungeon_instability_mainView:creatAffix()
  local dungeon_data = Z.DataMgr.Get("dungeon_data")
  local dungeonAffix = dungeon_data:GetDungeonAffixDic(self.dungeonId_)
  local affixList
  local dataList = {}
  if dungeonAffix then
    affixList = dungeonAffix.affixes
  end
  if affixList then
    for _, value in ipairs(affixList) do
      local d = {}
      d.isKey = false
      d.affixId = value
      dataList[#dataList + 1] = d
    end
  end
  local keyUuid = 0
  if self.canUseKey_ then
    keyUuid = self.data_:GetUseKeyData()
  end
  if keyUuid and 0 < keyUuid then
    local itemInfo = self.itemsVM_.GetItemInfo(keyUuid, E.BackPackItemPackageType.Item)
    if itemInfo then
      local affix = itemInfo.affixData.affixIds
      for _, value in ipairs(affix) do
        local d = {}
        d.isKey = true
        d.affixId = value
        dataList[#dataList + 1] = d
      end
    end
  end
  table.sort(dataList, function(a, b)
    return a.affixId < b.affixId
  end)
  self.loopAffixList:RefreshListView(dataList, false)
end

function Hero_dungeon_instability_mainView:getCfgData()
  self.dungeonData_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(self.dungeonId_)
  self.teamTargetId_ = self.teamMainVm_.GetTargetIdByDungeonId(self.dungeonId_)
  self:setLab(self.dungeonId_)
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
  if self.uiBinder.btn_tab_01.isOn == true then
  else
    self.uiBinder.btn_tab_01.isOn = true
  end
  self.toggleisTeam_ = true
  self:OnSelectLeftItem(self.dungeonDataList_[1])
  self.uiBinder.tog_team.isOn = true
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
  Z.VMMgr.GetVM("helpsys").CloseTitleContentBtn()
end

function Hero_dungeon_instability_mainView:OnRefresh()
end

function Hero_dungeon_instability_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.HeroDungeonKeyChange, self.refreshKeyItem, self)
end

function Hero_dungeon_instability_mainView:UnBindAllEvents()
  Z.EventMgr:Remove(Z.ConstValue.HeroDungeonKeyChange, self.refreshKeyItem, self)
end

function Hero_dungeon_instability_mainView:refreshKeyItem()
  local s = goStr
  local itemUuid = self.data_:GetUseKeyData()
  local hasUseItem = 0 < itemUuid
  if self.canUseKey_ and hasUseItem then
    local itemData = self.itemsVM_.GetItemTabDataByUuid(itemUuid)
    if itemData then
    end
  end
  if self.canUseKey_ then
    s = hasUseItem == true and goStr or keyStr
  end
  self.hasUseKey_ = hasUseItem
  local btn = self.uiBinder.btn_go_uibinder
  btn.lab_normal.text = s
  self:creatAffix()
end

function Hero_dungeon_instability_mainView:refreshTimeLab()
  local challengeCfg = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(self.dungeonId_)
  if challengeCfg.LimitTime <= 0 then
    self.labTime_.text = Lang("NoTimeLimit")
  else
    self.labTime_.text = Z.TimeTools.FormatToDHM(challengeCfg.LimitTime)
  end
end

function Hero_dungeon_instability_mainView:OnSelectLeftItem(data)
  local canUseKey = data.type == 2
  self.dungeonId_ = data.dungeonID
  self.canUseKey_ = canUseKey
  self:refreshTimeLab()
  self:SetUIVisible(self.uiBinder.node_tog, canUseKey == false)
  self:SetUIVisible(self.uiBinder.layout_select, not self.isBase_ and canUseKey)
  self:getCfgData()
  self:initUi()
  if self.canUseKey_ == false then
    self.data_.InstabilityIsTeam = self.toggleisTeam_
  else
    self.data_.InstabilityIsTeam = true
  end
  self:setPersonLab()
  self:setLimit()
  self:refreshKeyItem()
end

return Hero_dungeon_instability_mainView
