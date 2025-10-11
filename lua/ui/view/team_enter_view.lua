local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_enterView = class("Team_enterView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local PERSONALZONEDEFINE = require("ui.model.personalzone_define")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")

function Team_enterView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_enter")
  self.selfIsLeader_ = false
  self.vm = Z.VMMgr.GetVM("team_enter")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.worldquestVM_ = Z.VMMgr.GetVM("worldquest")
  self.snapShotVM_ = Z.VMMgr.GetVM("snapshot")
  self.assistFightVM_ = Z.VMMgr.GetVM("assist_fight")
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchTeamData_ = Z.DataMgr.Get("match_team_data")
  self.matchActivityData_ = Z.DataMgr.Get("match_activity_data")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
end

function Team_enterView:initBinder()
  self.sceneMask_ = self.uiBinder.scenemask
  self.lab_title_ = self.uiBinder.lab_title
  self.btn_confirm_ = self.uiBinder.btn_confirm
  self.btn_cancel_ = self.uiBinder.btn_cancel
  self.imgSlider_ = self.uiBinder.img_slider
  self.lab_time_ = self.uiBinder.lab_time
  self.btn_node_ = self.uiBinder.btn_node
  self.layout_gruop_ = self.uiBinder.layout_gruop
  self.node_worldquest = self.uiBinder.node_worldquest
  self.affixNode_ = self.uiBinder.btn_affix
  self.affixBtn_ = self.affixNode_.btn
  self.memberNode20_ = self.uiBinder.layout_gruop_20team
end

function Team_enterView:OnActive()
  self.readyMap = {}
  self:initBinder()
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.Ref:SetVisible(self.btn_node_, true)
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.downloadVm_ = Z.VMMgr.GetVM("download")
  if self.viewData and self.viewData.assignSceneParams then
    self:setViewInfo()
    Z.CoroUtil.create_coro_xpcall(function()
      self:setMemberInfo()
    end)()
  end
  if self.viewData and self.viewData.isMatching then
    self:setMatchViewInfo()
    Z.CoroUtil.create_coro_xpcall(function()
      self:setMatchMemberInfo()
    end)()
  end
  self:BindEvents()
end

function Team_enterView:OnDeActive()
  Z.EventMgr:RemoveObjAll(self)
  self.timerMgr:Clear()
  self.readyMap = {}
end

function Team_enterView:setMatchTeamViewInfo()
  local dungeonId = self.matchTeamData_:GetCurMatchingDungeonId()
  local difficulty = self.matchTeamData_:GetCurMatchingMasterDifficulty()
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonCfg then
    return
  end
  local teamMainVm = Z.VMMgr.GetVM("team_main")
  local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId)
  local teamTargetTableRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if teamTargetTableRow then
    self.uiBinder.rimg_bg:SetImage(teamTargetTableRow.MatchPic)
    self.TeamMaxMemberType_ = teamTargetTableRow.MemberCountStopMatch > 5 and E.ETeamMemberType.Twenty or E.ETeamMemberType.Five
  end
  local targetName = ""
  if difficulty and 0 < difficulty then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][difficulty]
    local masterChallengeDungeonTableRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    if masterChallengeDungeonTableRow then
      targetName = Lang("DungeonMasterName", {
        dungeonName = dungeonCfg.Name,
        masterName = masterChallengeDungeonTableRow.DungeonTypeName
      })
    end
  else
    targetName = dungeonCfg.Name .. "  " .. dungeonCfg.DungeonTypeName
  end
  self.lab_title_.text = targetName
  self.uiBinder.Ref:SetVisible(self.node_worldquest, self.worldquestVM_.CheckIsWorldDungeonAndFinish(dungeonId))
  local affixList
  local hasAffix = false
  local dungeon_data = Z.DataMgr.Get("dungeon_data")
  local dungeonAffix = dungeon_data:GetDungeonAffixDic(dungeonId)
  if dungeonAffix and dungeonAffix.affixes then
    affixList = dungeonAffix.affixes
    hasAffix = 0 < table.zcount(affixList)
  end
  self:AddClick(self.affixBtn_, function()
    self.vm.OpenAffixInfoView(dungeonAffix.affixes)
  end)
  self.affixNode_.Ref:SetVisible(self.affixBtn_, hasAffix)
  local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(teamTargetTableRow.MatchID)
  local lastTime = matchTableRow.ConfirmTime
  local sliderValue = lastTime
  self.lab_time_.text = lastTime .. Lang("EquipSecondsText")
  self.timerMgr:StartFrameTimer(function()
    sliderValue = sliderValue - Time.deltaTime
    self.lab_time_.text = sliderValue < 0 and 0 .. Lang("EquipSecondsText") or math.floor(sliderValue) .. Lang("EquipSecondsText")
    self.imgSlider_.fillAmount = sliderValue / lastTime
  end, 1, -1)
end

function Team_enterView:setMatchViewInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, false)
  local matchType = self.matchData_:GetMatchType()
  if matchType == E.MatchType.Team then
    self:setMatchTeamViewInfo()
  end
  self:AddAsyncClick(self.btn_confirm_, function()
    self.matchVm_.AsyncMatchReady(true)
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
  end, nil, nil)
  self:AddAsyncClick(self.btn_cancel_, function()
    local confirmFunc = function()
      Z.CoroUtil.create_coro_xpcall(function()
        self.matchVm_.AsyncMatchReady(false)
        self.uiBinder.Ref:SetVisible(self.btn_node_, false)
      end)()
    end
    local data = {
      dlgType = E.DlgType.YesNo,
      onConfirm = confirmFunc,
      labDesc = Lang("ConfirmUnreadyMatchTips")
    }
    Z.DialogViewDataMgr:OpenDialogView(data)
  end, nil, nil)
  self.uiBinder.Ref:SetVisible(self.btn_confirm_, true)
end

function Team_enterView:setViewInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, true)
  local dungeonId = self.viewData.assignSceneParams.sceneId
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonCfg then
    return
  end
  local dungeonTypeName = dungeonCfg.DungeonTypeName
  if dungeonCfg.PlayType == E.DungeonType.MasterChallengeDungeon and dungeonCfg.PlayType == E.DungeonType.MasterChallengeDungeon then
    local diff = self.viewData.assignSceneParams.initParam.masterModeDiff
    dungeonTypeName = Z.VMMgr.GetVM("hero_dungeon_main").GetHeroDungeonTypeName(dungeonId, diff)
  end
  local teamMainVm = Z.VMMgr.GetVM("team_main")
  local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId)
  if targetId ~= nil then
    local teamTargetTableRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
    if teamTargetTableRow then
      self.uiBinder.rimg_bg:SetImage(teamTargetTableRow.MatchPic)
    end
  else
    self.uiBinder.rimg_bg:SetImage("ui/background/seasonact/activity_dina_7")
  end
  self.lab_title_.text = dungeonCfg.Name .. "  " .. dungeonTypeName
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.TeamMaxMemberType_ = teamInfo.teamMemberType
  self.selfIsLeader_ = teamInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
  self:AddAsyncClick(self.btn_confirm_, function()
    if not self.teamVM_.CheckIsInTeam() then
      self.vm.CloseEnterView()
      return
    end
    self.vm.AsyncReplyJoinActivity(true, self.cancelSource:CreateToken())
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
  end, nil, nil)
  self:AddAsyncClick(self.btn_cancel_, function()
    if not self.teamVM_.CheckIsInTeam() then
      self.vm.CloseEnterView()
      return
    end
    if self.selfIsLeader_ then
      self.vm.AsyncTeamCancelActivity(self.cancelSource:CreateToken())
    else
      self.vm.AsyncReplyJoinActivity(false, self.cancelSource:CreateToken())
    end
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
    self.vm.CloseEnterView()
  end, nil, nil)
  self.uiBinder.Ref:SetVisible(self.btn_confirm_, not self.selfIsLeader_)
  self.uiBinder.Ref:SetVisible(self.node_worldquest, self.worldquestVM_.CheckIsWorldDungeonAndFinish(dungeonId))
  local teamActivity = self.viewData
  local useItem
  if teamActivity.dungeonInfo then
    useItem = teamActivity.dungeonInfo.useItem
  end
  local hasUseKey = useItem and useItem.uuid > 0
  local dungeonId = teamActivity.assignSceneParams.sceneId
  local affixList
  local hasAffix = false
  local dungeon_data = Z.DataMgr.Get("dungeon_data")
  local dungeonAffix = dungeon_data:GetDungeonAffixDic(dungeonId)
  if dungeonAffix and dungeonAffix.affixes then
    affixList = dungeonAffix.affixes
    hasAffix = 0 < table.zcount(affixList)
  end
  if hasUseKey then
    affixList = useItem.affixData.affixIds
    hasAffix = 0 < table.zcount(affixList)
  end
  self.affixNode_.Ref:SetVisible(self.affixBtn_, hasAffix)
  self:AddClick(self.affixBtn_, function()
    self.vm.OpenAffixInfoView(dungeonAffix.affixes, hasUseKey and useItem.affixData.affixIds or nil)
  end)
  local lastTime = Z.Global.TeamApplyActivityLastTime
  local sliderValue = lastTime
  self.lab_time_.text = lastTime .. Lang("EquipSecondsText")
  self.timerMgr:StartFrameTimer(function()
    sliderValue = sliderValue - Time.deltaTime
    self.imgSlider_.fillAmount = sliderValue / lastTime
    self.lab_time_.text = sliderValue < 0 and 0 .. Lang("EquipSecondsText") or math.floor(sliderValue) .. Lang("EquipSecondsText")
    if sliderValue < 0 then
      self.timerMgr:Clear()
      self.vm.CloseEnterView()
    end
  end, 1, -1)
end

function Team_enterView:setMatchMemberInfo()
  self:ClearAllUnits()
  local memberList = self.matchData_:GetMatchPlayerInfo()
  local parent = self.TeamMaxMemberType_ == E.ETeamMemberType.Five and self.layout_gruop_ or self.memberNode20_
  self.uiBinder.Ref:SetVisible(self.layout_gruop_, self.TeamMaxMemberType_ == E.ETeamMemberType.Five)
  self.uiBinder.Ref:SetVisible(self.memberNode20_, self.TeamMaxMemberType_ == E.ETeamMemberType.Twenty)
  local path = self.TeamMaxMemberType_ == E.ETeamMemberType.Five and GetLoadAssetPath(Z.ConstValue.Team.EnterPlayTpl) or GetLoadAssetPath(Z.ConstValue.Team.EnterPlayTpl20)
  for k, v in pairs(memberList) do
    local memberInfo = v
    local charId = memberInfo.charId
    local memberItem = self:AsyncLoadUiUnit(path, "member" .. charId, parent)
    local isReady = memberInfo.readyStatus == E.RedayType.Ready
    if table.zcontainsKey(self.readyMap, memberInfo.charId) then
      isReady = true
    end
    memberItem.Ref:SetVisible(memberItem.img_select, isReady)
    memberItem.Ref:SetVisible(memberItem.cont_login, not isReady)
    memberItem.Ref:SetVisible(memberItem.lab_tips, false)
    local isAssistFight = false
    if not memberInfo.isAi then
      isAssistFight = memberInfo.isAssist
    end
    memberItem.Ref:SetVisible(memberItem.node_assist_fight, isAssistFight)
    self:setMatchHalfPortraitPImg(memberInfo, memberItem)
    memberItem.Ref:SetVisible(memberItem.lab_master, false)
    local idcard = Z.DataMgr.Get("personal_zone_data"):GetDefaultProfileImageConfigByType(PERSONALZONEDEFINE.ProfileImageType.Card)
    if memberInfo.matchShowInfo and memberInfo.matchShowInfo.avatarInfo and memberInfo.matchShowInfo.avatarInfo.businessCardStyleId ~= 0 then
      idcard = memberInfo.matchShowInfo.avatarInfo.businessCardStyleId
    end
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idcard)
    if config and memberItem.rimg_bg then
      memberItem.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalTeamBg .. config.Image)
    end
    local medals = {}
    local medalCount = 0
    if memberInfo.matchShowInfo and memberInfo.matchShowInfo.personalZone and memberInfo.matchShowInfo.personalZone.medals then
      for i = 1, Z.Global.PersonalMedalLimit * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] do
        if memberInfo.matchShowInfo.personalZone.medals[i] ~= nil and memberInfo.matchShowInfo.personalZone.medals[i] ~= 0 then
          medalCount = medalCount + 1
          medals[medalCount] = memberInfo.matchShowInfo.personalZone.medals[i]
          if medalCount == Z.Global.IdCardShowMedalCount then
            break
          end
        end
      end
    end
    if self.TeamMaxMemberType_ == E.ETeamMemberType.Five then
      local mgr = Z.TableMgr.GetTable("MedalTableMgr")
      for i = 1, Z.Global.TeamCardShowMedalCount do
        local img = memberItem.node_badge["rimg_badge_" .. i]
        if medals[i] ~= nil and medals[i] ~= 0 then
          memberItem.node_badge.Ref:SetVisible(img, true)
          local config = mgr.GetRow(medals[i])
          if config then
            img:SetImage(config.Image)
          end
        else
          memberItem.node_badge.Ref:SetVisible(img, false)
        end
      end
    end
  end
end

function Team_enterView:setMemberInfo()
  local teamActivity = self.viewData
  local useItem
  if teamActivity.dungeonInfo then
    useItem = teamActivity.dungeonInfo.useItem
  end
  local hasUseKey = useItem and useItem.uuid > 0
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local memberList = self.teamVM_.GetTeamMemData()
  local memberListCount = #memberList
  local dungeonId = self.viewData.assignSceneParams.sceneId
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local showScore = false
  if dungeonCfg then
    showScore = dungeonCfg.PlayType == E.DungeonType.MasterChallengeDungeon
  end
  local parent = self.TeamMaxMemberType_ == E.ETeamMemberType.Five and self.layout_gruop_ or self.memberNode20_
  self.uiBinder.Ref:SetVisible(self.layout_gruop_, self.TeamMaxMemberType_ == E.ETeamMemberType.Five)
  self.uiBinder.Ref:SetVisible(self.memberNode20_, self.TeamMaxMemberType_ == E.ETeamMemberType.Twenty)
  local path = self.TeamMaxMemberType_ == E.ETeamMemberType.Five and GetLoadAssetPath(Z.ConstValue.Team.EnterPlayTpl) or GetLoadAssetPath(Z.ConstValue.Team.EnterPlayTpl20)
  for i = 1, memberListCount do
    local memberInfo = memberList[i]
    local charId = memberInfo.charId
    local memberItem = self:AsyncLoadUiUnit(path, "member" .. charId, parent)
    local isLeader = charId == teamInfo.leaderId
    local memberSocialData = memberInfo.socialData
    memberItem.Ref:SetVisible(memberItem.img_select, isLeader)
    memberItem.Ref:SetVisible(memberItem.cont_login, not isLeader)
    memberItem.Ref:SetVisible(memberItem.lab_tips, hasUseKey == true)
    local isAssistFight = false
    if not memberInfo.isAi then
      isAssistFight = teamActivity.awardCountInfo[charId].isAssist
    end
    memberItem.Ref:SetVisible(memberItem.node_assist_fight, isAssistFight)
    if hasUseKey then
      local limitID, limitCount, curCount, str
      if isLeader then
        limitID = Z.Global.KeyRewardLimitId
        limitCount = Z.CounterHelper.GetCounterLimitCount(limitID)
        curCount = limitCount - teamActivity.awardCountInfo[charId].keyAwardCount
        str = Lang("RewardKey")
      else
        limitID = Z.Global.RollRewardLimitId
        limitCount = Z.CounterHelper.GetCounterLimitCount(limitID)
        curCount = limitCount - teamActivity.awardCountInfo[charId].rollAwardCount
        str = Lang("RewardRoll")
      end
      local strType = curCount == 0 and E.TextStyleTag.Red or E.TextStyleTag.White
      local numStr = Z.RichTextHelper.ApplyStyleTag(tostring(curCount), strType)
      str = str .. " " .. numStr .. "/" .. limitCount
      memberItem.lab_tips.text = str
    end
    if memberSocialData then
      self:setHalfPortraitPImg(memberInfo, memberItem)
      local score = 0
      local master_dungeon_score_text = Lang("MaterDungeonScore") .. score
      if memberInfo.socialData.masterModeDungeonData then
        score = memberInfo.socialData.masterModeDungeonData.seasonScore
        local scoreText = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
        master_dungeon_score_text = Lang("MaterDungeonScore") .. scoreText
        if memberInfo.socialData.masterModeDungeonData.isShow then
          master_dungeon_score_text = Lang("MaterDungeonScore") .. Lang("Hidden")
        end
      end
      memberItem.lab_master.text = master_dungeon_score_text
      memberItem.Ref:SetVisible(memberItem.lab_master, 0 < score and showScore)
      local idcard = Z.DataMgr.Get("personal_zone_data"):GetDefaultProfileImageConfigByType(PERSONALZONEDEFINE.ProfileImageType.Card)
      if memberSocialData.avatarInfo and memberSocialData.avatarInfo.businessCardStyleId and memberSocialData.avatarInfo.businessCardStyleId ~= 0 then
        idcard = memberSocialData.avatarInfo.businessCardStyleId
      end
      local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(idcard)
      if config and memberItem.rimg_bg then
        memberItem.rimg_bg:SetImage(Z.ConstValue.PersonalZone.PersonalTeamBg .. config.Image)
      end
      local medals = {}
      local medalCount = 0
      if memberSocialData.personalZone and memberSocialData.personalZone.medals then
        for i = 1, Z.Global.PersonalMedalLimit * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] do
          if memberSocialData.personalZone.medals[i] ~= nil and memberSocialData.personalZone.medals[i] ~= 0 then
            medalCount = medalCount + 1
            medals[medalCount] = memberSocialData.personalZone.medals[i]
            if medalCount == Z.Global.IdCardShowMedalCount then
              break
            end
          end
        end
      end
      if self.TeamMaxMemberType_ == E.ETeamMemberType.Five then
        local mgr = Z.TableMgr.GetTable("MedalTableMgr")
        for i = 1, Z.Global.TeamCardShowMedalCount do
          local img = memberItem.node_badge["rimg_badge_" .. i]
          if medals[i] ~= nil and medals[i] ~= 0 then
            memberItem.node_badge.Ref:SetVisible(img, true)
            local config = mgr.GetRow(medals[i])
            if config then
              img:SetImage(config.Image)
            end
          else
            memberItem.node_badge.Ref:SetVisible(img, false)
          end
        end
      end
    end
  end
end

function Team_enterView:setHalfPortraitPImg(memberInfo, memberItem)
  local memberSocialData = memberInfo.socialData
  local professionId = 0
  memberItem.Ref:SetVisible(memberItem.img_idcard, false)
  memberItem.Ref:SetVisible(memberItem.rimg_idcard, false)
  local modelId = 0
  local level = 0
  if memberInfo.isAi then
    local botAiId = memberSocialData.basicData.botAiId
    level = self.teamData_:GetLeaderLevel()
    local botAiTableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
    if botAiTableRow then
      professionId = botAiTableRow.Weapon[1]
      modelId = botAiTableRow.ModelID
      memberItem.lab_name.text = botAiTableRow.Name
      local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
      if path ~= nil then
        memberItem.Ref:SetVisible(memberItem.img_idcard, true)
        memberItem.img_idcard:SetImage(path)
      end
    end
  else
    local professionData = memberSocialData.professionData
    level = memberSocialData.basicData.level
    memberItem.lab_name.text = memberSocialData.basicData.name
    if professionData then
      professionId = professionData.professionId
    end
    modelId = Z.ModelManager:GetModelIdByGenderAndSize(memberSocialData.basicData.gender, memberSocialData.basicData.bodySize)
    local path = self.snapShotVM_.GetInternalHalfPortrait(memberInfo.charId, modelId)
    if path ~= nil then
      if type(path) == "number" then
        memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
        memberItem.rimg_idcard:SetNativeTexture(path)
      else
        memberItem.Ref:SetVisible(memberItem.img_idcard, true)
        memberItem.img_idcard:SetImage(path)
      end
    end
    if self.switchVm_.CheckFuncSwitch(E.FunctionID.DisplayCustomHalfBody) then
      self.snapShotVM_.AsyncGetHttpHalfPortraitId(memberInfo.charId, function(nativeTextureId)
        if not self.uiBinder then
          return
        end
        if nativeTextureId ~= nil and nativeTextureId ~= 0 then
          memberItem.Ref:SetVisible(memberItem.img_idcard, false)
          memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
          memberItem.rimg_idcard:SetNativeTexture(nativeTextureId)
        end
      end)
    end
  end
  if professionId ~= 0 then
    local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionSystemTableRow then
      memberItem.img_profession:SetImage(professionSystemTableRow.Icon)
      memberItem.lab_salutation.text = Lang("LevelWithProfession", {
        level = level,
        professionName = professionSystemTableRow.Name
      })
    end
  end
end

function Team_enterView:setMatchHalfPortraitPImg(memberInfo, memberItem)
  local professionId = memberInfo.professionId
  memberItem.Ref:SetVisible(memberItem.img_idcard, false)
  memberItem.Ref:SetVisible(memberItem.rimg_idcard, false)
  local modelId = 0
  local level = 0
  if memberInfo.isBot then
    local botAiId = memberInfo.charId
    level = memberInfo.matchShowInfo.level
    local botAiTableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
    if botAiTableRow then
      professionId = botAiTableRow.Weapon[1]
      modelId = botAiTableRow.ModelID
      memberItem.lab_name.text = botAiTableRow.Name
      local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
      if path ~= nil then
        memberItem.Ref:SetVisible(memberItem.img_idcard, true)
        memberItem.img_idcard:SetImage(path)
      end
    end
  else
    memberItem.lab_name.text = memberInfo.matchShowInfo.name
    if self.switchVm_.CheckFuncSwitch(E.FunctionID.DisplayCustomHalfBody) and memberInfo.matchShowInfo.avatarInfo and memberInfo.matchShowInfo.avatarInfo.halfBody and not string.zisEmpty(memberInfo.matchShowInfo.avatarInfo.halfBody.url) and memberInfo.matchShowInfo.avatarInfo.halfBody.verify.ReviewStartTime == E.EPictureReviewType.EPictureReviewed then
      local name = self.downloadVm_:GetFileName(memberInfo.charId, memberInfo.matchShowInfo.avatarInfo.halfBody.verify.version, E.HttpPictureDownFoldType.HalfBody)
      self.downloadVm_:GetPicture(name, memberInfo.matchShowInfo.avatarInfo.halfBody.url, self.cancelSource:CreateToken(), function(nativeTextureId)
        self:getHalfBodyTextureCallBack(memberInfo, memberItem, nativeTextureId)
      end, E.HttpPictureDownFoldType.HalfBody)
    else
      self:setDefaultModelHalf(memberInfo, memberItem)
    end
  end
  if professionId ~= 0 then
    local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionSystemTableRow then
      memberItem.img_profession:SetImage(professionSystemTableRow.Icon)
      memberItem.lab_salutation.text = Lang("LevelWithProfession", {
        level = memberInfo.matchShowInfo.level,
        professionName = professionSystemTableRow.Name
      })
    end
  end
end

function Team_enterView:getHalfBodyTextureCallBack(memberInfo, memberItem, nativeTextureId)
  if self.uiBinder == nil then
    return
  end
  if nativeTextureId then
    memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
    memberItem.rimg_idcard:SetNativeTexture(nativeTextureId)
  else
    self:setDefaultModelHalf(memberInfo, memberItem)
  end
end

function Team_enterView:setDefaultModelHalf(memberInfo, memberItem)
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(memberInfo.matchShowInfo.gender, memberInfo.matchShowInfo.bodySize)
  local path = self.snapShotVM_.GetInternalHalfPortrait(memberInfo.charId, modelId)
  if path ~= nil then
    if type(path) == "number" then
      memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
      memberItem.rimg_idcard:SetNativeTexture(path)
    else
      memberItem.Ref:SetVisible(memberItem.img_idcard, true)
      memberItem.img_idcard:SetImage(path)
    end
  end
  self.snapShotVM_.AsyncGetHttpHalfPortraitId(memberInfo.charId, function(nativeTextureId)
    if not self.uiBinder then
      return
    end
    if nativeTextureId ~= nil and nativeTextureId ~= 0 then
      memberItem.Ref:SetVisible(memberItem.img_idcard, false)
      memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
      memberItem.rimg_idcard:SetNativeTexture(nativeTextureId)
    end
  end)
end

function Team_enterView:teamRefreshActivityVoteResult(resultData)
  if resultData == nil then
    return
  end
  local unit = self.units["member" .. resultData.charId]
  if unit then
    unit.Ref:SetVisible(unit.img_select, resultData.isAgree)
    unit.Ref:SetVisible(unit.cont_login, not resultData.isAgree)
  end
end

function Team_enterView:hideActivityLeaderCancelBtn()
  if self.selfIsLeader_ then
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
  end
end

function Team_enterView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.HideActivityLeaderCancelBtn, self.hideActivityLeaderCancelBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.TeamRefreshActivityVoteResult, self.teamRefreshActivityVoteResult, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchPlayerInfoChange, self.teamMatchRefreshActivityVoteResult, self)
end

function Team_enterView:teamMatchRefreshActivityVoteResult()
  local memberList = self.matchData_:GetMatchPlayerInfo()
  for k, v in pairs(memberList) do
    local memberInfo = v
    local memberItem = self.units["member" .. memberInfo.charId]
    if memberItem then
      memberItem.Ref:SetVisible(memberItem.img_select, memberInfo.readyStatus == E.RedayType.Ready)
      memberItem.Ref:SetVisible(memberItem.cont_login, memberInfo.readyStatus ~= E.RedayType.Ready)
    else
      if self.readyMap == nil then
        self.readyMap = {}
      end
      if memberInfo.readyStatus == E.RedayType.Ready then
        table.insert(self.readyMap, memberInfo.charId)
      end
    end
  end
end

function Team_enterView:OnRefresh()
end

return Team_enterView
