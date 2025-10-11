local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_upgrade_mainView = class("Union_upgrade_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item = require("ui.component.common_reward_loop_list_item")
local unionBuffitem = require("ui.component.union.union_buff_item")
local COND_ICON_ON_PATH = "ui/atlas/union/union_check"
local COND_ICON_OFF_PATH = "ui/atlas/union/union_check_off"
local MAX_BUFF_COUNT = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT

function Union_upgrade_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_upgrade_main")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.commonVM = Z.VMMgr.GetVM("common")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.socialData_ = Z.DataMgr.Get("social_data")
  self.unionBuildingTableMgr_ = Z.TableMgr.GetTable("UnionBuildingTableMgr")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
end

function Union_upgrade_mainView:OnActive()
  Z.UIMgr:FadeIn({
    IsInstant = true,
    TimeOut = Z.UICameraHelperFadeTime
  })
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:bindEvents()
  self:initComponent()
  self:initData()
  self:initCamera()
  self:initLoopListView()
  self:initQuery()
end

function Union_upgrade_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curBuildConfig_.NpcUId and self.curBuildConfig_.NpcUId ~= 0 then
    Z.CameraMgr:CloseDialogCamera()
  else
    Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.curBuildConfig_.CameraTemplateId, false)
  end
  self:clearProgressTimer()
  self:unBindEvents()
  self:unInitBuffItem()
  self:unInitLoopListView()
  self:closeItemTips()
end

function Union_upgrade_mainView:OnRefresh()
end

function Union_upgrade_mainView:initData()
  self.curBuildId_ = self.viewData.BuildId
  self.curBuildConfig_ = self.unionVM_:GetUnionBuildConfig(self.curBuildId_)
  self.curBuildLv_ = self.unionVM_:GetUnionBuildLv(self.curBuildId_)
  self.mySocialData_ = self.socialData_:GetSocialData()
  self.curSpeedUpCount_ = self.unionData_.SpeedUpTimes
  self.speedUpCountLimit_ = Z.Global.UnionUpgradingNum[1]
  self.buffItemDict_ = {}
end

function Union_upgrade_mainView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.binder_info.btn_upgrade, function()
    self:onUpdateBtnClick()
  end)
  self:AddClick(self.uiBinder.binder_info.binder_cond_1.btn_exp_icon, function()
    self:openItemTips(self.uiBinder.binder_info.binder_cond_1.Trans, E.UnionResourceId.Exp)
  end)
  self:AddClick(self.uiBinder.binder_info.binder_cond_2.btn_cost_icon, function()
    self:openItemTips(self.uiBinder.binder_info.binder_cond_2.Trans, E.UnionResourceId.Gold)
  end)
end

local buildModelPosCfg = {
  [1] = {entId = 6, innerCameraId = 10000}
}
local maxRot = 30

function Union_upgrade_mainView:initCamera()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.curBuildConfig_.NpcUId and self.curBuildConfig_.NpcUId ~= 0 then
      local entityVM = Z.VMMgr.GetVM("entity")
      local uuid = entityVM.EntIdToUuid(self.curBuildConfig_.NpcUId, Z.PbEnum("EEntityType", "EntNpc"), false, true)
      Z.NpcBehaviourMgr:SetDialogCameraByConfigId(301, uuid)
    else
      Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, self.curBuildConfig_.CameraTemplateId, false)
      if buildModelPosCfg[self.curBuildId_] then
        Z.Delay(0.1, self.cancelSource:CreateToken())
        local cfg = buildModelPosCfg[self.curBuildId_]
        local entity = Z.EntityMgr:GetLevelEntity(Z.PbEnum("EEntityType", "EntNpc"), cfg.entId)
        local entityPos = entity.Model:GetAttrGoPosition()
        local pos = Z.CameraMgr.MainCamera:WorldToScreenPoint(entityPos)
        local newPosx = UnityEngine.Screen.width / UnityEngine.Screen.height * pos.x / 1.78
        local newEntityPos = Z.CameraMgr.MainCamera:ScreenToWorldPoint(Vector3.New(newPosx, pos.y, pos.z))
        local oriPos, oriRot = Z.CameraMgr:GetUnionCameraParam(cfg.innerCameraId, nil, nil)
        local newRotY = UnityEngine.Screen.width / UnityEngine.Screen.height * oriRot.y / 1.78
        if newRotY > maxRot then
          newRotY = maxRot
        end
        Z.CameraMgr:UnionCameraInvoke({
          cfg.innerCameraId
        }, Vector3.New(entityPos.x - newEntityPos.x, 0, 0), Vector3.New(oriRot.x, newRotY, oriRot.z))
        Z.Delay(0.1, self.cancelSource:CreateToken())
        Z.CameraMgr:SetUnionCameraParam(cfg.innerCameraId, oriPos, oriRot)
      end
    end
  end)()
end

function Union_upgrade_mainView:initQuery()
  Z.CoroUtil.create_coro_xpcall(function()
    local reply = self.unionVM_:AsyncReqUnionInfo(self.unionVM_:GetPlayerUnionId(), self.cancelSource:CreateToken())
    if reply.errCode and reply.errCode == 0 then
      self:refreshBuildInfo()
    end
  end)()
end

function Union_upgrade_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_upgrade_mainView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange, self.onUnionBuildInfoChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_upgrade_mainView:unInitBuffItem()
  for key, item in pairs(self.buffItemDict_) do
    item:UnInit()
  end
  self.buffItemDict_ = nil
end

function Union_upgrade_mainView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.binder_info.loop_item, common_reward_loop_list_item, "com_item_square_1_8")
  local dataList = {}
  self.loopListView_:Init(dataList)
end

function Union_upgrade_mainView:refreshLoopListView(nextUpgradeConfig)
  local costEnough = true
  local dataList = {}
  for i, v in ipairs(nextUpgradeConfig.UpgradingAccelerateItem) do
    local itemId = v[1]
    local num = v[2]
    dataList[i] = {ItemId = itemId, Num = num}
    local haveNum = self.itemsVM_.GetItemTotalCount(itemId)
    if num > haveNum then
      costEnough = false
    end
  end
  self.loopListView_:RefreshListView(dataList)
  self.uiBinder.binder_info.btn_upgrade.IsDisabled = not costEnough
end

function Union_upgrade_mainView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_upgrade_mainView:GetCacheData()
  return self.viewData
end

function Union_upgrade_mainView:refreshBuildInfo()
  local maxBuildLv = self.unionVM_:GetUnionBuildMaxLv(self.curBuildId_)
  local curUpgradeConfig = self.unionData_:GetUnionUpgradeConfigByLv(self.curBuildId_, self.curBuildLv_)
  local nextUpgradeConfig = self.unionData_:GetUnionUpgradeConfigByLv(self.curBuildId_, self.curBuildLv_ + 1)
  local isUnlock = self.unionVM_:IsUnionBuildUnlock(self.curBuildId_)
  local isMaxLv = maxBuildLv <= self.curBuildLv_
  local isMaxNum = self.curSpeedUpCount_ >= self.speedUpCountLimit_
  local funcName = self.commonVM.GetTitleByConfig(E.UnionFuncId.Build)
  self.uiBinder.lab_title.text = string.zconcat(funcName, "/", self.curBuildConfig_.BuildingName)
  self.uiBinder.binder_info.lab_name.text = self.curBuildConfig_.BuildingName
  self.uiBinder.binder_info.lab_cur_level.text = Lang("LvFormat", {
    val = self.curBuildLv_
  })
  self.uiBinder.binder_info.lab_next_level.text = Lang("LvFormat", {
    val = self.curBuildLv_ + 1
  })
  self.uiBinder.binder_info.lab_content.text = self.curBuildConfig_.BuildingTxt
  local nextBuffConfigList, isBuffEffect = self.unionVM_:ParseUnionBuildBuffPurview(nextUpgradeConfig)
  if isBuffEffect then
    self:refreshBuffEffectInfo(curUpgradeConfig, nextBuffConfigList, isMaxLv)
  else
    self:refreshNormalEffectInfo(curUpgradeConfig, nextUpgradeConfig, isMaxLv)
  end
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_normal_effect, not isBuffEffect)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_buff_effect, isBuffEffect)
  if not isMaxLv then
    local isUpgrading = self.unionVM_:CheckBuildIsUpgrading(self.curBuildId_)
    if isUpgrading then
      self:refreshProgressInfo(nextUpgradeConfig)
    elseif not isUnlock then
      self:refreshUnlockCond(self.curBuildConfig_)
    else
      self:refreshCondInfo(nextUpgradeConfig)
    end
    self:refreshButtonLabel(isUpgrading, nextUpgradeConfig)
    local isShowUpgradeBtn = isUnlock and (not isUpgrading or not isMaxNum)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_progress, isUpgrading)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_condition, not isUpgrading)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.btn_upgrade, isShowUpgradeBtn)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_btn_panel, isShowUpgradeBtn)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.lab_speed_up_tips, isUpgrading)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.lab_num, isUpgrading and not isMaxNum)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.lab_useless, isUpgrading and isMaxNum)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.img_panel, isUpgrading and isMaxNum)
  end
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_upgrade_info, not isMaxLv)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.lab_next_level, not isMaxLv)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.img_arrow, not isMaxLv)
end

function Union_upgrade_mainView:refreshButtonLabel(isUpgrade, nextUpgradeConfig)
  local labStr
  if isUpgrade then
    local timeDesc = Z.TimeFormatTools.FormatToDHMS(nextUpgradeConfig.UpgradingAccelerateTime)
    labStr = Lang("UnionSpeedUpDesc", {val = timeDesc})
  else
    labStr = Lang("levelUp")
  end
  self.uiBinder.binder_info.binder_btn_upgrade.lab_normal.text = labStr
end

function Union_upgrade_mainView:refreshNormalEffectInfo(curUpgradeConfig, nextUpgradeConfig, isMaxLv)
  if isMaxLv then
    self.uiBinder.binder_info.lab_next_effect.text = Lang("UnionBuildMaxLv")
  else
    local nextPurviewDesc = self.unionVM_:ParseUnionBuildPurviewDesc(nextUpgradeConfig.Level, nextUpgradeConfig.Purview)
    self.uiBinder.binder_info.lab_next_effect.text = nextPurviewDesc
  end
end

function Union_upgrade_mainView:refreshBuffEffectInfo(curUpgradeConfig, nextBuffConfigList, isMaxLv)
  if isMaxLv then
    self.uiBinder.binder_info.lab_next_buff.text = Lang("UnionBuildMaxLv")
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_next_buff, false)
  elseif 0 < #nextBuffConfigList then
    self.uiBinder.binder_info.lab_next_buff.text = ""
    for i = 1, MAX_BUFF_COUNT do
      local buffConfig = nextBuffConfigList[i]
      local key = "binder_next_buff_" .. i
      local item = self.uiBinder.binder_info[key]
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
      self.uiBinder.binder_info.Ref:SetVisible(item.Ref, buffConfig ~= nil)
    end
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_next_buff, true)
  else
    self.uiBinder.binder_info.lab_next_buff.text = Lang("UnionBuildMaxLv")
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.trans_next_buff, false)
  end
end

function Union_upgrade_mainView:refreshUnlockCond(buildConfig)
  local unlockDescList = Z.ConditionHelper.GetConditionDescList(buildConfig.Unlock)
  local descList = {}
  for i, v in ipairs(unlockDescList) do
    descList[i] = v.Desc
  end
  local descStr = table.concat(descList, "\n")
  self.uiBinder.binder_info.binder_cond_3.lab_desc.text = descStr
  self.uiBinder.binder_info.binder_cond_3.img_icon:SetImage(COND_ICON_OFF_PATH)
  local preferredValue = self.uiBinder.binder_info.binder_cond_3.lab_desc:GetPreferredValues(descStr)
  self.uiBinder.binder_info.binder_cond_3.trans_desc:SetHeight(20 + preferredValue.y)
  self.uiBinder.binder_info.binder_cond_3.Trans:SetHeight(60 + preferredValue.y)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_3.Ref, true)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_1.Ref, false)
  self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_2.Ref, false)
  self.uiBinder.binder_info.lab_condition_title.text = Lang("UnLockCondition")
end

function Union_upgrade_mainView:refreshCondInfo(nextUpgradeConfig)
  local isCanUpgrade = true
  if #nextUpgradeConfig.UnionExp > 0 then
    local itemId = nextUpgradeConfig.UnionExp[1]
    local curExp = self.unionVM_:GetUnionResourceCount(itemId)
    local needExp = nextUpgradeConfig.UnionExp[2]
    local itemConfig = self.itemTableMgr_.GetRow(itemId)
    local condEnough = curExp >= needExp
    if not condEnough then
      isCanUpgrade = false
    end
    self.uiBinder.binder_info.binder_cond_1.lab_experience.text = Lang("UnionExpCond", {exp1 = curExp, exp2 = needExp})
    self.uiBinder.binder_info.binder_cond_1.sliced_filled_image.fillAmount = curExp / needExp
    self.uiBinder.binder_info.binder_cond_1.rimg_exp_icon:SetImage(itemConfig.Icon)
    self.uiBinder.binder_info.binder_cond_1.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_1.Ref, true)
  else
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_1.Ref, false)
  end
  if 0 < #nextUpgradeConfig.UnionBankroll then
    local itemId = nextUpgradeConfig.UnionBankroll[1]
    local curGold = self.unionVM_:GetUnionResourceCount(itemId)
    local needGold = nextUpgradeConfig.UnionBankroll[2]
    local condEnough = curGold >= needGold
    if not condEnough then
      isCanUpgrade = false
    end
    self.uiBinder.binder_info.binder_cond_2.lab_cost_number.text = string.zconcat(curGold, "/", needGold)
    self.uiBinder.binder_info.binder_cond_2.rimg_cost_icon:SetImage(self.itemsVM_.GetItemIcon(itemId))
    self.uiBinder.binder_info.binder_cond_2.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_2.Ref, true)
  else
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_2.Ref, false)
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
    if not condEnough then
      isCanUpgrade = false
    end
    local descStr = table.concat(descList, "\n")
    self.uiBinder.binder_info.binder_cond_3.lab_desc.text = descStr
    self.uiBinder.binder_info.binder_cond_3.img_icon:SetImage(condEnough and COND_ICON_ON_PATH or COND_ICON_OFF_PATH)
    local preferredValue = self.uiBinder.binder_info.binder_cond_3.lab_desc:GetPreferredValues(descStr)
    self.uiBinder.binder_info.binder_cond_3.trans_desc:SetHeight(20 + preferredValue.y)
    self.uiBinder.binder_info.binder_cond_3.Trans:SetHeight(60 + preferredValue.y)
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_3.Ref, true)
  else
    self.uiBinder.binder_info.Ref:SetVisible(self.uiBinder.binder_info.binder_cond_3.Ref, false)
  end
  self.uiBinder.binder_info.btn_upgrade.IsDisabled = not isCanUpgrade
  self.uiBinder.binder_info.lab_condition_title.text = Lang("UpgradeCondition")
end

function Union_upgrade_mainView:refreshProgressInfo(nextUpgradeConfig)
  self:clearProgressTimer()
  local buildInfo = self.unionVM_:GetBuildInfo(self.curBuildId_)
  if buildInfo and buildInfo.upgradeFinishTime ~= 0 then
    local startTime = buildInfo.upgradeFinishTime - nextUpgradeConfig.UpgradingTime
    local endTime = buildInfo.upgradeFinishTime
    local currentTime = math.floor(Z.ServerTime:GetServerTime() / 1000) + buildInfo.hasSpeedUpSec
    if endTime > currentTime then
      self:createProgressTimer(startTime, currentTime, endTime)
    end
  end
  self:refreshLoopListView(nextUpgradeConfig)
  self:refreshSpeedUpInfo()
end

function Union_upgrade_mainView:refreshSpeedUpInfo()
  local isMax = self.curSpeedUpCount_ >= self.speedUpCountLimit_
  if not isMax then
    self.uiBinder.binder_info.lab_num.text = Lang("UnionSpeedUpCount", {
      val1 = self.curSpeedUpCount_,
      val2 = self.speedUpCountLimit_
    })
  end
end

function Union_upgrade_mainView:createProgressTimer(startTime, currentTime, endTime)
  local startTime = startTime
  local currentTime = currentTime
  local endTime = endTime
  self:onTimerUpdate(startTime, currentTime, endTime)
  self.progressTimer_ = self.timerMgr:StartTimer(function()
    currentTime = currentTime + 1
    self:onTimerUpdate(startTime, currentTime, endTime)
  end, 1, endTime - currentTime)
end

function Union_upgrade_mainView:onTimerUpdate(startTime, currentTime, endTime)
  local timeStr = Lang("UnionBuildTime", {
    time = Z.TimeFormatTools.FormatToDHMS(endTime - currentTime, true)
  })
  local progress = (currentTime - startTime) / (endTime - startTime)
  self.uiBinder.binder_info.lab_upgrade_time.text = timeStr
  self.uiBinder.binder_info.sclied_filled_image.fillAmount = progress
end

function Union_upgrade_mainView:clearProgressTimer()
  if self.progressTimer_ then
    self.progressTimer_:Stop()
    self.progressTimer_ = nil
  end
end

function Union_upgrade_mainView:checkCanSpeedUp()
  if self.curSpeedUpCount_ >= self.speedUpCountLimit_ then
    Z.TipsVM.ShowTips(1000557)
    return false
  end
  local nextUpgradeConfig = self.unionData_:GetUnionUpgradeConfigByLv(self.curBuildId_, self.curBuildLv_ + 1)
  for i, v in ipairs(nextUpgradeConfig.UpgradingAccelerateItem) do
    local itemId = v[1]
    local num = v[2]
    local haveNum = self.itemsVM_.GetItemTotalCount(itemId)
    if num > haveNum then
      Z.TipsVM.ShowTips(1000558)
      return false
    end
  end
  return true
end

function Union_upgrade_mainView:onUpdateBtnClick()
  local isUpgrading = self.unionVM_:CheckBuildIsUpgrading(self.curBuildId_)
  if isUpgrading then
    if not self:checkCanSpeedUp() then
      return
    end
    self.unionVM_:AsyncSpeedUpUnionBuild(self.curBuildId_, self.curBuildLv_, self.cancelSource:CreateToken())
  else
    if not self.unionVM_:CheckPlayerPower(E.UnionPowerDef.UpgradeBuilding) then
      Z.TipsVM.ShowTipsLang(1000527)
      return
    end
    local curBuildLv = self.unionVM_:GetUnionBuildLv(self.curBuildId_)
    if not self.unionVM_:CheckBuildUpgrade(self.curBuildId_, curBuildLv, true) then
      return
    end
    self.unionVM_:AsyncUpgradeUnionBuild(self.curBuildId_, self.cancelSource:CreateToken())
  end
end

function Union_upgrade_mainView:onUnionBuildInfoChange()
  local curLevel = self.unionVM_:GetUnionBuildLv(self.curBuildId_)
  if curLevel > self.curBuildLv_ then
    self.curBuildLv_ = curLevel
    self.unionVM_:OpenUnionBuildPopupView(E.UnionBuildPopupType.Upgrade, self.curBuildId_)
  end
  self.curSpeedUpCount_ = self.unionData_.SpeedUpTimes
  self:refreshBuildInfo()
end

function Union_upgrade_mainView:onUnionResourceChange()
  self:refreshBuildInfo()
end

function Union_upgrade_mainView:openItemTips(trans, itemId)
  self:closeItemTips()
  self.itemTipsId_ = Z.TipsVM.ShowItemTipsView(trans, itemId)
end

function Union_upgrade_mainView:closeItemTips()
  if self.itemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.itemTipsId_)
    self.itemTipsId_ = nil
  end
end

return Union_upgrade_mainView
