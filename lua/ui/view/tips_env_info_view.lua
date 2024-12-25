local UI = Z.UI
local super = require("ui.ui_subview_base")
local Tips_env_infoView = class("Tips_env_infoView", super)
local DEFAULT_DESC_COLOR = Color.New(1, 1, 1, 1)

function Tips_env_infoView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_env_info", "common_tips_new/tips_env_info", UI.ECacheLv.None)
end

function Tips_env_infoView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
end

function Tips_env_infoView:OnDeActive()
end

function Tips_env_infoView:OnRefresh()
  self:clearEnvTimer()
  self:SetTipsInfo()
end

function Tips_env_infoView:SetTipsInfo()
  self:SetUIVisible(self.uiBinder.node_lock, self.viewData.state == E.EnvResonanceSkillState.Lock)
  self:SetUIVisible(self.uiBinder.node_unlock, self.viewData.state ~= E.EnvResonanceSkillState.Lock)
  self.uiBinder.lab_title.text = self.viewData.title
  if self.viewData.iconPath then
    self.uiBinder.img_icon:SetImage(self.viewData.iconPath)
  end
  self:SetUIVisible(self.uiBinder.img_icon, self.viewData.iconPath ~= nil)
  self.uiBinder.lab_func_name.text = self.viewData.funcName
  self.uiBinder.lab_area_name.text = self.viewData.areaName
  local isShowEmpty = self.viewData.state == E.EnvResonanceSkillState.Lock or self.viewData.state == E.EnvResonanceSkillState.NotActive
  self:SetUIVisible(self.uiBinder.lab_area_name, isShowEmpty)
  self:SetUIVisible(self.uiBinder.img_icon_empty, isShowEmpty)
  self.uiBinder.img_icon:SetColor(isShowEmpty and Color.New(1, 1, 1, 0.1) or Color.New(1, 1, 1, 1))
  self:setLabelText(self.uiBinder.lab_tag, self.viewData.stateDesc, self.viewData.stateColor)
  self.uiBinder.img_tag_bg:SetColor(self.viewData.stateColor)
  self.uiBinder.lab_effect_time.text = self.viewData.effectTime
  self.uiBinder.lab_current_desc.text = self.viewData.currentDesc
  self:SetUIVisible(self.uiBinder.node_current, self.viewData.currentDesc ~= "")
  self.uiBinder.lab_next_desc.text = self.viewData.nextDesc
  self:SetUIVisible(self.uiBinder.node_next, self.viewData.nextDesc ~= "")
  self.uiBinder.lab_desc.text = self.viewData.skillDesc
  self:SetUIVisible(self.uiBinder.node_desc, self.viewData.skillDesc ~= "")
  self.uiBinder.lab_item_name.text = self.viewData.itemName
  if self.viewData.showTime then
    self:SetUIVisible(self.uiBinder.node_time, true)
    self:createEnvTimer()
  else
    self:SetUIVisible(self.uiBinder.node_time, false)
  end
end

function Tips_env_infoView:setLabelText(comp, str, color)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(comp, str)
  comp.color = color or DEFAULT_DESC_COLOR
end

function Tips_env_infoView:setTimeLabel(count)
  self.uiBinder.lab_time.text = Z.TimeTools.FormatToDHM(count)
end

function Tips_env_infoView:createEnvTimer()
  local count = self.viewData.showTime
  self:setTimeLabel(count)
  self.envTimer_ = self.timerMgr:StartTimer(function()
    count = count - 1
    self:setTimeLabel(count)
  end, 1, self.viewData.showTime)
end

function Tips_env_infoView:clearEnvTimer()
  if self.envTimer_ then
    self.envTimer_:Stop()
    self.envTimer_ = nil
  end
end

return Tips_env_infoView
