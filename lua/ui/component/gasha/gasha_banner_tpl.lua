local GashaBannerTpl = class("GashaBannerTpl")

function GashaBannerTpl:ctor(banner)
  self.uiBinder = banner
end

function GashaBannerTpl:SetSelfActive(visible, gashaPoolTableRow)
  self.uiBinder.Go:SetActive(visible)
  if visible then
    self:Refresh(gashaPoolTableRow)
  end
end

function GashaBannerTpl:Refresh(gashaPoolTableRow)
  if gashaPoolTableRow.GashaType == 1 then
    self:RefreshFashionBanner(gashaPoolTableRow)
  elseif gashaPoolTableRow.GashaType == 2 then
    self:RefreshVehicleBanner(gashaPoolTableRow)
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
  banner.lab_fashion.text = gashaPoolTableRow.BannerTitle
  banner.lab_name.text = gashaPoolTableRow.BannerTips
  banner.anim:Restart(Z.DOTweenAnimType.Open)
end

function GashaBannerTpl:RefreshVehicleBanner(gashaPoolTableRow)
  local banner = self.uiBinder
  self.uiBinder.Ref:SetVisible(banner.btn_play, true)
  if gashaPoolTableRow == nil then
    return
  end
  local faceData = Z.DataMgr.Get("face_data")
  local playerGender = faceData:GetPlayerGender()
  banner.rimg_banner:SetImage(gashaPoolTableRow.Banner[playerGender][2])
  banner.lab_vehicle.text = gashaPoolTableRow.BannerTitle
  banner.btn_play:AddListener(function()
    banner.Ref:SetVisible(banner.btn_play, false)
    banner.group_video:PlayCurrent(true)
  end)
  banner.anim:CoroPlay(Z.DOTweenAnimType.Open, function()
    banner.group_video:Prepare(gashaPoolTableRow.BannerVideo .. ".mp4", false, true)
    banner.group_video:AddListener(function()
      self.uiBinder.Ref:SetVisible(banner.btn_play, false)
    end, function()
      self.uiBinder.Ref:SetVisible(banner.btn_play, true)
    end)
  end, nil)
end

return GashaBannerTpl
