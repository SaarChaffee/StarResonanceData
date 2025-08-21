local UI = Z.UI
local super = require("ui.ui_view_base")
local House_play_farm_tipsView = class("House_play_farm_tipsView", super)

function House_play_farm_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_play_farm_tips")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.houseVm_ = Z.VMMgr.GetVM("house")
end

function House_play_farm_tipsView:initBinders()
  self.playerNameLab_ = self.uiBinder.lab_char_name
  self.itemNameLab_ = self.uiBinder.lab_name
  self.stateLab_ = self.uiBinder.lab_state
  self.timeLab_ = self.uiBinder.lab_time
  self.progressImg_ = self.uiBinder.img_progress
  self.collectNode_ = self.uiBinder.node_collect_info
  self.collectNumLab_ = self.uiBinder.lab_info_num
  self.collectInfoLab_ = self.uiBinder.lab_info
  self.imgIcon_ = self.uiBinder.img_icon
end

function House_play_farm_tipsView:initData()
  self.curStructureUid_ = self.viewData
  local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(self.curStructureUid_)
  self.farmlandInfo_ = structure.farmlandInfo
end

function House_play_farm_tipsView:initBtns()
end

function House_play_farm_tipsView:initUi()
  self:refreshUi()
end

function House_play_farm_tipsView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.HomeEntityStructureUpdate, self.structureUpdate, self)
end

function House_play_farm_tipsView:structureUpdate(uuid)
  if self.curStructureUid_ == uuid then
    local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(self.curStructureUid_)
    self.farmlandInfo_ = structure.farmlandInfo
    if not self.farmlandInfo_ or self.farmlandInfo_.isEnd then
      self.houseVm_.CloseHousePlayFarmTipsView()
    else
      self:refreshUi()
    end
  end
end

function House_play_farm_tipsView:refreshUi()
  if self.farmlandInfo_.isEnd then
    return
  end
  local homeSeedTableRow = Z.TableMgr.GetRow("HomeSeedTableMgr", self.farmlandInfo_.seedInstance.configId)
  if not homeSeedTableRow then
    return
  end
  self.curGrowType = self.farmlandInfo_.farmlandState:ToInt()
  local plantRuleRow = Z.TableMgr.GetRow("HomePlantRuleTableMgr", homeSeedTableRow.Type)
  if not plantRuleRow then
    return
  end
  local endTime = 0
  local needTime = 0
  self.itemNameLab_.text = plantRuleRow.Name
  if self.curGrowType == E.HomeEFarmlandState.EFarmlandStateGrow then
    endTime = self.farmlandInfo_.growEndTime
    local cutDownTime = 0
    for i = 0, self.farmlandInfo_.records.count - 1 do
      local data = self.farmlandInfo_.records[i]
      if data.isWatered then
        for index, value in ipairs(plantRuleRow.Watering) do
          if value[1] == data.segmentId then
            cutDownTime = cutDownTime + value[4]
            break
          end
        end
      end
    end
    for i = 0, self.farmlandInfo_.fertilizes.count - 1 do
      local id = self.farmlandInfo_.fertilizes[i]
      for index, value in ipairs(plantRuleRow.Fertilize) do
        if value[1] == id then
          cutDownTime = cutDownTime + value[2]
          break
        end
      end
    end
    needTime = plantRuleRow.GrowUpTime
    self.collectInfoLab_.text = Lang("ManureSurplusCount")
    self.collectNumLab_.text = plantRuleRow.FertilizeCount - self.farmlandInfo_.fertilizes.count
    self.stateLab_.text = Lang("FarmlandStateGrow")
    self.itemNameLab_.text = homeSeedTableRow.Name
    self.imgIcon_:SetImage(Z.GlobalHome.HomeStateGrowIcon)
  elseif self.curGrowType == E.HomeEFarmlandState.EFarmlandStatePollen then
    endTime = self.farmlandInfo_.pollinateEndTime
    needTime = plantRuleRow.PollinationTime
    self.stateLab_.text = Lang("FarmlandStatePollen")
    self.imgIcon_:SetImage(Z.GlobalHome.HomeStatePollenIcon)
  elseif self.curGrowType == E.HomeEFarmlandState.EFarmlandStateHarvest then
    self.stateLab_.text = Lang("FarmlandStateHarvest")
    local homeFlowerTableRow = Z.TableMgr.GetRow("HomeFlowerTableMgr", self.farmlandInfo_.flowerInstance.configId)
    if homeFlowerTableRow then
      self.collectInfoLab_.text = Lang("HouseCollectiblePollenCount")
      local count = Z.DIServiceMgr.HomeService:GetFarmlandPickUpCount(self.curStructureUid_)
      self.collectNumLab_.text = homeFlowerTableRow.MaxPickup - count
    end
    self.imgIcon_:SetImage(Z.GlobalHome.HomeStateHarvestIcon)
  end
  local curRefreshSecond = Panda.Util.ZTimeUtils.ConvertToUnixTimestamp(endTime)
  endTime = curRefreshSecond - Z.TimeTools.Now() / 1000
  self.progressImg_.fillAmount = 1
  if 0 < endTime then
    self.timerMgr:StopTimer(self.time_)
    if self.time_ then
      self.timerMgr:StopTimer(self.time_)
      self.time_ = nil
    end
    self.time_ = self.timerMgr:StartTimer(function()
      self.progressImg_.fillAmount = 1 - endTime / needTime
      self.timeLab_.text = Lang("RemainingTime:") .. Z.TimeFormatTools.FormatToDHMS(endTime)
      endTime = endTime - 1
      if endTime <= 0 and self.time_ then
        self.timerMgr:StopTimer(self.time_)
        self.time_ = nil
      end
    end, 1, endTime, nil, nil, true)
  end
  self.uiBinder.Ref:SetVisible(self.timeLab_, 0 < endTime)
  self.uiBinder.Ref:SetVisible(self.collectNode_, self.curGrowType == E.HomeEFarmlandState.EFarmlandStateHarvest or self.curGrowType == E.HomeEFarmlandState.EFarmlandStateGrow)
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, self.farmlandInfo_.operatorCharId, self.cancelSource:CreateToken())
    if socialData then
      self.playerNameLab_.text = socialData.basicData.name
    end
  end)()
end

function House_play_farm_tipsView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initData()
  self:initUi()
  self:bindEvent()
end

function House_play_farm_tipsView:OnDeActive()
end

function House_play_farm_tipsView:OnRefresh()
end

return House_play_farm_tipsView
