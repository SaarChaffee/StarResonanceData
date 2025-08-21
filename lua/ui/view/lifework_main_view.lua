local UI = Z.UI
local super = require("ui.ui_view_base")
local Lifework_mainView = class("Lifework_mainView", super)
local loopListView = require("ui.component.loop_list_view")
local leftTogItem = require("ui.component.life_work.life_work_left_tog_item")
local lifeWorkAwardLoopItem = require("ui.component.life_work.life_work_main_reward_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Lifework_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "lifework_main")
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  self.lifeWorkVM = Z.VMMgr.GetVM("life_work")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function Lifework_mainView:OnActive()
  self:Init()
  self:InitBinder()
  self:InitBtnClick()
  self:RefreshLeft()
  self:bindEvents()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    Z.SystemItem.VigourItemId
  })
  Z.EventMgr:Add(Z.ConstValue.LifeWork.LifeWorkRewardChange, self.lifeWorkRewardChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onCountChange, self)
end

function Lifework_mainView:onCountChange()
  self:OnTogSelect(self.data_)
end

function Lifework_mainView:lifeWorkRewardChange()
  self:OnTogSelect(self.data_)
end

function Lifework_mainView:bindEvents()
end

function Lifework_mainView:InitBtnClick()
  self:AddClick(self.maxBtn_, function()
    self:getWorkMaxCount()
    self.slider_.maxValue = self.sliderMaxValue_
    self.slider_.value = self.sliderMaxValue_
  end)
  self:AddClick(self.addBtn_, function()
    self:getWorkMaxCount()
    self.slider_.maxValue = self.sliderMaxValue_
    if self.selectedNum_ < self.sliderMaxValue_ then
      self.slider_.value = self.selectedNum_ + 1
    end
  end)
  self:AddClick(self.minusBtn_, function()
    self:getWorkMaxCount()
    self.slider_.maxValue = self.sliderMaxValue_
    if self.selectedNum_ > 0 then
      self.slider_.value = self.selectedNum_ - 1
    end
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(2104)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.lifeWorkVM.CloseLifeWorkView()
  end)
  self:AddClick(self.uiBinder.btn_learn, function()
    self.lifeProfessionVM.OpenLifeProfessionInfoView(self.curProID)
  end)
  self:AddClick(self.uiBinder.btn_work_not_enough, function()
    Z.TipsVM.ShowTips(1001904)
  end)
  self:AddClick(self.uiBinder.btn_record, function()
    self.lifeWorkVM.OpenWorkRecordView()
  end)
  self:AddClick(self.uiBinder.btn_reward, function()
    self.lifeWorkVM.OpenWorkRewardView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_work, function()
    self.lifeWorkVM.AsyncRequsetWork(self.curProID, self.selectedNum_)
  end)
  self:AddAsyncClick(self.uiBinder.btn_fast, function()
    local workingCount = self.lifeWorkVM.GetCurProWorkingCount(self.curProID)
    local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
    if lifeWorkTableRow == nil then
      return
    end
    local cost = lifeWorkTableRow.EarlyEndCost
    local itemList = {}
    for k, v in pairs(cost) do
      local itemData = {}
      itemData.ItemId = v[1]
      itemData.ItemNum = v[2] * workingCount
      table.insert(itemList, itemData)
    end
    local dialogViewData = {
      dlgType = E.DlgType.YesNo,
      labTitle = Lang("DialogDefaultTitle"),
      labDesc = Lang("LifeProfessionWorkConfirmContent"),
      onConfirm = function()
        if self.lifeWorkVM.IsCurWorkingEnd(self.curProID) then
          Z.TipsVM.ShowTips(1001906)
        else
          Z.CoroUtil.create_coro_xpcall(function()
            self.lifeWorkVM.AsyncRequsetWorkFast()
          end)()
        end
      end,
      itemList = itemList
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_not, function()
    local dialogViewData = {
      dlgType = E.DlgType.YesNo,
      labTitle = Lang("DialogDefaultTitle"),
      labDesc = Lang("LifeProfessionCancelConfirmContent"),
      onConfirm = function()
        if self.lifeWorkVM.IsCurWorkingEnd(self.curProID) then
          Z.TipsVM.ShowTips(1001905)
        else
          self.lifeWorkVM.AsyncRequsetStopWork(self.curProID, self.selectedNum_)
        end
      end
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
  end)
  self:AddClick(self.uiBinder.btn_spe_1, function()
    local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
    if lifeWorkTableRow == nil then
      return
    end
    if #lifeWorkTableRow.Specializations < 1 then
      return
    end
    local specID = lifeWorkTableRow.Specializations[1]
    self:OpenSpecTips(specID, self.uiBinder.btn_spe_1.transform)
  end)
  self:AddClick(self.uiBinder.btn_spe_2, function()
    local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
    if lifeWorkTableRow == nil then
      return
    end
    if #lifeWorkTableRow.Specializations < 2 then
      return
    end
    local specID = lifeWorkTableRow.Specializations[2]
    self:OpenSpecTips(specID, self.uiBinder.btn_spe_2.transform)
  end)
end

function Lifework_mainView:Init()
  local data = {}
  if Z.IsPCUI then
    self.leftToggleListView_ = loopListView.new(self, self.uiBinder.left_tog_scrollview, leftTogItem, "life_work_left_tog_tpl_pc")
    self.rewardLoopListView_ = loopListView.new(self, self.uiBinder.loop_item, lifeWorkAwardLoopItem, "com_item_square_1_8_pc")
  else
    self.leftToggleListView_ = loopListView.new(self, self.uiBinder.left_tog_scrollview, leftTogItem, "life_work_left_tog_tpl")
    self.rewardLoopListView_ = loopListView.new(self, self.uiBinder.loop_item, lifeWorkAwardLoopItem, "com_item_square_1_8")
  end
  self.leftToggleListView_:Init(data)
  self.rewardLoopListView_:Init(data)
end

function Lifework_mainView:InitBinder()
  self.numbModuleBinder_ = self.uiBinder.cont_num_module
  self.selectedNumLab_ = self.numbModuleBinder_.lab_num
  self.maxBtn_ = self.numbModuleBinder_.btn_max
  self.minusBtn_ = self.numbModuleBinder_.btn_reduce
  self.addBtn_ = self.numbModuleBinder_.btn_add
  self.slider_ = self.numbModuleBinder_.slider_temp
end

function Lifework_mainView:RefreshLeft()
  self.proDataList = self.lifeProfessionVM.GetAllSortedProfessions()
  self.leftToggleListView_:RefreshListView(self.proDataList)
  if self.viewData then
    self.curProID = self.viewData.proID
  else
    self.curProID = self.proDataList[1].ProId
  end
  local index = 1
  for i = 1, #self.proDataList do
    if self.proDataList[i].ProId == self.curProID then
      index = i
      break
    end
  end
  self.leftToggleListView_:SelectIndex(index - 1)
end

function Lifework_mainView:OnDeActive()
  self.leftToggleListView_:UnInit()
  self.leftToggleListView_ = nil
  Z.EventMgr:RemoveObjAll(self)
  self.rewardLoopListView_:UnInit()
  self.rewardLoopListView_ = nil
  Z.CommonTipsVM.CloseTipsTitleContent()
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
end

function Lifework_mainView:OnRefresh()
end

function Lifework_mainView:OpenSpecTips(specID, trans)
  local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(specID)
  lifeFormulaTableRow = self.lifeProfessionVM.GetCurSpecialization(lifeFormulaTableRow.ProId, specID, lifeFormulaTableRow.GroupId)
  Z.CommonTipsVM.ShowTipsTitleContent(trans, lifeFormulaTableRow.Name, Lang("LifeWorkSpecDesc", {
    level = lifeFormulaTableRow.Level,
    desc = lifeFormulaTableRow.Des
  }))
end

function Lifework_mainView:OnTogSelect(data)
  self.data_ = data
  self.curProID = data.ProId
  local isWorkUnlocked = self.lifeWorkVM.IsWorkUnlocked(self.curProID)
  self.lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
  if self.lifeWorkTableRow == nil then
    return
  end
  local curWorkingPro = self.lifeWorkVM.GetCurWorkingPro()
  local isOtherProWorking = curWorkingPro ~= 0 and curWorkingPro ~= self.curProID
  local isCurWorking = curWorkingPro == self.curProID
  local isCurWorkingEnd = self.lifeWorkVM.IsCurWorkingEnd(self.curProID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_locked, not isWorkUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_working, isCurWorking and not isCurWorkingEnd)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_can_work, isWorkUnlocked and not isOtherProWorking and not isCurWorking and not isCurWorkingEnd)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_other_is_working, isOtherProWorking and isWorkUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_work_end, isCurWorkingEnd)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_count, isWorkUnlocked and (not isCurWorking or isCurWorkingEnd))
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_ing, isCurWorking and not isCurWorkingEnd)
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
  if lifeWorkTableRow == nil then
    return
  end
  self.uiBinder.lab_work_name.text = lifeWorkTableRow.Title
  self.uiBinder.lab_work_desc.text = lifeWorkTableRow.Desc
  self.uiBinder.rimg_bg:SetImage(lifeWorkTableRow.Background)
  local cost = self.lifeWorkVM.GetLifeWorkCost(lifeWorkTableRow)
  local curHave = self.itemVm_.GetItemTotalCount(Z.SystemItem.VigourItemId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_work_not_enough, cost > curHave)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_work, cost <= curHave)
  self:refreshCost()
  self:refreshAward()
  self:refreshCount()
  self:refreshWorkingState()
  self:refreshSpecializations(lifeWorkTableRow.Specializations)
end

function Lifework_mainView:refreshSpecializations(specializations)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_spe_1, 1 <= #specializations)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_spe_2, 2 <= #specializations)
  if 1 <= #specializations then
    local specID1 = specializations[1]
    local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(specID1)
    self.uiBinder.img_spe_1:SetImage(lifeFormulaTableRow.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.spe_active_1, self.lifeProfessionVM.IsSpecializationUnlocked(self.curProID, specID1))
  end
  if 2 <= #specializations then
    local specID2 = specializations[2]
    local lifeFormulaTableRow = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetRow(specID2)
    self.uiBinder.img_spe_2:SetImage(lifeFormulaTableRow.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.spe_active_2, self.lifeProfessionVM.IsSpecializationUnlocked(self.curProID, specID2))
  end
end

function Lifework_mainView:refreshAward()
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
  if lifeWorkTableRow == nil then
    return
  end
  if self.selectedNum_ == nil then
    self.selectedNum_ = 1
  end
  local awardTable = {}
  table.insert(awardTable, lifeWorkTableRow.Award)
  for k, v in pairs(lifeWorkTableRow.ExtraAward) do
    if self.lifeProfessionVM.IsSpecializationUnlocked(self.curProID, v[2]) then
      table.insert(awardTable, v[1])
    end
  end
  local rewards = self.awardPreviewVM_.GetAllAwardPreListByIds(awardTable)
  for k, v in pairs(rewards) do
    v.awardNum = math.ceil(v.awardNum * self.selectedNum_)
  end
  self.rewardLoopListView_:RefreshListView(rewards, true)
  self.rewardLoopListView_:ClearAllSelect()
end

function Lifework_mainView:refreshCount()
  self:initNumSlider()
end

function Lifework_mainView:initNumSlider()
  self:getWorkMaxCount()
  self.slider_.maxValue = self.sliderMaxValue_
  self.slider_.minValue = 1
  self.selectedNumLab_.text = 1
  self.slider_.value = 1
  self.selectedNum_ = 1
  self:AddClick(self.slider_, function(value)
    self.selectedNumLab_.text = math.floor(value)
    self.selectedNum_ = tonumber(value)
    self:refreshCost()
    self:refreshAward()
  end)
end

function Lifework_mainView:getWorkMaxCount()
  local cost = self.lifeWorkVM.GetLifeWorkCost(self.lifeWorkTableRow)
  local curHave = self.itemVm_.GetItemTotalCount(Z.SystemItem.VigourItemId)
  local canMakeMax = math.floor(curHave / cost)
  if canMakeMax >= Z.Global.LifeWorkMaxLimitNum then
    canMakeMax = Z.Global.LifeWorkMaxLimitNum
  end
  self.sliderMaxValue_ = canMakeMax < 1 and 1 or canMakeMax
end

function Lifework_mainView:refreshCost()
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curProID)
  if lifeWorkTableRow == nil then
    return
  end
  local cost = self.lifeWorkVM.GetLifeWorkCost(lifeWorkTableRow)
  if self.selectedNum_ == nil then
    self.selectedNum_ = 1
  end
  self.uiBinder.rimg_icon_cost:SetImage(self.itemVm_.GetItemIcon(Z.SystemItem.VigourItemId))
  self.uiBinder.lab_cost.text = math.ceil(self.selectedNum_ * cost)
  local workSingleTime = self.lifeWorkVM.GetLifeWorkTime(lifeWorkTableRow)
  self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(math.ceil(self.selectedNum_ * workSingleTime))
end

function Lifework_mainView:refreshWorkingState()
  local curWorkingPro = self.lifeWorkVM.GetCurWorkingPro()
  local isCurWorking = curWorkingPro == self.curProID
  if not isCurWorking then
    return
  end
  local workStartTime, workEndTime = self.lifeWorkVM.GetWorkStartEndTime(self.curProID)
  self.uiBinder.node_countdown:StartCountDownTime(workStartTime, workEndTime, "", function(secs)
    return Z.TimeFormatTools.FormatToDHMS(secs)
  end)
end

return Lifework_mainView
