local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_main_windowView = class("Fishing_main_windowView", super)
local itemClass = require("common.item_binder")
local fishingItemSelectView = require("ui/view/fishing_itemselect_tips_view")
local fishingCtrlBtn = require("ui/view/fishing_btn_ctrl_view")
local joysyickView = require("ui/view/fishing_touch_area_tpl_view")
local bottomUIView = require("ui/view/main_bottom_ui_sub_view")
local fishingSetting = require("ui/view/fishing_set_sub_view")
local mainShortcutView = require("ui/view/main_shortcut_key_view")
local PERSONAL_ZONE_DEFINE = require("ui.model.personalzone_define")

function Fishing_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_main_window")
  self.baitItemClass_ = itemClass.new(self)
  self.fishRodItemClass_ = itemClass.new(self)
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.joystickView_ = joysyickView.new()
  self.fishingCtrlBtn_ = fishingCtrlBtn.new()
  self.bottomUIView_ = bottomUIView.new()
  self.mainShortcutView_ = mainShortcutView.new()
  self.fishingSettingView_ = fishingSetting.new(self)
  self.isPlayStripAnim_ = false
  self.oldFishingProgress = 0
  self.curSliderState_ = E.FishingSliderState.None
  self.fishingSliderColor = {
    [E.FishingSliderState.None] = Color.New(0.023529411764705882, 1, 0.40784313725490196, 1),
    [E.FishingSliderState.Green] = Color.New(0.023529411764705882, 1, 0.40784313725490196, 1),
    [E.FishingSliderState.Yellow] = Color.New(0.9411764705882353, 0.803921568627451, 0.050980392156862744, 1),
    [E.FishingSliderState.Orange] = Color.New(0.9647058823529412, 0.44313725490196076, 0.054901960784313725, 1),
    [E.FishingSliderState.Red] = Color.New(0.8980392156862745, 0.0392156862745098, 0.03529411764705882, 1),
    [E.FishingSliderState.Flash] = Color.New(0.8980392156862745, 0.0392156862745098, 0.03529411764705882, 1)
  }
end

function Fishing_main_windowView:OnActive()
  if Z.IsPCUI then
    Z.ZInputMapModeMgr:ChangeInputMode(Panda.ZInput.EInputMode.Fishing)
    self:InitPCUIInput()
    self:refreshProtection()
  end
  self:onFishingStageChanged()
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.UIInteract, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.QuickUseItem, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.NormalAttack, true, Panda.ZGame.EIgnoreMaskSource.Fishing)
  self.mainUIData_:SetIsShowMainChat(true)
  self.chatMainVM_.OpenMainChatView()
  Z.EventMgr:Dispatch(Z.ConstValue.Fishing.UpdateFishingMainChat)
  self:bindEvent()
  self:initbinder()
  self:AddClick(self.uiBinder.btn_return, function()
    self:startAnimatedHide()
  end)
  self:AddClick(self.uiBinder.node_lv.btn_func, function()
    self.fishingVM_.OpenMainFuncWindow()
  end)
  self:resetData()
  self:AddClick(self.uiBinder.fishing_item_bait.btn_self, function()
    self:showItemSelectView(E.FishingItemType.FishBait)
  end)
  self:AddClick(self.uiBinder.fishing_item_fishingrod.btn_self, function()
    self:showItemSelectView(E.FishingItemType.FishingRod)
  end)
  if self.uiBinder.btn_helpsys then
    self:AddClick(self.uiBinder.btn_helpsys, function()
      local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
      helpsysVM_.OpenMulHelpSysView(6050)
    end)
  end
  if self.uiBinder.btn_set then
    self:AddClick(self.uiBinder.btn_set, function()
      self:OpenSettingView()
    end)
  end
  self.fishingCtrlBtn_:Active(nil, self.uiBinder.fishing_btn_ctrl_holder)
  if not Z.IsPCUI then
    self.bottomUIView_:Active(nil, self.uiBinder.node_bottom_ui_sub)
  end
  self.fishingVM_.ResetEntityAndUIVisible(true)
  Z.UIMgr:FadeOut()
  self:preLoadResultView()
  self.curSelectType_ = nil
end

function Fishing_main_windowView:onDeviceTypeChange()
  self:InitPCUIInput()
end

function Fishing_main_windowView:onFishingStageChanged()
  if self.fishingData_.FishingStage == E.FishingStage.FishBiteHook and self.fishingData_.TargetFish.FishInfo.FishingHint then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bite, true)
    self.uiBinder.anim_img_tips:CoroPlayOnce("anim_fishing_main_window_04_open_1", self.cancelSource:CreateToken(), function()
      self.uiBinder.anim_img_tips:PlayLoop("anim_fishing_main_window_04_open_2")
    end, nil)
  else
    self.uiBinder.anim_img_tips:CoroPlayOnce("anim_fishing_main_window_04_close", self.cancelSource:CreateToken(), function()
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_bite, false)
    end, nil)
  end
end

function Fishing_main_windowView:OnDeActive()
  local fishingSourceEInt = Panda.ZGame.EIgnoreMaskSource.Fishing:ToInt()
  local sourceMask = 1 << fishingSourceEInt
  Z.IgnoreMgr:ClearAllIgnore(sourceMask)
  self:unbindEvent()
  self.joystickView_:DeActive()
  self.fishingCtrlBtn_:DeActive()
  if not Z.IsPCUI then
    self.bottomUIView_:DeActive()
  end
  self.mainShortcutView_:DeActive()
  self.fishingData_.IgnoreInputBack = false
  self.fishingVM_.ResetEntityAndUIVisible()
  self:CloseSettingView()
  self:releaseResultView()
  self.mainUIData_:SetIsShowMainChat(false)
  self.chatMainVM_.CloseMainChatView()
  self.stateQuited = false
  if Z.IsPCUI then
    Z.ZInputMapModeMgr:ChangeInputMode(Z.ZInputMapModeMgr.GamePlayDefaultMode)
  end
  self.curSelectType_ = nil
  if self.itemSelectView_ then
    self.itemSelectView_:DeActive()
  end
end

function Fishing_main_windowView:refreshProtection()
  local protectionBinder = self.uiBinder.protection_binder
  protectionBinder.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  protectionBinder.lab_talent_name.text = Z.VMMgr.GetVM("talent_skill").GetCurProfessionTalentStageName()
  protectionBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local titleId = personalzoneVM.GetCurProfileImageId(PERSONAL_ZONE_DEFINE.ProfileImageType.Title)
  if titleId and titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= PERSONAL_ZONE_DEFINE.ProfileImageUnlockType.DefaultUnlock then
      protectionBinder.lab_title.text = profileImageConfig.Name
    else
      protectionBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    protectionBinder.lab_title.text = Lang("NoneTitle")
  end
  self:AddAsyncClick(protectionBinder.btn_talent, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Talent)
  end)
  self:refreshTalentIcon(protectionBinder)
  self:refreshPlayerLvExp(protectionBinder)
end

function Fishing_main_windowView:refreshTalentPointBtn()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  if talentSkillVM.CheckTalentTreeRed() or talentSkillVM.CheckRed() then
    self.uiBinder.protection_binder.Ref:SetVisible(self.uiBinder.protection_binder.img_talentweapon_reddot, true)
  else
    self.uiBinder.protection_binder.Ref:SetVisible(self.uiBinder.protection_binder.img_talentweapon_reddot, false)
  end
end

function Fishing_main_windowView:refreshTalentIcon(protectionBinder)
  protectionBinder.Ref:SetVisible(protectionBinder.img_talent_icon, false)
  local switchVM = Z.VMMgr.GetVM("switch")
  local isOpen = switchVM.CheckFuncSwitch(E.FunctionID.Talent)
  protectionBinder.Ref:SetVisible(protectionBinder.img_talent_lock, not isOpen)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponId = weaponVm.GetCurWeapon()
  if weaponId then
    local ProfessionSystemRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if ProfessionSystemRow then
      protectionBinder.img_talent_icon:SetImage(ProfessionSystemRow.Icon)
      protectionBinder.Ref:SetVisible(protectionBinder.img_talent_icon, isOpen)
    end
  end
  self:refreshTalentPointBtn()
end

function Fishing_main_windowView:refreshPlayerLvExp(protectionBinder)
  if Z.IsPCUI then
    local rolelevelData = Z.DataMgr.Get("role_level_data")
    local roleLv = Z.ContainerMgr.CharSerialize.roleLevel.level
    protectionBinder.Ref:SetVisible(protectionBinder.lab_max, roleLv == rolelevelData.MaxPlayerLevel)
    protectionBinder.lab_lv.text = Lang("Level", {val = roleLv})
    local roleLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLv)
    if roleLv == rolelevelData.MaxPlayerLevel then
      protectionBinder.Ref:SetVisible(protectionBinder.lab_max, true)
      protectionBinder.img_exp.fillAmount = 1
      protectionBinder.img_exp_green.fillAmount = 1
    else
      protectionBinder.Ref:SetVisible(protectionBinder.lab_max, false)
      if roleLevelCfg then
        local maxExp = roleLevelCfg.Exp
        local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
        protectionBinder.img_exp.fillAmount = curExp / maxExp
      end
    end
    local rolelevelVm = Z.VMMgr.GetVM("rolelevel_main")
    if rolelevelVm.IsBlessExpFuncOn() then
      if roleLv < Z.ContainerMgr.CharSerialize.roleLevel.prevSeasonMaxLv then
        protectionBinder.img_exp_green.fillAmount = 1
      elseif roleLevelCfg then
        local maxExp = roleLevelCfg.Exp
        local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
        protectionBinder.img_exp_green.fillAmount = (roleLevelInfo.curLevelExp + roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp) / maxExp
      end
    else
      protectionBinder.img_exp_green.fillAmount = 0
    end
  end
end

function Fishing_main_windowView:resizeHotKeySize(binder)
  local size = binder.lab_key:GetPreferredValues(binder.lab_key.text, 0, 20)
  binder.Trans:SetWidth(size.x)
end

function Fishing_main_windowView:SetKeyCode(lab_keycode, rowId)
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local val = keyVM.GetKeyCodeDescListByKeyId(rowId)[1]
  if val == nil or val == "" then
    self.uiBinder.Ref:SetVisible(lab_keycode, false)
    return
  end
  self.uiBinder.Ref:SetVisible(lab_keycode, true)
  lab_keycode.text = Lang("KeyCode", {val = val})
end

function Fishing_main_windowView:InitPCUIInput()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  self:SetKeyCode(self.uiBinder.lab_keycode_lv, 145)
  self:SetKeyCode(self.uiBinder.lab_keycode_study, 146)
  self:SetKeyCode(self.uiBinder.lab_keycode_bait, 147)
  self:SetKeyCode(self.uiBinder.lab_keycode_rod, 148)
  self:SetKeyCode(self.uiBinder.lab_keycode_playerInfo, 152)
  self.uiBinder.main_key_bottom_tpl_click.lab_key.text = Lang("KeyCodeFish", {
    val = keyVM.GetKeyCodeDescListByKeyId(149)[1]
  })
  self.uiBinder.main_key_bottom_tpl_guide.lab_key.text = Lang("KeyCodeFishingGuide", {
    val = keyVM.GetKeyCodeDescListByKeyId(150)[1]
  })
  self.uiBinder.main_key_bottom_tpl_setting.lab_key.text = Lang("KeyCodeFishingSetting", {
    val = keyVM.GetKeyCodeDescListByKeyId(151)[1]
  })
  self:resizeHotKeySize(self.uiBinder.main_key_bottom_tpl_click)
  self:resizeHotKeySize(self.uiBinder.main_key_bottom_tpl_guide)
  self:resizeHotKeySize(self.uiBinder.main_key_bottom_tpl_setting)
  
  function self.FishingLevelClick(inputActionEventData)
    self.fishingVM_.OpenMainFuncWindow()
  end
  
  function self.FishingStudyClick(inputActionEventData)
    self.fishingVM_.OpenMainFuncWindow(E.FishingMainFunc.Research)
  end
  
  function self.FishingBaitClick(inputActionEventData)
    if self.curSelectType_ == E.FishingItemType.FishBait and self.itemSelectView_ and self.itemSelectView_.IsActive then
      self.itemSelectView_:DeActive()
      self.curSelectType_ = nil
      return
    end
    if self.itemSelectView_ and self.itemSelectView_.IsActive then
      self.itemSelectView_:DeActive()
    end
    self:showItemSelectView(E.FishingItemType.FishBait)
  end
  
  function self.FishingRodClick(inputActionEventData)
    if self.curSelectType_ == E.FishingItemType.FishingRod and self.itemSelectView_ and self.itemSelectView_.IsActive then
      self.itemSelectView_:DeActive()
      self.curSelectType_ = nil
      return
    end
    if self.itemSelectView_ and self.itemSelectView_.IsActive then
      self.itemSelectView_:DeActive()
    end
    self:showItemSelectView(E.FishingItemType.FishingRod)
  end
  
  function self.FishingGuideClick(inputActionEventData)
    local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
    helpsysVM_.OpenMulHelpSysView(6050)
  end
  
  function self.FishingSettingClick(inputActionEventData)
    if self.fishingSettingView_.IsActive then
      self:CloseSettingView()
    else
      self:OpenSettingView()
    end
  end
  
  function self.FishingPlayerDetailClick(inputActionEventData)
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Talent)
  end
end

function Fishing_main_windowView:OnTriggerInputAction(inputActionEventData)
  if not Z.IsPCUI then
    return
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingLevel then
    self.FishingLevelClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingStudy then
    self.FishingStudyClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingBait then
    self.FishingBaitClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingRod then
    self.FishingRodClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingGuide then
    self.FishingGuideClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingSetting then
    self.FishingSettingClick(inputActionEventData)
  end
  if inputActionEventData.ActionId == Z.InputActionIds.FishingPlayerDetail then
    self.FishingPlayerDetailClick(inputActionEventData)
  end
end

function Fishing_main_windowView:OnRefresh()
  self:refreshFishingBait()
  self:refreshFishingRod()
  self:refreshFishingSlider(0)
  self:refreshDirNoMatchEffect()
  self:setFishingStage()
  self:refreshFishingLevelUI()
  self:refreshFishingResearchUI()
  self:startAnimatedShow()
  self:refreshMainShortCutView()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingMainLevelBtn, self, self.uiBinder.node_lv.Trans)
end

function Fishing_main_windowView:refreshMainShortCutView()
  if Z.IsPCUI then
    local shortcutViewData = {
      keyList = Z.Global.SetKeyboardShowFishing,
      isShowShortcut = true
    }
    self.mainShortcutView_:Active(shortcutViewData, self.uiBinder.node_bottom_ui_sub)
  end
end

function Fishing_main_windowView:resetData()
  self.isPlayStripAnim_ = false
  self.oldFishingProgress = 0
  self.curSliderState_ = E.FishingSliderState.None
end

function Fishing_main_windowView:refreshFishingRod()
  local haveRod_ = self.fishingData_.FishingRod ~= nil and self.fishingData_.FishingRod ~= 0
  if Z.IsPCUI then
    self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.anim_item_node, haveRod_)
    self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.img_empty, not haveRod_)
    if haveRod_ then
      local rodInfo_ = self.itemsVM_.GetItemTabDataByUuid(self.fishingData_.FishingRod)
      if rodInfo_ then
        local rodConfigId_ = rodInfo_.Id
        local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(rodConfigId_)
        self.uiBinder.fishing_item_fishingrod.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(rodConfigId_))
        self.uiBinder.fishing_item_fishingrod.btn_bg:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. itemTableBase.Quality)
        local fishingRodRow_ = Z.TableMgr.GetTable("FishingRodTableMgr").GetRow(rodConfigId_)
        if not fishingRodRow_ then
          return
        end
        local res = fishingRodRow_.Durability
        self.uiBinder.fishing_item_fishingrod.lab_durability.text = self.fishingData_:GetFishingRodDurability(self.fishingData_.FishingRod) .. "/" .. res
        self.uiBinder.fishing_item_fishingrod.lab_tool.text = itemTableBase.Name
      else
        logError("\230\156\170\230\137\190\229\136\176uuid=" .. self.fishingData_.FishingRod .. "\231\154\132\233\133\141\231\189\174\230\149\176\230\141\174")
      end
    end
  else
    self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.anim_item_node, haveRod_)
    self.uiBinder.fishing_item_fishingrod.Ref:SetVisible(self.uiBinder.fishing_item_fishingrod.img_empty, not haveRod_)
    if haveRod_ then
      local rodInfo_ = self.itemsVM_.GetItemTabDataByUuid(self.fishingData_.FishingRod)
      if rodInfo_ then
        local rodConfigId_ = rodInfo_.Id
        local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(rodConfigId_)
        self.fishRodItemClass_:InitCircleItem(self.uiBinder.fishing_item_fishingrod, rodConfigId_, nil, itemTableBase.Quality, nil, Z.ConstValue.QualityImgRoundBg)
        local fishingRodRow_ = Z.TableMgr.GetTable("FishingRodTableMgr").GetRow(rodConfigId_)
        if not fishingRodRow_ then
          return
        end
        local res = fishingRodRow_.Durability
        local fillAmount = 0
        if res ~= 0 then
          fillAmount = self.fishingData_:GetFishingRodDurability(self.fishingData_.FishingRod) / res
        end
        self.uiBinder.fishing_item_fishingrod.img_on.fillAmount = fillAmount
      else
        logError("\230\156\170\230\137\190\229\136\176uuid=" .. self.fishingData_.FishingRod .. "\231\154\132\233\133\141\231\189\174\230\149\176\230\141\174")
      end
    end
  end
end

function Fishing_main_windowView:refreshFishingBait()
  local haveBaits_ = self.fishingData_.FishBait ~= nil and self.fishingData_.FishBait ~= 0
  if Z.IsPCUI then
    self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.anim_item_node, haveBaits_)
    self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.img_empty, not haveBaits_)
    if haveBaits_ then
      local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.fishingData_.FishBait)
      self.uiBinder.fishing_item_bait.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(self.fishingData_.FishBait))
      self.uiBinder.fishing_item_bait.btn_bg:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. itemTableBase.Quality)
      self.uiBinder.fishing_item_bait.lab_content.text = Lang("FishingBaitCount", {
        val = self.itemsVM_.GetItemTotalCount(self.fishingData_.FishBait)
      })
      self.uiBinder.fishing_item_bait.lab_bait.text = itemTableBase.Name
    end
  else
    self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.anim_item_node, haveBaits_)
    self.uiBinder.fishing_item_bait.Ref:SetVisible(self.uiBinder.fishing_item_bait.img_empty, not haveBaits_)
    if haveBaits_ then
      local itemTableBase = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.fishingData_.FishBait)
      self.baitItemClass_:InitCircleItem(self.uiBinder.fishing_item_bait, self.fishingData_.FishBait, nil, itemTableBase.Quality, nil, Z.ConstValue.QualityImgRoundBg)
      self.uiBinder.fishing_item_bait.lab_content.text = self.itemsVM_.GetItemTotalCount(self.fishingData_.FishBait)
    end
  end
end

function Fishing_main_windowView:refreshFishingLevelUI()
  self.uiBinder.node_lv.lab_lv.text = self.fishingData_.FishingLevel
  self.uiBinder.node_lv.img_exp.fillAmount = self.fishingData_.PeripheralData.FishingLevelProgress[1]
end

function Fishing_main_windowView:refreshFishingResearchUI()
  local useFishResearch = self.fishingData_.QTEData.UseResearchFish ~= nil and self.fishingData_.QTEData.UseResearchFish ~= 0
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_study, useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_empty, not useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_quality, useFishResearch)
  self.uiBinder.node_study.Ref:SetVisible(self.uiBinder.node_study.img_mask_icon, useFishResearch)
  if useFishResearch then
    local recordData_ = self.fishingData_.FishRecordDict[self.fishingData_.QTEData.UseResearchFish]
    self.uiBinder.node_study.img_study.fillAmount = recordData_.ResearchProgress[1]
    self.uiBinder.node_study.rimg_icon:SetImage(recordData_.FishCfg.FishingIcon)
  end
  self.uiBinder.node_study.btn_self:RemoveAllListeners()
  self:AddClick(self.uiBinder.node_study.btn_self, function()
    self.fishingVM_.OpenMainFuncWindow(E.FishingMainFunc.Research)
  end)
end

function Fishing_main_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStateChange, self.setFishingStage, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingRodChange, self.refreshFishingRod, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingBaitChange, self.refreshFishingBait, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingLevelChange, self.refreshFishingLevelUI, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingResearchUseChange, self.refreshFishingResearchUI, self)
  Z.EventMgr:Add(Z.ConstValue.TalentPointChange, self.refreshTalentPointBtn, self)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.TalentListChange, self.refreshTalentPointBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStateChange, self.onFishingStageChanged, self)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceTypeChange, self)
end

function Fishing_main_windowView:unbindEvent()
  Z.EventMgr:RemoveObjAll()
end

function Fishing_main_windowView:initbinder()
  self.runAwayTip_ = self.uiBinder.lab_tips_01
  self.successTip_ = self.uiBinder.lab_tips_02
  self.hookingUpTip_ = self.uiBinder.lab_tips_03
end

function Fishing_main_windowView:refreshFishingSlider()
  local progress = self.fishingData_.QTEData.FishingProgress
  local rodTension = self.fishingData_.QTEData.FishRodTension
  self.uiBinder.lab_percentage.text = self.fishingData_.QTEData.FishRodTensionInt .. "%"
  self.uiBinder.img_strip.fillAmount = rodTension / 100
  self.uiBinder.img_strip_02.fillAmount = rodTension / 100
  local lastState = self.curSliderState_
  if rodTension > Z.Global.FishingTensionGreen[4] then
    self.curSliderState_ = E.FishingSliderState.Flash
  elseif rodTension > Z.Global.FishingTensionGreen[3] and rodTension < Z.Global.FishingTensionGreen[4] then
    self.curSliderState_ = E.FishingSliderState.Red
  elseif rodTension > Z.Global.FishingTensionGreen[2] and rodTension < Z.Global.FishingTensionGreen[3] then
    self.curSliderState_ = E.FishingSliderState.Orange
  elseif rodTension > Z.Global.FishingTensionGreen[1] and rodTension < Z.Global.FishingTensionGreen[2] then
    self.curSliderState_ = E.FishingSliderState.Yellow
  else
    self.curSliderState_ = E.FishingSliderState.Green
  end
  if self.curSliderState_ ~= lastState then
    self.uiBinder.img_strip:SetColor(self.fishingSliderColor[self.curSliderState_])
  end
  if self.curSliderState_ == E.FishingSliderState.Flash then
    if self.isPlayStripAnim_ == false then
      self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_4)
      self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_4)
      self.isPlayStripAnim_ = true
    end
  elseif self.isPlayStripAnim_ == true then
    self.uiBinder.anim:Pause(Z.DOTweenAnimType.Tween_4)
    self.isPlayStripAnim_ = false
  end
  if self.curSliderState_ >= E.FishingSliderState.Red then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, true)
    self.uiBinder.anim_tips:PlayLoop("anim_fishing_main_window_01_open")
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_strip_02, self.curSliderState_ == E.FishingSliderState.Flash)
  self.uiBinder.node_icon:SetAnchors(1 - progress / 100, 1 - progress / 100, 0.5, 0.5)
  self.uiBinder.node_icon:SetAnchorPosition(0, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, self.oldFishingProgress ~= progress)
  self.oldFishingProgress = progress
end

function Fishing_main_windowView:refreshDirNoMatchEffect()
  if self.fishingData_.FishingStage == E.FishingStage.QTE and self.fishingData_.QTEData.ShowDirNoMatchEffect then
    local isLeft = self.fishingData_.TargetFish.dir < self.fishingData_.QTEData.playerSwingDir_
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_left, isLeft)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_right, not isLeft)
    if isLeft then
      self.uiBinder.anim_img_arrow_left:PlayLoop("anim_fishing_main_window_03_open")
    else
      self.uiBinder.anim_img_arrow_right:PlayLoop("anim_fishing_main_window_02_open")
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_left, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_right, false)
  end
end

function Fishing_main_windowView:refreshTips()
  self.uiBinder.Ref:SetVisible(self.runAwayTip_, false)
  self.uiBinder.Ref:SetVisible(self.successTip_, false)
  self.uiBinder.Ref:SetVisible(self.hookingUpTip_, false)
  self.uiBinder.eff_tips01:SetEffectGoVisible(false)
  self.uiBinder.eff_tips02:SetEffectGoVisible(false)
  self.uiBinder.eff_tips03:SetEffectGoVisible(false)
  if self.fishingData_.FishingStage == E.FishingStage.EndRodBreak then
    self.uiBinder.Ref:SetVisible(self.runAwayTip_, true)
    self.uiBinder.eff_tips01:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_1)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_1)
  elseif self.fishingData_.FishingStage == E.FishingStage.EndRunAway or self.fishingData_.FishingStage == E.FishingStage.EndBuoyDive then
    self.uiBinder.Ref:SetVisible(self.runAwayTip_, true)
    self.uiBinder.eff_tips01:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_1)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_1)
  elseif self.fishingData_.FishingStage == E.FishingStage.EndSuccess then
    Z.AudioMgr:Play("UI_Event_Fishing_Get")
    self.uiBinder.Ref:SetVisible(self.successTip_, true)
    self.uiBinder.eff_tips02:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_2)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_2)
  elseif self.fishingData_.FishingStage == E.FishingStage.QTE then
    self.uiBinder.Ref:SetVisible(self.hookingUpTip_, true)
    self.uiBinder.eff_tips03:SetEffectGoVisible(true)
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Tween_3)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Tween_3)
  end
end

function Fishing_main_windowView:setFishingStage()
  self.uiBinder.fishing_item_bait.Ref.UIComp:SetVisible(self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  self.uiBinder.fishing_item_fishingrod.Ref.UIComp:SetVisible(self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider, self.fishingData_.FishingStage == E.FishingStage.QTE)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, self.fishingData_.FishingStage == E.FishingStage.QTE)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, self.fishingData_.FishingStage == E.FishingStage.EnterFishing)
  if self.fishingData_.FishingStage == E.FishingStage.QTE then
    self:resetData()
    self:clearQteTimer()
    self.refreshProgressTimer_ = self.timerMgr:StartFrameTimer(function()
      self:refreshFishingSlider()
      self:refreshDirNoMatchEffect()
    end, self.fishingData_.QTEData.UpdateRate, -1)
    self:openJoystick()
  else
    self:clearQteTimer()
    self:closeJoystick()
  end
  if self.fishingData_.FishingStage == E.FishingStage.EnterFishing then
    self.uiBinder.anim:Pause(Z.DOTweenAnimType.Tween_4)
    self.isPlayStripAnim_ = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_strip_02, false)
  end
  self:refreshDirNoMatchEffect()
  self:refreshTips()
  if self.fishingData_.FishingStage == E.FishingStage.Settlement then
    return
  end
end

function Fishing_main_windowView:clearQteTimer()
  if self.refreshProgressTimer_ then
    self.timerMgr:StopFrameTimer(self.refreshProgressTimer_)
    self.refreshProgressTimer_ = nil
  end
end

function Fishing_main_windowView:openJoystick()
  if not Z.IsPCUI then
    self.joystickView_:Active(nil, self.uiBinder.Trans)
  end
end

function Fishing_main_windowView:closeJoystick()
  if self.joystickView_.IsActive then
    self.joystickView_:DeActive()
  end
end

function Fishing_main_windowView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Fishing_main_windowView:startAnimatedHide()
  self.stateQuited = true
  self.fishingVM_.AsyncQuitFishingState(self.cancelSource:CreateToken())
end

function Fishing_main_windowView:showItemSelectView(type)
  if self.itemSelectView_ == nil then
    self.itemSelectView_ = fishingItemSelectView.new()
  end
  local extraParams = {}
  local viewData_ = {}
  self.curSelectType_ = type
  viewData_.selectType = type
  if type == E.FishingItemType.FishBait then
    if Z.IsPCUI then
      extraParams = {
        fixedPos = Vector3.New(self.uiBinder.fishing_item_bait.Trans.position.x + 2, self.uiBinder.fishing_item_bait.Trans.position.y + 0.5, self.uiBinder.fishing_item_bait.Trans.position.z),
        pivotX = 1,
        pivotY = 0
      }
    else
      extraParams = {
        fixedPos = Vector3.New(self.uiBinder.fishing_item_bait.Trans.position.x + 1, self.uiBinder.fishing_item_bait.Trans.position.y + 7, self.uiBinder.fishing_item_bait.Trans.position.z),
        pivotX = 0,
        pivotY = 1
      }
    end
  elseif Z.IsPCUI then
    extraParams = {
      fixedPos = Vector3.New(self.uiBinder.fishing_item_fishingrod.Trans.position.x + 2, self.uiBinder.fishing_item_fishingrod.Trans.position.y + 0.5, self.uiBinder.fishing_item_fishingrod.Trans.position.z),
      pivotX = 1,
      pivotY = 0
    }
  else
    extraParams = {
      fixedPos = Vector3.New(self.uiBinder.fishing_item_fishingrod.Trans.position.x + 1, self.uiBinder.fishing_item_fishingrod.Trans.position.y + 7, self.uiBinder.fishing_item_fishingrod.Trans.position.z),
      pivotX = 0,
      pivotY = 1
    }
  end
  viewData_.extraParams = extraParams
  viewData_.parentView = self
  self.itemSelectView_:Active(viewData_, self.uiBinder.fishing_item_bait.Trans)
end

function Fishing_main_windowView:OnInputBack()
  if not self.fishingData_.IgnoreInputBack and self.IsResponseInput then
    self:startAnimatedHide()
  end
end

function Fishing_main_windowView:OpenSettingView()
  if self.uiBinder.btn_return then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return, false)
  end
  if self.uiBinder.btn_set then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set, false)
  end
  self.fishingSettingView_:Active(nil, self.uiBinder.Trans)
end

function Fishing_main_windowView:CloseSettingView()
  if self.uiBinder.btn_return then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return, true)
  end
  if self.uiBinder.btn_set then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set, true)
  end
  self.fishingSettingView_:DeActive()
end

function Fishing_main_windowView:preLoadResultView()
  self.resultGo_ = nil
  local viewConfigKey = "fishing_obtain_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  local loadPath = "ui/prefabs/" .. prefabPath
  Z.UIMgr:PreloadObject(loadPath)
end

function Fishing_main_windowView:releaseResultView()
  local viewConfigKey = "fishing_obtain_window"
  local prefabPath = Z.UIConfig[viewConfigKey].PrefabPath
  local loadPath = "ui/prefabs/" .. prefabPath
  Z.UIMgr:ReleasePreloadObject(loadPath)
end

return Fishing_main_windowView
