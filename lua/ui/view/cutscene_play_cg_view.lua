local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_play_cgView = class("Cutscene_play_cgView", super)

function Cutscene_play_cgView:ctor()
  self.uiBinder = nil
  super.ctor(self, "cutscene_play_cg")
end

function Cutscene_play_cgView:OnActive()
  Z.EventMgr:Add(Z.ConstValue.Cutscene.SeekCG, self.SeekVideo, self)
  Z.EventMgr:Add(Z.ConstValue.Cutscene.PauseSeekCG, self.PauseSeekVideo, self)
end

function Cutscene_play_cgView:OnRefresh()
  self.uiBinder.video:RemoveAllListeners()
  self.uiBinder.video:AddListener(self.viewData.onStarted, nil, nil)
  self.uiBinder.video:Prepare(self.viewData.path, false, true)
end

function Cutscene_play_cgView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Cutscene.SeekCG, self.SeekVideo, self)
  Z.EventMgr:Remove(Z.ConstValue.Cutscene.PauseSeekCG, self.PauseSeekVideo, self)
  self.uiBinder.video:RemoveAllListeners()
  self.uiBinder.video:Stop()
end

function Cutscene_play_cgView:SeekVideo(time)
  self.uiBinder.video:RemoveAllListeners()
  self.uiBinder.video:Seek(time)
end

function Cutscene_play_cgView:PauseSeekVideo(time)
  self.uiBinder.video:PauseSeek(time)
end

return Cutscene_play_cgView
