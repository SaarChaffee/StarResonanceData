local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_buff_tipsView = class("Union_buff_tipsView", super)
local unionBuffitem = require("ui.component.union.union_buff_item")
local HEIGHT_LOCK = 120
local HEIGHT_UNLOCK_NORMAL = 202
local HEIGHT_UNLOCK_EXTEND = 242

function Union_buff_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_buff_tips")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_buff_tipsView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self:refreshInfo()
end

function Union_buff_tipsView:OnDeActive()
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
  self.buffItem_:UnInit()
  self.buffItem_ = nil
end

function Union_buff_tipsView:OnRefresh()
end

function Union_buff_tipsView:refreshInfo()
  local buffId = self.viewData.BuffId
  local slotIndex = self.viewData.BuffSlotIndex
  local unlockSlotNum = self.unionVM_:GetUnlockBuffSlotNum()
  local isLock = slotIndex and slotIndex > unlockSlotNum
  if isLock then
    self:refreshLockInfo(slotIndex)
  else
    self:refreshBuffInfo(buffId)
  end
  local buffItemData = {
    BuffId = buffId,
    SlotIndex = slotIndex,
    IgnoreClick = true,
    IsPreview = self.viewData.IsPreview
  }
  self.buffItem_ = unionBuffitem.new()
  self.buffItem_:Init(self.uiBinder.binder_item, buffItemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, not isLock)
  self.uiBinder.adapt_pos_tips:UpdatePosition(self.viewData.ParentTrans, true)
end

function Union_buff_tipsView:refreshLockInfo(slotIndex)
  local unlockConfig = self.unionVM_:GetUnlockInfoBySlotIndex(slotIndex)
  if unlockConfig == nil then
    return
  end
  local buildConfig = self.unionVM_:GetUnionBuildConfig(unlockConfig.BuildingId)
  self.uiBinder.lab_content.text = Lang("UnionBuildUnlockDesc", {
    name = buildConfig.BuildingName,
    level = unlockConfig.Level
  })
  self.uiBinder.trans_bg:SetHeight(HEIGHT_LOCK)
end

function Union_buff_tipsView:refreshBuffInfo(buffId)
  local buildConfig = self.unionVM_:GetUnionBuildConfig(E.UnionBuildId.Buff)
  local buffConfig = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr").GetRow(buffId)
  self.uiBinder.lab_content.text = buffConfig.Desc
  local isBuffUnlock, unlockConfig = self.unionVM_:CheckUnionBuffUnlock(buffId)
  if not isBuffUnlock then
    self.uiBinder.lab_cond.text = Lang("UnionBuildUnlockDesc", {
      name = buildConfig.BuildingName,
      level = unlockConfig.Level
    })
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_cond, true)
    self.uiBinder.trans_bg:SetHeight(HEIGHT_UNLOCK_EXTEND)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_cond, false)
    self.uiBinder.trans_bg:SetHeight(HEIGHT_UNLOCK_NORMAL)
  end
  self.uiBinder.lab_time.text = Lang("UnionBuffTimeDesc", {
    time = Z.TimeTools.FormatToDHM(buffConfig.Time)
  })
end

return Union_buff_tipsView
