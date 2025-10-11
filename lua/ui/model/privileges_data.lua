local super = require("ui.model.data_base")
local PrivilegesData = class("PrivilegesData", super)

function PrivilegesData:ctor()
  super.ctor(self)
end

function PrivilegesData:Init()
  self.privilegesData_ = {}
end

function PrivilegesData:Clear()
  self.privilegesData_ = {}
end

function PrivilegesData:UnInit()
end

function PrivilegesData:InitPrivilegesData(data)
  self.privilegesData_ = {}
  if data and table.zcount(data.allSourcePrivilegeEffectsMap) > 0 then
    for k, v in pairs(data.allSourcePrivilegeEffectsMap) do
      self.privilegesData_[k] = v
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.PrivilegesDataChanged)
end

function PrivilegesData:GetAllPrivilegesData()
  return self.privilegesData_
end

function PrivilegesData:GetPrivilegesDataByFunction(functionType, privilegesType)
  local privilegesData = self.privilegesData_[functionType]
  if privilegesData then
    for k, v in pairs(privilegesData.privilegeEffectsMap) do
      for i, j in pairs(v.privilegeEffectData) do
        if j.type == privilegesType then
          return j
        end
      end
    end
  end
  return nil
end

return PrivilegesData
