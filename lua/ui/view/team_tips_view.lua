local super = require("ui.ui_view_base")
local Team_tipsView = class("Team_tipsView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Team_tipsView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.team_tips.PrefabPath = "main/team/main_team_tips_pc"
  else
    Z.UIConfig.team_tips.PrefabPath = "main/team/main_team_tips"
  end
  super.ctor(self, "team_tips")
  self.tipsData = Z.DataMgr.Get("team_tip_data")
end

function Team_tipsView:OnActive()
  self.timeDict = {}
  self.itemInfo_ = {}
  self:BindEvents()
  self:refreshTipsInfoByData()
end

function Team_tipsView:OnDeActive()
end

function Team_tipsView:refreshTipsInfo(info)
  local unitName = info.tipsType .. "_" .. info.charId .. "_" .. info.content
  if self.timeDict[unitName] or self.itemInfo_[unitName] then
    return
  end
  self.itemInfo_[unitName] = info
  if not self.units[unitName] then
    Z.CoroUtil.create_coro_xpcall(function()
      local path
      if Z.IsPCUI then
        path = GetLoadAssetPath(Z.ConstValue.Team.TipsFlsnowTplPC)
      else
        path = GetLoadAssetPath(Z.ConstValue.Team.TipsFlsnowTpl)
      end
      local item = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.layout_content.transform)
      local socialData
      if info.charId and tonumber(info.charId) then
        local socialVM = Z.VMMgr.GetVM("social")
        socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(info.charId, self.cancelSource:CreateToken())
      end
      self:initItemInfo(item, info, socialData)
      self:AddAsyncClick(item.cont_btn_accept, function()
        self:clearTipsUnit(unitName)
        if info.funcParam then
          info.func(info.funcParam, true, self.cancelSource)
        else
          info.func(true, self.cancelSource)
        end
      end, nil, nil)
      self:AddAsyncClick(item.cont_btn_return, function()
        self:clearTipsUnit(unitName)
        if info.funcParam then
          info.func(info.funcParam, false, self.cancelSource)
        else
          info.func(false, self.cancelSource)
        end
      end, nil, nil)
      self:TipsDuration(item, unitName, info.cd)
      item.anim:Restart(Z.DOTweenAnimType.Open)
    end)()
  end
end

function Team_tipsView:refreshTipsInfoByData()
  if table.zcount(self.itemInfo_) > 0 then
    return
  end
  local info = self.tipsData:GetCacheData()
  if info then
    self:refreshTipsInfo(info)
  end
end

function Team_tipsView:initItemInfo(item, info, socialData)
  self:resetItem(item)
  if info.tipsType == E.InvitationTipsType.MultActionInvite then
    self:showMultActionImg(item, info.funcParam.vActionId)
  elseif info.tipsType == E.InvitationTipsType.UnionHunt or info.tipsType == E.InvitationTipsType.UnionWarDance then
    self:showUnionHuntInvitation(item, info)
  elseif socialData then
    item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_active_icon, false)
    playerPortraitHgr.InsertNewPortraitBySocialData(item.cont_player_portrait_item, socialData)
  end
  local isAction = info.tipsType == E.InvitationTipsType.MultActionInvite
  item.Ref:SetVisible(item.img_apple, not isAction)
  item.Ref:SetVisible(item.img_action, isAction)
  if isAction then
    item.lab_action_name.text = info.content
  else
    item.lab_apple_name.text = info.content
  end
  if socialData and socialData.basicData then
    item.lab_name.text = socialData.basicData.name
  end
end

function Team_tipsView:showUnionHuntInvitation(item, info)
  item.Ref:SetVisible(item.node_team, false)
  item.Ref:SetVisible(item.node_worldquest, true)
  item.lab_worldquest.text = info.content
end

function Team_tipsView:resetItem(item)
  item.Ref:SetVisible(item.node_team, true)
  item.Ref:SetVisible(item.node_worldquest, false)
end

function Team_tipsView:showMultActionImg(item, vActionId)
  if item == nil or vActionId == nil then
    return
  end
  local config = Z.TableMgr.GetTable("EmoteTableMgr").GetRow(vActionId)
  if config == nil then
    logError("EmoteTable not have actionid = " .. vActionId)
    return
  end
  local multactionPath = self.uiBinder.prefab:GetString("multactionPath")
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_portrait, false)
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.rimg_portrait, false)
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_active_icon, true)
  item.cont_player_portrait_item.img_active_icon:SetImage(string.format("%s%s", multactionPath, config.Icon))
end

function Team_tipsView:TipsDuration(item, unitName, cd)
  local duration = tonumber(cd)
  local time = 0
  item.slider_time.value = duration
  item.slider_time.maxValue = duration
  if self.timeDict[unitName] == nil then
    self.timeDict[unitName] = self.timerMgr:StartFrameTimer(function()
      time = time + Time.deltaTime
      item.slider_time.value = duration - time
      if time >= duration then
        item.slider_time.value = 0
        self:callFailFunc(unitName)
        self:clearTipsUnit(unitName)
      end
    end, 1, -1)
  end
end

function Team_tipsView:callFailFunc(unitName)
  local info = self.itemInfo_[unitName]
  if info and info.isCallFailFunc then
    if info.funcParam then
      info.func(info.funcParam, false, self.cancelSource)
    else
      info.func(false, self.cancelSource)
    end
  end
end

function Team_tipsView:clearTipsUnit(unitName)
  Z.CoroUtil.create_coro_xpcall(function()
    if self.timeDict[unitName] then
      self.timeDict[unitName]:Stop()
      self.timeDict[unitName] = nil
      self.itemInfo_[unitName] = nil
      self.units[unitName].anim:Play(Z.DOTweenAnimType.Close)
      self:RemoveUiUnit(unitName)
    end
    self:refreshTipsInfoByData()
  end)()
end

local clickFriendApply = function(funcParam, isAgree, cancelSource)
  local friendsMainVm = Z.VMMgr.GetVM("friends_main")
  friendsMainVm.AsyncProcessAddRequest(funcParam.charId, isAgree, funcParam.name, cancelSource:CreateToken())
end

function Team_tipsView:addFriendApply(applicationList)
  Z.CoroUtil.create_coro_xpcall(function()
    for i = #applicationList, 1, -1 do
      local applyCharId = applicationList[i].charId
      local socialVm = Z.VMMgr.GetVM("social")
      local socialData = socialVm.AsyncGetHeadAndHeadFrameInfo(applyCharId, self.cancelSource:CreateToken())
      local info = {
        charId = applyCharId,
        tipsType = E.InvitationTipsType.FriendApply,
        content = Lang("RequestFriendApply"),
        func = clickFriendApply,
        cd = Z.Global.FriendRequestNoticeShowTime,
        funcParam = {
          charId = applyCharId,
          name = socialData.basicData.name
        }
      }
      self:refreshTipsInfo(info)
    end
  end)()
end

function Team_tipsView:removeTipsInfo(tipsType, charId)
  local unitName = tipsType .. "_" .. charId
  self:RemoveUiUnit(unitName)
end

function Team_tipsView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.InvitationRefreshTips, self.refreshTipsInfo, self)
  Z.EventMgr:Add(Z.ConstValue.InvitationRefreshTipsByData, self.refreshTipsInfoByData, self)
  Z.EventMgr:Add(Z.ConstValue.InvitationClearTipsUnit, self.clearTipsUnit, self)
  Z.EventMgr:Add(Z.ConstValue.InvitationRemoveTipsUnit, self.removeTipsInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendAddApply, self.addFriendApply, self)
end

return Team_tipsView
