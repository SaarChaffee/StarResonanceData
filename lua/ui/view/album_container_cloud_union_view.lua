local UI = Z.UI
local super = require("ui.ui_subview_base")
local Album_container_couldalbumView = class("Album_container_couldalbumView", super)
local LoopScrollRect = require("ui/component/loopscrollrect")
local albumLoopItem = require("ui.component.album.album_loop_item")

function Album_container_couldalbumView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "album_container_union_cloud_sub", "photograph/album_container_couldalbum_union_sub", UI.ECacheLv.None, parent)
  self.albumNum_ = 0
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.viewData = nil
end

function Album_container_couldalbumView:OnActive()
  self:startAnimatedShow()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initBtnClick()
  self.camerasysTabScrollRect_ = LoopScrollRect.new(self.uiBinder.item_loop_scroll, self, albumLoopItem)
  self:BindEvents()
  self:initUIState()
end

function Album_container_couldalbumView:initBtnClick()
  self:AddClick(self.uiBinder.add_btn, function()
    self:onAddBtnClick()
  end)
  self:AddClick(self.uiBinder.cancel_multiple_btn, function()
    self:setItemShowState(true, E.AlbumSelectType.Normal)
  end)
  self:AddAsyncClick(self.uiBinder.multiple_btn, function()
    self:setItemShowState(false, E.AlbumSelectType.Select)
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    local ret = self.albumMainVM_.AsyncSetUnionCoverPhoto(self.cancelSource:CreateToken())
    if ret and ret.errCode == 0 then
      Z.TipsVM.ShowTips(1000566)
      Z.UIMgr:CloseView("album_main")
    else
      Z.TipsVM.ShowTips(1000567)
    end
  end)
end

function Album_container_couldalbumView:onAddBtnClick()
  local allAlbumsData = self.albumMainData_:GetAlbumAllData()
  if #allAlbumsData >= self.albumMainData_.AlbumMaxNum then
    Z.TipsVM.ShowTipsLang(1000003)
    return
  end
  self.albumMainData_.albumPopupType = E.AlbumPopupType.Create
  self.albumMainVM_.ShowAlbumCreatePopupView(E.AlbumPopupType.Create, E.AlbumJurisdictionType.Union)
  self:setItemShowState(true, E.AlbumSelectType.Normal)
end

function Album_container_couldalbumView:setItemShowState(isMultipleState, albumSelectType)
  local isMultiple = isMultipleState
  local isCancelMultiple = not isMultipleState
  if self.albumNum_ <= 0 or self.viewData == E.AlbumOpenSource.Union or self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    isMultiple = false
    isCancelMultiple = false
  end
  local haveAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.EditAlbum)
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_btn, isMultiple and haveAuthority)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cancel_multiple_btn, isCancelMultiple)
  self.albumMainData_.AlbumSelectType = albumSelectType
  Z.EventMgr:Dispatch(Z.ConstValue.Album.DelState, albumSelectType)
end

function Album_container_couldalbumView:updateItemList()
  Z.CoroUtil.create_coro_xpcall(function()
    local albumNetworkData = self.albumMainVM_.AsyncGetUnionAllAlbums(self.cancelSource:CreateToken())
    local allAlbums = {}
    if albumNetworkData and #albumNetworkData.allAlbums > 0 then
      allAlbums = albumNetworkData.allAlbums
    end
    self.albumMainData_:SetAlbumAllData(allAlbums)
    self.albumNum_ = #allAlbums
    self:refTempPhotoCount(self.albumNum_)
    self.camerasysTabScrollRect_:ClearCells()
    self.camerasysTabScrollRect_:SetData(allAlbums)
    self:setItemShowState(true, E.AlbumSelectType.Normal)
    self:refreshViewData(allAlbums)
  end)()
end

function Album_container_couldalbumView:OnDeActive()
  self.camerasysTabScrollRect_:ClearCells()
  self.camerasysTabScrollRect_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Album.CreateAlbum, self.updateAlbumViewByData, self)
  if self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    Z.EventMgr:Remove(Z.ConstValue.Album.UnionSetScreenCountUpdate, self.onSetScreenCountUpdate, self)
  end
end

function Album_container_couldalbumView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.CreateAlbum, self.updateAlbumViewByData, self)
  Z.EventMgr:Add(Z.ConstValue.Album.UpdateSelectNumber, self.setUnionSelectedNum, self)
  if self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    Z.EventMgr:Add(Z.ConstValue.Album.UnionSetScreenCountUpdate, self.onSetScreenCountUpdate, self)
  end
end

function Album_container_couldalbumView:updateAlbumViewByData()
  self:updateItemList()
end

function Album_container_couldalbumView:refTempPhotoCount(num)
  self.uiBinder.Ref:SetVisible(self.uiBinder.empty_node, num == 0)
end

function Album_container_couldalbumView:OnRefresh()
  self.albumMainData_.AlbumSelectType = E.AlbumSelectType.Normal
  self:updateItemList()
  self:setUnionSelectedNum()
  if self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    self:setUnionScreenMaxNum()
  end
end

function Album_container_couldalbumView:startAnimatedShow()
  self.uiBinder.anim_node:Restart(Z.DOTweenAnimType.Open)
end

function Album_container_couldalbumView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim_node.CoroPlay)
  coro(self.uiBinder.anim_node, Panda.ZUi.DOTweenAnimType.Close)
end

function Album_container_couldalbumView:initUIState()
  local isUnionSource = self.viewData == E.AlbumOpenSource.Union
  local isElectronicSource = self.viewData == E.AlbumOpenSource.UnionElectronicScreen
  local haveCoverAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetCover)
  local haveElectronicAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetEScreenPhoto)
  local haveCreateAuthority = self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.EditAlbum)
  local isShowSaveBtn = isUnionSource and haveCoverAuthority or isElectronicSource and haveElectronicAuthority
  local isShowPowerTips = isUnionSource and not haveCoverAuthority or isElectronicSource and not haveElectronicAuthority
  local isShowAddBtn = haveCreateAuthority and not isUnionSource and not isElectronicSource
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, isShowSaveBtn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.add_btn, isShowAddBtn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_union_selected, isUnionSource or isElectronicSource)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_union_save_count, isElectronicSource)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_power_tips, isShowPowerTips)
end

function Album_container_couldalbumView:setUnionSelectedNum()
  if not self.viewData then
    return
  end
  local limit = Z.Global.UnionPhotoAlbumSendCoverNum
  local currentSelected = self.albumMainData_.SelectedUnionAlbumPhoto == nil and 0 or 1
  local showValue = string.format("%d/%d", currentSelected, limit)
  self.uiBinder.btn_save.IsDisabled = false
  if self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    local unionVM = Z.VMMgr.GetVM("union")
    limit = unionVM:GetUnionScreenNum(self.albumMainData_.EScreenId)
    currentSelected = table.zcount(self.albumMainData_.SelectedUnionElectronicScreen)
    showValue = string.format("%d/%d", currentSelected, limit)
    self.uiBinder.lab_union_selected.text = Lang("UnionElectronicScreenSetCount", {
      id = self.albumMainData_.EScreenId,
      val = showValue
    })
    self.uiBinder.btn_save.IsDisabled = limit == 0
  elseif self.viewData ~= E.AlbumOpenSource.Union then
    return
  else
    self.uiBinder.lab_union_selected.text = Lang("UnionCoversNum", {val = showValue})
  end
end

function Album_container_couldalbumView:refreshViewData(allAlbumData)
  local unionVM = Z.VMMgr.GetVM("union")
  local maxNum = unionVM:GetUnionAlbumMaxNum()
  self.uiBinder.lab_used.text = self.albumMainVM_.GetUnionAllPhotoCount(allAlbumData) .. "/" .. maxNum
end

function Album_container_couldalbumView:setUnionScreenMaxNum()
  if not self.viewData or self.viewData ~= E.AlbumOpenSource.UnionElectronicScreen then
    return
  end
  local textValue = {
    val1 = self.albumMainData_.EScreenPhotoSetCount.cur,
    val2 = self.albumMainData_.EScreenPhotoSetCount.max
  }
  self.uiBinder.lab_union_save_count.text = Lang("UnionSpeedUpCount", textValue)
end

function Album_container_couldalbumView:onSetScreenCountUpdate()
  self:setUnionSelectedNum()
  self:setUnionScreenMaxNum()
end

return Album_container_couldalbumView
