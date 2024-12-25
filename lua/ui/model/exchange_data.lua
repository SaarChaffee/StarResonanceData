local super = require("ui.model.data_base")
local ExchangeData = class("ExchangeData", super)

function ExchangeData:ctor()
  super.ctor(self)
end

function ExchangeData:Init()
  self:InitCfgData()
end

function ExchangeData:InitCfgData()
  self.ExchangeItemTableDatas = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetDatas()
end

function ExchangeData:Clear()
end

function ExchangeData:OnLanguageChange()
  self:InitCfgData()
end

function ExchangeData:OnInit()
end

return ExchangeData
