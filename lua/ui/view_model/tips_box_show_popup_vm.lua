local TipsBoxShowPopupVM = {}

function TipsBoxShowPopupVM.ShowTips(info)
  Z.UIMgr:OpenView("tips_box_show_popup", info)
end

return TipsBoxShowPopupVM
