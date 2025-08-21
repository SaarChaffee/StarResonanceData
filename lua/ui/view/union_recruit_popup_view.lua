local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_recruit_popupView = class("Union_recruit_popupView", super)

function Union_recruit_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_recruit_popup")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_recruit_popupView:OnActive()
  self:bindEvents()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_preview, function()
    self:onPreviewBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:asyncSetRecruit()
  end)
  self.uiBinder.input_lv:AddEndEditListener(function()
    self:onInputLvChange()
  end)
  self.uiBinder.input_slogan:AddListener(function()
    self:onInputSloganChange()
  end)
  self.uiBinder.input_announce:AddListener(function()
    self:onInputAnnounceChange()
  end)
  self.limitLvMin_ = Z.Global.UnionJoinLimitLevel
  local playerLevelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetDatas()
  local maxLevelCfg = playerLevelCfg[#playerLevelCfg]
  self.limitLvMax_ = maxLevelCfg.Level
  self.limitSloganNum_ = Z.Global.UnionJoinSloganMax
  self.limitAnnounceNum_ = Z.Global.UnionJoinDescriptionMax
  self.isHavePower_ = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.ModifyRecruit)
  self:refreshRecruitInfo()
end

function Union_recruit_popupView:OnDeActive()
  self:unBindEvents()
end

function Union_recruit_popupView:OnRefresh()
end

function Union_recruit_popupView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_recruit_popupView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_recruit_popupView:refreshRecruitInfo()
  local recruitInfo = self.unionData_.RecruitInfo or {}
  if recruitInfo.joinLevel and recruitInfo.joinLevel > 0 then
    self.uiBinder.input_lv.text = recruitInfo.joinLevel
  else
    self.uiBinder.input_lv.text = self.limitLvMin_
  end
  self.uiBinder.input_slogan.text = self.unionData_.UnionInfo.baseInfo.slogan or ""
  self:onInputSloganChange()
  self.uiBinder.input_announce.text = recruitInfo.instruction or ""
  self:onInputAnnounceChange()
end

function Union_recruit_popupView:onInputLvChange()
  local curLv = tonumber(self.uiBinder.input_lv.text) or 0
  if curLv < self.limitLvMin_ then
    self.uiBinder.input_lv.text = self.limitLvMin_
  elseif curLv > self.limitLvMax_ then
    self.uiBinder.input_lv.text = self.limitLvMax_
  else
    self.uiBinder.input_lv.text = curLv
  end
  self:checkModify()
end

function Union_recruit_popupView:onInputSloganChange()
  local length = string.zlenNormalize(self.uiBinder.input_slogan.text)
  if length > self.limitSloganNum_ then
    self.uiBinder.input_slogan.text = string.zcutNormalize(self.uiBinder.input_slogan.text, self.limitSloganNum_)
  else
    self.uiBinder.lab_digit_slogan.text = string.zconcat(length, "/", self.limitSloganNum_)
  end
  self:checkModify()
end

function Union_recruit_popupView:onInputAnnounceChange()
  local length = string.zlenNormalize(self.uiBinder.input_announce.text)
  if length > self.limitAnnounceNum_ then
    self.uiBinder.input_announce.text = string.zcutNormalize(self.uiBinder.input_announce.text, self.limitAnnounceNum_)
  else
    self.uiBinder.lab_digit_announce.text = string.zconcat(length, "/", self.limitAnnounceNum_)
  end
  self:checkModify()
end

function Union_recruit_popupView:checkInfoVaild()
  local curLv = tonumber(self.uiBinder.input_lv.text) or 0
  if curLv < self.limitLvMin_ or curLv > self.limitLvMax_ then
    return false
  elseif string.zlenNormalize(self.uiBinder.input_slogan.text) > self.limitSloganNum_ then
    return false
  elseif string.zlenNormalize(self.uiBinder.input_announce.text) > self.limitAnnounceNum_ then
    return false
  else
    return true
  end
end

function Union_recruit_popupView:checkModify()
  if not self.isHavePower_ then
    self.uiBinder.btn_ok.IsDisabled = true
  else
    local recruitInfo = self.unionData_.RecruitInfo or {}
    local curLv = tonumber(self.uiBinder.input_lv.text) or 0
    if curLv ~= recruitInfo.joinLevel or self.uiBinder.input_slogan.text ~= self.unionData_.UnionInfo.baseInfo.slogan or self.uiBinder.input_announce.text ~= recruitInfo.instruction then
      self.uiBinder.btn_ok.IsDisabled = false
    else
      self.uiBinder.btn_ok.IsDisabled = true
    end
  end
end

function Union_recruit_popupView:asyncSetRecruit()
  if not self.isHavePower_ then
    Z.TipsVM.ShowTipsLang(1000527)
  elseif self.uiBinder.btn_ok.IsDisabled then
    Z.TipsVM.ShowTipsLang(1000548)
  elseif self:checkInfoVaild() then
    local level = tonumber(self.uiBinder.input_lv.text)
    local slogan = self.uiBinder.input_slogan.text
    local announce = self.uiBinder.input_announce.text
    local errCode = self.unionVM_:AsyncSetUnionRecruit(level, slogan, announce, self.cancelSource:CreateToken())
    if errCode == 0 then
      Z.TipsVM.ShowTips(1000547)
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end
end

function Union_recruit_popupView:onPreviewBtnClick()
  local unionRecruitInfo = {
    joinLevel = tonumber(self.uiBinder.input_lv.text),
    slogan = self.uiBinder.input_slogan.text,
    instruction = self.uiBinder.input_announce.text
  }
  local viewData = {
    ViewType = E.UnionRecruitViewType.Preview,
    UnionInfo = self.unionVM_:GetPlayerUnionInfo(),
    UnionRecruitInfo = unionRecruitInfo
  }
  self.unionVM_:OpenUnionRecruitDetailView(viewData)
end

function Union_recruit_popupView:onOpenPrivateChat()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Union_recruit_popupView
