local DialogViewDataManager = class("DialogViewDataManager")

function DialogViewDataManager:ctor()
  self.queue_ = {}
  self.curShowDialogType = nil
  self.onlyReceivedSystemViewData = false
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function DialogViewDataManager:CheckAndOpenPreferencesDialog(desc, onConfirmFunc, onCancelFunc, preferencesType, preferencesKey, itemList)
  if self:CheckNeedShowDlg(preferencesType, preferencesKey) then
    local data = {
      dlgType = E.DlgType.YesNo,
      onConfirm = function()
        if onConfirmFunc ~= nil then
          onConfirmFunc()
        end
        self:CloseDialogView()
      end,
      onCancel = function()
        if onCancelFunc ~= nil then
          onCancelFunc()
        end
        self:CloseDialogView()
      end,
      labDesc = desc,
      dlgPreferencesType = preferencesType,
      preferencesKey = preferencesKey,
      itemList = itemList
    }
    self:OpenDialogView(data, E.EDialogViewDataType.Game)
  else
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
    Z.LocalUserDataMgr.SetBool(key, true)
  elseif preferencesType == E.DlgPreferencesType.Login then
    local tipsData = Z.DataMgr.Get("tips_data")
    tipsData.DlgActivePreferences[key] = true
  elseif preferencesType == E.DlgPreferencesType.Time then
  elseif preferencesType == E.DlgPreferencesType.Day then
    Z.LocalUserDataMgr.SetString(key, math.floor(Z.ServerTime:GetServerTime() / 1000))
  end
end

function DialogViewDataManager:CheckNeedShowDlg(preferencesType, data)
  if preferencesType == E.DlgPreferencesType.Never then
    if not data then
      return true
    end
    return not Z.LocalUserDataMgr.GetBool(data, false)
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
    local time = Z.LocalUserDataMgr.GetString(data)
    if time ~= "" then
      return not Z.TimeTools.CheckIsSameDay(time, math.floor(Z.ServerTime:GetServerTime() / 1000))
    end
    return true
  else
    return true
  end
end

function DialogViewDataManager:OpenOKDialogWithTitle(title, desc, onConfirm, type, onlyReceivedSys)
  if type == nil then
    type = E.EDialogViewDataType.Game
  end
  local dialogViewData = {
    dlgType = E.DlgType.OK,
    labTitle = title,
    labDesc = desc,
    onConfirm = onConfirm,
    type = type
  }
  self:OpenDialogView(dialogViewData, type, onlyReceivedSys)
end

function DialogViewDataManager:OpenOKDialog(desc, onConfirm, type, onlyReceivedSys)
  self:OpenOKDialogWithTitle(nil, desc, onConfirm, type, onlyReceivedSys)
end

function DialogViewDataManager:OpenNormalItemsDialog(desc, onConfirm, onCancel, itemList, type, onlyReceivedSys)
  local textAnchor
  if itemList ~= nil then
    textAnchor = TMPro.TextAlignmentOptions.TopLeft
  end
  if type == nil then
    type = E.EDialogViewDataType.Game
  end
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = desc,
    onConfirm = onConfirm,
    onCancel = onCancel,
    itemList = itemList,
    textAnchor = textAnchor,
    type = type
  }
  self:OpenDialogView(dialogViewData, type, onlyReceivedSys)
end

function DialogViewDataManager:OpenNormalDialog(desc, onConfirm, onCancel, type, onlyReceivedSys)
  self:OpenNormalItemsDialog(desc, onConfirm, onCancel, nil, type, onlyReceivedSys)
end

function DialogViewDataManager:OpenCountdownOKDialog(desc, onConfirm, onCancel, countdown, countDownCanClick)
  local dialogViewData = {}
  dialogViewData.dlgType = E.DlgType.CountdownYes
  dialogViewData.labDesc = desc
  dialogViewData.onConfirm = onConfirm
  dialogViewData.onCancel = onCancel
  dialogViewData.countdown = countdown
  dialogViewData.countDownCanClick = countDownCanClick
  self:OpenDialogView(dialogViewData, E.EDialogViewDataType.Game, false)
end

function DialogViewDataManager:OpenCountdownNODialog(desc, onConfirm, onCancel, countdown, countDownCanClick)
  local dialogViewData = {}
  dialogViewData.dlgType = E.DlgType.CountdownNo
  dialogViewData.labDesc = desc
  dialogViewData.onConfirm = onConfirm
  dialogViewData.onCancel = onCancel
  dialogViewData.countdown = countdown
  dialogViewData.countDownCanClick = countDownCanClick
  self:OpenDialogView(dialogViewData, E.EDialogViewDataType.Game, false)
end

function DialogViewDataManager:OpenDialogView(viewData, dialogType, onlyReceivedSys)
  self:AddDialogViewData(viewData, dialogType, onlyReceivedSys)
end

function DialogViewDataManager:CloseDialogView()
  Z.UIMgr:CloseView("dialog")
end

function DialogViewDataManager:OpenCenterControlDialog(viewData)
  self:AddDialogViewData(viewData, E.EDialogViewDataType.System, true, true)
end

function DialogViewDataManager:AddDialogViewData(viewData, dialogType, onlyReceivedSys, showImmediately)
  if self.queue_[dialogType] == nil then
    self.queue_[dialogType] = {}
  end
  local needOpenView = false
  if dialogType == E.EDialogViewDataType.System then
    if onlyReceivedSys then
      self.onlyReceivedSystemViewData = true
      for type in pairs(self.queue_) do
        if type ~= E.EDialogViewDataType.System then
          self.queue_[type] = {}
        end
      end
    end
    needOpenView = self.curShowDialogType == nil or self.curShowDialogType ~= E.EDialogViewDataType.System
    self.curShowDialogType = E.EDialogViewDataType.System
  elseif dialogType == E.EDialogViewDataType.Game then
    if self.onlyReceivedSystemViewData then
      logError("\229\189\147\229\137\141\230\151\160\230\179\149\230\183\187\229\138\160Game\231\186\167\229\136\171Dialog\232\191\155\229\133\165\229\177\149\231\164\186\233\152\159\229\136\151")
      return
    end
    if self.curShowDialogType == nil then
      self.curShowDialogType = E.EDialogViewDataType.Game
      needOpenView = true
    end
  end
  if showImmediately then
    needOpenView = true
    table.insert(self.queue_[dialogType], 1, viewData)
  else
    table.insert(self.queue_[dialogType], viewData)
  end
  if needOpenView then
    Z.UIMgr:OpenView("dialog", viewData)
  end
end

function DialogViewDataManager:PopDialogViewData()
  if self.curShowDialogType then
    table.remove(self.queue_[self.curShowDialogType], 1)
    if #self.queue_[self.curShowDialogType] == 0 then
      if self.curShowDialogType == E.EDialogViewDataType.System then
        self.onlyReceivedSystemViewData = false
      end
      self.curShowDialogType = nil
      for type, value in pairs(self.queue_) do
        if 0 < #value then
          self.curShowDialogType = type
          Z.UIMgr:OpenView("dialog", value[1])
        end
      end
    else
      Z.UIMgr:OpenView("dialog", self.queue_[self.curShowDialogType][1])
    end
  end
end

function DialogViewDataManager:ClearDialogViewData(dialogType)
  if self.curShowDialogType and self.curShowDialogType == dialogType then
    local tempViewData = self.queue_[dialogType][1]
    self.queue_[dialogType] = {}
    table.insert(self.queue_[dialogType], tempViewData)
  else
    self.queue_[dialogType] = {}
  end
end

function DialogViewDataManager:ClearAll()
  self.queue_ = {}
  self.curShowDialogType = nil
  self.onlyReceivedSystemViewData = false
end

function DialogViewDataManager:GetDialogViewDataCount(dialogType)
  return self.queue_[dialogType] == nil and 0 or #self.queue_[dialogType]
end

function DialogViewDataManager:IsEmpty(dialogType)
  return self.queue_[dialogType] == nil or #self.queue_[dialogType] == 0
end

function DialogViewDataManager:onCloseViewEvent(viewConfigKey)
  if viewConfigKey == "dialog" then
    self:PopDialogViewData()
  end
end

return DialogViewDataManager
