local super = require("ui.component.loop_list_view_item")
local InteractionItem = class("InteractionItem", super)
local inputKeyDescComp = require("input.input_key_desc_comp")
local DEFAULT_ICON_PATH = "ui/atlas/npc/talk_icon_chat"
local entityVm = Z.VMMgr.GetVM("entity")

function InteractionItem:OnInit()
  Z.EventMgr:Add(Z.ConstValue.InteractionProgressBegin, self.progressBegin, self)
  Z.EventMgr:Add(Z.ConstValue.InteractionProgressEnd, self.progressEnd, self)
  self:AddAsyncListener(self.uiBinder.btn_interaction, function()
    local handleData = self:GetCurData()
    if handleData == nil then
      return
    end
    handleData:OnBtnClick(self.parent.UIView.cancelSource)
  end)
  self.uiBinder.btn_interaction.OnPointDownEvent:AddListener(function()
    if self.uiBinder.cont_pressdown then
      self.uiBinder.Ref:SetVisible(self.uiBinder.cont_pressdown, true)
    end
  end)
  self.uiBinder.btn_interaction.OnPointUpEvent:AddListener(function()
    if self.uiBinder.cont_pressdown then
      self.uiBinder.Ref:SetVisible(self.uiBinder.cont_pressdown, false)
    end
  end)
  self.keyDescComp_ = inputKeyDescComp.new()
end

function InteractionItem:OnRefresh(handleData)
  local uuid = handleData:GetUuid()
  if uuid then
    local uid = entityVm.UuidToEntId(uuid)
    if Z.IsPCUI then
      Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer_node_pc, E.DynamicSteerType.InteractionId, uid)
    else
      Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer_node, E.DynamicSteerType.InteractionId, uid)
    end
  end
  self.keyDescComp_:Init(1, self.uiBinder.cont_key_icon)
  local content = handleData:GetContentStr()
  if handleData:CheckCondition() == false then
    content = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.TipsRed)
  end
  local iconPath = handleData:GetIcon() or DEFAULT_ICON_PATH
  if self.uiBinder.cont_pressdown then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_pressdown, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_collecting, false)
  self.uiBinder.img_icon:SetImage(iconPath)
  self.uiBinder.lab_content.text = content
  self:refreshItemSelectState()
end

function InteractionItem:OnUnInit()
  self.keyDescComp_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.InteractionProgressBegin, self.progressBegin, self)
  Z.EventMgr:Remove(Z.ConstValue.InteractionProgressEnd, self.progressEnd, self)
end

function InteractionItem:OnSelected()
  self:refreshItemSelectState()
end

function InteractionItem:OnRecycle()
  if Z.IsPCUI then
    self.uiBinder.uisteer_node_pc:ClearSteerList()
  else
    self.uiBinder.uisteer_node:ClearSteerList()
  end
  self.keyDescComp_:UnInit()
  self.uiBinder.img_icon:ClearAll()
  self.uiBinder.lab_content.text = ""
end

function InteractionItem:refreshItemSelectState()
  self.keyDescComp_:SetVisible(Z.IsPCUI and self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_off, not self.IsSelected)
end

function InteractionItem:refreshOptionProgress(progressTime)
  if progressTime and 0 < progressTime then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_off, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_on, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_collecting, true)
    self.uiBinder.img_progress.fillAmount = 0
    self:createProgressTimer(progressTime)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_on, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_collecting, false)
  end
end

function InteractionItem:createProgressTimer(progressTime)
  self:clearProgressTimer()
  self.progressTimer_ = self.parent.UIView.timerMgr:StartTimer(function()
    self.uiBinder.img_progress.fillAmount = self.uiBinder.img_progress.fillAmount + 0.05 / progressTime
  end, 0.05, progressTime / 0.05)
end

function InteractionItem:clearProgressTimer()
  if self.progressTimer_ then
    self.parent.UIView.timerMgr:StopTimer(self.progressTimer_)
    self.progressTimer_ = nil
  end
end

function InteractionItem:progressBegin(btnData)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local unitName = btnData:GetUnitName()
  if unitName == curData:GetUnitName() then
    local progressTime = btnData:GetProgressTime()
    self:refreshOptionProgress(progressTime)
  end
end

function InteractionItem:progressEnd(btnData)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local unitName = btnData:GetUnitName()
  if unitName == curData:GetUnitName() then
    self:refreshOptionProgress(0)
  end
end

return InteractionItem
