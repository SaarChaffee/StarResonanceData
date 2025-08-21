local super = require("ui.model.data_base")
local CookData = class("CookData", super)

function CookData:ctor()
  super.ctor(self)
  self:Clear()
end

function CookData:Init()
  self.CookMaterialData = {}
  self:InitCfgData()
end

function CookData:InitCfgData()
  self.CookMaterialTableDatas = Z.TableMgr.GetTable("CookMaterialTableMgr").GetDatas()
  local data = {}
  for k, v in pairs(self.CookMaterialTableDatas) do
    if not data[v.TypeB] then
      data[v.TypeB] = {}
    end
    data[v.TypeB][#data[v.TypeB] + 1] = v
  end
  self.CookMaterialData = data
end

function CookData:OnLanguageChange()
  self:InitCfgData()
end

function CookData:Clear()
end

return CookData
