local UI = Z.UI
local super = require("ui.ui_view_base")
local DialogView = class("DialogView", super)
local dialog_loop_item = require("ui.component.dialog.dialog_loop_item")
local loopGridView = require("ui/component/loop_grid_view")
local CENTE_COUNT = 5

function DialogView:ctor()
  self.uiBinder = nil
  self.viewData = {}
  super.ctor(self, "dialog")
  self.defaultTitle = Lang("DialogDefaultTitle")
  self.defaultDesc = ""
  self.isWaitingNet_ = false
  
  function self.onConfirmFunc_()
    if self.isWaitingNet_ then
      Z.TipsVM.ShowTips(1001500)
      return
    end
    self:setPreferences()
    if self.viewData.onConfirm then
      self.isWaitingNet_ = true
      xpcall(function()
        self.viewData.onConfirm(self.cancelSource:CreateToken())
      end, function(err)
        if err ~= ZUtil.ZCancelSource.CancelException then
          logError("DialogView Confirm error : " .. tostring(err))
        end
      end)
    end
    self.isWaitingNet_ = false
    Z.DialogViewDataMgr:CloseDialogView()
  end
  
  function self.onCancelFunc_()
    if self.isWaitingNet_ then
      Z.TipsVM.ShowTips(1001500)
      return
    end
    self:setPreferences()
    if self.viewData.onCancel then
      self.isWaitingNet_ = true
      xpcall(function()
        self.viewData.onCancel(self.cancelSource:CreateToken())
      end, function(err)
        if err ~= ZUtil.ZCancelSource.CancelException then
          logError("DialogView Cancel error : " .. tostring(err))
        end
      end)
    end
    self.isWaitingNet_ = false
    Z.DialogViewDataMgr:CloseDialogView()
  end
end

function DialogView:initUiBinders()
  self.SceneMask_ = self.uiBinder.scenemask
  self.titleLab_ = self.uiBinder.lab_title
  self.contentLab_ = self.uiBinder.lab_content
  self.cancelBinder_ = self.uiBinder.btn_cancel
  self.confirmBinder_ = self.uiBinder.btn_confirm
  self.loopscroll_reward_list_ = self.uiBinder.loopscroll_reward_list
  self.node_content_ = self.uiBinder.node_content
  self.itemTog_ = self.uiBinder.tog_item
  self.lab_notice_ = self.uiBinder.lab_notice
  self.toggleNode_ = self.uiBinder.com_toggle
  self.nodeLoop_ = self.uiBinder.node_loop
  self.SceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function DialogView:OnActive()
  self:initUiBinders()
  self.itemScrollRect_ = loopGridView.new(self, self.loopscroll_reward_list_, dialog_loop_item, "com_item_square_1_8")
  self.itemScrollRect_:Init({})
  self.uiBinder.Ref:SetVisible(self.toggleNode_, false)
end

function DialogView:OnRefresh()
  self.defaultLabOK = Lang("BtnOK")
  self.defaultLabYes = Lang("BtnYes")
  self.defaultLabNo = Lang("BtnNo")
  self.isWaitingNet_ = false
  if self.viewData and self.viewData.dlgType then
    self.uiLayer = UI.ELayer.UILayerTop
    self.uiType = UI.EType.Standalone
    if self.viewData.labTitle then
      self.titleLab_.text = self.viewData.labTitle
    else
      self.titleLab_.text = self.defaultTitle
    end
    if self.viewData.labDesc then
      self.uiBinder.Ref:SetVisible(self.contentLab_, true)
      self.contentLab_.text = string.gsub(self.viewData.labDesc, "<br>", "\n")
    else
      self.uiBinder.Ref:SetVisible(self.contentLab_, false)
      self.contentLab_.text = self.defaultDesc
    end
    local textAnchor = self.viewData.textAnchor or TMPro.TextAlignmentOptions.Center
    self.contentLab_.alignment = textAnchor
    local showConfirmBtn_ = self.viewData.dlgType == E.DlgType.OK or self.viewData.dlgType == E.DlgType.YesNo or self.viewData.dlgType == E.DlgType.CountdownNo or self.viewData.dlgType == E.DlgType.CountdownYes
    local showCancelBtn_ = self.viewData.dlgType == E.DlgType.YesNo or self.viewData.dlgType == E.DlgType.CountdownNo or self.viewData.dlgType == E.DlgType.CountdownYes
    self.confirmBinder_.Ref.UIComp:SetVisible(showConfirmBtn_)
    self.cancelBinder_.Ref.UIComp:SetVisible(showCancelBtn_)
    self:setConfirmBtnInteractable(true)
    self:setCancelBtnInteractable(true)
    local confirmBtnContent = self.defaultLabYes
    local cancelBtnContent = self.defaultLabNo
    if self.viewData.dlgType == E.DlgType.OK then
      confirmBtnContent = self.viewData.labOK or self.defaultLabOK
    elseif self.viewData.dlgType == E.DlgType.YesNo then
      cancelBtnContent = self.viewData.labNo or self.defaultLabNo
      confirmBtnContent = self.viewData.labYes or self.defaultLabYes
    elseif self.viewData.dlgType == E.DlgType.CountdownYes then
      cancelBtnContent = self.viewData.labNo or self.defaultLabNo
      local confirmBtnContentTemp_ = self.viewData.labYes or self.defaultLabYes
      confirmBtnContent = confirmBtnContentTemp_ .. "(" .. Z.TimeFormatTools.FormatToDHMS(self.viewData.countdown, true) .. ")"
      local countDownCanClick = self.viewData.countDownCanClick and self.viewData.countDownCanClick or false
      self:setConfirmBtnInteractable(countDownCanClick)
      local count_ = self.viewData.countdown - 1
      self.seasonTimer_ = self.timerMgr:StartTimer(function()
        self:setConfirmBtnContent(confirmBtnContentTemp_ .. "(" .. Z.TimeFormatTools.FormatToDHMS(count_, true) .. ")")
        count_ = count_ - 1
        if count_ < 0 and self.viewData and self.viewData.countDownConfirmFunc then
          Z.CoroUtil.create_coro_xpcall(function()
            self.viewData.countDownConfirmFunc()
            Z.DialogViewDataMgr:CloseDialogView()
          end)()
        end
      end, 1, self.viewData.countdown, nil, function()
        self:setConfirmBtnInteractable(true)
        self:setConfirmBtnContent(confirmBtnContentTemp_)
      end)
    elseif self.viewData.dlgType == E.DlgType.CountdownNo then
      local cancelBtnContentTemp_ = self.viewData.labNo or self.defaultLabNo
      cancelBtnContent = cancelBtnContentTemp_ .. "(" .. Z.TimeFormatTools.FormatToDHMS(self.viewData.countdown, true) .. ")"
      confirmBtnContent = self.viewData.labYes or self.defaultLabYes
      local countDownCanClick = self.viewData.countDownCanClick and self.viewData.countDownCanClick or false
      self:setCancelBtnInteractable(countDownCanClick)
      local count_ = self.viewData.countdown - 1
      self.seasonTimer_ = self.timerMgr:StartTimer(function()
        count_ = count_ - 1
        self:setCancelBtnContent(cancelBtnContentTemp_ .. "(" .. Z.TimeFormatTools.FormatToDHMS(count_, true) .. ")")
      end, 1, self.viewData.countdown, nil, function()
        self:setCancelBtnInteractable(true)
        self:setCancelBtnContent(cancelBtnContentTemp_)
      end)
    end
    self:setConfirmBtnContent(confirmBtnContent)
    self:setCancelBtnContent(cancelBtnContent)
    self:AddAsyncClick(self.confirmBinder_.btn, self.onConfirmFunc_)
    self:AddAsyncClick(self.cancelBinder_.btn, self.onCancelFunc_)
    self:refreshPreferencesTog()
    self:refreshItemList()
  else
    logError("DialogView viewData or viewData.dlgType is nil")
    self.uiBinder.Ref:SetVisible(self.contentLab_, false)
    self.contentLab_.text = self.defaultDesc
    self.confirmBinder_.Ref.UIComp:SetVisible(true)
    self.cancelBinder_.Ref.UIComp:SetVisible(false)
    self:AddAsyncClick(self.confirmBinder_.btn, self.onCancelFunc_)
  end
  self:SetBtnImage()
  self.node_content_:ForceRebuildLayoutImmediate()
end

function DialogView:setConfirmBtnInteractable(interactable)
  self.confirmBinder_.btn.interactable = interactable
  self.confirmBinder_.btn.IsDisabled = not interactable
end

function DialogView:setCancelBtnInteractable(interactable)
  self.cancelBinder_.btn.interactable = interactable
  self.cancelBinder_.btn.IsDisabled = not interactable
end

function DialogView:setConfirmBtnContent(confirmBtnContent)
  self.confirmBinder_.lab_normal.text = confirmBtnContent
end

function DialogView:setCancelBtnContent(cancelBtnContent)
  self.cancelBinder_.lab_normal.text = cancelBtnContent
end

function DialogView:SetBtnImage()
  if not self.viewData then
    return
  end
end

function DialogView:refreshPreferencesTog()
  local tog = self.itemTog_
  if self.viewData.dlgPreferencesType == nil or self.viewData.dlgPreferencesType == E.DlgPreferencesType.None then
    tog:RemoveAllListeners()
    self.uiBinder.Ref:SetVisible(self.toggleNode_, false)
    self.itemTog_.isOn = false
  else
    local preferencesDes = ""
    if self.viewData.dlgPreferencesType == E.DlgPreferencesType.Never then
      preferencesDes = Lang("NoMoreTipsForever")
    elseif self.viewData.dlgPreferencesType == E.DlgPreferencesType.Login then
      preferencesDes = Lang("NoMoreTipsForThisLogin")
    elseif self.viewData.dlgPreferencesType == E.DlgPreferencesType.Day then
      preferencesDes = Lang("ActiveMuteNotify")
    end
    self.uiBinder.Ref:SetVisible(self.toggleNode_, true)
    tog.isOn = false
    self.lab_notice_.text = preferencesDes
  end
end

function DialogView:setPreferences()
  if self.viewData.dlgPreferencesType and self.viewData.dlgPreferencesType ~= E.DlgPreferencesType.None and self.itemTog_.isOn then
    Z.DialogViewDataMgr:SetDlgPreferences(self.viewData.dlgPreferencesType, self.viewData.preferencesKey)
  end
end

function DialogView:refreshItemList()
  if not self.viewData.itemList or table.zcount(self.viewData.itemList) == 0 then
    self.uiBinder.Ref:SetVisible(self.nodeLoop_, false)
  else
    self.uiBinder.Ref:SetVisible(self.nodeLoop_, true)
    if #self.viewData.itemList > CENTE_COUNT then
      self.itemScrollRect_:SetIsCenter(false)
    else
      self.itemScrollRect_:SetIsCenter(true)
    end
    self.itemScrollRect_:RefreshListView(self.viewData.itemList)
  end
end

function DialogView:OnDeActive()
  self.viewData = nil
  if self.seasonTimer_ then
    self.timerMgr.StopTimer(self.seasonTimer_)
  end
  self.itemScrollRect_:UnInit()
  self.itemScrollRect_ = nil
end

function DialogView:OnInputBack()
  if self.IsResponseInput then
    if self.viewData.dlgType == E.DlgType.OK then
      Z.CoroUtil.create_coro_xpcall(function()
        self.onConfirmFunc_()
      end)()
    elseif self.viewData.dlgType == E.DlgType.YesNo then
      Z.CoroUtil.create_coro_xpcall(function()
        self.onCancelFunc_()
      end)()
    end
  end
end

function DialogView:OnTriggerInputAction(inputActionEventData)
  if not Z.PlayerInputController:IsGamepadComboValidForAction(inputActionEventData) then
    return
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.Cancel then
    self:OnInputBack()
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.Confirm then
    Z.CoroUtil.create_coro_xpcall(function()
      self.onConfirmFunc_()
    end)()
  end
end

return DialogView
