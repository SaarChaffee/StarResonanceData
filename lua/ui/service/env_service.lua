local super = require("ui.service.service_base")
local EnvService = class("EnvService", super)

function EnvService:OnInit()
end

function EnvService:OnUnInit()
end

function EnvService:OnLogin()
  function self.onContainerDataChange(container, dirty)
    if dirty.resonances ~= nil then
      for id, value in pairs(dirty.resonances) do
        if value:IsNew() then
          self:ShowActiveTips(id)
        end
      end
    end
  end
  
  Z.ContainerMgr.CharSerialize.resonance.Watcher:RegWatcher(self.onContainerDataChange)
end

function EnvService:OnLogout()
  Z.ContainerMgr.CharSerialize.resonance.Watcher:UnregWatcher(self.onContainerDataChange)
  self.onContainerDataChange = nil
end

function EnvService:ShowActiveTips(resonanceId)
  local key = Z.ConstValue.PlayerPrefsKey.EnvActive .. Z.EntityMgr.PlayerUuid .. resonanceId
  local value = Z.LocalUserDataMgr.GetBool(key, false)
  Z.EventMgr:Dispatch(Z.ConstValue.OnEnvSkillCd, resonanceId)
  if not value then
    local envVM = Z.VMMgr.GetVM("env")
    envVM.OpenEnvWindowView()
    Z.LocalUserDataMgr.SetBool(key, true)
  end
end

return EnvService
