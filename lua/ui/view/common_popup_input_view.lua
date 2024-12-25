local UI = Z.UI
local super = require("ui.ui_view_base")
local Common_popup_inputView = class("Common_popup_inputView", super)

function Common_popup_inputView:ctor()
  self.uiBinder = nil
  super.ctor(self, "common_popup_input")
  self.viewData = nil
end

function Common_popup_inputView:OnActive()
  self:AddClick(self.uiBinder.btn_cancel, function()
    if self.viewData and self.viewData.onCancel then
      self.viewData.onCancel()
    end
    self:close()
  end)
  self.inputlongtipsStr_ = Lang("CommonPopupInputTooLong")
  self.inputshorttipsStr_ = Lang("CommonPopupInputZero")
  self.uiBinder.sceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.input_field:SetTextWithoutNotify("")
  if self.viewData.isMultiLine then
    self.uiBinder.input_ref:SetHeight(176)
    self.uiBinder.lab_input.alignment = TMPro.TextAlignmentOptions.TopLeft
  else
    self.uiBinder.input_ref:SetHeight(54)
    self.uiBinder.lab_input.alignment = TMPro.TextAlignmentOptions.Midline
  end
end

function Common_popup_inputView:OnDeActive()
end

function Common_popup_inputView:OnRefresh()
  if self.viewData.title and self.viewData.title ~= "" then
    self.uiBinder.lab_title.text = self.viewData.title
  else
    self.uiBinder.lab_title.text = Lang("commonPopUpInputDefaultTitle")
  end
  if self.viewData.inputContent then
    self.uiBinder.input_field:SetTextWithoutNotify(self.viewData.inputContent)
  end
  if self.viewData.inputDesc then
    self.uiBinder.lab_default.text = self.viewData.inputDesc
  else
    self.uiBinder.lab_default.text = ""
  end
  if self.viewData.inputlongtipsStr and self.viewData.inputlongtipsStr ~= "" then
    self.inputlongtipsStr_ = self.viewData.inputlongtipsStr
  end
  if self.viewData.inputshorttipsStr and self.viewData.inputshorttipsStr ~= "" then
    self.inputshorttipsStr_ = self.viewData.inputshorttipsStr
  end
  if self.viewData.stringLengthLimitNum and self.viewData.stringLengthLimitNum > 0 then
    local inputLength = self.uiBinder.input_field:CalculatePlaces()
    self:refreshInputLimitShow(inputLength)
  else
    self.uiBinder.lab_num.text = ""
    self.uiBinder.lab_desc.text = ""
    self.uiBinder.btn_affirm.IsDisabled = false
    self.uiBinder.btn_affirm.interactable = true
  end
  self.uiBinder.input_field:AddListener(function(string)
    local inputLength = string.zlen(string)
    self:refreshInputLimitShow(inputLength)
  end)
  self:AddAsyncClick(self.uiBinder.btn_affirm, function()
    local inputLength = self.uiBinder.input_field:CalculatePlaces()
    if inputLength == 0 then
      if self.viewData.isCanInputEmpty == nil or self.viewData.isCanInputEmpty == false then
        return
      end
    elseif self.viewData.stringLengthLimitNum and inputLength > self.viewData.stringLengthLimitNum then
      return
    end
    if self.viewData.onConfirm then
      local errCode = self.viewData.onConfirm(self.uiBinder.input_field.text)
      if errCode and errCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
        self.uiBinder.lab_desc.text = Lang("ErrSensitiveContent")
        self.uiBinder.btn_affirm.IsDisabled = true
        self.uiBinder.btn_affirm.interactable = false
        return
      end
    end
    self:close()
  end, nil, nil)
end

function Common_popup_inputView:refreshInputLimitShow(inputLength)
  if inputLength == 0 then
    if self.viewData.isCanInputEmpty == nil or self.viewData.isCanInputEmpty == false then
      self:refreshLengthLimitEmpty(inputLength)
    else
      self:refreshLengthLimitNormal(inputLength)
    end
  elseif self.viewData.stringLengthLimitNum and inputLength > self.viewData.stringLengthLimitNum then
    self:refreshLengthLimitNum(inputLength)
  else
    self:refreshLengthLimitNormal(inputLength)
  end
end

function Common_popup_inputView:refreshLengthLimitNum(inputLength)
  self.uiBinder.lab_desc.text = self.inputlongtipsStr_
  local strLength = Z.RichTextHelper.ApplyStyleTag(tostring(inputLength), E.TextStyleTag.EmphRb)
  self.uiBinder.lab_num.text = string.format("%s/%s", strLength, self.viewData.stringLengthLimitNum)
  self.uiBinder.btn_affirm.IsDisabled = true
  self.uiBinder.btn_affirm.interactable = false
end

function Common_popup_inputView:refreshLengthLimitEmpty(inputLength)
  self.uiBinder.lab_desc.text = self.inputshorttipsStr_
  self.uiBinder.lab_num.text = string.format("%s/%s", inputLength, self.viewData.stringLengthLimitNum)
  self.uiBinder.btn_affirm.IsDisabled = true
  self.uiBinder.btn_affirm.interactable = false
end

function Common_popup_inputView:refreshLengthLimitNormal(inputLength)
  self.uiBinder.lab_desc.text = ""
  self.uiBinder.lab_num.text = string.format("%s/%s", inputLength, self.viewData.stringLengthLimitNum)
  self.uiBinder.btn_affirm.IsDisabled = false
  self.uiBinder.btn_affirm.interactable = true
end

function Common_popup_inputView:close()
  Z.UIMgr:CloseView("common_popup_input")
end

return Common_popup_inputView
