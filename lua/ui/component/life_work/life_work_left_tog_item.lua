local super = require("ui.component.loop_list_view_item")
local LifeWorkLeftTogItem = class("LifeWorkLeftTogItem", super)

function LifeWorkLeftTogItem:OnInit()
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.lifeWorkVM = Z.VMMgr.GetVM("life_work")
  self.lifeProfessionWorkData = Z.DataMgr.Get("life_profession_work_data")
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionExpChanged, self.lifeProfessionExpChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeWork.LifeWorkRewardChange, self.lifeWorkRewardChange, self)
end

function LifeWorkLeftTogItem:lifeProfessionLevelChanged(proID)
  if self.data_.ProId == proID then
    self:refreshItem()
  end
end

function LifeWorkLeftTogItem:lifeProfessionExpChanged(proID)
  if self.data_.ProId == proID then
    self:refreshItem()
  end
end

function LifeWorkLeftTogItem:lifeWorkRewardChange()
  self:refreshItem()
end

function LifeWorkLeftTogItem:OnRefresh(data)
  if data == nil then
    return
  end
  self.data_ = data
  self:refreshItem()
  local _, proWorkTabRed = self.lifeProfessionWorkData:GetRedPointID(self.data_.ProId)
  Z.RedPointMgr.LoadRedDotItem(proWorkTabRed, self.parent.UIView, self.uiBinder.Trans)
end

function LifeWorkLeftTogItem:refreshItem()
  self.uiBinder.img_icon_on:SetImage(self.data_.Icon)
  self.uiBinder.img_icon_off:SetImage(self.data_.Icon)
  self.uiBinder.img_icon_locked:SetImage(self.data_.Icon)
  self.uiBinder.lab_name_on.text = self.data_.Name
  self.uiBinder.lab_name_off.text = self.data_.Name
  self.uiBinder.lab_name_locked.text = self.data_.Name
  self.uiBinder.lab_level_on.text = Lang("LifeProfessionLevel", {
    val = self.lifeProfessionVM.GetLifeProfessionLv(self.data_.ProId)
  })
  self.uiBinder.lab_level_off.text = Lang("LifeProfessionLevel", {
    val = self.lifeProfessionVM.GetLifeProfessionLv(self.data_.ProId)
  })
  local curExp, maxExp = self.lifeProfessionVM.GetLifeProfessionExp(self.data_.ProId)
  local isNowMaxLevel = self.lifeProfessionVM.IsLifeProfessionMaxLevel(self.data_.ProId)
  self.uiBinder.lab_exp_on.text = isNowMaxLevel and Lang("LifeProfessionMaxLevel") or Lang("LifeProfessionExp", {cur = curExp, max = maxExp})
  self.uiBinder.lab_exp_off.text = isNowMaxLevel and Lang("LifeProfessionMaxLevel") or Lang("LifeProfessionExp", {cur = curExp, max = maxExp})
  self.uiBinder.img_slider_bar_on.fillAmount = maxExp == 0 and 0 or curExp / maxExp
  self.uiBinder.img_slider_bar_off.fillAmount = maxExp == 0 and 0 or curExp / maxExp
  local isUnlock = self.lifeProfessionVM.IsLifeProfessionUnlocked(self.data_.ProId)
  if not self.lifeProfessionVM.IsLifeProfessionFuncUnlocked(self.data_.ProId, true) then
    self:SetCanSelect(false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlocked_on, isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlocked_off, isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_locked, not isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_locked, not isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  local curWorkingPro = self.lifeWorkVM.GetCurWorkingPro()
  local isWorking = curWorkingPro == self.data_.ProId and not self.lifeWorkVM.IsCurWorkingEnd(self.data_.ProId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_working, isWorking)
end

function LifeWorkLeftTogItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelected)
  if isSelected then
    self.parent.UIView:OnTogSelect(self.data_)
  end
end

function LifeWorkLeftTogItem:OnPointerClick(go, eventData)
  if not self.lifeProfessionVM.IsLifeProfessionFuncUnlocked(self.data_.ProId, false) then
    return
  end
  local isUnlock = self.lifeProfessionVM.IsLifeProfessionUnlocked(self.data_.ProId)
  if not isUnlock then
    self.lifeProfessionVM.OpenUnlockProfessionWindow(self.data_.ProId)
    return
  end
end

function LifeWorkLeftTogItem:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

return LifeWorkLeftTogItem
