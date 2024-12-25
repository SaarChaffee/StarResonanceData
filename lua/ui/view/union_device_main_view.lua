local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_device_mainView = class("Union_device_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local union_loop_buff_item = require("ui.component.union.union_loop_buff_item")
local unionBuffitem = require("ui.component.union.union_buff_item")
local MAX_BUFF_COUNT = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT

function Union_device_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_device_main")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.commonVM = Z.VMMgr.GetVM("common")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_device_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:bindEvents()
  self:initData()
  self:initComponent()
  self:initLoopListView()
  self:initQuery()
end

function Union_device_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.buildConfig_.NpcId and self.buildConfig_.NpcId ~= 0 then
    Z.CameraMgr:CloseDialogCamera()
  else
    Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.buildConfig_.CameraTemplateId, false)
  end
  self:clearBuffTimer()
  self:unBindEvents()
  self:unInitBuffItem()
  self:unInitLoopListView()
  self:closeItemTips()
end

function Union_device_mainView:OnRefresh()
end

function Union_device_mainView:initData()
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.unionTimelinessBuffTableMgr_ = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr")
  self.buildConfig_ = self.unionVM_:GetUnionBuildConfig(E.UnionBuildId.Buff)
  self.allBuffConfigList_ = {}
  self.curSelectedBuffId_ = nil
  self.curBuffSlotIndex_ = nil
  self.curEquipBuffDict_ = self.unionVM_:GetEquipBuffInfoDict()
  local configDict = self.unionTimelinessBuffTableMgr_:GetDatas()
  for _, config in pairs(configDict) do
    table.insert(self.allBuffConfigList_, config)
  end
  self.buffItemDict_ = {}
  self.isSetBySelf_ = false
  self.updateSlotDict_ = {}
end

function Union_device_mainView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(5001062)
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:onConfirmBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    self:onCancelBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_cost, function()
    self:onCostBtnClick()
  end)
  if self.buildConfig_.NpcUId and self.buildConfig_.NpcUId ~= 0 then
    Z.NpcBehaviourMgr:SetDialogCameraByConfigId(301, self.buildConfig_.NpcUId)
  else
    Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, self.buildConfig_.CameraTemplateId, false)
  end
end

function Union_device_mainView:initQuery()
  Z.CoroUtil.create_coro_xpcall(function()
    local reply = self.unionVM_:AsyncReqUnionInfo(self.unionVM_:GetPlayerUnionId(), self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode == 0 then
      self:resetData()
      self:refreshTotalInfo()
    end
  end)()
end

function Union_device_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionBuildBuffInfoChange, self.onUnionBuildBuffInfoChange, self)
end

function Union_device_mainView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionBuildBuffInfoChange, self.onUnionBuildBuffInfoChange, self)
end

function Union_device_mainView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, union_loop_buff_item, "union_effect_item_tpl")
  self:SortBuffList()
  self.loopListView_:Init(self.allBuffConfigList_)
end

function Union_device_mainView:refreshLoopListView()
  self.loopListView_:ClearAllSelect()
  self:SortBuffList()
  self.loopListView_:RefreshListView(self.allBuffConfigList_)
end

function Union_device_mainView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_device_mainView:SortBuffList()
  table.sort(self.allBuffConfigList_, function(a, b)
    local a_unlockState = self.unionVM_:CheckUnionBuffUnlock(a.Id) and 1 or 0
    local b_unlockState = self.unionVM_:CheckUnionBuffUnlock(b.Id) and 1 or 0
    if a_unlockState == b_unlockState then
      return a.Id < b.Id
    else
      return a_unlockState > b_unlockState
    end
  end)
end

function Union_device_mainView:refreshBuffItem()
  self:clearBuffTimer()
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  self.updateSlotDict_ = {}
  for i = 1, MAX_BUFF_COUNT do
    local curBuffId
    local curBuffInfo = self.unionData_.BuildBuffInfo[i]
    if curBuffInfo and curServerTime < curBuffInfo.endTime then
      curBuffId = curBuffInfo.effectBuffId
      self.updateSlotDict_[i] = curBuffInfo
    end
    local binder_root = self.uiBinder["binder_buff_root_" .. i]
    if binder_root then
      do
        local item = binder_root.binder_buff_item
        local buffItemData = {
          BuffId = curBuffId,
          SlotIndex = i,
          IgnoreClick = false,
          IsSelect = self.curBuffSlotIndex_ and self.curBuffSlotIndex_ == i
        }
        if curBuffId == nil then
          function buffItemData.ClickFunc()
            self:onBuffAddBtnClick(curBuffId, i)
          end
        end
        if self.buffItemDict_[i] == nil then
          self.buffItemDict_[i] = unionBuffitem.new()
          self.buffItemDict_[i]:Init(item, buffItemData)
        else
          self.buffItemDict_[i]:Refresh(buffItemData)
        end
        binder_root.Ref:SetVisible(binder_root.trans_time, curBuffId ~= nil)
        binder_root.Ref:SetVisible(binder_root.trans_empty, curBuffId == nil)
      end
    end
  end
  if next(self.updateSlotDict_) ~= nil then
    self:createBuffTimer()
  end
end

function Union_device_mainView:unInitBuffItem()
  for key, item in pairs(self.buffItemDict_) do
    item:UnInit()
  end
  self.buffItemDict_ = nil
end

function Union_device_mainView:onTimerUpdate()
  for slotIndex, info in pairs(self.updateSlotDict_) do
    local binder_root = self.uiBinder["binder_buff_root_" .. slotIndex]
    if binder_root then
      local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
      local leftTime = info.endTime - curServerTime
      if leftTime <= -1 then
        self:clearBuffTimer()
        self:resetData()
        self:refreshTotalInfo()
        return
      end
      if leftTime < 0 then
        leftTime = 0
      end
      binder_root.lab_time.text = Z.TimeTools.S2HMSFormat(leftTime)
    end
  end
end

function Union_device_mainView:createBuffTimer()
  self:clearBuffTimer()
  self:onTimerUpdate()
  self.buffTimer_ = self.timerMgr:StartTimer(function()
    self:onTimerUpdate()
  end, 1, -1)
end

function Union_device_mainView:clearBuffTimer()
  if self.buffTimer_ then
    self.buffTimer_:Stop()
    self.buffTimer_ = nil
  end
end

function Union_device_mainView:resetData()
  self.curSelectedBuffId_ = nil
  self.curBuffSlotIndex_ = nil
  self.curEquipBuffDict_ = self.unionVM_:GetEquipBuffInfoDict()
  self.updateSlotDict_ = {}
end

function Union_device_mainView:refreshTotalInfo()
  local funcName = self.commonVM.GetTitleByConfig(E.UnionFuncId.Build)
  self.uiBinder.lab_title.text = string.zconcat(funcName, "/", self.buildConfig_.BuildingName)
  self:refreshCurEffect()
  self:refreshBottomInfo()
end

function Union_device_mainView:refreshCurEffect()
  self:refreshLoopListView()
  self:refreshBuffItem()
end

function Union_device_mainView:refreshBottomInfo()
  local isHavePower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetBuildingEffect)
  local isEmpty = self.curSelectedBuffId_ == nil or self.curBuffSlotIndex_ == nil
  local isUnload = not isEmpty and self.curEquipBuffDict_[self.curSelectedBuffId_] ~= nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_confirm, isHavePower and not isEmpty and not isUnload)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel, isHavePower and not isEmpty and isUnload)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_tips, isHavePower and isEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_power_tips, not isHavePower)
  if not isEmpty and not isUnload then
    self:refreshCostInfo()
  end
  if self.curSelectedBuffId_ == nil then
    self.uiBinder.lab_tips.text = Lang("ClickToselect")
  elseif self.curBuffSlotIndex_ == nil then
    self.uiBinder.lab_tips.text = Lang("UnionBuffUnloadTips")
  end
end

function Union_device_mainView:refreshCostInfo()
  if self.curSelectedBuffId_ == nil then
    return
  end
  local config = self.unionTimelinessBuffTableMgr_.GetRow(self.curSelectedBuffId_)
  local costItemId = config.UnionBankroll[1]
  local costItemNum = config.UnionBankroll[2]
  local itemsVM = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_cost_icon:SetImage(itemsVM.GetItemIcon(costItemId))
  self.uiBinder.lab_cost_num.text = costItemNum
end

function Union_device_mainView:onCostBtnClick()
  if self.curSelectedBuffId_ == nil then
    return
  end
  local config = self.unionTimelinessBuffTableMgr_.GetRow(self.curSelectedBuffId_)
  local costItemId = config.UnionBankroll[1]
  self:closeItemTips()
  self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.btn_cost.transform, costItemId)
end

function Union_device_mainView:closeItemTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

function Union_device_mainView:checkCostEnough(isShowTips)
  if self.curSelectedBuffId_ == nil or self.curBuffSlotIndex_ == nil then
    return false
  end
  local config = self.unionTimelinessBuffTableMgr_.GetRow(self.curSelectedBuffId_)
  local costItemId = config.UnionBankroll[1]
  local costItemNum = config.UnionBankroll[2]
  local haveItemNum = self.itemsVM_.GetItemTotalCount(costItemId)
  if costItemNum > haveItemNum then
    if isShowTips then
      Z.TipsVM.ShowTips(1000560)
    end
    return false
  end
  return true
end

function Union_device_mainView:onBuffItemSelected()
  self.curSelectedBuffId_ = nil
  self.curBuffSlotIndex_ = nil
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local curSelectIndex = self.loopListView_:GetSelectedIndex()
  if 0 < curSelectIndex then
    local buffId = self.allBuffConfigList_[curSelectIndex].Id
    self.curSelectedBuffId_ = buffId
    if self.curEquipBuffDict_[buffId] then
      self.curBuffSlotIndex_ = self.curEquipBuffDict_[buffId].buffPos + 1
    else
      local unlockSlotNum = self.unionVM_:GetUnlockBuffSlotNum()
      for i = 1, MAX_BUFF_COUNT do
        local curBuffInfo = self.unionData_.BuildBuffInfo[i]
        if i <= unlockSlotNum and (curBuffInfo == nil or curServerTime > curBuffInfo.endTime) then
          self.curBuffSlotIndex_ = i
          break
        end
      end
    end
  end
  self:refreshBuffItem()
  self:refreshBottomInfo()
end

function Union_device_mainView:onBuffAddBtnClick(buffId, slotIndex)
end

function Union_device_mainView:onConfirmBtnClick()
  if self.curSelectedBuffId_ == nil or self.curBuffSlotIndex_ == nil then
    return
  end
  if not self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetBuildingEffect) then
    Z.TipsVM.ShowTipsLang(1000527)
    return
  end
  if self:checkCostEnough(true) then
    self.isSetBySelf_ = true
    local reply = self.unionVM_:AsyncSetEffectBuff(self.curSelectedBuffId_, self.curBuffSlotIndex_, self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode == 0 then
      local unionVM = Z.VMMgr.GetVM("union")
      unionVM:OpenUnionBuildPopupView(E.UnionBuildPopupType.Buff, E.UnionBuildId.Buff, reply.effectBuff)
    end
  end
end

function Union_device_mainView:onCancelBtnClick()
  if self.curSelectedBuffId_ == nil or self.curBuffSlotIndex_ == nil then
    return
  end
  if not self.unionVM_:CheckPlayerPower(E.UnionPowerDef.SetBuildingEffect) then
    Z.TipsVM.ShowTipsLang(1000527)
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("UnionBuffCancelDialogTips"), function()
    Z.DialogViewDataMgr:CloseDialogView()
    self.isSetBySelf_ = true
    self.unionVM_:AsyncCancelEffectBuff(self.curSelectedBuffId_, self.curBuffSlotIndex_, self.cancelSource:CreateToken())
  end)
end

function Union_device_mainView:onUnionResourceChange()
  self:refreshCostInfo()
end

function Union_device_mainView:onUnionBuildBuffInfoChange(isNotify)
  if isNotify and not self.isSetBySelf_ then
    Z.TipsVM.ShowTipsLang(1000561)
  end
  self.isSetBySelf_ = false
  self:resetData()
  self:refreshTotalInfo()
end

return Union_device_mainView
