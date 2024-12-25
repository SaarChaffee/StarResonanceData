local UI = Z.UI
local super = require("ui.ui_view_base")
local Proficiency_mainView = class("Proficiency_mainView", super)
local loopscrollrect = require("ui/component/loopscrollrect")
local proficiencyItme = require("ui/component/proficiency/proficiency_loop_item")

function Proficiency_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "proficiency_main")
  self.proficiencyVm_ = Z.VMMgr.GetVM("proficiency")
  self.profilciencyData_ = Z.DataMgr.Get("proficiency_data")
  self.tipSub_ = require("ui/view/proficiency_tips_sub_view").new(self)
end

function Proficiency_mainView:initUiBinders()
  self.UiDepth = self.uiBinder.uidepth
end

function Proficiency_mainView:OnActive()
  self:initUiBinders()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:DoCameraAnim("proficiencyEnter")
  self.lastItemIndex_ = -1
  self.lastItemDataIndex_ = -1
  self.selectData_ = {}
  self.isActive_ = false
  self.isUnLock_ = false
  self.isGrade_ = false
  self.level_ = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.profilciencyData_:InitProficiency()
  self:AddClick(self.uiBinder.cont_title_return.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(30016)
  end)
  self:AddClick(self.uiBinder.btn_tips, function()
    local rolelevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
    rolelevelVm_.OpenRoleLevelWayWindow()
  end)
  self:AddClick(self.uiBinder.cont_title_return.btn, function()
    self.proficiencyVm_.CloseProficiencyView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_activated, function()
    if not (self.selectData_ and self.isUnLock_) or not self.isGrade_ then
      return
    end
    if self.isActive_ and self.selectData_.Deactive then
      return
    end
    if self.isActive_ then
      self.proficiencyVm_.NotActiveLevel(self.selectData_.ActiveLevel)
    else
      local buffId = self.profilciencyData_:GetLevelActivationId(self.selectData_.ActiveLevel)
      if buffId and buffId ~= self.selectData_.BuffId then
        self.proficiencyVm_.NotActiveLevel(self.selectData_.ActiveLevel)
      end
      self.proficiencyVm_.SetActiveLevel(self.selectData_.ActiveLevel, self.selectData_.BuffId)
    end
    local ret = self.proficiencyVm_.AsyncSetProficiency(self.profilciencyData_:GetPotentialTab(), self.cancelSource:CreateToken())
    if ret == 0 then
      self.isActive_ = not self.isActive_
      self:changeSaveBtn(self.isUnLock_ and self.isGrade_)
      self:setActiveBtnState(self.isUnLock_, self.isActive_, self.selectData_)
      self.proficiencyRect:UpDateByIndex(self.lastItemIndex_, {})
    end
  end, nil, nil)
  self:AddAsyncClick(self.uiBinder.btn_reset, function()
    if self.profilciencyData_:GetIsRefresh() then
      local onConfirm = function()
        self.proficiencyVm_.NotActvationAll()
        local ret = self.proficiencyVm_.AsyncSetProficiency(self.profilciencyData_:GetPotentialTab(), self.cancelSource:CreateToken())
        if ret == 0 then
          self.isActive_ = false
          self:setActiveBtnState(self.isUnLock_, self.isActive_, self.selectData_)
          self.proficiencyRect:SetData(self.proficiencyVm_.GetProficiencyData())
          self.proficiencyRect:SetSelected(0)
        end
        Z.DialogViewDataMgr:CloseDialogView()
      end
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("ProficiencyIsReset"), onConfirm)
    end
  end)
  self:init()
  self:BindEvents()
end

function Proficiency_mainView:init()
  self:changeSaveBtn(false)
  self.uiBinder.lab_grade.text = self.level_
  local vLoopScrollRect = self.uiBinder.loopscroll_grade
  self.proficiencyRect = loopscrollrect.new(vLoopScrollRect, self, proficiencyItme)
  self.proficiencyRect:SetData(self.proficiencyVm_.GetProficiencyData())
  self.proficiencyRect:SetSelected(0)
end

function Proficiency_mainView:unLock()
  if self.selectData_ then
    local ret = self.proficiencyVm_.AsyncUnlockProficiency(self.selectData_.ActiveLevel, self.selectData_.BuffId, self.cancelSource:CreateToken())
    if ret == 0 then
      self.proficiencyRect:UpDateByIndex(self.lastItemIndex_, {})
    end
  end
end

function Proficiency_mainView:SelectProficiencyItem(index, itemData, dataIndex, isActive, isUnLock, isGrade)
  self.selectData_ = itemData[dataIndex]
  self.isActive_ = isActive
  self.isUnLock_ = isUnLock
  self.isGrade_ = isGrade
  self.tipSub_:DeActive()
  self.tipSub_:Active(self.selectData_, self.uiBinder.cont_tips_small.anim)
  if self.lastItemIndex_ == index and dataIndex == self.lastItemDataIndex_ or self.selectData_ == nil then
    return
  end
  self.proficiencyRect:UpDateByIndex(self.lastItemIndex_, nil)
  self.lastItemIndex_ = index
  self.lastItemDataIndex_ = dataIndex
  self:changeSaveBtn(isUnLock and isGrade)
  self:setActiveBtnState(isUnLock, isActive, self.selectData_)
end

function Proficiency_mainView:setActiveBtnState(isUnLock, isActive, data)
  local str
  if not isUnLock then
    str = string.format(Lang("ProficiencyUnlock"), data.ActiveLevel)
  elseif isActive then
    if data.Deactive then
      str = Lang("NotCancelled")
    else
      str = Lang("ProficiencyUnActive")
    end
  else
    str = Lang("ProficiencyActive")
  end
  self.uiBinder.lab_content.text = str
end

function Proficiency_mainView:changeSaveBtn(isChange)
  if isChange and self.isActive_ then
    isChange = not self.selectData_.Deactive
  end
  self.uiBinder.btn_activated.IsDisabled = not isChange
  local isRefresh = self.profilciencyData_:GetIsRefresh()
  self.uiBinder.btn_reset.IsDisabled = not isRefresh
end

function Proficiency_mainView:OnDeActive()
  self.proficiencyRect:ClearCells()
  if self.helpTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.helpTipsId_)
    self.helpTipsId_ = nil
  end
  self.tipSub_:DeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.selectData_ = {}
  self.isActive_ = false
  self.isUnLock_ = false
  self.isGrade_ = false
end

function Proficiency_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("proficiency_main")
end

function Proficiency_mainView:onItemCountChange(item)
  if table.zcount(self.selectData_.LockItem) == 0 then
    return
  end
  if not self.proficiencyVm_.GetIsLockByLevelAndBuffId(self.selectData_.LockItem, self.selectData_.ActiveLevel, self.selectData_.BuffId) then
    for key, popupItemData in pairs(self.selectData_.LockItem) do
      if popupItemData.ConfigId == item.configId then
        self.tipSub_:Active(self.selectData_, self.uiBinder.cont_tips_small.anim)
      end
    end
  end
end

function Proficiency_mainView:BindEvents()
  Z.EventMgr:Add("RefreshSaveBtn", self.changeSaveBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
end

function Proficiency_mainView:OnRefresh()
end

function Proficiency_mainView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Proficiency_mainView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
end

return Proficiency_mainView
