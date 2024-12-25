local UI = Z.UI
local super = require("ui.ui_view_base")
local Characterinfo_gatherView = class("Characterinfo_gatherView", super)
local equipview = require("ui.view.equip_system_view").new()
local roleview = require("ui.view.role_info_main_view").new()
local weaponHero = require("ui.view.weaponhero_resonance_main_view").new()

function Characterinfo_gatherView:ctor()
  self.panel = nil
  self.viewData = nil
  super.ctor(self, "characterinfo_gather")
  self.vm_ = Z.VMMgr.GetVM("characterinfo_gather")
end

function Characterinfo_gatherView:OnActive()
  self:startAnimatedShow()
  if self.viewData.data == nil then
    self.viewData.data = {}
  end
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  self.curSubViewType_ = self.viewData.subViewType
  self.items_ = {
    [1] = {
      subView = roleview,
      toggle = self.panel.con_role,
      returnBntName = Lang("role")
    },
    [2] = {
      subView = weaponHero,
      toggle = self.panel.con_weapon,
      returnBntName = Lang("role")
    },
    [3] = {
      subView = equipview,
      toggle = self.panel.con_equip,
      returnBntName = Lang("role")
    },
    [4] = {
      toggle = self.panel.con_equip,
      returnBntName = "4",
      returnBntName = Lang("role")
    }
  }
  self.init_ = true
  for index, item in pairs(self.items_) do
    item.toggle.Tog.group = self.panel.bodmod_tab_bg.TogGroup
    item.toggle.Tog:AddListener(function(isOn)
      if isOn then
        self:onchangeSubView(index, self.init_)
        self.init_ = false
      end
    end)
  end
  local state = self.switchVm_.CheckFuncSwitch(E.EquipFuncId.Equip)
  self.panel.con_equip:SetVisible(state == nil and true or state)
  self.modelPosY_ = {
    [1] = 1983,
    [2] = 1979.8,
    [3] = 1979.5
  }
  local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  local modelHumanData = Z.TableMgr.GetTable("ModelHumanTableMgr").GetRow(modelId)
  if modelHumanData then
    self.modelSize_ = modelHumanData.Model
  end
  self:AddAsyncClick(self.panel.common_btn_return.btn_return_bg.Btn, function()
    self:closeBntClick()
  end, nil, nil)
  
  function self.onWeaponHeroEquipSuccess_()
    if self.curSubViewType_ == E.CharacterViewType.EWeaponHero then
      local weaponView = self.items_[self.curSubViewType_].subView
      if weaponView.State == E.WeaponHeroResonanceType.Details then
        weaponView:CloseWeaponHeroDetail()
        self:showSelectTag()
      end
    end
  end
  
  self.modifyModelPos_ = false
  
  function self.onEquipPortSelect()
    self.returnLab.text = Lang("Equip")
    self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
    self.panel.bodmod_tab_bg:SetVisible(false)
  end
  
  Z.EventMgr:Add(Z.ConstValue.Hero.EquipSuccess, self.onWeaponHeroEquipSuccess_, self)
  Z.EventMgr:Add(Z.ConstValue.Hero.DetailDisplay, self.hideSelectTag, self)
  Z.EventMgr:Add(Z.ConstValue.Equip.PortSelect, self.onEquipPortSelect, self)
  self.returnLab = self.panel.common_btn_return.lab_return.TMPLab
  self:showPlayerModel()
  self.items_[self.curSubViewType_].toggle.Tog.isOn = true
  self:BindEvents()
end

function Characterinfo_gatherView:closeBntClick()
  if self.curSubViewType_ == E.CharacterViewType.EEquip then
    local itemView = self.items_[self.curSubViewType_].subView
    if itemView.State == 2 and itemView.ReturnPartsView then
      itemView:ShowEquipPartsView()
      self.returnLab.text = self.items_[self.curSubViewType_].returnBntName
      self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
      self:showSelectTag()
      return
    end
  elseif self.curSubViewType_ == E.CharacterViewType.EWeaponHero then
    local weaponView = self.items_[self.curSubViewType_].subView
    if weaponView.State == 2 then
      weaponView:CloseWeaponHeroDetail()
      self.returnLab.text = self.items_[self.curSubViewType_].returnBntName
      self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
      self:showSelectTag()
      return
    end
    weaponView:ClearCacheState()
  end
  self.vm_.CloseView()
end

function Characterinfo_gatherView:setModelPos(x, y)
end

function Characterinfo_gatherView:hideSelectTag()
  self.returnLab.text = Lang("connector")
  self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
  self.panel.bodmod_tab_bg:SetVisible(false)
  if self.playerZModel_ then
    Z.ModelHelper.SetAlpha(self.playerZModel_, Z.ModelRenderType.All, 0, Panda.ZGame.EModelAlphaSourceType.EUI, false)
  end
end

function Characterinfo_gatherView:showSelectTag()
  self.returnLab.text = Lang("role")
  self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
  if self.playerZModel_ then
    Z.ModelHelper.SetAlpha(self.playerZModel_, Z.ModelRenderType.All, 0.5, Panda.ZGame.EModelAlphaSourceType.EUI, false)
  end
  self.panel.bodmod_tab_bg:SetVisible(true)
end

function Characterinfo_gatherView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for key, value in pairs(self.items_) do
    if value.subView then
      value.subView:DeActive()
    end
  end
  Z.EventMgr:Remove(Z.ConstValue.Hero.DetailDisplay, self.hideSelectTag, self)
  Z.EventMgr:Remove(Z.ConstValue.Hero.EquipSuccess, self.onWeaponHeroEquipSuccess_, self)
  Z.EventMgr:Remove(Z.ConstValue.Equip.PortSelect, self.hideSelectTag, self)
  self.panel.bodmod_tab_bg:SetVisible(true)
  self.playerZModel_ = nil
end

function Characterinfo_gatherView:GetCacheData()
  local viewData = self.viewData
  viewData.subViewType = self.curSubViewType_
  return viewData
end

function Characterinfo_gatherView:OnRefresh()
end

function Characterinfo_gatherView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionAttrChange, self.onFashionAttrChange, self)
end

function Characterinfo_gatherView:onFashionAttrChange(attrType, ...)
  if not self.playerZModel_ then
    return
  end
  local arg = {
    ...
  }
  self.playerZModel_:SetLuaAttr(attrType, table.unpack(arg))
end

function Characterinfo_gatherView:openEquipView()
end

function Characterinfo_gatherView:onchangeSubView(subViewType, force)
  if subViewType == self.curSubViewType_ and not force then
    return
  end
  if self.modifyModelPos_ then
  end
  local lastType = self.curSubViewType_
  local prevItem = self.items_[self.curSubViewType_]
  if force then
  else
    self:showPlayerUIModelEffect(lastType, subViewType)
  end
  if prevItem then
    if prevItem.subView then
      prevItem.subView:DeActive()
    end
    self.curSubViewType_ = subViewType
    local item = self.items_[self.curSubViewType_]
    if item then
      self.returnLab.text = item.returnBntName
      self.panel.common_btn_return.btn_return_bg.ZLayout:ForceRebuildLayoutImmediate()
      if item.subView then
        item.subView:Active(self.viewData.data, self.panel.subview_content.Trans)
      else
        Z.DialogViewDataMgr:OpenOKDialog(Lang("FuncNoDevelopment"))
      end
    end
  end
end

function Characterinfo_gatherView:showPlayerModel()
  self.playerZModel_ = Z.UnrealSceneMgr:CloneModelByLua(self.playerZModel_, Z.EntityMgr.PlayerEnt.Model)
  self.playerZModel_:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
  self.playerZModel_:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
  self:ChangeHeroModel(self.curSubViewType_)
end

function Characterinfo_gatherView:showPlayerUIModelEffect(lastViewType, curViewType)
  if curViewType == E.CharacterViewType.ERoleInfo and lastViewType == E.CharacterViewType.EWeaponHero then
    self:ChangeHeroModel(curViewType)
  elseif curViewType == E.CharacterViewType.ERoleInfo and lastViewType == E.CharacterViewType.EEquip then
  elseif curViewType == E.CharacterViewType.EWeaponHero and lastViewType == E.CharacterViewType.ERoleInfo then
    self:ChangeHeroModel(curViewType)
  elseif curViewType == E.CharacterViewType.EWeaponHero and lastViewType == 3 then
    self:ChangeHeroModel(curViewType)
  elseif curViewType == E.CharacterViewType.EEquip and lastViewType == E.CharacterViewType.ERoleInfo then
  else
    if curViewType == E.CharacterViewType.EEquip and lastViewType == E.CharacterViewType.EWeaponHero then
      self:ChangeHeroModel(curViewType)
    else
    end
  end
end

function Characterinfo_gatherView:ChangeHeroModel(subViewType)
  self.playerZModel_:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, false)
  local height = self.playerZModel_:GetAttrGoNormalHeight()
  if subViewType == E.CharacterViewType.ERoleInfo or subViewType == E.CharacterViewType.EEquip then
    Z.ModelHelper.SetAlpha(self.playerZModel_, Z.ModelRenderType.All, 1, Panda.ZGame.EModelAlphaSourceType.EUI, false)
    self.playerZModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 140, 0)))
    self.playerZModel_:SetAttrGoPosition(Vector3.New(99.5, 2000, 100))
    self.playerZModel_:SetLuaAttrGoScale(1)
    self.playerZModel_:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, true)
  elseif subViewType == E.CharacterViewType.EWeaponHero then
    Z.ModelHelper.SetAlpha(self.playerZModel_, Z.ModelRenderType.All, 0.5, Panda.ZGame.EModelAlphaSourceType.EUI, false)
    local delaytime = 0
    if self.init_ then
      delaytime = 0.2
    end
    self.timerMgr:StartTimer(function()
      self.playerZModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(-15, 180, 0)))
      self.playerZModel_:SetAttrGoPosition(Vector3.New(100.5, self.modelPosY_[self.modelSize_], 110.46))
      self.playerZModel_:SetLuaAttrGoScale(15)
      self.playerZModel_:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, true)
    end, delaytime, 1)
  end
end

function Characterinfo_gatherView:startAnimatedShow()
  self.panel.anim.anim:PlayOnce("anim_characterinfo_gather_001")
end

function Characterinfo_gatherView:startAnimatedHide()
  if self.curSubViewType_ == 2 then
    local weaponView = self.items_[self.curSubViewType_].subView
    if weaponView.State == E.WeaponHeroResonanceType.Details then
      return
    end
  end
end

function Characterinfo_gatherView:CustomClose()
  Z.UnrealSceneMgr:CloseUnrealScene("characterinfo_gather")
end

return Characterinfo_gatherView
