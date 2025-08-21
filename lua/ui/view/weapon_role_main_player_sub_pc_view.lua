local UI = Z.UI
local super = require("ui.ui_subview_base")
local Weapon_role_main_player_sub_pcView = class("Weapon_role_main_player_sub_pcView", super)
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
local DEFINE = require("ui.model.personalzone_define")

function Weapon_role_main_player_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_player_sub_pc", "weapon/weapon_role_main_player_sub_pc", UI.ECacheLv.None)
end

function Weapon_role_main_player_sub_pcView:OnActive()
  self:onStartAnimShow()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.rfVM_ = Z.VMMgr.GetVM("recommend_fightvalue")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
  self:AddAsyncClick(self.uiBinder.btn_details, function()
    local roleInfoVm = Z.VMMgr.GetVM("role_info_attr_detail")
    roleInfoVm.OpenRoleAttrDetailView()
    Z.GuideMgr:CloseView()
  end)
  self:AddClick(self.uiBinder.btn_score, function()
    self.rfVM_.OpenMainView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_level, function()
    local rolelevelVm = Z.VMMgr.GetVM("rolelevel_main")
    rolelevelVm.OpenRolelevelAwardPanel()
  end)
  self:AddAsyncClick(self.uiBinder.btn_talent, function()
    local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
    talentSkillVM.OpenTalentSkillMainWindow()
  end)
  self:AddClick(self.uiBinder.btn_profession, function()
    local professionVm = Z.VMMgr.GetVM("profession")
    professionVm.OpenProfessionSelectView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_name_redact, function()
    local playerVM = Z.VMMgr.GetVM("player")
    playerVM:OpenRenameWindow()
  end)
  self:AddClick(self.uiBinder.btn_levelup, function()
    local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
    local doubleExp = roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp
    if self.rolelevelVm_.IsBlessExpFuncOn() and roleLevelInfo.level < self.rolelevelData_.MaxPlayerLevel and (0 < doubleExp or roleLevelInfo.level < roleLevelInfo.prevSeasonMaxLv) then
      local curLevelExp = ""
      local levelCgf = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLevelInfo.level)
      if levelCgf then
        curLevelExp = roleLevelInfo.curLevelExp .. "/" .. levelCgf.Exp
      end
      local doubleExp = roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp
      Z.CommonTipsVM.OpenExp(self.uiBinder.node_exp, Lang("TipsExp", {val = curLevelExp}), Lang("TipsDoubleExp", {val = doubleExp}))
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_personalzonebg, function()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneCard)
  end)
  self:AddAsyncClick(self.uiBinder.btn_title, function()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneTitle)
  end)
  self:AddClick(self.uiBinder.btn_newbie, function()
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.img_newbie, Lang("MengXinCjiemianDesTitle"), Lang("MengXinCjiemianDes"))
  end)
  self:BindEvents()
  self:refreshWeapon()
  self:refreshTalent()
  self:showRoleInfo()
  self:showAttrs()
  self:loadRedDotItem()
end

function Weapon_role_main_player_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
end

function Weapon_role_main_player_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
end

function Weapon_role_main_player_sub_pcView:refreshWeapon()
  local professionVm = Z.VMMgr.GetVM("profession")
  local professionId = professionVm:GetContainerProfession()
  if professionId then
    local ProfessionSystemRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if ProfessionSystemRow then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_profession_icon, true)
      self.uiBinder.img_profession_icon:SetImage(ProfessionSystemRow.Icon)
      self.uiBinder.lab_profession_name.text = ProfessionSystemRow.Name
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_profession_icon, false)
    self.uiBinder.lab_profession_name.text = ""
  end
end

function Weapon_role_main_player_sub_pcView:refreshTalent()
  local switchVm = Z.VMMgr.GetVM("switch")
  local isUnlock = switchVm.CheckFuncSwitch(E.FunctionID.Talent)
  local talentVm = Z.VMMgr.GetVM("talent_skill")
  local talentStageName = talentVm.GetCurProfessionTalentStageName()
  if not isUnlock or talentStageName == "" then
    self.uiBinder.lab_talent_name.text = Lang("noYet")
  else
    self.uiBinder.lab_talent_name.text = talentStageName
  end
  local tagIcon = talentVm.GetWeaponnTalentTagIcon()
  if isUnlock and tagIcon then
    self.uiBinder.img_talent_icon:SetImage(tagIcon)
  else
    self.uiBinder.img_talent_icon:SetImage("ui/atlas/new_com/weap_role_talent_empty")
  end
end

function Weapon_role_main_player_sub_pcView:OnDeActive()
  Z.CommonTipsVM.CloseTipsTitleContent()
  self:UnBindEvents()
  self:unLoadRedDotItem()
end

function Weapon_role_main_player_sub_pcView:showAttrs()
  local vm = Z.VMMgr.GetVM("role_info_attr_detail")
  local attrs = vm.GetRoleMainAttr()
  local recommendAttrs, recommendDescAttrs = self.fightAttrParseVm_.GetRecommendFightAttrId()
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(attrs) do
      local path = self.uiBinder.uiprefab_cashdata:GetString("weapon_attr_unit")
      local root = self.uiBinder.attr_node_content1
      if index > MAX_UP_ATTR_COUNT then
        root = self.uiBinder.attr_node_content2
      end
      local unit = self:AsyncLoadUiUnit(path, value.AttrId, root)
      unit.lab_number.text = self.fightAttrParseVm_.ParseFightAttrNumber(value.AttrId, Z.EntityMgr.PlayerEnt:GetLuaAttr(value.AttrId).Value, true)
      unit.Ref:SetVisible(unit.img_bg, index % 2 ~= 0)
      local fightAttrCfg = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(value.AttrId)
      if fightAttrCfg then
        unit.lab_name.text = fightAttrCfg.OfficialName
        unit.img_icon:SetImage(fightAttrCfg.Icon)
        unit.Ref:SetVisible(unit.btn_praise, table.zcontains(recommendAttrs, value.AttrId))
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

function Weapon_role_main_player_sub_pcView:showAttrDetails(Id)
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
        content = string.zconcat(Lang("BaseAttr"), fightAttrData.OfficialName, Lang(":"), fightAttrData.BaseAttr / 100, "%")
        content = string.zconcat(content, "\n", fightAttrData.OfficialName, Lang(":"), value, "[", addAttr - addAttr % 0.01, "%", "]")
      end
      desc = string.zconcat(desc, "\n", content)
    end
    Z.CommonTipsVM.ShowTipsTitleContent(self.uiBinder.node_tips_pos, fightAttrData.OfficialName, desc)
  end
end

function Weapon_role_main_player_sub_pcView:showRoleInfo()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isRenameFuncUnloack = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Rename, true)
  local playerVM = Z.VMMgr.GetVM("player")
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_name_redact, playerVM:IsNamed() and isRenameFuncUnloack)
  if playerVM:IsNamed() then
    self.uiBinder.lab_player_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  else
    self.uiBinder.lab_player_name.text = Lang("EmptyRoleName")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value))
  self:onChangeTitle()
  self:refreshCardBg()
  local viewData = {
    id = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.EntId,
    token = self.cancelSource:CreateToken()
  }
  if Z.ContainerMgr.CharSerialize.charBase.avatarInfo and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarFrameId then
    viewData.headFrameId = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarFrameId
  end
  
  function viewData.func()
    local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
    personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
  end
  
  self.portraitUnit_ = playerPortraitHgr_.InsertNewPortrait(self.uiBinder.com_head, viewData)
  self.uiBinder.lab_gs.text = self.rfVM_.GetTotalPoint()
  local roleLevelInfo = Z.ContainerMgr.CharSerialize.roleLevel
  self.uiBinder.lab_level.text = roleLevelInfo.level
  if roleLevelInfo.level == self.rolelevelData_.MaxPlayerLevel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
    self.uiBinder.img_blue.fillAmount = 1
    self.uiBinder.img_green.fillAmount = 1
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_highest, false)
    local levelCgf = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(roleLevelInfo.level)
    if levelCgf then
      self.uiBinder.img_blue.fillAmount = roleLevelInfo.curLevelExp / levelCgf.Exp
    end
    if self.rolelevelVm_.IsBlessExpFuncOn() then
      if roleLevelInfo.level < roleLevelInfo.prevSeasonMaxLv then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, true)
        self.uiBinder.img_green.fillAmount = 1
      else
        local doubleExp = roleLevelInfo.blessExpPool - roleLevelInfo.grantBlessExp
        if 0 < doubleExp then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, true)
        else
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
        end
        self.uiBinder.img_green.fillAmount = (roleLevelInfo.curLevelExp + doubleExp) / levelCgf.Exp
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_experience, false)
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

function Weapon_role_main_player_sub_pcView:onChangePortrait(avatarId, frameId)
  local viewData = {
    id = avatarId,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.EntId,
    headFrameId = frameId,
    token = self.cancelSource:CreateToken()
  }
  playerPortraitHgr_.RefreshNewProtrait(self.uiBinder.com_head, viewData, self.portraitUnit_)
end

function Weapon_role_main_player_sub_pcView:onChangeNameResultNtf(errCode)
  if errCode == 0 then
    self.uiBinder.lab_player_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  end
end

function Weapon_role_main_player_sub_pcView:onChangeTitle()
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local titleId = personalzoneVM.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  if titleId and titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = profileImageConfig.Name
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    self.uiBinder.lab_title.text = Lang("NoneTitle")
  end
end

function Weapon_role_main_player_sub_pcView:refreshCardBg()
  local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
  local cardBgId = personalzoneVM.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  personalzoneVM.IDCardHelperBasePC(self.uiBinder.uibinder_player, cardBgId)
end

function Weapon_role_main_player_sub_pcView:OnRefresh()
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  if talentSkillVM.CheckTalentTreeRed() or talentSkillVM.CheckRed() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.talent_reddot, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.talent_reddot, false)
  end
end

function Weapon_role_main_player_sub_pcView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.RoleMainRolelevelPageBtn, self, self.uiBinder.btn_level.transform)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHead, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHeadFrame, self, self.uiBinder.com_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneCard, self, self.uiBinder.node_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneTitle, self, self.uiBinder.rect_titlered)
end

function Weapon_role_main_player_sub_pcView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.RoleMainRolelevelPageBtn, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHead, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHeadFrame, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneCard, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneTitle, self)
end

function Weapon_role_main_player_sub_pcView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Weapon_role_main_player_sub_pcView
