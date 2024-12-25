local super = require("ui.component.loopscrollrectitem")
local ProficiencyItem = class("ProficiencyItem", super)

function ProficiencyItem:ctor()
  self.profilciencyData_ = Z.DataMgr.Get("proficiency_data")
  self.proficiencyVm_ = Z.VMMgr.GetVM("proficiency")
end

function ProficiencyItem:OnInit()
  self.parentView_ = self.parent.uiView
  self.level_ = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.nowSelectIdnex_ = 0
  self.cont_skill_list_ = {
    cont_skill_01 = self.uiBinder.cont_skill_01,
    cont_skill_02 = self.uiBinder.cont_skill_02,
    cont_skill_03 = self.uiBinder.cont_skill_03
  }
  self:AddClick(self.uiBinder.cont_skill_01.btn, function()
    self:btnClickFunc(self.itemData_[1], self.uiBinder.cont_skill_01, 1)
    self.nowSelectIdnex_ = 1
  end)
  self:AddClick(self.uiBinder.cont_skill_02.btn, function()
    self:btnClickFunc(self.itemData_[2], self.uiBinder.cont_skill_02, 2)
    self.nowSelectIdnex_ = 2
  end)
  self:AddClick(self.uiBinder.cont_skill_03.btn, function()
    self:btnClickFunc(self.itemData_[1], self.uiBinder.cont_skill_03, 1)
    self.nowSelectIdnex_ = 3
  end)
  self.parentView_.UiDepth:AddChildDepth(self.cont_skill_list_.cont_skill_01.eff_root_switch)
  self.parentView_.UiDepth:AddChildDepth(self.cont_skill_list_.cont_skill_02.eff_root_switch)
  self.parentView_.UiDepth:AddChildDepth(self.cont_skill_list_.cont_skill_03.eff_root_switch)
end

function ProficiencyItem:btnClickFunc(data, item, index)
  if data == nil or item == nil then
    return
  end
  local isUnLock = self.proficiencyVm_.GetIsLockByLevelAndBuffId(data.LockItem, data.ActiveLevel, data.BuffId)
  local isActive = self.proficiencyVm_.IsActiveByItemData(data)
  local isGrade = self.level_ >= data.ActiveLevel
  self.parentView_:SelectProficiencyItem(self.component.Index, self.itemData_, index, isActive, isUnLock, isGrade)
  if self.profilciencyData_.ProficiencyNewItem[data.BuffId] then
    self.profilciencyData_.ProficiencyNewItem[data.BuffId] = nil
    Z.RedPointMgr.RefreshClientNodeCount(E.RedType.RoleMainRolelevelBtn, table.zcount(self.profilciencyData_.ProficiencyNewItem))
    item.Ref:SetVisible(item.img_dot, false)
  end
  self:setSelectState(item, true)
end

function ProficiencyItem:refreshItemStateByData(item, data)
  local buffId = self.profilciencyData_:GetLevelActivationId(self.itemData_[1].ActiveLevel)
  if data.ActiveLevel > self.level_ then
    self:refreshItemStateByType(item, E.ProficiencyItemState.NotGrade)
  elseif buffId and buffId == data.BuffId then
    self:refreshItemStateByType(item, E.ProficiencyItemState.On)
    self:playSelectAnima(item)
  else
    local isUnLock = self.proficiencyVm_.GetIsLockByLevelAndBuffId(data.LockItem, data.ActiveLevel, data.BuffId)
    if isUnLock then
      self:refreshItemStateByType(item, E.ProficiencyItemState.Off)
    else
      self:refreshItemStateByType(item, E.ProficiencyItemState.NotLock)
    end
  end
  item.Ref:SetVisible(item.img_dot, self.profilciencyData_.ProficiencyNewItem[data.BuffId] ~= nil)
end

function ProficiencyItem:refreshState()
  if self.itemData_[2] then
    self:refreshItemStateByData(self.uiBinder.cont_skill_01, self.itemData_[1])
    self:refreshItemStateByData(self.uiBinder.cont_skill_02, self.itemData_[2])
  else
    self:refreshItemStateByData(self.uiBinder.cont_skill_03, self.itemData_[1])
  end
end

function ProficiencyItem:setItemIcon(item, icom)
  self:setProficiencyLoopItemIcon(item, icom)
  self:setSelectState(item, false)
end

function ProficiencyItem:setProficiencyLoopItemIcon(item, iconPath)
  if item == nil then
    return
  end
  item.img_icon_on:SetImage(iconPath)
  item.img_icon_off:SetImage(iconPath)
  item.img_icon_grade:SetImage(iconPath)
  item.img_icon_unlocked:SetImage(iconPath)
end

function ProficiencyItem:refreshItemStateByType(item, type)
  if item == nil then
    return
  end
  item.Ref:SetVisible(item.node_on, E.ProficiencyItemState.On == type)
  item.Ref:SetVisible(item.node_off, E.ProficiencyItemState.Off == type)
  item.Ref:SetVisible(item.node_not_unlocked, E.ProficiencyItemState.NotLock == type)
  item.Ref:SetVisible(item.node_not_grade, E.ProficiencyItemState.NotGrade == type)
end

function ProficiencyItem:Refresh()
  self.index_ = self.component.Index + 1
  self.itemData_ = self.parent:GetDataByIndex(self.index_)
  self:initUi()
  self:refreshState()
end

function ProficiencyItem:initUi()
  self:refreshItemStateByType(self.uiBinder.cont_skill_01, E.ProficiencyItemState.None)
  self:refreshItemStateByType(self.uiBinder.cont_skill_02, E.ProficiencyItemState.None)
  self:refreshItemStateByType(self.uiBinder.cont_skill_03, E.ProficiencyItemState.None)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_skill, self.itemData_[2] ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_skill_one, self.itemData_[2] == nil)
  if self.itemData_[2] ~= nil then
    local rightBuffData = self.proficiencyVm_.GetBuffData(self.itemData_[2].BuffId)
    if rightBuffData then
      self:setItemIcon(self.uiBinder.cont_skill_02, rightBuffData.Icon)
    end
  end
  local leftBuffData = self.proficiencyVm_.GetBuffData(self.itemData_[1].BuffId)
  if leftBuffData then
    self:setItemIcon(self.uiBinder.cont_skill_01, leftBuffData.Icon)
    self:setItemIcon(self.uiBinder.cont_skill_03, leftBuffData.Icon)
  end
  local isShow = self.level_ >= self.itemData_[1].ActiveLevel
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade_on, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_grade_off, not isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot_off, not isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot_on, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_on1, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_on2, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_off1, not isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_off2, not isShow)
  self.uiBinder.lab_grade_on.text = self.itemData_[1].ActiveLevel
  self.uiBinder.lab_grade_off.text = self.itemData_[1].ActiveLevel
  local diff = 0
  if self.level_ >= self.itemData_[1].ActiveLevel then
    diff = 1
    if self.level_ < self.itemData_[1].NextLevel then
      local levelDiff = self.level_ - self.itemData_[1].ActiveLevel
      local nextLevelDiff = self.itemData_[1].NextLevel - self.itemData_[1].ActiveLevel
      diff = levelDiff / nextLevelDiff
    end
  else
    diff = 0
    self.uiBinder.cont_skill_01.Ref:SetVisible(self.uiBinder.cont_skill_01.node_not_unlocked, true)
    self.uiBinder.cont_skill_02.Ref:SetVisible(self.uiBinder.cont_skill_02.node_not_unlocked, true)
    self.uiBinder.cont_skill_03.Ref:SetVisible(self.uiBinder.cont_skill_03.node_not_unlocked, true)
  end
  self.uiBinder.img_line_on.fillAmount = diff
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_line, self.index_ ~= self.parent:GetCount())
end

function ProficiencyItem:Selected(selected)
  if not self.profilciencyData_.IsFrist then
    return
  end
  if selected and self.component.Index == 0 then
    self:SelectedFirst()
    self.profilciencyData_.IsFrist = false
  end
end

function ProficiencyItem:SelectedFirst()
  local buffId = self.profilciencyData_:GetLevelActivationId(self.itemData_[1].ActiveLevel)
  local isUnLock = self.proficiencyVm_.GetIsLockByLevelAndBuffId(self.itemData_[1].LockItem, self.itemData_[1].ActiveLevel, self.itemData_[1].BuffId)
  local isGrade = self.level_ >= self.itemData_[1].ActiveLevel
  if not buffId then
    self.parentView_:SelectProficiencyItem(self.component.Index, self.itemData_, 1, false, isUnLock, isGrade)
    self:setSelectState(self.uiBinder.cont_skill_01, true)
    self:setSelectState(self.uiBinder.cont_skill_03, true)
    self.nowSelectIdnex_ = self.itemData_[2] and 1 or 3
  elseif self.itemData_[1].BuffId == buffId then
    self.parentView_:SelectProficiencyItem(self.component.Index, self.itemData_, 1, true, isUnLock, isGrade)
    self:setSelectState(self.uiBinder.cont_skill_01, true)
    self:setSelectState(self.uiBinder.cont_skill_03, true)
    self.nowSelectIdnex_ = self.itemData_[2] and 1 or 3
  else
    self.parentView_:SelectProficiencyItem(self.component.Index, self.itemData_, 2, true, isUnLock, isGrade)
    self:setSelectState(self.uiBinder.cont_skill_02, true)
    self.nowSelectIdnex_ = 2
  end
end

function ProficiencyItem:UpdateData(data)
  if data == nil then
    self:setSelectState(self.uiBinder.cont_skill_01, false)
    self:setSelectState(self.uiBinder.cont_skill_02, false)
    self:setSelectState(self.uiBinder.cont_skill_03, false)
  else
    if self.nowSelectIdnex_ == 2 then
      self:btnClickFunc(self.itemData_[2], self.uiBinder.cont_skill_02, 2)
      self:playUnLockAnima(self.uiBinder.cont_skill_02)
    else
      self:btnClickFunc(self.itemData_[1], self.uiBinder["cont_skill_0" .. self.nowSelectIdnex_], 1)
      self:playUnLockAnima(self.uiBinder["cont_skill_0" .. self.nowSelectIdnex_])
    end
    self:refreshState()
  end
end

function ProficiencyItem:setSelectState(item, state)
  item.Ref:SetVisible(item.img_right, state)
  self:playSelectAnima(item)
end

function ProficiencyItem:playUnLockAnima(item)
  Z.AudioMgr:Play("UI_Event_Magic_C")
  item.eff_root_switch:SetEffectGoVisible(true)
end

function ProficiencyItem:playSelectAnima(item)
  item.anim_skill:PlayLoop("ui_anim_proficiency_skill_tpl_node_on_loop")
end

function ProficiencyItem:OnBeforePlayAnim()
  self.uiBinder.anim_group.OnPlay:AddListener(function()
    self.uiBinder.UIComp:SetVisible(true)
  end)
  local groupAnimComp = self.parent:GetContainerGroupAnimComp()
  if groupAnimComp then
    groupAnimComp:AddTweenContainer(self.uiBinder.anim_group)
    self.uiBinder.UIComp:SetVisible(false)
  end
end

function ProficiencyItem:OnUnInit()
  self.cont_skill_list_.cont_skill_01.eff_root_switch:SetEffectGoVisible(false)
  self.cont_skill_list_.cont_skill_02.eff_root_switch:SetEffectGoVisible(false)
  self.cont_skill_list_.cont_skill_03.eff_root_switch:SetEffectGoVisible(false)
  self.parentView_.UiDepth:RemoveChildDepth(self.cont_skill_list_.cont_skill_01.eff_root_switch)
  self.parentView_.UiDepth:RemoveChildDepth(self.cont_skill_list_.cont_skill_02.eff_root_switch)
  self.parentView_.UiDepth:RemoveChildDepth(self.cont_skill_list_.cont_skill_03.eff_root_switch)
  self.cont_skill_list_ = nil
end

return ProficiencyItem
