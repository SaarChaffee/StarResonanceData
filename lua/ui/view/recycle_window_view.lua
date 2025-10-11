local UI = Z.UI
local super = require("ui.ui_view_base")
local Recycle_windowView = class("Recycle_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local loopTotalItem = require("ui/component/recycle/recycle_total_item")
local loopHomeItem = require("ui/component/recycle/recycle_home_item")
local loopPreviewItem = require("ui/component/recycle/recycle_preview_item")
local loopObtainItem = require("ui/component/recycle/recycle_obtain_item")
local currency_item_list = require("ui.component.currency.currency_item_list")
local keyPad = require("ui.view.cont_num_keyboard_view")

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
  self.timer_ = self.timerMgr:StartTimer(function()
    self:onStartAnimShow()
  end, Z.UICameraHelperFadeTime)
  self:initData()
  self:initComp()
  self:initLoopComp()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.keypad_ = keyPad.new(self)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, self.curRecycleRow_.CurrencyDisplay)
  self:RefreshBottom()
end

function Recycle_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.timerMgr:Clear()
  self.timer_ = nil
  self:unInitLoopComp()
  self:CloseItemTips()
  self.recycleData_:ClearTempRecycleData()
  self.currencyItemList_:UnInit()
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
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
  self:AddClick(self.uiBinder.binder_sort.btn_refresh, function()
    self:OnSortBtnClick()
  end)
  self:AddClick(self.uiBinder.node_slider.slider_temp, function(value)
    self.recycleData_:SetTempRecycleData(self.curSelectData, self.curRecycleRow_.SystemId, value)
    self.uiBinder.node_slider.lab_num.text = math.floor(value)
    self:RefreshRightPanel()
    self.loopTotalGridView_:RefreshItemByItemIndex(self.curIndex)
  end)
  self:AddClick(self.uiBinder.node_slider.btn_add, function()
    self:OnTotalItemAdd(self.curSelectData)
    local selectCount = self.recycleData_:GetTempRecycleCount(self.curSelectData, self.curRecycleRow_.SystemId)
    self.uiBinder.node_slider.slider_temp.value = selectCount
    self.uiBinder.node_slider.lab_num.text = math.floor(selectCount)
    self.loopTotalGridView_:RefreshItemByItemIndex(self.curIndex)
  end)
  self:AddClick(self.uiBinder.node_slider.btn_reduce, function()
    self:OnTotalItemReduce(self.curSelectData)
    local selectCount = self.recycleData_:GetTempRecycleCount(self.curSelectData, self.curRecycleRow_.SystemId)
    self.uiBinder.node_slider.slider_temp.value = selectCount
    self.uiBinder.node_slider.lab_num.text = math.floor(selectCount)
    self.loopTotalGridView_:RefreshItemByItemIndex(self.curIndex)
  end)
  self:AddClick(self.uiBinder.btn_one_touch, function()
    self.loopTotalGridView_:ClearAllSelect()
    local itemsCnt = table.zcount(self.curTotalItemList_)
    for i = 1, itemsCnt do
      self.loopTotalGridView_:SetSelected(i)
      local curData = self.loopTotalGridView_:GetDataByIndex(i)
      local haveCount = self:GetHaveCount(curData)
      local maxCnt = Mathf.Min(Z.Global.RecycleItemNumMax, haveCount)
      self.recycleData_:SetTempRecycleData(curData, self.curRecycleRow_.SystemId, maxCnt)
      self.loopTotalGridView_:RefreshItemByItemIndex(i)
      if i >= Z.Global.RecycleItemMax then
        self.curSelectData = nil
        self:RefreshBottom()
        self:RefreshRightPanel()
        return
      end
    end
    self.curSelectData = nil
    self:RefreshBottom()
    self:RefreshRightPanel()
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
  self.loopTotalGridView_:SetGetItemClassFunc(function(...)
    if self.curRecycleRow_.SystemId == E.FunctionID.HomeFlowerRecycle then
      return loopHomeItem
    else
      return loopTotalItem
    end
  end)
  self.loopTotalGridView_:SetGetPrefabNameFunc(function(...)
    if self.curRecycleRow_.SystemId == E.FunctionID.HomeFlowerRecycle then
      return "com_item_long_3_2"
    else
      return "com_item_long_3_1"
    end
  end)
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
end

function Recycle_windowView:unInitCamera()
  Z.CameraMgr:CameraInvoke(E.CameraState.Position, false, self.curRecycleRow_.CameraTemplateId, false)
end

function Recycle_windowView:OnTotalItemAdd(data)
  local selectCount = self.recycleData_:GetTempRecycleCount(data, self.curRecycleRow_.SystemId)
  local haveCount = self:GetHaveCount(data)
  if selectCount >= haveCount then
    return
  end
  self.recycleData_:AddTempRecycleData(data, self.curRecycleRow_.SystemId)
  self:RefreshRightPanel()
end

function Recycle_windowView:GetHaveCount(data)
  local itemInfo
  if self.curRecycleRow_.SystemId == E.FunctionID.HomeFlowerRecycle then
    itemInfo = data.ownerToStackMap[Z.ContainerMgr.CharSerialize.charId]
  else
    itemInfo = self.itemsVM_.GetItemInfobyItemId(data.itemUuid, data.configId)
  end
  local haveCount = itemInfo and itemInfo.count or 0
  return haveCount
end

function Recycle_windowView:OnTotalItemReduce(data)
  self.recycleData_:ReduceTempRecycleData(data, self.curRecycleRow_.SystemId)
  self:RefreshRightPanel()
end

function Recycle_windowView:OnTotalItemClear(data)
  self.recycleData_:ClearCurTempRecycleData(data, self.curRecycleRow_.SystemId)
  self:RefreshRightPanel()
  self.curSelectData = nil
  self:RefreshBottom()
end

function Recycle_windowView:OnTotalItemClick(index, trans, data)
  self.curIndex = index
  self.curSelectData = data
  self:RefreshBottom()
  local config, itemUuid, tipsUid
  if self.curRecycleRow_.SystemId == E.FunctionID.HomeFlowerRecycle then
    config = data.ConfigId
    tipsUid = data.InstanceId
  else
    config = data.configId
    itemUuid = data.itemUuid
    tipsUid = itemUuid
  end
  self:onClickStartAnimShow()
  self:OpenItemTips(trans, config, itemUuid, tipsUid)
end

function Recycle_windowView:RefreshBottom()
  local hasSelectedItem = self.curSelectData ~= nil
  self.uiBinder.binder_sort.Ref.UIComp:SetVisible(not hasSelectedItem)
  self.uiBinder.node_slider.Ref.UIComp:SetVisible(hasSelectedItem)
  if hasSelectedItem then
    self:InitSlider()
  end
end

function Recycle_windowView:InitSlider()
  self.uiBinder.node_slider.slider_temp.minValue = 1
  self.uiBinder.node_slider.lab_num_min.text = 1
  local haveCount = self:GetHaveCount(self.curSelectData)
  self.uiBinder.node_slider.slider_temp.value = 1
  self.max_ = Mathf.Min(Z.Global.RecycleItemNumMax, haveCount)
  self.uiBinder.node_slider.slider_temp.maxValue = self.max_
  self.uiBinder.node_slider.lab_num_max.text = self.max_
  self.recycleData_:SetTempRecycleData(self.curSelectData, self.curRecycleRow_.SystemId, 1)
  self:RefreshRightPanel()
  self.uiBinder.node_slider.lab_num.text = 1
  self.uiBinder.node_slider.btn_num:RemoveAllListeners()
  self:AddClick(self.uiBinder.node_slider.btn_num, function()
    self.keypad_:Active({
      max = self.max_
    }, self.uiBinder.node_slider.group_keypadroot)
  end)
  self.loopTotalGridView_:RefreshItemByItemIndex(self.curIndex)
end

function Recycle_windowView:InputNum(num)
  self.curNum_ = num
  if num < 1 then
    self.curNum_ = 1
  end
  if num < 1 then
    self.curNum_ = 1
  end
  if num > self.max_ then
    self.curNum_ = self.max_
  end
  self.recycleData_:SetTempRecycleData(self.curSelectData, self.curRecycleRow_.SystemId, self.curNum_)
  self.uiBinder.node_slider.lab_num.text = math.floor(self.curNum_)
  self.uiBinder.node_slider.slider_temp.value = self.curNum_
  self:RefreshRightPanel()
  self.loopTotalGridView_:RefreshItemByItemIndex(self.curIndex)
end

function Recycle_windowView:RefreshLeftPanel()
  local sortData = {
    recycleSortType = self.curSortType_,
    isAscending = self.curSortAscending_,
    functionId = self.curRecycleRow_.SystemId
  }
  self.curTotalItemList_ = self.recycleData_:GetTotalCanRecycleItems(self.curRecycleRow_.SystemId, sortData)
  self.loopTotalGridView_:RefreshListView(self.curTotalItemList_, true)
  self.loopTotalGridView_:ClearAllSelect()
  local isShowPanel = #self.curTotalItemList_ > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left, isShowPanel)
end

function Recycle_windowView:RefreshRightPanel()
  self.curSelectItemList_ = self.recycleData_:GetTempRecycleList(self.curRecycleRow_.SystemId)
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

function Recycle_windowView:OpenItemTips(trans, configId, itemUuid, tipsUid)
  if self.lastTipsUuid_ and self.lastTipsUuid_ == tipsUid then
    return
  end
  self:CloseItemTips()
  self.lastTipsUuid_ = tipsUid
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
      local result = self.recycleVM_:AsyncReqRecycleItem(itemList, self.cancelSource:CreateToken())
      if result then
        self:ResetRecycleUI()
      end
    end
  end, nil, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.ItemRecycleTips)
end

function Recycle_windowView:OnCancelBtnClick()
  self:ResetRecycleUI()
end

function Recycle_windowView:OnSortBtnClick()
  self.curSortAscending_ = not self.curSortAscending_
  self:RefreshLeftPanel()
end

function Recycle_windowView:GetCurFunctionId()
  return self.curRecycleRow_.SystemId
end

function Recycle_windowView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

function Recycle_windowView:onClickStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
end

return Recycle_windowView
