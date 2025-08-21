local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_resonance_obtain_popupView = class("Weapon_resonance_obtain_popupView", super)
local windowOpenEffect = "ui/uieffect/prefab/weaponhero/ui_sfx_group_com_rewards_hit"
local exceptionEndCB = function(err)
  if err == ZUtil.ZCancelSource.CancelException then
    return
  end
  logError(err)
end

function Weapon_resonance_obtain_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_resonance_obtain_popup")
  self.skillAoyiTableMgr_ = Z.TableMgr.GetTable("SkillAoyiTableMgr")
  self.skillTableMgr_ = Z.TableMgr.GetTable("SkillTableMgr")
  self.skillAoyiItemTableMgr_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr")
end

function Weapon_resonance_obtain_popupView:OnActive()
  self.uiBinder.btn_close.enabled = false
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.node_effect:CreatEFFGO(windowOpenEffect, Vector3.zero)
  self.uiBinder.node_effect:SetEffectGoVisible(true)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self.uiBinder.animDoTween:Play(Z.DOTweenAnimType.Open)
  Z.AudioMgr:Play("sys_general_award")
  self:initData()
  self:initComponent()
  self:refreshInfo()
  self.uiBinder.anim:CoroPlayOnce("anim_com_rewards_window_open_02", self.cancelSource:CreateToken(), function()
    self.uiBinder.anim:PlayLoop("anim_com_rewards_window_loop")
    self.uiBinder.btn_close.enabled = true
  end, exceptionEndCB)
end

function Weapon_resonance_obtain_popupView:OnDeActive()
  self.uiBinder.node_effect:ReleseEffGo()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
end

function Weapon_resonance_obtain_popupView:OnRefresh()
end

function Weapon_resonance_obtain_popupView:initData()
  local itemData = self.viewData.itemData
  local resonanceItemConfig = self.skillAoyiItemTableMgr_.GetRow(itemData.ItemConfigId)
  if resonanceItemConfig == nil then
    return
  end
  self.curSkillId_ = resonanceItemConfig.SkillId
  self.curResonanceConfig_ = self.skillAoyiTableMgr_.GetRow(self.curSkillId_)
  self.curSkillConfig_ = self.skillTableMgr_.GetRow(self.curSkillId_)
  self.itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemData.ItemConfigId)
end

function Weapon_resonance_obtain_popupView:initComponent()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    self:closeViewHandler()
  end)
end

function Weapon_resonance_obtain_popupView:refreshInfo()
  self.uiBinder.lab_name.text = self.curSkillConfig_.Name
  self.uiBinder.lab_desc.text = self.curResonanceConfig_.Dialogue
  self.uiBinder.rimg_monster:SetImage(self.curResonanceConfig_.ArtPreview)
  self.uiBinder.img_quality:SetImage(string.zconcat(Z.ConstValue.Item.ItemQualityBackGroundImage, self.itemRow.Quality))
end

function Weapon_resonance_obtain_popupView:OnInputBack()
  if self.IsResponseInput then
    self:closeViewHandler()
  end
end

function Weapon_resonance_obtain_popupView:closeViewHandler()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Weapon_resonance_obtain_popupView
