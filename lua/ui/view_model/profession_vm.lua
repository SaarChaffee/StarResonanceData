local ProfessionVM = {}

function ProfessionVM.OpenProfessionSelectView(isFaceView)
  local viewData = {isFaceView = isFaceView}
  if isFaceView then
  else
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.SelectProfession)
    if not isOn then
      return
    end
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, "profession_select_window", function()
    Z.UIMgr:OpenView("profession_select_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end

function ProfessionVM:CloseProfessionSelectView()
  Z.UIMgr:CloseView("profession_select_window")
end

function ProfessionVM:GetCurProfession()
  if Z.EntityMgr.PlayerEnt == nil then
    return self:GetContainerProfession()
  end
  return Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrProfessionId")).Value
end

function ProfessionVM:GetContainerProfession()
  return Z.ContainerMgr.CharSerialize.professionList.curProfessionId
end

function ProfessionVM:CheckProfessionUnlock(professionId)
  if professionId == nil then
    professionId = self:GetContainerProfession()
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
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if not professionRow then
    return true
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ProfessionReplaceJumpTips", {
    val = professionRow.Name
  }), function()
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
