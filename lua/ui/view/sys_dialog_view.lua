local UI = Z.UI
local super = require("ui.ui_view_base")
local SysDialogView = class("SysDialogView", super)

function SysDialogView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "sys_dialog")
  self.defaultDesc_ = ""
  self.isWaitingNet_ = false
  
  function self.onConfirmFunc_()
    if self.isWaitingNet_ then
      return
    end
    if self.viewData.onConfirm then
      self.isWaitingNet_ = true
      xpcall(function()
        self.viewData.onConfirm(self.cancelSource:CreateToken())
      end, function(err)
        if err ~= ZUtil.ZCancelSource.CancelException then
          logError("SysDialogView Confirm error : " .. tostring(err))
        end
      end)
    end
    self.isWaitingNet_ = false
    Z.UIMgr:CloseView("sys_dialog")
  end
  
  function self.onCancelFunc_()
    if self.isWaitingNet_ then
      return
    end
    if self.viewData.onCancel then
      self.isWaitingNet_ = true
      xpcall(function()
        self.viewData.onCancel(self.cancelSource:CreateToken())
      end, function(err)
        if err ~= ZUtil.ZCancelSource.CancelException then
          logError("SysDialogView Cancel error : " .. tostring(err))
        end
      end)
    end
    self.isWaitingNet_ = false
    Z.UIMgr:CloseView("sys_dialog")
  end
  
  self.IsResponseInput = false
end

function SysDialogView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.uibinder_confirm.btn, self.onConfirmFunc_)
  self:AddAsyncClick(self.uiBinder.uibinder_cancel.btn, self.onCancelFunc_)
end

function SysDialogView:OnRefresh()
  self.isWaitingNet_ = false
  if self.viewData.title then
    self.uiBinder.lab_title.text = self.viewData.title
  else
    self.uiBinder.lab_title.text = Lang("DialogDefaultTitle")
  end
  if self.viewData.content then
    self.uiBinder.lab_content.text = self.viewData.content
  else
    self.uiBinder.lab_content.text = self.defaultDesc_
  end
  if self.viewData.isShowCancelBtn then
    self.uiBinder.uibinder_cancel.Ref.UIComp:SetVisible(true)
  else
    self.uiBinder.uibinder_cancel.Ref.UIComp:SetVisible(false)
  end
  if self.viewData.labCertain then
    self.uiBinder.uibinder_confirm.lab_normal.text = self.viewData.labCertain
  else
    self.uiBinder.uibinder_confirm.lab_normal.text = Lang("BtnYes")
  end
  if self.viewData.labCancel then
    self.uiBinder.uibinder_cancel.lab_normal.text = self.viewData.labCancel
  else
    self.uiBinder.uibinder_cancel.lab_normal.text = Lang("BtnNo")
  end
end

function SysDialogView:OnDeActive()
end

return SysDialogView
