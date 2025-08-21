local UI = Z.UI
local super = require("ui.ui_subview_base")
local Album_container_couldalbumView = class("Album_container_couldalbumView", super)
local LoopScrollRect = require("ui/component/loopscrollrect")
local albumLoopItem = require("ui.component.album.album_loop_item")

function Album_container_couldalbumView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "album_container_couldalbum_sub", "photograph/album_container_couldalbum_sub", UI.ECacheLv.None)
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
end

function Album_container_couldalbumView:onAddBtnClick()
  local allAlbumsData = self.albumMainData_:GetAlbumAllData()
  if #allAlbumsData >= self.albumMainData_.AlbumMaxNum then
    Z.TipsVM.ShowTipsLang(1000003)
    return
  end
  self.albumMainData_.albumPopupType = E.AlbumPopupType.Create
  self.albumMainVM_.ShowAlbumCreatePopupView(E.AlbumPopupType.Create)
  self:setItemShowState(true, E.AlbumSelectType.Normal)
end

function Album_container_couldalbumView:setItemShowState(isMultipleState, albumSelectType)
  local isMultiple = isMultipleState
  local isCancelMultiple = not isMultipleState
  if self.albumNum_ <= 0 then
    isMultiple = false
    isCancelMultiple = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_btn, isMultiple)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cancel_multiple_btn, isCancelMultiple)
  self.albumMainData_.AlbumSelectType = albumSelectType
  Z.EventMgr:Dispatch(Z.ConstValue.Album.DelState, albumSelectType)
end

function Album_container_couldalbumView:updateItemList()
  Z.CoroUtil.create_coro_xpcall(function()
    local albumNetworkData = self.albumMainVM_.AsyncGetAllAlbums(self.cancelSource:CreateToken())
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
  end)()
end

function Album_container_couldalbumView:OnDeActive()
  self.camerasysTabScrollRect_:ClearCells()
  self.camerasysTabScrollRect_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Album.CreateAlbum, self.updateAlbumViewByData, self)
end

function Album_container_couldalbumView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.CreateAlbum, self.updateAlbumViewByData, self)
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
end

function Album_container_couldalbumView:startAnimatedShow()
  self.uiBinder.anim_node:Restart(Z.DOTweenAnimType.Open)
end

function Album_container_couldalbumView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim_node.CoroPlay)
  coro(self.uiBinder.anim_node, Panda.ZUi.DOTweenAnimType.Close)
end

function Album_container_couldalbumView:initUIState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.add_btn, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, false)
end

return Album_container_couldalbumView
