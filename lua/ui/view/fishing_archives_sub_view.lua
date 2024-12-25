local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_archives_subView = class("Fishing_archives_subView", super)

function Fishing_archives_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_archives_sub", "fishing/fishing_archives_sub", UI.ECacheLv.None)
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.snapShotVM = Z.VMMgr.GetVM("snapshot")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function Fishing_archives_subView:OnActive()
  local showData = self.viewData
  self.charId = showData.CharId
  self:AddClick(self.uiBinder.btn_share, function()
    self.fishingVM_.ShareArchievesToChat()
  end)
  self.dataList_ = showData.DataList
  self.showInChat_ = showData.ShowInChat
  self.titleData = showData.titleData
  self.itemUI_ = {}
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.presscheck:StopCheck()
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
end

function Fishing_archives_subView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Fishing_archives_subView:OnRefresh()
  self:refreshUI()
end

function Fishing_archives_subView:refreshUI()
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.lab_lv.text = self.fishingData_.FishingLevel
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local canUseChat = gotoFuncVM.CheckFuncCanUse(E.FunctionID.MainChat, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, not self.showInChat_ and canUseChat)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_no, self.showInChat_)
  self.uiBinder.node_archives.anchoredPosition = self.showInChat_ and Vector3.New(0, 78) or Vector3.New(64, -30)
  self.uiBinder.lab_title_name.text = self.titleData.Name
  self.uiBinder.lab_title_union.text = self.titleData.UnionName
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
  if socialData.avatarInfo and socialData.avatarInfo.halfBody and not string.zisEmpty(socialData.avatarInfo.halfBody.url) and socialData.avatarInfo.halfBody.verify.ReviewStartTime == E.EPictureReviewType.EPictureReviewed then
    local snapshotVm = Z.VMMgr.GetVM("snapshot")
    local nativeTextureId = snapshotVm.AsyncDownLoadPictureByUrl(socialData.avatarInfo.halfBody.url)
    if nativeTextureId then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_idcard_figure, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard_figure, true)
      self.uiBinder.rimg_idcard_figure:SetNativeTexture(nativeTextureId)
    else
      self:setDefaultModelHalf(socialData)
    end
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

return Fishing_archives_subView
