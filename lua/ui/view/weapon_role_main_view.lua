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
  [E.FightAttrId.MasteryPct] = "MasteryToMasteryPct",
  [E.FightAttrId.BlockPct] = "BlockToBlockRate"
}
local attrTransDict = {
  [E.FightAttrId.Crit] = E.FightAttrId.Cri,
  [E.FightAttrId.HastePct] = E.FightAttrId.Haste,
  [E.FightAttrId.LuckyStrikeProb] = E.FightAttrId.Luck,
  [E.FightAttrId.VersatilityPct] = E.FightAttrId.Versatility,
  [E.FightAttrId.MasteryPct] = E.FightAttrId.Mastery,
  [E.FightAttrId.BlockPct] = E.FightAttrId.Block
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
  local assetPath
  if Z.IsPCUI then
    assetPath = "weapon/weapon_role_main_pc"
  else
    assetPath = "weapon/weapon_role_main"
  end
  super.ctor(self, "weapon_role_main", assetPath)
end

function Weapon_role_mainView:OnActive()
  Z.AudioMgr:Play("UI_Event_CharacterAttributes_Open")
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
  self.rfVM_ = Z.VMMgr.GetVM("recommend_fightvalue")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.charBase_ = Z.ContainerMgr.CharSerialize.charBase
  self:AddAsyncClick(self.uiBinder.btn_details, function()
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
  self:AddClick(self.uiBinder.btn_score, function()
    self.rfVM_.OpenMainView()
  end)
  self:AddAsyncClick(self.uiBinder.uibinder_qqprivilege.btn, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_privilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_newbie, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.img_newbie, Lang("MengXinCjiemianDesTitle"), Lang("MengXinCjiemianDes"))
  end)
  self.uiBinder.btn_equip.isOn = false
  self.uiBinder.btn_equip:AddListener(function(isOn)
    if isOn then
      Z.AudioMgr:Play("UI_Event_CharacterAttributes_Switch")
      self:openRightSubView(RightSubType.Equip)
    end
  end)
  self.uiBinder.btn_skill.isOn = false
  self.uiBinder.btn_skill:AddListener(function(isOn)
    if isOn then
      Z.AudioMgr:Play("UI_Event_CharacterAttributes_Switch")
      self:openRightSubView(RightSubType.Skill)
    end
  end)
  self.uiBinder.btn_mod.isOn = false
  self.uiBinder.btn_mod:AddListener(function(isOn)
    if isOn then
      local isModUnlock = self.funcVm_.CheckFuncCanUse(E.FunctionID.Mod)
      if isModUnlock then
        Z.AudioMgr:Play("UI_Event_CharacterAttributes_Switch")
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
  Z.RedPointMgr.LoadRedDotItem(E.RedType.RoleMainRolelevelPageBtn, self, self.uiBinder.btn_find.transform)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHead, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHeadFrame, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneCard, self, self.uiBinder.uibinder_player.node_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneTitle, self, self.uiBinder.rect_lab)
  self:showAttrs()
  self:showRoleInfo()
  self:privilegeRefresh()
  self:loadRedDotItem()
  self:BindEvents()
  self.subViews_ = {}
  self.curSubView_ = nil
  self.weaponVm_.SwitchEntityShow(false)
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
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHead)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHeadFrame)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneCard)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneTitle)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.RoleMainRolelevelPageBtn)
end

function Weapon_role_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.onRidingChange, self)
  Z.EventMgr:Add(Z.ConstValue.SDK.TencentPrivilegeRefresh, self.privilegeRefresh, self)
end

function Weapon_role_mainView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.UpdateRiding, self.onRidingChange, self)
  Z.EventMgr:Remove(Z.ConstValue.SDK.TencentPrivilegeRefresh, self.privilegeRefresh, self)
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
  local recommendAttrs, recommendDescAttrs = self.fightAttrParseVm_.GetRecommendFightAttrId()
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
        unit.Ref:SetVisible(unit.img_recommend, table.zcontains(recommendAttrs, value.AttrId))
        unit.btn_praise.interactable = table.zcontains(recommendAttrs, value.AttrId)
        self:AddAsyncClick(unit.btn, function()
          self:showAttrDetails(value.AttrId)
        end)
        self:AddAsyncClick(unit.btn_praise, function()
          self.fightAttrParseVm_.ShowRecommendAttrsTips(self.uiBinder.node_tips_pos, recommendDescAttrs)
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
      local professionId = Z.VMMgr.GetVM("profession").GetContainerProfession()
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
        content = string.zconcat(Lang("BaseAttr"), fightAttrData.OfficialName, Lang("colon"), fightAttrData.BaseAttr / 100, "%")
        content = string.zconcat(content, "\n", fightAttrData.OfficialName, Lang("colon"), value, "[", addAttr - addAttr % 0.01, "%", "]")
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
    self.uiBinder.lab_player_name.text = Lang("EmptyRoleName")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value))
  local gender = self.charBase_.gender
  self:onChangeTitle()
  self:refreshCardBg()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.CharId, self.cancelSource:CreateToken())
    local viewData = {}
    viewData.id = socialData.avatarInfo.avatarId
    viewData.modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    viewData.charId = Z.EntityMgr.PlayerEnt.CharId
    viewData.headFrameId = nil
    viewData.token = self.cancelSource:CreateToken()
    if socialData.avatarInfo and socialData.avatarInfo.avatarFrameId then
      viewData.headFrameId = socialData.avatarInfo.avatarFrameId
    end
    
    function viewData.func()
      local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
      personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
    
    self.portraitUnit_ = playerPortraitHgr_.InsertNewPortrait(self.uiBinder.com_head, viewData)
  end)()
  self.uiBinder.lab_gs.text = self.rfVM_.GetTotalPoint()
  local roleLv = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.uiBinder.lab_grade.text = string.format(Lang("RoleLevelAcquireNodeAttrTip"), roleLv)
  local roleLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLv)
  if roleLevelCfg then
    local maxExp = roleLevelCfg.Exp
    local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
    self.uiBinder.img_progress.fillAmount = curExp / maxExp
    self.uiBinder.lab_experience.text = curExp .. "/" .. maxExp
  end
  local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
  if roleLevelInfo.level == self.rolelevelData_.MaxPlayerLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_double, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icondouble, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_experience, false)
    self.uiBinder.img_progress.fillAmount = 1
    self.uiBinder.img_green.fillAmount = 1
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, false)
    if self.rolelevelVm_.IsBlessExpFuncOn() then
      if roleLevelInfo.level < roleLevelInfo.prevSeasonMaxLv then
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_double, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_icondouble, true)
        self.uiBinder.img_green.fillAmount = 1
      else
        local doubleExp = roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp
        if 0 < doubleExp then
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_double, true)
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_icondouble, true)
        else
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_double, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_icondouble, false)
        end
        self.uiBinder.img_green.fillAmount = (roleLevelInfo.curLevelExp + doubleExp) / roleLevelCfg.Exp
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_double, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icondouble, false)
      self.uiBinder.img_green.fillAmount = 0
    end
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
    charId = Z.EntityMgr.PlayerEnt.CharId,
    headFrameId = frameId,
    token = self.cancelSource:CreateToken()
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

function Weapon_role_mainView:refreshCardBg()
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local cardBgId = personalzoneVM.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  personalzoneVM.IDCardHelperBase(self.uiBinder.uibinder_player, cardBgId)
end

function Weapon_role_mainView:onRidingChange()
  self.weaponVm_.CloseWeaponRoleView()
end

function Weapon_role_mainView:privilegeRefresh(isPrivilege)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, false)
  self.uiBinder.uibinder_qqprivilege.Ref.UIComp:SetVisible(false)
  if isPrivilege == nil then
    isPrivilege = self.sdkVM_.IsShowPrivilege()
  end
  if self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
    self.uiBinder.uibinder_qqprivilege.Ref.UIComp:SetVisible(true)
    self.uiBinder.uibinder_qqprivilege.Ref:SetVisible(self.uiBinder.uibinder_qqprivilege.img_mask, not isPrivilege)
  elseif self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege, isPrivilege)
  end
end

return Weapon_role_mainView
