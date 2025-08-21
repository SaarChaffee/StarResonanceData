local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_video_windowView = class("Gasha_video_windowView", super)

function Gasha_video_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_video_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.faceData_ = Z.DataMgr.Get("face_data")
end

function Gasha_video_windowView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    self.gashaVm_.CloseGashaVideoView()
  end)
  self.gashaId_ = self.viewData.gashaID
  self:playLoopVideo()
end

function Gasha_video_windowView:playLoopVideo()
  self.gashaPoolTableRow_ = Z.TableMgr.GetRow("GashaPoolTableMgr", self.gashaId_)
  if self.gashaPoolTableRow_ == nil then
    self.gashaVm_.CloseGashaVideoView()
    return
  end
  local playerGender = self.faceData_:GetPlayerGender()
  self:PlayAudio()
  self.uiBinder.group_video:Prepare(self.gashaPoolTableRow_.BannerVideo[playerGender] .. ".mp4", false, true)
  self.uiBinder.group_video:AddListener(function()
  end, function()
    self:PlayAudio()
    self.uiBinder.group_video:PlayCurrent(true)
  end)
end

function Gasha_video_windowView:PlayAudio()
  local playerGender = self.faceData_:GetPlayerGender()
  local videoPath = self.gashaPoolTableRow_.BannerVideo[playerGender]
  local array = string.split(videoPath, "/")
  if not array then
    return
  end
  self.audioName = array[#array]
  Z.AudioMgr:Play(self.audioName)
  Z.AudioMgr:PlayBGM(string.zconcat("BGM_", self.audioName))
  Z.AudioMgr:PlayBGM("BGM_System")
end

function Gasha_video_windowView:OnDeActive()
  if self.audioName then
    Z.AudioMgr:StopSound(self.audioName, nil, 0.5)
    Z.AudioMgr:PlayBGM("BGM_Sys_Shop_End")
  end
end

function Gasha_video_windowView:OnRefresh()
end

return Gasha_video_windowView
