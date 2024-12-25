local super = require("ui.ui_view_base")
local Album_mainView = class("Album_mainView", super)

function Album_mainView:ctor()
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "album_main")
  self.viewData = nil
  self.albumContainerTemporary_ = require("ui/view/album_container_temporary_view").new(self)
  self.albumContainerCouldalbum_ = require("ui/view/album_container_couldalbum_view").new(self)
  self.albumContainerUnionTemporary_ = require("ui/view/album_container_temporary_union_view").new(self)
  self.albumContainerUnionCloudAlbum_ = require("ui/view/album_container_cloud_union_view").new(self)
  self.AllContainerView_ = {
    self.albumContainerTemporary_,
    self.albumContainerCouldalbum_,
    self.albumContainerUnionTemporary_,
    self.albumContainerUnionCloudAlbum_
  }
  self.handlersFunc_ = {
    [E.AlbumMainState.Temporary] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.binder_temporary_album.anim_tog, cancelSource)
    end,
    [E.AlbumMainState.Couldalbum] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.binder_cloud_album.anim_tog, cancelSource)
    end,
    [E.AlbumMainState.UnionCloud] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.binder_cloud_album_union.anim_tog, cancelSource)
    end,
    [E.AlbumMainState.UnionTemporary] = function(cancelSource)
      self.commonVM_.CommonPlayTogAnim(self.uiBinder.binder_temporary_album_union.anim_tog, cancelSource)
    end
  }
end

function Album_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initParam()
  self:BindEvents()
  self:initBtnClick()
  self:startAnimatedShow()
  if self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    self:getUnionElectronicScreenList()
  end
end

function Album_mainView:getUnionElectronicScreenList()
  Z.CoroUtil.create_coro_xpcall(function()
    local ret = self.albumMainVM_.AsyncGetUnionElectronicScreenPhoto(self.cancelSource:CreateToken())
    if ret.errCode == 0 then
      local eScreenId = self.albumMainData_.EScreenId
      self.albumMainVM_.ParserUnionEScreenInfo(ret, eScreenId)
    end
  end)()
end

function Album_mainView:initView()
  self.uiBinder.binder_temporary_album.tog_tab_select.isOn = false
  self.uiBinder.binder_cloud_album.tog_tab_select.isOn = false
  self.uiBinder.binder_temporary_album_union.tog_tab_select.isOn = false
  self.uiBinder.binder_cloud_album_union.tog_tab_select.isOn = false
  self:checkIsShowUnion()
  self:setTogOnByOpenSource()
end

function Album_mainView:setTogOnByOpenSource()
  if self.viewData and self.viewData == E.AlbumOpenSource.Personal then
    self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_node, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cloud_album_node, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_union_node, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cloud_album_union_node, false)
    self.uiBinder.binder_cloud_album.tog_tab_select.isOn = true
  elseif self.viewData and self.viewData == E.AlbumOpenSource.Union or self.viewData == E.AlbumOpenSource.UnionElectronicScreen then
    self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_node, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cloud_album_node, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_union_node, false)
    self.uiBinder.binder_cloud_album_union.tog_tab_select.isOn = true
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_node, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cloud_album_node, true)
    local defaultTab = self.albumMainData_:GetAlbumDefaultTab()
    if defaultTab then
      if defaultTab == E.AlbumTabType.EAlbumTemporary then
        self.uiBinder.binder_temporary_album.tog_tab_select.isOn = true
      elseif defaultTab == E.AlbumTabType.EAlbumCloud then
        self.uiBinder.binder_cloud_album.tog_tab_select.isOn = true
      elseif defaultTab == E.AlbumTabType.EAlbumUnionTemporary then
        local isShow = self.albumMainVM_.CheckIsShowUnion()
        if isShow then
          self.uiBinder.binder_temporary_album_union.tog_tab_select.isOn = true
        else
          self.uiBinder.binder_temporary_album.tog_tab_select.isOn = true
        end
      elseif defaultTab == E.AlbumTabType.EAlbumUnion then
        local isShow = self.albumMainVM_.CheckIsShowUnion()
        if isShow then
          self.uiBinder.binder_cloud_album_union.tog_tab_select.isOn = true
        else
          self.uiBinder.binder_temporary_album.tog_tab_select.isOn = true
        end
      end
      self.albumMainData_:SetAlbumDefaultTab(nil)
    else
      self.uiBinder.binder_temporary_album.tog_tab_select.isOn = true
    end
  end
end

function Album_mainView:initParam()
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.containerType_ = nil
end

function Album_mainView:initBtnClick()
  self.uiBinder.binder_temporary_album.tog_tab_select.group = self.uiBinder.tog_group
  self.uiBinder.binder_cloud_album.tog_tab_select.group = self.uiBinder.tog_group
  self.uiBinder.binder_temporary_album_union.tog_tab_select.group = self.uiBinder.tog_group
  self.uiBinder.binder_cloud_album_union.tog_tab_select.group = self.uiBinder.tog_group
  self.uiBinder.binder_temporary_album.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:onTogSelected(E.AlbumMainState.Temporary, E.AlbumFuncId.Temporary)
    end
  end)
  self.uiBinder.binder_cloud_album.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:onTogSelected(E.AlbumMainState.Couldalbum, E.AlbumFuncId.Mine)
    end
  end)
  self.uiBinder.binder_temporary_album_union.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:onTogSelected(E.AlbumMainState.UnionTemporary, E.AlbumFuncId.UnionTemporary)
    end
  end)
  self.uiBinder.binder_cloud_album_union.tog_tab_select:AddListener(function(isOn)
    if isOn then
      self:onTogSelected(E.AlbumMainState.UnionCloud, E.AlbumFuncId.UnionCloud)
    end
  end)
  self:AddClick(self.uiBinder.close_btn, function()
    if self.containerType_ == E.AlbumMainState.MovePhoto then
      self.containerType_ = E.AlbumMainState.Couldalbum
      self:updateContainerView()
      Z.DataMgr.Get("album_main_data").IsMoveAlbum = false
      Z.EventMgr:Dispatch(Z.ConstValue.Album.DelState, E.AlbumSelectType.Normal)
      self.albumMainVM_.OpenCameraPhotoAlbumView()
    else
      Z.UIMgr:CloseView("album_main")
    end
  end)
end

function Album_mainView:onTogSelected(containerType, functionId)
  if self.containerType_ == containerType then
    return
  end
  self.containerType_ = containerType
  self.albumMainData_.ContainerType = self.containerType_
  self:onTogSelectedAnim(self.containerType_)
  self.commonVM_.SetLabText(self.uiBinder.lab_title, {
    E.AlbumFuncId.Album,
    functionId
  })
  self:updateContainerView()
end

function Album_mainView:onTogSelectedAnim(containerType)
  local cancelSource = self.cancelSource:CreateToken()
  local handler = self.handlersFunc_[containerType]
  if handler then
    handler(cancelSource)
  end
end

function Album_mainView:updateContainerView()
  self:hideAllContainerView()
  if self.containerType_ == E.AlbumMainState.Temporary then
    self.albumContainerTemporary_:Active(self.viewData, self.uiBinder.node_center_trans)
  elseif self.containerType_ == E.AlbumMainState.Couldalbum then
    self.albumContainerCouldalbum_:Active(self.viewData, self.uiBinder.node_center_trans)
  elseif self.containerType_ == E.AlbumMainState.UnionTemporary then
    self.albumContainerUnionTemporary_:Active(self.viewData, self.uiBinder.node_center_trans)
  elseif self.containerType_ == E.AlbumMainState.UnionCloud then
    self.albumContainerUnionCloudAlbum_:Active(self.viewData, self.uiBinder.node_center_trans)
  end
end

function Album_mainView:hideAllContainerView()
  for _, v in pairs(self.AllContainerView_) do
    v:DeActive()
  end
end

function Album_mainView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.albumMainData_.SelectedUnionAlbumPhoto = nil
  self:hideAllContainerView()
  self:UnBindEvents()
  self.handlersFunc_ = {}
  self.albumMainData_.SelectedUnionElectronicScreen = {}
  self.albumMainData_.CacheUnionElectronicScreen = {}
  self.albumMainData_.EScreenId = -1
end

function Album_mainView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.MainViewRef, self.refView, self)
end

function Album_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.MainViewRef, self.refView, self)
end

function Album_mainView:refView(eventData)
  if eventData and eventData.type then
    self.containerType_ = eventData.type
    self.albumMainData_.ContainerType = self.containerType_
  end
  self:updateContainerView()
end

function Album_mainView:OnRefresh()
  self:initView()
end

function Album_mainView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Album_mainView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Panda.ZUi.DOTweenAnimType.Close)
end

function Album_mainView:OnInputBack()
  if not self.albumMainData_.IsUpLoadState then
    Z.UIMgr:CloseView("album_main")
  end
end

function Album_mainView:checkIsShowUnion()
  local isShow = self.albumMainVM_.CheckIsShowUnion()
  self.uiBinder.Ref:SetVisible(self.uiBinder.temporary_album_union_node, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cloud_album_union_node, isShow)
end

return Album_mainView
