local super = require("ui.ui_view_base")
local Monthly_reward_card_listView = class("Monthly_reward_card_listView", super)
local handbookDefine = require("ui.model.handbook_define")
local loopListView = require("ui.component.loop_list_view")
local monthly_reward_loop_list_obtained_item = require("ui.component.monthly_reward_card.monthly_reward_loop_list_obtained_item")
local handbookMonthCardTableMap = require("table.HandbookMonthCardTableMap")

function Monthly_reward_card_listView:ctor()
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_list")
  self.handbookVM_ = Z.VMMgr.GetVM("handbook")
  self.handbookData_ = Z.DataMgr.Get("handbook_data")
end

function Monthly_reward_card_listView:OnActive()
  self:initBtn()
  local data = {}
  local dataCount = 0
  local monthCardConfigs = handbookMonthCardTableMap.MonthCard
  for _, id in pairs(monthCardConfigs) do
    local isUnlock = self.handbookVM_.IsUnlock(handbookDefine.HandbookType.MonthlyCard, id)
    if isUnlock then
      dataCount = dataCount + 1
      data[dataCount] = id
    end
  end
  self.selectId_ = nil
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_left_item, monthly_reward_loop_list_obtained_item, "monthly_reward_card_obtained_main_item_tpl")
  if dataCount == 0 then
    self.loopListView_:Init({})
    self:setEmptyState(true)
  else
    local mgr = Z.TableMgr.GetTable("NoteMonthCardTableMgr")
    table.sort(data, function(a, b)
      local aConfig = mgr.GetRow(a)
      local bConfig = mgr.GetRow(b)
      if aConfig and bConfig then
        if aConfig.Episode == bConfig.Episode then
          return a < b
        else
          return aConfig.Episode < bConfig.Episode
        end
      else
        return false
      end
    end)
    self.loopListView_:Init(data)
    self.loopListView_:SetSelected(1)
    self:setEmptyState(false)
  end
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.HandbookMonthCard)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
end

function Monthly_reward_card_listView:OnDeActive()
  self.monthlyCardData_ = nil
  self.currentCardIndex_ = nil
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Monthly_reward_card_listView:OnRefresh()
end

function Monthly_reward_card_listView:initBtn()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2090)
  end)
  self:AddClick(self.uiBinder.btn_square, function()
    Z.VMMgr.GetVM("shop").OpenShopView(E.FunctionID.MonthlyCard)
  end)
end

function Monthly_reward_card_listView:SetCardInfo(id)
  if self.selectId_ and self.selectId_ == id then
    return
  end
  local config = Z.TableMgr.GetTable("NoteMonthCardTableMgr").GetRow(id)
  if config then
    self.uiBinder.rimg_card:SetImage(config.Resources)
    self.uiBinder.lab_bottom_title.text = config.Name
    self.uiBinder.lab_desc.text = config.DictionaryDes
  end
end

function Monthly_reward_card_listView:setEmptyState(isVisible)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_card_info, not isVisible)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left_list_empty, isVisible)
end

return Monthly_reward_card_listView
