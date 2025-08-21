local UnionListDetailItem = class("UnionListDetailItem")
local unionLogoItem = require("ui.component.union.union_logo_item")
local unionTagItem = require("ui.component.union.union_tag_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local reportDefine = require("ui.model.report_define")

function UnionListDetailItem:ctor()
end

function UnionListDetailItem:Init(uiBinder, parentView, index)
  self.uiBinder = uiBinder
  self.parentView = parentView
  self.index = index
  self.photoId = 0
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.reportVm_ = Z.VMMgr.GetVM("report")
  self.parentView:AddAsyncClick(self.uiBinder.btn_apply, function()
    self:onApplyBtnClick()
  end)
  self.parentView:AddAsyncClick(self.uiBinder.btn_panel, function()
    self:onPanelBtnClick()
  end)
  self.parentView:AddClick(self.uiBinder.btn_call, function()
    self:onCallBtnClick()
  end)
  self.parentView:AddAsyncClick(self.uiBinder.btn_collection, function()
    self:onCollectionBtnClick()
  end)
  self.parentView:AddAsyncClick(self.uiBinder.btn_panel.OnLongPressEvent, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, self.reportVm_.IsReportOpen(true))
  end, nil, nil)
  self.parentView:AddAsyncClick(self.uiBinder.btn_report, function()
    if self.unionListData then
      self.reportVm_.OpenReportPop(reportDefine.ReportScene.UnionInfo, self.unionListData.baseInfo.Name, self.unionListData.baseInfo.Id)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
  end)
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Normal, parentView, self.uiBinder.trans_time_tag, self.uiBinder.trans_activity_tag)
  self.Logo_ = unionLogoItem.new()
  self.Logo_:Init(self.uiBinder.binder_logo.Go)
  self:bindEvents()
end

function UnionListDetailItem:UnInit()
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.Logo_:UnInit()
  self.Logo_ = nil
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self:unbindEvents()
  self.uiBinder = nil
  self.parentView = nil
  self.unionListData = nil
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
end

function UnionListDetailItem:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.CollectionUnionChange, self.onCollectionUnionChange, self)
end

function UnionListDetailItem:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.CollectionUnionChange, self.onCollectionUnionChange, self)
end

function UnionListDetailItem:Refresh(unionListData)
  self.unionListData = unionListData
  self.uiBinder.Ref.UIComp:SetVisible(unionListData ~= nil)
  if unionListData == nil then
    return
  end
  local logoData = self.unionVM_:GetLogoData(self.unionListData.baseInfo.Icon)
  self.Logo_:SetLogo(logoData)
  self.uiBinder.lab_name.text = self.unionListData.baseInfo.Name
  self.uiBinder.lab_grade.text = Lang("LvFormatSymbol", {
    val = self.unionListData.baseInfo.level
  })
  self.uiBinder.lab_person.text = self.unionListData.baseInfo.num .. "/" .. self.unionListData.baseInfo.maxNum
  if self.unionListData.baseInfo.slogan == nil or self.unionListData.baseInfo.slogan == "" then
    self.uiBinder.lab_bulletin.text = Lang("Notset")
  else
    self.uiBinder.lab_bulletin.text = self.unionListData.baseInfo.slogan
  end
  local isHadUnion = self.unionVM_:GetPlayerUnionId() ~= 0
  local isHadApply = self.unionListData.isReq
  local isCurUnion = self.unionVM_:GetPlayerUnionId() == self.unionListData.baseInfo.Id
  self.uiBinder.btn_apply.IsDisabled = isHadUnion
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_apply, not isHadUnion and not isHadApply)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_had_apply, not isHadUnion and isHadApply)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_cur_union, isCurUnion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_collection_on, self.unionData_:IsUnionCollection(self.unionListData.baseInfo.Id))
  self:refreshTagUI()
  self:refreshHeadUI()
  self:refreshPhotoUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, false)
end

function UnionListDetailItem:refreshTagUI()
  local tagIdList = self.unionListData.baseInfo.tags
  self.unionTagItem_:SetCommonTagUI(tagIdList, self.uiBinder, "listDetailTag_" .. self.index)
end

function UnionListDetailItem:refreshHeadUI()
  if self.unionListData.presidentInfo == nil then
    return
  end
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  local isSelf = self.unionListData.presidentInfo.basicData.charID == Z.ContainerMgr.CharSerialize.charBase.charId
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_call, not isSelf)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.unionListData.presidentInfo.basicData.isNewbie))
  self.uiBinder.lab_president.text = self.unionListData.presidentInfo.basicData.name
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, self.unionListData.presidentInfo, function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.unionListData.presidentInfo.basicData.charID, self.parentView.cancelSource:CreateToken())
    end)()
  end, self.parentView.cancelSource:CreateToken())
end

function UnionListDetailItem:refreshPhotoUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_photo_empty, false)
  self:getUnionPhoto()
end

function UnionListDetailItem:onApplyBtnClick()
  if self.unionVM_:GetPlayerUnionId() ~= 0 then
    return
  end
  self.parentView:onRequestJoinBtnClick(self.unionListData.baseInfo.Id)
end

function UnionListDetailItem:onPanelBtnClick()
  local viewData = {
    ViewType = E.UnionRecruitViewType.List,
    UnionDataList = self.parentView.curUnionListData_,
    UnionIndex = (self.parentView.curUnionListDataPage_ - 1) * 3 + self.index
  }
  self.unionVM_:OpenUnionRecruitDetailView(viewData)
end

function UnionListDetailItem:onCallBtnClick()
  local presidentId = self.unionListData.presidentInfo.basicData.charID
  self.unionVM_:CloseJoinWindow()
  self.unionVM_:CloseUnionMainView()
  Z.VMMgr.GetVM("friends_main").OpenPrivateChat(presidentId)
end

function UnionListDetailItem:onCollectionBtnClick()
  local unionId = self.unionListData.baseInfo.Id
  if self.unionData_:IsUnionCollection(unionId) then
    self.unionVM_:AsyncCancelCollectUnion(unionId, self.parentView.cancelSource:CreateToken())
  elseif self.unionData_:IsCanCollectUnion() then
    self.unionVM_:AsyncCollectUnion(unionId, self.parentView.cancelSource:CreateToken())
  end
end

function UnionListDetailItem:onCollectionUnionChange()
  if self.unionListData == nil then
    return
  end
  local unionId = self.unionListData.baseInfo.Id
  local isCollected = self.unionData_:IsUnionCollection(unionId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_collection_on, isCollected)
end

function UnionListDetailItem:onPhotoCallBack(photoId)
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
  self.photoId = photoId
  self.uiBinder.rimg_photo:SetNativeTexture(photoId)
end

function UnionListDetailItem:getUnionPhoto()
  local coverPhotoInfo = self.unionListData.baseInfo
  if not coverPhotoInfo.coverPhotoInfo or coverPhotoInfo.coverPhotoId == 0 then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  local album_main_vm = Z.VMMgr.GetVM("album_main")
  local photoData = coverPhotoInfo.coverPhotoInfo.images[E.PictureType.ECameraThumbnail]
  if not photoData or string.zisEmpty(photoData.cosUrl) then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  album_main_vm.AsyncGetHttpAlbumPhoto(photoData.cosUrl, E.PictureType.ECameraRender, E.NativeTextureCallToken.album_loop_item, self.parentView.cancelSource, self.onPhotoCallBack, self)
end

return UnionListDetailItem
