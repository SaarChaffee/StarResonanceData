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
  local height, left, right, anchorPosition, alignment, imgHeight, labNumPosition
  if self.viewData.isMultiLine then
    height = 178
    imgHeight = 200
    left = 0
    right = 0
    anchorPosition = 56
    labNumPosition = -25
    alignment = TMPro.TextAlignmentOptions.TopLeft
  else
    height = 54
    imgHeight = 54
    left = 100
    right = 100
    anchorPosition = 0
    labNumPosition = 0
    alignment = TMPro.TextAlignmentOptions.Midline
  end
  self.uiBinder.input_ref:SetHeight(height)
  self.uiBinder.img_input_bg:SetHeight(imgHeight)
  self.uiBinder.lab_input_ref:SetOffsetMin(left, 0)
  self.uiBinder.lab_input_ref:SetOffsetMax(-right, 0)
  self.uiBinder.lab_output_ref:SetOffsetMin(left, 0)
  self.uiBinder.lab_output_ref:SetOffsetMax(-right, 0)
  self.uiBinder.lab_rule_ref:SetAnchorPosition(0, anchorPosition)
  self.uiBinder.lab_num_ref:SetAnchorPosition(0, labNumPosition)
  self.uiBinder.lab_input.alignment = alignment
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
    self.uiBinder.lab_desc.text = self.viewData.tipDesc or ""
    self.uiBinder.btn_affirm.IsDisabled = false
    self.uiBinder.btn_affirm.interactable = true
  end
  self.uiBinder.input_field:AddListener(function(string)
    local inputLength = string.zlenNormalize(string)
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
      if errCode then
        self.uiBinder.lab_desc.text = Lang("ErrSensitiveContent")
        self.uiBinder.btn_affirm.IsDisabled = true
        self.uiBinder.btn_affirm.interactable = false
        return
      end
    end
    self:close()
  end, nil, nil)
  self:checkVerifyLabel()
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
  self:checkVerifyLabel()
end

function Common_popup_inputView:checkVerifyLabel()
  if self.viewData.verifyLabel and self.viewData.verifyLabel ~= "" then
    local verify = self.viewData.verifyLabel == self.uiBinder.input_field.text
    self.uiBinder.btn_affirm.IsDisabled = not verify
    self.uiBinder.btn_affirm.interactable = verify
  end
end

function Common_popup_inputView:refreshLengthLimitNum(inputLength)
  self.uiBinder.lab_desc.text = self.inputlongtipsStr_
  local strLength = Z.RichTextHelper.ApplyStyleTag(tostring(inputLength), E.TextStyleTag.EmphRb)
  if self.viewData.stringLengthLimitNum then
    self.uiBinder.lab_num.text = string.format("%s/%s", strLength, self.viewData.stringLengthLimitNum)
  else
    self.uiBinder.lab_num.text = ""
  end
  self.uiBinder.btn_affirm.IsDisabled = true
  self.uiBinder.btn_affirm.interactable = false
end

function Common_popup_inputView:refreshLengthLimitEmpty(inputLength)
  self.uiBinder.lab_desc.text = self.inputshorttipsStr_
  if self.viewData.stringLengthLimitNum then
    self.uiBinder.lab_num.text = string.format("%s/%s", inputLength, self.viewData.stringLengthLimitNum)
  else
    self.uiBinder.lab_num.text = ""
  end
  self.uiBinder.btn_affirm.IsDisabled = true
  self.uiBinder.btn_affirm.interactable = false
end

function Common_popup_inputView:refreshLengthLimitNormal(inputLength)
  self.uiBinder.lab_desc.text = self.viewData.tipDesc or ""
  if self.viewData.stringLengthLimitNum then
    self.uiBinder.lab_num.text = string.format("%s/%s", inputLength, self.viewData.stringLengthLimitNum)
  else
    self.uiBinder.lab_num.text = ""
  end
  self.uiBinder.btn_affirm.IsDisabled = false
  self.uiBinder.btn_affirm.interactable = true
end

function Common_popup_inputView:close()
  Z.UIMgr:CloseView("common_popup_input")
end

return Common_popup_inputView
