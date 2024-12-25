local UI = Z.UI
local super = require("ui.ui_subview_base")
local AccountmoduleView = class("AccountmoduleView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local PERSONALZONEDEFINE = require("ui.model.personalzone_define")

function AccountmoduleView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_account_sub", "set/set_account_sub", UI.ECacheLv.None, parent)
end

function AccountmoduleView:OnActive()
  self.uiBinder.set_account_sub:SetOffsetMin(0, 0)
  self.uiBinder.set_account_sub:SetOffsetMax(0, 0)
  self.settingsTbl_ = Z.TableMgr.GetTable("SettingsTableMgr")
  self.settingsTypeTbl_ = Z.TableMgr.GetTable("SettingsTypeTableMgr")
  self.vm = Z.VMMgr.GetVM("accountmodule")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.roleLevelData_ = Z.DataMgr.Get("role_level_data")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.playerVM_ = Z.VMMgr.GetVM("player")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.isHudSettingChange_ = false
  self:setPlayerInfo()
  self:HUDSetting()
end

function AccountmoduleView:setPlayerInfo()
  if self.playerVM_:IsNamed() then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  else
    self.uiBinder.lab_name.text = ""
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isRenameFuncUnloack = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Rename, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_rename, self.playerVM_:IsNamed() and isRenameFuncUnloack)
  self.uiBinder.lab_uid.text = Lang("UID") .. Z.ContainerMgr.CharSerialize.charBase.showId
  self.uiBinder.lab_level.text = Lang("RoleLevel", {
    val = self.roleLevelData_:GetRoleLevel()
  })
  local iconstr = Z.ContainerMgr.CharSerialize.charBase.gender == 1 and "manicon" or "womanicon"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.prefabCacheData, iconstr)
  self.uiBinder.img_gender:SetImage(path)
  Z.CoroUtil.create_coro_xpcall(function()
    self.socialData_ = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.EntId, self.cancelSource:CreateToken())
    local viewData = {}
    viewData.id = self.socialData_.avatarInfo.avatarId
    viewData.modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    viewData.charId = Z.EntityMgr.PlayerEnt.EntId
    viewData.headFrameId = nil
    if self.socialData_.avatarInfo and self.socialData_.avatarInfo.avatarFrameId then
      viewData.headFrameId = self.socialData_.avatarInfo.avatarFrameId
    end
    
    function viewData.func()
      local personalzoneVM = Z.VMMgr.GetVM("personal_zone")
      personalzoneVM.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
    
    playerPortraitHgr.InsertNewPortrait(self.uiBinder.cont_portrait, viewData)
    local cardConfig
    if self.socialData_.avatarInfo and 0 < self.socialData_.avatarInfo.businessCardStyleId then
      cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.socialData_.avatarInfo.businessCardStyleId)
    else
      cardConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.personalzoneData_:GetDefaultProfileImageConfigByType(PERSONALZONEDEFINE.ProfileImageType.Card))
    end
    if cardConfig then
      self.uiBinder.rimg_bg:SetImage(cardConfig.Image)
      self.uiBinder.img_line_left:SetColorByHex(cardConfig.Color)
      self.uiBinder.img_bg:SetColorByHex(cardConfig.Color)
    end
  end)()
  local settingData = self.settingsTbl_.GetRow(6)
  if settingData then
    self.uiBinder.lab_function_out.text = settingData.Name
  end
  self:AddAsyncClick(self.uiBinder.btn_copy, function()
    Z.LuaBridge.SystemCopy(tostring(Z.ContainerMgr.CharSerialize.charBase.showId))
    Z.TipsVM.ShowTipsLang(100110)
  end)
  self:AddAsyncClick(self.uiBinder.btn_function_break, function()
    self.playerVM_:OpenUnstuckTip()
  end)
  self:AddAsyncClick(self.uiBinder.btn_function_out, function()
    self.vm.Logout()
  end)
  self:AddAsyncClick(self.uiBinder.btn_rename, function()
    self.playerVM_:OpenRenameWindow()
  end)
end

function AccountmoduleView:OnDeActive()
  if self.isHudSettingChange_ then
    Z.LuaBridge.RefreshHudSetting()
  end
  playerPortraitHgr.ClearAllActiveItems()
end

function AccountmoduleView:WeaponDisplaySetting()
  local switch = self.uiBinder.cont_battle.binder_display_weapon.cont_switch.switch
  local weaponDisplay = self.settingVM_.Get(E.SettingID.WeaponDisplay)
  switch:SetIsOnWithoutNotify(weaponDisplay)
  switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.WeaponDisplay, isOn)
  end)
end

function AccountmoduleView:HUDSetting()
  self:PlayerInfoHUDSetting()
  self:OtherPlayerInfoHUDSetting()
  self:NPCInfoHUDSetting()
end

function AccountmoduleView:PlayerInfoHUDSetting()
  local togTitle = self.uiBinder.cont_battle.binder_player_info.tog_title
  local togName = self.uiBinder.cont_battle.binder_player_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.PlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local titleOn = settingDict[E.SettingHUDType.Title] == nil or settingDict[E.SettingHUDType.Title] == "1"
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  togTitle:SetIsOnWithoutCallBack(titleOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togTitle:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local titleIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.PlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local titleIsOn = togTitle.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.PlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
end

function AccountmoduleView:OtherPlayerInfoHUDSetting()
  local togTitle = self.uiBinder.cont_battle.binder_other_player_info.tog_title
  local togName = self.uiBinder.cont_battle.binder_other_player_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.OtherPlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local titleOn = settingDict[E.SettingHUDType.Title] == nil or settingDict[E.SettingHUDType.Title] == "1"
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  togTitle:SetIsOnWithoutCallBack(titleOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togTitle:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local titleIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.OtherPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local titleIsOn = togTitle.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Title, "=", titleIsOn)
    self.settingVM_.Set(E.SettingID.OtherPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
end

function AccountmoduleView:NPCInfoHUDSetting()
  local togFunc = self.uiBinder.cont_battle.binder_npc_info.tog_func
  local togName = self.uiBinder.cont_battle.binder_npc_info.tog_name
  local data = self.settingVM_.Get(E.SettingID.NPCPlayerHeadInformation)
  local settings = string.zsplit(data, ",")
  local settingDict = {}
  for _, v in ipairs(settings) do
    local setting = string.zsplit(v, "=")
    settingDict[tonumber(setting[1])] = setting[2]
  end
  local nameOn = settingDict[E.SettingHUDType.Name] == nil or settingDict[E.SettingHUDType.Name] == "1"
  local funcOn = settingDict[E.SettingHUDType.Func] == nil or settingDict[E.SettingHUDType.Func] == "1"
  togFunc:SetIsOnWithoutCallBack(funcOn)
  togName:SetIsOnWithoutCallBack(nameOn)
  togFunc:AddListener(function(isOn)
    local nameIsOn = togName.isOn and 1 or 0
    local funcIsOn = isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Func, "=", funcIsOn)
    self.settingVM_.Set(E.SettingID.NPCPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
  togName:AddListener(function(isOn)
    local nameIsOn = isOn and 1 or 0
    local funcIsOn = togFunc.isOn and 1 or 0
    local data = string.zconcat(E.SettingHUDType.Name, "=", nameIsOn, ",", E.SettingHUDType.Func, "=", funcIsOn)
    self.settingVM_.Set(E.SettingID.NPCPlayerHeadInformation, data)
    self.isHudSettingChange_ = true
  end)
end

return AccountmoduleView
