local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_set_bulletin_tplView = class("Union_set_bulletin_tplView", super)

function Union_set_bulletin_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_set_bulletin_tpl", "union/union_set_bulletin_tpl", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.parentView_ = parent
end

function Union_set_bulletin_tplView:OnActive()
  self.uiBinder.input_content:AddListener(function()
    self:onInputContentChanged()
  end)
  self.charMinLimit_ = Z.Global.UnionNoticeLengthMinLimit
  self.charMaxLimit_ = Z.Global.UnionNoticeLengthMaxLimit
  self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
end

function Union_set_bulletin_tplView:OnDeActive()
end

function Union_set_bulletin_tplView:OnRefresh()
  self:setAnnounceInfo()
end

function Union_set_bulletin_tplView:setAnnounceInfo()
  self.uiBinder.input_content.text = self.unionInfo_.baseInfo.declaration
  self:onInputContentChanged()
end

function Union_set_bulletin_tplView:onInputContentChanged()
  local content = self.uiBinder.input_content.text
  local length = string.zlenNormalize(content)
  if length > self.charMaxLimit_ then
    self.uiBinder.input_content.text = string.zcutNormalize(content, self.charMaxLimit_)
  else
    self.uiBinder.lab_digit.text = string.zconcat(length, "/", self.charMaxLimit_)
  end
  local isModify = content ~= self.unionInfo_.baseInfo.declaration
  self.parentView_:EnableOrDisableByModify(isModify)
end

function Union_set_bulletin_tplView:checkVaild()
  local strLen = string.zlenNormalize(self.uiBinder.input_content.text)
  if strLen < self.charMinLimit_ or strLen > self.charMaxLimit_ then
    Z.TipsVM.ShowTipsLang(1000515)
    return false
  end
  return true
end

function Union_set_bulletin_tplView:onClickConfirm()
  if self:checkVaild() then
    local strContent = self.uiBinder.input_content.text
    local reply = self.unionVM_:AsyncSetUnionDeclaration(self.unionVM_:GetPlayerUnionId(), strContent, self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode == 0 then
      Z.TipsVM.ShowTips(1000549)
      if self.parentView_ then
        self.parentView_:EnableOrDisableByModify(false)
      end
    end
  end
end

return Union_set_bulletin_tplView
