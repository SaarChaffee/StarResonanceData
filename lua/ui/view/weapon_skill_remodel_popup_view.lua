local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_skill_remodel_popupView = class("Weapon_skill_remodel_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local SkillRemodelItem = require("ui.component.weapon.skill_remodel_item")

function Weapon_skill_remodel_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_skill_remodel_popup")
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function Weapon_skill_remodel_popupView:OnActive()
  self.oriSkillId_ = self.viewData.skillId
  self.skillId_ = self.weaponSkillVm_:GetReplaceSkillId(self.oriSkillId_)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  local redNodeName = self.weaponSkillVm_:GetSkillRemouldRedId(self.oriSkillId_)
  Z.RedPointMgr.LoadRedDotItem(redNodeName, self, self.uiBinder.btn_remodel.transform)
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self:AddAsyncClick(self.uiBinder.btn_remodel, function()
    if self.weaponSkillVm_:ChechSkillRemodelMax(self.skillId_) then
      return
    end
    local skillRemodelRow = Z.TableMgr.GetTable("WeaponStarTableMgr").GetRow(self.selectSkillNodeId)
    if skillRemodelRow then
      for _, value in ipairs(skillRemodelRow.UpgradeCost) do
        local itemId = value[1]
        local num = value[2]
        local haveNum = self.itemsVM_.GetItemTotalCount(itemId)
        if num > haveNum then
          if self.sourceTipId_ then
            Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
          end
          local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
          if itemConfig then
            Z.TipsVM.ShowTipsLang(1045007, {
              val = itemConfig.Name
            })
            self.sourceTipId_ = Z.TipsVM.OpenSourceTips(itemId, self.uiBinder.tips_root)
          end
          return
        end
      end
      local config = self.weaponSkillVm_:GetSkillRemodelConfig(self.oriSkillId_)
      local remodelSkill = self.weaponSkillVm_:GetSkillRemodelLevel(self.oriSkillId_)
      local nodeId = self.selectSkillNodeId
      for _, value in ipairs(config) do
        if value.Level == remodelSkill + 1 then
          nodeId = value.Id
        end
      end
      self.weaponSkillVm_:AsyncProfessionSkillRemodel(nodeId, self.oriSkillId_, self.cancelSource:CreateToken())
    end
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.weaponSkillVm_:CloseSkillRemodePopUp()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.weaponSkillVm_:CloseSkillRemodePopUp()
  end)
  self.initLoopList_ = false
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_item, SkillRemodelItem, "weapon_skill_remodel_item_tpl")
  self:BindEvents()
  self:refreshLoop()
end

function Weapon_skill_remodel_popupView:BindEvents()
  local refresh = function()
    self:refreshLoop()
    local viewData = {
      viewType = E.UpgradeType.SkillRemodel,
      skillId = self.skillId_
    }
    self.weaponVm_.OpenUpgradeView(viewData)
  end
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillRemodelSuccess, refresh, self)
end

function Weapon_skill_remodel_popupView:refreshLoop()
  local config = self.weaponSkillVm_:GetSkillRemodelConfig(self.skillId_)
  if self.initLoopList_ then
    self.loopList_:ClearAllSelect()
    self.loopList_:RefreshListView(config)
  else
    self.loopList_:Init(config)
    self.initLoopList_ = true
  end
  if 3 <= #config then
    self.uiBinder.node_content:SetPivot(0, 0.5)
  else
    self.uiBinder.node_content:SetPivot(0.5, 0.5)
  end
  local remodelSkill = self.weaponSkillVm_:GetSkillRemodelLevel(self.skillId_)
  if remodelSkill < #config then
    self.loopList_:SetSelected(remodelSkill + 1)
    self.loopList_:MovePanelToItemIndex(remodelSkill)
  end
  if self.weaponSkillVm_:ChechSkillRemodelMax(self.skillId_) then
    self.uiBinder.btn_remodel.IsDisabled = true
    self.uiBinder.btn_remodel_binder.lab_normal.text = Lang("skillFullRemodel")
  else
    self.uiBinder.btn_remodel.IsDisabled = false
    self.uiBinder.btn_remodel_binder.lab_normal.text = Lang("Remodel")
  end
end

function Weapon_skill_remodel_popupView:onItemSelected(data)
  self.selectSkillNodeId = data.Id
  local remodelSkill = self.weaponSkillVm_:GetSkillRemodelLevel(data.SkillId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_remodel, data.Level == remodelSkill + 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.remodel_finish, remodelSkill >= data.Level)
  self.uiBinder.Ref:SetVisible(self.uiBinder.remodel_tips, data.Level > remodelSkill + 1)
end

function Weapon_skill_remodel_popupView:OnDeActive()
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
  self.loopList_:UnInit()
  self.loopList_ = nil
  self.initLoopList_ = false
end

function Weapon_skill_remodel_popupView:OnRefresh()
end

return Weapon_skill_remodel_popupView
