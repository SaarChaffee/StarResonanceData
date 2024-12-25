local StatusSwitchMgr = {}
local viewStatusMap = {
  weapon_role_main = Z.EStatusSwitch.StatusEquipMenu,
  equip_change_window = Z.EStatusSwitch.StatusEquipMenu,
  talk_dialog_window = Z.EStatusSwitch.StatusNormalDialogue,
  cutscene_main = Z.EStatusSwitch.StatusCutscene,
  camerasys = Z.EStatusSwitch.StatusCamera
}

function StatusSwitchMgr:TrySetStateActive(viewConfigKey, isActive)
  if viewStatusMap[viewConfigKey] then
    Z.StatusSwitchMgr:SetStateActive(viewStatusMap[viewConfigKey], isActive)
  end
end

return StatusSwitchMgr
