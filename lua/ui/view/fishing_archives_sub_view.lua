local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_archives_subView = class("Fishing_archives_subView", super)
local SDKDefine = require("ui.model.sdk_define")

function Fishing_archives_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "fishing_archives_sub", "fishing/fishing_archives_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "fishing_archives_sub", "fishing/fishing_archives_sub", UI.ECacheLv.None)
  end
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.snapShotVM = Z.VMMgr.GetVM("snapshot")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.downloadVm_ = Z.VMMgr.GetVM("download")
end

function Fishing_archives_subView:OnActive()
  local showData = self.viewData
  self.charId = showData.CharId
  self:onStartAnimShow()
  self:initShareNode()
  local isUnlock = self.gotoFuncVM_.FuncIsOn(E.FunctionID.TencentWechatOriginalShare, true)
  self:AddClick(self.uiBinder.btn_share, function()
    if Z.GameContext.IsPC or Z.SDKDevices.IsCloudGame or not isUnlock then
      self.fishingVM_.ShareArchievesToChat()
    else
      self.uiBinder.node_share.Ref.UIComp:SetVisible(true)
      self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_chat.gameObject)
      self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
      self.uiBinder.node_share.group_press_check:AddGameObject(self.uiBinder.node_share.btn_moments.gameObject)
      self.uiBinder.node_share.group_press_check:StartCheck()
    end
  end)
  self.dataList_ = showData.DataList
  self.showInChat_ = showData.ShowInChat
  self.titleData = showData.titleData
  self.isNewbie_ = showData.IsNewbie
  self.itemUI_ = {}
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.presscheck:StopCheck()
  if self.showInChat_ or Z.IsPCUI then
    self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
      if not isContain and self.showInChat_ then
        Z.UIMgr:CloseView("fishing_archives_window")
      end
    end, nil, nil)
    self:AddClick(self.uiBinder.btn_no, function()
      if self.showInChat_ then
        Z.UIMgr:CloseView("fishing_archives_window")
      end
    end)
  else
    self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
    self.uiBinder.node_share.group_press_check:StopCheck()
    self:EventAddAsyncListener(self.uiBinder.node_share.group_press_check.ContainGoEvent, function(isContain)
      if not isContain then
        self.uiBinder.node_share.Ref.UIComp:SetVisible(false)
        self.uiBinder.node_share.group_press_check:StopCheck()
      end
    end, nil, nil)
    self:AddAsyncClick(self.uiBinder.node_share.btn_chat, function()
      self.fishingVM_.ShareArchievesToChat()
    end)
    self:AddAsyncClick(self.uiBinder.node_share.btn_wechat, function()
      self.sdkVM_.SDKOriginalShare({
        SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.Fishing,
        false
      })
    end)
    self:AddAsyncClick(self.uiBinder.node_share.btn_moments, function()
      self.sdkVM_.SDKOriginalShare({
        SDKDefine.ORIGINAL_SHARE_FUNCTION_TYPE.Fishing,
        true
      })
    end)
  end
end

function Fishing_archives_subView:initShareNode()
  if Z.IsPCUI then
    return
  end
  local currentPlatform = Z.SDKLogin.GetPlatform()
  self.uiBinder.node_share.Ref:SetVisible(self.uiBinder.node_share.btn_wechat, currentPlatform == E.LoginPlatformType.TencentPlatform)
  self.uiBinder.node_share.Ref:SetVisible(self.uiBinder.node_share.btn_moments, currentPlatform == E.LoginPlatformType.TencentPlatform)
  if currentPlatform ~= E.LoginPlatformType.TencentPlatform then
    local width = self.uiBinder.node_share.share_frame.rect.width / 3
    self.uiBinder.node_share.share_frame:SetWidth(width)
    self.uiBinder.node_share.share_bg:SetWidth(width)
    local pos = self.uiBinder.node_share.node_chat.localPosition
    self.uiBinder.node_share.node_chat:SetLocalPos(0, pos.y)
  end
end

function Fishing_archives_subView:OnDeActive()
  if not Z.IsPCUI then
    self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_chat.gameObject)
    self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_wechat.gameObject)
    self.uiBinder.node_share.group_press_check:RemoveGameObject(self.uiBinder.node_share.btn_moments.gameObject)
    self.uiBinder.node_share.group_press_check:StopCheck()
  end
  self.uiBinder.presscheck:StopCheck()
end

function Fishing_archives_subView:OnRefresh()
  self:refreshUI()
end

function Fishing_archives_subView:refreshUI()
  self.uiBinder.lab_lv.text = self.fishingData_.FishingLevel
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local canUseChat = gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true)
  if self.showInChat_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, false)
    self.uiBinder.presscheck:StartCheck()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, canUseChat)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_no, self.showInChat_)
  self.uiBinder.node_archives.anchoredPosition = self.showInChat_ and Vector3.New(0, 78) or Vector3.New(64, -30)
  self.uiBinder.lab_title_name.text = self.titleData.Name
  self.uiBinder.lab_title_union.text = self.titleData.UnionName
  if self.isNewbie_ ~= nil and Z.VMMgr.GetVM("player"):IsShowNewbie(self.isNewbie_) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, false)
  end
  self:createArchiesItem()
  self:refreshLeftHeadImg()
end

function Fishing_archives_subView:createArchiesItem()
  if self.isCreating_ then
    return
  end
  self.isCreating_ = true
  Z.CoroUtil.create_coro_xpcall(function()
    for _, v in ipairs(self.itemUI_) do
      self:RemoveUiUnit(v)
    end
    self.itemUI_ = {}
    self.isCreating_ = true
    local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "share_item")
    for k, v in ipairs(self.dataList_) do
      local name = "archives_" .. k
      local item = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_list)
      table.insert(self.itemUI_, name)
      if item then
        item.lab_content_01.text = v.Name
        item.lab_content_02.text = v.Value
      end
    end
    self.isCreating_ = false
  end)()
end

function Fishing_archives_subView:refreshLeftHeadImg()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVm = Z.VMMgr.GetVM("social")
    local socialData = socialVm.AsyncGetSocialData(0, self.charId, self.cancelSource:CreateToken())
    if socialData then
      self:refreshFigureImg(socialData)
    end
  end)()
end

function Fishing_archives_subView:refreshFigureImg(socialData)
  local switchVm = Z.VMMgr.GetVM("switch")
  if switchVm.CheckFuncSwitch(E.FunctionID.DisplayCustomHalfBody) and socialData.avatarInfo and socialData.avatarInfo.halfBody and not string.zisEmpty(socialData.avatarInfo.halfBody.url) and socialData.avatarInfo.halfBody.verify.ReviewStartTime == E.EPictureReviewType.EPictureReviewed then
    local name = self.downloadVm_:GetFileName(socialData.charId, socialData.avatarInfo.halfBody.verify.version, E.HttpPictureDownFoldType.HalfBody)
    self.downloadVm_:GetPicture(name, socialData.avatarInfo.halfBody.url, self.cancelSource:CreateToken(), function(nativeTextureId)
      self:getHalfBodyTextureCallBack(socialData, nativeTextureId)
    end, E.HttpPictureDownFoldType.HalfBody)
  else
    self:setDefaultModelHalf(socialData)
  end
end

function Fishing_archives_subView:getHalfBodyTextureCallBack(socialData, nativeTextureId)
  if self.uiBinder == nil then
    return
  end
  if nativeTextureId and nativeTextureId ~= -1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, true)
    self.uiBinder.rimg_idcard_figure:SetNativeTexture(nativeTextureId)
  else
    self:setDefaultModelHalf(socialData)
  end
end

function Fishing_archives_subView:setDefaultModelHalf(socialData)
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(socialData.basicData.gender, socialData.basicData.bodySize)
  local path = self.snapShotVM.GetModelHalfPortrait(modelId)
  if path ~= nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, false)
    self.uiBinder.img_idcard_figure:SetImage(path)
    self.uiBinder.img_idcard_figure:SetNativeSize()
  else
    logError("ModelHalfPortrait config row is Empty!")
  end
end

function Fishing_archives_subView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Fishing_archives_subView
