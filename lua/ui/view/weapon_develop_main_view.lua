local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_develop_mainView = class("Weapon_develop_mainView", super)
local weaponLevelUpView = require("ui.view.weapon_develop_attribute_sub_view")
local weaponSkillView = require("ui.view.weapon_develop_remodel_sub_view")
local weaponSkinView = require("ui.view.weapon_skin_sub_view")
local weaponSkillRemodelView = require("ui.view.weapon_develop_function_sub_view")
local weaponSkillLevelView = require("ui.view.weapon_develop_skill_sub_view")
local MAXDISTANCE = 0.6
local UIDISTANCE = 200
local weaponRed = require("rednode.weapon_red")
local SubView_Name_Enum = {
  LevelUp = "LevelUpView",
  Skill = "WeaponHeroSkillView",
  Skin = "WeaponSkinView"
}
local weaponPosType = {left = 1, right = 2}

function Weapon_develop_mainView:ctor()
  self.panel = nil
  super.ctor(self, "weapon_develop_main")
end

function Weapon_develop_mainView:OnActive()
  self:startAnimatedShow()
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self:AddAsyncClick(self.panel.cont_title_return.cont_btn_return.btn.Btn, function()
    self.weaponVm_.CloseWeaponDevelopView()
  end)
  self:AddAsyncClick(self.panel.cont_title_return.btn_ask.Btn, function()
    local helpsysVM_ = Z.VMMgr.GetVM("helpsys")
    helpsysVM_.OpenFullScreenTipsView(10012)
  end)
  self.curShowModel_ = {}
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.weaponLevelUpView_ = weaponLevelUpView.new()
  self.weaponSkillView_ = weaponSkillView.new()
  self.weaponSkinView_ = weaponSkinView.new()
  self.weaponSkillLevelUp_ = weaponSkillLevelView.new()
  self.weaponSkillRemodel_ = weaponSkillRemodelView.new()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.weaponId_ = self.viewData.weaponId
  Z.UnrealSceneMgr:SwicthVirtualStyle(E.UnrealSceneStyle.Green)
  self:initSubView()
  self:BindEvents()
end

function Weapon_develop_mainView:BindEvents()
  function self.onWeaoponSkinChange(skinId)
    self:refreshWeaponModel(skinId)
  end
  
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkinChange, self.onWeaoponSkinChange)
end

function Weapon_develop_mainView:GetCacheData()
  local viewData = {}
  viewData.weaponId = self.weaponId_
  return viewData
end

function Weapon_develop_mainView:initSubView()
  self.subViewInfo_ = {
    [SubView_Name_Enum.LevelUp] = {
      tabCont = self.panel.cont_tab_02.btn_attr,
      tabItem = self.panel.cont_tab_02.btn_attr.tog_tab_select,
      labOn = self.panel.cont_tab_02.btn_attr.layout_lab_on,
      labOff = self.panel.cont_tab_02.btn_attr.layout_lab_off,
      redDot = self.panel.cont_tab_02.btn_attr.c_com_reddot,
      functionId = E.FunctionID.WeaponStrengthen,
      effRoot = self.panel.cont_tab_02.btn_attr.eff_select,
      view = self.weaponLevelUpView_
    },
    [SubView_Name_Enum.Skill] = {
      tabCont = self.panel.cont_tab_02.btn_remodel,
      tabItem = self.panel.cont_tab_02.btn_remodel.tog_tab_select,
      labOn = self.panel.cont_tab_02.btn_remodel.layout_lab_on,
      labOff = self.panel.cont_tab_02.btn_remodel.layout_lab_off,
      redDot = self.panel.cont_tab_02.btn_remodel.c_com_reddot,
      functionId = E.FunctionID.WeaponReform,
      effRoot = self.panel.cont_tab_02.btn_remodel.eff_select,
      view = self.weaponSkillView_
    },
    [SubView_Name_Enum.Skin] = {
      tabCont = self.panel.cont_tab_02.btn_skin,
      tabItem = self.panel.cont_tab_02.btn_skin.tog_tab_select,
      labOn = self.panel.cont_tab_02.btn_skin.layout_lab_on,
      labOff = self.panel.cont_tab_02.btn_skin.layout_lab_off,
      redDot = self.panel.cont_tab_02.btn_skin.c_com_reddot,
      functionId = E.FunctionID.WeaponSkin,
      effRoot = self.panel.cont_tab_02.btn_skin.eff_select,
      view = self.weaponSkinView_
    }
  }
  self.skillSubViewInfo_ = {
    [E.SkillViewSubViewType.skillLevel] = {
      view = self.weaponSkillLevelUp_
    },
    [E.SkillViewSubViewType.skillRemodel] = {
      view = self.weaponSkillRemodel_
    }
  }
  for subViewType, value in pairs(self.subViewInfo_) do
    value.labOn:SetVisible(false)
    value.labOff:SetVisible(true)
    value.tabItem.Tog.group = self.panel.cont_tab_02.layout_tab.TogGroup
    value.tabItem.Tog:AddListener(function(isOn)
      value.labOn:SetVisible(isOn)
      value.labOff:SetVisible(not isOn)
      if isOn then
        self:onChangeSubViewType(subViewType)
      end
    end)
  end
  self.subViewInfo_[SubView_Name_Enum.Skin].tabItem.Tog.isOn = true
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  self.subViewInfo_[SubView_Name_Enum.Skin].tabCont:SetVisible(funcVM.CheckFuncCanUse(E.FunctionID.WeaponSkin, true))
end

function Weapon_develop_mainView:onChangeSubViewType(subViewType)
  if subViewType == nil then
    return
  end
  local parent = self.panel.subContent.Trans
  local selectViewInfo = self.subViewInfo_[subViewType]
  if selectViewInfo == nil then
    return
  end
  if self.curSubView_ and self.curSubView_ ~= selectViewInfo.view then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.commonVm_.SetLabText(self.panel.cont_title_return.lab_title.TMPLab, {
    E.FunctionID.Weapon,
    selectViewInfo.functionId
  })
  if self.curSubViewType_ ~= subViewType then
    self:onChangeWeaponPos(subViewType)
    if subViewType == SubView_Name_Enum.LevelUp or subViewType == SubView_Name_Enum.Skin then
      if self.effect_bg_ then
        Z.UnrealSceneMgr:ClearEffect(self.effect_bg_)
        self.effect_bg_ = nil
      end
    elseif subViewType == SubView_Name_Enum.Skill then
      self.effect_bg_ = Z.UnrealSceneMgr:CreatEffect("virtualscene/p_fx_xuniui_weapon_01", "weapon_develop_effect_bg_1")
    end
  end
  self.curSubViewType_ = subViewType
  self.curSubView_ = selectViewInfo.view
  self.curSubView_:Active({
    weaponId = self.weaponId_,
    parentView = self
  }, parent)
  local skinId = self.weaponVm_.GetWeaponSkinId(self.weaponId_)
  self:refreshWeaponModel(skinId)
end

function Weapon_develop_mainView:onChangeWeaponPos(subViewType)
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.weaponId_)
  if weaponConfig == nil then
    return
  end
  if self.animTimer_ then
    self.timerMgr:StopTimer(self.animTimer_)
    self.animTimer_ = nil
  end
  local count = 7
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local timelineTotalDis = MAXDISTANCE
  if subViewType == SubView_Name_Enum.Skill and self.weaponPosType_ == weaponPosType.left then
    local nowTimelineDis = MAXDISTANCE
    self.animTimer_ = self.timerMgr:StartTimer(function()
      nowTimelineDis = nowTimelineDis - timelineTotalDis / count
      local targetPos = pos - Vector3.New(nowTimelineDis, 0, 0)
      Z.UITimelineDisplay:SetTimelinePos(weaponConfig.TimelineId, targetPos)
    end, 0.01, count)
    self.weaponPosType_ = weaponPosType.right
  elseif (subViewType == SubView_Name_Enum.LevelUp or SubView_Name_Enum.Skin) and self.weaponPosType_ == weaponPosType.right then
    local nowTimelineDis = 0
    self.animTimer_ = self.timerMgr:StartTimer(function()
      nowTimelineDis = nowTimelineDis + timelineTotalDis / count
      local targetPos = pos - Vector3.New(nowTimelineDis, 0, 0)
      Z.UITimelineDisplay:SetTimelinePos(weaponConfig.TimelineId, targetPos)
    end, 0.01, count)
    self.weaponPosType_ = weaponPosType.left
  end
end

function Weapon_develop_mainView:refreshWeaponModel(skinId)
  if skinId and skinId == self.showSkinId_ then
    return
  end
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.weaponId_)
  if weaponConfig == nil then
    return
  end
  local skinConfig = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(skinId)
  if skinConfig == nil then
    return
  end
  Z.UITimelineDisplay:ClearTimeLine()
  for _, value in ipairs(self.curShowModel_) do
    Z.UnrealSceneMgr:ClearModel(value)
  end
  if skinId == nil then
    skinId = self.weaponVm_.GetWeaponSkinId(self.weaponId_)
  end
  local WeaponModelId = skinConfig.WeaponModelId
  for index, value in ipairs(WeaponModelId) do
    local model = Z.UnrealSceneMgr:GenModelByLua(self.curShowModel_[index], value)
    self.curShowModel_[index] = model
  end
  self.showSkinId_ = skinId
  Z.UITimelineDisplay:AsyncPreLoadTimeline(weaponConfig.TimelineId, self.cancelSource:CreateToken(), function()
    for index, model in ipairs(self.curShowModel_) do
      model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
      Z.UITimelineDisplay:BindModel(index - 1, model)
    end
    Z.UITimelineDisplay:Play(weaponConfig.TimelineId)
    Z.UITimelineDisplay:SetGoPosByCutsceneId(weaponConfig.TimelineId, Z.UnrealSceneMgr:GetTransPos("pos") - Vector3.New(MAXDISTANCE, 0, 0))
    self.weaponPosType_ = weaponPosType.left
  end)
end

function Weapon_develop_mainView:CreatSkillSubView(viewType, root, viewData)
  if self.skillSubViewInfo_[viewType] then
    self.skillSubViewInfo_[viewType].view:Active(viewData, root)
    if self.effect_bg_ == nil then
      self.effect_bg_ = Z.UnrealSceneMgr:CreatEffect("virtualscene/p_fx_xuniui_weapon_01", "weapon_develop_effect_bg_1")
    end
    Z.UnrealSceneMgr:SetEffectInfo(self.effect_bg_, "weapon_develop_effect_bg_2")
  end
end

function Weapon_develop_mainView:RemoveSkillSubView(viewType)
  if self.skillSubViewInfo_[viewType] then
    self.skillSubViewInfo_[viewType].view:DeActive()
    if self.effect_bg_ then
      Z.UnrealSceneMgr:SetEffectInfo(self.effect_bg_, "weapon_develop_effect_bg_1")
    end
  end
end

function Weapon_develop_mainView:SetWeaponPos(nodeTrans)
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.weaponId_)
  if weaponConfig == nil then
    return
  end
  if self.animTimer_ then
    self.timerMgr:StopTimer(self.animTimer_)
    self.animTimer_ = nil
  end
  local uiDis = UIDISTANCE
  local timelineDis = MAXDISTANCE
  self.animTimer_ = self.timerMgr:StartTimer(function()
    if uiDis - math.abs(nodeTrans.localPosition.x) > 1 then
      local x = math.abs(nodeTrans.localPosition.x) / uiDis * timelineDis
      Z.UITimelineDisplay:SetTimelinePos(weaponConfig.TimelineId, Z.UnrealSceneMgr:GetTransPos("pos") - Vector3.New(x, 0, 0))
    end
  end, 0.01, 45)
  self.weaponPosType_ = weaponPosType.left
end

function Weapon_develop_mainView:OnDeActive()
  Z.UITimelineDisplay:ClearTimeLine()
  self:startAnimatedHide()
  self.subViewInfo_[self.curSubViewType_].effRoot.ZEff:SetEffectGoVisible(false)
  self.curSubViewType_ = nil
  for _, value in pairs(self.subViewInfo_) do
    value.view:DeActive()
  end
  self.curSubView_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for _, value in ipairs(self.curShowModel_) do
    Z.UnrealSceneMgr:ClearModel(value)
  end
  self.curShowModel_ = {}
  if self.effect_bg_ then
    Z.UnrealSceneMgr:ClearEffect(self.effect_bg_)
    self.effect_bg_ = nil
  end
  if self.animTimer_ then
    self.timerMgr:StopTimer(self.animTimer_)
    self.animTimer_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Weapon.OnWeaponSkinChange, self.onWeaoponSkinChange)
  self.onWeaoponSkinChange = nil
  self.weaponList_ = nil
  Z.UnrealSceneMgr:CloseUnrealScene("weapon_develop_main")
  self.weaponPosType_ = nil
end

function Weapon_develop_mainView:OnRefresh()
end

function Weapon_develop_mainView:CustomClose()
end

function Weapon_develop_mainView:startAnimatedShow()
  self.panel.content.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function Weapon_develop_mainView:startAnimatedHide()
  self.panel.content.TweenContainer:Restart(Z.DOTweenAnimType.Close)
end

return Weapon_develop_mainView
