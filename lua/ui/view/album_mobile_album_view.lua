local super = require("ui.ui_view_base")
local Album_mobile_albumView = class("Album_mobile_albumView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local albumUnit = require("ui.component.album.album_newlybuild_item")

function Album_mobile_albumView:ctor()
  self.uiBinder = nil
  super.ctor(self, "album_mobile_album")
end

function Album_mobile_albumView:OnActive()
  self:initParam()
  self:initUIComponent()
  self:startAnimatedShow()
  self:BindEvents()
end

function Album_mobile_albumView:initParam()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.currentMoveCount_ = 0
  self.currentErrorCount_ = 0
  self.targetMoveCount_ = 0
end

function Album_mobile_albumView:initUIComponent()
  self.rightSubViewReturnBtn = self.uiBinder.close_btn
  self.loopScrollRect = self.uiBinder.album_loopScroll
  self.addBtn = self.uiBinder.add_btn
  self.remainingQuantity = self.uiBinder.remaining_quantity_lab
  self.animalBg = self.uiBinder.bg_ainm
  self.labSurplus = self.uiBinder.upload_title_lab
  self.bgBtn = self.uiBinder.bg_btn
  self.scrollViewAlbum_ = loopScrollRect.new(self.loopScrollRect, self, albumUnit)
  self:AddClick(self.rightSubViewReturnBtn, function()
    self:CloseMobileAlbumView()
  end)
  self:AddClick(self.bgBtn, function()
    self:CloseMobileAlbumView()
  end)
  self:AddClick(self.addBtn, function()
    local albumNumber = self.albumMainData_:GetAlbumAllData()
    if #albumNumber >= self.albumMainData_.AlbumMaxNum then
      Z.TipsVM.ShowTipsLang(1000003)
      return
    end
    self.albumMainVM_.ShowAlbumCreatePopupView(E.AlbumPopupType.Create)
  end)
end

function Album_mobile_albumView:ResetMoveCount()
  self.currentMoveCount_ = 0
  self.targetMoveCount_ = 0
  self.currentErrorCount_ = 0
end

function Album_mobile_albumView:OnDeActive()
  self.scrollViewAlbum_:ClearCells()
  self.scrollViewAlbum_ = nil
  self:ResetMoveCount()
  self:RemoveEvents()
  self:AnimControls(Z.DOTweenAnimType.Close)
  self.albumOperationType_ = E.AlbumOperationType.None
end

function Album_mobile_albumView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.CreateAlbum, self.UpdateViewByData, self)
  Z.EventMgr:Add(Z.ConstValue.Album.GetUploadPhotographTokenSuccess, self.CloseMobileAlbumView, self)
end

function Album_mobile_albumView:RemoveEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.CreateAlbum, self.UpdateViewByData, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.GetUploadPhotographTokenSuccess, self.CloseMobileAlbumView, self)
end

function Album_mobile_albumView:AnimControls(animalState)
  self.animalBg:Restart(animalState)
end

function Album_mobile_albumView:OnRefresh()
  self.albumOperationType_ = self.viewData.albumOperationType
  self:AnimControls(Z.DOTweenAnimType.Open)
  self:UpdateViewByData()
  self:refSelectPhotoInfo()
end

function Album_mobile_albumView:UpdateViewByData()
  Z.CoroUtil.create_coro_xpcall(function()
    self:refAlbumScrollView()
  end)()
end

function Album_mobile_albumView:CloseMobileAlbumView()
  self.albumMainVM_.CloseMobileAlbumView()
end

function Album_mobile_albumView:refAlbumScrollView()
  local albumNetworkData = {}
  if self.albumMainVM_.CheckIsShowUnion() and self.albumMainVM_.CheckSubTypeIsUnion() then
    albumNetworkData = self.albumMainVM_.AsyncGetUnionAllAlbums(self.cancelSource:CreateToken())
  else
    albumNetworkData = self.albumMainVM_.AsyncGetAllAlbums(self.cancelSource:CreateToken())
  end
  if not albumNetworkData or #albumNetworkData.allAlbums <= 0 then
    return
  end
  local photoData = self.albumMainData_:SetAlbumAllData(albumNetworkData.allAlbums)
  self.scrollViewAlbum_:ClearCells()
  if self.albumOperationType_ == E.AlbumOperationType.UpLoad then
    self.albumNum_ = #photoData
    self.scrollViewAlbum_:SetData(photoData)
  elseif self.albumOperationType_ == E.AlbumOperationType.Move or self.albumOperationType_ == E.AlbumOperationType.UnionMove then
    local moveData = {}
    for _, value in pairs(photoData) do
      if value.albumId ~= self.viewData.albumId then
        moveData[#moveData + 1] = value
      end
    end
    self.albumNum_ = #moveData
    self.scrollViewAlbum_:SetData(moveData)
  end
end

function Album_mobile_albumView:refSelectPhotoInfo()
  local decText = ""
  local isLabelSurplus = false
  local albumPhotoMaxNum = self.albumMainVM_.GetAlbumMaxNum()
  if self.albumOperationType_ == E.AlbumOperationType.UpLoad then
    decText = Lang("UpLoadTo")
    isLabelSurplus = true
    local allPhotoCount = self.albumMainData_:GetPhotoAllNumber()
    self.remainingQuantity.text = albumPhotoMaxNum - allPhotoCount
  elseif self.albumOperationType_ == E.AlbumOperationType.Move then
    isLabelSurplus = false
    decText = Lang("MoveTo")
  elseif self.albumOperationType_ == E.AlbumOperationType.UnionMove then
    decText = Lang("UpLoadTo")
    isLabelSurplus = true
    local allPhotoCount = self.albumMainData_:GetPhotoAllNumber()
    self.remainingQuantity.text = albumPhotoMaxNum - allPhotoCount
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.surplus_lab, isLabelSurplus)
  self.labSurplus.text = decText
end

function Album_mobile_albumView:SelectedItemEvent(eventData)
  local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
  local allPhotoCount = self.albumMainData_:GetPhotoAllNumber()
  local currentNum = self.albumOperationType_ == E.AlbumOperationType.UpLoad and allPhotoCount or eventData.num
  local albumPhotoMaxNum = self.albumMainVM_.GetAlbumMaxNum()
  if albumPhotoMaxNum < currentNum + selectedNum then
    Z.TipsVM.ShowTipsLang(1000018)
    return
  end
  self.albumMainData_.AlbumUploadCountTable.albumId = eventData.id
  self.albumMainData_.CurrentUploadPhotoCount = 0
  self.albumMainData_.TargetUploadPhotoCount = self.albumMainData_:GetSelectedAlbumNumber()
  if self.albumOperationType_ == E.AlbumOperationType.UpLoad then
    self:uploadPhoto(eventData)
  elseif self.albumOperationType_ == E.AlbumOperationType.Move then
    self:movePhoto(eventData)
  elseif self.albumOperationType_ == E.AlbumOperationType.UnionMove then
    self:unionMoveTmpToAlbum(eventData)
  end
end

function Album_mobile_albumView:uploadPhoto(selectAlbumData)
  local photos = self.albumMainData_:GetSelectedAlbumPhoto()
  if not photos or not next(photos) then
    return
  end
  self.albumMainData_.CurrentUploadSourceType = E.PlatformFuncType.Photograph
  for _, value in pairs(photos) do
    Z.CoroUtil.create_coro_xpcall(function()
      local requestData = self.albumMainVM_.InitUploadPhotoData(value, selectAlbumData.id, E.PlatformFuncType.Photograph, Z.ContainerMgr.CharSerialize.charId or 0)
      self.albumMainVM_.AsyncUploadPhotoRequestToken(requestData, self.cancelSource:CreateToken())
    end)()
  end
  self.albumMainData_.UpLoadStateType = E.CameraUpLoadStateType.UpLoading
  self.albumMainVM_.SetIsUploadState(true)
  Z.UIMgr:OpenView("album_storage_tips")
end

function Album_mobile_albumView:movePhoto(selectAlbumData)
  local photos = self.albumMainData_:GetSelectedAlbumPhoto()
  self.targetMoveCount_ = self.albumMainData_:GetSelectedAlbumNumber()
  for _, photo in pairs(photos) do
    Z.CoroUtil.create_coro_xpcall(function()
      local errCode
      if self.albumMainVM_.CheckSubTypeIsUnion() then
        errCode = self.albumMainVM_.AsyncMovePhotoToUnionAlbum(photo.id, selectAlbumData.id, self.cancelSource:CreateToken())
      else
        local ret = self.albumMainVM_.AsyncMovePhotoOtherAlbum(photo.id, selectAlbumData.id, self.cancelSource:CreateToken())
        errCode = ret.errCode
      end
      if errCode == 0 then
        self.currentMoveCount_ = self.currentMoveCount_ + 1
      end
      if self.targetMoveCount_ == self.currentMoveCount_ then
        self:CloseMobileAlbumView()
      end
    end)()
  end
end

function Album_mobile_albumView:unionMoveTmpToAlbum(selectAlbumData)
  local photos = self.albumMainData_:GetSelectedAlbumPhoto()
  self.targetMoveCount_ = self.albumMainData_:GetSelectedAlbumNumber()
  self.currentErrorCount_ = 0
  for _, photo in pairs(photos) do
    Z.CoroUtil.create_coro_xpcall(function()
      local errCode = self.albumMainVM_.AsyncMoveTmpPhotoToAlbum(photo.id, selectAlbumData.id, self.cancelSource:CreateToken())
      self.currentMoveCount_ = self.currentMoveCount_ + 1
      if errCode ~= 0 then
        self.currentErrorCount_ = self.currentErrorCount_ + 1
      end
      if self.targetMoveCount_ == self.currentMoveCount_ then
        local showNumTips = {
          val1 = self.targetMoveCount_ - self.currentErrorCount_,
          val2 = self.currentErrorCount_
        }
        Z.TipsVM.ShowTips(1000564, showNumTips)
        self:CloseMobileAlbumView()
        Z.EventMgr:Dispatch(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto)
      end
    end)()
  end
end

function Album_mobile_albumView:startAnimatedShow()
  self.animalBg:Restart(Z.DOTweenAnimType.Open)
end

function Album_mobile_albumView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.animalBg.CoroPlay)
  coro(self.animalBg, Panda.ZUi.DOTweenAnimType.Close)
end

return Album_mobile_albumView
