local super = require("ui.ui_view_base")
local BossbattleView = class("BossbattleView", super)

function BossbattleView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.bossbattle.PrefabPath = "battle/battle_boss_blood_pc_sub"
  else
    Z.UIConfig.bossbattle.PrefabPath = "battle/battle_boss_blood_sub"
  end
  super.ctor(self, "bossbattle")
  self.abnormalStateView_ = require("ui/view/abnormal_state_view").new()
  self.vm = Z.VMMgr.GetVM("bossbattle")
end

function BossbattleView:OnActive()
  self.isPlayingAnim = false
  local uuid = self.vm:GetBossUuid()
  self.dbmInfo_ = {}
  self.buffInfo_ = {
    [1] = {},
    [2] = {}
  }
  self.monsterDataMgr_ = Z.DataMgr.Get("monster_data")
  self.playerEntity = Z.EntityMgr:GetEntity(tostring(Z.EntityMgr.PlayerUuid))
  if uuid == nil then
    logWarning("Boss Uuid is nil !!!")
    self.vm.CloseBossUI()
    return
  end
  self.bossUuid_ = uuid
  local bossEntity = Z.EntityMgr:GetEntity(self.bossUuid_)
  if bossEntity == nil then
    self.vm.SetBossUuid(nil)
    self.vm.CloseBossUI()
    return
  end
  local state = bossEntity:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if state == 9 then
    self.vm.SetBossUuid(nil)
    self.vm.CloseBossUI()
    return
  end
  self.uiBinder.boss_blood_comp:InitComponent(uuid)
  self.abnormalStateView_:Active({
    viewType = E.AbnormalPanelType.Boss
  }, self.uiBinder.node_abnormal_container)
  self:BindEvents()
  self:BindLuaAttrWatchers()
end

function BossbattleView:OnRefresh()
end

function BossbattleView:OnDeActive()
  self.uiBinder.boss_blood_comp:ResetParams()
  self.monsterId_ = nil
  self:UnBindLuaAttrWatchers()
  Z.CameraMgr:UpdateDarkScene(false, Color.New(0, 0, 0, 1))
  Z.CameraMgr:UpdateRGBSplitGlitch(false, 0, 0)
  self.uiBinder.break_fx:SetEffectGoVisible(false)
  self.abnormalStateView_:DeActive()
  self:ClearAllUnits()
end

function BossbattleView:BindEvents()
  Z.EventMgr:Add("DisplayBossOutOverdriveUI", self.onDisplayBossOutOverdriveUI, self)
end

function BossbattleView:BindLuaAttrWatchers()
  local bossEntity = Z.EntityMgr:GetEntity(self.bossUuid_)
  if bossEntity == nil then
    return
  end
  self.stateToken = self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrState")
  }, bossEntity, self.refreshState)
end

function BossbattleView:UnBindLuaAttrWatchers()
  self:UnBindEntityLuaAttrWatcher(self.stateToken)
end

function BossbattleView:refreshState()
  local bossEntity = Z.EntityMgr:GetEntity(self.bossUuid_)
  if bossEntity == nil then
    return
  end
  local state = bossEntity:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if state == 9 then
    self.vm.CloseBossUI()
  end
end

function BossbattleView:onDisplayBossOutOverdriveUI(isBreak, isWeak)
  self.isPlayingAnim = true
  local clipName
  if isBreak then
    clipName = "anim_fx_bossbattle"
  end
  if isWeak then
    clipName = "anim_fx_bossBreakStagebg_End"
  end
  self.abnormalStateView_:UnBindLuaAttrWatchers()
  Z.CoroUtil.coro_xpcall(function()
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.img_break_bg.CoroPlayOnce)
    asyncCall(self.uiBinder.img_break_bg, clipName, self.cancelSource:CreateToken())
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_break_bg, false)
    self.isPlayingAnim = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_boss_fury_break, false)
    self.abnormalStateView_:BindLuaAttrWatchers()
  end)
end

return BossbattleView
