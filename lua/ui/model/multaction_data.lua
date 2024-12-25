local super = require("ui.model.data_base")
local MultActionData = class("MultActionData", super)

function MultActionData:ctor()
  super.ctor(self)
  self.SelectInviteId = 0
  self.BeInviteId = 0
  self.ActionType = E.MultActionType.Null
end

return MultActionData
