local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_active_subView = class("Union_active_subView", super)
local loopListView = require("ui.component.loop_list_view")
local union_active_item = require("ui.component.union.union_active_item")
local unionRed_ = require("rednode.union_red")
local AWARD_WIDTH = 222

function Union_active_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_active_sub", "union_2/union_active_sub", UI.ECacheLv.None)
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.unionActiveListTableMgr_ = Z.TableMgr.GetTable("UnionActiveListTableMgr")
  self.unionActiveValueTableMgr_ = Z.TableMgr.GetTable("UnionActiveValueTableMgr")
  self.itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
  self.allAwardItemDict_ = nil
end

function Union_active_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self:bindEvents()
  self:initQuery()
end

function Union_active_subView:OnDeActive()
  self:unInitLoopListView()
  self:clearAwardItem()
  self:unbindEvents()
  Z.UIMgr:CloseView("tips_item_reward_popup")
end

function Union_active_subView:OnRefresh()
end

function Union_active_subView:initData()
  self.allAwardItemList_ = self.unionActiveValueTableMgr_:GetDatas()
  self.curActiveValue_ = self.unionVM_:GetUnionResourceCount(E.UnionResourceId.Active)
  local maxConfig = self.allAwardItemList_[#self.allAwardItemList_]
  self.maxActiveValue_ = maxConfig.ActiveValue
  self.refreshTimerId_ = Z.Global.UnionActiveRefresh
  self.rewardTimeLimit_ = Z.Global.UnionDuration
  self.targetInfoDict_ = {}
  self.isEnoughGetTime_ = self.unionVM_:IsEnoughActiveGetTime()
end

function Union_active_subView:initComponent()
  self.uiBinder.lab_time_desc.text = Z.TimeTools.GetTimeDescByTimerId(self.refreshTimerId_)
  self.uiBinder.sliced_image.fillAmount = 0
  local itemsVM = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_active_icon:SetImage(itemsVM.GetItemIcon(E.UnionResourceId.Active))
  self:initLoopListView()
end

function Union_active_subView:initQuery()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncLoadAwardItem()
    self:asyncReqGetActiveInfo()
  end)()
end

function Union_active_subView:refreshTotalInfo()
  self:refreshSlider()
  self:refreshAwardInfo()
  self:refreshLoopListView()
end

function Union_active_subView:getTotalActiveList()
  local totalList = {}
  local dataList = self.unionActiveListTableMgr_:GetDatas()
  for id, config in pairs(dataList) do
    table.insert(totalList, {
      config = config,
      targetInfo = self.targetInfoDict_[id]
    })
  end
  table.sort(totalList, function(a, b)
    local a_reach = a.targetInfo and a.targetInfo.hasFinished and 1 or 0
    local b_reach = b.targetInfo and b.targetInfo.hasFinished and 1 or 0
    if a_reach == b_reach then
      return a.config.Id < b.config.Id
    else
      return a_reach < b_reach
    end
  end)
  return totalList
end

function Union_active_subView:asyncLoadAwardItem()
  self:clearAwardItem()
  for index, config in ipairs(self.allAwardItemList_) do
    local itemName = "awardItem_" .. index
    local itemPath = GetLoadAssetPath(Z.ConstValue.UnionLoadPathKey.UnionActiveItem)
    local binderItem = self:AsyncLoadUiUnit(itemPath, itemName, self.uiBinder.trans_content)
    local activeItemInfo = {binderItem = binderItem, config = config}
    self.allAwardItemDict_[itemName] = activeItemInfo
    self:calAwardPos(activeItemInfo)
    self:refreshSingleAward(activeItemInfo, true)
  end
end

function Union_active_subView:clearAwardItem()
  if self.allAwardItemDict_ then
    for itemName, info in pairs(self.allAwardItemDict_) do
      unionRed_.RemoveUnionActiveRedItem(info.config.AwardId, self)
      self:RemoveUiUnit(itemName)
    end
  end
  self.allAwardItemDict_ = {}
end

function Union_active_subView:refreshAwardInfo()
  if self.allAwardItemDict_ then
    for itemName, info in pairs(self.allAwardItemDict_) do
      self:refreshSingleAward(info, false)
    end
  end
end

function Union_active_subView:refreshSlider()
  local nextActiveValue = self.maxActiveValue_
  for i, v in ipairs(self.allAwardItemList_) do
    if v.ActiveValue > self.curActiveValue_ then
      nextActiveValue = v.ActiveValue
      break
    end
  end
  if nextActiveValue < self.curActiveValue_ then
    self.uiBinder.lab_active.text = nextActiveValue .. "/" .. nextActiveValue
  else
    self.uiBinder.lab_active.text = self.curActiveValue_ .. "/" .. nextActiveValue
  end
  self.uiBinder.sliced_image.fillAmount = self.curActiveValue_ / self.maxActiveValue_
end

function Union_active_subView:calAwardPos(itemInfo)
  local ratio = itemInfo.config.ActiveValue / self.maxActiveValue_
  local slider_width = self.uiBinder.sliced_image.transform.rect.width
  local posX = slider_width * ratio - AWARD_WIDTH * 0.5
  itemInfo.binderItem.Trans:SetAnchorPosition(posX, 0)
end

function Union_active_subView:refreshSingleAward(itemInfo, isInit)
  local isReached = self.curActiveValue_ >= itemInfo.config.ActiveValue
  local isHadGet = self.unionData_:IsUnionActiveHadGet(itemInfo.config.Id)
  local isCanGet = self.isEnoughGetTime_ and isReached and not isHadGet
  if isInit then
    local qualityPath = Z.ConstValue.Item.ItemQualityPath .. itemInfo.config.IconType
    itemInfo.binderItem.binder_item.img_quality:SetImage(qualityPath)
    itemInfo.binderItem.binder_item.rimg_icon:SetImage(itemInfo.config.Icon)
    itemInfo.binderItem.binder_item.btn_temp:AddListener(function()
      self.isEnoughGetTime_ = self.unionVM_:IsEnoughActiveGetTime()
      local isReachedTemp = self.curActiveValue_ >= itemInfo.config.ActiveValue
      local isHadGetTemp = self.unionData_:IsUnionActiveHadGet(itemInfo.config.Id)
      local isCanGetTemp = isReachedTemp and not isHadGetTemp
      if isCanGetTemp and self.isEnoughGetTime_ then
        Z.CoroUtil.create_coro_xpcall(function()
          self:asyncReqGetActiveAward(itemInfo.config.Id)
        end)()
      else
        local viewData = {
          AwardId = itemInfo.config.AwardId,
          ParentTrans = itemInfo.binderItem.binder_item.btn_temp.transform
        }
        Z.UIMgr:OpenView("tips_item_reward_popup", viewData)
        if isCanGetTemp and not self.isEnoughGetTime_ then
          local timeDesc = Z.TimeTools.FormatToHMS(self.rewardTimeLimit_)
          Z.TipsVM.ShowTips(1000553, {time = timeDesc})
        elseif not isReachedTemp and not isHadGetTemp then
          Z.TipsVM.ShowTips(1000554)
        end
      end
    end)
  end
  itemInfo.binderItem.lab_digit.text = itemInfo.config.ActiveValue
  itemInfo.binderItem.Ref:SetVisible(itemInfo.binderItem.img_on, isReached)
  itemInfo.binderItem.Ref:SetVisible(itemInfo.binderItem.img_off, not isReached)
  itemInfo.binderItem.Ref:SetVisible(itemInfo.binderItem.img_select, isCanGet)
  itemInfo.binderItem.Ref:SetVisible(itemInfo.binderItem.img_get, isHadGet)
  if isCanGet then
    unionRed_.LoadUnionActiveItem(itemInfo.config.AwardId, self, itemInfo.binderItem.binder_item.Trans)
  end
end

function Union_active_subView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_activity, union_active_item, "union_active_task_item_tpl")
  local configList = self:getTotalActiveList()
  self.loopListView_:Init(configList)
end

function Union_active_subView:refreshLoopListView()
  local configList = self:getTotalActiveList()
  self.loopListView_:RefreshListView(configList)
end

function Union_active_subView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Union_active_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_active_subView:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UnionResourceChange, self.onUnionResourceChange, self)
end

function Union_active_subView:onUnionResourceChange()
  self.curActiveValue_ = self.unionVM_:GetUnionResourceCount(E.UnionResourceId.Active)
  self:refreshSlider()
  self:refreshAwardInfo()
end

function Union_active_subView:asyncReqGetActiveInfo()
  local reply = self.unionVM_:AsyncGetActiveInfo(self.cancelSource:CreateToken())
  if reply.errCode and reply.errCode == 0 then
    for id, info in pairs(reply.selfActivity.personalTargets) do
      self.targetInfoDict_[id] = info
    end
    for id, info in pairs(reply.unionActivity.unionTargets) do
      self.targetInfoDict_[id] = info
    end
    self:refreshTotalInfo()
  end
end

function Union_active_subView:asyncReqGetActiveAward(id)
  local reply = self.unionVM_:AsyncGetActiveAward(id, self.cancelSource:CreateToken())
  if reply.errCode and reply.errCode == 0 then
    self:refreshAwardInfo()
  end
end

return Union_active_subView
