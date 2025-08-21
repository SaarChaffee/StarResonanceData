local super = require("ui.component.loop_list_view_item")
local BattlePassContentLoopItem = class("BattlePassContentLoopItem", super)
local itemClass = require("common.item_binder")

function BattlePassContentLoopItem:ctor()
  super:ctor()
end

function BattlePassContentLoopItem:OnInit()
  self:initParam()
  self:initWidgets()
  self:initBtn()
end

function BattlePassContentLoopItem:initWidgets()
  self.level_label = self.uiBinder.lab_grade
  self.top_item_node = self.uiBinder.top_node_item
  self.bottom_item_node = self.uiBinder.bottom_node_item
  self.lock_img = self.uiBinder.img_lock
  self.top_item_btn = self.uiBinder.btn_top
  self.bottom_item_btn = self.uiBinder.btn_bottom
  self.top_img = self.uiBinder.img_top
  self.itemBinders_ = {
    self.uiBinder.bpcard_item_square_01,
    self.uiBinder.bpcard_item_square_02,
    self.uiBinder.bpcard_item_square_03
  }
  for _, value in ipairs(self.itemBinders_) do
    value.event_triggle_temp:SetScrollRect(self.top_item_node)
    value.event_triggle_temp.onBeginDrag:RemoveAllListeners()
    value.event_triggle_temp.onDrag:RemoveAllListeners()
    value.event_triggle_temp.onEndDrag:RemoveAllListeners()
    value.event_triggle_temp.onBeginDrag:AddListener(function(go, eventData)
      value.btn_temp.interactable = false
    end)
    value.event_triggle_temp.onDrag:AddListener(function(go, eventData)
      value.btn_temp.interactable = false
    end)
    value.event_triggle_temp.onEndDrag:AddListener(function(go, eventData)
      value.btn_temp.interactable = true
    end)
  end
end

function BattlePassContentLoopItem:initBtn()
  self:AddAsyncListener(self.top_item_btn, function()
    self:getAwards(false)
  end)
  self:AddAsyncListener(self.bottom_item_btn, function()
    self:getAwards(true)
  end)
end

function BattlePassContentLoopItem:initParam()
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.itemClassTab_ = {}
  self.itemUnit = {}
  self.composeView_ = self.parent.UIView
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  self.itemListIndex = 1
  self.rewardList_ = {}
end

function BattlePassContentLoopItem:OnRefresh(data)
  self.data_ = data
  self:refreshItemState()
  self:initAward()
  self.composeView_:SetCurrentMaxShowIndex(self.Index)
end

function BattlePassContentLoopItem:refreshItemState()
  if next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.lock_img, not self.battlePassData_.CurBattlePassData.isUnlock)
  self.level_label.text = self.data_.configData.SeasonLevel
  self.uiBinder.Ref:SetVisible(self.top_img, self.data_.configData.SeasonLevel == self.battlePassData_.CurBattlePassData.level)
  self:setReceiveIsShow()
end

function BattlePassContentLoopItem:initAward()
  local freeAwards = self.awardPreviewVm_.GetAllAwardPreListByIds(self.data_.configData.FreeAward)
  local paidAwards = self.awardPreviewVm_.GetAllAwardPreListByIds(self.data_.configData.PaidAward)
  if self.cancelToken_ then
    self.composeView_.cancelSource:CancelToken(self.cancelToken_)
  end
  self.rewardList_ = {}
  self:loadAwardUnit(freeAwards, self.top_item_node, self.data_.freeAwardIsReceive, E.EBattlePassAwardType.Free)
  self:loadAwardUnit(paidAwards, self.bottom_item_node, self.data_.paidAwardIsReceive, E.EBattlePassAwardType.Payment)
  self:refreshRewardItem()
end

function BattlePassContentLoopItem:loadAwardUnit(awards, rootTrans, isShowReceive, awardType)
  if next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  if awards == nil or #awards < 1 then
    return
  end
  for k, v in ipairs(awards) do
    local d = {}
    d.awardData = v
    local isShowLight = self.data_.configData.SeasonLevel <= self.battlePassData_.CurBattlePassData.level and not isShowReceive
    if awardType == E.EBattlePassAwardType.Payment and not self.battlePassData_.CurBattlePassData.isUnlock then
      isShowLight = false
    end
    d.isShowLight = isShowLight
    d.isShowReceive = isShowReceive
    self.rewardList_[#self.rewardList_ + 1] = d
  end
end

function BattlePassContentLoopItem:refreshRewardItem()
  local count = #self.itemBinders_
  for i = 1, count do
    local data = self.rewardList_[i]
    local item = self.itemBinders_[i]
    self.uiBinder.Ref:SetVisible(item.Ref, data ~= nil)
    if data then
      local v = data.awardData
      local isShowReceive = data.isShowReceive
      local isShowLight = data.isShowLight
      if self.itemClassTab_[i] == nil then
        self.itemClassTab_[i] = itemClass.new(self)
      end
      local itemData = {
        uiBinder = item,
        configId = v.awardId,
        isPreview = true,
        PrevDropType = v.PrevDropType,
        isClickOpenTips = true,
        isShowReceive = isShowReceive,
        isShowLight = isShowLight,
        isSquareItem = true
      }
      itemData.labType, itemData.lab = self.awardPreviewVm_.GetPreviewShowNum(v)
      self.itemClassTab_[i]:Init(itemData)
      self.itemClassTab_[i]:SetRedDot(isShowLight)
    end
  end
end

function BattlePassContentLoopItem:OnUnInit()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self:clearUnit()
end

function BattlePassContentLoopItem:clearUnit()
  if not self.composeView_ then
    return
  end
  for _, v in pairs(self.itemUnit) do
    self.composeView_:RemoveUiUnit(v)
  end
  self.itemUnit = {}
end

function BattlePassContentLoopItem:getAwards(unlock)
  if next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  self.battlePassVM_.AsyncGetBattlePassAwardRequest(self.battlePassData_.CurBattlePassData.id, false, self.data_.configData.SeasonLevel, unlock, self.composeView_.cancelSource:CreateToken())
end

function BattlePassContentLoopItem:AddAsyncClick(btn, clickFunc, onErr, onCancel)
  self.composeView_:AddAsyncClick(btn, clickFunc, onErr, onCancel)
end

function BattlePassContentLoopItem:setReceiveIsShow()
  if next(self.battlePassData_.CurBattlePassData) == nil then
    return
  end
  if self.data_.configData.SeasonLevel > self.battlePassData_.CurBattlePassData.level then
    self.uiBinder.Ref:SetVisible(self.top_item_btn, false)
    self.uiBinder.Ref:SetVisible(self.bottom_item_btn, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.top_item_btn, not self.data_.freeAwardIsReceive)
  self.uiBinder.Ref:SetVisible(self.bottom_item_btn, not self.data_.paidAwardIsReceive and not not self.battlePassData_.CurBattlePassData.isUnlock)
end

return BattlePassContentLoopItem
