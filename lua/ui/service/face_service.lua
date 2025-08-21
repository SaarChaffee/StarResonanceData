local super = require("ui.service.service_base")
local faceRed = require("rednode.face_red")
local FaceService = class("FaceService", super)
local onContainerDataChange = function(container, dirtyKeys)
  local faceData = Z.DataMgr.Get("face_data")
  if not faceData:GetIsInit() then
    return
  end
  if dirtyKeys.faceInfo then
    for optionEnum, value in pairs(container.faceInfo) do
      faceData:UpdateFaceOptionData(optionEnum, value)
    end
  end
  if dirtyKeys.colorInfo then
    for optionEnum, value in pairs(container.colorInfo) do
      faceData:UpdateFaceOptionData(optionEnum, value)
    end
  end
end
local onRoleFaceDataChange = function(container, dirtyKeys)
  for faceId, _ in pairs(dirtyKeys.unlockItemMap) do
    faceRed.UpdateFaceUnlockCostData(faceId)
  end
end

function FaceService:OnInit()
end

function FaceService:OnUnInit()
end

function FaceService:OnLogin()
  faceRed.Init()
  Z.ContainerMgr.CharSerialize.charBase.faceData.Watcher:RegWatcher(onContainerDataChange)
  Z.ContainerMgr.CharSerialize.roleFace.Watcher:RegWatcher(onRoleFaceDataChange)
end

function FaceService:OnLogout()
  Z.ContainerMgr.CharSerialize.charBase.faceData.Watcher:UnregWatcher(onContainerDataChange)
  Z.ContainerMgr.CharSerialize.roleFace.Watcher:UnregWatcher(onRoleFaceDataChange)
  faceRed.UnInit()
end

function FaceService:OnReconnect()
  local faceData = Z.DataMgr.Get("face_data")
  faceData:SetIsInit(false)
  self:initFaceData()
  faceRed.InitFaceUnlockCostData()
end

function FaceService:OnEnterScene()
  if Z.StageMgr.GetIsInGameScene() then
    self:initFaceData()
    faceRed.InitFaceUnlockCostData()
    local faceData = Z.DataMgr.Get("face_data")
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Account, faceData.FaceCacheData)
  end
end

function FaceService:initFaceData()
  local faceData = Z.DataMgr.Get("face_data")
  if faceData:GetIsInit() then
    return
  end
  local faceContainer = Z.ContainerMgr.CharSerialize.charBase.faceData
  if not faceContainer then
    return
  end
  faceData:SetIsInit(true)
  faceData:InitFaceOption()
  for optionEnum, value in pairs(faceContainer.faceInfo) do
    faceData:AddFaceOptionServerValue(optionEnum, value)
  end
  for optionEnum, value in pairs(faceContainer.colorInfo) do
    faceData:AddFaceOptionServerValue(optionEnum, value)
  end
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateFaceInitOptionDictByModelId()
end

return FaceService
