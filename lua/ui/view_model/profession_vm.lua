local ProfessionVM = {}

function ProfessionVM.OpenProfessionSelectView(isFaceView)
  local viewData = {isFaceView = isFaceView}
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, "profession_select_window", function()
    Z.UIMgr:OpenView("profession_select_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end

function ProfessionVM:CloseProfessionSelectView()
  Z.UIMgr:CloseView("profession_select_window")
end

function ProfessionVM:GetCurProfession()
  return Z.ContainerMgr.CharSerialize.professionList.curProfessionId
end

function ProfessionVM:CheckProfessionUnlock(professionId)
  if professionId == nil then
    professionId = self:GetCurProfession()
  end
  return Z.ContainerMgr.CharSerialize.professionList.professionList[professionId] ~= nil
end

function ProfessionVM:CheckUnlockAllProfession()
  local professionData = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for index, value in pairs(professionData) do
    if value.IsOpen and not self:CheckProfessionUnlock(value.Id) then
      return false
    end
  end
  return true
end

function ProfessionVM:CheckProfessionEquipWeapon()
  local weaponPart = Z.Global.EquipWeaponSlot
  if Z.ContainerMgr.CharSerialize.equip.equipList[weaponPart] == nil then
    return false
  end
  return Z.ContainerMgr.CharSerialize.equip.equipList[weaponPart].itemUuid ~= 0
end

function ProfessionVM:AsyncChangeProfession(professionId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local equipWeaponInfo = {professionId = professionId}
  local ret = worldProxy.EquipProfession(equipWeaponInfo, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Hero.ChangeProfession, professionId)
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if not professionRow then
    return true
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ProfessionReplaceJumpTips", {
    val = professionRow.Name
  }), function()
    Z.DialogViewDataMgr:CloseDialogView()
    local equipVm = Z.VMMgr.GetVM("equip_system")
    local viewData = {
      itemUuid = 0,
      prtId = Z.Global.EquipWeaponSlot
    }
    equipVm.OpenChangeEquipView(viewData)
  end)
  return true
end

function ProfessionVM:AsyncAcceptProfessionQuest(professionId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ProfessionQuestRequest = {professionId = professionId}
  local ret = worldProxy.AcceptProfessionQuest(ProfessionQuestRequest, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
end

return ProfessionVM
