local super = require("ui.model.data_base")
local LifeCollectionData = class("LifeCollectionData", super)

function LifeCollectionData:ctor()
end

function LifeCollectionData:Init()
end

function LifeCollectionData:Clear()
end

function LifeCollectionData:UnInit()
end

function LifeCollectionData:OnLanguageChange()
  self.collectDatas = nil
end

function LifeCollectionData:GetCollectionDatas()
  if not self.collectDatas then
    self.collectDatas = Z.TableMgr.GetTable("LifeCollectListTableMgr").GetDatas()
  end
  return self.collectDatas
end

return LifeCollectionData
