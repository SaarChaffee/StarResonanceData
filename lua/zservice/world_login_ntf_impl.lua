local pb = require("pb2")
local WorldLoginNtfStubImpl = {}

function WorldLoginNtfStubImpl:OnCreateStub()
end

function WorldLoginNtfStubImpl:NotifyInstructionInfo(call, vInfo)
  logError("[NotifyInstructionInfo]" .. table.ztostring(vInfo))
  local loginVM = Z.VMMgr.GetVM("login")
  local onConfirm
  if vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_Tips") then
  elseif vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_Logout") then
    function onConfirm()
      if Z.GameContext.IsPC == true and Z.GameContext.IsEditor == false then
        Z.GameContext.QuitGame()
      else
        loginVM:KickOffByClient(E.KickOffClientErrCode.UnderageLimit)
      end
    end
  elseif vInfo.type == Z.PbEnum("EInstructionType", "InstructionType_OpenUrl") then
    function onConfirm()
      xpcall(function()
        local isModal = vInfo.modal == 1
        
        local jsonStr
        if isModal then
          jsonStr = "{\"url\": \"" .. vInfo.url .. "\", \"show_titlebar\": \"0\", \"show_title\": \"0\", \"buttons\": [] }"
        else
          jsonStr = "{\"url\": \"" .. vInfo.url .. "\", \"show_titlebar\": \"0\", \"show_title\": \"0\", \"buttons\": [{\"buttonId\": \"1\", \"name\": \"\232\191\148\229\155\158\230\184\184\230\136\143\", \"action\": \"0\"}] }"
        end
        Z.SDKTencent.OpenAntiAddictionPage(jsonStr, function()
          if isModal then
            loginVM:Logout(true)
          end
        end)
      end, function(msg)
        logError("[NotifyInstructionInfo] InstructionType_OpenUrl Error : " .. msg)
      end)
    end
  end
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.OperationCenter, E.ESysDialogOperationCenterOrder.Normal, vInfo.title, vInfo.msg, onConfirm)
  if vInfo.type ~= Z.PbEnum("EInstructionType", "InstructionType_Logout") then
    Z.CoroUtil.create_coro_xpcall(function()
      local accountData = Z.DataMgr.Get("account_data")
      loginVM:AsyncReportMSDK(accountData.OpenID, vInfo.ruleName, vInfo.traceId)
    end)()
  end
end

return WorldLoginNtfStubImpl
