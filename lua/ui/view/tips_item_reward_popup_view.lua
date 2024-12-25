local super = require("ui.ui_view_base")
local Tips_item_reward_popupView = class("Tips_item_reward_popupView", super)
local itemBinder = require("common.item_binder")
local ITEM_SIZE = 110
local ITEM_SPACING = 8
local MAX_ROW_COUNT = 5
local HEIGHT_OFFSET = 138

function Tips_item_reward_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_item_reward_popup")
  self.itemBinderDict_ = {}
  self.loadItemDict_ = {}
end

function Tips_item_reward_popupView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_bg, false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearAwardItem()
    self:asyncLoadAwardItem()
  end)()
end

function Tips_item_reward_popupView:OnDeActive()
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
  self:clearAwardItem()
end

function Tips_item_reward_popupView:OnRefresh()
end

function Tips_item_reward_popupView:asyncLoadAwardItem()
  local itemPath = self.uiBinder.prefab_cache_data:GetString("item_path")
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardDataList = awardPreviewVm.GetAllAwardPreListByIds(self.viewData.AwardId)
  local itemCount = #awardDataList
  for index = 1, itemCount do
    local awardData = awardDataList[index]
    local itemName = "awardItem_" .. index
    if self.loadItemDict_[itemName] == nil then
      local item = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_item_root, self.cancelSource:CreateToken())
      self.loadItemDict_[itemName] = item
      self.itemBinderDict_[itemName] = itemBinder.new(self)
      local itemPreviewData = {
        uiBinder = item,
        configId = awardData.awardId,
        isSquareItem = true,
        PrevDropType = awardData.PrevDropType,
        tipsBindPressCheckComp = self.uiBinder.presscheck
      }
      itemPreviewData.labType, itemPreviewData.lab = awardPreviewVm.GetPreviewShowNum(awardData)
      self.itemBinderDict_[itemName]:Init(itemPreviewData)
    end
  end
  local totalRowCount = math.ceil(itemCount / MAX_ROW_COUNT)
  local totalHeight = totalRowCount * ITEM_SIZE + (totalRowCount - 1) * ITEM_SPACING
  self.uiBinder.trans_item_root:SetHeight(totalHeight)
  self.uiBinder.trans_bg:SetHeight(totalHeight + HEIGHT_OFFSET)
  self.uiBinder.adapt_pos_tips:UpdatePosition(self.viewData.ParentTrans, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_bg, true)
end

function Tips_item_reward_popupView:clearAwardItem()
  for _, itemBinder in pairs(self.itemBinderDict_) do
    itemBinder:UnInit()
  end
  self.itemBinderDict_ = {}
  for itemName, item in pairs(self.loadItemDict_) do
    self:RemoveUiUnit(itemName)
  end
  self.loadItemDict_ = {}
end

return Tips_item_reward_popupView
