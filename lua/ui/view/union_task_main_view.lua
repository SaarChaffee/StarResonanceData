local UI = Z.UI
local super = require("ui.ui_view_base")
local numMod = require("ui.view.union_task_num_module_tpl_view")
local loop_list_view = require("ui/component/loop_list_view")
local loop_title_item = require("ui.component.uniontask.union_task_loop_title_item")
local loop_resolve_item = require("ui.component.uniontask.union_task_loop_list_item")
local loop_award_item = require("ui.component.uniontask.union_task_loop_award_item")
local tableId_ = 280
local imgPathList = {
  "ui/atlas/union/union_taks_img_frame_off",
  "ui/atlas/union/union_taks_img_frame_on"
}
local Union_task_mainView = class("Union_task_mainView", super)

function Union_task_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_task_main")
  self.numMod_ = numMod.new(self)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.unionTaskVM_ = Z.VMMgr.GetVM("union_task")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
end

function Union_task_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBaseData()
  self:initBinders()
  self:initPanelInfo()
  self:checkSendSuccess()
  self:onSubmitSuccess()
end

function Union_task_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.scrollItemView_:UnInit()
  self.scrollItemView_ = nil
  self.baseAwardScrollView_:UnInit()
  self.baseAwardScrollView_ = nil
  self.PriceOffsetList = nil
  self.PriceTitleStrList = nil
  self.curSelectData_ = nil
  self.curTotalSelectIndex_ = nil
  self.curResolveDataList_ = nil
  self:CloseItemTips()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
  end
  self.timer_ = nil
  if self.numMod_ then
    self.numMod_:DeActive()
  end
end

function Union_task_mainView:OnRefresh()
end

function Union_task_mainView:initBinders()
  self.submit_btn_ = self.uiBinder.btn_submit
  self.go_btn_ = self.uiBinder.btn_go
  self.close_btn_ = self.uiBinder.btn_close
  self.ask_btn_ = self.uiBinder.btn_ask
  self.price_all_label_ = self.uiBinder.lab_digit
  self.price_single_lab_ = self.uiBinder.lab_price
  self.numModRootTrans_ = self.uiBinder.node_num
  self.scrollItemView_ = loop_list_view.new(self, self.uiBinder.loop_item)
  self.scrollItemView_:SetGetPrefabNameFunc(function(data)
    if data.Type == 1 then
      return "union_task_title_tpl"
    else
      return "union_task_list_tpl"
    end
  end)
  self.scrollItemView_:SetGetItemClassFunc(function(data)
    if data.Type == 1 then
      return loop_title_item
    else
      return loop_resolve_item
    end
  end)
  self:AddAsyncClick(self.go_btn_, function()
    local totalScore = self.unionTaskVM_:GetFreightNum()
    if totalScore < self.minLimitValue_ then
      Z.TipsVM.ShowTips(6603)
      return
    end
    self.unionTaskVM_:AsyncSendGo(self.cancelSource:CreateToken())
    self:checkSendSuccess()
    self:refreshTimeInfo()
  end)
  self:AddAsyncClick(self.submit_btn_, function()
    local ret = self.unionTaskVM_:AsyncSubmitItem(self.curSelectData_.resolveData.Id, self.curNum_, self.cancelSource:CreateToken())
    if ret and ret == 0 then
      Z.TipsVM.ShowTipsLang(1000580, {
        val = self.curSubmitNum_
      })
    end
    self:onSubmitSuccess()
    self:refreshLeftPanel()
  end)
  self:AddClick(self.close_btn_, function()
    self.unionTaskVM_:CloseTaskView()
  end)
  self:AddClick(self.ask_btn_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(300010)
  end)
  self:AddClick(self.uiBinder.btn_item, function()
    if self.curSelectData_ then
      local data = self.curSelectData_.itemTableData
      self:OpenItemTips(nil, data.Id)
    end
  end)
  if self.numMod_ then
    self.numMod_:Active({}, self.numModRootTrans_)
  end
  
  function self.UpdateFunc(num)
    if self.curSelectData_ then
      local priceOffsetNum = self:GetPriceOffsetNum(self.curSelectData_.offsetType)
      local price = num * priceOffsetNum * self.curSelectData_.resolveData.SingleValue
      self.curSubmitNum_ = price
      self.uiBinder.lab_add.text = "+" .. string.format("%.0f", price)
      self.curNum_ = num
    end
  end
  
  local dataList = {}
  self.scrollItemView_:Init(dataList)
  self.baseAwardScrollView_ = loop_list_view.new(self, self.uiBinder.loop_item_basics, loop_award_item, "com_item_square_8")
  self.baseAwardScrollView_:Init(dataList)
end

function Union_task_mainView:initBaseData()
  self.itemId_ = 0
  self.maxCount_ = 0
  self.minCount_ = 1
  self.price_single_ = 1
  self.PriceOffsetList = {
    [1] = 1 + Z.Global.UnionResolveUpProbability / 100,
    [2] = 1 + Z.Global.UnionResolveKeepProbability / 100,
    [3] = 1 - Z.Global.UnionResolveDownProbability / 100
  }
  self.PriceTitleStrList = {
    [1] = Lang("UnionResolveUp"),
    [2] = Lang("UnionResolveKeep"),
    [3] = Lang("UnionResolveDown")
  }
  self.NextPriceTitleStrList = {
    [1] = Lang("UnionResolveUpNext"),
    [2] = Lang("UnionResolveKeepNext"),
    [3] = Lang("UnionResolveDownNext")
  }
  self.minLimitValue_ = Z.Global.UnionResolveMinValue
  self.singleCount_ = 1000
  self.extraAwardId_ = Z.Global.UnionResolveBaseAwardId
end

function Union_task_mainView:ClickLeftItem(data)
end

function Union_task_mainView:checkSendSuccess()
  local hasSend = self.unionTaskVM_:GetHasSend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_submit, hasSend == false)
  self.uiBinder.Ref:SetVisible(self.go_btn_, hasSend == false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reached, hasSend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, hasSend)
  local alpha = hasSend == true and 0.5 or 1
  self.uiBinder.group_additional.alpha = alpha
  if hasSend and self.timer_ == nil then
    self.timer_ = self.timerMgr:StartTimer(function()
      local nowTime = Z.TimeTools.Now() / 1000
      local getAwardTime = self.unionTaskVM_:GetCanGetRewardTime()
      local leftTime = math.ceil(getAwardTime - nowTime)
      if 0 <= leftTime then
        self.uiBinder.lab_time.text = Z.TimeTools.FormatToDHMSStr(leftTime)
      end
    end, 1, -1)
  end
  self.curResolveDataList_ = self.unionTaskVM_:GetResolveData()
  self.scrollItemView_:RefreshListView(self.curResolveDataList_)
end

function Union_task_mainView:initPanelInfo()
  self.uiBinder.lab_digit.text = self.minLimitValue_
  local timeTable = Z.TableMgr.GetTable("TimerTableMgr")
  local timeCfg = timeTable.GetRow(tableId_)
  if timeCfg and #timeCfg.offset > 0 then
    local startTime = timeCfg.offset[1]
    local timeStr = Z.TimeTools.S2HMSFormat(startTime)
    self.uiBinder.lab_go_time.text = Lang("UnionResloveAutoSend") .. timeStr
  end
  local dataList = self:GetAwardData(Z.Global.UnionResolveBaseAwardId, 1)
  self.baseAwardScrollView_:RefreshListView(dataList)
  self.uiBinder.lab_limit_tip.text = Lang("UnionResloveMinTip", {
    val = self.minLimitValue_
  })
  self:refreshLeftPanel()
  self:initBaseReward()
end

function Union_task_mainView:refreshLeftPanel()
  self.curResolveDataList_ = self.unionTaskVM_:GetResolveData()
  self.scrollItemView_:RefreshListView(self.curResolveDataList_)
  if self.curSelectData_ and self.curTotalSelectIndex_ then
    self:OnClickItem(self.curSelectData_, self.curTotalSelectIndex_)
  else
    for index, value in ipairs(self.curResolveDataList_) do
      if value.Data and #value.Data > 0 then
        self:OnClickItem(value.Data[1], index)
        break
      end
    end
  end
end

function Union_task_mainView:OnClickItem(data, index)
  local hasSend = self.unionTaskVM_:GetHasSend()
  if hasSend then
    return
  end
  self.curSelectData_ = data
  local itemData = data.itemTableData
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(itemData.Id))
  self.uiBinder.lab_name.text = itemData.Name
  local quaity = itemData.Quality
  self.uiBinder.rimg_quality:SetImage(Z.ConstValue.UnionItemQualityPath .. quaity)
  local count = self.itemsVm_.GetItemTotalCount(itemData.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_num, 0 < count)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_submit, 0 < count)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_no, count <= 0)
  local offsetNum = self.PriceOffsetList[data.offsetType]
  self.uiBinder.lab_single_price.text = data.resolveData.SingleValue .. "X " .. offsetNum
  self.uiBinder.lab_item_num.text = count
  self.itemId_ = data.resolveData.Id
  self.maxCount_ = count
  self.minCount_ = math.min(1, self.maxCount_)
  self.numMod_:SetModuleParma(self.minCount_, self.maxCount_, self.UpdateFunc)
  self.numMod_:InitCurNum()
  if self.curTotalSelectIndex_ and self.curTotalSelectIndex_ ~= index then
    self.scrollItemView_:RefreshItemByItemIndex(self.curTotalSelectIndex_)
  end
  self.curTotalSelectIndex_ = index
  self.scrollItemView_:RefreshItemByItemIndex(self.curTotalSelectIndex_)
end

function Union_task_mainView:CheckItemIsSelect()
  local result = 0
  if self.curSelectData_ then
    result = self.curSelectData_.resolveData.Id
  end
  return result
end

function Union_task_mainView:GetPriceOffsetNum(type)
  return self.PriceOffsetList[type] or 1
end

function Union_task_mainView:onSubmitSuccess()
  local totalScore = self.unionTaskVM_:GetFreightNum()
  local isEnough = totalScore >= self.minLimitValue_
  local strType = isEnough and E.TextStyleTag.UnionResloveGreen or E.TextStyleTag.Orange
  local limitStr = Z.RichTextHelper.ApplyStyleTag(tostring(totalScore), strType)
  local rightString = Z.RichTextHelper.ApplySizeTag("/" .. limitStr, 36)
  self.uiBinder.lab_price.text = self.minLimitValue_ .. rightString
  for key, value in pairs(self.showAwardItemList_) do
    local scoreEnough = key <= totalScore
    value.Ref:SetVisible(value.img_receive, scoreEnough)
    local pathIndex = scoreEnough and 2 or 1
    value.img_bg:SetImage(imgPathList[pathIndex])
  end
  self:calProgress()
  self.go_btn_.IsDisabled = isEnough == false
  self:refreshTimeInfo()
end

function Union_task_mainView:calProgress()
  local totalScore = self.unionTaskVM_:GetFreightNum()
  local perRatio = 1 / #Z.Global.UnionResolveExtraAwardId
  local curRatio = 0
  local lastTargetValue = 0
  for i, v in ipairs(Z.Global.UnionResolveExtraAwardId) do
    local targetValue = v[1]
    if totalScore >= targetValue then
      curRatio = curRatio + perRatio
    else
      local tempRatio = (totalScore - lastTargetValue) / (targetValue - lastTargetValue)
      curRatio = curRatio + tempRatio * perRatio
      break
    end
    lastTargetValue = targetValue
  end
  self.uiBinder.img_progress.fillAmount = curRatio
end

function Union_task_mainView:refreshTimeInfo()
  local hasSend = self.unionTaskVM_:GetHasSend()
  local totalScore = self.unionTaskVM_:GetFreightNum()
  local isEnough = totalScore >= self.minLimitValue_
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, isEnough and not hasSend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_limit_tip, isEnough == false)
end

function Union_task_mainView:GetTitleStr(type)
  local hadSend = self.unionTaskVM_:GetHasSend()
  local strList = hadSend and self.NextPriceTitleStrList or self.PriceTitleStrList
  return strList[type] or ""
end

function Union_task_mainView:GetAwardData(awardId, num)
  local result = {}
  local list = self.awardPreviewVm_.GetAllAwardPreListByIds(awardId)
  for _, value in ipairs(list) do
    local labType, lab = self:GetPreviewShowNum(value, num)
    local d = {
      PreviewData = value,
      labType = labType,
      lab = lab
    }
    result[#result + 1] = d
  end
  return result
end

function Union_task_mainView:GetPreviewShowNum(awardData, num)
  local labType, lab
  if awardData.awardNum == awardData.awardNumExtend then
    labType = E.ItemLabType.Num
    local trueNum = awardData.awardNum * num
    lab = trueNum
  else
    labType = E.ItemLabType.Str
    local num1 = awardData.awardNum * num
    local num2 = awardData.awardNumExtend * num
    if num1 == num2 then
      labType = E.ItemLabType.Num
      lab = num1
    else
      lab = num1 .. "~" .. num2
    end
  end
  return labType, lab
end

function Union_task_mainView:initBaseReward()
  self.maxResloveValue_ = 0
  self.showAwardItemList_ = {}
  local rewardIDs = Z.Global.UnionResolveExtraAwardId
  for j = 1, 4 do
    local index = j
    local value = rewardIDs[j]
    local s = string.format("union_task_itme_%02d", index)
    local awardItem = self.uiBinder[s]
    if value then
      local reloveNum = value[1]
      self.showAwardItemList_[reloveNum] = awardItem
      self.maxResloveValue_ = math.max(self.maxResloveValue_, reloveNum)
      awardItem.lab_score.text = reloveNum
      self:setRewardItem(awardItem, value[2], 1)
    end
    self:SetUIVisible(awardItem.Ref, value ~= nil)
  end
end

function Union_task_mainView:setRewardItem(awardItem, awardId, num)
  local list = self.awardPreviewVm_.GetAllAwardPreListByIds(awardId)
  for i = 1, 2 do
    local d = list[i]
    local s1 = string.format("node_itme_%02d", i)
    local node = awardItem[s1]
    awardItem.Ref:SetVisible(node, d ~= nil)
    if d then
      local labType, lab = self:GetPreviewShowNum(d, num)
      s1 = string.format("lab_number%02d", i)
      local lab_number = awardItem[s1]
      lab_number.text = "x" .. lab
      s1 = string.format("rimg_icon%02d", i)
      local icon = awardItem[s1]
      local configId = d.awardId
      self:AddClick(node, function()
        self:OpenItemTips(awardItem.Trans, configId)
      end)
      local itemsVM = Z.VMMgr.GetVM("items")
      icon:SetImage(itemsVM.GetItemIcon(configId))
    end
  end
end

function Union_task_mainView:OpenItemTips(trans, configId)
  trans = trans or self.uiBinder.btn_item.transform
  self:CloseItemTips()
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(trans, configId)
end

function Union_task_mainView:CloseItemTips()
  if self.tipsId_ ~= nil then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

return Union_task_mainView
