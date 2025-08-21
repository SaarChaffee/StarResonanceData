local DungeonSettlementPos = class("DungeonSettlementPos")

function DungeonSettlementPos:ctor(view, parent, itemPath)
  self.teamVm_ = Z.VMMgr.GetVM("team")
  self.dungeonMainData_ = Z.DataMgr.Get("hero_dungeon_main_data")
  self.view_ = view
  self.parent_ = parent
  self.itemPath_ = itemPath
  self.entChar_ = Z.PbEnum("EEntityType", "EntChar")
  self.entityVM_ = Z.VMMgr.GetVM("entity")
end

function DungeonSettlementPos:AsyncSetPos()
  local teamMembers = self.teamVm_.GetTeamMemData()
  if self.itemPath_ == nil or self.itemPath_ == "" then
    return
  end
  local vUserPos = self.dungeonMainData_.TeamDisplayData.vUserPos
  local ret = {}
  ret.vUserPos = {}
  local units = {}
  if 0 < #teamMembers then
    for i = 1, #teamMembers do
      local memberInfo = teamMembers[i]
      if not memberInfo.isAi and vUserPos and vUserPos[memberInfo.charId] then
        local playItem = self.view_:AsyncLoadUiUnit(self.itemPath_, "playerinfo" .. i, self.parent_.transform)
        if playItem then
          units[memberInfo.charId] = playItem
        end
        local uuid = self.entityVM_.EntIdToUuid(memberInfo.charId, self.entChar_)
        local entity = Z.EntityMgr:GetEntity(uuid)
        if entity then
          entity.Model:SetLuaAttr(Z.ModelAttr.EModelAnimIKClose, true)
        end
      end
    end
  elseif vUserPos and vUserPos[Z.ContainerMgr.CharSerialize.charId] then
    local playItem = self.view_:AsyncLoadUiUnit(self.itemPath_, "playerinfo1", self.parent_.transform)
    if playItem then
      units[Z.ContainerMgr.CharSerialize.charId] = playItem
      local uuid = self.entityVM_.EntIdToUuid(Z.ContainerMgr.CharSerialize.charId, self.entChar_)
      local entity = Z.EntityMgr:GetEntity(uuid)
      if entity then
        entity.Model:SetLuaAttr(Z.ModelAttr.EModelAnimIKClose, true)
      end
    end
  end
  Z.Delay(0.1, self.view_.cancelSource:CreateToken())
  for charId, playItem in pairs(units) do
    if playItem then
      local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(playItem.Trans.position)
      local cameraPosition = Z.CameraMgr.MainCamera.transform.position
      screenPosition.z = Z.NumTools.Distance(cameraPosition, vUserPos[charId].pos)
      local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(screenPosition)
      local tab = {}
      tab.pos = {
        x = worldPosition.x,
        y = vUserPos[charId].pos.y,
        z = worldPosition.z,
        dir = vUserPos[charId].pos.dir
      }
      ret.vUserPos[charId] = tab
    end
  end
  local proxy = require("zproxy.world_proxy")
  proxy.ReportSettlementPosition(ret, self.view_.cancelSource:CreateToken())
end

return DungeonSettlementPos
