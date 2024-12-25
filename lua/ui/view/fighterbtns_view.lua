local UI = Z.UI
local super = require("ui.ui_subview_base")
local FighterBtnsView = class("FighterBtnsView", super)
local battleResUIHelper = require("ui.fighter_battle_res.battle_res_ui_helper")
local professionBuffShowHelper = require("ui.fighter_battle_res.profession_buff_show_helper")
local keyIconHelper = require("ui.component.mainui.key_icon_helper")
local QteCreator = require("ui.component.qte.qte_creator")
local PlayerCtrlTmpMgr = require("ui.player_ctrl_btns.player_ctrl_btn_templates")
local ParkourStyleList = require("ui.component.parkour_style_list.parkour_style_list")
local FightBtnConfig = require("ui.component.fight.fight_btn_config")
E.CBTTestFlagEnum = {Hidden = 0, Show = 1}

function FighterBtnsView:ctor(parent)
  self.panel = nil
  self.parentView_ = parent
  local viewConfigKey, assetPath
  if Z.IsPCUI then
    viewConfigKey = "battle_main_node_window_pc"
    assetPath = "battle/battle_main_node_window_pc"
  else
    viewConfigKey = "battle_main_node_window"
    assetPath = "battle/battle_main_node_window"
  end
  super.ctor(self, viewConfigKey, assetPath, UI.ECacheLv.High, parent)
  self.abnormalStateView_ = require("ui/view/abnormal_state_view").new()
  self.quickUseItemComp_ = require("ui/component/mainui/quick_use_item_bar_comp_old").new(self)
  self.vm = Z.VMMgr.GetVM("fighterbtns")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.buffData_ = Z.DataMgr.Get("buff_data")
  self.PCUIBattleCtrlBtnSize = 50
  self.PCUIBattleCtrlBtnSplit = 28
  self.buffNoticeList_ = {}
  self.slotShow_ = {}
  self.slotLock_ = {}
  self.slotInputIgnore_ = {}
  self.node_player_state_barVisible_ = true
  
  function self.onInputAction_(inputActionEventData)
    if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
      return
    end
    if not (self.IsVisible and self.parentView_.IsVisible) or not Z.UIRoot:GetLayerVisible(self.parentView_.uiLayer) then
      return
    end
    if not self.node_player_state_barVisible_ then
      return
    end
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Talent)
  end
end

function FighterBtnsView:OnActive()
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.panel.Ref.ZUIDepth)
  self.panel.Ref.ZUIDepth:AddChildDepth(self.panel.battle_skill_release.effct.ZEff)
  self:startAnimatedShow()
  self.panel.Ref:SetSize(0, 0)
  self.panel.Ref:SetPosition(0, 0)
  self.panel.battle_skill_release.effct.ZEff:SetEffectGoVisible(false)
  self.playerCtrlTmpMgr_ = PlayerCtrlTmpMgr.new(self)
  self:SetVisible(true)
  self:clearBuffNotice()
  self:refreshEventSkillSlot()
  self:refreshBattleResView()
  self:refreshTalentIcon()
  self:showPlayerBlood()
  self:refreshProfessionBuffTips()
  self.extraSlot_ = {}
  self.finalState_ = {}
  self.curUseSkillId_ = 0
  self.take_medicine_item_ = Z.IsPCUI and self.panel.take_medicine_pc_item or self.panel.take_medicine_item
  self.quickUseItemComp_:Init(self.take_medicine_item_, E.ShortcutsItemType.Shortcuts)
  self.buffTipsCount_ = 10
  self.showBuffCountMax_ = 3
  self:EventAddAsyncListener(self.panel.img_equip_damaged.Btn.OnLongPressEvent, function()
    Z.VMMgr.GetVM("equip_system").OpenDamagedTips(self.panel.img_equip_damaged.Trans)
  end)
  self.abnormalStateView_:Active({
    viewType = E.AbnormalPanelType.Self
  }, self.panel.group_blood.abnormalContainer.Trans)
  self:initProfessionBtn()
  self:initSkillPanelToggle()
  self.ParkourStyleList = ParkourStyleList.new(self)
  self:initEquipDamaged()
  self:setTalentTag()
  self:initTestPromptPanel()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self.panel.battle_skill_release.Ref:SetVisible(false)
  self:RegisterInputActions()
  self:InitPCKeyIcon()
  self.panel.node_skill:SetVisible(false)
  self:refreshAutoBattleSwitch()
  self:updateTakeMedicineState()
end

function FighterBtnsView:updateTakeMedicineState()
  local isIgnoreQuickUse = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.QuickUseItem)
  if Z.IsPCUI then
    self.panel.node_112_line:SetVisible(not isIgnoreQuickUse)
  end
  self.take_medicine_item_:SetVisible(not isIgnoreQuickUse)
end

function FighterBtnsView:OnRefresh()
  self:OnOpenAnimShow()
  self:updateBuffNoticeByList()
  self:refreshBtnContainerState()
  self:checkSkillPanelToggleIsOn()
  self:refreshFlightAndGlidingSlot()
  self:refreshUnlockSkillSlot()
  self:refreshUid()
end

function FighterBtnsView:refreshUid()
  self.panel.lab_uid.TMPLab.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
end

function FighterBtnsView:OnOpenAnimShow()
  if self.panel and self.panel.anim_battle then
    self.panel.anim_battle.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  end
end

function FighterBtnsView:checkSkillPanelToggleIsOn(slotId)
  if Z.IsPCUI then
    return
  end
  if self:banSkill() then
    self:refreshSkillCheckBtn(false)
    self:refreshSkillPanel(false)
    return
  end
  local isOpen = self.switchVm_.CheckFuncSwitch(E.FunctionID.EnvResonance)
  if not isOpen then
    self:refreshSkillCheckBtn(false)
    self:refreshSkillPanel(true)
    return
  end
  local skillPanelToggleIsOn = self.vm:GetSkillPanelShow()
  if slotId == 1 then
    skillPanelToggleIsOn = true
  end
  self.panel.toggle_skill.Tog.isOn = skillPanelToggleIsOn
  self:refreshSkillCheckBtn(true)
  self:refreshSkillPanel(skillPanelToggleIsOn)
end

function FighterBtnsView:banSkill()
  local buffDataList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  local banSkill = false
  if buffDataList then
    buffDataList = buffDataList.Value
    for i = 0, buffDataList.count - 1 do
      if buffDataList[i].BuffBaseId == 681701 then
        banSkill = true
      end
    end
  end
  return banSkill
end

function FighterBtnsView:setPcBtnShow(showNum)
  if not Z.IsPCUI then
    return
  end
  if self:banSkill() and showNum == nil then
    showNum = FightBtnConfig[E.PlayerCtrlBtnPCShowBtnType.Less]
  end
  self.slotShow_ = {}
  for k, v in pairs(showNum) do
    self.slotShow_[v] = true
  end
end

function FighterBtnsView:InitPCKeyIcon()
  keyIconHelper.InitKeyIcon(self.take_medicine_item_.main_icon_key, self.take_medicine_item_.main_icon_key, 17)
  keyIconHelper.InitKeyIcon(self.panel.talent_icon_key, self.panel.talent_icon_key, 115)
end

function FighterBtnsView:OnDeActive()
  keyIconHelper.UnInitKeyIcon(self.take_medicine_item_.main_icon_key)
  keyIconHelper.UnInitKeyIcon(self.panel.talent_icon_key)
  self:UnBindLuaAttrWatchers()
  self:UnBindEvents()
  self:UnRegisterInputActions()
  self:ClearBattleRes()
  self:clearBuffNotice()
  self.battleResHelper_ = nil
  self.playerCtrlTmpMgr_:ClearCurTmpCtrlBtns()
  self.playerCtrlTmpMgr_ = nil
  self.abnormalStateView_:DeActive()
  self.quickUseItemComp_:UnInit()
  self.professionBuffShowHelper_:UnInit()
  self.professionBuffShowHelper_ = nil
end

function FighterBtnsView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.OnPorfessionChange, self.Refresh, self)
  Z.EventMgr:Add(Z.ConstValue.OnBattleResChange, self.refreshBattleResView, self)
  Z.EventMgr:Add(Z.ConstValue.CreateQteUIUnit, self.CreateQteUIUnit, self)
  Z.EventMgr:Add("InputQuickUseItem", self.onInputQuickUse, self)
  Z.EventMgr:Add(Z.ConstValue.OnChangeSkillSlotByVm, self.OnSkillSlotChangedByVm, self)
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.inputUIFresh, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.RefreshEquipRepairState, self.refreshRepairState, self)
  Z.EventMgr:Add(Z.ConstValue.ShowSkillUsingFailedMsg, self.ShowSkillUsingFailedMsg, self)
  Z.EventMgr:Add(Z.ConstValue.ShowSkillWarning, self.refreshSkillWarning, self)
  Z.EventMgr:Add(Z.ConstValue.HideSkillWarning, self.brokeSkillWarning, self)
  Z.EventMgr:Add(Z.ConstValue.TalentPointChange, self.refreshTalentPointBtn, self)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.TalentWeaponChange, self.refreshTalentIcon, self)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.TalentListChange, self.refreshTalentPointBtn, self)
  Z.EventMgr:Add(Z.ConstValue.PlayerSkillProgress, self.refreshPlayerSkillProgress, self)
  Z.EventMgr:Add(Z.ConstValue.PlayerSkillEnd, self.stopPlayerSkillProgress, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.refreshFunctionBtn, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.refreshUnlockSkillSlot, self)
  Z.EventMgr:Add(Z.ConstValue.SkillSlotInstall, self.refreshUnlockSkillSlot, self)
  Z.EventMgr:Add(Z.ConstValue.NormalAttackClicked, self.checkSkillPanelToggleIsOn, self)
  Z.EventMgr:Add(Z.ConstValue.AutoBattleChange, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.UpDatePlayerStateBar, self.hidePlayerStateBar, self)
  Z.EventMgr:Add(Z.ConstValue.PlayerSkillPanelChange, self.refreshSkillPanel, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Buff.ProfessionBuffRefreshView, self.refreshProfessionBuffTips, self)
  if self.ParkourStyleList ~= nil then
    self.ParkourStyleList:RegisterEvent()
  end
end

function FighterBtnsView:hidePlayerStateBar(isShow)
  self.panel.node_player_state_bar:SetVisible(isShow)
  self.panel.parkour_qte_pos:SetVisible(isShow)
  self.panel.battle_res_follow_pos:SetVisible(isShow)
  self.panel.node_bufftime_list:SetVisible(isShow)
  self.panel.node_debufftime_list:SetVisible(isShow)
  if Z.IsPCUI then
    self.panel.button_pos_group:SetVisible(isShow)
  end
end

function FighterBtnsView:refreshPlayerSkillProgress(skillId, isDirectionUp, skillTime)
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  self.panel.skill_progress_effect.ZEff:SetEffectGoVisible(false)
  self.panel.node_skill:SetVisible(true)
  self.panel.lab_skill_num.text = self.panel.slider_temp.fillAmount
  self.panel.lab_skill_name.TMPLab.text = ""
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  if skillRow then
    self.panel.lab_skill_name.TMPLab.text = skillRow.Name
  end
  local begin = 1
  local target = 0
  if isDirectionUp then
    begin = 0
    target = 1
  end
  self.curUseSkillId_ = skillId
  self.panel.img_progress.imageBar:Play(begin, target, skillTime, function()
    self:stopPlayerSkillProgress(false, skillId)
  end)
end

function FighterBtnsView:stopPlayerSkillProgress(isBreak, skillId)
  if skillId ~= self.curUseSkillId_ then
    return
  end
  self.curUseSkillId_ = 0
  Z.CoroUtil.create_coro_xpcall(function()
    if isBreak then
    else
      self.panel.img_progress.imageBar:Stop()
      self.panel.skill_progress_effect.ZEff:SetEffectGoVisible(true)
      Z.Delay(0.2, self.cancelSource:CreateToken())
      self.panel.node_skill:SetVisible(false)
      self.panel.skill_progress_effect.ZEff:SetEffectGoVisible(false)
    end
  end)()
end

function FighterBtnsView:UnBindEvents()
  Z.EventMgr:RemoveObjAll(self)
  if self.ParkourStyleList ~= nil then
    self.ParkourStyleList:UnregisterEvent()
  end
end

function FighterBtnsView:initEquipDamaged()
  local equipVm = Z.VMMgr.GetVM("equip_system")
  self:refreshRepairState(equipVm.GetRepairEquip())
end

function FighterBtnsView:refreshRepairState(isShow)
  self.panel.node_damaged:SetVisible(isShow)
end

function FighterBtnsView:setTalentTag()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local talentTag = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EHudTalentTag).Value
  self.panel.node_talent:SetVisible(0 < talentTag)
end

function FighterBtnsView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerHpWatcher = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrHp"),
      Z.PbAttrEnum("AttrMaxHp"),
      Z.PbAttrEnum("AttrShieldList")
    }, Z.EntityMgr.PlayerEnt, self.refreshPlayBlood)
    self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.EAttrState
    }, Z.EntityMgr.PlayerEnt, self.refreshBtnContainerState, true)
    self:BindEntityLuaAttrWatcher({
      Z.AttrCreator.ToIndex(Z.LocalAttr.EMultiActionState)
    }, Z.EntityMgr.PlayerEnt, self.refreshBtnContainerState)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrResourceLeft"),
      Z.PbAttrEnum("AttrResourceRight")
    }, Z.EntityMgr.PlayerEnt, self.refreshEnvCtrlBtn)
    self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.ENowBuffList
    }, Z.EntityMgr.PlayerEnt, self.onBuffChange, true)
    self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.EShowBuffList
    }, Z.EntityMgr.PlayerEnt, self.onShowBuffChange, true)
    self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.EHudTalentTag
    }, Z.EntityMgr.PlayerEnt, self.setTalentTag, true)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrCombatState")
    }, Z.EntityMgr.PlayerEnt, self.refreshSkillPanel)
    
    function self.equipListChangeFunc_(container, dirtys)
      if container.equipList then
        self:refreshBtnContainerState()
      end
    end
    
    Z.ContainerMgr.CharSerialize.equip.Watcher:RegWatcher(self.equipListChangeFunc_)
  end
end

function FighterBtnsView:UnBindLuaAttrWatchers()
  self:UnBindAllWatchers()
  Z.ContainerMgr.CharSerialize.equip.Watcher:UnregWatcher(self.equipListChangeFunc_)
end

function FighterBtnsView:ShowSkillUsingFailedMsg(msgId)
  if msgId <= 0 then
    return
  end
  if msgId == 150009 then
    local professionId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrProfessionId")).Value
    local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionRow == nil then
      return
    end
    local param = {
      val = professionRow.Name
    }
    Z.TipsVM.ShowTipsLang(msgId, param)
    return
  end
  Z.TipsVM.ShowTipsLang(msgId)
end

function FighterBtnsView:refreshEnvCtrlBtn()
  local left = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceLeft")).Value
  local right = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrResourceRight")).Value
  local resonanceTbl = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr")
  if not resonanceTbl then
    return
  end
  local isPC = Z.IsPCUI
  local bitType = E.PlayerCtrlBtnTmpType.Default
  if isPC then
    bitType = bitType | E.PlayerCtrlBtnTmpType.FlowGlide | E.PlayerCtrlBtnTmpType.Swim
  end
  if left and 0 < left then
    local row = resonanceTbl.GetRow(left)
    self.playerCtrlTmpMgr_:AddSlotToTmp(bitType, row.SlotType, E.SlotName.ResonanceSkillSlot_left, false)
  else
    self.playerCtrlTmpMgr_:RemoveSlotToTmp(bitType, E.SlotName.ResonanceSkillSlot_left, false)
    if isPC then
      self.playerCtrlTmpMgr_:AddSlotToTmp(bitType, E.PlayerCtrlBtnType.ESkillSlotBtn, E.SlotName.ResonanceSkillSlot_left, false)
    end
  end
  if right and 0 < right then
    local row = resonanceTbl.GetRow(right)
    self.playerCtrlTmpMgr_:AddSlotToTmp(bitType, row.SlotType, E.SlotName.ResonanceSkillSlot_right, false)
  else
    self.playerCtrlTmpMgr_:RemoveSlotToTmp(bitType, E.SlotName.ResonanceSkillSlot_right, false)
    if isPC then
      self.playerCtrlTmpMgr_:AddSlotToTmp(bitType, E.PlayerCtrlBtnType.ESkillSlotBtn, E.SlotName.ResonanceSkillSlot_right, false)
    end
  end
end

function FighterBtnsView:brokeSkillWarning()
  self.panel.battle_skill_release.node_slider_bar.imageBar:Stop()
  if self.panel.battle_skill_release.node_slider_bar.Img.fillAmount ~= 1 then
    local imgPath = self:GetPrefabCacheData("bossSkillBroke")
    self.panel.battle_skill_release.node_slider_bar.Img:SetImage(imgPath)
    self.timerMgr:StartTimer(function()
      self.panel.battle_skill_release.effct.TweenContainer:Restart(Z.DOTweenAnimType.Close)
      self.panel.battle_skill_release.node_skill_release:SetVisible(false)
    end, 0.5)
  else
    self.panel.battle_skill_release.effct.ZEff:SetEffectGoVisible(true)
    self.timerMgr:StartTimer(function()
      self.panel.battle_skill_release.effct.TweenContainer:Restart(Z.DOTweenAnimType.Close)
      self.panel.battle_skill_release.Ref:SetVisible(false)
    end, 0.5)
  end
end

function FighterBtnsView:refreshSkillWarning(warningTime, skillTime, mode, skillId)
  self.panel.battle_skill_release.Ref:SetVisible(true)
  self.panel.battle_skill_release.effct.ZEff:SetEffectGoVisible(false)
  self.panel.battle_skill_release.effct.TweenContainer:Restart(Z.DOTweenAnimType.Open)
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  self.panel.battle_skill_release.node_skill_release:SetVisible(false)
  local imgPath = self:GetPrefabCacheData("bossSkillNormal")
  if mode then
    imgPath = self:GetPrefabCacheData("bossSkillDanger")
    self.panel.battle_skill_release.node_skill_release:SetVisible(true)
    self.panel.battle_skill_release.effct.TweenContainer:Restart(Z.DOTweenAnimType.Tween_1)
    self.panel.battle_skill_release.effct.TweenContainer:Restart(Z.DOTweenAnimType.Tween_2)
  end
  self.panel.battle_skill_release.node_slider_bar.Img:SetImage(imgPath)
  self.panel.battle_skill_release.lab_name.TMPLab.text = skillRow.Name
  self.panel.battle_skill_release.node_slider_bar.imageBar:Play(0, 1, warningTime)
end

function FighterBtnsView:refreshEventSkillSlot()
  local cache = self.vm:GetSkillSlotEventCache()
  if not cache or #cache == 0 then
    logGreen("refreshEventSkillSlot cache is nil or 0")
    return
  end
  for _, v in pairs(cache) do
    self:OnSkillSlotChangedByVm(v.slotKey, v.tmpFlag, v.behave)
  end
end

function FighterBtnsView:OnSkillSlotChangedByVm(slotKey, tmpFlag, behave)
  if self.playerCtrlTmpMgr_ == nil then
    return
  end
  if behave == E.SkillSlotEventCtrlType.EAddSlot then
    self.playerCtrlTmpMgr_:AddSlotToTmp(tmpFlag, E.PlayerCtrlBtnType.ESkillSlotBtn, slotKey)
  elseif behave == E.SkillSlotEventCtrlType.ERemoveSlot then
    logGreen("removeSLot slotKey {1}", slotKey)
    self.playerCtrlTmpMgr_:RemoveSlotToTmp(tmpFlag, slotKey)
  end
end

function FighterBtnsView:inputUIFresh()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) then
    for _, value in pairs(E.SkillSlot) do
      self.slotInputIgnore_[value] = true
    end
  else
    for _, value in pairs(E.SkillSlot) do
      self.slotInputIgnore_[value] = false
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.LockTargetOpenSettingChange)
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump) then
    for _, value in pairs(E.Jump) do
      self.slotInputIgnore_[value] = true
    end
  else
    for _, value in pairs(E.Jump) do
      self.slotInputIgnore_[value] = false
    end
  end
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Rush) then
    for _, value in pairs(E.Dash) do
      self.slotInputIgnore_[value] = true
    end
  else
    for _, value in pairs(E.Dash) do
      self.slotInputIgnore_[value] = false
    end
  end
  self.slotInputIgnore_[E.SlotName.ExtraSlot_4] = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.LockTarget)
  self.slotInputIgnore_[E.ResonanceSkillSlot.ResonanceSkillSlot_left] = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance1)
  self.slotInputIgnore_[E.ResonanceSkillSlot.ResonanceSkillSlot_right] = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance2)
  if Z.IgnoreMgr:IsBattleUIIgnore(Panda.ZGame.EBattleUIMask.Blood) then
    self.panel.node_player_state_bar.Ref:SetVisible(false)
    self.node_player_state_barVisible_ = false
    self:setBattleResUIVisible(false)
  else
    self.panel.node_player_state_bar.Ref:SetVisible(true)
    self.node_player_state_barVisible_ = true
    self:setBattleResUIVisible(true)
  end
  self:refreshSlotShowOrHide()
  self:updateTakeMedicineState()
end

function FighterBtnsView:refreshSlotShowOrHide()
  self.finalState_ = {}
  local currentTmpTable = self.playerCtrlTmpMgr_:GetCurrentTmpTable()
  if currentTmpTable == nil then
    return
  end
  local defaultState = true
  if Z.IsPCUI and self:banSkill() then
    defaultState = false
  end
  for slotId, _ in pairs(currentTmpTable) do
    if self.slotLock_[slotId] == false then
      self.finalState_[slotId] = false
    else
      self.finalState_[slotId] = self.slotShow_[slotId] or defaultState
    end
  end
  for _, slotId in pairs(E.SlotName) do
    if self.slotInputIgnore_[slotId] then
      self.finalState_[slotId] = false
    end
  end
  for _, slotId in pairs(E.SlotName) do
    if slotId == E.SlotName.SkillSlot_10 then
      self.panel[slotId].Ref:SetVisible(true)
    else
      if self.finalState_[slotId] == nil then
        self.finalState_[slotId] = false
      end
      self.panel[slotId].Ref:SetVisible(self.finalState_[slotId], slotId ~= E.SlotName.SkillSlot_10)
    end
  end
  self:refreshSkillNodeLine()
end

function FighterBtnsView:Refresh()
  self:ClearBattleRes()
  self:refreshBattleResView()
end

function FighterBtnsView:refreshSkillNodeLine()
  if Z.IsPCUI then
    if self.finalState_[E.ResonanceSkillSlot.ResonanceSkillSlot_left] or self.finalState_[E.ResonanceSkillSlot.ResonanceSkillSlot_right] or self.finalState_[E.VehicleSkills.VehicleSkillSlot_1] then
      self.panel.node_8_line:SetVisible(true)
    else
      self.panel.node_8_line:SetVisible(false)
    end
    if self.finalState_[E.SlotName.SkillSlot_7] or self.finalState_[E.SlotName.SkillSlot_8] then
      self.panel.node_7_line:SetVisible(true)
    else
      self.panel.node_7_line:SetVisible(false)
    end
  end
end

function FighterBtnsView:ClearBattleRes()
  if self.battleResHelper_ then
    self.battleResHelper_:DeActive()
  end
end

function FighterBtnsView:setBattleResUIVisible(flag)
  if self.battleResHelper_ then
    self.battleResHelper_:SetVisible(flag)
  end
end

function FighterBtnsView:refreshRidingBtn()
  self:refreshBtnContainerState()
end

function FighterBtnsView:refreshBtnContainerState()
  self:checkSkillPanelToggleIsOn()
  local templateData = self.vm.GetBtnContainerState()
  if not templateData then
    return
  end
  self.slotShow_[E.SlotName.CancelMulAction] = false
  if templateData.IsClearAllTmpBtns then
    self.playerCtrlTmpMgr_:ClearCurTmpCtrlBtns()
  end
  if templateData.ForcedOpenSlot then
    self.slotShow_[templateData.ForcedOpenSlot] = true
  end
  if templateData.IsChangeSkillPanel ~= nil then
    self:refreshSkillPanel(templateData.IsChangeSkillPanel)
  end
  if templateData.IsShowSkillCheckBtn ~= nil then
    self:refreshSkillCheckBtn(templateData.IsShowSkillCheckBtn)
  end
  if templateData.PCShowBtnType ~= nil then
    self:setPcBtnShow(FightBtnConfig[templateData.PCShowBtnType])
  end
  if templateData.Type then
    if self.playerCtrlTmpMgr_:GetCurrentTmpValue() == templateData.Type then
      return
    end
    self:ChangedCtrlTemplate(templateData.Type)
  end
  self:refreshEnvCtrlBtn()
end

function FighterBtnsView:ChangedCtrlTemplate(tmpType)
  self.playerCtrlTmpMgr_:ClearCurTmpCtrlBtns()
  self.playerCtrlTmpMgr_:CreateTmpCtrlBtns(tmpType)
  self:inputUIFresh()
end

function FighterBtnsView:onInputQuickUse()
  self.quickUseItemComp_:QuickUseItem()
end

function FighterBtnsView:refreshBattleResView()
  if self.battleResHelper_ == nil then
    self.battleResHelper_ = battleResUIHelper.new(self.panel.group_energy_bar, self)
    self.battleResHelper_:Active()
  end
  self.battleResHelper_:Refresh()
end

function FighterBtnsView:refreshTalentIcon()
  self.panel.img_talent_icon:SetVisible(false)
  local switchVM = Z.VMMgr.GetVM("switch")
  local isOpen = switchVM.CheckFuncSwitch(E.FunctionID.Talent)
  self.panel.img_talent_lock:SetVisible(not isOpen)
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  local taletTagIcon = talentSkillVM.GetWeaponnTalentTagIcon()
  if taletTagIcon then
    self.panel.img_talent_icon.Img:SetImage(taletTagIcon)
    self.panel.img_talent_icon:SetVisible(isOpen)
  end
  self:refreshTalentPointBtn()
end

function FighterBtnsView:refreshTalentPointBtn()
  self.panel.img_talent_dot:SetVisible(false)
  self.panel.img_talentweapon_reddot:SetVisible(false)
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  local isFishingState = stateID == Z.PbEnum("EActorState", "ActorStateFishing")
  if isFishingState then
    return
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  if talentSkillVM.CheckTalentTreeRed() then
    self.panel.img_talent_dot:SetVisible(true)
    local restPoint = talentSkillVM.GetSurpluseTalentPointCount(weaponId)
    self.panel.lab_talentpoiknts.TMPLab.text = restPoint
  elseif talentSkillVM.CheckRed() then
    self.panel.img_talentweapon_reddot:SetVisible(true)
  end
end

function FighterBtnsView:showPlayerBlood()
  self.panel.group_blood:SetVisible(true)
  if Z.EntityMgr.PlayerEnt == nil then
    if self.playerHpWatcher ~= nil then
      self:UnBindEntityLuaAttrWatcher(self.playerHpWatcher)
    end
    self.panel.group_blood:SetVisible(false)
    return
  end
  local curHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrHp")).Value
  local maxHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrMaxHp")).Value
  local shieldList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrShieldList")).Value
  local shieldMaxValue = 0
  local shieldProgressList = {}
  for i = shieldList.count - 1, 0, -1 do
    local shieldInfo = shieldList[i]
    if shieldMaxValue < shieldInfo.value then
      shieldMaxValue = shieldInfo.value
    end
    table.insert(shieldProgressList, {
      shieldType = shieldInfo.shieldType,
      shieldValue = shieldMaxValue + curHp
    })
  end
  local progress = curHp / maxHp
  if maxHp < curHp + shieldMaxValue then
    progress = curHp / (maxHp + shieldMaxValue)
  end
  if maxHp == 0 and curHp == 0 then
    progress = 0
  end
  self.panel.group_blood.lab_hp_num.TMPLab.text = curHp .. "/" .. maxHp
  self.vm:SetPlayerLastHpData(curHp, maxHp)
  self:setBlood(self.panel.group_blood, progress, 0)
  self:setShield(self.panel.group_blood, maxHp, progress, shieldProgressList)
end

function FighterBtnsView:refreshPlayBlood()
  local curHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrHp")).Value
  local maxHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrMaxHp")).Value
  local shieldList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrShieldList")).Value
  local shieldMaxValue = 0
  local shieldProgressList = {}
  for i = shieldList.count - 1, 0, -1 do
    local shieldInfo = shieldList[i]
    if shieldMaxValue < shieldInfo.value then
      shieldMaxValue = shieldInfo.value
    end
    table.insert(shieldProgressList, {
      shieldType = shieldInfo.shieldType,
      shieldValue = shieldMaxValue + curHp
    })
  end
  self.panel.group_blood.lab_hp_num.TMPLab.text = curHp .. "/" .. maxHp
  if curHp == 0 then
    self.vm:SetPlayerLastHpData(curHp, maxHp)
    self:setBlood(self.panel.group_blood, 0, 3)
    self:setShield(self.panel.group_blood, maxHp, 0, shieldProgressList)
    return
  end
  local progress, stage = self.vm:calculatePlayerBlood(curHp, maxHp, shieldMaxValue)
  self:setBlood(self.panel.group_blood, progress, stage)
  self:setShield(self.panel.group_blood, maxHp, progress, shieldProgressList)
end

function FighterBtnsView:setBlood(container, progress, stage)
  container.node_slider_little_blood.ImgClipAnim:SetFilled(progress, stage == 1)
  container.node_slider_big_blood.ImgClipAnim:SetFilled(progress, stage == 2)
  container.node_slider_add_blood.ImgClipAnim:SetFilled(progress, false)
  container.node_slider_top_blood.ImgClipAnim:SetFilled(progress, stage == 3)
end

function FighterBtnsView:setShield(Container, maxHp, hpProgress, progressList)
  if progressList ~= nil and 0 < #progressList then
    local maxShieldValue = 0
    for _, progressInfo in ipairs(progressList) do
      local shieldType = Z.PbEnum("EShieldType", tostring(progressInfo.shieldType))
      if maxShieldValue < progressInfo.shieldValue then
        maxShieldValue = progressInfo.shieldValue
      end
    end
    Container.node_slider_shield_max.Slider.value = maxShieldValue / maxHp
  else
    Container.node_slider_shield_max.Slider.value = hpProgress
  end
end

function FighterBtnsView:CreateQteUIUnit(qteId)
  QteCreator.Create(qteId, self, self.panel)
end

function FighterBtnsView:startAnimatedShow()
  self.panel.anim.anim:PlayOnce("anim_fighterbtns_001")
end

function FighterBtnsView:startAnimatedHide()
  local asyncCall = Z.CoroUtil.async_to_sync(self.panel.anim.anim.CoroPlayOnce)
  asyncCall(self.panel.anim.anim, "anim_fighterbtns_002", self.cancelSource:CreateToken())
  self.panel.anim.anim:ResetAniState("anim_fighterbtns_002")
end

function FighterBtnsView:initProfessionBtn()
  self:AddAsyncClick(self.panel.btn_talent.Btn, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Talent)
  end)
end

function FighterBtnsView:initSkillPanelToggle()
  if Z.IsPCUI then
    return
  end
  self.panel.toggle_skill.Tog:AddListener(function(isOn)
    self:refreshSkillPanel(isOn)
  end)
end

function FighterBtnsView:initTestPromptPanel()
  if Z.Global.MainUITxt == E.CBTTestFlagEnum.Show then
    self.panel.lab_exegesis.TMPLab.text = Lang("MainUITxtTip")
    self.panel.lab_exegesis:SetVisible(true)
  else
    self.panel.lab_exegesis:SetVisible(false)
  end
end

function FighterBtnsView:onBuffChange()
  self:refreshSlotShowOrHide()
  if self.battleResHelper_ then
    self.battleResHelper_:OnBuffChange()
  end
  self:refreshAutoBattleSwitch()
end

function FighterBtnsView:onShowBuffChange()
  self:updateBuffNoticeByList()
end

function FighterBtnsView:clearBuffNotice()
  for _, data in pairs(self.buffNoticeList_) do
    self:removeBuffNotice(data)
  end
  self.buffNoticeList_ = {}
end

function FighterBtnsView:removeBuffNotice(data)
  if not data then
    return
  end
  self:RemoveUiUnit(data.unitName)
end

function FighterBtnsView:isBuffRemove(buffDataList, uuid)
  if buffDataList then
    for i = 1, table.zcount(buffDataList) do
      if buffDataList[i].BuffUuid == uuid then
        return false
      end
    end
  end
  return true
end

function FighterBtnsView:updateBuffNoticeByList()
  local buffVm = Z.VMMgr.GetVM("buff")
  local buffDataList = buffVm.GetEntityBuffList(Z.EntityMgr.PlayerEnt, self.showBuffCountMax_, E.EBuffPriority.Highest)
  local removeList = {}
  for uuid, data in pairs(self.buffNoticeList_) do
    if self:isBuffRemove(buffDataList, uuid) then
      self:removeBuffNotice(data)
      removeList[#removeList + 1] = uuid
    end
  end
  for i = 1, #removeList do
    self.buffNoticeList_[removeList[i]] = nil
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, table.zcount(buffDataList) do
      buffDataList[i].Index = i
      if not self.buffNoticeList_[buffDataList[i].BuffUuid] then
        self:asyncAddBuffNotice(buffDataList[i])
      else
        self:updateBuffNotice(buffDataList[i])
      end
    end
  end)()
end

function FighterBtnsView:asyncAddBuffNotice(buffData)
  local buffNoticeItem = {}
  local buffListPath = self:GetPrefabCacheData("buffNoticeItem")
  local unitName = string.zconcat("buffNotice", buffData.BuffUuid)
  local listPath = self.panel.node_bufftime_list.Trans
  if buffData.BuffType ~= E.EBuffType.Gain then
    listPath = self.panel.node_debufftime_list.Trans
  end
  buffNoticeItem.unitName = unitName
  self.buffNoticeList_[buffData.BuffUuid] = buffNoticeItem
  buffNoticeItem.unit = self:AsyncLoadUiUnit(buffListPath, unitName, listPath, self.cancelSource:CreateToken())
  self:updateBuffTime(buffNoticeItem, buffData)
end

function FighterBtnsView:updateBuffNotice(buffData)
  local noticeData = self.buffNoticeList_[buffData.BuffUuid]
  if not noticeData or not noticeData.unit then
    return
  end
  self:updateBuffTime(noticeData, buffData)
end

function FighterBtnsView:updateBuffTime(noticeData, buffData)
  local unit = noticeData.unit
  unit.lab_name.text = buffData.Name
  unit.battle_icon_buff_tpl.img_icon:SetImage(buffData.Icon)
  unit.battle_icon_buff_tpl.Ref:SetVisible(unit.battle_icon_buff_tpl.lab_digit, buffData.Layer > 1)
  unit.battle_icon_buff_tpl.lab_digit.text = buffData.Layer
  unit.Trans:SetSiblingIndex(buffData.Index)
  local progress, stopProgress, imgIcon
  if buffData.BuffType ~= E.EBuffType.Gain then
    progress = unit.img_progress_debuff
    stopProgress = unit.img_progress_buff
    imgIcon = unit.img_debuff
    unit.Ref:SetVisible(unit.img_progress_debuff, true)
    unit.Ref:SetVisible(unit.img_progress_buff, false)
  else
    progress = unit.img_progress_buff
    stopProgress = unit.img_progress_debuff
    imgIcon = unit.img_buff
    unit.Ref:SetVisible(unit.img_progress_debuff, false)
    unit.Ref:SetVisible(unit.img_progress_buff, true)
  end
  stopProgress:Stop()
  if buffData.DurationTime <= 0 then
    unit.battle_icon_buff_tpl.img_progress:Stop()
    unit.battle_icon_buff_tpl.img_progress_icon.fillAmount = 0
    progress:Stop()
    imgIcon.fillAmount = 1
    unit.lab_time.text = ""
  else
    local nowTime = Z.NumTools.GetPreciseDecimal(Z.ServerTime:GetServerTime() / 1000, 1)
    local nowValue = nowTime - buffData.CreateTime
    local totalTime = buffData.DurationTime - nowValue
    local begin
    if buffData.BuffTime and 0 < buffData.BuffTime and buffData.DurationTime > buffData.BuffTime then
      begin = 1 - (nowValue - (buffData.DurationTime - buffData.BuffTime)) / buffData.BuffTime
    else
      begin = 1 - nowValue / buffData.DurationTime
    end
    unit.battle_icon_buff_tpl.img_progress:Play(begin, 0, totalTime, nil, buffData.BuffTime)
    progress:Play(begin, 0, totalTime, nil, buffData.BuffTime)
    noticeData.imgbar1 = unit.battle_icon_buff_tpl.img_progress
    noticeData.imgbar2 = progress
  end
end

function FighterBtnsView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.TalentView)
end

function FighterBtnsView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.TalentView)
end

function FighterBtnsView:refreshSkillPanel(isShow)
  if Z.IsPCUI then
    return
  end
  local isOn = isShow
  if isOn == nil and Z.EntityMgr.PlayerEnt then
    isOn = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCombatState")).Value > 0
    if self.isInBattleTimer_ then
      self.timerMgr:StopTimer(self.isInBattleTimer_)
    end
    if isOn == false then
      self.isInBattleTimer_ = self.timerMgr:StartTimer(function()
        self.panel.toggle_skill.Tog.isOn = isOn
        self:refreshSkillPanel(false)
      end, Z.Global.RouletteOffBattleSwitchTime)
      return
    end
  end
  self.panel.node_skill_1:SetVisible(isOn)
  self.panel.node_skill_2:SetVisible(not isOn)
  self.panel.img_off:SetVisible(not isOn)
  self.panel.img_on:SetVisible(isOn)
  self.vm:SetSkillPanelShow(isOn)
end

function FighterBtnsView:refreshSkillCheckBtn(isShow)
  if Z.IsPCUI or isShow == nil then
    return
  end
  local professionVm = Z.VMMgr.GetVM("profession")
  if not professionVm:CheckProfessionEquipWeapon() then
    self.panel.toggle_skill:SetVisible(false)
    return
  end
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance2) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance1) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Rush) then
    self.panel.toggle_skill:SetVisible(false)
    return
  end
  self.panel.toggle_skill:SetVisible(isShow)
end

function FighterBtnsView:refreshFunctionBtn(functionId, isOpen)
  self:checkSkillPanelToggleIsOn()
  self:refreshFlightAndGlidingSlot()
  self:refreshUnlockSkillSlot()
  self:refreshTalentIcon()
end

function FighterBtnsView:refreshFlightAndGlidingSlot()
  if not Z.IsPCUI then
    return
  end
  local isOpen = self.switchVm_.CheckFuncSwitch(E.FunctionID.EnvResonance)
  self.slotLock_[E.ResonanceSkillSlot.ResonanceSkillSlot_left] = isOpen
  self.slotLock_[E.ResonanceSkillSlot.ResonanceSkillSlot_right] = isOpen
  self:refreshSlotShowOrHide()
end

function FighterBtnsView:refreshUnlockSkillSlot()
  local skillSlotPositionTableMgr = Z.TableMgr.GetTable("SkillSlotPositionTableMgr")
  for _, value in pairs(E.SkillSlot) do
    local skillSlotRow = skillSlotPositionTableMgr.GetRow(tonumber(value))
    if skillSlotRow then
      self.slotLock_[value] = Z.ConditionHelper.CheckCondition(skillSlotRow.UnlockCondition)
      if Z.StageMgr.GetCurrentSceneId() == Z.Global.BornMap and table.zcontains(E.NormalSkill, value) then
        self.slotLock_[value] = true
      end
    end
  end
  self:refreshSlotShowOrHide()
end

function FighterBtnsView:refreshAutoBattleSwitch()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) or self:banSkill() then
    self.panel.node_auto_battle:SetVisible(false)
    self.vm:SetAutoBattleFlag(false)
    Z.EventMgr:Dispatch(Z.ConstValue.OnAutoBattleBannedBySkillBanned)
    return
  end
  self.vm:SetAutoBattleFlag(true)
  Z.EventMgr:Dispatch(Z.ConstValue.OnAutoBattleBannedBySkillBanned)
  local settingVm = Z.VMMgr.GetVM("setting")
  local autoBattleOpen = settingVm.Get(E.SettingID.AutoBattle)
  local switchOpen = Z.LocalUserDataMgr.GetBool("auto_battle_switch", false)
  self:AddAsyncClick(self.panel.node_auto_battle.btn_feame.Btn, function()
    local switchOpen = Z.LocalUserDataMgr.GetBool("auto_battle_switch", false)
    switchOpen = not switchOpen
    Z.LocalUserDataMgr.SetBool("auto_battle_switch", switchOpen)
    if Z.EntityMgr.PlayerEnt ~= nil then
      Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.EAutoBattleSwitch, switchOpen)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.AutoBattleChange)
    if switchOpen == false and Z.EntityMgr.PlayerEnt ~= nil then
      Panda.ZGame.ZBattleUtils.StopPlayerAIBattle()
    end
  end)
  if switchOpen then
    self.panel.node_auto_battle.btn_feame.Img:SetColorByHex(E.ColorHexValues.Yellow)
    self.panel.node_auto_battle.img_icon.Img:SetColorByHex(E.ColorHexValues.Yellow)
  else
    self.panel.node_auto_battle.btn_feame.Img:SetColorByHex(E.ColorHexValues.White)
    self.panel.node_auto_battle.img_icon.Img:SetColorByHex(E.ColorHexValues.White)
  end
  self.panel.node_auto_battle:SetVisible(autoBattleOpen)
  if autoBattleOpen == false then
    Z.LocalUserDataMgr.SetBool("auto_battle_switch", false)
    if Z.EntityMgr.PlayerEnt ~= nil then
      Panda.ZGame.ZBattleUtils.StopPlayerAIBattle()
    end
  end
  if Z.EntityMgr.PlayerEnt ~= nil then
    Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.EAutoBattleSwitch, switchOpen)
  end
end

function FighterBtnsView:refreshProfessionBuffTips()
  if self.professionBuffShowHelper_ == nil then
    self.professionBuffShowHelper_ = professionBuffShowHelper.new(self, self.panel.profession_buff_icon_group)
    self.professionBuffShowHelper_:Init()
  else
    self.professionBuffShowHelper_:RefreshProfessionBuffTips()
  end
end

return FighterBtnsView
