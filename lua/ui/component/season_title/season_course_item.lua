local super = require("ui.component.loop_grid_view_item")
local SeasonCourseItem = class("SeasonCourseItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function SeasonCourseItem:ctor()
  self.uiBinder = nil
  self.seasonTitleData_ = Z.DataMgr.Get("season_title_data")
  self.seasonTitleVM_ = Z.VMMgr.GetVM("season_title")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.config_ = nil
end

function SeasonCourseItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished, false)
end

function SeasonCourseItem:OnRefresh(data)
  self.data = data
  self.config_ = self.seasonTitleData_:GetRankIdConfig(data)
  if self.config_ == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_unfinished, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_finished, true)
  local seasonInfo = self.seasonTitleData_:GetCurRankInfo()
  if seasonInfo == nil then
    return
  end
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local seasonRankConfig = seasonRankTableMgr.GetRow(seasonInfo.curRanKStar)
  if seasonRankConfig == nil then
    return
  end
  local allConfigs = self.seasonTitleData_:GetRankRewardConfigList()
  for key, value in ipairs(allConfigs) do
    if value.RankId == data then
      self.uiBinder.lab_finished_level.text = key
      break
    end
  end
  if self.config_.RankId < seasonRankConfig.RankId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_finished, true)
    self.uiBinder.img_line_finished.fillAmount = 1
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished_icon, true)
  elseif self.config_.RankId == seasonRankConfig.RankId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_finished, true)
    self.uiBinder.img_line_finished.fillAmount = self.seasonTitleVM_.CheckRankStarProgress(self.config_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished_icon, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_finished, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished_icon, false)
  end
  if self.config_.RankId == self.seasonTitleData_:GetMaxRankId() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_unfinished, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_finished, false)
  end
  local isReceived = false
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    if value == self.config_.Id then
      isReceived = true
      break
    end
  end
  if isReceived then
    self.uiBinder.rimg_icon:SetColor(Color.New(1, 1, 1, 0.5))
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  else
    self.uiBinder.rimg_icon:SetColor(Color.New(1, 1, 1, 1))
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, self.config_.RankId <= seasonRankConfig.RankId)
  end
  local rewards = self.awardPreviewVM_.GetAllAwardPreListByIds(self.config_.RewardId)
  if rewards[1] then
    local itemData = {}
    itemData.configId = rewards[1].awardId
    itemData.uiBinder = self.uiBinder.binder_item
    itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(rewards[1])
    itemData.isShowZero = false
    itemData.isShowOne = true
    itemData.isShowReceive = isReceived
    itemData.isSquareItem = true
    itemData.PrevDropType = rewards[1].PrevDropType
    
    function itemData.clickCallFunc()
      if self.config_ then
        if not isReceived and self.config_.RankId <= seasonRankConfig.RankId then
          self.seasonTitleVM_.AsyncReceiveSeasonRankAward(self.config_.Id)
        else
          self.parent.UIView:SetCurSelectItem(self.config_.RankId)
        end
      end
    end
    
    self.itemClass_:Init(itemData)
    self.itemClass_:SetSelected(false)
  end
  self:SelectState()
  local rankId = self.seasonTitleVM_.GetUnReceivedRankId()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finished, rankId == self.config_.RankId)
end

function SeasonCourseItem:Selected(isSelected)
  self:SelectState()
end

function SeasonCourseItem:SelectState()
  local isSelected = self.IsSelected
  self.itemClass_:SetSelected(isSelected)
end

function SeasonCourseItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function SeasonCourseItem:OnUnInit()
  self.itemClass_:UnInit()
end

return SeasonCourseItem
