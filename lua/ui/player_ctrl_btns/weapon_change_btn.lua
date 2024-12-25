local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local WeaponChangeBtn = class("WeaponChangeBtn", super)
local keyIconHelper = require("ui.component.mainui.key_icon_helper")

function WeaponChangeBtn:ctor(key, panel)
  super.ctor(self, key, panel)
  self.changeWeaponIsInCd_ = false
  self.cdkey_ = "weapon_changed_cd"
end

function WeaponChangeBtn:GetUIUnitPath()
  local path = "ui/prefabs/controller/controller_weaponchange_ctrl_btn_new_tpl"
  return Z.IsPCUI and path .. Z.ConstValue.PCAssetSuffix or path
end

function WeaponChangeBtn:OnActive()
  local weaponHeroCount = self:GetWeaponHeroCount()
  local funcOpen = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.WeaponSlot, true)
  if weaponHeroCount <= 1 or not funcOpen then
    self.uiUnit_.Ref:SetVisible(false)
  else
    self.uiUnit_.Ref:SetVisible(true)
  end
  self:ShowWeaponChangeBtn()
  local cdHandler = self.uiUnit_.weapon_changed_cd.cd_ctrl_handler.cdHandler
  cdHandler:ChangeCdKey(self.cdkey_)
  Z.GuideMgr:SetSteerId(self.uiUnit_.img_base, E.DynamicSteerType.KeyBoardId, 16)
  keyIconHelper.InitKeyIcon(self, self.uiUnit_.cont_key_icon, 16)
end

function WeaponChangeBtn:OnDeActive()
end

function WeaponChangeBtn:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrWeaponIds")
  }, Z.EntityMgr.PlayerEnt, self.refreshBtn)
end

function WeaponChangeBtn:RegisterEvent()
  Z.EventMgr:Add("InputChangeWeapon", self.onInputChangeWeapon, self)
  Z.EventMgr:Add("OnCDLayerChanged", self.OnCDLayerChanged, self)
end

function WeaponChangeBtn:UnregisterEvent()
  Z.EventMgr:RemoveObjAll(self)
end

function WeaponChangeBtn:refreshBtn()
  local weaponHeroCount = self:GetWeaponHeroCount()
  local funcOpen = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.WeaponSlot, true)
  if weaponHeroCount <= 1 or not funcOpen then
    self.uiUnit_.Ref:SetVisible(false)
  else
    self.uiUnit_.Ref:SetVisible(true)
  end
end

function WeaponChangeBtn:OnCDLayerChanged(key)
  if self.cdkey_ == key then
    self.changeWeaponIsInCd_ = false
  end
end

function WeaponChangeBtn:asyncChangeWeapon()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  return weaponVm.AsyncSwitchWeapon(weaponVm.GetCurPlanId(), self.cancelSource:CreateToken())
end

function WeaponChangeBtn:ShowWeaponChangeBtn()
  local btnTrigger = self.uiUnit_.touch_area.EventTrigger
  btnTrigger.onDown:AddListener(function()
    if self.uiUnit_ == nil then
      return
    end
    self:onInputChangeWeapon()
  end)
  self:InitChangeWeaponCD()
end

function WeaponChangeBtn:onInputChangeWeapon()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if gotoFuncVM.CheckFuncCanUse(E.FunctionID.WeaponSlot) then
    local weaponVM = Z.VMMgr.GetVM("weapon")
    local weaponCount = weaponVM.GetCurEquipWeaponCount()
    if weaponCount <= 1 then
      Z.TipsVM.ShowTipsLang(1000737)
    else
      Z.CoroUtil.create_coro_xpcall(function()
        self:onAsyncClickChangeBtn()
      end)()
    end
  end
end

function WeaponChangeBtn:onAsyncClickChangeBtn()
  local canChange = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ECanChangeWeapon).Value
  if not canChange then
    return
  end
  if self.changeWeaponIsInCd_ then
    return
  end
  local weaponHeroCount = self:GetWeaponHeroCount()
  local funcOpen = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.WeaponSlot, true)
  if weaponHeroCount <= 1 or not funcOpen then
    return
  end
  if self:asyncChangeWeapon() then
    self.changeWeaponIsInCd_ = true
    local uiCD = self.uiUnit_.weapon_changed_cd.cd_ctrl_handler.cdData
    uiCD.CDLen = Z.Global.WeaponSwitchCd
    local cdHandler = self.uiUnit_.weapon_changed_cd.cd_ctrl_handler.cdHandler
    cdHandler.CDLen = tonumber(Z.GlobalConfig:GetString("WeaponSwitchCd"))
    cdHandler:CreateCD()
  end
end

function WeaponChangeBtn:GetWeaponHeroCount()
  return 1
end

function WeaponChangeBtn:InitChangeWeaponCD()
  local beginTime = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrProfessionSwitchTime")).Value
  local serverTime = Z.ServerTime:GetServerTime()
  local maxCdTime = Z.Global.WeaponSwitchCd
  if serverTime - beginTime < maxCdTime * 1000 then
    local cdHandler = self.uiUnit_.weapon_changed_cd.cd_ctrl_handler.cdHandler
    cdHandler.CDLen = maxCdTime
    cdHandler.Progress = (serverTime - beginTime) / (maxCdTime * 1000)
    cdHandler:CreateCD()
  end
end

return WeaponChangeBtn
