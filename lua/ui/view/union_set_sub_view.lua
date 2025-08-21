local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_set_subView = class("Union_set_subView", super)
local loopListView = require("ui.component.loop_list_view")
local union_build_item = require("ui.component.union.union_build_item")
local unionBuffitem = require("ui.component.union.union_buff_item")
local unionRed_ = require("rednode.union_red")
local COND_ICON_ON_PATH = "ui/atlas/union/union_check"
local COND_ICON_OFF_PATH = "ui/atlas/union/union_check_off"
local MAX_BUFF_COUNT = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT

function Union_set_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_set_sub", "union_2/union_set_sub", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.unionBuildingTableMgr_ = Z.TableMgr.GetTable("UnionBuildingTableMgr")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
end

function Union_set_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:bindEvents()
  self:initData()
  self:initComponent()
  self:initLoopListView()
  self:initQuery()
end

function Union_set_subView:OnDeActive()
  self:clearProgressTimer()
  self:unBindEvents()
  self:unInitBuffItem()
  self:unInitLoopListView()
  self:closeItemTips()
end

function Union_set_subView:OnRefresh()
end

function Union_set_subView:initData()
  self.curSelectBuildId_ = nil
  self.curSpeedUpCount_ = self.unionData_.SpeedUpTimes
  self.speedUpCountLimit_ = Z.Global.UnionUpgradingNum[1]
  self.buffItemDict_ = {}
end

function Union_set_subView:initComponent()
  self:startAnimatedShow()
  self:AddAsyncClick(self.uiBinder.btn_switch_upgrade, function()
    self:onSwitchBtnClick(E.UnionPowerDef.UpgradeBuilding)
  end)
  self:AddClick(self.uiBinder.btn_switch_speed_up, function()
    self:onSwitchBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_buff_set, function()
    self:onSwitchBtnClick(E.UnionPowerDef.SetBuildingEffect)
  end)
  self:AddClick(self.uiBinder.binder_cond_1.btn_exp_icon, function()
    self:openItemTips(self.uiBinder.binder_cond_1.Trans, E.UnionResourceId.Exp)
  end)
  self:AddClick(self.uiBinder.binder_cond_2.btn_cost_icon, function()
    self:openItemTips(self.uiBinder.binder_cond_2.Trans, E.UnionResourceId.Gold)
  end)
end

function Union_set_subView:initQuery()
  Z.CoroUtil.create_coro_xpcall(function()
    local reply = self.unionVM_:AsyncReqUnionInfo(self.unionVM_:GetPlayerUnionId(), self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode == 0 then
      self:refreshLoopListView()
    end
  end)()
end

function Union_set_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_set_subView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_set_subView:unInitBuffItem()
  for key, item in pairs(self.buffItemDict_) do
    item:UnInit()
  end
  self.buffItemDict_ = nil
end

function Union_set_subView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_set_subView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, union_build_item, "union_set_list_btn_tpl")
  local dataList = self:getBuildingDataList()
  self.loopListView_:Init(dataList)
  self.loopListView_:SetSelected(1)
end

function Union_set_subView:refreshLoopListView()
  local dataList = self:getBuildingDataList()
  local curSelectIndex = self.loopListView_:GetSelectedIndex()
  if curSelectIndex < 1 then
    curSelectIndex = 1
  end
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(dataList)
  self.loopListView_:SetSelected(curSelectIndex)
end

function Union_set_subView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_set_subView:getBuildingDataList()
  local dataList = self.unionBuildingTableMgr_.GetDatas()
  table.sort(dataList, function(a, b)
    return a.Sort < b.Sort
  end)
  return dataList
end

function Union_set_subView:RefreshSelectBuildInfo(buildId)
  if self.curSelectBuildId_ then
    unionRed_.RemoveUnionBuildingUpBtnRedItem(self.curSelectBuildId_, self)
  end
  self.curSelectBuildId_ = buildId
  local buildConfig = self.unionVM_:GetUnionBuildConfig(buildId)
  local buildLv = self.unionVM_:GetUnionBuildLv(buildId)
  local maxBuildLv = self.unionVM_:GetUnionBuildMaxLv(buildId)
  local curUpgradeConfig = self.unionData_:GetUnionUpgradeConfigByLv(buildId, buildLv)
  local nextUpgradeConfig = self.unionData_:GetUnionUpgradeConfigByLv(buildId, buildLv + 1)
  local isUnlock = self.unionVM_:IsUnionBuildUnlock(buildId)
  local isMaxLv = buildLv >= maxBuildLv
  local isMaxNum = self.curSpeedUpCount_ >= self.speedUpCountLimit_
  self.uiBinder.lab_title.text = buildConfig.BuildingName
  self.uiBinder.lab_lv.text = buildLv
  self.uiBinder.lab_content.text = buildConfig.BuildingTxt
  self.uiBinder.rimg_picture:SetImage(buildConfig.Picture)
  local nextBuffConfigList, isBuffEffect = self.unionVM_:ParseUnionBuildBuffPurview(nextUpgradeConfig)
  if isBuffEffect then
    self:refreshBuffEffectInfo(curUpgradeConfig, nextBuffConfigList, isMaxLv)
  else
    self:refreshNormalEffectInfo(curUpgradeConfig, nextUpgradeConfig, isMaxLv)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_normal_effect, not isBuffEffect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_buff_effect, isBuffEffect)
  local unlock = self.unionVM_:GetUnionSceneIsUnlock()
  self:SetUIVisible(self.uiBinder.lab_unlock, unlock == false)
  self:SetUIVisible(self.uiBinder.node_btn, unlock and not isMaxLv)
  if not isMaxLv then
    local isUpgrading = self.unionVM_:CheckBuildIsUpgrading(buildId)
    if isUpgrading then
      self:refreshProgressInfo(nextUpgradeConfig)
    elseif not isUnlock then
      self:refreshUnlockCond(buildConfig)
    else
      self:refreshCondInfo(nextUpgradeConfig)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_progress, isUpgrading)
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_condition, not isUpgrading)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_switch_upgrade, not isUpgrading)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_switch_speed_up, isUpgrading and not isMaxNum)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_num, isUpgrading and not isMaxNum)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_useless, isUpgrading and isMaxNum)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_panel, isUpgrading and isMaxNum)
    self:refreshSwitchLabel()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_upgrade_info, not isMaxLv)
  unionRed_.LoadUnionBuildUpBtnItem(buildId, self, self.uiBinder.trans_upgrade)
end

function Union_set_subView:refreshNormalEffectInfo(curUpgradeConfig, nextUpgradeConfig, isMaxLv)
  if isMaxLv then
    self.uiBinder.lab_next_effect.text = Lang("UnionBuildMaxLv")
  else
    local nextPurviewDesc = self.unionVM_:ParseUnionBuildPurviewDesc(nextUpgradeConfig.Level, nextUpgradeConfig.Purview)
    self.uiBinder.lab_next_effect.text = nextPurviewDesc
  end
end

function Union_set_subView:refreshBuffEffectInfo(curUpgradeConfig, nextBuffConfigList, isMaxLv)
  if isMaxLv then
    self.uiBinder.lab_next_buff.text = Lang("UnionBuildMaxLv")
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_next_buff, false)
  elseif 0 < #nextBuffConfigList then
    self.uiBinder.lab_next_buff.text = ""
    for i = 1, MAX_BUFF_COUNT do
      local buffConfig = nextBuffConfigList[i]
      local key = "binder_next_buff_" .. i
      local item = self.uiBinder[key]
      if buffConfig then
        local buffItemData = {
          BuffId = buffConfig and buffConfig.Id or nil,
          IsPreview = true,
          IgnoreClick = false
        }
        if self.buffItemDict_[key] == nil then
          self.buffItemDict_[key] = unionBuffitem.new()
          self.buffItemDict_[key]:Init(item, buffItemData)
        else
          self.buffItemDict_[key]:Refresh(buffItemData)
        end
      end
      self.uiBinder.Ref:SetVisible(item.Ref, buffConfig ~= nil)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_next_buff, true)
  else
    self.uiBinder.lab_next_buff.text = Lang("UnionBuildMaxLv")
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_next_buff, false)
  end
end

function Union_set_subView:refreshUnlockCond(buildConfig)
  local unlockDescList = Z.ConditionHelper.GetConditionDescList(buildConfig.Unlock)
  local descList = {}
  for i, v in ipairs(unlockDescList) do
    descList[i] = v.Desc
  end
  local descStr = table.concat(descList, "\n")
  self.uiBinder.binder_cond_3.lab_desc.text = descStr
  self.uiBinder.binder_cond_3.img_icon:SetImage(COND_ICON_OFF_PATH)
  local preferredValue = self.uiBinder.binder_cond_3.lab_desc:GetPreferredValues(descStr)
  self.uiBinder.binder_cond_3.trans_desc:SetHeight(20 + preferredValue.y)
  self.uiBinder.binder_cond_3.Trans:SetHeight(60 + preferredValue.y)
  self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_3.Ref, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_1.Ref, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_2.Ref, false)
  self.uiBinder.lab_condition_title.text = Lang("UnLockCondition")
end

function Union_set_subView:refreshCondInfo(nextUpgradeConfig)
  if #nextUpgradeConfig.UnionExp > 0 then
    local itemId = nextUpgradeConfig.UnionExp[1]
    local curExp = self.unionVM_:GetUnionResourceCount(itemId)
    local needExp = nextUpgradeConfig.UnionExp[2]
    local itemConfig = self.itemTableMgr_.GetRow(itemId)
    local condEnough = curExp >= needExp
    self.uiBinder.binder_cond_1.lab_experience.text = Lang("UnionExpCond", {exp1 = curExp, exp2 = needExp})
    self.uiBinder.binder_cond_1.sliced_filled_image.fillAmount = curExp / needExp
    self.uiBinder.binder_cond_1.rimg_exp_icon:SetImage(itemConfig.Icon)
    self.uiBinder.binder_cond_1.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_1.Ref, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_1.Ref, false)
  end
  if 0 < #nextUpgradeConfig.UnionBankroll then
    local itemId = nextUpgradeConfig.UnionBankroll[1]
    local curGold = self.unionVM_:GetUnionResourceCount(itemId)
    local needGold = nextUpgradeConfig.UnionBankroll[2]
    local condEnough = curGold >= needGold
    self.uiBinder.binder_cond_2.lab_cost_number.text = string.zconcat(curGold, "/", needGold)
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.binder_cond_2.rimg_cost_icon:SetImage(itemsVM.GetItemIcon(itemId))
    self.uiBinder.binder_cond_2.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_2.Ref, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_2.Ref, false)
  end
  if 0 < #nextUpgradeConfig.UpgradingLimits then
    local condEnough = true
    local descList = {}
    for i, v in ipairs(nextUpgradeConfig.UpgradingLimits) do
      local buildId = v[1]
      local buildLv = v[2]
      local curBuildLv = self.unionVM_:GetUnionBuildLv(buildId)
      local buildConfig = self.unionVM_:GetUnionBuildConfig(buildId)
      if buildLv > curBuildLv then
        condEnough = false
      end
      descList[i] = Lang("UnionBuildLvCond", {
        name = buildConfig.BuildingName,
        level = buildLv
      })
    end
    local descStr = table.concat(descList, "\n")
    self.uiBinder.binder_cond_3.lab_desc.text = descStr
    self.uiBinder.binder_cond_3.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    local preferredValue = self.uiBinder.binder_cond_3.lab_desc:GetPreferredValues(descStr)
    self.uiBinder.binder_cond_3.trans_desc:SetHeight(20 + preferredValue.y)
    self.uiBinder.binder_cond_3.Trans:SetHeight(60 + preferredValue.y)
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_3.Ref, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.binder_cond_3.Ref, false)
  end
  self.uiBinder.lab_condition_title.text = Lang("UpgradeCondition")
end

function Union_set_subView:refreshProgressInfo(nextUpgradeConfig)
  self:clearProgressTimer()
  local buildInfo = self.unionVM_:GetBuildInfo(self.curSelectBuildId_)
  if buildInfo and buildInfo.upgradeFinishTime ~= 0 then
    local startTime = buildInfo.upgradeFinishTime - nextUpgradeConfig.UpgradingTime
    local endTime = buildInfo.upgradeFinishTime
    local currentTime = math.floor(Z.ServerTime:GetServerTime() / 1000) + buildInfo.hasSpeedUpSec
    if endTime > currentTime then
      self:createProgressTimer(startTime, currentTime, endTime)
    end
  end
  self:refreshSpeedUpInfo()
end

function Union_set_subView:refreshSpeedUpInfo()
  local isMax = self.curSpeedUpCount_ >= self.speedUpCountLimit_
  if not isMax then
    self.uiBinder.lab_num.text = Lang("UnionSpeedUpCount", {
      val1 = self.curSpeedUpCount_,
      val2 = self.speedUpCountLimit_
    })
  end
end

function Union_set_subView:refreshSwitchLabel()
  local isHavePower = self.unionVM_:CheckPlayerPower(E.UnionPowerDef.UpgradeBuilding)
  self.uiBinder.lab_content_upgrade.text = isHavePower and Lang("GoUpgrade") or Lang("GoView")
end

function Union_set_subView:createProgressTimer(startTime, currentTime, endTime)
  local startTime = startTime
  local currentTime = currentTime
  local endTime = endTime
  self:onTimerUpdate(startTime, currentTime, endTime)
  self.progressTimer_ = self.timerMgr:StartTimer(function()
    currentTime = currentTime + 1
    self:onTimerUpdate(startTime, currentTime, endTime)
  end, 1, endTime - currentTime)
end

function Union_set_subView:onTimerUpdate(startTime, currentTime, endTime)
  local timeStr = Lang("UnionBuildTime", {
    time = Z.TimeFormatTools.FormatToDHMS(endTime - currentTime, true)
  })
  local progress = (currentTime - startTime) / (endTime - startTime)
  self.uiBinder.lab_upgrade_time.text = timeStr
  self.uiBinder.sclied_filled_image.fillAmount = progress
end

function Union_set_subView:clearProgressTimer()
  if self.progressTimer_ then
    self.progressTimer_:Stop()
    self.progressTimer_ = nil
  end
end

function Union_set_subView:onSwitchBtnClick(powerId)
  if self.curSelectBuildId_ == nil then
    return
  end
  if not self.unionVM_:IsUnionBuildUnlock(self.curSelectBuildId_, true) then
    return
  end
  local buildConfig = self.unionVM_:GetUnionBuildConfig(self.curSelectBuildId_)
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  quickJumpVm.DoJumpByConfigParam(buildConfig.QuickJumpType, buildConfig.QuickJumpParam)
end

function Union_set_subView:onUnionBuildInfoChange()
  self:refreshLoopListView()
end

function Union_set_subView:onUnionResourceChange()
  self:RefreshSelectBuildInfo(self.curSelectBuildId_)
end

function Union_set_subView:openItemTips(trans, itemId)
  self:closeItemTips()
  self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(trans, itemId)
end

function Union_set_subView:closeItemTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

return Union_set_subView
