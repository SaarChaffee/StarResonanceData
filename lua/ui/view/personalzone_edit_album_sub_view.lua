local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_edit_album_subView = class("Personalzone_edit_album_subView", super)
local LoopListView = require("ui/component/loop_list_view")
local LoopGridView = require("ui/component/loop_grid_view")
local PersonalzoneEditAlbumItem = require("ui/component/personalzone/personalzone_edit_album_item")
local PersonalzoneEditPhotoItem = require("ui/component/personalzone/personalzone_edit_photo_item")

function Personalzone_edit_album_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_edit_album_sub", "personalzone/personalzone_edit_album_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
end

function Personalzone_edit_album_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.node_album.btn, function()
    if self.selectAlbumId_ ~= nil then
      self:BackAlbum()
    else
      Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Album)
    end
  end)
  self.listphoto_ = LoopGridView.new(self, self.uiBinder.loop_photo, PersonalzoneEditPhotoItem, "personalzone_edit_photo_item_tpl")
  self.listphoto_:Init({})
  self.listalbum_ = LoopListView.new(self, self.uiBinder.loop_album, PersonalzoneEditAlbumItem, "personalzone_edit_album_item_tpl")
  self.listalbum_:Init({})
  self.selectAlbumId_ = nil
  self.albums_ = {}
  self:refreshInfo()
  Z.EventMgr:Add(Z.ConstValue.Album.MainViewRef, self.refreshInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Album.CreateAlbum, self.refreshInfo, self)
end

function Personalzone_edit_album_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Album.MainViewRef, self.refreshInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.CreateAlbum, self.refreshInfo, self)
  self.photos_ = {}
  self.listalbum_:UnInit()
  self.listalbum_ = nil
  self.listphoto_:UnInit()
  self.listphoto_ = nil
end

function Personalzone_edit_album_subView:OnRefresh()
end

function Personalzone_edit_album_subView:IsSelect(id)
  return self.parentView_:IsPhotoUse(id)
end

function Personalzone_edit_album_subView:SelectId(id)
  self.parentView_:SelectPhoto(id)
end

function Personalzone_edit_album_subView:RefreshAllShownItem()
  self.listphoto_:RefreshAllShownItem()
end

function Personalzone_edit_album_subView:BackAlbum()
  self.selectAlbumId_ = nil
  self.listalbum_:ClearAllSelect()
  self.listalbum_:RefreshListView(self.albums_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_photo, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_album, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #self.albums_ == 0)
  self:refreshBtn()
end

function Personalzone_edit_album_subView:SelectAlbum(albumId)
  Z.CoroUtil.create_coro_xpcall(function()
    self.parentView_.ListSelectEvent = false
    self.listphoto_:ClearAllSelect()
    self.listphoto_:RefreshListView({})
    self.selectAlbumId_ = albumId
    self.photos_ = self.albumMainVM_.AsyncGetAlbumPhotos(self.selectAlbumId_, self.cancelSource:CreateToken())
    self.listphoto_:RefreshListView(self.photos_)
    for k, data in ipairs(self.photos_) do
      if self:IsSelect(data.id) then
        self.listphoto_:SetSelected(k)
      end
    end
    self.parentView_.ListSelectEvent = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_photo, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.loop_album, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #self.photos_ == 0)
    self:refreshBtn()
  end)()
end

function Personalzone_edit_album_subView:refreshInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    local albumNetworkData = self.albumMainVM_.AsyncGetAllAlbums(self.cancelSource:CreateToken())
    self.albumMainData_:SetAlbumAllData(albumNetworkData.allAlbums)
    self.albums_ = albumNetworkData.allAlbums
    if self.selectAlbumId_ ~= nil then
      local isExist = false
      for _, v in ipairs(self.albums_) do
        if v.albumId == self.selectAlbumId_ then
          isExist = true
          break
        end
      end
      if not isExist then
        self.selectAlbumId_ = nil
      end
    end
    if self.selectAlbumId_ == nil then
      self.listalbum_:ClearAllSelect()
      self.listalbum_:RefreshListView(self.albums_)
      self.parentView_.ListSelectEvent = true
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_photo, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_album, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #self.albums_ == 0)
    else
      self.photos_ = self.albumMainVM_.AsyncGetAlbumPhotos(self.selectAlbumId_, self.cancelSource:CreateToken())
      self.parentView_.ListSelectEvent = false
      self.listphoto_:ClearAllSelect()
      self.listphoto_:RefreshListView(self.photos_)
      for k, data in ipairs(self.photos_) do
        if self:IsSelect(data.id) then
          self.listphoto_:SetSelected(k)
        end
      end
      self.parentView_.ListSelectEvent = true
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_photo, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_album, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #self.photos_ == 0)
    end
    self:refreshBtn()
  end)()
end

function Personalzone_edit_album_subView:refreshBtn()
  if self.selectAlbumId_ ~= nil then
    self.uiBinder.node_album.lab_normal.text = Lang("BackAlbumList")
    self.uiBinder.lab_empty.text = Lang("NotAvailablePicture")
  else
    self.uiBinder.node_album.lab_normal.text = Lang("GotoAlbum")
    self.uiBinder.lab_empty.text = Lang("NotAvailableAlbum")
  end
end

return Personalzone_edit_album_subView
