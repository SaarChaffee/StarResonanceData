local super = require("ui.service.service_base")
local EnvService = class("EnvService", super)

function EnvService:OnInit()
  self.envVM_ = Z.VMMgr.GetVM("env")
end

function EnvService:OnUnInit()
end

function EnvService:OnLogin()
  function self.onContainerDataChange(container, dirty)
    if dirty and dirty.resonances ~= nil then
      local isNew = false
      
      for id, value in pairs(dirty.resonances) do
        if value:IsNew() then
          isNew = true
          self:ShowActiveTips(id)
        end
      end
      if isNew then
        self.envVM_:ShowResonanceEffect()
      end
    end
    if dirty and (dirty.installed ~= nil or dirty.resonances ~= nil) then
      self.envVM_:CheckEnvRedDot()
    end
  end
  
  Z.ContainerMgr.CharSerialize.resonance.Watcher:RegWatcher(self.onContainerDataChange)
end

function EnvService:OnLogout()
  Z.ContainerMgr.CharSerialize.resonance.Watcher:UnregWatcher(self.onContainerDataChange)
  self.onContainerDataChange = nil
end

function EnvService:ShowActiveTips(resonanceId)
  local key = Z.ConstValue.PlayerPrefsKey.EnvActive .. resonanceId
  local value = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key, false)
  Z.EventMgr:Dispatch(Z.ConstValue.OnEnvSkillCd, resonanceId)
  if not value then
    local envVM = Z.VMMgr.GetVM("env")
    envVM.OpenEnvWindowView()
    Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, true)
  end
end

return EnvService
