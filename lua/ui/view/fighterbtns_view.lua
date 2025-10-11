local UI = Z.UI
local super = require("ui.ui_subview_base")
local FighterBtnsView = class("FighterBtnsView", super)
local battleResUIHelper = require("ui.fighter_battle_res.battle_res_ui_helper")
local professionBuffShowHelper = require("ui.fighter_battle_res.profession_buff_show_helper")
local inputKeyDescComp = require("input.input_key_desc_comp")
local QteCreator = require("ui.component.qte.qte_creator")
local PlayerCtrlTmpMgr = require("ui.player_ctrl_btns.player_ctrl_btn_templates")
local ParkourStyleList = require("ui.component.parkour_style_list.parkour_style_list")
local PERSONAL_ZONE_DEFINE = require("ui.model.personalzone_define")
local skillSingSuccessEffect = "ui/uieffect/prefab/ui_sfx_battle_001/ui_sfx_group_battle_fankui_001"
local skillUseSuccessEffect = "ui/uieffect/prefab/ui_sfx_battle_001/ui_sfx_group_hit_fankui_001"
local emptyLength = 2
local lineWidth = 5
E.CBTTestFlagEnum = {Hidden = 0, Show = 1}

function FighterBtnsView:ctor(parent)
  self.uiBinder = nil
  self.parentView_ = parent
  local viewConfigKey, assetPath
  if Z.IsPCUI then
    viewConfigKey = "battle_main_node_window_pc"
  else
    viewConfigKey = "battle_main_node_window"
  end
  super.ctor(self, viewConfigKey, "battle/battle_main_node_window", UI.ECacheLv.High, true)
  self.abnormalStateView_ = require("ui/view/abnormal_state_view").new()
  self.quickUseItemComp_ = require("ui/component/mainui/quick_use_item_bar_comp").new(self)
  self.takeMedicineSubView_ = require("ui.view.main_take_medicine_sub_view").new(self)
  self.talentInputKeyDescComp_ = inputKeyDescComp.new()
  self.vm = Z.VMMgr.GetVM("fighterbtns")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.buffData_ = Z.DataMgr.Get("buff_data")
  self.rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
  self.PCUIBattleCtrlBtnSize = 50
  self.PCUIBattleCtrlBtnSplit = 28
  self.buffNoticeList_ = {}
  self.slotShow_ = {}
  self.slotLock_ = {}
  self.slotInputIgnore_ = {}
end

function FighterBtnsView:OnActive()
  self.parentView_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.uidepth)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.battle_skill_release_uibinder.effct)
  self:startAnimatedShow()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.uiBinder.battle_skill_release_uibinder.effct:SetEffectGoVisible(false)
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
  self.skillProgressTimer_ = {}
  self.skillProgressLine_ = {}
  self.lastSlotShow_ = true
  self.cacheAnim_ = {}
  self.isPlaySkillSlotAnim_ = false
  self.lastBloodShow_ = true
  self.curEnergy_ = 0
  self.maxEnergyValue_ = 0
  self.isAlert_ = false
  if Z.IsPCUI then
    self.takeMedicineSubView_:Active(nil, self.uiBinder.takemedicine_sub)
  else
    self.take_medicine_item_ = self.uiBinder.take_medicine_item
    self.quickUseItemComp_:Init(self.take_medicine_item_, E.ShortcutsItemType.Shortcuts)
  end
  self.buffTipsCount_ = 10
  self.showBuffCountMax_ = 6
  self:AddAsyncClick(self.uiBinder.img_equip_damaged, function()
    Z.VMMgr.GetVM("equip_system").OpenDamagedTips(self.uiBinder.img_equip_damaged.transform)
  end)
  self.abnormalStateView_:Active({
    viewType = E.AbnormalPanelType.Self
  }, self.uiBinder.abnormal_container)
  self:initProfessionBtn()
  self:initSkillPanelToggle()
  self.ParkourStyleList = ParkourStyleList.new(self)
  self:initEquipDamaged()
  self:setTalentTag()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self.uiBinder.battle_skill_release_uibinder.Ref.UIComp:SetVisible(false)
  if not Z.IsPCUI then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill_cancel, false)
  end
  self:InitPCKeyIcon()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill, false)
  self:refreshAutoBattleSwitch()
  self:updateTakeMedicineState()
end

function FighterBtnsView:updateTakeMedicineState()
  local isIgnoreQuickUse = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.QuickUseItem)
  if Z.IsPCUI then
    if isIgnoreQuickUse then
      self.takeMedicineSubView_:Hide()
    else
      self.takeMedicineSubView_:Show()
    end
  else
    self.take_medicine_item_.Ref.UIComp:SetVisible(not isIgnoreQuickUse)
  end
end

function FighterBtnsView:OnRefresh()
  self:OnOpenAnimShow()
  self:updateBuffNoticeByList()
  self:refreshBtnContainerState()
  self:refreshFlightAndGlidingSlot()
  self:refreshUnlockSkillSlot()
  self:refreshPlayerInfo()
  self:refreshEnergy()
  self:refreshBattleResVisible()
end

function FighterBtnsView:OnShow()
  self:refreshPcSkillPanel()
end

function FighterBtnsView:refreshPlayerInfo()
  self.uiBinder.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  if Z.IsPCUI then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
    self.uiBinder.lab_talent_name.text = Z.VMMgr.GetVM("talent_skill").GetCurProfessionTalentStageName()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    local titleId = personalzoneVM.GetCurProfileImageId(PERSONAL_ZONE_DEFINE.ProfileImageType.Title)
    if titleId and titleId ~= 0 then
      local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
      if profileImageConfig and profileImageConfig.Unlock ~= PERSONAL_ZONE_DEFINE.ProfileImageUnlockType.DefaultUnlock then
        self.uiBinder.lab_title.text = profileImageConfig.Name
      else
        self.uiBinder.lab_title.text = Lang("NoneTitle")
      end
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
    self:refreshPlayerLvExp()
  end
end

function FighterBtnsView:refreshPlayerLvExp()
  if Z.IsPCUI then
    local roleLv = Z.ContainerMgr.CharSerialize.roleLevel.level
    self.uiBinder.lab_lv.text = Lang("Level", {val = roleLv})
    local roleLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLv)
    if roleLv == self.rolelevelData_.MaxPlayerLevel then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, true)
      self.uiBinder.img_exp.fillAmount = 1
      self.uiBinder.img_exp_green.fillAmount = 1
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, false)
      if roleLevelCfg then
        local maxExp = roleLevelCfg.Exp
        local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
        self.uiBinder.img_exp.fillAmount = curExp / maxExp
      end
    end
    if self.rolelevelVm_.IsBlessExpFuncOn() then
      if roleLv < Z.ContainerMgr.CharSerialize.roleLevel.prevSeasonMaxLv then
        self.uiBinder.img_exp_green.fillAmount = 1
      elseif roleLevelCfg then
        local maxExp = roleLevelCfg.Exp
        local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
        self.uiBinder.img_exp_green.fillAmount = (roleLevelInfo.curLevelExp + roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp) / maxExp
      end
    else
      self.uiBinder.img_exp_green.fillAmount = 0
    end
  end
end

function FighterBtnsView:OnOpenAnimShow()
  if self.uiBinder and self.uiBinder.anim_battle then
    self.uiBinder.anim_battle_tween:Restart(Z.DOTweenAnimType.Open)
  end
end

function FighterBtnsView:checkSkillPanelToggleIsOn()
  if Z.IsPCUI then
    return
  end
  self:refreshBtnContainerState()
end

function FighterBtnsView:InitPCKeyIcon()
  if Z.IsPCUI then
    self.talentInputKeyDescComp_:Init(33, self.uiBinder.talent_icon_key)
  end
end

function FighterBtnsView:OnDeActive()
  if Z.IsPCUI then
    self.talentInputKeyDescComp_:UnInit()
  end
  self:UnBindLuaAttrWatchers()
  self:UnBindEvents()
  self:ClearBattleRes()
  self:clearBuffNotice()
  self:cancelSwitchNormalSkillPanel()
  self.playerCtrlTmpMgr_:ClearCurTmpCtrlBtns()
  self.playerCtrlTmpMgr_ = nil
  self.abnormalStateView_:DeActive()
  if not Z.IsPCUI then
    self.quickUseItemComp_:UnInit()
  else
    self.takeMedicineSubView_:DeActive()
  end
  if self.skillSlotAnimTimer_ then
    self.timerMgr:StopTimer(self.skillSlotAnimTimer_)
    self.skillSlotAnimTimer_ = nil
  end
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  if self.energyTimer_ then
    self.timerMgr:StopTimer(self.energyTimer_)
    self.energyTimer_ = nil
  end
  self.professionBuffShowHelper_:UnInit()
  self.professionBuffShowHelper_ = nil
  self.cacheAnim_ = {}
end

function FighterBtnsView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.OnPorfessionChange, self.onPorfessionChange, self)
  Z.EventMgr:Add(Z.ConstValue.OnBattleResChangeRefreshUI, self.refreshBattleResView, self)
  Z.EventMgr:Add(Z.ConstValue.CreateQteUIUnit, self.CreateQteUIUnit, self)
  if not Z.IsPCUI then
    Z.EventMgr:Add("InputQuickUseItem", self.onInputQuickUse, self)
  end
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
  Z.EventMgr:Add(Z.ConstValue.AutoBattleChange, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.refreshAutoBattleSwitch, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.UpDatePlayerStateBar, self.hidePlayerStateBar, self)
  Z.EventMgr:Add(Z.ConstValue.PlayerSkillPanelChange, self.onSkillInput, self)
  Z.EventMgr:Add(Z.ConstValue.CancelSwitchNormalSkillPanel, self.cancelSwitchNormalSkillPanel, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshPcSkillPanel, self)
  Z.EventMgr:Add(Z.ConstValue.Buff.ProfessionBuffRefreshView, self.refreshProfessionBuffTips, self)
  Z.EventMgr:Add(Z.ConstValue.BattleResCdChange, self.onBattleResCdChange, self)
  Z.EventMgr:Add(Z.ConstValue.AISlotSetMode, self.switchAISetMode, self)
  Z.EventMgr:Add(Z.ConstValue.OpenSkillRoulette, self.OpenSkillRoulette, self)
  if self.ParkourStyleList ~= nil then
    self.ParkourStyleList:RegisterEvent()
  end
end

function FighterBtnsView:hidePlayerStateBar(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.parkour_qte_pos, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.battle_res_follow_pos, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bufftime_list, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_debufftime_list, isShow)
  if Z.IsPCUI then
    self.uiBinder.profession_buff_icon_group.Ref.UIComp:SetVisible(self.lastSlotShow_ and isShow and not Z.EntityMgr.PlayerEnt.IsRiding)
    self.uiBinder.Ref:SetVisible(self.uiBinder.abnormal_container, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.button_pos_group_hide_root, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_state_bar_hide_root, isShow)
    if isShow then
      self.takeMedicineSubView_:Show()
    else
      self.takeMedicineSubView_:Hide()
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_state_bar, isShow)
  end
end

function FighterBtnsView:refreshPlayerSkillProgress(skillId, beginTime, skillTime, factor)
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local isDirectionUp = 0 < skillId
  skillId = math.abs(skillId)
  logGreen("refreshPlayerSkillProgress, skillId:{0}, beginTime{1}, skillTime:{2}, factor:{3}", skillId, beginTime, skillTime, factor)
  if factor == nil or factor == 0 then
    factor = 1
  end
  self.uiBinder.skill_progress_effect:SetEffectGoVisible(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill, true)
  self.uiBinder.lab_skill_num.text = self.uiBinder.slider_temp.fillAmount
  self.uiBinder.lab_skill_name.text = ""
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  for _, value in ipairs(self.skillProgressLine_) do
    value.ui_effect:SetEffectGoVisible(false)
    value.Ref.UIComp:SetVisible(false)
  end
  for _, value in ipairs(self.skillProgressTimer_) do
    self.timerMgr:StopTimer(value)
  end
  self.skillProgressTimer_ = {}
  if skillRow and 1 < #skillRow.SingOrGuideTime and skillRow.SingOrGuideTime[1][2] == 1 then
    self.uiBinder.skill_progress_effect:CreatEFFGO(skillSingSuccessEffect, Vector3.zero, false)
    self.uiBinder.lab_skill_name.text = skillRow.Name
    if 1 < #skillRow.SingOrGuideTime then
      local root = self.uiBinder.slider_temp.transform
      local lineAllLength = self.uiBinder.slider_temp_rect.rect.width
      local allLength = lineAllLength - 2 * emptyLength - lineWidth
      local allTime = skillRow.SingOrGuideTime[1][1]
      local linePath = self.uiBinder.prefab_cache:GetString("battleProgressLine")
      local index = 1
      local perTimeTbl_ = {}
      local detalTime = allTime - skillTime
      for i = #skillRow.SingOrGuideTime, 2, -1 do
        for j = 1, skillRow.SingOrGuideTime[i][3] do
          perTimeTbl_[index] = skillRow.SingOrGuideTime[i][2] - detalTime
          detalTime = detalTime - skillRow.SingOrGuideTime[i][2]
          if detalTime < 0 then
            detalTime = 0
          end
          index = index + 1
        end
      end
      perTimeTbl_ = table.zreverse(perTimeTbl_)
      local lastTime = 0
      Z.CoroUtil.create_coro_xpcall(function()
        for index, value in ipairs(perTimeTbl_) do
          if index == #perTimeTbl_ then
            break
          end
          if self.skillProgressLine_[index] == nil then
            self.skillProgressLine_[index] = self:AsyncLoadUiUnit(linePath, "img_line_" .. index, root, self.cancelSource:CreateToken())
          end
          self.skillProgressLine_[index].ui_effect:SetEffectGoVisible(false)
          self.skillProgressLine_[index].Ref.UIComp:SetVisible(true)
          local nowTime = lastTime + value / factor
          lastTime = nowTime
          local nowLength_ = allLength * (nowTime / skillTime)
          if isDirectionUp == false then
            nowLength_ = allLength - allLength * (nowTime / skillTime)
          end
          self.skillProgressLine_[index].Trans:SetAnchorPosition(nowLength_, 0)
          self.skillProgressTimer_[index] = self.timerMgr:StartTimer(function()
            self.skillProgressLine_[index].ui_effect:SetEffectGoVisible(true)
          end, nowTime, 1)
        end
      end)()
    end
  else
    self.uiBinder.skill_progress_effect:CreatEFFGO(skillUseSuccessEffect, Vector3.zero, false)
  end
  local begin = 1 - beginTime / skillTime
  local target = 0
  if isDirectionUp then
    begin = beginTime / skillTime
    target = 1
  end
  self.curUseSkillId_ = skillId
  self.uiBinder.img_progress:Play(begin, target, skillTime - beginTime, function()
    self:stopPlayerSkillProgress(false, skillId)
  end)
end

function FighterBtnsView:stopPlayerSkillProgress(isBreak, skillId)
  if skillId ~= self.curUseSkillId_ then
    return
  end
  self.curUseSkillId_ = 0
  for _, value in ipairs(self.skillProgressTimer_) do
    self.timerMgr:StopTimer(value)
  end
  self.skillProgressTimer_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    if isBreak then
      self.uiBinder.img_progress:Stop()
      self.uiBinder.lab_skill_name.text = Lang("interrupt")
    else
      self.uiBinder.img_progress:Stop()
      self.uiBinder.skill_progress_effect:SetEffectGoVisible(true)
      Z.Delay(0.2, self.cancelSource:CreateToken())
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill, false)
      self.uiBinder.skill_progress_effect:SetEffectGoVisible(false)
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_equip_damaged, isShow)
end

function FighterBtnsView:setTalentTag()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_talent, false)
end

function FighterBtnsView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerHpWatcher = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrHp"),
      Z.PbAttrEnum("AttrMaxHp"),
      Z.PbAttrEnum("AttrShieldList")
    }, Z.EntityMgr.PlayerEnt, self.refreshPlayBlood)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrHp")
    }, Z.EntityMgr.PlayerEnt, self.refreshPcSkillPanel)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrToy")
    }, Z.EntityMgr.PlayerEnt, self.refreshPcSkillPanel)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrInBattleShow")
    }, Z.EntityMgr.PlayerEnt, self.refreshPcSkillPanel)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrCombatState")
    }, Z.EntityMgr.PlayerEnt, self.refreshPcSkillPanel)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrInBattleShow")
    }, Z.EntityMgr.PlayerEnt, self.checkBattleShowSkillPanelChange)
    self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrCombatState")
    }, Z.EntityMgr.PlayerEnt, self.checkOutCombatSkillPanelChange)
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      self:onPlayerStateChange()
    end)
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
    
    function self.equipListChangeFunc_(container, dirtys)
      if container.equipList then
        self:refreshBtnContainerState()
      end
    end
    
    Z.ContainerMgr.CharSerialize.equip.Watcher:RegWatcher(self.equipListChangeFunc_)
    
    function self.roleLevelChangeFunc_(container, dirtys)
      if dirtys.curLevelExp or dirtys.level then
        self:refreshPlayerLvExp()
      end
    end
    
    Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.roleLevelChangeFunc_)
    
    function self.playerNameChangeFunc_(container, dirtys)
      if dirtys.name then
        self:refreshPlayerInfo()
      end
    end
    
    Z.ContainerMgr.CharSerialize.charBase.Watcher:RegWatcher(self.playerNameChangeFunc_)
    
    function self.playerTitleChangeFunc_(container, dirtys)
      if dirtys.titleId then
        self:refreshPlayerInfo()
      end
    end
    
    Z.ContainerMgr.CharSerialize.personalZone.Watcher:RegWatcher(self.playerTitleChangeFunc_)
  end
end

function FighterBtnsView:UnBindLuaAttrWatchers()
  self:UnBindAllWatchers()
  Z.ContainerMgr.CharSerialize.equip.Watcher:UnregWatcher(self.equipListChangeFunc_)
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.roleLevelChangeFunc_)
  Z.ContainerMgr.CharSerialize.charBase.Watcher:UnregWatcher(self.playerNameChangeFunc_)
  Z.ContainerMgr.CharSerialize.personalZone.Watcher:UnregWatcher(self.playerTitleChangeFunc_)
end

function FighterBtnsView:ShowSkillUsingFailedMsg(msgId)
  if msgId <= 0 then
    return
  end
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
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
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
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
  self.uiBinder.battle_skill_release_uibinder.node_slider_bar:Stop()
  if self.uiBinder.battle_skill_release_uibinder.node_slider_bar_img.fillAmount ~= 1 then
    local imgPath = self.uiBinder.prefab_cache:GetString("bossSkillBroke")
    self.uiBinder.battle_skill_release_uibinder.node_slider_bar_img:SetImage(imgPath)
    self.timerMgr:StartTimer(function()
      self.uiBinder.battle_skill_release_uibinder.effct_tween:Restart(Z.DOTweenAnimType.Close)
      self.uiBinder.battle_skill_release_uibinder.Ref:SetVisible(self.uiBinder.battle_skill_release_uibinder.node_skill_release, false)
    end, 0.5)
  else
    self.uiBinder.battle_skill_release_uibinder.effct:SetEffectGoVisible(true)
    self.timerMgr:StartTimer(function()
      self.uiBinder.battle_skill_release_uibinder.effct_tween:Restart(Z.DOTweenAnimType.Close)
      self.uiBinder.battle_skill_release_uibinder.Ref.UIComp:SetVisible(false)
    end, 0.5)
  end
end

function FighterBtnsView:refreshSkillWarning(warningTime, skillTime, mode, skillId)
  self.uiBinder.battle_skill_release_uibinder.Ref.UIComp:SetVisible(true)
  self.uiBinder.battle_skill_release_uibinder.effct:SetEffectGoVisible(false)
  self.uiBinder.battle_skill_release_uibinder.effct_tween:Restart(Z.DOTweenAnimType.Open)
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  self.uiBinder.battle_skill_release_uibinder.Ref:SetVisible(self.uiBinder.battle_skill_release_uibinder.node_skill_release, false)
  local imgPath = self.uiBinder.prefab_cache:GetString("bossSkillNormal")
  if mode then
    imgPath = self.uiBinder.prefab_cache:GetString("bossSkillDanger")
    self.uiBinder.battle_skill_release_uibinder.Ref:SetVisible(self.uiBinder.battle_skill_release_uibinder.node_skill_release, true)
    self.uiBinder.battle_skill_release_uibinder.effct_tween:Restart(Z.DOTweenAnimType.Tween_1)
    self.uiBinder.battle_skill_release_uibinder.effct_tween:Restart(Z.DOTweenAnimType.Tween_2)
  end
  self.uiBinder.battle_skill_release_uibinder.node_slider_bar_img:SetImage(imgPath)
  self.uiBinder.battle_skill_release_uibinder.lab_name.text = skillRow.Name
  self.uiBinder.battle_skill_release_uibinder.node_slider_bar:Play(0, 1, warningTime)
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
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_state_bar, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_state_bar, true)
  end
  self:refreshSlotShowOrHide()
  self:checkSkillPanelToggleIsOn()
  self:refreshPcSkillPanel()
  self:updateTakeMedicineState()
end

function FighterBtnsView:refreshPcSkillPanel()
  if not self.parentView_.IsVisible or not self.IsLoaded then
    return
  end
  if not Z.IsPCUI then
    self:refreshBattleResVisible()
    return
  end
  local skillInputMask = Z.IgnoreMgr:IsInputIgnoreExcludeSource(Panda.ZGame.EInputMask.Skill, 1 << E.EIgnoreMaskSource.EBigSkill | 1 << E.EIgnoreMaskSource.EUIMask | 1 << E.EIgnoreMaskSource.EUIView)
  local bloodUIMask = Z.IgnoreMgr:IsBattleUIIgnore(Panda.ZGame.EBattleUIMask.Blood)
  local normalIndexToSlotName = {
    [1] = E.SlotName.SkillSlot_1,
    [2] = E.SlotName.SkillSlot_2,
    [3] = E.SlotName.SkillSlot_3,
    [4] = E.SlotName.SkillSlot_4,
    [5] = E.SlotName.SkillSlot_5,
    [6] = E.SlotName.SkillSlot_9,
    [7] = E.SlotName.SkillSlot_6,
    [8] = E.SlotName.SkillSlot_7,
    [9] = E.SlotName.SkillSlot_8
  }
  local curHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrHp")).Value
  local maxHp = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrMaxHp")).Value
  self.ingoreBloodAnim_ = false
  if curHp < maxHp or self.curEnergy_ < self.maxEnergyValue_ then
    self.ingoreBloodAnim_ = true
    if not bloodUIMask ~= self.lastBloodShow_ then
      self.lastBloodShow_ = not bloodUIMask
      self.uiBinder.anim_battle_tween:Restart(not bloodUIMask and Z.DOTweenAnimType.Tween_0 or Z.DOTweenAnimType.Tween_1)
    end
  end
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneRow_ = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow_.SceneSubType ~= E.SceneSubType.MainCity and sceneRow_.SceneSubType ~= E.SceneSubType.WildMap and sceneRow_.SceneSubType ~= E.SceneSubType.Community and sceneRow_.SceneSubType ~= E.SceneSubType.Homeland then
    self:playSkillSlotShowOrHideAnim(not skillInputMask, not bloodUIMask, normalIndexToSlotName)
    return
  end
  if Z.EntityMgr.PlayerEnt:GetLuaLocalAttrInBattleShow() or Z.EntityMgr.PlayerEnt:GetLuaIsInCombat() then
    self:playSkillSlotShowOrHideAnim(not skillInputMask, not bloodUIMask, normalIndexToSlotName)
    return
  end
  if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EMultiActionState).Value ~= 0 then
    self:playSkillSlotShowOrHideAnim(true, true, normalIndexToSlotName)
    return
  end
  local usingToy = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrToy")).Value
  if usingToy == 1 then
    self:playSkillSlotShowOrHideAnim(true, true, normalIndexToSlotName)
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if stateID == Z.PbEnum("EActorState", "ActorStateSkill") then
    self:playSkillSlotShowOrHideAnim(not skillInputMask, not bloodUIMask, normalIndexToSlotName)
    return
  elseif stateID == Z.PbEnum("EActorState", "ActorStateSwim") then
    self:playSkillSlotShowOrHideAnim(false, false, normalIndexToSlotName)
    return
  elseif stateID == Z.PbEnum("EActorState", "ActorStateClimb") or stateID == Z.PbEnum("EActorState", "ActorStatePedalWall") or stateID == Z.PbEnum("EActorState", "ActorStateClimbWall") then
    self:playSkillSlotShowOrHideAnim(false, false, normalIndexToSlotName)
    return
  elseif Z.EntityMgr.PlayerEnt.IsRiding then
    self:playSkillSlotShowOrHideAnim(not skillInputMask, not bloodUIMask, normalIndexToSlotName)
    return
  end
  self:playSkillSlotShowOrHideAnim(false, false, normalIndexToSlotName)
end

function FighterBtnsView:refreshBattleResVisible(IsVisible)
  if not self.parentView_.IsVisible or not self.IsLoaded then
    return
  end
  if not Z.IsPCUI then
    local skillInputMask = Z.IgnoreMgr:IsInputIgnoreExcludeSource(Panda.ZGame.EInputMask.Skill, 1 << E.EIgnoreMaskSource.EBigSkill | 1 << E.EIgnoreMaskSource.EUIMask)
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local sceneRow_ = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
    if sceneRow_.SceneSubType ~= E.SceneSubType.MainCity and sceneRow_.SceneSubType ~= E.SceneSubType.WildMap and sceneRow_.SceneSubType ~= E.SceneSubType.Community and sceneRow_.SceneSubType ~= E.SceneSubType.Homeland then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, not skillInputMask)
      return
    end
    if Z.EntityMgr.PlayerEnt:GetLuaLocalAttrInBattleShow() or Z.EntityMgr.PlayerEnt:GetLuaIsInCombat() then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, not skillInputMask)
      return
    end
    if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EMultiActionState).Value ~= 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, true)
      return
    end
    local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    if stateID == Z.PbEnum("EActorState", "ActorStateSkill") then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, true)
      return
    elseif stateID == Z.PbEnum("EActorState", "ActorStateSwim") then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, false)
      return
    elseif stateID == Z.PbEnum("EActorState", "ActorStateClimb") or stateID == Z.PbEnum("EActorState", "ActorStatePedalWall") or stateID == Z.PbEnum("EActorState", "ActorStateClimbWall") then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, false)
      return
    end
  end
  local usingToy = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrToy")).Value
  if usingToy == 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, false)
    return
  end
  if Z.EntityMgr.PlayerEnt.IsRiding then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, false)
    return
  end
  IsVisible = IsVisible or false
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_energy, IsVisible)
end

function FighterBtnsView:playSkillSlotShowOrHideAnim(skillShow, bloodShow, slotMap)
  if bloodShow ~= self.lastBloodShow_ and not self.ingoreBloodAnim_ then
    self.lastBloodShow_ = bloodShow
    self.uiBinder.anim_battle_tween:Complete()
    self.uiBinder.anim_battle_tween:Restart(bloodShow and Z.DOTweenAnimType.Tween_0 or Z.DOTweenAnimType.Tween_1)
  end
  if skillShow ~= self.lastSlotShow_ then
    self.uiBinder.buff_anim_tween:Complete()
    self.uiBinder.buff_anim_tween:Restart(skillShow and Z.DOTweenAnimType.Tween_2 or Z.DOTweenAnimType.Tween_3)
    self.lastSlotShow_ = skillShow
    self.uiBinder.button_pos_group.Ref.UIComp.Interactable = skillShow
    if not self.isPlaySkillSlotAnim_ or #self.cacheAnim_ == 0 then
      local temp = {skillShow = skillShow, slotMap = slotMap}
      table.insert(self.cacheAnim_, temp)
      if not self.isPlaySkillSlotAnim_ then
        self:tryPlaySkillSlotAnim()
      end
    elseif self.cacheAnim_[1].skillShow ~= skillShow then
      table.remove(self.cacheAnim_, 1)
    end
  end
  self:refreshBattleResVisible(skillShow)
  self.uiBinder.profession_buff_icon_group.Ref.UIComp:SetVisible(skillShow and not Z.EntityMgr.PlayerEnt.IsRiding)
end

function FighterBtnsView:tryPlaySkillSlotAnim()
  if self.IsActive == false then
    return
  end
  if #self.cacheAnim_ > 0 then
    local data = table.remove(self.cacheAnim_, 1)
    local slotMap = data.slotMap
    local skillShow = data.skillShow
    local maxSlotId = #slotMap
    local index = 0
    local delay = 0
    if skillShow == false then
      delay = 0.15
    end
    self.isPlaySkillSlotAnim_ = true
    Z.CoroUtil.create_coro_xpcall(function()
      Z.Delay(delay, self.cancelSource:CreateToken())
      self.timerMgr:StartTimer(function()
        index = index + 1
        local slotName = slotMap[index]
        self.uiBinder.button_pos_group["anim_" .. slotName]:Restart(skillShow and Z.DOTweenAnimType.Open or Z.DOTweenAnimType.Close)
      end, 0.05, maxSlotId - 1, true, function()
        self:tryPlaySkillSlotAnim()
      end, true)
    end)()
  else
    self.isPlaySkillSlotAnim_ = false
  end
end

function FighterBtnsView:refreshSlotShowOrHide()
  self.finalState_ = {}
  local currentTmpTable = self.playerCtrlTmpMgr_:GetCurrentTmpTable()
  if currentTmpTable == nil then
    return
  end
  for slotId, _ in pairs(currentTmpTable) do
    if self.slotLock_[slotId] == false then
      self.finalState_[slotId] = false
    elseif self.slotShow_[slotId] == false then
      self.finalState_[slotId] = false
    else
      self.finalState_[slotId] = true
    end
  end
  local AISlotSetMode = self.vm:CheckAISlotSetMode()
  for _, slotId in pairs(E.SlotName) do
    if self.slotInputIgnore_[slotId] and not Z.IsPCUI then
      self.finalState_[slotId] = false
    end
    if AISlotSetMode then
      local slotConfig = Z.TableMgr.GetTable("SkillSlotPositionTableMgr").GetRow(tonumber(slotId), true)
      if slotConfig and slotConfig.SlotType == 0 then
        self.finalState_[slotId] = false
      end
    end
  end
  for _, slotId in pairs(E.SlotName) do
    if slotId == E.SlotName.SkillSlot_10 then
      self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group[slotId], true)
    else
      if self.finalState_[slotId] == nil then
        self.finalState_[slotId] = false
      end
      if self.uiBinder.button_pos_group[slotId .. "_root"] then
        self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group[slotId .. "_root"], self.finalState_[slotId])
      else
        self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group[slotId], self.finalState_[slotId])
      end
    end
  end
end

function FighterBtnsView:Refresh()
end

function FighterBtnsView:onPorfessionChange()
  self:ClearBattleRes()
  self.battleResHelper_:OnPorfessionChange()
end

function FighterBtnsView:ClearBattleRes()
  if self.battleResHelper_ then
    self.battleResHelper_:DeActive()
  end
end

function FighterBtnsView:refreshRidingBtn()
  self:refreshBtnContainerState()
end

function FighterBtnsView:onPlayerStateChange()
  self:refreshBtnContainerState()
end

function FighterBtnsView:refreshBtnContainerState()
  local templateData = self.vm:GetBtnContainerState()
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
    self:changeSkillPanelToggle(templateData.IsChangeSkillPanel)
  end
  if templateData.IsShowSkillCheckBtn ~= nil then
    self:refreshSkillCheckBtn(templateData.IsShowSkillCheckBtn)
  end
  if templateData.Type then
    if self.playerCtrlTmpMgr_:GetCurrentTmpValue() == templateData.Type then
      return
    end
    self:ChangedCtrlTemplate(templateData.Type)
  end
  self:refreshPcSkillPanel()
  self:refreshEnvCtrlBtn()
end

function FighterBtnsView:ChangedCtrlTemplate(tmpType)
  self.playerCtrlTmpMgr_:ClearCurTmpCtrlBtns()
  self.playerCtrlTmpMgr_:CreateTmpCtrlBtns(tmpType)
  self.vm:SetPlayerCtrlTmpType(tmpType)
  self:inputUIFresh()
end

function FighterBtnsView:onInputQuickUse()
  self.quickUseItemComp_:QuickUseItem()
end

function FighterBtnsView:refreshBattleResView()
  if self.battleResHelper_ == nil then
    self.battleResHelper_ = battleResUIHelper.new(self.uiBinder.group_energy, self)
    self.battleResHelper_:Active()
  end
  self.battleResHelper_:Refresh()
end

function FighterBtnsView:refreshTalentIcon()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_talent_icon, false)
  local switchVM = Z.VMMgr.GetVM("switch")
  local isOpen = switchVM.CheckFuncSwitch(E.FunctionID.Talent)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_talent_lock, not isOpen)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  if weaponId then
    local ProfessionSystemRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if ProfessionSystemRow then
      self.uiBinder.img_talent_icon:SetImage(ProfessionSystemRow.Icon)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_talent_icon, isOpen)
    end
  end
  self:refreshTalentPointBtn()
end

function FighterBtnsView:refreshTalentPointBtn()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local isFishingState = stateID == Z.PbEnum("EActorState", "ActorStateFishing")
  if isFishingState then
    return
  end
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  if talentSkillVM.CheckTalentTreeRed() or talentSkillVM.CheckRed() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_talentweapon_reddot, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_talentweapon_reddot, false)
  end
end

function FighterBtnsView:showPlayerBlood()
  self.uiBinder.group_blood.Ref.UIComp:SetVisible(true)
  if Z.EntityMgr.PlayerEnt == nil then
    if self.playerHpWatcher ~= nil then
      self:UnBindEntityLuaAttrWatcher(self.playerHpWatcher)
    end
    self.uiBinder.group_blood.Ref.UIComp:SetVisible(false)
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
  self.uiBinder.group_blood.lab_hp_num.text = curHp .. "/" .. maxHp
  self.vm:SetPlayerLastHpData(curHp, maxHp)
  self:setBlood(self.uiBinder.group_blood, progress, 0)
  self:setShield(self.uiBinder.group_blood, maxHp, progress, shieldProgressList)
end

function FighterBtnsView:refreshPlayBlood()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
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
  self.uiBinder.group_blood.lab_hp_num.text = curHp .. "/" .. maxHp
  if curHp == 0 then
    self.vm:SetPlayerLastHpData(curHp, maxHp)
    self:setBlood(self.uiBinder.group_blood, 0, 3)
    self:setShield(self.uiBinder.group_blood, maxHp, 0, shieldProgressList)
    return
  end
  local progress, stage = self.vm:calculatePlayerBlood(curHp, maxHp, shieldMaxValue)
  self:setBlood(self.uiBinder.group_blood, progress, stage)
  self:setShield(self.uiBinder.group_blood, maxHp, progress, shieldProgressList)
end

function FighterBtnsView:setBlood(uiBinder, progress, stage)
  uiBinder.node_slider_little_blood:SetFilled(progress, stage == 1)
  uiBinder.node_slider_big_blood:SetFilled(progress, stage == 2)
  uiBinder.node_slider_add_blood:SetFilled(progress, false)
  uiBinder.node_slider_top_blood:SetFilled(progress, stage == 3)
end

function FighterBtnsView:setShield(uiBinder, maxHp, hpProgress, progressList)
  if progressList ~= nil and 0 < #progressList then
    local maxShieldValue = 0
    for _, progressInfo in ipairs(progressList) do
      if maxShieldValue < progressInfo.shieldValue then
        maxShieldValue = progressInfo.shieldValue
      end
    end
    uiBinder.node_slider_shield_max:SetFilled(maxShieldValue / maxHp)
  else
    uiBinder.node_slider_shield_max:SetFilled(hpProgress)
  end
end

function FighterBtnsView:CreateQteUIUnit(qteId)
  QteCreator.Create(qteId, self, self.uiBinder)
end

function FighterBtnsView:startAnimatedShow()
end

function FighterBtnsView:startAnimatedHide()
end

function FighterBtnsView:initProfessionBtn()
  self:AddAsyncClick(self.uiBinder.btn_talent, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Talent)
  end)
end

function FighterBtnsView:onBuffChange()
  self:refreshSlotShowOrHide()
  if self.battleResHelper_ then
    self.battleResHelper_:OnBuffChange()
  end
  self:refreshAutoBattleSwitch()
end

function FighterBtnsView:onBattleResCdChange(resId, fightResCd)
  if self.battleResHelper_ then
    self.battleResHelper_:OnBattleResCdChange(resId, fightResCd)
  end
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
  local buffListPath = self.uiBinder.prefab_cache:GetString("buffNoticeItem")
  local unitName = string.zconcat("buffNotice", buffData.BuffUuid)
  local listPath = self.uiBinder.node_bufftime_list
  if buffData.BuffType ~= E.EBuffType.Gain then
    listPath = self.uiBinder.node_debufftime_list
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
  unit.battle_icon_buff_tpl.lab_digit.text = buffData.Layer
  unit.battle_icon_buff_tpl.Ref:SetVisible(unit.battle_icon_buff_tpl.node_buff_mask, buffData.BuffType ~= E.EBuffType.Debuff)
  unit.battle_icon_buff_tpl.Ref:SetVisible(unit.battle_icon_buff_tpl.node_debuff_mask, buffData.BuffType == E.EBuffType.Debuff)
  unit.battle_icon_buff_tpl.Ref:SetVisible(unit.battle_icon_buff_tpl.node_layer, buffData.Layer > 1)
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
    if buffData.BuffTime and 0 < buffData.BuffTime then
      if totalTime > buffData.BuffTime then
        begin = 1
      else
        begin = totalTime / buffData.BuffTime
      end
    else
      begin = totalTime / buffData.DurationTime
    end
    unit.battle_icon_buff_tpl.img_progress:Play(begin, 0, totalTime, nil, buffData.BuffTime)
    progress:Play(begin, 0, totalTime, nil, buffData.BuffTime)
    noticeData.imgbar1 = unit.battle_icon_buff_tpl.img_progress
    noticeData.imgbar2 = progress
  end
end

function FighterBtnsView:initSkillPanelToggle()
  if Z.IsPCUI then
    return
  end
  self.uiBinder.button_pos_group.toggle_skill:AddListener(function(isOn)
    self:refreshSkillPanel(isOn)
    self.vm:SetSkillPanelLocked(not isOn)
  end)
end

function FighterBtnsView:changeSkillPanelToggle(isBattlePanel)
  if Z.IsPCUI then
    return
  end
  if self.vm:GetSkillPanelLocked() then
    return
  end
  self.uiBinder.button_pos_group.toggle_skill:SetIsOnWithoutCallBack(isBattlePanel)
  self:refreshSkillPanel(isBattlePanel)
end

function FighterBtnsView:refreshSkillPanel(isShow)
  if Z.IsPCUI then
    return
  end
  if self.vm:CheckIsBanSkill() and not Z.EntityMgr.PlayerEnt.IsRiding then
    isShow = false
  end
  if isShow then
    self:cancelSwitchNormalSkillPanel()
    self:checkRushSkillPanelChange()
  end
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.node_skill_1, isShow)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.node_skill_2, not isShow)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.img_off, not isShow)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.img_on, isShow)
  self.isOnSkillPanel_ = isShow
  self.vm:SetSkillPanelShow(isShow)
end

function FighterBtnsView:refreshSkillCheckBtn(isShow)
  if Z.IsPCUI then
    return
  end
  local professionVm = Z.VMMgr.GetVM("profession")
  if not professionVm:CheckProfessionEquipWeapon() then
    self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.toggle_skill, false)
    return
  end
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance2) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Resonance1) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump) and Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Rush) then
    self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.toggle_skill, false)
    return
  end
  if self.vm:CheckIsBanSkill() and not Z.EntityMgr.PlayerEnt.IsRiding then
    self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.toggle_skill, false)
    return
  end
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.toggle_skill, isShow)
end

function FighterBtnsView:checkOutCombatSkillPanelChange()
  if Z.IsPCUI then
    return
  end
  local combatState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCombatState")).Value > 0
  if not combatState and not Z.EntityMgr.PlayerEnt:GetLuaLocalAttrInBattleShow() then
    self:delaySwitchNormalSkillPanel(5)
  end
end

function FighterBtnsView:onSkillInput(isPress)
  self:changeSkillPanelToggle(isPress)
end

function FighterBtnsView:checkBattleShowSkillPanelChange()
  if Z.IsPCUI then
    return
  end
  local combatState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrCombatState")).Value > 0
  if not combatState and not Z.EntityMgr.PlayerEnt:GetLuaLocalAttrInBattleShow() then
    self:changeSkillPanelToggle(false)
  end
end

function FighterBtnsView:checkRushSkillPanelChange()
  if Z.IsPCUI then
    return
  end
  local moveType = Z.EntityMgr.PlayerEnt:GetLuaAttrVirtualMoveType()
  local dontShowBattleList = {
    Z.PbEnum("EMoveType", "MoveDash")
  }
  if table.zcontains(dontShowBattleList, moveType) then
    self:delaySwitchNormalSkillPanel(5)
  end
end

function FighterBtnsView:delaySwitchNormalSkillPanel(time)
  if Z.IsPCUI then
    return
  end
  local currentTmpTable = self.playerCtrlTmpMgr_:GetCurrentTmpValue()
  if currentTmpTable == E.PlayerCtrlBtnTmpType.Vehicles then
    return
  end
  if self.delayHideSkillPanleTimer_ then
    return
  end
  self.delayHideSkillPanleTimer_ = self.timerMgr:StartTimer(function()
    self:changeSkillPanelToggle(false)
  end, time)
end

function FighterBtnsView:cancelSwitchNormalSkillPanel()
  if Z.IsPCUI then
    return
  end
  if self.delayHideSkillPanleTimer_ then
    self.timerMgr:StopTimer(self.delayHideSkillPanleTimer_)
    self.delayHideSkillPanleTimer_ = nil
  end
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
  if Z.IsPCUI then
    return
  end
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
  local settingVM = Z.VMMgr.GetVM("setting")
  local autoBattleOpen = settingVM.Get(E.SettingID.AutoBattle)
  if autoBattleOpen == false and Z.EntityMgr.PlayerEnt ~= nil then
    Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.EAutoBattleSwitch, false)
    Panda.ZGame.ZBattleUtils.StopPlayerAIBattle()
  end
  if Z.IsPCUI then
    return
  end
  self.uiBinder.node_auto_battle.Ref.UIComp:SetVisible(autoBattleOpen)
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Skill) then
    self.uiBinder.node_auto_battle.Ref.UIComp:SetVisible(false)
    return
  end
  if self.vm:CheckIsBanSkill() then
    self.uiBinder.node_auto_battle.btn_feame.IsDisabled = true
    self.uiBinder.node_auto_battle.btn_feame.interactable = false
    return
  end
  self.uiBinder.node_auto_battle.btn_feame.interactable = true
  self.uiBinder.node_auto_battle.btn_feame.IsDisabled = false
  self:AddAsyncClick(self.uiBinder.node_auto_battle.btn_feame, function()
    if not Z.VMMgr.GetVM("profession").CheckProfessionEquipWeapon() then
      Z.TipsVM.ShowTips(150009)
      return
    end
    local switchOpen = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAutoBattleSwitch).Value
    switchOpen = not switchOpen
    if Z.EntityMgr.PlayerEnt ~= nil then
      Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.EAutoBattleSwitch, switchOpen)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.AutoBattleChange)
    if switchOpen == false and Z.EntityMgr.PlayerEnt ~= nil then
      Panda.ZGame.ZBattleUtils.StopPlayerAIBattle()
    end
  end)
  local switchOpen = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAutoBattleSwitch).Value
  if switchOpen then
    self.uiBinder.node_auto_battle.img_feame:SetColorByHex(E.ColorHexValues.Yellow)
    self.uiBinder.node_auto_battle.img_icon:SetColorByHex(E.ColorHexValues.Yellow)
  else
    self.uiBinder.node_auto_battle.img_feame:SetColorByHex(E.ColorHexValues.White)
    self.uiBinder.node_auto_battle.img_icon:SetColorByHex(E.ColorHexValues.White)
  end
end

function FighterBtnsView:refreshProfessionBuffTips()
  if self.professionBuffShowHelper_ == nil then
    self.professionBuffShowHelper_ = professionBuffShowHelper.new(self, self.uiBinder.profession_buff_icon_group)
    self.professionBuffShowHelper_:Init()
  else
    self.professionBuffShowHelper_:RefreshProfessionBuffTips()
  end
end

function FighterBtnsView:ForceChangeSkillPanel(isShow)
  if Z.IsPCUI then
    return
  end
  local isOn = isShow
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.node_skill_1, isOn)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.node_skill_2, not isOn)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.img_off, not isOn)
  self.uiBinder.button_pos_group.Ref:SetVisible(self.uiBinder.button_pos_group.img_on, isOn)
end

function FighterBtnsView:SetPlayerStateNodeIsShow(isShow)
  if not Z.IsPCUI then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_protection, isShow)
end

function FighterBtnsView:switchAISetMode()
  self:refreshSlotShowOrHide()
  self:refreshPcSkillPanel()
  self:hidePlayerStateBar(not self.vm:CheckAISlotSetMode())
end

function FighterBtnsView:OpenSkillRoulette(slotId, open)
  if Z.IsPCUI then
    return
  end
  local slotConfig = Z.TableMgr.GetRow("SkillSlotPositionTableMgr", slotId)
  if slotConfig == nil or slotConfig.SlotLogicType == E.SkillSlotLogicType.SceneMaskSkill then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_skill_cancel, open)
end

function FighterBtnsView:refreshEnergy()
  if not Z.IsPCUI then
    return
  end
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  self.maxEnergyValue_ = math.floor(Z.EntityMgr.PlayerEnt:GetLuaMaxOriEnergy())
  self.energyTimer_ = self.timerMgr:StartTimer(function()
    if Z.EntityMgr.PlayerEnt == nil then
      logError("PlayerEnt is nil")
      return
    end
    self.curEnergy_ = math.floor(Z.EntityMgr.PlayerEnt:GetLuaOriginEnergy())
    self.isFullEnergy_ = self.curEnergy_ == self.maxEnergyValue_
    self.lastIsFullEnergy = self.lastEnergy_ == self.maxEnergyValue_
    if self.lastIsFullEnergy ~= self.isFullEnergy_ then
      self:refreshPcSkillPanel()
    end
    self.lastEnergy_ = self.curEnergy_
    self.uiBinder.group_str.node_slider_str_blood:SetFilled(self.curEnergy_ / self.maxEnergyValue_)
    self.uiBinder.group_str.lab_str_num.text = self.curEnergy_ .. "/" .. self.maxEnergyValue_
    if self.curEnergy_ < Z.GlobalParkour.OriginEnergyAlertPercent then
      if not self.isAlert_ then
        self.isAlert_ = true
        self.uiBinder.group_str.eff_red:SetEffectGoVisible(true)
      end
    else
      self.uiBinder.group_str.eff_red:SetEffectGoVisible(false)
      self.isAlert_ = false
    end
  end, 0.1, -1)
  Z.EventMgr:Add("MaxOriginEnergyChanged", self.refreshMaxEnergy, self)
end

function FighterBtnsView:refreshMaxEnergy()
  if not Z.IsPCUI then
    return
  end
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  self.maxEnergyValue_ = math.floor(Z.EntityMgr.PlayerEnt:GetLuaMaxOriEnergy())
  self.uiBinder.group_str.node_slider_str_blood:SetFilled(self.curEnergy_ / self.maxEnergyValue_)
  self.uiBinder.group_str.lab_str_num.text = self.curEnergy_ .. "/" .. self.maxEnergyValue_
end

return FighterBtnsView
