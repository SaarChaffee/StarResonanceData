local super = require("ui.model.data_base")
local CookData = class("CookData", super)

function CookData:ctor()
  super.ctor(self)
  self:Clear()
end

function CookData:Init()
  self.CookMaterialData = {}
  self.DefaultUnlockCookIds = {}
  self:InitCfgData()
end

function CookData:InitCfgData()
  self.CookRecipeTableRows = Z.TableMgr.GetTable("CookRecipeTableMgr").GetDatas()
  self.CookMaterialTableDatas = Z.TableMgr.GetTable("CookMaterialTableMgr").GetDatas()
end

function CookData:OnLanguageChange()
  self:InitCfgData()
end

function CookData:Clear()
end

return CookData
