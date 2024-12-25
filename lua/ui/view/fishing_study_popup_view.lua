local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_study_popupView = class("Fishing_study_popupView", super)

function Fishing_study_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_study_popup")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function Fishing_study_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.selectFish_ = self.viewData.selectFish
  self.useCount_ = 0
  self.uiBinder.slider_consume.value = 0
  self.researchView_ = self.viewData.researchView
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.fishingVM_.CloseResearchPopWindow()
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    local count_ = math.min(self.useCount_ + 1, self.maxCount)
    self:setCreateCount(count_)
  end)
  self:AddClick(self.uiBinder.btn_max, function()
    self:setCreateCount(self.maxCount)
  end)
  self:AddClick(self.uiBinder.btn_reduce, function()
    local count_ = self.useCount_ - 1
    if count_ < 0 then
      count_ = 0
    end
    self:setCreateCount(count_)
  end)
  self.uiBinder.slider_consume:AddListener(function()
    self.useCount_ = math.floor(self.uiBinder.slider_consume.value)
    self:refreshUI()
  end)
  self:AddAsyncClick(self.uiBinder.btn_sure, function()
    if self.selectFish_ > 0 and 0 < self.useCount_ then
      self.fishingVM_.ResearchFish(self.selectFish_, self.useCount_, self.cancelSource:CreateToken())
      self.researchView_:RefreshUI()
      self.fishingVM_.CloseResearchPopWindow()
    end
  end)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingDataChange, self.refreshUI, self)
end

function Fishing_study_popupView:OnDeActive()
  self.uiBinder.slider_consume:RemoveAllListeners()
end

function Fishing_study_popupView:setCreateCount(count)
  self.uiBinder.slider_consume.value = count
end

function Fishing_study_popupView:refreshUI()
  local fishCfg_ = self.fishingData_.FishRecordDict[self.selectFish_].FishCfg
  self.uiBinder.lab_have.text = string.format(Lang("FishingResearchOwn"), self.haveCount_)
  self.uiBinder.lab_lv.text = string.format(Lang("FishingResearchCurLv"), self.fishingData_.FishRecordDict[self.selectFish_].ResearchLevel)
  self.uiBinder.lab_tips.text = string.format(Lang("FishingResearchUpDes"), self.useCount_, Z.RichTextHelper.ApplyColorTag(fishCfg_.Name, "#D8F453"))
  self.uiBinder.rimg_icon:SetImage(fishCfg_.FishingIcon)
  self.uiBinder.btn_sure.IsDisabled = self.useCount_ <= 0
end

function Fishing_study_popupView:OnRefresh()
  self:refreshData()
  self:refreshUI()
end

function Fishing_study_popupView:refreshData()
  self.haveCount_ = self.itemsVM_.GetItemTotalCount(self.selectFish_)
  local fishCfg_ = self.fishingData_.FishRecordDict[self.selectFish_].FishCfg
  self.maxCount = fishCfg_.FishingResearchExp[#fishCfg_.FishingResearchExp]
  local research_ = 0
  if self.fishingData_.FishRecordDict[self.selectFish_].FishRecord then
    research_ = self.fishingData_.FishRecordDict[self.selectFish_].FishRecord.research
  end
  self.maxCount = math.max(self.maxCount - research_, 0)
  self.maxCount = math.min(self.maxCount, self.haveCount_)
  self.uiBinder.slider_consume.maxValue = self.maxCount
  self.uiBinder.slider_consume.minValue = 0
  self:setCreateCount(0)
end

return Fishing_study_popupView
