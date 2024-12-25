local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_praise_windowView = class("Hero_dungeon_praise_windowView", super)
local WorldProxy = require("zproxy.world_proxy")
local titleColor = {
  [3] = "ff9578ff",
  [6] = "00D1ffff",
  [7] = "d7ff00ff"
}

function Hero_dungeon_praise_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_praise_window")
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_praise_window")
  self.heroVm_ = Z.VMMgr.GetVM("hero_dungeon_copy_window")
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.dungeonData_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.friendVm_ = Z.VMMgr.GetVM("friends_main")
  self.entityVM_ = Z.VMMgr.GetVM("entity")
end

function Hero_dungeon_praise_windowView:initWidgets()
  self.playerLayoutTran_ = self.uiBinder.group_content.layout_play_info
  self.leaveBtn_ = self.uiBinder.group_content.btn_leave
  self.continueBtn_ = self.uiBinder.group_content.btn_continue
  self.actionBtn_ = self.uiBinder.group_content.btn_action
  self.anim_ = self.uiBinder.anim
end

function Hero_dungeon_praise_windowView:OnActive()
  self:initWidgets()
  self:startAnimatedShow()
  self.entChar_ = Z.PbEnum("EEntityType", "EntChar")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294965247, true)
  self.praiseTab_ = {}
  self.isPlanetmemory_ = false
  self.allSlider_ = {}
  self.allUIModel = {}
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  local dungeonType = dungeonVm.GetCurrDungeonType()
  local isLeader = self.teamVm_.GetYouIsLeader()
  if dungeonType and dungeonType == E.DungeonType.Planetmemory then
    self.isPlanetmemory_ = true
  end
  self.uiBinder.group_content.Ref:SetVisible(self.continueBtn_, self.isPlanetmemory_ and isLeader)
  self:creatPlayerInfo()
  self:BindEvents()
end

function Hero_dungeon_praise_windowView:creatPlayerInfo()
  local teamMembers = self.teamVm_.GetTeamMemData()
  local titles = {}
  local allTitles = Z.ContainerMgr.DungeonSyncData.title.titleList
  local titleTab = Z.TableMgr.GetTable("DungeonTitleTableMgr")
  for key, value in pairs(allTitles) do
    local charId = self.entityVM_.UuidToEntId(key - self.entChar_)
    titles[charId] = value
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local prefabPath = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "praise_tpl")
    if prefabPath == nil or prefabPath == "" then
      return
    end
    local memberCount = 0
    for i = 1, #teamMembers do
      local memberInfo = teamMembers[i]
      if not memberInfo.isAi then
        memberCount = memberCount + 1
      end
    end
    local vUserPos = self.dungeonData_.TeamDisplayData.vUserPos
    for i = 1, #teamMembers do
      local memberInfo = teamMembers[i]
      if not memberInfo.isAi then
        local charId = memberInfo.charId
        local uuid = self.entityVM_.EntIdToUuid(charId, self.entChar_)
        local enit = Z.EntityMgr:GetEntity(uuid)
        if enit then
          do
            local playItem = self:AsyncLoadUiUnit(prefabPath, "playerinfo" .. i, self.playerLayoutTran_)
            if playItem == nil then
              return
            end
            playItem.lab_name.text = memberInfo.socialData and memberInfo.socialData.basicData.name or ""
            local titeInfoList_ = {}
            if titles[charId] then
              titeInfoList_ = titles[charId].titleInfo
            end
            local dungeonTitles = {}
            for key, value in pairs(titeInfoList_) do
              table.insert(dungeonTitles, value)
            end
            table.sort(dungeonTitles, function(a, b)
              local titkeA = titleTab.GetRow(a.titleId)
              local titkeB = titleTab.GetRow(b.titleId)
              if titkeA and titkeB then
                return titkeA.Weight > titkeB.Weight
              end
            end)
            playItem.lab_name_01.Ref.UIComp:SetVisible(dungeonTitles[1] ~= nil)
            playItem.lab_name_02.Ref.UIComp:SetVisible(dungeonTitles[2] ~= nil)
            for index, titleInfo in ipairs(dungeonTitles) do
              if index < 3 then
                local dungeonTitle = titleTab.GetRow(titleInfo.titleId)
                if dungeonTitle then
                  do
                    local node = playItem["lab_name_0" .. index]
                    local color = titleColor[dungeonTitle.Id]
                    if color then
                      node.lab_name.text = string.format("<color=#%s>%s</color>", color, dungeonTitle.Name)
                    else
                      node.lab_name.text = dungeonTitle.Name
                    end
                    self:AddClick(node.lab_name_btn, function()
                      self:openTitleTips(node.lab_name_trans, dungeonTitle)
                    end)
                  end
                end
              end
            end
            playItem.slider_praise.maxValue = memberCount - 1
            self.allSlider_[charId] = playItem.slider_praise
            self.allSlider_[charId].value = 0
            local isFriend = true
            if charId ~= Z.ContainerMgr.CharSerialize.charId then
              isFriend = self.friendMainData_:IsFriendByCharId(charId)
            else
              playItem.Ref:SetVisible(playItem.btn_praise, 1 < memberCount)
            end
            playItem.Ref:SetVisible(playItem.btn_friend, not isFriend)
            local v3 = Vector3.zero
            if vUserPos and vUserPos[charId] then
              v3.x = vUserPos[charId].pos.x
              v3.y = vUserPos[charId].pos.y
              v3.z = vUserPos[charId].pos.z
            else
              v3 = enit:GetLocalAttrVirtualPos()
            end
            local v2 = ZTransformUtility.WorldToScreenPoint(v3, false, nil)
            local _, pos = ZTransformUtility.ScreenPointToLocalPointInRectangle(playItem.Trans, Vector2.New(v2.x, v2.y), nil)
            v3.x, v3.y, v3.z = pos.x, 0, 0
            playItem.Trans.localPosition = v3
            playItem.effect_praise:SetEffectGoVisible(false)
            self:AddAsyncClick(playItem.btn_praise, function()
              if self.praiseTab_[uuid] == nil then
                playItem.effect_praise:SetEffectGoVisible(true)
                self.praiseTab_[uuid] = uuid
                self.vm_.AsyncDungeonVote(uuid, self.cancelSource)
              end
            end)
            playItem.Ref:SetVisible(playItem.btn_friend, not memberInfo.isAi)
            self:AddAsyncClick(playItem.btn_friend, function()
              local ret = self.friendVm_.AsyncSendAddFriend(charId, E.FriendAddSource.EDungeon, self.cancelSource:CreateToken())
              if ret then
                playItem.Ref:SetVisible(playItem.btn_friend, false)
              end
            end)
          end
        end
      end
    end
    self:syncVote()
  end)()
end

function Hero_dungeon_praise_windowView:syncVote()
  local tab = self.vm_.GetLikedAction()
  local allVotes = Z.ContainerMgr.DungeonSyncData.vote.vote
  for key, value in pairs(allVotes) do
    local charId = self.entityVM_.UuidToEntId(key - self.entChar_)
    if self.allSlider_[charId] then
      self.allSlider_[charId].value = value
      for k, v in pairs(tab) do
        if value == tonumber(v[1]) then
          self:playAnim(charId, tonumber(v[2]))
        end
      end
    end
  end
end

function Hero_dungeon_praise_windowView:openTitleTips(playItem, titleData)
  if titleData then
    Z.CommonTipsVM.ShowTipsTitleContent(playItem, titleData.Name, titleData.Content)
  end
end

function Hero_dungeon_praise_windowView:playAnim(charId, animaId)
  if charId == Z.EntityMgr.PlayerEnt.EntId then
    Z.ZAnimActionPlayMgr:PlayAction(animaId, true)
  end
end

function Hero_dungeon_praise_windowView:updatePraiseEvent(voteData)
  local tab = self.vm_.GetLikedAction()
  for key, value in pairs(voteData) do
    local charId = self.entityVM_.UuidToEntId(key - self.entChar_)
    if self.allSlider_[charId] then
      self.allSlider_[charId].value = value
      for k, v in pairs(tab) do
        if value == tonumber(v[1]) then
          self:playAnim(charId, tonumber(v[2]))
        end
      end
    end
  end
end

function Hero_dungeon_praise_windowView:OnDeActive()
  Z.UITimelineDisplay:ClearTimeLine()
  Z.CommonTipsVM.CloseTipsTitleContent()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294965247, false)
end

function Hero_dungeon_praise_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Dungeon.UpdateVoteView, self.updatePraiseEvent, self)
  self.leaveBtn_:AddListener(function()
    self.anim_:CoroPlay(Z.DOTweenAnimType.Close, function()
      Z.CoroUtil.create_coro_xpcall(function()
        self.vm_.QuitDungeon(self.cancelSource:CreateToken())
      end)()
    end, function(err)
    end)
  end)
  self:AddClick(self.continueBtn_, function()
    self.heroVm_.OnContinueExplore(self.cancelSource:CreateToken())
  end)
  self:AddClick(self.actionBtn_, function()
    Z.UIMgr:OpenView("expression")
  end)
end

function Hero_dungeon_praise_windowView:startAnimatedShow()
  self.anim_:Restart(Z.DOTweenAnimType.Open)
end

function Hero_dungeon_praise_windowView:OnRefresh()
end

return Hero_dungeon_praise_windowView
