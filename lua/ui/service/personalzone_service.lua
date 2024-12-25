local super = require("ui.service.service_base")
local PersonalzoneService = class("PersonalzoneService", super)

function PersonalzoneService:OnInit()
end

function PersonalzoneService:OnUnInit()
end

function PersonalzoneService:OnLogin()
  function self.onContainerChanged(container, dirty)
    if dirty.unlockTargetRecord then
      local personalzoneData = Z.DataMgr.Get("personal_zone_data")
      
      for key, record in pairs(Z.ContainerMgr.CharSerialize.personalZone.unlockTargetRecord) do
        personalzoneData:SetProfileImageTarget(key, record)
      end
      local personalZoneVM = Z.VMMgr.GetVM("personal_zone")
      personalZoneVM.CheckRed()
    end
    if dirty.unlockGetRewardRecord then
      local personalZoneVM = Z.VMMgr.GetVM("personal_zone")
      personalZoneVM.CheckRed()
    end
  end
  
  Z.ContainerMgr.CharSerialize.personalZone.Watcher:RegWatcher(self.onContainerChanged)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function PersonalzoneService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
  if self.onContainerChanged ~= nil then
    Z.ContainerMgr.CharSerialize.personalZone.Watcher:UnregWatcher(self.onContainerChanged)
    self.onContainerChanged = nil
  end
end

function PersonalzoneService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    local personalzoneData = Z.DataMgr.Get("personal_zone_data")
    for key, record in pairs(Z.ContainerMgr.CharSerialize.personalZone.unlockTargetRecord) do
      personalzoneData:SetProfileImageTarget(key, record)
    end
    local personalZoneVM = Z.VMMgr.GetVM("personal_zone")
    personalZoneVM.CheckRed()
  end
end

function PersonalzoneService:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId, true)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Personalzone) then
    local personalZoneVM = Z.VMMgr.GetVM("personal_zone")
    if itemConfig and itemConfig.IsSpecialDisplay then
      personalZoneVM.OpenAwardPopView(item.configId)
    end
    local personalzoneData = Z.DataMgr.Get("personal_zone_data")
    personalzoneData:AddPersonalzoneItem(item.configId)
    personalZoneVM.CheckRed()
  end
end

return PersonalzoneService
