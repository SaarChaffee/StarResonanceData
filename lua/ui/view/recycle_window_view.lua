local UI = Z.UI
local super = require("ui.ui_view_base")
local Recycle_windowView = class("Recycle_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local loopTotalItem = require("ui/component/recycle/recycle_total_item")
local loopPreviewItem = require("ui/component/recycle/recycle_preview_item")
local loopObtainItem = require("ui/component/recycle/recycle_obtain_item")

function Recycle_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "recycle_window")
end

function Recycle_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UIMgr:FadeIn({
    IsInstant = true,
    TimeOut = Z.UICameraHelperFadeTime
  })
  self:initData()
  self:initComp()
  self:initCamera()
  self:initLoopComp()
end

function Recycle_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unInitCamera()
  self:unInitLoopComp()
  self:CloseItemTips()
  self.recycleData_:ClearTempRecycleData()
end

function Recycle_windowView:OnRefresh()
  self:RefreshLeftPanel()
  self:RefreshRightPanel()
end

function Recycle_windowView:initData()
  self.curRecycleId_ = self.viewData
  self.recycleVM_ = Z.VMMgr.GetVM("recycle")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.recycleData_ = Z.DataMgr.Get("recycle_data")
  self.curRecycleRow_ = Z.TableMgr.GetRow("RecycleTableMgr", self.curRecycleId_)
  self.curFunctionRow_ = Z.TableMgr.GetRow("FunctionTableMgr", self.curRecycleRow_.SystemId)
  self.CurSelectItemDict = {}
  self.curSortType_ = E.RecycleItemSortType.Quality
  self.curSortAscending_ = false
  self.lastClickIndex_ = nil
  self.recycleData_:InitTempRecycleData()
end

function Recycle_windowView:initComp()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.OpenFullScreenTipsView(500111)
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm, function()
    self:OnConfirmBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:OnCancelBtnClick()
  end)
  self:AddClick(self.uiBinder.binder_sort.sort_btn, function()
    self:OnSortBtnClick()
  end)
  local options = {
    [1] = Lang("ColorOrder"),
    [2] = Lang("CountSort")
  }
  self.uiBinder.binder_sort.dpd:ClearAll()
  self.uiBinder.binder_sort.dpd:AddOptions(options)
  self.uiBinder.binder_sort.dpd:AddListener(function(index)
    self.curSortType_ = index + 1
    self:RefreshLeftPanel()
  end, true)
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig(self.curFunctionRow_.Id)
  self.uiBinder.img_icon:SetImage(self.curFunctionRow_.Icon)
end

function Recycle_windowView:initLoopComp()
  self.loopTotalGridView_ = loopGridView.new(self, self.uiBinder.loop_item_total, loopTotalItem, "com_item_long_3")
  self.loopTotalGridView_:Init({})
  self.loopPreviewGridView_ = loopGridView.new(self, self.uiBinder.loop_item_preview, loopPreviewItem, "com_item_long_1")
  self.loopPreviewGridView_:Init({})
  self.loopObtainListView_ = loopListView.new(self, self.uiBinder.loop_item_obtain, loopObtainItem, "com_item_square_1_8")
  self.loopObtainListView_:Init({})
end

function Recycle_windowView:unInitLoopComp()
  self.loopTotalGridView_:UnInit()
  self.loopTotalGridView_ = nil
  self.loopPreviewGridView_:UnInit()
  self.loopPreviewGridView_ = nil
  self.loopObtainListView_:UnInit()
  self.loopObtainListView_ = nil
end

function Recycle_windowView:initCamera()
  Z.CameraMgr:CameraInvoke(E.CameraState.Position, true, self.curRecycleRow_.CameraTemplateId, false)
  Z.UICameraHelper.SetCameraFocus(true, Z.Global.CameraFocusRecycleView[1], Z.Global.CameraFocusRecycleView[2])
end

function Recycle_windowView:unInitCamera()
  Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.curRecycleRow_.CameraTemplateId, false)
  Z.UICameraHelper.SetCameraFocus(false)
end

function Recycle_windowView:OnTotalItemAdd(data)
  local selectCount = self.recycleData_:GetTempRecycleCount(data)
  if selectCount >= Z.Global.RecycleItemNumMax then
    Z.TipsVM.ShowTips(800002)
    return
  end
  local columnCount = self.recycleData_:GetTempRecycleRolumnCount()
  if selectCount <= 0 and columnCount >= Z.Global.RecycleItemMax then
    Z.TipsVM.ShowTips(800001)
    return
  end
  local itemInfo = self.itemsVM_.GetItemInfobyItemId(data.itemUuid, data.configId)
  local haveCount = itemInfo and itemInfo.count or 0
  if selectCount >= haveCount then
    return
  end
  self.recycleData_:AddTempRecycleData(data)
  self:RefreshRightPanel()
end

function Recycle_windowView:OnTotalItemReduce(data)
  self.recycleData_:ReduceTempRecycleData(data)
  self:RefreshRightPanel()
end

function Recycle_windowView:OnTotalItemClick(index, trans, data)
  if self.lastClickIndex_ and self.lastClickIndex_ ~= index then
    self.loopTotalGridView_:RefreshItemByItemIndex(self.lastClickIndex_)
  end
  self.lastClickIndex_ = index
  self:OpenItemTips(trans, data.configId, data.itemUuid)
end

function Recycle_windowView:RefreshLeftPanel()
  local sortData = {
    recycleSortType = self.curSortType_,
    isAscending = self.curSortAscending_
  }
  self.curTotalItemList_ = self.recycleData_:GetTotalCanRecycleItems(self.curRecycleRow_.SystemId, sortData)
  self.loopTotalGridView_:RefreshListView(self.curTotalItemList_, true)
  local isShowPanel = #self.curTotalItemList_ > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left, isShowPanel)
end

function Recycle_windowView:RefreshRightPanel()
  self.curSelectItemList_ = self.recycleData_:GetTempRecycleList()
  self.loopPreviewGridView_:RefreshListView(self.curSelectItemList_, true)
  local obtainItemList = self.recycleData_:GetRecycleObtainList(self.curRecycleRow_.SystemId, self.curSelectItemList_)
  self.loopObtainListView_:RefreshListView(obtainItemList, true)
  local isShowEmpty = #self.curSelectItemList_ == 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, not isShowEmpty)
  if isShowEmpty then
    if #self.curTotalItemList_ == 0 then
      self.uiBinder.lab_empty.text = Lang("RecycleEmptyTips")
    else
      self.uiBinder.lab_empty.text = Lang("RecycleSelectEmptyTips")
    end
  end
end

function Recycle_windowView:ResetRecycleUI()
  self.recycleData_:ClearTempRecycleData()
  self:RefreshLeftPanel()
  self:RefreshRightPanel()
end

function Recycle_windowView:GetConfirmTipsDesc()
  local includeQualityDict = {}
  for i, v in ipairs(self.curSelectItemList_) do
    local itemRow = Z.TableMgr.GetRow("ItemTableMgr", v.configId)
    if itemRow and itemRow.Quality >= E.ItemQuality.Yellow then
      includeQualityDict[itemRow.Quality] = true
    end
  end
  if next(includeQualityDict) then
    local qualityDesc
    for quality, v in pairs(includeQualityDict) do
      local tempStr = Lang("item_rare_" .. quality) .. Lang("Quality")
      local colorTag = "ItemQuality_" .. quality
      tempStr = Z.RichTextHelper.ApplyStyleTag(tempStr, colorTag)
      if qualityDesc == nil then
        qualityDesc = tempStr
      else
        qualityDesc = string.zconcat(qualityDesc, ",", tempStr)
      end
    end
    return Lang("RecycleConfirmQuality", {quality = qualityDesc})
  else
    return Lang("RecycleConfirm")
  end
end

function Recycle_windowView:OpenItemTips(trans, configId, itemUuid)
  if self.lastTipsUuid_ and self.lastTipsUuid_ == itemUuid then
    return
  end
  self:CloseItemTips()
  self.lastTipsUuid_ = itemUuid
  local extraParams = {
    closeCallBack = function()
      self.lastTipsUuid_ = nil
    end
  }
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(trans, configId, itemUuid, extraParams)
end

function Recycle_windowView:CloseItemTips()
  if self.tipsId_ ~= nil then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function Recycle_windowView:OnConfirmBtnClick()
  local desc = self:GetConfirmTipsDesc()
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(desc, function()
    local itemList = self.recycleData_:GetSendServerItemList(self.curRecycleRow_.SystemId, self.curSelectItemList_)
    if itemList then
      self.recycleVM_:AsyncReqRecycleItem(itemList, self.cancelSource:CreateToken())
      self:ResetRecycleUI()
    end
    Z.DialogViewDataMgr:CloseDialogView()
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.ItemRecycleTips)
end

function Recycle_windowView:OnCancelBtnClick()
  self:ResetRecycleUI()
end

function Recycle_windowView:OnSortBtnClick()
  self.curSortAscending_ = not self.curSortAscending_
  self:RefreshLeftPanel()
end

return Recycle_windowView
