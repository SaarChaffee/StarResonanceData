local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_copy_additional_subView = class("Main_copy_additional_subView", super)
local newKeyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function Main_copy_additional_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "main/main_copy_additional_sub_pc" or "main/main_copy_additional_sub"
  super.ctor(self, "main_copy_additional_sub", assetPath, UI.ECacheLv.None)
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  
  function self.updateDungeonData_()
    self:startTime()
  end
end

function Main_copy_additional_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.isShowRestTime_ = nil
  local isInVisualLayer = Z.StageMgr.IsInVisualLayer()
  if isInVisualLayer then
    self:showOrHideRestTimeUI(false)
  else
    self:initCopyRestTime()
  end
  Z.ContainerMgr.DungeonSyncData.flowInfo.Watcher:RegWatcher(self.updateDungeonData_)
  self:AddAsyncClick(self.uiBinder.btn_exit_copy, function()
    self.funcVM_.GoToFunc(E.FunctionID.ExitDungeon)
  end)
  self:initShortcutKey()
end

function Main_copy_additional_subView:initCopyRestTime()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  self.dungeonCfg_ = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
  self:showOrHideRestTimeUI(false)
  self:startTime()
end

function Main_copy_additional_subView:startTime()
  if Z.ContainerMgr.DungeonSyncData.flowInfo.state ~= E.DungeonState.DungeonStatePlaying then
    if self.copyRestTimer_ then
      self.timerMgr:StopTimer(self.copyRestTimer_)
      self.copyRestTimer_ = nil
      self:showOrHideRestTimeUI(false)
    end
    return
  end
  if self.dungeonCfg_ then
    local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    self.endTime_ = nowTime + self.dungeonCfg_.PlayingStateTime
    if self.copyRestTimer_ then
      self.timerMgr:StopTimer(self.copyRestTimer_)
      self.copyRestTimer_ = nil
    end
    self.copyRestTimer_ = self.timerMgr:StartTimer(function()
      self:refreshRestTimeUI()
    end, 1, self.dungeonCfg_.PlayingStateTime)
  else
    self:showOrHideRestTimeUI(false)
  end
end

function Main_copy_additional_subView:OnDeActive()
  self.timerMgr:StopTimer(self.copyRestTimer_)
  Z.ContainerMgr.DungeonSyncData.flowInfo.Watcher:UnregWatcher(self.updateDungeonData_)
  self:unInitShortcutKey()
end

function Main_copy_additional_subView:OnRefresh()
end

function Main_copy_additional_subView:initShortcutKey()
  if Z.IsPCUI then
    newKeyIconHelper.InitKeyIcon(self.uiBinder.binder_key_exit_copy, self.uiBinder.binder_key_exit_copy, 112)
  end
end

function Main_copy_additional_subView:unInitShortcutKey()
  if Z.IsPCUI then
    newKeyIconHelper.UnInitKeyIcon(self.uiBinder.binder_key_exit_copy)
  end
end

function Main_copy_additional_subView:refreshRestTimeUI()
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local dTime = self.endTime_ - nowTime
  local showCountdown = 0 <= dTime and dTime <= Z.Global.DungeonOutTime
  if showCountdown then
    local time = Z.TimeTools.S2MSFormat(dTime)
    if time ~= nil and time ~= "" then
      self:showOrHideRestTimeUI(true)
      self.uiBinder.lab_resttime.text = time
    else
      self:showOrHideRestTimeUI(false)
    end
  else
    self:showOrHideRestTimeUI(false)
  end
end

function Main_copy_additional_subView:showOrHideRestTimeUI(isShow)
  if self.isShowRestTime_ == isShow then
    return
  end
  self.isShowRestTime_ = isShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_countdown, isShow)
end

return Main_copy_additional_subView
