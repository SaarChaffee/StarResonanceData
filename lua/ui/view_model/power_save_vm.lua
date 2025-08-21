local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local PowerSaveVM = {}

function PowerSaveVM.SetIsPowerSaveOpen(isOpen)
  local powerSaveData = Z.DataMgr.Get("power_save_data")
  powerSaveData:SetOpen(isOpen)
  if isOpen then
    PowerSaveVM.OpenPowerSaveMode()
  else
    PowerSaveVM.ClosePowerSaveMode()
  end
end

function PowerSaveVM.OpenPowerSaveMode()
  if Z.GameContext.IsPC or Z.IsPCUI then
    return
  end
  local powerSaveData = Z.DataMgr.Get("power_save_data")
  if not powerSaveData:GetOpen() then
    return
  end
  Z.UIMgr:OpenView("power_saving_window")
end

function PowerSaveVM.ClosePowerSaveMode()
  if Z.GameContext.IsPC or Z.IsPCUI then
    return
  end
  Z.UIMgr:CloseView("power_saving_window")
end

function PowerSaveVM.EnterPowerSaveMode()
  QualityGradeSetting.IsSavePowerMode = true
  Z.GuideMgr:SetBlockSteer(E.BlockSteerType.ScreenSaver, true)
end

function PowerSaveVM.ExitPowerSaveMode()
  QualityGradeSetting.IsSavePowerMode = false
  Z.GuideMgr:SetBlockSteer(E.BlockSteerType.ScreenSaver, false)
end

return PowerSaveVM
