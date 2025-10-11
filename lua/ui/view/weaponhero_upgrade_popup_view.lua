local UI = Z.UI
local super = require("ui.ui_view_base")
local Weaponhero_upgrade_popupView = class("Weaponhero_upgrade_popupView", super)
local MaxUnitCount = 4

function Weaponhero_upgrade_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weaponhero_upgrade_popup")
  self.vm_ = Z.VMMgr.GetVM("weapon")
  self.fightAttrParseVm_ = Z.VMMgr.GetVM("fight_attr_parse")
  self.skillVm_ = Z.VMMgr.GetVM("skill")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
end

function Weaponhero_upgrade_popupView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.point_check:StopCheck()
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self:onStartAnimShow()
  self:EventAddAsyncListener(self.uiBinder.point_check.ContainGoEvent, function(isContain)
    if not isContain then
      self.vm_.CloseUpGradeView()
    end
  end, nil, nil)
  self.uiBinder.point_check:StartCheck()
  self.uiBinder.node_audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_1)
  if self.viewData.viewType == E.UpgradeType.WeaponHeroLevel or self.viewData.viewType == E.UpgradeType.WeaponHeroOverstep then
    Z.CoroUtil.create_coro_xpcall(function()
      self:RefreshWeaponHeroInfo()
    end)()
  elseif self.viewData.viewType == E.UpgradeType.WeaponHeroSkillLevel then
    Z.CoroUtil.create_coro_xpcall(function()
      self:RefreshSkillInfo()
    end)()
  elseif self.viewData.viewType == E.UpgradeType.SkillRemodel then
    Z.CoroUtil.create_coro_xpcall(function()
      self:RefreshSkillRemodelInfo()
    end)()
  elseif self.viewData.viewType == E.UpgradeType.WeaponSkillUnlock then
    Z.CoroUtil.create_coro_xpcall(function()
      self:RefreshSkillUnlock()
    end)()
  end
end

function Weaponhero_upgrade_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.point_check:StopCheck()
  Z.CommonTipsVM.CloseRichText()
end

function Weaponhero_upgrade_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.anim:PlayOnce("anim_weaponhero_upgrade_popup_an")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Weaponhero_upgrade_popupView:OnRefresh()
end

function Weaponhero_upgrade_popupView:RefreshWeaponHeroInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_num, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content_unlock, false)
  self.uiBinder.lab_title_grade_former.text = Lang("Level", {
    val = self.viewData.preLevel
  })
  local nowLevel = self.vm_.GetWeaponInfo(self.viewData.professionId).level
  self.uiBinder.lab_title_grade_after.text = Lang("Level", {val = nowLevel})
  self.uiBinder.lab_skill.text = ""
  local nowAttrCfgData = {}
  local preAttrCfgData = {}
  if self.viewData.viewType == E.UpgradeType.WeaponHeroLevel then
    self.uiBinder.lab_title.text = Lang("level_upgrade_success")
  elseif self.viewData.viewType == E.UpgradeType.WeaponHeroOverstep then
    self.uiBinder.lab_title.text = Lang("BreachSucceed")
  end
  nowAttrCfgData = self.vm_.GetAttrPreview(self.viewData.professionId, nowLevel, true)
  preAttrCfgData = self.vm_.GetAttrPreview(self.viewData.professionId, self.viewData.preLevel)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_skill_base, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_weapon_base, true)
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.viewData.professionId)
  if professionRow then
    self.uiBinder.img_weapon:SetImage(professionRow.Icon)
  end
  local parent = self.uiBinder.node_content
  local path = self.uiBinder.prefab_cache:GetString("upgrade_unit")
  self:contentSizeFitter(#nowAttrCfgData)
  for _, value in ipairs(nowAttrCfgData) do
    if preAttrCfgData[value.attrId] == nil then
      preAttrCfgData[value.attrId] = 0
    end
    local unit = self:AsyncLoadUiUnit(path, value.attrId, parent)
    if not unit then
      return
    end
    local fightAttrData = self.fightAttrParseVm_.GetFightAttrTableRow(value.attrId)
    if fightAttrData then
      unit.lab_across.text = fightAttrData.OfficialName
      unit.lab_digit_1.text = self.fightAttrParseVm_.ParseFightAttrNumber(value.attrId, preAttrCfgData[value.attrId], true)
      unit.lab_digit_2.text = self.fightAttrParseVm_.ParseFightAttrNumber(value.attrId, value.number, true)
      unit.Ref:SetVisible(unit.img_arrow, true)
    end
  end
  self.uiBinder.node_content_rebuild:ForceRebuildLayoutImmediate()
  self.uiBinder.node_content:SetAnchorPosition(0, 0)
end

function Weaponhero_upgrade_popupView:RefreshSkillInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_num, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content_unlock, false)
  self.uiBinder.lab_title_grade_former.text = Lang("Level", {
    val = self.viewData.preLevel
  })
  self.uiBinder.lab_title_grade_after.text = Lang("Level", {
    val = self.viewData.level
  })
  self.uiBinder.lab_title.text = Lang("level_upgrade_success")
  local skillTabData = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.viewData.skillId)
  if skillTabData == nil then
    return
  end
  self.uiBinder.lab_skill.text = ""
  local skillFightData = self.weaponSkillVm_:GetSkillFightDataById(self.viewData.skillId)
  local nowSkillFightLvTblData = skillFightData[self.viewData.level]
  local preSkillFightLvTblData = skillFightData[self.viewData.preLevel]
  if nowSkillFightLvTblData == nil or preSkillFightLvTblData == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_skill_base, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_weapon_base, false)
  self.uiBinder.img_skill:SetImage(skillTabData.Icon)
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local remodelLevel = weaponSkillVm:GetSkillRemodelLevel(self.viewData.skillId)
  local nowSkillDecsList = self.skillVm_.GetSkillDecs(nowSkillFightLvTblData.Id, remodelLevel) or {}
  local preSkillDescList = self.skillVm_.GetSkillDecs(preSkillFightLvTblData.Id, remodelLevel) or {}
  preSkillDescList = self.skillVm_.GetSkillDecsWithColor(preSkillDescList)
  nowSkillDecsList = self.skillVm_.ContrastSkillDecs(preSkillDescList, nowSkillDecsList)
  local parent = self.uiBinder.node_content
  local path = self.uiBinder.prefab_cache:GetString("skill_upgrade_unit")
  self:contentSizeFitter(#nowSkillDecsList)
  for _, value in ipairs(nowSkillDecsList) do
    local unit = self:AsyncLoadUiUnit(path, value.Dec, parent)
    if not unit then
      return
    end
    unit.lab_across.text = value.Dec .. Lang("colon") .. value.Num
  end
  self.uiBinder.node_content_rebuild:ForceRebuildLayoutImmediate()
  self.uiBinder.node_content:SetAnchorPosition(0, 0)
end

function Weaponhero_upgrade_popupView:RefreshSkillRemodelInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_num, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content_unlock, false)
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local remodelLevel = weaponSkillVm:GetSkillRemodelLevel(self.viewData.skillId)
  self.uiBinder.lab_title_grade_former.text = Lang("AdvanceLevel2") .. " " .. remodelLevel - 1
  self.uiBinder.lab_title_grade_after.text = Lang("AdvanceLevel2") .. " " .. remodelLevel
  self.uiBinder.lab_title.text = Lang("AdvanceSuccess")
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.viewData.skillId)
  if skillRow == nil then
    return
  end
  self.uiBinder.lab_skill.text = ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_skill_base, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_weapon_base, false)
  self.uiBinder.img_skill:SetImage(skillRow.Icon)
  local desc, descList = weaponSkillVm:ParseRemodelDesc(self.viewData.skillId, remodelLevel, false)
  local parent = self.uiBinder.node_content
  local path = self.uiBinder.prefab_cache:GetString("skill_upgrade_unit")
  self:contentSizeFitter(#descList)
  for index, value in ipairs(descList) do
    local unit = self:AsyncLoadUiUnit(path, "remodel_skill_" .. index, parent)
    if not unit then
      return
    end
    unit.lab_across.text = value
  end
  self.uiBinder.node_content_rebuild:ForceRebuildLayoutImmediate()
  self.uiBinder.node_content:SetAnchorPosition(0, 0)
end

function Weaponhero_upgrade_popupView:RefreshSkillUnlock()
  self.uiBinder.lab_title.text = Lang("UnlockSuccess")
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_num, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_content_unlock, true)
  local skillId = self.viewData.skillId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_skill_base, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_weapon_base, false)
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  local content = ""
  if config ~= nil then
    self.uiBinder.lab_skill.text = config.Name
    content = Z.TableMgr.DecodeLineBreak(config.Desc)
    self.uiBinder.img_skill:SetImage(config.Icon)
  end
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local skillFightData = weaponSkillVm:GetSkillFightDataById(skillId)
  content = content .. "\n"
  local skillAttrDescList = self.skillVm_.GetSkillDecs(skillFightData[1].Id, 0)
  skillAttrDescList = self.skillVm_.GetSkillDecsWithColor(skillAttrDescList)
  for _, value in ipairs(skillAttrDescList) do
    content = content .. "\n" .. value.Dec .. Lang("colon") .. Z.RichTextHelper.ApplyStyleTag(value.Num, E.TextStyleTag.SkillNum)
  end
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_unlock_content, content)
  self.uiBinder.skill_unlock_node_content:SetAnchorPosition(0, 0)
end

function Weaponhero_upgrade_popupView:contentSizeFitter(count)
  if count < MaxUnitCount then
    self.uiBinder.node_content:SetHeight(276)
    self.uiBinder.node_content_layout.childControlHeight = false
    self.uiBinder.node_content_size_fitter.verticalFit = Panda.ZUi.ZContentSizeFitter.ZFitMode.Unconstrained
    self.uiBinder.node_content_layout.childAlignment = UnityEngine.TextAnchor.MiddleCenter
    self.uiBinder.node_content_layout.childForceExpandHeight = false
  else
    self.uiBinder.node_content_layout.childControlHeight = true
    self.uiBinder.node_content_size_fitter.verticalFit = Panda.ZUi.ZContentSizeFitter.ZFitMode.PreferredSize
    self.uiBinder.node_content_layout.childAlignment = UnityEngine.TextAnchor.UpperCenter
    self.uiBinder.node_content_layout.childForceExpandHeight = true
  end
end

return Weaponhero_upgrade_popupView
