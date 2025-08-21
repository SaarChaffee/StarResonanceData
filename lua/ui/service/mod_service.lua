local super = require("ui.service.service_base")
local ModService = class("ModService", super)

function ModService:OnInit()
end

function ModService:OnUnInit()
end

function ModService:OnLogin()
  function self.onContainerDataChange_()
    self:checkModRedDot()
    
    Z.EventMgr:Dispatch(Z.ConstValue.Mod.OnModContainerChange)
  end
  
  Z.ContainerMgr.CharSerialize.mod.Watcher:RegWatcher(self.onContainerDataChange_)
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.onContainerDataChange_)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function ModService:OnLogout()
  Z.ContainerMgr.CharSerialize.mod.Watcher:UnregWatcher(self.onContainerDataChange_)
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.onContainerDataChange_)
  self.onContainerDataChange_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function ModService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:checkModRedDot()
  end
end

function ModService:checkModRedDot()
  local modVM = Z.VMMgr.GetVM("mod")
  local red, mods = modVM.IsHaveRedDot()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.ModTab, red and 1 or 0)
end

function ModService:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Mod) then
    self:checkModRedDot()
  end
end

return ModService
