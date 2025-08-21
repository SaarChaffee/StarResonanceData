local UI = Z.UI
local super = require("ui.ui_view_base")
local All_item_info_tipsView = class("All_item_info_tipsView", super)
local itemTipsView = require("ui.view.tips_item_info_popup_view")
local tipsPopupView = require("ui.view.tips_popup_view")
local tipsPopupPcView = require("ui.view.tips_item_info_popup_bag_pc_view")

function All_item_info_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "all_item_info_tips")
  self.tipsData_ = Z.DataMgr.Get("tips_data")
  self.viewsType = {
    item_tips = itemTipsView,
    common_tips = tipsPopupView,
    item_tips_pc = tipsPopupPcView
  }
end

function All_item_info_tipsView:OnActive()
  self.tipsData_ = Z.DataMgr.Get("tips_data")
  self.itemTipsViewPool_ = {}
  self.curShowItemInfoTipsViews_ = {}
  self.curShowTipsDatas_ = {}
  Z.EventMgr:Add(Z.ConstValue.CloseAllNoResidentTips, self.closeAllNoResidentTips, self)
end

function All_item_info_tipsView:OnDeActive()
  self.tipsData_:ClearItemTipsData()
  self.itemTipsData_ = {}
  for k, v in pairs(self.itemTipsViewPool_) do
    if v and next(v) then
      for i, val in pairs(v) do
        if val then
          val:DeActive()
        end
      end
    end
  end
  for k, v in pairs(self.curShowItemInfoTipsViews_) do
    if v then
      v:DeActive()
    end
  end
end

function All_item_info_tipsView:OnRefresh()
  local datas = self.tipsData_:GetItemTipsData()
  for _, value in pairs(datas) do
    self:refreshItemTips(value)
  end
  self.tipsData_:ClearItemTipsData()
end

function All_item_info_tipsView:refreshItemTips(tipsData)
  if not tipsData then
    return
  end
  local tipsId = tipsData.tipsId
  if not tipsId then
    return
  end
  local tipsView = self.curShowItemInfoTipsViews_[tipsId]
  if not tipsData.isOpen then
    if tipsView then
      self.curShowItemInfoTipsViews_[tipsId] = nil
      if self.itemTipsViewPool_[tipsView.viewConfigKey] == nil then
        self.itemTipsViewPool_[tipsView.viewConfigKey] = {}
      end
      local views = self.itemTipsViewPool_[tipsView.viewConfigKey]
      table.insert(views, tipsView)
      self.curShowTipsDatas_[tipsId] = nil
      tipsView:DeActive()
    end
    return
  end
  self.curShowTipsDatas_[tipsId] = tipsData
  if not tipsView then
    tipsView = self:getItemInfoView(tipsData)
    self.curShowItemInfoTipsViews_[tipsId] = tipsView
  end
  if tipsData.isVisible ~= nil then
    tipsView:SetVisible(tipsData.isVisible)
  end
  if tipsData.posType == E.EItemTipsPopType.Parent then
    tipsView:Active(tipsData, tipsData.parentTrans)
  else
    tipsView:Active(tipsData, self.uiBinder.tipsPartent)
  end
end

function All_item_info_tipsView:getItemInfoView(tipsData)
  local viewKey
  if tipsData.isPcTips then
    viewKey = "item_tips_pc"
  elseif tipsData.configId then
    viewKey = "item_tips"
  else
    viewKey = "common_tips"
  end
  if self.itemTipsViewPool_[viewKey] ~= nil then
    local count = #self.itemTipsViewPool_[viewKey]
    if 0 < count then
      local view = self.itemTipsViewPool_[viewKey][count]
      table.remove(self.itemTipsViewPool_[viewKey], count)
      return view
    else
      return self.viewsType[viewKey].new()
    end
  else
    return self.viewsType[viewKey].new()
  end
end

function All_item_info_tipsView:closeAllNoResidentTips()
  for k, v in pairs(self.curShowTipsDatas_) do
    if not v.isResident then
      v.isOpen = false
      self:refreshItemTips(v)
    end
  end
end

return All_item_info_tipsView
