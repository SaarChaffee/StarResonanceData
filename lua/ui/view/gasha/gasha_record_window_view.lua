local UI = Z.UI
local super = require("ui.ui_view_base")
local Gasha_record_windowView = class("Gasha_record_windowView", super)

function Gasha_record_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gasha_record_window")
  self.gashaVm_ = Z.VMMgr.GetVM("gasha")
  self.gashaData_ = Z.DataMgr.Get("gasha_data")
end

function Gasha_record_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initComp()
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.gashaShareId_ = nil
  self.isRequesting_ = false
  self:onAddListener()
end

function Gasha_record_windowView:initComp()
  self.btnclose_ = self.uiBinder.btn_close
  self.dpd_gasha_pools_ = self.uiBinder.dpd_gasha_pools
  self.node_empty_ = self.uiBinder.node_empty
  self.btn_arrow_left_ = self.uiBinder.btn_arrow_left
  self.btn_arrow_right_ = self.uiBinder.btn_arrow_right
  self.lab_page_ = self.uiBinder.lab_page
  self.node_list_ = self.uiBinder.node_list
  self.scenemask_ = self.uiBinder.scenemask
  self.recordItemBinders_ = {
    self.uiBinder.gasha_record_item_1,
    self.uiBinder.gasha_record_item_2,
    self.uiBinder.gasha_record_item_3,
    self.uiBinder.gasha_record_item_4,
    self.uiBinder.gasha_record_item_5
  }
end

function Gasha_record_windowView:onAddListener()
  self:AddClick(self.btnclose_, function()
    self.gashaVm_.CloseGashaRecordView()
  end)
  self:AddClick(self.btn_arrow_left_, function()
    self:changePage(-1)
  end)
  self:AddClick(self.btn_arrow_right_, function()
    self:changePage(1)
  end)
  self.dpd_gasha_pools_:AddListener(function(index)
    local gashaShareId = self.gashaData_:GetGashaPoolIdByIndex(index, self.viewData.openType)
    self:refreshContent(gashaShareId)
  end, true)
end

function Gasha_record_windowView:OnDeActive()
  self.gashaData_:ClearHistory()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Gasha_record_windowView:OnRefresh()
  if self.viewData == nil then
    logError("Gasha_record_windowView:OnRefresh() self.viewData is nil")
    return
  end
  self:refreshDropDown(self.viewData.gashaShareId)
  self:refreshContent(self.viewData.gashaShareId)
end

function Gasha_record_windowView:refreshDropDown(gashaId)
  local gashaPoolNames = self.gashaData_:GetAllGashPoolName(self.viewData.openType)
  self.dpd_gasha_pools_:ClearOptions()
  self.dpd_gasha_pools_:AddOptions(gashaPoolNames)
  self.dpd_gasha_pools_.value = self.gashaData_:GetIndexByGashaPoolId(gashaId, self.viewData.openType)
end

function Gasha_record_windowView:refreshContent(gashaShareId)
  Z.CoroUtil.create_coro_xpcall(function()
    if self.gashaShareId_ == gashaShareId then
      return
    end
    self.gashaShareId_ = gashaShareId
    local recordData = self.gashaVm_.AsyncGetGashaRecord(gashaShareId, 0, self.gashaData_.RecordPageSize, self.cancelSource:CreateToken())
    self.totaoCount_ = self.gashaData_:GetRecordTotalCount(self.gashaShareId_)
    self.totalPage_ = self.gashaData_:GetRecordTotalPage(self.gashaShareId_)
    self:refreshEmptyState(recordData == nil or #recordData == 0 or self.totaoCount_ == 0)
    self.pageIndex_ = 1
    self:refreshPageBtns()
    if recordData == nil or #recordData == 0 or self.totaoCount_ == 0 then
      return
    end
    self:refreshRecordByPageIndex(self.pageIndex_)
  end)()
end

function Gasha_record_windowView:refreshEmptyState(isEmpty)
  self.uiBinder.Ref:SetVisible(self.node_empty_, isEmpty)
  self.uiBinder.Ref:SetVisible(self.node_list_, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.btn_arrow_left_, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.btn_arrow_right_, not isEmpty)
  self.uiBinder.Ref:SetVisible(self.lab_page_, not isEmpty)
end

function Gasha_record_windowView:changePage(direction)
  if self.isRequesting_ then
    return
  end
  local newPageIndex = self.pageIndex_ + direction
  if newPageIndex < 1 or newPageIndex > self.totalPage_ then
    return
  end
  self.pageIndex_ = newPageIndex
  self:refreshRecordByPageIndex(self.pageIndex_)
  self:refreshPageBtns()
end

function Gasha_record_windowView:refreshPageBtns()
  self.uiBinder.Ref:SetVisible(self.btn_arrow_left_, self.pageIndex_ > 1)
  self.uiBinder.Ref:SetVisible(self.btn_arrow_right_, self.pageIndex_ < self.totalPage_)
  local totalStr = Z.RichTextHelper.ApplyStyleTag(self.totalPage_, "GashaPageTotal")
  self.lab_page_.text = string.zconcat(self.pageIndex_, "/", totalStr)
end

function Gasha_record_windowView:refreshRecordByPageIndex(pageIndex)
  Z.CoroUtil.create_coro_xpcall(function()
    self.isRequesting_ = true
    local startIndex = math.max(0, (pageIndex - 1) * self.gashaData_.RecordPageSize)
    local recordDatas = self.gashaVm_.AsyncGetGashaRecord(self.gashaShareId_, startIndex, self.gashaData_.RecordPageSize, self.cancelSource:CreateToken())
    self.isRequesting_ = false
    if recordDatas == nil then
      return
    end
    self:refreshRecords(recordDatas)
  end, function(err)
    logError(err)
    self.isRequesting_ = false
  end)()
end

function Gasha_record_windowView:refreshRecords(recordDatas)
  for i = 1, self.gashaData_.RecordPageSize do
    self:refreshRecord(recordDatas[i], self.recordItemBinders_[i])
  end
end

function Gasha_record_windowView:refreshRecord(recordData, uibinder)
  self.uiBinder.Ref:SetVisible(uibinder.Ref, false)
  if recordData == nil then
    return
  end
  local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", recordData.configId)
  if itemTableRow == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(uibinder.Ref, true)
  local gashaQuality = recordData.quality
  local colorTag = "ItemQuality_" .. itemTableRow.Quality
  uibinder.lab_type.text = Lang(string.zconcat("GashaQuilityName_", gashaQuality))
  uibinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(itemTableRow.Name, colorTag)
  uibinder.lab_time.text = Z.TimeFormatTools.TicksFormatTime(recordData.time * 1000, E.TimeFormatType.YMDHMS)
  uibinder.lab_number.text = recordData.count
end

return Gasha_record_windowView
