local SysDialogViewDataManager = class("SysDialogViewDataManager")
E.ESysDialogViewType = {
  OperationCenter = 1,
  GameImportant = 2,
  GameNormal = 3
}
E.ESysDialogOperationCenterOrder = {Normal = 1}
E.ESysDialogGameImportantOrder = {
  Normal = 1,
  Important = 2,
  LoginError = 3,
  KickOff = 99
}
E.ESysDialogGameNormalOrder = {Normal = 1, TencentChangeAccount = 2}

function SysDialogViewDataManager:ctor()
  self:initData()
  self.curShowDialogViewData_ = nil
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function SysDialogViewDataManager:ShowSysDialogView(type, sort, title, content, onConfirm, onCancel, isShowCancelBtn, labCertain, labCancel)
  local viewData = {
    type = type,
    sort = sort,
    title = title,
    content = content,
    onConfirm = onConfirm,
    onCancel = onCancel,
    isShowCancelBtn = isShowCancelBtn,
    labCertain = labCertain,
    labCancel = labCancel
  }
  local isInQueue = false
  if self.queueCount_[type] == 0 then
    table.insert(self.queue_[type], viewData)
    self.queueCount_[type] = self.queueCount_[type] + 1
  else
    local viewDataQueue = self.queue_[type]
    for key, data in ipairs(viewDataQueue) do
      if data.sort == sort and data.content == content then
        isInQueue = true
        break
      elseif sort < data.sort then
        table.insert(self.queue_[type], key, viewData)
        self.queueCount_[type] = self.queueCount_[type] + 1
        break
      end
    end
  end
  if not isInQueue and (self.curShowDialogViewData_ == nil or type < self.curShowDialogViewData_.type or type == self.curShowDialogViewData_.type and sort < self.curShowDialogViewData_.sort) then
    self.curShowDialogViewData_ = viewData
    Z.UIMgr:OpenView("sys_dialog", viewData)
  end
end

function SysDialogViewDataManager:ClearAll(isCloseView)
  self:initData()
  self.curShowDialogViewData_ = nil
  if isCloseView then
    Z.UIMgr:CloseView("sys_dialog")
  end
end

function SysDialogViewDataManager:initData()
  self.queue_ = {
    [E.ESysDialogViewType.OperationCenter] = {},
    [E.ESysDialogViewType.GameImportant] = {},
    [E.ESysDialogViewType.GameNormal] = {}
  }
  self.queueCount_ = {
    [E.ESysDialogViewType.OperationCenter] = 0,
    [E.ESysDialogViewType.GameImportant] = 0,
    [E.ESysDialogViewType.GameNormal] = 0
  }
end

function SysDialogViewDataManager:popSysDialogViewData()
  if self.curShowDialogViewData_ == nil then
    return
  end
  local type = self.curShowDialogViewData_.type
  table.remove(self.queue_[type], 1)
  self.queueCount_[type] = self.queueCount_[type] - 1
  self.queueCount_[type] = math.max(0, self.queueCount_[type])
  if self.queueCount_[type] > 0 then
    self.curShowDialogViewData_ = self.queue_[type][1]
    Z.UIMgr:OpenView("sys_dialog", self.curShowDialogViewData_)
  else
    self.curShowDialogViewData_ = nil
    for i = type + 1, E.ESysDialogViewType.GameNormal do
      if self.queueCount_[i] > 0 then
        self.curShowDialogViewData_ = self.queue_[i][1]
        Z.UIMgr:OpenView("sys_dialog", self.curShowDialogViewData_)
        break
      end
    end
  end
end

function SysDialogViewDataManager:onCloseViewEvent(viewConfigKey)
  if viewConfigKey == "sys_dialog" then
    self:popSysDialogViewData()
  end
end

return SysDialogViewDataManager
