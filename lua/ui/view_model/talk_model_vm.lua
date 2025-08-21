local openModelTalk = function(viewData)
  logGreen("[quest] openModelTalk")
  Z.UIMgr:OpenView("talk_model_window", viewData)
end
local closeModelTalk = function(isForce)
  if not Z.UIMgr:IsActive("talk_model_window") then
    Z.EPFlowBridge.OnModelTalkEnded()
  else
    local talkVM = Z.VMMgr.GetVM("talk")
    talkVM.CloseCommonTalkDialog()
    Z.EventMgr:Dispatch(Z.ConstValue.Talk.CloseModelUI)
    if isForce then
      Z.UIMgr:CloseView("talk_model_window")
      Z.EPFlowBridge.OnModelTalkEnded()
    else
      Z.UIMgr:OpenView("screeneffect", {
        effectType = Panda.ZUi.ZUIFadeType.FadeBlackToOut,
        effectFunc = function()
          Z.UIMgr:CloseView("talk_model_window")
          Z.EPFlowBridge.OnModelTalkEnded()
        end
      })
    end
  end
end
local ret = {OpenModelTalk = openModelTalk, CloseModelTalk = closeModelTalk}
return ret
