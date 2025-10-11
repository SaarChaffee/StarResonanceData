local GashaBannerTpl = class("GashaBannerTpl")

function GashaBannerTpl:ctor(banner, parentView)
  self.uiBinder = banner
  self.parentView_ = parentView
  self:BindEvents()
end

function GashaBannerTpl:Dispose()
  self.uiBinder = nil
  self.parentView_ = nil
  self.isVideoPrepared_ = false
  self:UnBindEvents()
end

function GashaBannerTpl:SetSelfActive(visible, gashaPoolTableRow)
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.isActive_ = visible
  self.uiBinder.Ref.UIComp:SetVisible(visible)
  if visible then
    self:Refresh(gashaPoolTableRow)
  end
end

function GashaBannerTpl:OnVideoWindowClose()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, true)
  self:RevertBannerVideo()
end

function GashaBannerTpl:Refresh(gashaPoolTableRow)
  self.isVideoPrepared_ = false
  self.gashaPoolTableRow_ = gashaPoolTableRow
  if gashaPoolTableRow.GashaType == 1 then
    self:RefreshFashionBanner(gashaPoolTableRow)
  elseif gashaPoolTableRow.GashaType == 2 then
    self:RefreshVehicleBanner(gashaPoolTableRow)
  elseif gashaPoolTableRow.GashaType == 3 then
    self:RefreshBattleSkillBanner(gashaPoolTableRow)
  end
end

function GashaBannerTpl:RefreshFashionBanner(gashaPoolTableRow)
  local banner = self.uiBinder
  if gashaPoolTableRow == nil then
    return
  end
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  banner.rimg_banner:SetImage(gashaPoolTableRow.Banner[playerGender][2])
  banner.rimg_fashion:SetImage(gashaPoolTableRow.BannerTitle)
  local hasVideo = table.zcount(gashaPoolTableRow.BannerVideo) ~= 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, hasVideo)
  banner.btn_play:AddListener(function()
    self:PauseBannerVideo()
    self.uiBinder.Ref:SetVisible(banner.group_video, false)
    self.gashaVm_.OpenGashaVideoView(gashaPoolTableRow.Id)
  end)
  local hasVideo = table.zcount(gashaPoolTableRow.BannerVideo) ~= 0
  local animComplete = function()
    banner.group_video:AddListener(function()
      self.isVideoPrepared_ = true
    end, function()
      if not self.parentView_.IsVisible then
        return
      end
      local comp = self.uiBinder.Ref:GetUIComp(banner.group_video)
      if comp == nil or not comp.IsVisible then
        return
      end
      banner.group_video:PlayCurrent(true)
    end)
    banner.group_video:Prepare(gashaPoolTableRow.BannerVideo[playerGender] .. ".mp4", false, true)
  end
  if not self.parentView_.PlayingVideo then
    if hasVideo then
      animComplete()
    end
  else
    banner.anim:CoroPlay(Z.DOTweenAnimType.Open, function()
      if hasVideo then
        animComplete()
      end
    end, nil)
  end
end

function GashaBannerTpl:RefreshVehicleBanner(gashaPoolTableRow)
  local banner = self.uiBinder
  if gashaPoolTableRow == nil then
    return
  end
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  banner.rimg_banner:SetImage(gashaPoolTableRow.Banner[playerGender][2])
  banner.rimg_vehicle:SetImage(gashaPoolTableRow.BannerTitle)
  local hasVideo = table.zcount(gashaPoolTableRow.BannerVideo) ~= 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, hasVideo)
  banner.btn_play:AddListener(function()
    self:PauseBannerVideo()
    self.uiBinder.Ref:SetVisible(banner.group_video, false)
    self.gashaVm_.OpenGashaVideoView(gashaPoolTableRow.Id)
  end)
  local hasVideo = table.zcount(gashaPoolTableRow.BannerVideo) ~= 0
  local animComplete = function()
    banner.group_video:AddListener(function()
      self.isVideoPrepared_ = true
    end, function()
      if not self.parentView_.IsVisible then
        return
      end
      local comp = self.uiBinder.Ref:GetUIComp(banner.group_video)
      if comp == nil or not comp.IsVisible then
        return
      end
      banner.group_video:PlayCurrent(true)
    end)
    banner.group_video:Prepare(gashaPoolTableRow.BannerVideo[playerGender] .. ".mp4", false, true)
  end
  if not self.parentView_.PlayingVideo then
    if hasVideo then
      animComplete()
    end
  else
    banner.anim:CoroPlay(Z.DOTweenAnimType.Open, function()
      if hasVideo then
        animComplete()
      end
    end, nil)
  end
end

function GashaBannerTpl:RefreshBattleSkillBanner(gashaPoolTableRow)
  local banner = self.uiBinder
  if gashaPoolTableRow == nil then
    return
  end
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  banner.rimg_banner:SetImage(gashaPoolTableRow.Banner[playerGender][2])
  banner.rimg_battle:SetImage(gashaPoolTableRow.BannerTitle)
  self.parentView_:AddAsyncClick(banner.btn_wish, function()
    self.gashaVm_.OpenSelectPrayView(gashaPoolTableRow)
  end)
  local wishFinishNum = self.gashaVm_.GetGashaPoolWishFinishCount(gashaPoolTableRow.Id)
  local maxWishNum = self.gashaVm_.GetGashaPoolWishLimit(gashaPoolTableRow.Id)
  banner.lab_can_wish_num.text = Lang("can_wish_count") .. maxWishNum - wishFinishNum
  banner.Ref:SetVisible(banner.reddot, 0 < maxWishNum - wishFinishNum)
  local wishNum = self.gashaVm_.GetGashaPoolWishValue(gashaPoolTableRow.Id)
  banner.lab_supplication_num.text = wishNum .. "/" .. gashaPoolTableRow.WishNum
  local wishId = self.gashaVm_.GetGashaPoolWishId(gashaPoolTableRow.Id)
  if wishId == 0 then
    banner.Ref:SetVisible(banner.node_supplication_empty, true)
    banner.Ref:SetVisible(banner.node_supplication_have, false)
  else
    banner.Ref:SetVisible(banner.node_supplication_empty, false)
    banner.Ref:SetVisible(banner.node_supplication_have, true)
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(wishId)
    if itemRow == nil then
      return
    end
    local itemVm = Z.VMMgr.GetVM("items")
    banner.rimg_icon:SetImage(itemVm.GetItemIcon(wishId))
  end
end

function GashaBannerTpl:BindEvents()
  if self.onChangeFunc ~= nil then
    return
  end
  
  function self.onChangeFunc(container, dirtyKeys)
    if self.gashaPoolTableRow_ == nil then
      return
    end
    if (dirtyKeys.wishId or dirtyKeys.wishValue or dirtyKeys.wishFinishCount) and self.isActive_ and self.gashaPoolTableRow_.IfWish == 1 then
      self:RefreshBattleSkillBanner(self.gashaPoolTableRow_)
    end
  end
  
  for _, gashaInfo in pairs(Z.ContainerMgr.CharSerialize.gashaData.gashaInfos) do
    gashaInfo.Watcher:RegWatcher(self.onChangeFunc)
  end
end

function GashaBannerTpl:UnBindEvents()
  for _, gashaInfo in pairs(Z.ContainerMgr.CharSerialize.gashaData.gashaInfos) do
    gashaInfo.Watcher:UnregWatcher(self.onChangeFunc)
  end
end

function GashaBannerTpl:RevertBannerVideo()
  local banner = self.uiBinder
  if banner == nil or banner.group_video == nil then
    return
  end
  if self.isVideoPrepared_ then
    banner.group_video:PlayCurrent(false)
  end
end

function GashaBannerTpl:PauseBannerVideo()
  local banner = self.uiBinder
  if banner == nil or banner.group_video == nil then
    return
  end
  if self.isVideoPrepared_ then
    banner.group_video:Pause()
  end
end

return GashaBannerTpl
