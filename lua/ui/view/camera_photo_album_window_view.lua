local super = require("ui.ui_view_base")
local Camera_photo_album_windowView = class("Camera_photo_album_windowView", super)

function Camera_photo_album_windowView:ctor()
  self.viewData = nil
  self.uiBinder = nil
  super.ctor(self, "camera_photo_album_window")
end

function Camera_photo_album_windowView:initComp()
  self.cancelMultipleBtn_ = self.uiBinder.cancel_multiple_btn
  self.closeBtn_ = self.uiBinder.close_btn
  self.editBtn_ = self.uiBinder.name_edit_btn
  self.multiSelectBtn_ = self.uiBinder.multiple_btn
  self.deleteBtn_ = self.uiBinder.delete_btn
  self.moveBtn_ = self.uiBinder.move_btn
  self.layoutBtn_ = self.uiBinder.multiple_layout
  self.animNode_ = self.uiBinder.anim_node
  self.selectNumLab_ = self.uiBinder.select_num_lab
  self.emptyNode_ = self.uiBinder.empty_node
  self.albumNameLab_ = self.uiBinder.album_title_lab
  self.personalzoneSaveBtn_ = self.uiBinder.btn_personalzone_save
  self.lab_title_ = self.uiBinder.lab_title
  self.lab_union_save_count_ = self.uiBinder.lab_union_save_count
  self.camerasysTabScrollRect_ = require("ui/component/loopscrollrect").new(self.uiBinder.photo_loopScroll, self, require("ui.component.album.album_photo_item"))
end

function Camera_photo_album_windowView:initParam()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.OpenAlbumViewType = E.AlbumType.Couldalbum
  self.isFirst_ = true
end

function Camera_photo_album_windowView:setSelectedState(isMultiSelect, albumSelectType, isResetSelectState)
  if self.viewData.source == E.AlbumOpenSource.Union or self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    self.uiBinder.Ref:SetVisible(self.editBtn_, false)
    self.uiBinder.Ref:SetVisible(self.multiSelectBtn_, false)
    self.uiBinder.Ref:SetVisible(self.layoutBtn_, false)
    self.albumMainData_.SelectType = E.AlbumSelectType.Select
    local haveCoverAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetCover)
    local haveElectronicAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetEScreenPhoto)
    self.uiBinder.Ref:SetVisible(self.personalzoneSaveBtn_, haveCoverAuthority or haveElectronicAuthority)
    self.uiBinder.select_num_lab.text = ""
    if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
      self.personalzoneSaveBtn_.IsDisabled = not self.albumMainVM_.CheckUnionElectronicIsChange()
    else
      self.personalzoneSaveBtn_.IsDisabled = false
    end
  else
    local isUnionCloud = self.albumMainData_.ContainerType == E.AlbumMainState.UnionCloud
    local canDeletePhoto = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.EditAlbum)
    if isUnionCloud and not canDeletePhoto then
      self.uiBinder.Ref:SetVisible(self.multiSelectBtn_, false)
      self.uiBinder.Ref:SetVisible(self.editBtn_, false)
    else
      self.uiBinder.Ref:SetVisible(self.multiSelectBtn_, not isMultiSelect)
      self.uiBinder.Ref:SetVisible(self.editBtn_, true)
    end
    self.uiBinder.Ref:SetVisible(self.layoutBtn_, isMultiSelect)
    self.uiBinder.Ref:SetVisible(self.selectNumLab_, isMultiSelect)
    self.uiBinder.Ref:SetVisible(self.personalzoneSaveBtn_, false)
    self.albumMainData_:ClearSelectedAlbumPhoto()
    self:albumUpdateSelectNumber()
    self.albumMainData_.SelectType = albumSelectType
    self.camerasysTabScrollRect_:ClearSelected()
    if isResetSelectState then
      self.albumMainData_.SelectType = E.AlbumSelectType.Normal
    end
  end
end

function Camera_photo_album_windowView:initBtnClick()
  self:AddClick(self.closeBtn_, function()
    Z.UIMgr:CloseView("camera_photo_album_window")
  end)
  self:AddClick(self.editBtn_, function()
    self.albumMainVM_.ShowAlbumCreatePopupView(E.AlbumPopupType.Change, self.viewData.albumShowInfo.access, self.viewData.albumShowInfo.albumId, self.viewData.albumShowInfo.name)
  end)
  self:AddClick(self.multiSelectBtn_, function()
    self:setSelectedState(true, E.AlbumSelectType.Select)
  end)
  self:AddClick(self.cancelMultipleBtn_, function()
    self:setSelectedState(false, E.AlbumSelectType.Select, true)
  end)
  self:AddClick(self.moveBtn_, function()
    self:onMoveBtnClick()
  end)
  self:AddAsyncClick(self.deleteBtn_, function()
    self:onDeleteBtnClick()
  end)
  self:AddAsyncClick(self.personalzoneSaveBtn_, function()
    if self.viewData.source == E.AlbumOpenSource.Union then
      local errCode = self.albumMainVM_.AsyncSetUnionCoverPhoto(self.cancelSource:CreateToken())
      if errCode == 0 then
        Z.TipsVM.ShowTips(1000566)
        Z.UIMgr:CloseView("album_main")
        Z.UIMgr:CloseView("camera_photo_album_window")
      else
        Z.TipsVM.ShowTips(1000567)
      end
    elseif self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
      if not self.albumMainVM_.CheckUnionElectronicIsChange() then
        Z.TipsVM.ShowTipsLang(1002105)
        return
      end
      local eScreenId = Z.DataMgr.Get("album_main_data").EScreenId
      local ret = self.albumMainVM_.AsyncSetUnionElectronicScreenPhoto(self.cancelSource:CreateToken(), eScreenId)
      if ret and ret.errCode == 0 then
        Z.TipsVM.ShowTips(1000566)
        Z.UIMgr:CloseView("album_main")
        Z.UIMgr:CloseView("camera_photo_album_window")
      end
    end
  end)
end

function Camera_photo_album_windowView:onMoveBtnClick()
  local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
  if selectedNum <= 0 then
    Z.TipsVM.ShowTipsLang(1000026)
    return
  end
  local eventData = {}
  eventData.albumOperationType = E.AlbumOperationType.Move
  eventData.albumId = self.viewData.albumShowInfo.albumId
  self:showMobileAlbum(eventData)
end

function Camera_photo_album_windowView:onDeleteBtnClick()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelCloud"), function()
    local delData = self.albumMainData_:GetSelectedAlbumPhoto()
    if not delData or table.zcount(delData) == 0 then
      Z.TipsVM.ShowTipsLang(1000027)
      return
    end
    local deleteCount = table.zcount(delData)
    local currentDeleteCount = 0
    for _, value in pairs(delData) do
      local retData = {}
      if self.albumMainVM_.CheckSubTypeIsUnion() then
        retData = self.albumMainVM_.AsyncDeleteUnionPhoto(value.id, self.cancelSource:CreateToken())
      else
        retData = self.albumMainVM_.AsyncDeleteServePhoto(value, self.cancelSource:CreateToken())
      end
      if retData and retData == 0 then
        currentDeleteCount = currentDeleteCount + 1
      end
      if currentDeleteCount == deleteCount then
        self:updateItemList()
        self:setSelectedState(false, E.AlbumSelectType.Select, true)
      end
    end
    Z.TipsVM.ShowTipsLang(1000008)
  end)
end

function Camera_photo_album_windowView:OnActive()
  self:initParam()
  self:initComp()
  self:initBtnClick()
  self:BindEvents()
  self:startAnimatedShow()
  self:initView()
end

function Camera_photo_album_windowView:initView()
  local isUnionSource = self.viewData.source == E.AlbumOpenSource.Union
  local isElectronicSource = self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen
  self.uiBinder.Ref:SetVisible(self.lab_union_save_count_, isElectronicSource)
  local haveCoverAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetCover)
  local haveElectronicAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetEScreenPhoto)
  local isShowPowerTips = isUnionSource and not haveCoverAuthority or isElectronicSource and not haveElectronicAuthority
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_power_tips, isShowPowerTips)
end

function Camera_photo_album_windowView:refreshView(albumData)
  local newName
  if albumData and albumData.name then
    newName = albumData.name
  end
  self:updatePanelInfo(newName)
  self:setSelectedState(false, E.AlbumSelectType.Select, true)
  self:updateItemList()
end

function Camera_photo_album_windowView:showMobileAlbum(data)
  self.albumMainVM_.ShowMobileAlbumView(data)
end

function Camera_photo_album_windowView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.EventMgr:Dispatch(Z.ConstValue.Album.MainViewRef)
  self.albumMainData_:ClearCurrentAlbumPhotosData()
  self.albumMainData_:ClearSelectedAlbumPhoto()
  self:RemoveEvents()
end

function Camera_photo_album_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Album.CloudAlbumPhotosDataUpdate, self.refreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Album.AlbumDataUpdate, self.refreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Album.AlbumPhotoDelete, self.refreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Album.UpdateSelectNumber, self.setUnionSelectedNum, self)
  if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    Z.EventMgr:Add(Z.ConstValue.Album.UnionSetScreenCountUpdate, self.onSetScreenCountUpdate, self)
  end
end

function Camera_photo_album_windowView:RemoveEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.CloudAlbumPhotosDataUpdate, self.refreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.AlbumDataUpdate, self.refreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.AlbumPhotoDelete, self.refreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.UpdateSelectNumber, self.setUnionSelectedNum, self)
  if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    Z.EventMgr:Remove(Z.ConstValue.Album.UnionSetScreenCountUpdate, self.onSetScreenCountUpdate, self)
  end
end

function Camera_photo_album_windowView:albumUpdateSelectNumber()
  local num = 0
  if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    local limit = self.unionVM_:GetUnionScreenNum(self.albumMainData_.EScreenId)
    if limit == 0 then
      self.uiBinder.select_num_lab.text = ""
    else
      num = self.albumMainData_:GetSelectedAlbumNumber()
      self.uiBinder.select_num_lab.text = Lang("SelectPhotoNumber", {val = num})
    end
    self.personalzoneSaveBtn_.IsDisabled = not self.albumMainVM_.CheckUnionElectronicIsChange()
  else
    num = self.albumMainData_:GetSelectedAlbumNumber()
    self.uiBinder.select_num_lab.text = Lang("SelectPhotoNumber", {val = num})
  end
end

function Camera_photo_album_windowView:OnRefresh()
  self:updatePanelInfo()
  self:setUnionSelectedNum()
  self:updateItemList()
  self:setSelectedState(false, E.AlbumSelectType.Select, true)
  if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    self:setUnionScreenMaxNum()
  end
end

function Camera_photo_album_windowView:updatePanelInfo(name)
  if not self.viewData or not next(self.viewData) then
    return
  end
  if name then
    self.albumNameLab_.text = name
    self.viewData.albumShowInfo.name = name
  elseif self.viewData.albumShowInfo.name == "" then
    self.albumNameLab_.text = self.albumMainData_.CloudAlbumName
  else
    self.albumNameLab_.text = self.viewData.albumShowInfo.name
  end
  local functionId = E.AlbumFuncId.Mine
  if self.albumMainData_.ContainerType == E.AlbumMainState.UnionCloud then
    functionId = E.AlbumFuncId.UnionCloud
  end
  self.commonVM_.SetLabText(self.uiBinder.lab_title, {
    E.AlbumFuncId.Album,
    functionId
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_union_selected, self.viewData.source == E.AlbumOpenSource.Union or self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen)
end

function Camera_photo_album_windowView:updateItemList()
  if not self.viewData or not next(self.viewData) then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local photoData = {}
    if self.albumMainVM_.CheckSubTypeIsUnion() then
      photoData = self.albumMainVM_.AsyncGetUnionAlbumPhotos(self.viewData.albumShowInfo.albumId, self.cancelSource:CreateToken())
    else
      photoData = self.albumMainVM_.AsyncGetAlbumPhotos(self.viewData.albumShowInfo.albumId, self.cancelSource:CreateToken())
    end
    self.uiBinder.Ref:SetVisible(self.emptyNode_, not photoData or not next(photoData))
    if self.viewData.source == E.AlbumOpenSource.Album then
      self.albumMainData_:SetCurrentAlbumPhotosData(photoData)
    end
    self.camerasysTabScrollRect_:ClearCells()
    self.camerasysTabScrollRect_:SetData(photoData, self.isFirst_)
    self.isFirst_ = false
  end)()
end

function Camera_photo_album_windowView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.animNode_:Restart(Z.DOTweenAnimType.Open)
end

function Camera_photo_album_windowView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.animNode_.CoroPlay)
  coro(self.animNode_, Panda.ZUi.DOTweenAnimType.Close)
end

function Camera_photo_album_windowView:setUnionSelectedNum()
  if not self.viewData then
    return
  end
  local limit = Z.Global.UnionPhotoAlbumSendCoverNum
  local currentSelected = self.albumMainData_.SelectedUnionAlbumPhoto == nil and 0 or 1
  local showValue = string.format("%d/%d", currentSelected, limit)
  if self.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    limit = self.unionVM_:GetUnionScreenNum(self.albumMainData_.EScreenId)
    currentSelected = table.zcount(self.albumMainData_.SelectedUnionElectronicScreen)
    showValue = string.format("%d/%d", currentSelected, limit)
    self.uiBinder.lab_union_selected.text = Lang("UnionElectronicScreenSetCount", {
      id = self.albumMainData_.EScreenId,
      val = showValue
    })
  elseif self.viewData.source ~= E.AlbumOpenSource.Union then
    return
  else
    self.uiBinder.lab_union_selected.text = Lang("UnionCoversNum", {val = showValue})
  end
end

function Camera_photo_album_windowView:setUnionScreenMaxNum()
  if not self.viewData or self.viewData.source ~= E.AlbumOpenSource.UnionElectronicScreen then
    return
  end
  local textValue = {
    val1 = self.albumMainData_.EScreenPhotoSetCount.cur,
    val2 = self.albumMainData_.EScreenPhotoSetCount.max
  }
  self.lab_union_save_count_.text = Lang("UnionScreenSaveCount", textValue)
end

function Camera_photo_album_windowView:onSetScreenCountUpdate()
  self:setUnionSelectedNum()
  self:setUnionScreenMaxNum()
end

return Camera_photo_album_windowView
