local super = require("ui.model.data_base")
local UnionTaskData = class("UnionTaskData", super)

function UnionTaskData:ctor()
end

function UnionTaskData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function UnionTaskData:Clear()
end

function UnionTaskData:UnInit()
  self.CancelSource:Recycle()
end

return UnionTaskData
