local super = require("ui.component.loop_list_view_item")
local FashionCollectionItem = class("FashionCollectionItem", super)

function FashionCollectionItem:OnInit()
  self.timerMgr = Z.TimerMgr.new()
end

function FashionCollectionItem:OnUnInit()
  if self.cycleTimer then
    self.cycleTimer:Stop()
    self.cycleTimer = nil
  end
  self.timerMgr:Clear()
end

function FashionCollectionItem:OnRefresh(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_tag, true)
  self.uiBinder.lab_up.text = ""
  self.uiBinder.lab_down.text = ""
  self.uiBinder.lab_num.text = ""
  if data.type == E.FashionCollectionScoreType.Mission then
    self:refreshMissionData(data.row)
  elseif data.type == E.FashionCollectionScoreType.Cycle then
    self:refreshCycleData(data.data)
  else
    self:refreshCollectionData(data.id)
  end
end

function FashionCollectionItem:refreshMissionData(row)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_tag, row.Times == -1)
  self.uiBinder.lab_num.text = row.Score
  local tackList = Z.ContainerMgr.CharSerialize.fashionBenefit.taskList
  local progress = 0
  if tackList[row.Id] then
    progress = tackList[row.Id].progress
  end
  self.uiBinder.lab_up.text = Z.Placeholder.Placeholder(row.TargetDes, {
    val1 = progress,
    val2 = row.Num
  })
  if row.Times > 0 then
    local completeCount = 0
    if tackList[row.Id] then
      completeCount = tackList[row.Id].count
    end
    self.uiBinder.lab_down.text = Lang("CollectionMissionItemRewardCount", {
      val1 = completeCount,
      val2 = row.Times
    })
  else
    self.uiBinder.lab_down.text = ""
  end
end

function FashionCollectionItem:refreshCycleData(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_tag, false)
  self.uiBinder.lab_down.text = Z.TimeFormatTools.TicksFormatTime(data.time * 1000, E.TimeFormatType.YMDHMS)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
  self:refreshCycleTimer(data)
  local remainTime = data.time + Z.Global.FashionLevelScoreTime - Z.TimeTools.Now() / 1000
  if self.cycleTimer then
    self.cycleTimer:Stop()
    self.cycleTimer = nil
  end
  self.cycleTimer = self.timerMgr:StartTimer(function()
    self:refreshCycleTimer(data)
  end, 1, remainTime, true)
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.fashionId, true)
  if not itemTable then
    local fashionAdvancedTableRow = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(data.fashionId, true)
    if fashionAdvancedTableRow then
      self.uiBinder.lab_up.text = Lang("FashionUnlockItem", {
        name = fashionAdvancedTableRow.Name
      })
    end
  else
    self.uiBinder.lab_up.text = Lang("FashionCollectionItem", {
      name = itemTable.Name
    })
  end
  if data.type == E.CollectionHistoryType.Fashion then
    local fashionTable = Z.TableMgr.GetTable("FashionTableMgr").GetRow(data.fashionId, true)
    if not fashionTable then
      return
    end
    self.uiBinder.lab_num.text = math.floor(fashionTable.Score * Z.Global.FashionScoreScale[1][2] * 1.0E-4)
  elseif data.type == E.CollectionHistoryType.Weapon then
    local weaponSkinTable = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(data.fashionId, true)
    if not weaponSkinTable then
      return
    end
    self.uiBinder.lab_num.text = math.floor(weaponSkinTable.Score * Z.Global.FashionScoreScale[2][2] * 1.0E-4)
  elseif data.type == E.CollectionHistoryType.Ride then
    local vehicleBaseTable = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(data.fashionId, true)
    if not vehicleBaseTable then
      return
    end
    self.uiBinder.lab_num.text = math.floor(vehicleBaseTable.Score * Z.Global.FashionScoreScale[3][2] * 1.0E-4)
  end
end

function FashionCollectionItem:refreshCycleTimer(data)
  local remainTime = data.time + Z.Global.FashionLevelScoreTime - Z.TimeTools.Now() / 1000
  if Z.Global.FashionLevelTimeTips ~= nil and remainTime < Z.Global.FashionLevelTimeTips then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, true)
    if remainTime <= 0 then
      self.uiBinder.lab_time.text = Lang("FashionCollectOverTime")
      return
    end
    local day = math.ceil(remainTime / 86400)
    if 0 < day then
      self.uiBinder.lab_time.text = Lang("FashionCollectOverTimeDay", {day = day})
    else
      local hour = math.ceil(remainTime / 3600)
      self.uiBinder.lab_time.text = Lang("FashionCollectOverTimeHour", {hour = hour})
    end
  end
end

function FashionCollectionItem:refreshCollectionData(id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
  local row = Z.TableMgr.GetTable("FashionCollectTableMgr").GetRow(id, true)
  if not row then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_tag, false)
  self.uiBinder.lab_up.text = Lang("FashionCollectionItemCollectionValue", {
    val = row.Score
  })
  self.uiBinder.lab_down.text = ""
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVm.GetAllAwardPreListByIds(row.AwardId)
  local awardCount = 0
  for i = 1, #awardList do
    if awardList[i].awardId == Z.Global.FashionLevelItemId then
      awardCount = awardList[i].awardNum
      break
    end
  end
  self.uiBinder.lab_num.text = awardCount
end

return FashionCollectionItem
