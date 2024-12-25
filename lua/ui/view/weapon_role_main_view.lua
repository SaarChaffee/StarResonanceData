local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_role_mainView = class("Weapon_role_mainView", super)
local playerPortraitHgr_ = require("ui.component.role_info.common_player_portrait_item_mgr")
local MAX_UP_ATTR_COUNT = 4
local attrTransHeadName = {
  [E.FightAttrId.Crit] = "CriToCrit",
  [E.FightAttrId.HastePct] = "HasteToHastePct",
  [E.FightAttrId.LuckyStrikeProb] = "LuckToLuckyStrikeProb",
  [E.FightAttrId.VersatilityPct] = "VersatilityToVersatilityPct",
  [E.FightAttrId.MasteryPct] = "MasteryToMasteryPct"
}
local attrTransDict = {
  [E.FightAttrId.Crit] = E.FightAttrId.Cri,
  [E.FightAttrId.HastePct] = E.FightAttrId.Haste,
  [E.FightAttrId.LuckyStrikeProb] = E.FightAttrId.Luck,
  [E.FightAttrId.VersatilityPct] = E.FightAttrId.Versatility,
  [E.FightAttrId.MasteryPct] = E.FightAttrId.Mastery
}
local RightSubType = {
  Equip = 1,
  Skill = 2,
  Mod = 3
}
local RightSubLua = {
  [RightSubType.Equip] = "ui/view/weapon_role_main_weapon_sub_view",
  [RightSubType.Skill] = "ui/view/weapon_role_main_skill_sub_view",
  [RightSubType.Mod] = "ui/view/weapon_role_main_mod_sub_view"
}
local DEFINE = require("ui.model.personalzone_define")

function Weapon_role_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main")
end

function Weapon_role_mainView:OnActive()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.vm_ = Z.VMMgr.GetVM("role_info_attr_detail")
  self.portraitVm_ = Z.VMMgr.GetVM("portrait_indiv_popup")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.roleData_ = Z.DataMgr.Get("role_info_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.weaponData_ = Z.DataMgr.Get("weapon_data")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.modVm_ = Z.VMMgr.GetVM("mod")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.charBase_ = Z.ContainerMgr.CharSerialize.charBase
  self:AddAsyncClick(self.uiBinder.btn_detail, function()
    self.vm_.OpenRoleAttrDetailView()
    Z.GuideMgr:CloseView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.weaponVm_.CloseWeaponRoleView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_find, function()
    local rolelevelVm = Z.VMMgr.GetVM("rolelevel_main")
    rolelevelVm.OpenRolelevelAwardPanel()
  end)
  self:AddAsyncClick(self.uiBinder.btn_lab, function()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneTitle)
  end)
  self:AddAsyncClick(self.uiBinder.btn_bg, function()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneCard)
  end)
  self:AddAsyncClick(self.uiBinder.btn_name_redact, function()
    local playerVM = Z.VMMgr.GetVM("player")
    playerVM:OpenRenameWindow()
  end)
  self:AddAsyncClick(self.uiBinder.btn_gs_info, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.gs_root, Lang("CommonGS"), Lang("gs_desc"))
  end)
  self.uiBinder.btn_equip.isOn = false
  self.uiBinder.btn_equip:AddListener(function(isOn)
    if isOn then
      self:openRightSubView(RightSubType.Equip)
    end
  end)
  self.uiBinder.btn_skill.isOn = false
  self.uiBinder.btn_skill:AddListener(function(isOn)
    if isOn then
      self:openRightSubView(RightSubType.Skill)
    end
  end)
  self.uiBinder.btn_mod.isOn = false
  self.uiBinder.btn_mod:AddListener(function(isOn)
    if isOn then
      local isModUnlock = self.funcVm_.CheckFuncCanUse(E.FunctionID.Mod)
      if isModUnlock then
        self:openRightSubView(RightSubType.Mod)
      else
        self.tog_[self.curSubType].isOn = true
      end
    end
  end)
  self.tog_ = {
    [RightSubType.Equip] = self.uiBinder.btn_equip,
    [RightSubType.Skill] = self.uiBinder.btn_skill,
    [RightSubType.Mod] = self.uiBinder.btn_mod
  }
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
  
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHead, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHeadFrame, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneCard, self, self.uiBinder.uibinder_player.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneTitle, self, self.uiBinder.rect_lab)
  self:showAttrs()
  self:showRoleInfo()
  self:loadRedDotItem()
  self:BindEvents()
  self:RegisterInputActions()
  self.subViews_ = {}
  self.curSubView_ = nil
  if Z.EntityMgr.PlayerEnt:GetLuaRidingId() == 0 then
    Z.UICameraHelper.SetCameraFocus(true, Z.Global.CameraFocusMainView[1], Z.Global.CameraFocusMainView[2])
    self.weaponVm_.SwitchEntityShow(false)
  else
    self.weaponVm_.SwitchEntityShow(true)
  end
end

function Weapon_role_mainView:GetCacheData()
  local viewData = {}
  viewData.selectType = self.curSubType
  return viewData
end

function Weapon_role_mainView:openRightSubView(type)
  if self.curSubType == type then
    return
  end
  self.curSubType = type
  if self.subViews_[self.curSubType] == nil then
    self.subViews_[self.curSubType] = require(RightSubLua[self.curSubType]).new(self)
  end
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.subViews_[self.curSubType]
  self.curSubView_:Active(nil, self.uiBinder.node_right)
end

function Weapon_role_mainView:onChangeSubViewType(subViewType)
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.subViews_[subViewType]
  self.curSubView_:Active(nil, self.uiBinder.node_right)
end

function Weapon_role_mainView:OnDeActive()
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubType = nil
  self.uiBinder.node_tab.AllowSwitchOff = true
  self.uiBinder.btn_equip.isOn = false
  self.uiBinder.btn_skill.isOn = false
  self.uiBinder.btn_mod.isOn = false
  self:unLoadRedDotItem()
  self:UnBindEvents()
  Z.CommonTipsVM.CloseTipsTitleContent()
  playerPortraitHgr_.ClearActiveItem(self.portraitUnit_)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.weaponVm_.SwitchEntityShow(true)
  self:UnRegisterInputActions()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHead)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHeadFrame)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneCard)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneTitle)
  Z.UICameraHelper.SetCameraFocus(false)
end

function Weapon_role_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
end

function Weapon_role_mainView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
end

function Weapon_role_mainView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponSkillTab, self, self.uiBinder.btn_skill.transform)
end

function Weapon_role_mainView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WeaponSkillTab, self)
end

function Weapon_role_mainView:OnRefresh()
  self.uiBinder.node_tab.AllowSwitchOff = false
  if self.viewData and next(self.viewData) then
    self.tog_[self.viewData.selectType].isOn = true
  else
    self.tog_[RightSubType.Equip].isOn = true
  end
  local isModUnlock = self.funcVm_.CheckFuncCanUse(E.FunctionID.Mod, true)
  if isModUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_icon, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_lock, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mod_lock, true)
  end
  local isRed = self.modVm_.IsHaveRedDot()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_mod_reddot, isRed)
end

function Weapon_role_mainView:showAttrs()
  local totalEquopAttr = Z.ContainerMgr.CharSerialize.equip.equipAttr
  self.uiBinder.lab_gs.text = ""
  local vm = Z.VMMgr.GetVM("role_info_attr_detail")
  local attrs = vm.GetRoleMainAttr()
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(attrs) do
      local path = self.uiBinder.uiprefab_cashdata:GetString("weapon_attr_unit")
      local root = self.uiBinder.layout_attribute1
      if index > MAX_UP_ATTR_COUNT then
        root = self.uiBinder.layout_attribute2
      end
      local unit = self:AsyncLoadUiUnit(path, value.AttrId, root)
      unit.lab_number.text = self.fightAttrParseVm_.ParseFightAttrNumber(value.AttrId, Z.EntityMgr.PlayerEnt:GetLuaAttr(value.AttrId).Value, true)
      local fightAttrCfg = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(value.AttrId)
      if fightAttrCfg then
        unit.lab_name.text = fightAttrCfg.OfficialName
        unit.img_icon:SetImage(fightAttrCfg.Icon)
        self:AddAsyncClick(unit.btn, function()
          self:showAttrDetails(value.AttrId)
        end)
      end
    end
  end)()
end

function Weapon_role_mainView:showAttrDetails(Id)
  local fightAttrData = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(Id)
  if fightAttrData then
    local desc = fightAttrData.AttrDes
    if Id == E.FightAttrId.MasteryPct then
      local tableSkillVm = Z.VMMgr.GetVM("talent_skill")
      local professionId = Z.VMMgr.GetVM("profession").GetCurProfession()
      local bdType = tableSkillVm.CheckCurTalentBDType()
      local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
      for _, value in ipairs(professionRow.MasteryDes) do
        if tonumber(value[1]) == bdType then
          desc = value[2]
        end
      end
    end
    if attrTransDict[Id] then
      local roleLv = Z.ContainerMgr.CharSerialize.roleLevel.level
      local fightAttrTranRow = Z.TableMgr.GetTable("FightAttrTranTableMgr").GetRow(1)
      local content = ""
      if fightAttrTranRow then
        local transFactor = fightAttrTranRow[attrTransHeadName[Id]]
        local value = Z.EntityMgr.PlayerEnt:GetLuaAttr(attrTransDict[Id]).Value
        local addAttr = value / (value + transFactor[1] + roleLv * transFactor[2]) * 100
        content = string.zconcat(Lang("BaseAttr"), fightAttrData.OfficialName, Lang(":"), fightAttrData.BaseAttr / 100, "%")
        content = string.zconcat(content, "\n", fightAttrData.OfficialName, Lang(":"), value, "[", addAttr - addAttr % 0.01, "%", "]")
      end
      desc = string.zconcat(desc, "\n", content)
    end
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, fightAttrData.OfficialName, desc)
  end
end

function Weapon_role_mainView:showRoleInfo()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isRenameFuncUnloack = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Rename, true)
  local playerVM = Z.VMMgr.GetVM("player")
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_name_redact, playerVM:IsNamed() and isRenameFuncUnloack)
  if playerVM:IsNamed() then
    self.uiBinder.lab_player_name.text = self.charBase_.name
  else
    self.uiBinder.lab_player_name.text = ""
  end
  local gender = self.charBase_.gender
  self:onChangeTitle()
  self:refreshCardBg()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.EntId, self.cancelSource:CreateToken())
    local viewData = {}
    viewData.id = socialData.avatarInfo.avatarId
    viewData.modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    viewData.charId = Z.EntityMgr.PlayerEnt.EntId
    viewData.headFrameId = nil
    if socialData.avatarInfo and socialData.avatarInfo.avatarFrameId then
      viewData.headFrameId = socialData.avatarInfo.avatarFrameId
    end
    
    function viewData.func()
      local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
      personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
    
    self.portraitUnit_ = playerPortraitHgr_.InsertNewPortrait(self.uiBinder.com_head, viewData)
  end)()
  self.uiBinder.lab_gs.text = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrFightPoint")).Value
  local roleLv = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.uiBinder.lab_grade.text = string.format(Lang("RoleLevelAcquireNodeAttrTip"), roleLv)
  local roleLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLv)
  if roleLevelCfg then
    local maxExp = roleLevelCfg.Exp
    local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
    self.uiBinder.img_progress.fillAmount = curExp / maxExp
    self.uiBinder.lab_experience.text = curExp .. "/" .. maxExp
  end
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonTitleId = seasonData:GetCurRankInfo().curRanKStar
  if seasonTitleId and seasonTitleId ~= 0 then
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
    if seasonRankConfig then
      self.uiBinder.img_armband_icon:SetImage(seasonRankConfig.IconBig)
    end
  end
end

function Weapon_role_mainView:onChangePortrait(avatarId, frameId)
  local viewData = {
    id = avatarId,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.EntId,
    headFrameId = frameId
  }
  playerPortraitHgr_.RefreshNewProtrait(self.uiBinder.com_head, viewData, self.portraitUnit_)
end

function Weapon_role_mainView:onChangeNameResultNtf(errCode)
  if errCode == 0 then
    self.uiBinder.lab_player_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  end
end

function Weapon_role_mainView:onChangeTitle()
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local titleId = personalzoneVM.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  if titleId and titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = string.format("%s", profileImageConfig.Name)
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    self.uiBinder.lab_title.text = Lang("NoneTitle")
  end
end

function Weapon_role_mainView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Weapon_role_mainView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Role)
end

function Weapon_role_mainView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Role)
end

function Weapon_role_mainView:refreshCardBg()
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local cardBgId = personalzoneVM.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  personalzoneVM.IDCardHelperBase(self.uiBinder.uibinder_player, cardBgId)
end

return Weapon_role_mainView
