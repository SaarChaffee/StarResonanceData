local super = require("ui.ui_view_base")
local Noticetip_popView = class("Noticetip_popView", super)
local popItem = require("ui.component.tips.noticetip_pop_item")
local type2AudioTable = {
  [E.TipsType.BottomTips] = "UI_Event_Notice_Tip",
  [E.TipsType.DungeonChallengeWinTips] = "UI_Event_Dungeon_Victory",
  [E.TipsType.DungeonChallengeFailTips] = "UI_Event_Dungeon_Fail",
  [E.TipsType.DungeonRedTips] = "UI_Event_Error_Tip",
  [E.TipsType.DungeonGreenTips] = "UI_Event_Magic_A",
  [E.TipsType.DungeonSpecialTips] = "UI_Event_Notice_Tip"
}

function Noticetip_popView:ctor()
  self.uiBinder = nil
  super.ctor(self, "noticetip_pop")
  self.data_ = Z.DataMgr.Get("noticetip_data")
  self.viewData = nil
end

function Noticetip_popView:OnActive()
  self.popItemBinderPoolCache_ = {}
  self.itemInShowQueue_ = {}
  self.ShowMsgItem_ = {}
  self.normalShowQueue_ = {}
  self.node_pop_tip_ = self.uiBinder.node_pop_tip
  self.item_1_ = self.uiBinder.node_pop_tip.item_1
  self.item_2_ = self.uiBinder.node_pop_tip.item_2
  self.item_3_ = self.uiBinder.node_pop_tip.item_3
  self.bottomTipsRect_ = self.uiBinder.node_pop_tip.parkour_tooltip_bottom_tpl
  self.bottomTipsLab_ = self.uiBinder.node_pop_tip.lab_info
  self.winTipsZwidgetAnim_ = self.uiBinder.node_pop_tip.tips_noticetip_win
  self.failTipsZwidgetAnim_ = self.uiBinder.node_pop_tip.tips_noticetip_fail
  self.dungeonGreenNode_ = self.uiBinder.node_pop_tip.node_dungeon_green
  self.dungeonRedNode_ = self.uiBinder.node_pop_tip.node_dungeon_red
  self.dungeonGreenLab_ = self.uiBinder.node_pop_tip.lab_dungeon_green
  self.dungeonRedLab_ = self.uiBinder.node_pop_tip.lab_dungeon_red
  self.dungeonGreenEff_ = self.uiBinder.node_pop_tip.node_eff_green
  self.dungeonRedEff_ = self.uiBinder.node_pop_tip.node_eff_red
  self.winTipsLable_ = self.uiBinder.node_pop_tip.lab_win
  self.failTipsLable_ = self.uiBinder.node_pop_tip.lab_fail
  self.spTipsAnimComp_ = self.uiBinder.node_pop_tip.tips_noticetip_special
  self.spTipsLable_ = self.uiBinder.node_pop_tip.lab_speclal
  self.popItemBinderPoolCache_[1] = self.item_1_
  self.popItemBinderPoolCache_[2] = self.item_2_
  self.popItemBinderPoolCache_[3] = self.item_3_
  self:SetNodeState()
  self:BindEvents()
end

function Noticetip_popView:SetNodeState()
  self.node_pop_tip_.Ref:SetVisible(self.item_1_.Ref, false)
  self.node_pop_tip_.Ref:SetVisible(self.item_2_.Ref, false)
  self.node_pop_tip_.Ref:SetVisible(self.item_3_.Ref, false)
  self.node_pop_tip_.Ref:SetVisible(self.bottomTipsRect_, false)
  self.node_pop_tip_.Ref:SetVisible(self.winTipsZwidgetAnim_, false)
  self.node_pop_tip_.Ref:SetVisible(self.failTipsZwidgetAnim_, false)
  self.node_pop_tip_.Ref:SetVisible(self.spTipsAnimComp_, false)
  self.node_pop_tip_.Ref:SetVisible(self.dungeonRedNode_, false)
  self.node_pop_tip_.Ref:SetVisible(self.dungeonGreenNode_, false)
end

function Noticetip_popView:OnRefresh()
  if not self.viewData then
    local msgItem = self.data_:DequeuePopData()
    self:showPopTip(msgItem)
  elseif self.viewData.viewType == E.TipsType.BottomTips then
    self:PopBottomPositonTips()
  elseif self.viewData.viewType == E.TipsType.DungeonChallengeWinTips then
    self:PopDungeonEndTips(true)
  elseif self.viewData.viewType == E.TipsType.DungeonChallengeFailTips then
    self:PopDungeonEndTips(false)
  elseif self.viewData.viewType == E.TipsType.DungeonSpecialTips then
    self:PopDungeonSpTips()
  end
  if self.viewData and type2AudioTable[self.viewData.viewType] then
    Z.AudioMgr:Play(type2AudioTable[self.viewData.viewType])
  end
end

function Noticetip_popView:OnDeActive()
  self:SetNodeState()
  self:UnBindEvents()
  self.popItemBinderPoolCache_ = nil
  self.popItemCache_ = nil
  self.itemInShowQueue_ = nil
  self.normalShowQueue_ = nil
  self.ShowMsgItem_ = nil
end

function Noticetip_popView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.CLoseBottomPositonTips, self)
end

function Noticetip_popView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.SceneActionEvent.EnterScene, self.CLoseBottomPositonTips, self)
end

function Noticetip_popView:showPopTip(msgItem)
  if #self.normalShowQueue_ >= 3 then
    self.data_:EnqueuePopData(msgItem)
    return
  end
  local viewTypeIsRed = msgItem.viewType == E.TipsType.DungeonRedTips and msgItem.viewType ~= E.TipsType.PopTip
  if msgItem.viewType == E.TipsType.DungeonRedTips or msgItem.viewType == E.TipsType.DungeonGreenTips then
    self:PopEditorDungeonTips(viewTypeIsRed, msgItem)
    return
  end
  if self.popItemCache_ == nil then
    self.popItemCache_ = {}
    for index, value in ipairs(self.popItemBinderPoolCache_) do
      local item = popItem.new(value, self)
      table.insert(self.popItemCache_, item)
    end
  end
  if not msgItem or self.data_:CheckConfigRepeat(self.ShowMsgItem_, msgItem) then
    return
  end
  table.insert(self.ShowMsgItem_, msgItem)
  local config = msgItem.config
  if config.Audio ~= "" then
    Z.AudioMgr:Play(config.Audio)
  end
  local showInterval = (config.RepeatPlay[2] or 0) * 0.001
  msgItem.repeatCount = math.max(config.RepeatPlay[1] or 1, 1)
  local showAction = function()
    msgItem.repeatCount = msgItem.repeatCount - 1
    self:popTipAnimation(msgItem)
  end
  table.insert(self.normalShowQueue_, 1, msgItem)
  self.timerMgr:StartTimer(function()
    showAction()
    if msgItem.repeatCount > 0 then
      self.timerMgr:StartTimer(showAction, config.DurationTime + showInterval, msgItem.repeatCount)
    end
  end, config.Delay)
end

function Noticetip_popView:popTipAnimation(msgItem)
  local item = table.remove(self.popItemCache_, 1)
  if item == nil then
    item = table.remove(self.itemInShowQueue_, #self.itemInShowQueue_)
    item:ForceStop()
  end
  table.insert(self.itemInShowQueue_, 1, item)
  
  function item.OnEnd(force)
    for index, value in pairs(self.ShowMsgItem_) do
      if value == msgItem then
        table.remove(self.ShowMsgItem_, index)
        break
      end
    end
    for index, value in pairs(self.itemInShowQueue_) do
      if value == item then
        table.remove(self.itemInShowQueue_, index)
        break
      end
    end
    if not force then
      table.insert(self.popItemCache_, item)
    end
    table.remove(self.normalShowQueue_, #self.normalShowQueue_)
    local msgItem = self.data_:DequeuePopData()
    if msgItem then
      self:showPopTip(msgItem)
    end
  end
  
  item:Init(msgItem)
  Z.DataMgr.Get("tips_data"):AddSystemTipInfo(E.ESystemTipInfoType.MessageInfo, msgItem.config.Id, msgItem.content)
  for index, showItem in ipairs(self.itemInShowQueue_) do
    showItem:PopToIndexPosition(index - 1)
  end
end

function Noticetip_popView:CLoseBottomPositonTips()
  if self.timer then
    self.timerMgr:StopTimer(self.timer)
    self.node_pop_tip_.Ref:SetVisible(self.bottomTipsRect_, false)
  end
end

function Noticetip_popView:PopBottomPositonTips()
  local itemData = self.viewData
  if not itemData then
    return
  end
  self.node_pop_tip_.Ref:SetVisible(self.bottomTipsRect_, true)
  self.bottomTipsLab_.text = itemData.content
  local detailTime = itemData.param.val
  if not detailTime or detailTime <= 0 then
    return
  end
  self.timer = self.timerMgr:StartTimer(function()
    detailTime = detailTime - 1
    itemData.param.val = detailTime
    self.bottomTipsLab_.text = Z.Placeholder.Placeholder(itemData.config.Content, itemData.param)
    if detailTime < 0 then
      self.node_pop_tip_.Ref:SetVisible(self.bottomTipsRect_, false)
      self.timerMgr:StopTimer(self.timer)
    end
  end, 1, detailTime, true, function()
    self.node_pop_tip_.Ref:SetVisible(self.bottomTipsRect_, false)
  end)
end

function Noticetip_popView:PopEditorDungeonTips(isRed, itemData)
  if not itemData then
    return
  end
  table.insert(self.normalShowQueue_, 1, itemData)
  self.node_pop_tip_.Ref:SetVisible(self.dungeonRedNode_, false)
  self.node_pop_tip_.Ref:SetVisible(self.dungeonGreenNode_, false)
  local tipsNode, tipsLab, tipsAnim, tipsEff
  if isRed then
    tipsNode = self.dungeonRedNode_
    tipsLab = self.dungeonRedLab_
    tipsAnim = "anim_tips_dungeon_bar_red_start_an"
    tipsEff = self.dungeonRedEff_
  else
    tipsNode = self.dungeonGreenNode_
    tipsLab = self.dungeonGreenLab_
    tipsAnim = "anim_tips_dungeon_bar_green_start_an"
    tipsEff = self.dungeonGreenEff_
  end
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(tipsEff)
  self.node_pop_tip_.Ref:SetVisible(tipsNode, true)
  self.node_pop_tip_.anim_dungeon:PlayOnce(tipsAnim)
  tipsLab.text = itemData.content
  local countTime = math.ceil(itemData.config.Delay + itemData.config.DurationTime)
  self.timer = self.timerMgr:StartTimer(function()
  end, 1, countTime, true, function()
    self.node_pop_tip_.Ref:SetVisible(tipsNode, false)
    table.remove(self.normalShowQueue_, #self.normalShowQueue_)
    local msgItem = self.data_:DequeuePopData()
    if msgItem then
      self:showPopTip(msgItem)
    end
  end)
end

function Noticetip_popView:PopDungeonEndTips(isWin)
  local itemData = self.viewData
  if not itemData then
    return
  end
  local tipsAnimComp_, closeAnimName
  if isWin then
    tipsAnimComp_ = self.winTipsZwidgetAnim_
    self.node_pop_tip_.Ref:SetVisible(self.winTipsZwidgetAnim_, true)
    local winOpenAnim = self.uiBinder.prefab_cache:GetString("winOpenAnim")
    if winOpenAnim then
      self.winTipsZwidgetAnim_:PlayOnce(winOpenAnim)
    end
    closeAnimName = self.uiBinder.prefab_cache:GetString("winCloseAnim")
    self.winTipsLable_.text = itemData.content
  else
    tipsAnimComp_ = self.failTipsZwidgetAnim_
    self.node_pop_tip_.Ref:SetVisible(self.failTipsZwidgetAnim_, true)
    local failOpenAnim = self.uiBinder.prefab_cache:GetString("failOpenAnim")
    if failOpenAnim then
      self.failTipsZwidgetAnim_:PlayOnce(failOpenAnim)
    end
    closeAnimName = self.uiBinder.prefab_cache:GetString("failCloseAnim")
    self.failTipsLable_.text = itemData.content
  end
  local cancelSourceToken = self.cancelSource:CreateToken()
  self.timerMgr:StartTimer(function()
    if tipsAnimComp_ and closeAnimName then
      Z.CoroUtil.create_coro_xpcall(function()
        local asyncCall = Z.CoroUtil.async_to_sync(tipsAnimComp_.CoroPlayOnce)
        asyncCall(tipsAnimComp_, closeAnimName, cancelSourceToken)
        self.node_pop_tip_.Ref:SetVisible(tipsAnimComp_, false)
        Z.UIMgr:CloseView(self.viewConfigKey)
        Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
      end)()
    else
      Z.UIMgr:CloseView(self.viewConfigKey)
      Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
    end
  end, itemData.config.Delay + itemData.config.DurationTime)
end

function Noticetip_popView:PopDungeonSpTips()
  local itemData = self.viewData
  if not itemData then
    return
  end
  self.node_pop_tip_.Ref:SetVisible(self.spTipsAnimComp_, true)
  self.spTipsAnimComp_:PlayOnce("anim_tips_noticetip_popup_open")
  self.spTipsLable_.text = itemData.content
  self.timerMgr:StartTimer(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.spTipsAnimComp_:CoroPlayOnce("anim_tips_noticetip_popup_close", self.cancelSource:CreateToken(), function()
        self.node_pop_tip_.Ref:SetVisible(self.spTipsAnimComp_, false)
        Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
      end, function(err)
        Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
        if err == ZUtil.ZCancelSource.CancelException then
          return
        end
        logError(err)
      end)
    end)()
  end, itemData.config.Delay + itemData.config.DurationTime)
end

function Noticetip_popView:ChangeQuestTipsColor(color)
end

return Noticetip_popView
