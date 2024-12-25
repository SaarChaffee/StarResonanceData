local super = require("ui.model.data_base")
local PlayerCtrlBtnsData = class("PlayerCtrlBtnsData", super)

function PlayerCtrlBtnsData:ctor()
  super.ctor(self)
  self.ctrlDatas = {}
end

return PlayerCtrlBtnsData
