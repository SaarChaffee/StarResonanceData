local openModelTalk = function(viewData)
  Z.UIMgr:OpenView("talk_model_window", viewData)
end
local closeModelTalk = function(isForce)
  if not Z.UIMgr:IsActive("talk_model_window") then
    Z.EPFlowBridge.OnModelTalkEnded()
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Talk.CloseModelUI)
    if isForce then
      Z.UIMgr:CloseView("talk_model_window")
      Z.EPFlowBridge.OnModelTalkEnded()
    else
      Z.UIMgr:OpenView("screeneffect", {
        effectname = "fade_black2out",
        effectfunc = function()
          Z.UIMgr:CloseView("talk_model_window")
          Z.EPFlowBridge.OnModelTalkEnded()
        end
      })
    end
  end
end
local ret = {OpenModelTalk = openModelTalk, CloseModelTalk = closeModelTalk}
return ret
