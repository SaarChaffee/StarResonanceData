local TipsBroadcastVM = {}

function TipsBroadcastVM.AddBroadcast(vInfo)
  local broadcastData = Z.DataMgr.Get("tips_broadcast_data")
  broadcastData:AddBroadcast(vInfo)
  if Z.UIMgr:IsActive("tips_broadcast") then
    Z.EventMgr:Dispatch(Z.ConstValue.Broadcast.AddData)
  else
    Z.UIMgr:OpenView("tips_broadcast")
  end
end

return TipsBroadcastVM
