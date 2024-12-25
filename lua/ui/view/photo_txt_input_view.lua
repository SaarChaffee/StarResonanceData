local UI = Z.UI
local super = require("ui.ui_view_base")
local Photo_txt_inputView = class("Photo_txt_inputView", super)

function Photo_txt_inputView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "photo_txt_input")
end

function Photo_txt_inputView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView("photo_txt_input")
  end)
  self:AddAsyncClick(self.uiBinder.btn_affirm, function()
    local str = self.uiBinder.input_content.text
    local vm = Z.VMMgr.GetVM("screenword")
    vm.CheckScreenWord(str, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
      if self.viewData.affirmFunc then
        self.viewData.affirmFunc(str)
      end
      Z.UIMgr:CloseView("photo_txt_input")
    end)
  end)
  self.uiBinder.input_content.characterLimit = self.viewData.txtMaxCount
  self:AddAsyncClick(self.uiBinder.input_content, function(str)
    local len = string.zlen(str)
    if len <= tonumber(self.viewData.txtMaxCount) then
      self.uiBinder.input_content.text = str
    end
    self:setDesLen(len)
  end)
  self.uiBinder.lab_title.text = self.viewData.txtTitle
  self.uiBinder.input_content.text = self.viewData.txtValue
end

function Photo_txt_inputView:setDesc(lab, desc, key)
end

function Photo_txt_inputView:setDesLen(len)
  local paramExp = {
    value1 = len,
    value2 = self.viewData.txtMaxCount
  }
  self.uiBinder.lab_num.text = Lang("degreeExpValue", paramExp)
end

function Photo_txt_inputView:OnDeActive()
end

function Photo_txt_inputView:OnRefresh()
  local len = string.zlen(self.uiBinder.input_content.text) or 0
  self:setDesLen(len)
end

return Photo_txt_inputView
