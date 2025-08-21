local UI = Z.UI
local super = require("ui.ui_view_base")
local House_upgrade_popupView = class("House_upgrade_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local houseLevelDescLoopItem = require("ui.component.house.house_level_desc_loop_item")
local houseLevelAwardLoopItem = require("ui.component.house.house_level_reward_loop_item")

function House_upgrade_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_upgrade_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.awardprevVm_ = Z.VMMgr.GetVM("awardpreview")
end

function House_upgrade_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.presscheck_tipspress:StartCheck()
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self:EventAddAsyncListener(self.uiBinder.presscheck_tipspress.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.presscheck_tipspress:StopCheck()
      self.houseVm_.CloseHouseUpgradeView()
    end
  end, nil, nil)
  self:initViewList()
end

function House_upgrade_popupView:initViewList()
  self.loopLevelListView_ = loopListView.new(self, self.uiBinder.scrollview_levelreward, houseLevelDescLoopItem, "house_unlock_item_tpl")
  self.rewardListView_ = loopListView.new(self, self.uiBinder.scrollview_award_item, houseLevelAwardLoopItem, "com_item_square_1_8")
  self.loopLevelListView_:Init({})
  self.rewardListView_:Init({})
end

function House_upgrade_popupView:OnDeActive()
  self.loopLevelListView_:UnInit()
  self.loopLevelListView_ = nil
  self.rewardListView_:UnInit()
  self.rewardListView_ = nil
end

function House_upgrade_popupView:OnRefresh()
  self.curLevel = self.houseData_:GetHouseLevel()
  self.uiBinder.lab_level.text = tostring(self.curLevel)
  self:refreshLevelList()
  self:refreshRewardList()
end

function House_upgrade_popupView:refreshLevelList()
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel)
  if not homeLevelTableRow then
    return
  end
  local dataList = {}
  for k, v in ipairs(homeLevelTableRow.LvUpDesc) do
    local data = {}
    data.desc = v
    data.isUnlocked = true
    table.insert(dataList, data)
  end
  self.loopLevelListView_:RefreshListView(dataList)
end

function House_upgrade_popupView:refreshRewardList()
  local homeLevelTableRow = Z.TableMgr.GetTable("HomeLevelTableMgr").GetRow(self.curLevel - 1)
  if not homeLevelTableRow then
    return
  end
  local mailTableRow = Z.TableMgr.GetTable("MailTableMgr").GetRow(homeLevelTableRow.Mailid)
  if mailTableRow == nil then
    return
  end
  local awardID = mailTableRow.AwardId
  local awardList = self.awardprevVm_.GetAllAwardPreListByIds(awardID)
  self.rewardListView_:RefreshListView(awardList)
end

return House_upgrade_popupView
