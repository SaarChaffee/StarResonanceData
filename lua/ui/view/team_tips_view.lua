local super = require("ui.ui_view_base")
local Team_tipsView = class("Team_tipsView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local inputKeyDescComp = require("input.input_key_desc_comp")
local teamApplyItem = require("ui.component.apply_tips.team_apply_tips")

function Team_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_tips", "main/team/main_team_tips", true)
  self.tipsData = Z.DataMgr.Get("team_tip_data")
  self.acceptInputKeyDescComp_ = inputKeyDescComp.new()
  self.refuseInputKeyDescComp_ = inputKeyDescComp.new()
end

function Team_tipsView:OnActive()
  self.timeDict = {}
  self.itemInfo_ = {}
  self.curInfo_ = nil
  self.applyTips_ = {}
  self:BindEvents()
  self:refreshTipsInfoByData()
end

function Team_tipsView:OnDeActive()
  self.acceptInputKeyDescComp_:UnInit()
  self.refuseInputKeyDescComp_:UnInit()
end

function Team_tipsView:refreshTipsInfo(info)
  local unitName = info.tipsType .. "_" .. info.charId .. "_" .. info.content
  if self.timeDict[unitName] or self.itemInfo_[unitName] then
    return
  end
  self.curInfo_ = info
  self.itemInfo_[unitName] = info
  if not self.units[unitName] then
    Z.CoroUtil.create_coro_xpcall(function()
      local path = info.path
      if path == nil then
        if Z.IsPCUI then
          path = GetLoadAssetPath(Z.ConstValue.Team.TipsFlsnowTplPC)
        else
          path = GetLoadAssetPath(Z.ConstValue.Team.TipsFlsnowTpl)
        end
      end
      local item = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.layout_content.transform)
      item.Ref.UIComp:SetVisible(false)
      local socialData
      if info.charId and tonumber(info.charId) then
        local socialVM = Z.VMMgr.GetVM("social")
        socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(info.charId, self.cancelSource:CreateToken())
      end
      self:initItemInfo(item, info, socialData, unitName)
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
      self:tipsDuration(item, unitName, info.cd)
      item.anim:Restart(Z.DOTweenAnimType.Open)
      item.Ref.UIComp:SetVisible(true)
      self.acceptInputKeyDescComp_:Init(134, item.com_icon_key_accept)
      self.refuseInputKeyDescComp_:Init(133, item.com_icon_key_refuse)
    end)()
  end
end

function Team_tipsView:refreshTipsInfoByData()
  self.curInfo_ = nil
  if table.zcount(self.itemInfo_) > 0 then
    return
  end
  local info = self.tipsData:GetCacheData()
  if info then
    self:refreshTipsInfo(info)
  end
end

function Team_tipsView:initItemInfo(item, info, socialData, unitName)
  local isAction = info.tipsType == E.InvitationTipsType.MultActionInvite
  self:resetItem(item)
  item.Ref:SetVisible(item.img_apple, not isAction)
  item.Ref:SetVisible(item.img_action, isAction)
  if info.tipsType == E.InvitationTipsType.MultActionInvite then
    self:showMultActionImg(item, info.funcParam.vActionId)
  elseif info.tipsType == E.InvitationTipsType.UnionHunt or info.tipsType == E.InvitationTipsType.UnionWarDance or info.tipsType == E.InvitationTipsType.LeisureActivity then
    self:showUnionHuntInvitation(item, info)
  elseif socialData then
    if item.cont_player_portrait_item.img_active_icon then
      item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_active_icon, false)
    end
    playerPortraitHgr.InsertNewPortraitBySocialData(item.cont_player_portrait_item, socialData, nil, self.cancelSource:CreateToken())
  end
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
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_portrait, false)
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.rimg_portrait, false)
  item.cont_player_portrait_item.Ref:SetVisible(item.cont_player_portrait_item.img_active_icon, true)
  item.cont_player_portrait_item.img_active_icon:SetImage(config.Icon)
end

function Team_tipsView:tipsDuration(item, unitName, cd)
  local duration = tonumber(cd)
  if not duration or duration <= 0 then
    return
  end
  local time = 0
  if self.timeDict[unitName] == nil then
    self.timeDict[unitName] = self.timerMgr:StartFrameTimer(function()
      time = time + Time.deltaTime
      item.img_time.fillAmount = 1 - time / duration
      if time >= duration then
        item.img_time.fillAmount = 0
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
      if self.applyTips_[unitName] then
        self.applyTips_[unitName]:UnInit()
        self.applyTips_[unitName] = nil
      end
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

function Team_tipsView:OnInputAcceptAction()
  if self.curInfo_ == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = self.curInfo_.tipsType .. "_" .. self.curInfo_.charId .. "_" .. self.curInfo_.content
    if self.curInfo_.funcParam then
      self.curInfo_.func(self.curInfo_.funcParam, true, self.cancelSource)
    else
      self.curInfo_.func(true, self.cancelSource)
    end
    self:clearTipsUnit(unitName)
  end)()
end

function Team_tipsView:OnInputRefuseAction()
  if self.curInfo_ == nil then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = self.curInfo_.tipsType .. "_" .. self.curInfo_.charId .. "_" .. self.curInfo_.content
    if self.curInfo_.funcParam then
      self.curInfo_.func(self.curInfo_.funcParam, false, self.cancelSource)
    else
      self.curInfo_.func(false, self.cancelSource)
    end
    self:clearTipsUnit(unitName)
  end)()
end

function Team_tipsView:OnTriggerInputAction(inputActionEventData)
  if not Z.IsPCUI then
    return
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.TipsAgree then
    self:OnInputAcceptAction()
  elseif inputActionEventData.actionId == Z.RewiredActionsConst.TipsRefuse then
    self:OnInputRefuseAction()
  end
end

return Team_tipsView
