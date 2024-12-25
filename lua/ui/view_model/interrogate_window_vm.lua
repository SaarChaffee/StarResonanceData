local InterrogateVm = {}

function InterrogateVm:OpenView(type)
  Z.UIMgr:OpenView("interrogate_window", type)
end

function InterrogateVm:CloseView()
  Z.UIMgr:CloseView("interrogate_window")
end

return InterrogateVm
