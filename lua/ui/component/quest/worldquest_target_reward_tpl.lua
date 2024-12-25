local super = require("ui.component.loopscrollrectitem")
local TargetRewardItem = class("TargetRewardItem", super)
local worladQuestVM = Z.VMMgr.GetVM("worldquest")
local award_loop_item = require("ui.component.award.award_loop_binderitem")
local loopScrollRect = require("ui/component/loopscrollrect")

function TargetRewardItem:OnInit()
  self.cancelSource_ = Z.CancelSource.Rent()
end

function TargetRewardItem:Refresh()
  local index_ = self.component.Index + 1
  local awardData_ = self.parent:GetDataByIndex(index_)
  if self.awardScrollRect_ == nil then
    self.awardScrollRect_ = loopScrollRect.new(self.uiBinder.cont_energy.loopscroll_item, self, award_loop_item)
  end
  local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardData_.rewardId)
  self.uiBinder.cont_energy.lab_energy_num.text = tostring(index_)
  local worldQuestVM = Z.VMMgr.GetVM("worldquest")
  local maxPoint, finishPoint = worldQuestVM.GetFinishPoint()
  if finishPoint >= awardData_.needPoint and not awardData_.bGet then
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.lab_underway, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.cont_btn_2, true)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_red, true)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_completed, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_mask, false)
  elseif awardData_.bGet then
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.lab_underway, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.cont_btn_2, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_red, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_completed, true)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_mask, true)
  else
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.lab_underway, true)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.cont_btn_2, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_completed, false)
    self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_mask, false)
  end
  self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_slider, index_ < finishPoint)
  self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_slider_bg, index_ ~= maxPoint)
  self:rewarldBeGet(awardList, awardData_.bGet)
  self.awardScrollRect_:SetData(awardList)
end

function TargetRewardItem:rewarldBeGet(awardList, bGet)
  for _, data in pairs(awardList) do
    data.beGet = bGet
  end
end

function TargetRewardItem:OnUnInit()
  self.awardScrollRect_:ClearCells()
  if self.cancelSource_ then
    self.cancelSource_:Recycle()
  end
  self.awardScrollRect_ = nil
end

return TargetRewardItem
