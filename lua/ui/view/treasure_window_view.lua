local UI = Z.UI
local super = require("ui.ui_view_base")
local Treasure_windowView = class("Treasure_windowView", super)
local loopListView_ = require("ui/component/loop_list_view")
local treasureLoopItem = require("ui.component.treasure.treasure_loop_item")

function Treasure_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "treasure_window")
end

function Treasure_windowView:OnActive()
  self.treasureVm_ = Z.VMMgr.GetVM("treasure")
  self.targetTypeRoots_ = {}
  self.selectTable_ = {}
  self.selectTreasureItems_ = {}
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.loopListView_ = loopListView_.new(self, self.uiBinder.loop_item, treasureLoopItem, "treasure_list_tpl")
  self.loopListView_:Init({})
  self:AddClick(self.uiBinder.btn_view, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(2500)
  end)
  self:AddAsyncClick(self.uiBinder.btn_get, function()
    if not self:checkSelectAllType() then
      Z.TipsVM.ShowTips(15010001)
      return
    end
    local tbl = {}
    for _, value in pairs(self.selectTable_) do
      local data = (value.type - 1) * 10 + value.index - 1
      table.insert(tbl, data)
    end
    local rewardList = {}
    for _, value in pairs(self.selectTreasureItems_) do
      for __, item in pairs(value) do
        table.insert(rewardList, {
          ItemId = item.configId,
          ItemNum = item.count,
          ItemInfo = item
        })
      end
    end
    Z.DialogViewDataMgr:OpenNormalItemsDialog(Lang("treasure_get_reward_tips"), function()
      self.treasureVm_:AsyncGetTreasureReward(tbl, self.cancelSource:CreateToken())
      self:refreshTime()
      self:refreshList()
    end, nil, rewardList)
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.treasureVm_:CloseTreasureView()
  end)
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Treasure_windowView:OnDeActive()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.CommonTipsVM.CloseTipsTitleContent()
end

function Treasure_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Treasure_windowView:OnRefresh()
  self:refreshTime()
  self:refreshList()
end

function Treasure_windowView:refreshTime()
  if not self.treasureVm_:CheckCanGetTreasure() then
    if self.timer_ then
      self.timerMgr:StopTimer(self.timer_)
      self.timer_ = nil
    end
    local endLeftTime_, startLeftTime_ = Z.TimeTools.GetLeftTimeByTimerId(Z.Global.ExplorTreasureFreshTimerId)
    self.uiBinder.lab_time.text = Lang("EndingTimeRemaining", {
      str = Z.TimeFormatTools.FormatToDHMS(endLeftTime_)
    })
    self.timer_ = self.timerMgr:StartTimer(function()
      endLeftTime_ = endLeftTime_ - 1
      self.uiBinder.lab_time.text = Lang("EndingTimeRemaining", {
        str = Z.TimeFormatTools.FormatToDHMS(endLeftTime_)
      })
    end, 1, endLeftTime_ + 1, true, function()
      self.treasureVm_:CloseTreasureView()
    end)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_title, false)
  else
    self.uiBinder.lab_time.text = Lang("select_reward")
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, true)
    self.uiBinder.btn_get.interactable = false
    self.uiBinder.btn_get.IsDisabled = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_title, true)
  end
end

function Treasure_windowView:refreshList()
  local list = {}
  local treasureData = {}
  if not self.treasureVm_:CheckCanGetTreasure() then
    treasureData = Z.ContainerMgr.CharSerialize.treasure.rows
  else
    treasureData = Z.ContainerMgr.CharSerialize.treasure.historyRows
  end
  local data = {}
  for _, value in pairs(treasureData) do
    data[value.configId] = value
    local row = Z.TableMgr.GetTable("WeeklyTreasureTypeTableMgr").GetRow(value.configId)
    if row then
      if list[row.Type] then
        logError("\230\156\172\229\145\168\229\188\128\228\186\134\228\184\164\228\184\170\229\144\140\231\177\187\229\158\139\231\154\132\230\180\187\229\138\168,id1:{0}, id2:{1}, type:{2}", list[row.Type].Id, row.Id, row.Type)
      else
        list[row.Type] = {}
        list[row.Type].config = row
        list[row.Type].serverData = value
      end
    end
  end
  self.loopListView_:RefreshListView(list)
  self:refreshAwardTips(list)
end

function Treasure_windowView:refreshAwardTips(list)
  local content
  for _, value in pairs(list) do
    local baseAwards = {}
    table.insert(baseAwards, value.config.BaseAward)
    for index, upTargetAward in ipairs(value.config.UpTargetAward) do
      table.insert(baseAwards, upTargetAward[2])
    end
    for __, baseAward in ipairs(baseAwards) do
      local treasureAwardRow = Z.TableMgr.GetTable("WeeklyTreasureAwardTableMgr").GetRow(baseAward)
      if treasureAwardRow and not string.zisEmpty(treasureAwardRow.Text) then
        if content == nil then
          content = treasureAwardRow.Text
        else
          content = content .. "/" .. treasureAwardRow.Text
        end
      end
    end
  end
  if content == nil then
    self.uiBinder.lab_tips.text = ""
  else
    self.uiBinder.lab_tips.text = Lang("brackets", {str = content})
  end
  if self.treasureVm_:CheckCanGetTreasure() then
    self.allType_ = {}
    for _, value in ipairs(list) do
      if value.serverData then
        for __, treasureItemTarget in pairs(value.serverData.subTargets) do
          if treasureItemTarget.reward and treasureItemTarget.reward.type ~= 0 then
            self.allType_[treasureItemTarget.reward.type] = true
          end
        end
      end
    end
    self.uiBinder.lab_award_tips.text = Lang("treasure_target_award_tips", {
      val = table.zcount(self.allType_)
    })
  end
end

function Treasure_windowView:OnItemSelect(type, index, treasureItem, root)
  local treasureType = treasureItem.type
  self.selectTable_[treasureType] = {type = type, index = index}
  for index, value in ipairs(treasureItem.items) do
    self.selectTreasureItems_[treasureType] = {}
    table.insert(self.selectTreasureItems_[treasureType], value)
  end
  if self.targetTypeRoots_[treasureType] then
    self.targetTypeRoots_[treasureType].Ref:SetVisible(self.targetTypeRoots_[treasureType].img_select, false)
  end
  self.targetTypeRoots_[treasureType] = root
  self.targetTypeRoots_[treasureType].Ref:SetVisible(self.targetTypeRoots_[treasureType].img_select, true)
  self.uiBinder.btn_get.interactable = self:checkSelectAllType()
  self.uiBinder.btn_get.IsDisabled = not self:checkSelectAllType()
end

function Treasure_windowView:checkSelectAllType()
  for key, value in pairs(self.allType_) do
    if self.selectTable_[key] == nil then
      return false
    end
  end
  return true
end

return Treasure_windowView
