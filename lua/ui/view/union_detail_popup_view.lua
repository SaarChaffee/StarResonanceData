local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_detail_popupView = class("Union_detail_popupView", super)
local unionLogoItem = require("ui.component.union.union_logo_item")
local unionTagItem = require("ui.component.union.union_tag_item")
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Union_detail_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_detail_popup")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_detail_popupView:OnActive()
  self:initData()
  self:initComponent()
  self:bindEvents()
  self:initOpenState()
end

function Union_detail_popupView:OnDeActive()
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
  self:unBindEvents()
  if self.headItem_ then
    self.headItem_:UnInit()
    self.headItem_ = nil
  end
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.Logo_:UnInit()
  self.Logo_ = nil
  self.cacheUnionDetailInfoDict_ = {}
end

function Union_detail_popupView:OnRefresh()
end

function Union_detail_popupView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_detail_popupView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_detail_popupView:initData()
  self.curType_ = self.viewData.ViewType
  self.unionDataList_ = self.viewData.UnionDataList
  self.curUnionIndex_ = self.viewData.UnionIndex
  self.curUnionInfo_ = self.viewData.UnionInfo
  self.curUnionRecruitInfo_ = self.viewData.UnionRecruitInfo
  self.limitLvMin_ = Z.Global.UnionJoinLimitLevel
  self.cacheUnionDetailInfoDict_ = {}
end

function Union_detail_popupView:initComponent()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    self:onCloseBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self:switchLastUnion()
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self:switchNextUnion()
  end)
  self:AddAsyncClick(self.uiBinder.btn_collection, function()
    self:onCollectionBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_call, function()
    self:onChatBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_application, function()
    self:onApplyBtnClick()
  end)
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Normal, self, self.uiBinder.trans_time, self.uiBinder.trans_activity)
  self.Logo_ = unionLogoItem.new()
  self.Logo_:Init(self.uiBinder.binder_logo.Go)
  local isListType = self.curType_ == E.UnionRecruitViewType.List
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_btn_root, isListType)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_collection, isListType)
end

function Union_detail_popupView:initOpenState()
  if self.curType_ == E.UnionRecruitViewType.Preview then
    self.curUnionInfo_ = self.unionVM_:GetPlayerUnionInfo()
    local memberData = self.unionVM_:GetUnionMemberData(self.curUnionInfo_.baseInfo.presidentId)
    self.curPresidentSocialData_ = memberData.socialData
    self:refreshUnionInfo()
  else
    self:asyncQueryUnionInfo()
  end
end

function Union_detail_popupView:enableOrDisableBtn(isEnable)
  self.uiBinder.btn_arrow_left.IsDisabled = not isEnable
  self.uiBinder.btn_arrow_right.IsDisabled = not isEnable
end

function Union_detail_popupView:refreshUnionInfo()
  self.uiBinder.scrollview_detail.VerticalNormalizedPosition = 1
  self.uiBinder.lab_union_name.text = self.curUnionInfo_.baseInfo.Name
  self.uiBinder.lab_president_name.text = self.curPresidentSocialData_.basicData.name
  self.uiBinder.lab_grade.text = Lang("LvFormatSymbol", {
    val = self.curUnionInfo_.baseInfo.level
  })
  self.uiBinder.lab_person.text = self.curUnionInfo_.baseInfo.num .. "/" .. self.curUnionInfo_.baseInfo.maxNum
  self.uiBinder.lab_rolelevel.text = Lang("MinimumRolelevel") .. (self.curUnionRecruitInfo_.joinLevel or self.limitLvMin_)
  if self.curUnionRecruitInfo_.slogan == nil or self.curUnionRecruitInfo_.slogan == "" then
    self.uiBinder.lab_bulletin.text = Lang("Notset")
  else
    self.uiBinder.lab_bulletin.text = self.curUnionRecruitInfo_.slogan
  end
  if self.curUnionRecruitInfo_.instruction == nil or self.curUnionRecruitInfo_.instruction == "" then
    self.uiBinder.lab_content.text = Lang("Notset")
  else
    self.uiBinder.lab_content.text = self.curUnionRecruitInfo_.instruction
  end
  local isSelf = self.curUnionInfo_.baseInfo.presidentId == Z.ContainerMgr.CharSerialize.charBase.charId
  local isCollectionUnion = self.unionData_:IsUnionCollection(self.curUnionInfo_.baseInfo.Id)
  local isListType = self.curType_ == E.UnionRecruitViewType.List
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_call, not isSelf)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_collection_on, isCollectionUnion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_left, isListType and 1 < self.curUnionIndex_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_right, isListType and self.curUnionIndex_ < #self.unionDataList_)
  local logoData = self.unionVM_:GetLogoData(self.curUnionInfo_.baseInfo.Icon)
  self.Logo_:SetLogo(logoData)
  self:refreshApplyState()
  self:refreshHeadInfo()
  self:refreshTagInfo()
  self:refreshPhotoUI()
end

function Union_detail_popupView:refreshApplyState()
  if self.curType_ == E.UnionRecruitViewType.Preview then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_application, false)
  else
    local unionData = self.unionDataList_[self.curUnionIndex_]
    local isHadUnion = self.unionVM_:GetPlayerUnionId() ~= 0
    local isHadApply = unionData.isReq
    local isCurUnion = self.unionVM_:GetPlayerUnionId() == unionData.baseInfo.Id
    self.uiBinder.btn_application.IsDisabled = isHadApply
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_application, not isHadUnion)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_cur_union, isCurUnion)
  end
end

function Union_detail_popupView:refreshHeadInfo()
  if self.headItem_ then
    self.headItem_:UnInit()
  end
  self.headItem_ = playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, self.curPresidentSocialData_, function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.curPresidentSocialData_.basicData.charID, self.cancelSource:CreateToken())
    end)()
  end)
end

function Union_detail_popupView:refreshTagInfo()
  local tagIdList = self.curUnionInfo_.baseInfo.tags
  self.unionTagItem_:SetCommonTagUI(tagIdList, self.uiBinder)
end

function Union_detail_popupView:refreshPhotoUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_photo_empty, false)
  local unionData = self.curUnionInfo_
  local imageArray = unionData.baseInfo.coverPhotoInfo.images
  if not imageArray or not next(imageArray) then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  local photoData = imageArray[E.PictureType.ECameraRender]
  if not photoData or string.zisEmpty(photoData.cosUrl) then
    self.uiBinder.rimg_photo:SetImage(Z.ConstValue.UnionRes.DefaultPhotoCover)
    return
  end
  self:getUnionPhoto(unionData.baseInfo.coverPhotoId, photoData.cosUrl)
end

function Union_detail_popupView:getUnionPhoto(photoId, cosUrl)
  local album_main_vm = Z.VMMgr.GetVM("album_main")
  album_main_vm.AsyncGetHttpAlbumPhoto(cosUrl, E.PictureType.ECameraRender, E.NativeTextureCallToken.album_loop_item, self.onPhotoCallBack, self)
end

function Union_detail_popupView:onPhotoCallBack(photoId)
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
  self.photoId = photoId
  self.uiBinder.rimg_photo:SetNativeTexture(photoId)
end

function Union_detail_popupView:switchLastUnion()
  if self.uiBinder.btn_arrow_left.IsDisabled or self.curUnionIndex_ <= 0 then
    return
  end
  self:asyncQueryUnionInfo(self.curUnionIndex_ - 1)
end

function Union_detail_popupView:switchNextUnion()
  if self.uiBinder.btn_arrow_right.IsDisabled or self.curUnionIndex_ >= #self.unionDataList_ then
    return
  end
  self:asyncQueryUnionInfo(self.curUnionIndex_ + 1)
end

function Union_detail_popupView:onCloseBtnClick()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Union_detail_popupView:onCollectionBtnClick()
  local unionData = self.unionDataList_[self.curUnionIndex_]
  local unionId = unionData.baseInfo.Id
  if self.unionData_:IsUnionCollection(unionId) then
    local reply = self.unionVM_:AsyncCancelCollectUnion(unionId, self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode ~= 0 then
      return
    end
  elseif self.unionData_:IsCanCollectUnion() then
    local reply = self.unionVM_:AsyncCollectUnion(unionId, self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode ~= 0 then
      return
    end
  else
    return
  end
  local isCollectionUnion = self.unionData_:IsUnionCollection(unionId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_collection_on, isCollectionUnion)
end

function Union_detail_popupView:onChatBtnClick()
  if self.curUnionInfo_.baseInfo.presidentId == Z.ContainerMgr.CharSerialize.charBase.charId then
    return
  end
  self.unionVM_:CloseUnionMainView()
  local friendsMainVM = Z.VMMgr.GetVM("friends_main")
  friendsMainVM.OpenPrivateChat(self.curUnionInfo_.baseInfo.presidentId)
end

function Union_detail_popupView:onApplyBtnClick()
  if self.unionVM_:GetPlayerUnionId() ~= 0 then
    return
  end
  local reply = self.unionVM_:AsyncReqJoinUnions({
    self.curUnionInfo_.baseInfo.Id
  }, false, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    local curUnionData = self.unionDataList_[self.curUnionIndex_]
    if curUnionData then
      curUnionData.isReq = true
      self:refreshUnionInfo()
      Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.ApplyJoinUnionBack, reply.unionsRet)
    end
  end
end

function Union_detail_popupView:asyncQueryUnionInfo(index)
  Z.CoroUtil.create_coro_xpcall(function()
    self:enableOrDisableBtn(false)
    index = index or self.curUnionIndex_
    local unionData = self.unionDataList_[index]
    local unionId = unionData.baseInfo.Id
    local cacheInfo = self.cacheUnionDetailInfoDict_[unionId]
    if cacheInfo == nil then
      local reply = self.unionVM_:AsyncReqOtherUnionInfo(unionId, self.cancelSource:CreateToken())
      if reply and reply.errorCode ~= 0 then
        self:enableOrDisableBtn(true)
        return
      end
      cacheInfo = {
        info = reply.info,
        recruitInfo = reply.recruitInfo or {},
        presidentInfo = reply.presidentInfo
      }
      self.cacheUnionDetailInfoDict_[unionId] = cacheInfo
    end
    self.curUnionIndex_ = index
    self.curUnionInfo_ = cacheInfo.info
    self.curUnionRecruitInfo_ = cacheInfo.recruitInfo
    self.curUnionRecruitInfo_.slogan = cacheInfo.info.baseInfo.slogan
    self.curPresidentSocialData_ = cacheInfo.presidentInfo
    self:refreshUnionInfo()
    self:enableOrDisableBtn(true)
  end)()
end

function Union_detail_popupView:onOpenPrivateChat()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Union_detail_popupView
