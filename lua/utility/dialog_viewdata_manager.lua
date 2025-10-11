local DialogViewDataManager = class("DialogViewDataManager")

function DialogViewDataManager:ctor()
  self.queue_ = {}
  self.queueCount_ = 0
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function DialogViewDataManager:CheckAndOpenPreferencesDialog(desc, onConfirmFunc, onCancelFunc, preferencesType, preferencesKey, itemList, ignoreConfirmFunc)
  if self:CheckNeedShowDlg(preferencesType, preferencesKey) then
    local data = {
      dlgType = E.DlgType.YesNo,
      onConfirm = function()
        if onConfirmFunc ~= nil then
          onConfirmFunc()
        end
      end,
      onCancel = function()
        if onCancelFunc ~= nil then
          onCancelFunc()
        end
      end,
      labDesc = desc,
      dlgPreferencesType = preferencesType,
      preferencesKey = preferencesKey,
      itemList = itemList
    }
    self:OpenDialogView(data)
  elseif not ignoreConfirmFunc then
    Z.CoroUtil.create_coro_xpcall(function()
      onConfirmFunc()
    end)()
  end
end

function DialogViewDataManager:SetDlgPreferences(preferencesType, key)
  if key == nil then
    return
  end
  if preferencesType == E.DlgPreferencesType.Never then
    Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Account, key, true)
  elseif preferencesType == E.DlgPreferencesType.Login then
    local tipsData = Z.DataMgr.Get("tips_data")
    tipsData.DlgActivePreferences[key] = true
  elseif preferencesType == E.DlgPreferencesType.Time then
  elseif preferencesType == E.DlgPreferencesType.Day then
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Account, key, math.floor(Z.ServerTime:GetServerTime() / 1000))
  end
  Z.LocalUserDataMgr.Save()
end

function DialogViewDataManager:CheckNeedShowDlg(preferencesType, data)
  if preferencesType == E.DlgPreferencesType.Never then
    if not data then
      return true
    end
    return not Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Account, data, false)
  elseif preferencesType == E.DlgPreferencesType.Login then
    local tipsData = Z.DataMgr.Get("tips_data")
    if tipsData.DlgActivePreferences[data] then
      return false
    else
      return true
    end
  elseif preferencesType == E.DlgPreferencesType.Time then
  elseif preferencesType == E.DlgPreferencesType.Day then
    if not data then
      return true
    end
    local time = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Account, data)
    if time ~= "" then
      return not Z.TimeTools.CheckIsSameDay(time, math.floor(Z.ServerTime:GetServerTime() / 1000))
    end
    return true
  else
    return true
  end
end

function DialogViewDataManager:OpenOKDialogWithTitle(title, desc, onConfirm)
  local dialogViewData = {
    dlgType = E.DlgType.OK,
    labTitle = title,
    labDesc = desc,
    onConfirm = onConfirm
  }
  self:OpenDialogView(dialogViewData)
end

function DialogViewDataManager:OpenOKDialog(desc, onConfirm)
  self:OpenOKDialogWithTitle(nil, desc, onConfirm)
end

function DialogViewDataManager:OpenRechargePreviewOKDialog(rechargeName, symbol, oldPrice, curPrice, itemList)
  local desc = ""
  if oldPrice and curPrice then
    desc = string.format("%s %s %s %s %s", rechargeName, Lang("RechargePrice"), symbol, string.format("<s>%s</s>", oldPrice), curPrice)
  elseif curPrice then
    desc = string.format("%s %s %s %s", rechargeName, Lang("RechargePrice"), symbol, curPrice)
  else
    desc = string.format("%s  %s", rechargeName, Lang("Free"))
  end
  local dialogViewData = {
    dlgType = E.DlgType.OK,
    labTitle = Lang("RewardPreview"),
    labDesc = desc,
    itemList = itemList
  }
  self:OpenDialogView(dialogViewData)
end

function DialogViewDataManager:OpenNormalItemsDialog(desc, onConfirm, onCancel, itemList)
  local textAnchor
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = desc,
    onConfirm = onConfirm,
    onCancel = onCancel,
    itemList = itemList,
    textAnchor = textAnchor
  }
  self:OpenDialogView(dialogViewData)
end

function DialogViewDataManager:OpenNormalDialog(desc, onConfirm, onCancel)
  self:OpenNormalItemsDialog(desc, onConfirm, onCancel)
end

function DialogViewDataManager:OpenCountdownOKDialog(desc, onConfirm, onCancel, countdown, countDownCanClick)
  local dialogViewData = {
    dlgType = E.DlgType.CountdownYes,
    labDesc = desc,
    onConfirm = onConfirm,
    onCancel = onCancel,
    countdown = countdown,
    countDownCanClick = countDownCanClick
  }
  self:OpenDialogView(dialogViewData)
end

function DialogViewDataManager:OpenCountdownNODialog(desc, onConfirm, onCancel, countdown, countDownCanClick)
  local dialogViewData = {
    dlgType = E.DlgType.CountdownNo,
    labDesc = desc,
    onConfirm = onConfirm,
    onCancel = onCancel,
    countdown = countdown,
    countDownCanClick = countDownCanClick
  }
  self:OpenDialogView(dialogViewData)
end

function DialogViewDataManager:OpenDialogView(viewData)
  self:AddDialogViewData(viewData)
end

function DialogViewDataManager:CloseDialogView()
  Z.UIMgr:CloseView("dialog")
end

function DialogViewDataManager:OpenCenterControlDialog(viewData)
  self:AddDialogViewData(viewData)
end

function DialogViewDataManager:AddDialogViewData(viewData)
  local needOpenView = false
  if self.queueCount_ == 0 then
    needOpenView = true
  end
  table.insert(self.queue_, viewData)
  self.queueCount_ = self.queueCount_ + 1
  if needOpenView then
    Z.UIMgr:OpenView("dialog", viewData)
  end
end

function DialogViewDataManager:ClearAll()
  self.queue_ = {}
  self.queueCount_ = 0
end

function DialogViewDataManager:popDialogViewData()
  if self.queueCount_ <= 0 then
    return
  end
  table.remove(self.queue_, 1)
  self.queueCount_ = self.queueCount_ - 1
  if self.queueCount_ > 0 then
    Z.UIMgr:OpenView("dialog", self.queue_[1])
  end
end

function DialogViewDataManager:onCloseViewEvent(viewConfigKey)
  if viewConfigKey == "dialog" then
    self:popDialogViewData()
  end
end

return DialogViewDataManager
