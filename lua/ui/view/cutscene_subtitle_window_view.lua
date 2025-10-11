local UI = Z.UI
local super = require("ui.ui_view_base")
local Cutscene_subtitle_windowView = class("Cutscene_subtitle_windowView", super)
local ESubtitleType = Cutscene.ESubtitleType

function Cutscene_subtitle_windowView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.cutscene_subtitle_window.PrefabPath = "cutscene/cutscene_subtitle_window_pc"
  else
    Z.UIConfig.cutscene_subtitle_window.PrefabPath = "cutscene/cutscene_subtitle_window"
  end
  super.ctor(self, "cutscene_subtitle_window")
end

function Cutscene_subtitle_windowView:OnActive()
  self.maxTime_ = self.viewData.maxTime
  self.subTitieCfg_ = Z.TableMgr.GetTable("CutsceneTextTableMgr").GetRow(self.viewData.trackData.Id)
  self:startAnimatedShow()
  Z.EventMgr:Add(Z.ConstValue.SubTitleClose, self.startAnimatedHide, self)
end

function Cutscene_subtitle_windowView:OnDeActive()
  if self.subTitleTimer_ ~= nil then
    self.timerMgr:StopTimer(self.subTitleTimer_)
    self.subTitleTimer_ = nil
  end
end

function Cutscene_subtitle_windowView:OnRefresh()
  self:init()
  self:setBackground()
  if self.viewData.trackData.TimeAdjust then
    local showTime = self.maxTime_ - self.viewData.trackData.DelayTime - self.viewData.trackData.RetentionTime
    if self.subTitleTimer_ ~= nil then
      self.timerMgr:StopTimer(self.subTitleTimer_)
      self.subTitleTimer_ = nil
    end
    if self.viewData.trackData.Karaoke then
      self.subTitleTimer_ = self.timerMgr:StartTimer(function()
        self.labContent_:DoTextAnimByDuration(self.content_, showTime, self.cancelSource:CreateToken())
      end, self.viewData.trackData.DelayTime)
    else
      self.subTitleTimer_ = self.timerMgr:StartTimer(function()
        self.labContent_.text = self.content_
      end, self.viewData.trackData.DelayTime)
    end
  elseif self.viewData.trackData.Karaoke then
    self.labContent_:DoTextAnimByDuration(self.content_, self.maxTime_, self.cancelSource:CreateToken())
  else
    self.labContent_.text = self.content_
  end
end

function Cutscene_subtitle_windowView:setBackground()
  if self.viewData.trackData.Type == ESubtitleType.Middle then
    self.uiBinder.subtitle_center.Ref:SetVisible(self.uiBinder.subtitle_center.img_bg, self.viewData.trackData.Background)
  elseif self.viewData.trackData.Type == ESubtitleType.Dialog then
    self.uiBinder.subtitle_dialog.Ref:SetVisible(self.uiBinder.subtitle_dialog.background, self.viewData.trackData.Background)
  end
end

function Cutscene_subtitle_windowView:init()
  local content = ""
  if self.subTitieCfg_ then
    content = self.subTitieCfg_.TextContent
  end
  local labContentBinder
  if self.viewData.trackData.Type == ESubtitleType.Middle then
    self.labContent_ = self.uiBinder.subtitle_center.lab_content
    labContentBinder = self.uiBinder.subtitle_center
    self.uiBinder.subtitle_bottom.lab_content.text = ""
  elseif self.viewData.trackData.Type == ESubtitleType.Bottom then
    self.labContent_ = self.uiBinder.subtitle_bottom.lab_content
    labContentBinder = self.uiBinder.subtitle_bottom
    self.uiBinder.subtitle_center.lab_content.text = ""
  elseif self.viewData.trackData.Type == ESubtitleType.Dialog then
    self.labContent_ = self.uiBinder.subtitle_dialog.lab_content
    labContentBinder = self.uiBinder.subtitle_dialog
    self.labName_ = self.uiBinder.subtitle_dialog.lab_name
    self.labContent_.text = ""
    local speakerName = ""
    if self.subTitieCfg_ then
      speakerName = self.subTitieCfg_.SpeakerName
    end
    local param = Z.Placeholder.SetMePlaceholder()
    self.labName_.text = Z.Placeholder.Placeholder(speakerName, param)
  end
  if labContentBinder and self.labContent_ then
    labContentBinder.Ref:SetVisible(self.labContent_, true, true)
  end
  local param = Z.Placeholder.SetMePlaceholder()
  param = Z.Placeholder.SetPlayerSelfPronoun(param)
  self.content_ = Z.Placeholder.Placeholder(content, param)
  self.labContent_.text = ""
end

function Cutscene_subtitle_windowView:startAnimatedShow()
  if self.viewData.trackData.Type == ESubtitleType.Middle then
    self.uiBinder.subtitle_center.Ref.UIComp:SetVisible(true)
    self.uiBinder.subtitle_bottom.Ref.UIComp:SetVisible(false)
    self.uiBinder.subtitle_dialog.Ref.UIComp:SetVisible(false)
    if not self.viewData.trackData.DisableOpenAnim then
      self.uiBinder.subtitle_center.anim:PlayOnce("cutscene_plot_window_open")
    else
      self.uiBinder.subtitle_center.Ref:SetVisible(self.uiBinder.subtitle_center.anim, true, true)
      self.uiBinder.subtitle_center.Ref:SetVisible(self.uiBinder.subtitle_center.img_bg_rect, true, true)
    end
  elseif self.viewData.trackData.Type == ESubtitleType.Bottom then
    self.uiBinder.subtitle_center.Ref.UIComp:SetVisible(false)
    self.uiBinder.subtitle_bottom.Ref.UIComp:SetVisible(true)
    self.uiBinder.subtitle_dialog.Ref.UIComp:SetVisible(false)
    if not self.viewData.trackData.DisableOpenAnim then
      self.uiBinder.subtitle_bottom.anim:PlayOnce("cutscene_caption_sub_fade_in")
    else
      self.uiBinder.subtitle_bottom.Ref:SetVisible(self.uiBinder.subtitle_bottom.anim, true, true)
    end
  elseif self.viewData.trackData.Type == ESubtitleType.Dialog then
    self.uiBinder.subtitle_center.Ref.UIComp:SetVisible(false)
    self.uiBinder.subtitle_bottom.Ref.UIComp:SetVisible(false)
    self.uiBinder.subtitle_dialog.Ref.UIComp:SetVisible(true)
    if not self.viewData.trackData.DisableOpenAnim then
      self.uiBinder.subtitle_dialog.anim:PlayOnce("anim_subtitle_dialog_open")
    else
      self.uiBinder.subtitle_dialog.Ref:SetVisible(self.uiBinder.subtitle_dialog.background, true, true)
      self.uiBinder.subtitle_dialog.Ref:SetVisible(self.uiBinder.subtitle_dialog.img_bg, true, true)
      self.uiBinder.subtitle_dialog.Ref:SetVisible(self.uiBinder.subtitle_dialog.anim, true, true)
    end
  end
end

function Cutscene_subtitle_windowView:startAnimatedHide()
  if self.viewData.trackData.DisableCloseAnim then
    return
  end
  if self.viewData.trackData.Type == ESubtitleType.Middle then
    self.uiBinder.subtitle_center.anim:PlayOnce("cutscene_plot_window_close")
  elseif self.viewData.trackData.Type == ESubtitleType.Bottom then
    self.uiBinder.subtitle_bottom.anim:PlayOnce("cutscene_caption_sub_fade_out")
  elseif self.viewData.trackData.Type == ESubtitleType.Dialog then
    self.uiBinder.subtitle_dialog.anim:PlayOnce("anim_subtitle_dialog_close")
  end
end

return Cutscene_subtitle_windowView
