local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local Result = class("Result", super)

function Result:ctor()
end

function Result:OnInit()
end

function Result:OnRefresh(data)
  self.uiBinder.tex_result.text = data
end

function Result:OnUnInit()
end

return Result
