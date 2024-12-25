local worldProxy = require("zproxy.world_proxy")
local openView = function()
  Z.UIMgr:OpenView("investigation_clue_window")
end
local asyncSelectReasoning = function(investigationId, stepId, reasoningId, answerId, cancelToken)
  local ret = worldProxy.SelectReasoning(investigationId, stepId, reasoningId, answerId, cancelToken)
  return ret
end
local ret = {OpenView = openView, AsyncSelectReasoning = asyncSelectReasoning}
return ret
