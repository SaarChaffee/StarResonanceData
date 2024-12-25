local AcquiretipsVM = {}

function AcquiretipsVM.ShowAcquireTips()
  local ui = Z.UIMgr:GetView("acquiretip")
  if ui == nil or not ui.IsActive then
    Z.UIMgr:OpenView("acquiretip")
  else
    Z.EventMgr:Dispatch(Z.ConstValue.ShowAcquireItemInfo)
  end
end

function AcquiretipsVM.CloseAcquireTipsView()
  Z.UIMgr:CloseView("acquiretip")
end

function AcquiretipsVM.IsHaveNeedShowTips()
  local tipsData = Z.DataMgr.Get("tips_data")
  return table.zcount(tipsData.AcquireTipsInfos) >= 1
end

return AcquiretipsVM
