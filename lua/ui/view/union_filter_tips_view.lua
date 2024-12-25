local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_filter_tipsView = class("Union_filter_tipsView", super)
local unionTagItem = require("ui.component.union.union_tag_item")
local SELECT_ICON_COLOR = Color.black
local SELECT_ON_COLOR = Color.New(0.9058823529411765, 0.984313725490196, 0, 1)

function Union_filter_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_filter_tips")
end

function Union_filter_tipsView:OnActive()
  self.uiBinder.adapt_pos_tips:UpdatePosition(self.viewData.worldPosition)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  self:AddClick(self.uiBinder.binder_filter_full.btn_item, function()
    self.filterData_.HideFullUnion = not self.filterData_.HideFullUnion
    self:refreshFilterUI()
  end)
  self:AddClick(self.uiBinder.btn_clear, function()
    self.filterData_ = {
      TagDict = {},
      HideFullUnion = false
    }
    self:refreshFilterUI()
  end)
  self:AddClick(self.uiBinder.btn_sift, function()
    self.viewData.callback(self.filterData_)
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.unionTagTableMgr_ = Z.TableMgr.GetTable("UnionTagTableMgr")
  self.unionTagItem_ = unionTagItem.new()
  self.unionTagItem_:Init(E.UnionTagItemType.Normal, self, self.uiBinder.trans_time_icon, self.uiBinder.trans_activity_icon)
  self.filterData_ = self.viewData.filterData
  self:refreshFilterUI()
end

function Union_filter_tipsView:OnDeActive()
  self:clearAllFilterItem()
  self.uiBinder.presscheck.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.presscheck:StopCheck()
  self.unionTagItem_:UnInit()
  self.unionTagItem_ = nil
  self.filterData_ = nil
end

function Union_filter_tipsView:OnRefresh()
end

function Union_filter_tipsView:refreshFilterUI()
  self:setTagFilter()
  self:setOtherFilter()
  self:refreshFilterList()
end

function Union_filter_tipsView:setTagFilter()
  local allTagList = self.unionTagTableMgr_.GetDatas()
  self.unionTagItem_:SetTag(allTagList, nil, nil, function(config, item)
    self:tagItemClickCallback(config, item)
  end, function()
    self:tagItemLoadedCallback()
  end)
end

function Union_filter_tipsView:setOtherFilter()
  local isFullSelect = self.filterData_.HideFullUnion
  self.uiBinder.binder_filter_full.Ref:SetVisible(self.uiBinder.binder_filter_full.img_on, isFullSelect)
  self.uiBinder.binder_filter_full.Ref:SetVisible(self.uiBinder.binder_filter_full.img_off, not isFullSelect)
end

function Union_filter_tipsView:tagItemClickCallback(config, item)
  local isSelected = not self.filterData_.TagDict[config.Id]
  if isSelected then
    self.filterData_.TagDict[config.Id] = isSelected
  else
    self.filterData_.TagDict[config.Id] = nil
  end
  self.unionTagItem_:SetTagColor(item, isSelected)
  self.unionTagItem_:SetTagBgColor(item, isSelected)
  self:refreshFilterList()
end

function Union_filter_tipsView:tagItemLoadedCallback()
  local tagItemDict = self.unionTagItem_:GetItemDict()
  for id, item in pairs(tagItemDict) do
    local isSelected = self.filterData_.TagDict[id]
    self.unionTagItem_:SetTagColor(item, isSelected)
    self.unionTagItem_:SetTagBgColor(item, isSelected)
  end
end

function Union_filter_tipsView:refreshFilterList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearAllFilterItem()
    for id, value in pairs(self.filterData_.TagDict) do
      if value == true then
        local itemName = "tag_" .. id
        local tagConfig = self.unionTagTableMgr_.GetRow(id)
        local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionNormalTagItem)
        local binderItem = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_filter)
        self.allLoadItemDict_[itemName] = binderItem
        if tagConfig.ShowTagRoute ~= "" then
          binderItem.img_icon:SetImage(tagConfig.ShowTagRoute)
          binderItem.img_icon:SetColor(SELECT_ICON_COLOR)
          binderItem.img_on:SetColor(SELECT_ON_COLOR)
          binderItem.Ref:SetVisible(binderItem.img_icon, true)
        else
          binderItem.Ref:SetVisible(binderItem.img_icon, false)
        end
      end
    end
    if self.filterData_.HideFullUnion == true then
      local itemName = "item_full"
      local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionFilterItem)
      local binderItem = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_filter)
      self.allLoadItemDict_[itemName] = binderItem
      binderItem.lab_name_on.text = Lang("UnionFilterFull")
      binderItem.lab_name_off.text = Lang("UnionFilterFull")
      binderItem.Ref:SetVisible(binderItem.img_on, true)
      binderItem.Ref:SetVisible(binderItem.img_off, false)
    end
  end)()
end

function Union_filter_tipsView:clearAllFilterItem()
  if self.allLoadItemDict_ then
    for name, item in pairs(self.allLoadItemDict_) do
      self:RemoveUiUnit(name)
    end
  end
  self.allLoadItemDict_ = {}
end

return Union_filter_tipsView
