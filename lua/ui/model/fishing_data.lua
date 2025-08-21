local super = require("ui.model.data_base")
E.FishingDirection = {
  Left = 1,
  Middle = 2,
  Right = 3
}
E.FishingStage = {
  EnterFishing = 1,
  ThrowFishingRod = 2,
  ThrowFishingRodInWater = 3,
  BuoyDive = 4,
  FishBiteHook = 5,
  QTE = 6,
  Settlement = 7,
  EndRunAway = 8,
  EndSuccess = 9,
  EndRodBreak = 10,
  EndBuoyDive = 11,
  Quit = 12,
  QTEEnd = 13
}
E.FishingBtnIconType = {
  HookingUp = 1,
  HarvestingRod = 2,
  CastFishingRod = 3
}
E.FishingSliderState = {
  None = 0,
  Green = 1,
  Yellow = 2,
  Orange = 3,
  Red = 4,
  Flash = 5
}
E.FishingAttrTemplateFilter = {FishId = 0, FishType = 1}
E.FishingMainFunc = {
  Illustrated = 300001,
  Research = 300002,
  Shop = 300003,
  RankList = 300004,
  Archives = 300005
}
E.FishingQuality = {
  Normal = 1,
  Rare = 2,
  Myth = 3
}
E.FishingFishType = {
  Fish = 1,
  NotFish = 2,
  Halobios = 5,
  Legend = 99
}
E.FishingRankType = {World = 0, Union = 1}
local FishingData = class("FishingData", super)

function FishingData:ctor()
  super.ctor(self)
  self.PeripheralData = {}
  self.QTEData = {}
  self.FishBait = nil
  self.FishingRod = nil
  self.QTEData.FishBiteHook = false
  self.TargetFish = nil
  self.QTEData.playerSwingDir_ = E.FishingDirection.Middle
  self.FishingStage = E.FishingStage.Quit
  self.QTEData.UpdateRate = 0.02
  self.QTEData.fishBackTimer_ = 0
  self.QTEData.fishRunAwayTimer_ = 0
  self.QTEData.fishingRodBreakTimer_ = 0
  self.QTEData.dirNoMatchTimer_ = 0
  self.QTEData.dirMatchNoDragTimer_ = 0
  self.QTEData.fishBacking_ = false
  self.QTEData.isDraging_ = false
  self.QTEData.FishRodTension = 0
  self.QTEData.FishingProgress = 0
  self.QTEData.FishRodTensionInt = 0
  self.QTEData.FishingProgressInt = 0
  self.isRequestFishingEnd = false
  self.timerMgr = Z.TimerMgr.new()
  self.fishingAttrArray_ = {
    "BiteTime",
    "OffHookTime",
    "OffTime",
    "DrawSpeed",
    "OffSpeed",
    "DiffDirectionSpeedWithoutDraw",
    "DiffDirectionSpeedWithDraw",
    "SameDirectionSpeedWithDraw",
    "SameDirectionSpeedWithoutDraw",
    "FishPathInterval",
    "FishSpeed",
    "FishStayInterval"
  }
  self.MainFuncLuaViewPath = {
    [E.FishingMainFunc.Illustrated] = "ui.view.fishing_illustrated_sub_view",
    [E.FishingMainFunc.Research] = "ui.view.fishing_study_sub_view",
    [E.FishingMainFunc.Shop] = "ui.view.fishing_shop_sub_view",
    [E.FishingMainFunc.RankList] = "ui.view.fishing_ranking_sub_view",
    [E.FishingMainFunc.Archives] = "ui.view.fishing_archives_sub_view"
  }
  self.RankPathDict = {
    "ui/atlas/fishing/fishing_img_ranking_01",
    "ui/atlas/fishing/fishing_img_ranking_02",
    "ui/atlas/fishing/fishing_img_ranking_03"
  }
  self.IllQualityPathDict_ = {
    [E.FishingQuality.Myth] = "ui/atlas/fishing/fishing_img_label_02",
    [E.FishingQuality.Rare] = "ui/atlas/fishing/fishing_img_label_03",
    [E.FishingQuality.Normal] = "ui/atlas/fishing/fishing_img_label_04"
  }
  self.PeripheralData.ArchivesData = {}
end

function FishingData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.HaveInitData = false
end

function FishingData:Clear()
  self.QTEData.FishBiteHook = false
  self.QTEData.playerSwingDir_ = E.FishingDirection.Middle
  self.QTEData.fishBacking_ = false
  self.QTEData.isDraging_ = false
  self.QTEData.FishRodTension = 0
  self.QTEData.FishingProgress = 0
  self.QTEData.FishRodTensionInt = 0
  self.QTEData.FishingProgressInt = 0
  self.IsRequestFishingEnd = false
end

function FishingData:SetFishBiteHook(bitehook)
  self.QTEData.FishBiteHook = bitehook
end

function FishingData:SetPlayerSwingDir(dir)
  self.QTEData.playerSwingDir_ = dir
end

function FishingData:SetFishSwingDir(dir)
  self.TargetFish.dir = dir
end

function FishingData:CreateFishClass(FishInfo)
  self.TargetFish = {}
  self.TargetFish.dir = E.FishingDirection.Middle
  self.TargetFish.Size = 0
  self.TargetFish.FishInfo = FishInfo
  self.TargetFish.TargetFishModelId = FishInfo.ModelId
  if self.FishRecordDict[FishInfo.FishId].FishRecord then
    self.TargetFish.OldSizeRecord = self.FishRecordDict[FishInfo.FishId].FishRecord.size
  else
    self.TargetFish.OldSizeRecord = -1
  end
  self:updateFishingAttr()
end

function FishingData:updateFishingAttr()
  local fishingAttrRow_ = Z.TableMgr.GetTable("FishingAttrTableMgr").GetRow(self.TargetFish.FishInfo.FishingAttrId)
  local researchBaseAttr_, researchAddAttr_, fishingRodAttr_
  if self.TargetFish.FishInfo.IfResearch == 1 and #self.TargetFish.FishInfo.FishingTemplateId > 0 then
    local researchLevel_ = self.FishRecordDict[self.TargetFish.FishInfo.FishId].ResearchLevel
    if 1 < researchLevel_ then
      local temp_ = Z.TableMgr.GetTable("FishingTemplateTableMgr").GetRow(self.TargetFish.FishInfo.FishingTemplateId[researchLevel_ - 1])
      researchBaseAttr_ = self:fishAttrTemplateFilter(temp_)
    end
  end
  if self.QTEData.UseResearchFish and self.QTEData.UseResearchFish ~= 0 then
    local fishCfg_ = Z.TableMgr.GetTable("FishingTableMgr").GetRow(self.QTEData.UseResearchFish)
    local researchLevel_ = self.FishRecordDict[self.QTEData.UseResearchFish].ResearchLevel
    local temp_ = Z.TableMgr.GetTable("FishingTemplateTableMgr").GetRow(fishCfg_.FishingTemplateId[researchLevel_ - 1])
    researchAddAttr_ = self:fishAttrTemplateFilter(temp_)
  end
  if self.FishingRod and self.FishingRod ~= 0 then
    local itemsVM_ = Z.VMMgr.GetVM("items")
    local rodConfigId_ = itemsVM_.GetItemTabDataByUuid(self.FishingRod).Id
    local fishingRodRow_ = Z.TableMgr.GetTable("FishingRodTableMgr").GetRow(rodConfigId_)
    local temp_ = Z.TableMgr.GetTable("FishingTemplateTableMgr").GetRow(fishingRodRow_.FishingTemplateId)
    fishingRodAttr_ = self:fishAttrTemplateFilter(temp_)
  end
  for _, attr in ipairs(self.fishingAttrArray_) do
    self.TargetFish[attr] = self:getFishingAttr(fishingAttrRow_[attr], researchBaseAttr_ and researchBaseAttr_[attr] or nil, researchAddAttr_ and researchAddAttr_[attr] or nil, fishingRodAttr_ and fishingRodAttr_[attr] or nil)
  end
end

function FishingData:fishAttrTemplateFilter(template)
  if template then
    for _, filter in ipairs(template.SuitType) do
      if filter[1] == E.FishingAttrTemplateFilter.FishId then
        for i = 2, #filter do
          if filter[i] == self.TargetFish.FishInfo.FishId then
            return template
          end
        end
      elseif filter[1] == E.FishingAttrTemplateFilter.FishType then
        for i = 2, #filter do
          if filter[i] == self.TargetFish.FishInfo.Type then
            return template
          end
        end
      end
    end
  end
  return nil
end

function FishingData:getFishingAttr(baseConfig, researchBaseAttr, researchAddAttr, fishingRodAttr)
  local baseAttr_ = baseConfig[1]
  local minAttr_ = baseConfig[2]
  local maxAttr_ = baseConfig[3]
  if researchBaseAttr then
    baseAttr_ = (baseAttr_ + researchBaseAttr[1]) * (1 + researchBaseAttr[2] / 10000)
  end
  if fishingRodAttr then
    baseAttr_ = (baseAttr_ + fishingRodAttr[1]) * (1 + fishingRodAttr[2] / 10000)
  end
  if researchAddAttr then
    baseAttr_ = (baseAttr_ + researchAddAttr[1]) * (1 + researchAddAttr[2] / 10000)
  end
  if maxAttr_ < baseAttr_ then
    baseAttr_ = maxAttr_
  elseif minAttr_ > baseAttr_ then
    baseAttr_ = minAttr_
  end
  return baseAttr_
end

function FishingData:ResetQTEData()
  self.QTEData.fishBackTimer_ = 0
  self.QTEData.fishRunAwayTimer_ = 0
  self.QTEData.fishingRodBreakTimer_ = 0
  self.QTEData.dirNoMatchTimer_ = 0
  self.QTEData.dirMatchNoDragTimer_ = 0
  self.QTEData.FishRodTension = 0
  self.QTEData.FishingProgress = 0
  self.dragTimer_ = 0
  self.QTEData.ShowDragEffect = false
  self.QTEData.ShowDirNoMatchEffect = false
end

function FishingData:UnInit()
  self.CancelSource:Recycle()
  self.timerMgr:Clear()
  self.timerMgr = nil
  self.PeripheralData = {}
  self.FishRecordDict = {}
  self.QTEData = {}
  self.HaveInitData = false
end

function FishingData:SetStage(stage)
  self.FishingStage = stage
  if stage == E.FishingStage.EnterFishing then
    self:Clear()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingStateChange)
  if stage == E.FishingStage.EndRodBreak or stage == E.FishingStage.EndRunAway then
    self.timerMgr:StartTimer(function()
      self:SetStage(E.FishingStage.EnterFishing)
    end, 2, 1)
  end
  if stage == E.FishingStage.EndSuccess then
    self.timerMgr:StartTimer(function()
      self:SetStage(E.FishingStage.Settlement)
    end, 2, 1)
  end
end

function FishingData:SetTargetFish(fishId)
  local fishRow = Z.TableMgr.GetTable("FishingTableMgr").GetRow(fishId)
  self:CreateFishClass(fishRow)
end

function FishingData:SetIsDraging(isDraging)
  self.QTEData.isDraging_ = isDraging
end

function FishingData:FishingUpdate()
  self:CheckFishBack()
  self:CheckFishRunAway()
  self:CheckFishingRodBreak()
  self:CheckDirNoMatch()
  self:CheckNeedDragTip()
  self:CheckFishingSuccess()
  local changeProgress_ = self:UpdateFishingProgress()
  local changeRodTension_ = self:UpdateFishRodTension()
  return changeProgress_ or changeRodTension_
end

function FishingData:UpdateFishingProgress()
  local change = false
  if self.QTEData.isDraging_ then
    if self.TargetFish.dir == self.QTEData.playerSwingDir_ then
      self.QTEData.FishingProgress = self.QTEData.FishingProgress + self.TargetFish.DrawSpeed * self.QTEData.UpdateRate
    end
  elseif self.QTEData.fishBacking_ then
    self.QTEData.FishingProgress = self.QTEData.FishingProgress - self.TargetFish.OffSpeed * self.QTEData.UpdateRate
  end
  local temp_ = math.ceil(self.QTEData.FishingProgress)
  if temp_ ~= self.QTEData.FishingProgressInt then
    change = true
  end
  self.QTEData.FishingProgressInt = temp_
  if self.QTEData.FishingProgress > 100 then
    self.QTEData.FishingProgress = 100
    self.QTEData.FishingProgressInt = 100
  elseif self.QTEData.FishingProgress < 0 then
    self.QTEData.FishingProgress = 0
    self.QTEData.FishingProgressInt = 0
  end
  return change
end

function FishingData:CheckFishBack()
  if self.QTEData.isDraging_ then
    self.QTEData.fishBackTimer_ = 0
    self.QTEData.fishBacking_ = false
  else
    self.QTEData.fishBackTimer_ = self.QTEData.fishBackTimer_ + self.QTEData.UpdateRate
    if self.QTEData.fishBackTimer_ > self.TargetFish.OffTime then
      self.QTEData.fishBacking_ = true
    end
  end
end

function FishingData:CheckFishRunAway()
  if self.QTEData.FishingProgress == 0 then
    self.QTEData.fishRunAwayTimer_ = self.QTEData.fishRunAwayTimer_ + self.QTEData.UpdateRate
  else
    self.QTEData.fishRunAwayTimer_ = 0
  end
  if self.QTEData.fishRunAwayTimer_ > self.TargetFish.OffHookTime then
    Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishRunAway)
  end
end

function FishingData:CheckFishingRodBreak()
  if self.QTEData.FishRodTension == 100 and 100 > self.QTEData.FishingProgress then
    self.QTEData.fishingRodBreakTimer_ = self.QTEData.fishingRodBreakTimer_ + self.QTEData.UpdateRate
    if self.QTEData.fishingRodBreakTimer_ > Z.Global.FishingFullTensionBreak then
      Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingRodBreak)
    end
  else
    self.QTEData.fishingRodBreakTimer_ = 0
  end
end

function FishingData:CheckDirNoMatch()
  if self.QTEData.playerSwingDir_ ~= self.TargetFish.dir then
    self.QTEData.dirNoMatchTimer_ = self.QTEData.dirNoMatchTimer_ + self.QTEData.UpdateRate
    if self.QTEData.dirNoMatchTimer_ > Z.Global.FishingDirectionRemindTime then
      self.QTEData.ShowDirNoMatchEffect = true
    end
  else
    self.QTEData.dirNoMatchTimer_ = 0
    self.QTEData.ShowDirNoMatchEffect = false
  end
end

function FishingData:CheckNeedDragTip()
  if self.QTEData.playerSwingDir_ == self.TargetFish.dir and not self.QTEData.isDraging_ then
    self.QTEData.dirMatchNoDragTimer_ = self.QTEData.dirMatchNoDragTimer_ + self.QTEData.UpdateRate
    if self.QTEData.dirMatchNoDragTimer_ > Z.Global.FishingPullRemindTime then
      self.QTEData.ShowDragEffect = self.QTEData.FishRodTension <= Z.Global.FishingPullRemindTension
    end
  else
    self.QTEData.dirMatchNoDragTimer_ = 0
    self.QTEData.ShowDragEffect = false
  end
end

function FishingData:CheckFishingSuccess()
  if self.QTEData.FishingProgress == 100 then
    Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingSuccess)
  end
end

function FishingData:UpdateFishRodTension()
  local change = false
  if self.TargetFish.dir == self.QTEData.playerSwingDir_ then
    if self.QTEData.isDraging_ then
      self.QTEData.FishRodTension = self.QTEData.FishRodTension + self.TargetFish.SameDirectionSpeedWithDraw * self.QTEData.UpdateRate
    else
      self.QTEData.FishRodTension = self.QTEData.FishRodTension + self.TargetFish.SameDirectionSpeedWithoutDraw * self.QTEData.UpdateRate
    end
  elseif self.QTEData.isDraging_ then
    self.QTEData.FishRodTension = self.QTEData.FishRodTension + self.TargetFish.DiffDirectionSpeedWithDraw * self.QTEData.UpdateRate
  else
    self.QTEData.FishRodTension = self.QTEData.FishRodTension + self.TargetFish.DiffDirectionSpeedWithoutDraw * self.QTEData.UpdateRate
  end
  local temp_ = math.ceil(self.QTEData.FishRodTension)
  if temp_ ~= self.QTEData.FishRodTensionInt then
    change = true
  end
  self.QTEData.FishRodTensionInt = temp_
  if self.QTEData.FishRodTension > 100 then
    self.QTEData.FishRodTension = 100
    self.QTEData.FishRodTensionInt = 100
  elseif self.QTEData.FishRodTension < 0 then
    self.QTEData.FishRodTension = 0
    self.QTEData.FishRodTensionInt = 0
  end
  return change
end

function FishingData.SortRankList(list)
  table.sort(list, function(a, b)
    if a.size == b.size then
      return a.millisecond < b.millisecond
    else
      return a.size > b.size
    end
  end)
end

function FishingData:refreshFishRecordDict()
  local isFirstFish = self.FishRecordDict == nil or table.zcount(self.FishRecordDict) == 0
  self.FishRecordDict = {}
  local fishingcfgs_ = Z.TableMgr.GetTable("FishingTableMgr").GetDatas()
  for _, v in pairs(fishingcfgs_) do
    local recordData_ = Z.ContainerMgr.CharSerialize.fishSetting.fishRecords[v.FishId]
    local level_ = 1
    local progress_ = 0
    local curResearchExpInterval_ = 0
    local needResearchExpInterval_ = 0
    local star_ = 0
    if recordData_ ~= nil then
      if isFirstFish then
        isFirstFish = false
        self:SetActionFishId(v.FishId)
      end
      if v.IfResearch and 0 < #v.FishingResearchExp then
        for lv = 1, #v.FishingResearchExp do
          if recordData_.research >= v.FishingResearchExp[lv] then
            level_ = level_ + 1
          else
            local lastExp_ = 1 < lv and v.FishingResearchExp[lv - 1] or 0
            needResearchExpInterval_ = v.FishingResearchExp[lv] - lastExp_
            curResearchExpInterval_ = recordData_.research - lastExp_
            progress_ = curResearchExpInterval_ / needResearchExpInterval_
            break
          end
        end
        if needResearchExpInterval_ == 0 then
          local lastExp_ = v.FishingResearchExp[#v.FishingResearchExp - 1]
          progress_ = 1
          curResearchExpInterval_ = v.FishingResearchExp[#v.FishingResearchExp] - lastExp_
          needResearchExpInterval_ = v.FishingResearchExp[#v.FishingResearchExp] - lastExp_
        end
      end
      star_ = self.GetStarBySize(recordData_.size / 100, v)
    end
    local minSize_, maxSize_ = self:getMaxMinSize(v)
    local data_ = {
      ResearchLevel = level_,
      ResearchProgress = {
        progress_,
        curResearchExpInterval_,
        needResearchExpInterval_
      },
      FishRecord = recordData_,
      FishCfg = v,
      Star = star_,
      MinSize = minSize_,
      MaxSize = maxSize_
    }
    self.FishRecordDict[v.FishId] = data_
  end
end

function FishingData:refreshFishingArchivesData()
  self.PeripheralData.ArchivesData = {}
  local fishingtotal = 0
  local mythTotal = 0
  local fishTotal = 0
  local halobiosTotal = 0
  local mostFishName = "--"
  local mostFishCount = 0
  local lovestAreaName = "--"
  local lovestAreaCount = -1
  for _, recordData in pairs(self.FishRecordDict) do
    if recordData.FishRecord then
      fishingtotal = fishingtotal + recordData.FishRecord.count
      local typeCfg = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(recordData.FishCfg.Type)
      if typeCfg.Type == E.FishingFishType.Fish then
        fishTotal = fishTotal + 1
        if recordData.FishCfg.Quality == E.FishingQuality.Myth then
          mythTotal = mythTotal + recordData.FishRecord.count
        end
      elseif typeCfg.Type == E.FishingFishType.Halobios then
        halobiosTotal = halobiosTotal + 1
      end
      if mostFishCount < recordData.FishRecord.count then
        mostFishName = recordData.FishCfg.Name
        mostFishCount = recordData.FishRecord.count
      end
    end
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.fishSetting.zeroFishTimes) do
    if v > lovestAreaCount then
      local areaCfg = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(k)
      if areaCfg then
        lovestAreaName = areaCfg.AreaName
        lovestAreaCount = v
      end
    end
  end
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingTotal"),
    Value = fishingtotal
  })
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingMythFishTotal"),
    Value = mythTotal
  })
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingFishTotal"),
    Value = fishTotal
  })
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingHalobiosTotal"),
    Value = halobiosTotal
  })
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingMostFish"),
    Value = mostFishName
  })
  table.insert(self.PeripheralData.ArchivesData, {
    Name = Lang("FishingLovestArea"),
    Value = lovestAreaName
  })
end

function FishingData.GetArchivesTitleData()
  local unionVM = Z.VMMgr.GetVM("union")
  local unionName = unionVM.GetPlayerUnionName()
  if unionName == "" then
    unionName = Lang("noYet")
  end
  local playerName = Z.ContainerMgr.CharSerialize.charBase.name
  local titleData = {Name = playerName, UnionName = unionName}
  return titleData
end

function FishingData.GetStarBySize(size, fishCfg)
  local star_ = 0
  local sizeTableCount = #fishCfg.Size
  if fishCfg.Size and 0 < sizeTableCount then
    for k, v in ipairs(fishCfg.Size) do
      if size >= v[1] and size < v[2] then
        star_ = k
        break
      end
      if k == sizeTableCount and size >= v[1] then
        star_ = k
        break
      end
    end
  end
  return star_
end

function FishingData:getMaxMinSize(fishCfg)
  local attrRow_ = Z.TableMgr.GetTable("FishingAttrTableMgr").GetRow(fishCfg.FishingAttrId)
  if attrRow_.SizeDefaultWeight and #attrRow_.SizeDefaultWeight > 0 then
    return attrRow_.SizeDefaultWeight[1][2] / 100, attrRow_.SizeDefaultWeight[#attrRow_.SizeDefaultWeight][3] / 100
  end
  return 0, 0
end

function FishingData:UpdateFishingData(refreshRed)
  self:updateFishingLevel()
  self:updateFishRodAndBait()
  self:refreshFishRecordDict()
  self:refreshFishingArchivesData()
  if refreshRed then
    local fishingRed = require("rednode.fishing_red")
    fishingRed.RefreshIllustratedItemRed()
    fishingRed.RefreshLevelRewardRed()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingBaitChange)
  Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingRodChange)
end

function FishingData:updateFishingLevel()
  local level, progress, curFishingExp, needFishingExp = self:GetFishingLevelByExp()
  local lastProgress = self.PeripheralData.FishingLevelProgress and self.PeripheralData.FishingLevelProgress[1] or 0
  self.PeripheralData.FishingLevelProgress = {
    progress,
    curFishingExp,
    needFishingExp
  }
  local lastLevel = self.FishingLevel
  self.FishingLevel = level
  if lastLevel and level > lastLevel then
    self.ShowLevelUp = true
  end
  if lastProgress ~= progress then
    Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingLevelChange)
  end
end

function FishingData:GetFishingLevelByExp()
  local exp = Z.ContainerMgr.CharSerialize.fishSetting.experiences
  local fishLevelCfgs_ = Z.TableMgr.GetTable("FishingLevelTableMgr").GetDatas()
  local level = -1
  local progress = 0
  local curFishingExp = 0
  local needFishingExp = 0
  local levelKeys_ = {}
  for k, v in pairs(fishLevelCfgs_) do
    table.insert(levelKeys_, k)
  end
  table.sort(levelKeys_)
  for _, v in ipairs(levelKeys_) do
    if exp < fishLevelCfgs_[v].Exp then
      level = fishLevelCfgs_[v].FishingLevel
      local lastExp_ = 1 < v and fishLevelCfgs_[v - 1].Exp or 0
      curFishingExp = exp - lastExp_
      needFishingExp = fishLevelCfgs_[v].Exp - lastExp_
      progress = curFishingExp / needFishingExp
      break
    end
  end
  if level == -1 then
    level = fishLevelCfgs_[#fishLevelCfgs_].FishingLevel
    progress = 1
    local fullExp_ = fishLevelCfgs_[#fishLevelCfgs_].Exp - fishLevelCfgs_[#fishLevelCfgs_ - 1].Exp
    curFishingExp = fullExp_
    needFishingExp = fullExp_
  end
  return level, progress, curFishingExp, needFishingExp
end

function FishingData:GetFishingRodDurability(uuid)
  local itemsVM_ = Z.VMMgr.GetVM("items")
  local rodConfigId_ = itemsVM_.GetItemTabDataByUuid(uuid).Id
  local fishingRodRow_ = Z.TableMgr.GetTable("FishingRodTableMgr").GetRow(rodConfigId_)
  if not fishingRodRow_ then
    return
  end
  local res = fishingRodRow_.Durability
  for key, rod in pairs(Z.ContainerMgr.CharSerialize.fishSetting.fishRodDurability) do
    if key == uuid then
      return res - rod
    end
  end
  return res
end

function FishingData:UpdateFishFirstUnLockFlag(fishId)
  local fishRecord_ = self.FishRecordDict[fishId].FishRecord
  if fishRecord_ then
    fishRecord_.firstFlag = true
  end
end

function FishingData:updateFishRodAndBait()
  self.FishBait = Z.ContainerMgr.CharSerialize.fishSetting.baitId
  self.FishingRod = Z.ContainerMgr.CharSerialize.fishSetting.rodUuid
  self.QTEData.UseResearchFish = Z.ContainerMgr.CharSerialize.fishSetting.researchFishId
end

function FishingData:AddFishingSettingWatcher()
  function self.onDataChange(container, dirtyKeys)
    self:UpdateFishingData(true)
    
    Z.EventMgr:Dispatch(Z.ConstValue.Fishing.FishingDataChange)
  end
  
  Z.ContainerMgr.CharSerialize.fishSetting.Watcher:RegWatcher(self.onDataChange)
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onDataChange)
end

function FishingData:RemoveFishingSettingWatcher()
  Z.ContainerMgr.CharSerialize.fishSetting.Watcher:UnregWatcher(self.onDataChange)
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onDataChange)
end

function FishingData:GetFishingRankRewardsData(fishId, isWorld)
  local fishingRankRewards = {}
  local fishingRankAwardTableRow = Z.TableMgr.GetTable("FishingRankAwardTableMgr").GetRow(fishId)
  if not fishingRankAwardTableRow then
    return fishingRankRewards
  end
  local rankList = {}
  local awardList = {}
  if isWorld then
    rankList = fishingRankAwardTableRow.WorldRank
    awardList = fishingRankAwardTableRow.WorldRankAward
  else
    rankList = fishingRankAwardTableRow.UnionRank
    awardList = fishingRankAwardTableRow.UnionRankAward
  end
  local lastMaxRank = 0
  for k, v in pairs(rankList) do
    local fishingRankRewardData = {}
    fishingRankRewardData.fishId = fishId
    fishingRankRewardData.minRank = lastMaxRank
    lastMaxRank = v
    fishingRankRewardData.maxRank = v
    fishingRankRewardData.awardPackageId = awardList[k]
    table.insert(fishingRankRewards, fishingRankRewardData)
  end
  return fishingRankRewards
end

function FishingData:GetActionFishList()
  local fishRecordList = {}
  if not self.FishRecordDict then
    return fishRecordList
  end
  for k, v in pairs(self.FishRecordDict) do
    if v.FishRecord ~= nil then
      table.insert(fishRecordList, v.FishCfg)
    end
  end
  return fishRecordList
end

function FishingData:GetActionIsMaxSize()
  if not Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "FishingActionIsMaxSize") then
    return true
  end
  return Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "FishingActionIsMaxSize") > 0
end

function FishingData:SetActionIsMaxSize(isMaxSize)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "FishingActionIsMaxSize", isMaxSize and 1 or 0)
end

function FishingData:GetCurActionSize()
  local isMaxSize = self:GetActionIsMaxSize()
  local fishID = self:GetActionFishId()
  if self.FishRecordDict[fishID] and self.FishRecordDict[fishID].FishRecord then
    return isMaxSize and self.FishRecordDict[fishID].FishRecord.size or self.FishRecordDict[fishID].FishRecord.minSize
  else
    return 0
  end
end

function FishingData:SetActionFishId(fishId)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "FishingActionFishId", fishId)
  Z.EventMgr:Dispatch(Z.ConstValue.Fishing.UpdateActionCurFishId)
end

function FishingData:GetActionFishId()
  local firstFishID = 0
  if 0 >= table.zcount(Z.ContainerMgr.CharSerialize.fishSetting.fishRecords) then
    return firstFishID
  end
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "FishingActionFishId") then
    return Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "FishingActionFishId")
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.fishSetting.fishRecords) do
    local recordData_ = v
    if 0 < recordData_.fishId then
      firstFishID = recordData_.fishId
      break
    end
  end
  self:SetActionFishId(firstFishID)
  return firstFishID
end

function FishingData:GetActionFishModelId()
  local fishID = self:GetActionFishId()
  if fishID == 0 then
    return 0
  end
  local fishRow = Z.TableMgr.GetTable("FishingTableMgr").GetRow(fishID)
  if fishRow == nil then
    return 0
  end
  return fishRow.ModelId
end

return FishingData
