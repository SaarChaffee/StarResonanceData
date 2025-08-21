local UI = Z.UI
local super = require("ui.ui_view_base")
local Album_create_popupView = class("Album_create_popupView", super)
local albumMainData = Z.DataMgr.Get("album_main_data")
local album_main_vm = Z.VMMgr.GetVM("album_main")

function Album_create_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "album_create_popup")
  self.popupType_ = E.AlbumPopupType.Create
  self.jurisType_ = E.AlbumJurisdictionType.All
  self.limitNum_ = Z.Global.PhotoAlbum_MaxAlbumNameLength
  self.isCanInputEmpty_ = false
  self.inputlongtipsStr_ = Lang("CommonPopupInputTooLong")
  self.inputshorttipsStr_ = Lang("CommonPopupInputZero")
end

function Album_create_popupView:OnActive()
  self:initComp()
  self.popupType_ = E.AlbumPopupType.Create
  self.jurisType_ = E.AlbumJurisdictionType.All
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self:setIsOkBtnDisabled(false)
  self.nameInput_:AddListener(function(string)
    local inputLength = self.nameInput_:CalculatePlaces()
    self:refreshInputLimitShow(inputLength)
  end)
  self:AddAsyncClick(self.okBtn_, function()
    local albumName = self.inputNameLab_.text
    if not albumName or albumName == "" then
      Z.TipsVM.ShowTipsLang(1000006)
      return
    end
    self:setIsOkBtnDisabled(true)
    if E.AlbumPopupType.Create == self.popupType_ then
      self:createAlbum(self.cancelSource:CreateToken())
    elseif E.AlbumPopupType.Change == self.popupType_ then
      self:changeAlbum(self.cancelSource:CreateToken(), self.cancelSource:CreateToken())
    end
  end)
  self:AddClick(self.cancelBtn_, function()
    Z.UIMgr:CloseView("album_create_popup")
  end)
  Z.EventMgr:Add(Z.ConstValue.ScreenWordAndGrpcPass, self.onScreenWordPass, self)
end

function Album_create_popupView:setIsOkBtnDisabled(IsDisabled)
  self.okBtn_.IsDisabled = IsDisabled
  self.okBtn_.interactable = not IsDisabled
end

function Album_create_popupView:onScreenWordPass()
  if E.AlbumPopupType.Create == self.popupType_ then
    Z.TipsVM.ShowTipsLang(1000004)
  elseif E.AlbumPopupType.Change == self.popupType_ then
    Z.TipsVM.ShowTipsLang(1000011)
  end
  Z.UIMgr:CloseView("album_create_popup")
end

function Album_create_popupView:initComp()
  self.closeBtn_ = self.uiBinder.btn_close
  self.cancelBtn_ = self.uiBinder.btn_no
  self.okBtn_ = self.uiBinder.btn_yes
  self.nameInput_ = self.uiBinder.input_album
  self.titleLab_ = self.uiBinder.lab_title
  self.inputNameLab_ = self.uiBinder.input_album
  self.lab_desc_ = self.uiBinder.lab_desc
  self.lab_num_ = self.uiBinder.lab_num
  self.scene_mask_ = self.uiBinder.scene_mask
end

function Album_create_popupView:OnDeActive()
end

function Album_create_popupView:OnRefresh()
  self.popupType_ = self.viewData.albumPopupType
  self.jurisType_ = self.viewData.jurisType
  self.nameInput_.readOnly = false
  self.uiBinder.Ref:SetVisible(self.lab_desc_, false)
  if E.AlbumPopupType.Create == self.popupType_ then
    self:refCreateUiShow()
  elseif E.AlbumPopupType.Change == self.popupType_ then
    self:refChangeUiShow()
  end
end

function Album_create_popupView:refCreateUiShow()
  self.nameInput_.text = album_main_vm.CreateAlbumDefaultName()
  local titleText = Lang("NewAlbum")
  if album_main_vm.CheckIsShowUnion() and album_main_vm.CheckSubTypeIsUnion() then
    titleText = Lang("NewUnionAlbum")
  end
  self.titleLab_.text = titleText
end

function Album_create_popupView:refChangeUiShow()
  self.nameInput_.text = self.viewData.name
  self.titleLab_.text = Lang("ChangeAlbum")
end

function Album_create_popupView:showErrorMsg(errCode)
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(errCode)
  if msgCfg == nil then
    logError("show notice tip error config id not found:" .. tostring(errCode))
    return
  end
  self.uiBinder.Ref:SetVisible(self.lab_desc_, true)
  self.lab_desc_.text = msgCfg.Content
end

function Album_create_popupView:createAlbum(token)
  local albumName = self.inputNameLab_.text
  local ret
  if album_main_vm.CheckSubTypeIsUnion() then
    ret = album_main_vm.AsyncCreateUnionAlbum(albumName, self.jurisType_, token)
  else
    ret = album_main_vm.AsyncCreateAlbum(albumName, self.jurisType_, token)
  end
  if ret and ret.errCode ~= 0 then
    self:showErrorMsg(ret.errCode)
  else
    Z.UIMgr:CloseView("album_create_popup")
  end
end

function Album_create_popupView:changeAlbum(rightToken, nameToken)
  local authorityRet = {}
  if self.jurisType_ ~= self.viewData.jurisType then
    authorityRet = album_main_vm.AsyncEditAlbumRight(self.viewData.albumId, self.jurisType_, rightToken)
  end
  local albumName = self.inputNameLab_.text
  local nameRet = {}
  if albumName ~= self.viewData.name then
    if album_main_vm.CheckIsShowUnion() and album_main_vm.CheckSubTypeIsUnion() then
      nameRet = album_main_vm.AsyncEditUnionAlbumName(self.viewData.albumId, albumName, nameToken)
    else
      nameRet = album_main_vm.AsyncEditAlbumName(self.viewData.albumId, albumName, nameToken)
    end
  end
  if authorityRet.errCode and authorityRet.errCode ~= 0 then
    self:showErrorMsg(authorityRet.errCode)
  elseif nameRet.errCode and nameRet.errCode ~= 0 then
    self:showErrorMsg(nameRet.errCode)
  else
    Z.UIMgr:CloseView("album_create_popup")
  end
end

function Album_create_popupView:refreshInputLimitShow(inputLength)
  if inputLength == 0 then
    if self.isCanInputEmpty_ == nil or self.isCanInputEmpty_ == false then
      self:refreshLengthLimitEmpty(inputLength)
    else
      self:refreshLengthLimitNormal(inputLength)
    end
  elseif self.limitNum_ and inputLength > self.limitNum_ then
    self:refreshLengthLimitNum(inputLength)
  else
    self:refreshLengthLimitNormal(inputLength)
  end
end

function Album_create_popupView:refreshLengthLimitNum(inputLength)
  self.lab_desc_.text = self.inputlongtipsStr_
  self.uiBinder.Ref:SetVisible(self.lab_desc_, true)
  local strLength = Z.RichTextHelper.ApplyStyleTag(tostring(inputLength), E.TextStyleTag.EmphRb)
  self.lab_num_.text = string.format("%s/%s", strLength, self.limitNum_)
  self.okBtn_.IsDisabled = true
  self.okBtn_.interactable = false
end

function Album_create_popupView:refreshLengthLimitEmpty(inputLength)
  self.lab_desc_.text = self.inputshorttipsStr_
  self.uiBinder.Ref:SetVisible(self.lab_desc_, true)
  self.lab_num_.text = string.format("%s/%s", inputLength, self.limitNum_)
  self.okBtn_.IsDisabled = true
  self.okBtn_.interactable = false
end

function Album_create_popupView:refreshLengthLimitNormal(inputLength)
  self.uiBinder.Ref:SetVisible(self.lab_desc_, false)
  self.lab_num_.text = string.format("%s/%s", inputLength, self.limitNum_)
  self.okBtn_.IsDisabled = false
  self.okBtn_.interactable = true
end

return Album_create_popupView
