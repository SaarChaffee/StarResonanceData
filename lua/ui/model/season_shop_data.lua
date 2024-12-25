local super = require("ui.model.data_base")
local SeasonShopData = class("SeasonShopData", super)

function SeasonShopData:ctor()
  super.ctor(self)
end

function SeasonShopData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:Clear()
end

function SeasonShopData:Clear()
  self.curChoosePageId_ = nil
end

function SeasonShopData:SetCurChoosePage(id)
  self.curChoosePageId_ = id
end

function SeasonShopData:GetCurChoosePage()
  return self.curChoosePageId_ or 1
end

function SeasonShopData:UnInit()
  self.CancelSource:Recycle()
end

return SeasonShopData
