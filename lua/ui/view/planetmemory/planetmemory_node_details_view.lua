local UI = Z.UI
local super = require("ui.ui_subview_base")
local Planetmemory_node_detailsView = class("Planetmemory_node_detailsView", super)
local planetmemoryVm = Z.VMMgr.GetVM("planetmemory")
local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
local itemClass = require("common.item")
local awardPrevVm = Z.VMMgr.GetVM("awardpreview")

function Planetmemory_node_detailsView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "planetmemory_node_details", "planetmemory/planetmemory_node_details", UI.ECacheLv.None)
end

function Planetmemory_node_detailsView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.itemClassTab_ = {}
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self:initVariable()
  self:initListener()
end

function Planetmemory_node_detailsView:initComp()
  self.cont_right_sub = self.uiBinder.cont_right_sub
  self.group_award = self.uiBinder.group_award
  self.closePanelBtn_ = self.cont_right_sub.cont_btn_return.btn
  self.planetMemoryNameLab_ = self.cont_right_sub.lab_title
  self.planetMemoryZWiget = self.cont_right_sub.img_edit
  self.planetMemoryGsLab_ = self.uiBinder.lab_gs
  self.planetMemoryReferralsLab_ = self.uiBinder.lab_referrals
  self.taskExplainLab_ = self.uiBinder.group_task.lab_content
  self.monsterInfoList_ = self.uiBinder.group_monster.node_monsters_content
  self.monsterInfoBtn_ = self.uiBinder.group_monster.btn_search
  self.wordInfoList_ = self.uiBinder.group_affix.node_affixs_content
  self.nullAffix_ = self.uiBinder.group_affix.lab_tips
  self.awardInfoScroll_ = self.group_award.node_awards_content
  self.awardInfoWidget_ = self.group_award.btn_search
  self.propGroup_ = self.uiBinder.group_prop
  self.propIconImg_ = self.propGroup_.img_prop
  self.propNumLab_ = self.propGroup_.lab_porp_quantity
  self.enterBtn_ = self.uiBinder.cont_btn_go
  self.taskCompletionLab_ = self.group_award.lab_task_completion
  self.descScroll_ = self.uiBinder.group_task.scrollview_lab
  self.anim_ = self.uiBinder.anim_sub
end

function Planetmemory_node_detailsView:initListener()
  self:AddClick(self.closePanelBtn_, function()
    self:onClosePlaneBtnClick()
  end)
  self:AddClick(self.monsterInfoBtn_, function()
    self:onMonsterInfoBtnClick()
  end)
  self:AddClick(self.awardInfoWidget_, function()
    self:onAwardInfoBtnClick()
  end)
  self:AddClick(self.enterBtn_, function()
    self:onEnterBtnClick()
  end)
end

function Planetmemory_node_detailsView:initVariable()
  self.isGSEnough_ = false
  self.isEnterPlanetmemory_ = false
  self.peopleNum_ = 1
  self.isGSTeamMemberEnough_ = false
  self.teamName_ = ""
  self.isReferralsEnough_ = false
  self.isUnlock_ = false
  self.isQuantityEnough_ = false
  self.planetMemoryId_ = nil
  self.planetmemoryCfg_ = nil
  self.dungeonsTableMgr_ = Z.TableMgr.GetTable("DungeonsTableMgr")
  self.affixTableMgr_ = Z.TableMgr.GetTable("AffixTableMgr")
  self.modelTableMgr_ = Z.TableMgr.GetTable("ModelTableMgr")
  self.monsterTableMgr_ = Z.TableMgr.GetTable("MonsterTableMgr")
  self.dungeonVm_ = Z.VMMgr.GetVM("dungeon")
end

function Planetmemory_node_detailsView:OnDeActive()
  self:clear()
end

function Planetmemory_node_detailsView:clear()
  self.planetMemoryId_ = nil
  self.planetMemoryTableRow_ = nil
  self.peopleNum_ = 1
  self.isEnterPlanetmemory_ = false
  self.isGSTeamMemberEnough_ = false
  self.teamName_ = ""
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
  planetmemoryVm.CloseMonsterTips()
  self:ClearAllUnits()
end

function Planetmemory_node_detailsView:OnRefresh()
  if self.viewData == nil then
    self:DeActive()
    return
  end
  self:clear()
  self.planetMemoryId_ = self.viewData.PlanetMemoryId
  self.planetmemoryCfg_ = self.viewData.PlanetmemoryCfg_
  local planetMemoryTableMgr = Z.TableMgr.GetTable("PlanetMemoryTableMgr")
  if planetMemoryTableMgr == nil then
    return
  end
  self.planetMemoryTableRow_ = planetMemoryTableMgr.GetRow(self.planetMemoryId_, false)
  if self.planetMemoryTableRow_ == nil then
    return
  end
  self.dungeonTableRow_ = self.dungeonsTableMgr_.GetRow(self.planetMemoryTableRow_.DungeonId)
  if self.dungeonTableRow_ == nil then
    return
  end
  self.descScroll_.verticalNormalizedPosition = 1
  self:updateRoomTypeImg()
  self:refreshNodeName()
  self:refreshGS()
  self:refreshReferrals()
  self:getGSTeamMember()
  self:refreshTaskInfo()
  self:refreshMonsterInfo()
  self:refreshAffixInfo()
  self:refreshAwardsInfo()
  self:refreshConsumeInfo()
  self:refreshEnterBtnState()
end

function Planetmemory_node_detailsView:onClosePlaneBtnClick()
  self:DeActive()
end

function Planetmemory_node_detailsView:onMonsterInfoBtnClick()
  planetmemoryVm.OpenMonsterTips(self.planetMemoryTableRow_.TargetMonster, self.planetMemoryTableRow_.GsLimit)
end

function Planetmemory_node_detailsView:onAffixInfoBtnClick()
  Z.CommonTipsVM.OpenAffixTips(self.planetMemoryTableRow_.Affix, self.wordInfoList_)
end

function Planetmemory_node_detailsView:onAwardInfoBtnClick()
  if (not self.dungeonTableRow_.PassAward or not self.dungeonTableRow_.PassAward[1]) and (not self.dungeonTableRow_.FirstPassAward or not self.dungeonTableRow_.FirstPassAward[1]) then
    return
  end
  local awardTable = {}
  local awardArrayTable = {}
  if self.dungeonTableRow_.PassAward[1] then
    awardArrayTable.passAward = self.dungeonTableRow_.PassAward[1]
  end
  if self.dungeonTableRow_.FirstPassAward[1] then
    awardArrayTable.firstAward = self.dungeonTableRow_.FirstPassAward[1]
  end
  if awardArrayTable.passAward then
    table.insert(awardTable, awardArrayTable.passAward)
  end
  if awardArrayTable.firstAward and not planetmemoryVm.CheckIsPassRoom(self.planetMemoryId_) then
    table.insert(awardTable, awardArrayTable.firstAward)
  end
  if not next(awardTable) then
    return
  end
  local awardList = awardPrevVm.GetAllAwardPreListByIds(awardTable)
  awardPrevVm.OpenRewardDetailViewByListData(awardList)
end

function Planetmemory_node_detailsView:onSendEnterMes()
  local token = self.cancelSource:CreateToken()
  Z.CoroUtil.coro_xpcall(function()
    planetmemoryVm.AsyncEnterPlanetMemory(self.planetmemoryCfg_.RoomId, token)
  end)
end

function Planetmemory_node_detailsView:onEnterBtnClick()
  if not self.isUnlock_ then
    Z.TipsVM.ShowTipsLang(15001011)
  elseif not self.isQuantityEnough_ then
    Z.TipsVM.ShowTipsLang(15001010)
  elseif not self.isEnterPlanetmemory_ then
    self:onSendEnterMes()
  elseif not self.isGSEnough_ or self.isGSTeamMemberEnough_ then
    if self.teamVM_.CheckIsInTeam() then
      local isLeader = self.teamVM_.GetYouIsLeader()
      if not isLeader then
        Z.TipsVM.ShowTips(2906)
        return
      end
      self:checkName()
    else
      self:onSendEnter(Lang("ConfirmationEquipGS"))
    end
  else
    self:onSendEnterMes()
  end
end

function Planetmemory_node_detailsView:checkName()
  local param = {
    player = {
      name = self.teamName_
    }
  }
  if not self.isGSEnough_ and self.isGSTeamMemberEnough_ then
    local gsAllLab = Lang("ConfirmationEquipTeamAllGS", param)
    self:onSendEnter(gsAllLab)
  elseif not self.isGSEnough_ then
    self:onSendEnter(Lang("ConfirmationEquipGS"))
  else
    local gsLab = Lang("ConfirmationEquipTeamGS", param)
    self:onSendEnter(gsLab)
  end
end

function Planetmemory_node_detailsView:onSendEnter(confirmationEquipGS)
  Z.DialogViewDataMgr:OpenNormalDialog(confirmationEquipGS, function()
    planetmemoryVm.AsyncEnterPlanetMemory(self.planetmemoryCfg_.RoomId, self.cancelSource:CreateToken())
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

function Planetmemory_node_detailsView:refreshNodeName()
  self.planetMemoryNameLab_.text = self.planetMemoryTableRow_.RoomName
end

function Planetmemory_node_detailsView:getGSTeamMember()
  if next(self.teamData_.TeamInfo.members) == nil then
    return
  end
  if #self.teamData_.TeamInfo.members > self.peopleNum_ then
    self.isEnterPlanetmemory_ = false
    return
  else
    self.isEnterPlanetmemory_ = true
  end
  for i, v in pairs(self.teamData_.TeamInfo.members) do
    if v.socialData and self.teamData_.TeamInfo.baseInfo.leaderId ~= i then
      self.teamName_ = v.socialData.basicData.name
      self.isGSTeamMemberEnough_ = true
    end
  end
end

function Planetmemory_node_detailsView:refreshGS()
  local gsLimit = self.planetMemoryTableRow_.GsLimit
  local param = {val = gsLimit}
  self.planetMemoryGsLab_.text = Lang("GSSuggest", param)
  self:checkGS(self.planetmemoryCfg_.GsLimit)
end

function Planetmemory_node_detailsView:refreshReferrals()
  local dungeonConditions = self.dungeonTableRow_.LimitedNum
  local firstDungeonCondition = dungeonConditions[2]
  self.peopleNum_ = firstDungeonCondition
  if self.peopleNum_ > 1 then
    self.isReferralsEnough_ = true
  else
    self.isReferralsEnough_ = false
  end
  self.uiBinder.Ref:SetVisible(self.planetMemoryReferralsLab_, self.isReferralsEnough_)
end

function Planetmemory_node_detailsView:refreshTaskInfo()
  local dungeonCfgData = self.dungeonsTableMgr_.GetRow(self.planetMemoryTableRow_.DungeonId)
  if dungeonCfgData == nil then
    return
  end
  self.taskExplainLab_.text = dungeonCfgData.Content
end

function Planetmemory_node_detailsView:refreshMonsterInfo()
  local itemList = self.planetMemoryTableRow_.TargetMonster
  if itemList == nil or #itemList < 1 then
    return
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.prefabcache_root, "monsterItemPath")
  Z.CoroUtil.create_coro_xpcall(function()
    for _, v in ipairs(itemList) do
      local name = string.format("monsterItem_%s", v)
      local item = self:AsyncLoadUiUnit(path, name, self.monsterInfoList_)
      self:refreshMonsterItem(item, v)
    end
  end)()
end

function Planetmemory_node_detailsView:refreshMonsterItem(uiunit, monsterId)
  if uiunit == nil then
    return
  end
  self:AddClick(uiunit.btn_monster.Btn, function()
    self:onMonsterInfoBtnClick()
  end)
  local monsterTableRow = self.monsterTableMgr_.GetRow(monsterId)
  if monsterTableRow == nil then
    return
  end
  local modelTableRow = self.modelTableMgr_.GetRow(monsterTableRow.ModelID)
  if modelTableRow == nil then
    return
  end
  local iconPath = modelTableRow.Image
  uiunit.img_monster.Img:SetImage(iconPath)
end

function Planetmemory_node_detailsView:refreshAffixInfo()
  local itemList = self.planetmemoryCfg_.Affix
  self.uiBinder.group_affix.Ref:SetVisible(self.nullAffix_, itemList == nil or #itemList < 1)
  if itemList == nil or #itemList < 1 then
    return
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.prefabcache_root, "affixItemPath")
  Z.CoroUtil.create_coro_xpcall(function()
    for _, v in ipairs(itemList) do
      local name = string.format("affix_%s", v)
      local item = self:AsyncLoadUiUnit(path, name, self.wordInfoList_)
      self:setAffixItem(item, v)
    end
  end)()
end

function Planetmemory_node_detailsView:setAffixItem(uiunit, affixId)
  if uiunit == nil then
    return
  end
  self:AddClick(uiunit.img_affix.Btn, function()
    self:onAffixInfoBtnClick()
  end)
  local affixTableRow = self.affixTableMgr_.GetRow(affixId)
  if affixTableRow == nil then
    return
  end
  uiunit.img_affix.Img:SetImage(affixTableRow.Icon)
end

function Planetmemory_node_detailsView:refreshAwardsInfo()
  if self.dungeonTableRow_ == nil then
    return
  end
  if (not self.dungeonTableRow_.PassAward or not self.dungeonTableRow_.PassAward[1]) and (not self.dungeonTableRow_.FirstPassAward or not self.dungeonTableRow_.FirstPassAward[1]) then
    return
  end
  local awardTable = {}
  local awardArrayTable = {}
  if self.dungeonTableRow_.PassAward[1] then
    awardArrayTable.passAward = self.dungeonTableRow_.PassAward[1]
  end
  if self.dungeonTableRow_.FirstPassAward[1] then
    awardArrayTable.firstAward = self.dungeonTableRow_.FirstPassAward[1]
  end
  self.group_award.Ref:SetVisible(self.awardInfoWidget_, true)
  self.group_award.Ref:SetVisible(self.taskCompletionLab_, false)
  if awardArrayTable.passAward then
    table.insert(awardTable, awardArrayTable.passAward)
  end
  if awardArrayTable.firstAward then
    if planetmemoryVm.CheckIsPassRoom(self.planetMemoryId_) then
      if not next(awardTable) then
        self.group_award.Ref:SetVisible(self.awardInfoWidget_, false)
        self.group_award.Ref:SetVisible(self.taskCompletionLab_, true)
      end
    else
      table.insert(awardTable, awardArrayTable.firstAward)
    end
  end
  if not next(awardTable) then
    return
  end
  local awards = awardPrevVm.GetAllAwardPreListByIds(awardTable)
  if awards == nil or #awards < 1 then
    return
  end
  local itemPath = self:GetPrefabCacheDataNew(self.uiBinder.prefabcache_root, "itemPath")
  Z.CoroUtil.create_coro_xpcall(function()
    if awards and next(awards) then
      for k, v in ipairs(awards) do
        local name = string.format("awardItem_%s", k)
        local item = self:AsyncLoadUiUnit(itemPath, name, self.awardInfoScroll_)
        local data = v
        self.units[name] = item
        self.itemClassTab_[name] = itemClass.new(self)
        local itemData = {
          unit = item,
          configId = data.awardId,
          isSquareItem = true,
          PrevDropType = data.PrevDropType,
          dungeonId = self.planetmemoryCfg_.DungeonId
        }
        itemData.labType, itemData.lab = awardPrevVm.GetPreviewShowNum(data)
        self.itemClassTab_[name]:Init(itemData)
      end
    end
  end)()
end

function Planetmemory_node_detailsView:refreshConsumeInfo()
  local isSp, itemId, itemNum = planetmemoryVm.IsSpecialCopy(self.planetmemoryCfg_.DungeonId)
  if isSp then
    self.uiBinder.Ref:SetVisible(self.propGroup_.Ref, true)
    local itemsVM = Z.VMMgr.GetVM("items")
    self.propIconImg_:SetImage(itemsVM.GetItemIcon(itemId))
    local num = Z.VMMgr.GetVM("items").GetItemTotalCount(itemId)
    if itemNum <= num then
      self.propNumLab_.text = Z.RichTextHelper.ApplyStyleTag(itemNum, E.TextStyleTag.White)
      return true
    else
      self.propNumLab_.text = Z.RichTextHelper.ApplyStyleTag(itemNum, E.TextStyleTag.Red)
      return false
    end
  else
    self.uiBinder.Ref:SetVisible(self.propGroup_.Ref, false)
    return true
  end
end

function Planetmemory_node_detailsView:refreshEnterBtnState()
  local pmStateTb = planetmemoryData:GetPlanetMemoryState()
  self.isQuantityEnough_ = self:refreshConsumeInfo()
  local roomId = self.planetMemoryId_
  if not pmStateTb[roomId] or pmStateTb[roomId] == E.PlanetmemoryState.Close then
    self.isUnlock_ = false
  else
    self.isUnlock_ = true
  end
  local isOn = true
  if not self.isUnlock_ or not self.isQuantityEnough_ then
    isOn = false
  else
    isOn = true
  end
  self.enterBtn_.IsDisabled = not isOn
end

function Planetmemory_node_detailsView:checkGS(value)
  self.isGSEnough_ = true
end

function Planetmemory_node_detailsView:updateRoomTypeImg()
  local seasonConfig = planetmemoryData:GetMonsterIconPath(self.planetmemoryCfg_.RoomType, Z.PlanetMemorySeasonConfig.RoomTypeIcon)
  if not seasonConfig or seasonConfig == "" then
    self.cont_right_sub.Ref:SetVisible(self.planetMemoryZWiget, false)
  else
    self.planetMemoryZWiget:SetImage(seasonConfig)
    self.cont_right_sub.Ref:SetVisible(self.planetMemoryZWiget, true)
  end
end

function Planetmemory_node_detailsView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Planetmemory_node_detailsView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.anim_.CoroPlay)
  coro(self.anim_, Z.DOTweenAnimType.Close)
end

return Planetmemory_node_detailsView
