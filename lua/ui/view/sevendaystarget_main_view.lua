local UI = Z.UI
local super = require("ui.ui_view_base")
local Sevendaystarget_mainView = class("Sevendaystarget_mainView", super)
local itemBinder = require("common.item_binder")
local loopListView = require("ui.component.loop_list_view")
local sevendays_target_manual_loop_item = require("ui.component.sevendaystarget.sevendays_target_manual_loop_item")
local sevendaysRed_ = require("rednode.sevendays_target_red")
local funcPreview = require("ui.view.sevendaystarget_preview_sub_view")

function Sevendaystarget_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "sevendaystarget_main")
  self.vm = Z.VMMgr.GetVM("season_quest_sub")
  self.awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
  
  self.colorWhite_ = Color.New(1, 1, 1, 1)
  self.colorBlack_ = Color.New(0, 0, 0, 1)
end

function Sevendaystarget_mainView:OnActive()
  Z.AudioMgr:Play("UI_Event_GeneralPopup")
  self.funcPreview_ = funcPreview.new(self)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff_loop)
  self.endTime_ = self.vm.GetDayEndTime()
  self.timerMgr:StartTimer(function()
    self:refreshByDay()
  end, self.endTime_, 1)
  self.tasks_ = self.vm.GetTaskList()
  
  function self.onDataChanged_()
    self.tasks_ = self.vm.GetTaskList()
    self:refreshUI()
    sevendaysRed_.RefreshOrInitSevenDaysTargetRed(self.tasks_)
  end
  
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:RegWatcher(self.onDataChanged_)
  self.curSelectDay_ = 0
  self.titlePageList_ = {
    self.uiBinder.node_page.sevendaystarget_day_01_tpl,
    self.uiBinder.node_page.sevendaystarget_day_02_tpl,
    self.uiBinder.node_page.sevendaystarget_day_03_tpl,
    self.uiBinder.node_page.sevendaystarget_day_04_tpl,
    self.uiBinder.node_page.sevendaystarget_day_05_tpl,
    self.uiBinder.node_page.sevendaystarget_day_06_tpl,
    self.uiBinder.node_page.sevendaystarget_day_07_tpl
  }
  self.titlePageItemList_ = {}
  for day_ = 1, #self.titlePageList_ do
    local itemBinder_ = itemBinder.new(self)
    table.insert(self.titlePageItemList_, itemBinder_)
  end
  self.manualAwardItemBinderList = {}
  self.manualAwardItemBinderUIList = {}
  self.manualTabDict_ = {}
  self.initManualTab_ = false
  self:bindClickEvent()
  self:initLoopListView()
  self.uiBinder.rimg_lab:SetImage("ui/textures/sevendaystarget/sevendaystarget_01")
end

function Sevendaystarget_mainView:resetPageItemBinder()
  for _, v in ipairs(self.titlePageItemList_) do
    v:UnInit()
  end
end

function Sevendaystarget_mainView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.node_handbook.loop_item, sevendays_target_manual_loop_item, "sevendaystarget_list_figure_tpl")
  self.selectManualCfg = nil
  self.loopListView_:Init({})
  self.uiBinder.node_handbook.loop_item_scroll.onValueChangedEvent:AddListener(function()
    local isTop = self.uiBinder.node_handbook.loop_item_scroll.normalizedPosition.y <= 0.05
    local isBottom = self.uiBinder.node_handbook.loop_item_scroll.normalizedPosition.y >= 0.95
    self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.img_arrow_up, not isBottom)
    self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.img_arrow_down, not isTop)
  end)
end

function Sevendaystarget_mainView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  self.uiBinder.node_handbook.loop_item_scroll.onValueChangedEvent:RemoveAllListeners()
end

function Sevendaystarget_mainView:bindClickEvent()
  self.uiBinder.tab_page_tog:AddListener(function()
    if self.uiBinder.tab_page_tog.isOn then
      self.showType_ = E.SevenDayFuncType.TitlePage
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
      self:refreshUI()
    end
  end)
  self.uiBinder.tab_handbook_tog:AddListener(function()
    if self.uiBinder.tab_handbook_tog.isOn then
      self.showType_ = E.SevenDayFuncType.Manual
      self:onStarthandbookClickAnimShow()
      self:refreshUI()
    end
  end)
  self.uiBinder.tab_funcpreview:AddListener(function()
    if self.uiBinder.tab_funcpreview.isOn then
      self.showType_ = E.SevenDayFuncType.FuncPreview
      self:refreshUI()
    end
  end)
  self:AddClick(self.uiBinder.btn_close_new, function()
    self.showType_ = E.SevenDayFuncType.TitlePage
    self.vm.CloseSevenDayWindow()
  end)
  self:AddClick(self.uiBinder.btn_helpsys, function()
    Z.VMMgr.GetVM("helpsys").OpenMulHelpSysView(100)
  end)
end

function Sevendaystarget_mainView:OnDeActive()
  Z.AudioMgr:Play("UI_Menu_QuickInstruction_Close")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.titlePageList_ = nil
  self:resetPageItemBinder()
  for _, v in ipairs(self.manualAwardItemBinderList) do
    v:UnInit()
  end
  for _, v in ipairs(self.manualAwardItemBinderUIList) do
    self:RemoveUiUnit(v)
  end
  self.titlePageItemList_ = nil
  self.manualAwardItemBinderList = nil
  self.manualAwardItemBinderUIList = nil
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:UnregWatcher(self.onDataChanged_)
  self:unInitLoopListView()
  self.funcPreview_:DeActive()
end

function Sevendaystarget_mainView:OnRefresh()
  self.curSelectDay_ = math.min(self.vm.GetCurDay(), #self.tasks_)
  if self.viewData and self.viewData.selectDay_ then
    self.curSelectDay_ = self.viewData.selectDay_
    self.viewData.selectDay_ = nil
  end
  local defaultType = E.SevenDayFuncType.TitlePage
  if self.viewData then
    if self.viewData.showType then
      defaultType = self.viewData.showType
      self.viewData.showType = nil
    end
    if self.viewData.previewFuncId then
      defaultType = E.SevenDayFuncType.FuncPreview
      self.previewFuncId_ = self.viewData.previewFuncId
      self.viewData.previewFuncId = nil
    end
  end
  local isSevenDayShow = self.vm.CheckHasSevenDayShow()
  local pageFuncOpen = self.switchVm_.CheckFuncSwitch(E.FunctionID.SevendayTargetTitlePage) and isSevenDayShow
  local manualFuncOpen = self.switchVm_.CheckFuncSwitch(E.FunctionID.SevendayTargetManual) and isSevenDayShow
  local funcPreviewFuncOpen = self.switchVm_.CheckFuncSwitch(E.FunctionID.FunctionPreview)
  local conditionDict = {
    [E.SevenDayFuncType.TitlePage] = pageFuncOpen,
    [E.SevenDayFuncType.Manual] = manualFuncOpen,
    [E.SevenDayFuncType.FuncPreview] = funcPreviewFuncOpen
  }
  if conditionDict[defaultType] then
    self.showType_ = defaultType
  else
    for i, v in ipairs(conditionDict) do
      if v then
        self.showType_ = i
        break
      end
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_page_trans, pageFuncOpen)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_handbook_trans, manualFuncOpen)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tab_gameplay_preview_trans, funcPreviewFuncOpen)
  if isSevenDayShow then
    self.uiBinder.lab_name.text = Lang("Sevendaystarget")
  else
    self.uiBinder.lab_name.text = Lang("GameplayPreview")
  end
  local toggleGroup = self.uiBinder.tab_handbook_tog.group
  self.uiBinder.tab_handbook_tog.group = nil
  self.uiBinder.tab_page_tog.group = nil
  self.uiBinder.tab_funcpreview.group = nil
  self.uiBinder.tab_handbook_tog:SetIsOnWithoutCallBack(false)
  self.uiBinder.tab_page_tog:SetIsOnWithoutCallBack(false)
  self.uiBinder.tab_funcpreview:SetIsOnWithoutCallBack(false)
  if self.showType_ == E.SevenDayFuncType.Manual then
    self.uiBinder.tab_handbook_tog.isOn = true
  elseif self.showType_ == E.SevenDayFuncType.TitlePage then
    self.uiBinder.tab_page_tog.isOn = true
  elseif self.showType_ == E.SevenDayFuncType.FuncPreview then
    self.uiBinder.tab_funcpreview.isOn = true
  end
  self.uiBinder.tab_handbook_tog.group = toggleGroup
  self.uiBinder.tab_page_tog.group = toggleGroup
  self.uiBinder.tab_funcpreview.group = toggleGroup
  sevendaysRed_.LoadTitlePageTabItem(self, self.uiBinder.node_tab_page_trans)
  sevendaysRed_.LoadManualTabRedItem(self, self.uiBinder.node_tab_handbook_trans)
  sevendaysRed_.LoadFuncPreviewTabRedItem(self, self.uiBinder.tab_gameplay_preview_trans)
end

function Sevendaystarget_mainView:refreshUI()
  self.uiBinder.node_handbook.Ref.UIComp:SetVisible(self.showType_ == E.SevenDayFuncType.Manual)
  self.uiBinder.node_page.Ref.UIComp:SetVisible(self.showType_ == E.SevenDayFuncType.TitlePage)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_handbook, self.showType_ == E.SevenDayFuncType.Manual)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_page, self.showType_ == E.SevenDayFuncType.TitlePage)
  self.funcPreview_:DeActive()
  if self.showType_ == E.SevenDayFuncType.Manual then
    self:refreshManualUI()
  elseif self.showType_ == E.SevenDayFuncType.TitlePage then
    self:refreshTitlePageUI()
  elseif self.showType_ == E.SevenDayFuncType.FuncPreview then
    self:refreshFuncPreviewUI()
  end
  self:refreshPageTip()
end

function Sevendaystarget_mainView:refreshPageTip()
  local restSecond = ""
  local timerInfo = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(Z.Global.LoginTips)
  if timerInfo ~= nil and timerInfo.Offset.count > 0 then
    restSecond = Z.TimeFormatTools.FormatToDHMS(timerInfo.Offset[0])
  end
  if restSecond and restSecond ~= "" then
    self.uiBinder.node_page.Ref:SetVisible(self.uiBinder.node_page.lab_tips, true)
    self.uiBinder.node_page.lab_tips.text = Lang("Receiverewards5pmdaily", {val = restSecond})
  else
    self.uiBinder.node_page.Ref:SetVisible(self.uiBinder.node_page.lab_tips, false)
  end
end

function Sevendaystarget_mainView:refreshManualUI()
  self:refreshManualTab()
  self:refreshManualTaskList()
end

function Sevendaystarget_mainView:refreshManualTab()
  if not self.initManualTab_ then
    self:loadManualTab()
  end
  if self.initManualTab_ and next(self.manualTabDict_) then
    for k, v in pairs(self.manualTabDict_) do
      v.tog_item.isOn = false
      sevendaysRed_.LoadManualTQuestabRedItem(k, self, v.tog_item_trans)
      local isUnlock = k <= self.vm.GetCurDay()
      v.Ref:SetVisible(v.lab_figure_off, isUnlock)
      v.Ref:SetVisible(v.lab_figure_on, isUnlock)
      if isUnlock then
        local finishCount_, taskCount_ = self.vm.GetFinishCountByTaskId(k)
        v.lab_figure_off.text = finishCount_ .. "/" .. taskCount_
        v.lab_figure_on.text = finishCount_ .. "/" .. taskCount_
      end
    end
    self.manualTabDict_[self.curSelectDay_].tog_item.isOn = true
  end
end

function Sevendaystarget_mainView:loadManualTab()
  Z.CoroUtil.create_coro_xpcall(function()
    local dataMgr = Z.DataMgr.Get("season_quest_sub_data")
    local dayArray = dataMgr:GetDayArray()
    local tabPath_ = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "manualpageItem")
    local dayStrDict = {}
    for _, day in ipairs(dayArray) do
      local uiName = "page_" .. day
      dayStrDict[day] = uiName
      self:RemoveUiUnit(uiName)
    end
    self.manualTabDict_ = {}
    for _, v in ipairs(dayArray) do
      local day_ = v
      local pageBinder_ = self:AsyncLoadUiUnit(tabPath_, dayStrDict[day_], self.uiBinder.tab_handbook_content)
      pageBinder_.lab_name_on.text = Lang("SeasonTargetTipsDay" .. day_)
      pageBinder_.lab_name_off.text = Lang("SeasonTargetTipsDay" .. day_)
      local isUnlock_ = day_ <= self.vm.GetCurDay()
      pageBinder_.Ref:SetVisible(pageBinder_.lab_day_off, isUnlock_)
      pageBinder_.Ref:SetVisible(pageBinder_.lab_day_on, isUnlock_)
      pageBinder_.Ref:SetVisible(pageBinder_.node_lab, not isUnlock_)
      if isUnlock_ then
        pageBinder_.lab_day_off.text = string.format(Lang("SeasonQuestDay"), day_)
        pageBinder_.lab_day_on.text = string.format(Lang("SeasonQuestDay"), day_)
      else
        pageBinder_.lab_lcok.text = string.format(Lang("SevenDaysTargetTabUnlock"), day_)
      end
      pageBinder_.tog_item.isOn = false
      pageBinder_.tog_item.group = self.uiBinder.tab_handbook_content_Toggroup
      pageBinder_.tog_item:AddListener(function()
        if pageBinder_.tog_item.isOn then
          pageBinder_.anim:Restart(Z.DOTweenAnimType.Open)
          self:changeDay(day_)
        end
      end)
      pageBinder_.Ref:SetVisible(pageBinder_.lab_figure_off, isUnlock_)
      pageBinder_.Ref:SetVisible(pageBinder_.lab_figure_on, isUnlock_)
      if isUnlock_ then
        local finishCount_, taskCount_ = self.vm.GetFinishCountByTaskId(day_)
        pageBinder_.lab_figure_off.text = finishCount_ .. "/" .. taskCount_
        pageBinder_.lab_figure_on.text = finishCount_ .. "/" .. taskCount_
      end
      pageBinder_.Ref:SetVisible(pageBinder_.btn_lock, not isUnlock_)
      self:AddClick(pageBinder_.btn_lock, function()
        Z.TipsVM.ShowTips(1381017, {val = day_})
      end)
      sevendaysRed_.LoadManualTQuestabRedItem(day_, self, pageBinder_.tog_item_trans)
      self.manualTabDict_[day_] = pageBinder_
    end
    self.manualTabDict_[self.curSelectDay_].tog_item.isOn = true
    self.initManualTab_ = true
  end)()
end

function Sevendaystarget_mainView:getLeftRightTaskList()
  local dataListHorizontal = {}
  local dataListVertical = {}
  local hor = true
  local taskCfgs = self.vm.GetAllTaskConfig()
  for _, cfg in pairs(taskCfgs) do
    if cfg.OpenDay == self.curSelectDay_ and self.tasks_[cfg.OpenDay] and self.tasks_[cfg.OpenDay][cfg.TargetId] then
      local taskData = self.tasks_[cfg.OpenDay][cfg.TargetId]
      if cfg and cfg.tab == E.SevenDayStargetType.Manual then
        if hor then
          table.insert(dataListHorizontal, {
            cfg,
            taskData.award,
            taskData.targetNum
          })
        else
          table.insert(dataListVertical, {
            cfg,
            taskData.award,
            taskData.targetNum
          })
        end
        hor = not hor
      end
    end
  end
  table.sort(dataListHorizontal, function(left, right)
    if left[1].TargetId < right[1].TargetId then
      return true
    end
    return false
  end)
  table.sort(dataListVertical, function(left, right)
    if left[1].TargetId < right[1].TargetId then
      return true
    end
    return false
  end)
  local hLen_ = #dataListHorizontal
  local vLen_ = #dataListVertical
  local maxLen_ = math.max(hLen_, vLen_)
  if vLen_ < maxLen_ then
    if vLen_ % 2 == 1 then
      local temp_ = dataListHorizontal[hLen_]
      table.remove(dataListHorizontal, hLen_)
      table.insert(dataListVertical, temp_)
      table.insert(dataListHorizontal, {
        nil,
        nil,
        nil
      })
    else
      table.insert(dataListVertical, {
        nil,
        nil,
        nil
      })
    end
  end
  return dataListHorizontal, dataListVertical, maxLen_
end

function Sevendaystarget_mainView:getTaskProgress(targetNum, cfg)
  if targetNum == nil or cfg == nil then
    return 0
  end
  local targetInfo_ = self.vm.GetTaskTargetConfig(cfg.Target)
  local progressNum_ = targetNum * 100 / targetInfo_.Num
  return math.floor(progressNum_)
end

function Sevendaystarget_mainView:refreshManualTaskList()
  local dataList_ = {}
  local dataListHorizontal_, dataListVertical_, maxLen_ = self:getLeftRightTaskList()
  local isVH_ = false
  for index_ = 1, maxLen_ do
    local data_ = {}
    data_.isVH = isVH_
    data_.select = 0
    if isVH_ then
      data_.leftInfo = dataListVertical_[index_][1]
      data_.rightInfo = dataListHorizontal_[index_][1]
      data_.leftComplete = dataListVertical_[index_][2]
      data_.rightComplete = dataListHorizontal_[index_][2]
      data_.leftProgress = self:getTaskProgress(dataListVertical_[index_][3], dataListVertical_[index_][1])
      data_.rightProgress = self:getTaskProgress(dataListHorizontal_[index_][3], dataListHorizontal_[index_][1])
    else
      data_.leftInfo = dataListHorizontal_[index_][1]
      data_.rightInfo = dataListVertical_[index_][1]
      data_.leftComplete = dataListHorizontal_[index_][2]
      data_.rightComplete = dataListVertical_[index_][2]
      data_.leftProgress = self:getTaskProgress(dataListHorizontal_[index_][3], dataListHorizontal_[index_][1])
      data_.rightProgress = self:getTaskProgress(dataListVertical_[index_][3], dataListVertical_[index_][1])
    end
    isVH_ = not isVH_
    table.insert(dataList_, data_)
  end
  local startSelect, startSelectLeft = self:getSelectIndex(dataList_)
  local moveList_ = self.selectManualCfg == nil
  dataList_[startSelect].select = startSelectLeft
  self.loopListView_:RefreshListView(dataList_)
  if moveList_ then
    self.loopListView_:MovePanelToItemIndex(startSelect)
  end
end

function Sevendaystarget_mainView:getSelectIndex(dataList)
  local startSelect = 0
  local startSelectLeft = 1
  if self.viewData and self.viewData.selectManualCfg then
    for index_, data_ in ipairs(dataList) do
      if data_.leftInfo and self.viewData.selectManualCfg.TargetId == data_.leftInfo.TargetId then
        startSelect = index_
        startSelectLeft = 1
        break
      elseif data_.rightInfo and self.viewData.selectManualCfg.TargetId == data_.rightInfo.TargetId then
        startSelectLeft = 2
        startSelect = index_
        break
      end
    end
    self.viewData.selectManualCfg = nil
  end
  if startSelect == 0 and self.selectManualCfg then
    for index_, data_ in ipairs(dataList) do
      if data_.leftInfo and self.selectManualCfg.TargetId == data_.leftInfo.TargetId then
        startSelect = index_
        startSelectLeft = 1
        break
      elseif data_.rightInfo and self.selectManualCfg.TargetId == data_.rightInfo.TargetId then
        startSelectLeft = 2
        startSelect = index_
        break
      end
    end
  end
  if startSelect == 0 then
    for index_, data_ in ipairs(dataList) do
      if data_.leftComplete == self.vm.AwardState.canGet then
        startSelectLeft = 1
        startSelect = index_
        break
      elseif data_.rightComplete == self.vm.AwardState.canGet then
        startSelectLeft = 2
        startSelect = index_
        break
      end
    end
  end
  if startSelect == 0 then
    for index_, data_ in ipairs(dataList) do
      if data_.leftComplete == self.vm.AwardState.notFinish then
        startSelectLeft = 1
        startSelect = index_
        break
      elseif data_.rightComplete == self.vm.AwardState.notFinish then
        startSelectLeft = 2
        startSelect = index_
        break
      end
    end
  end
  if startSelect == 0 then
    startSelect = 1
    startSelectLeft = 1
  end
  return startSelect, startSelectLeft
end

function Sevendaystarget_mainView:OnClickManualItem(cfg, showVertical, isClick)
  for _, v in pairs(self.loopListView_.itemDict_) do
    v:RefreshSelect(false, nil)
  end
  self.selectManualCfg = cfg
  self:refreshManualRightInfoUI(showVertical, isClick)
end

function Sevendaystarget_mainView:refreshManualRightInfoUI(showVertical, isClick)
  if self.selectManualCfg then
    if self.tasks_[self.curSelectDay_] == nil then
      return
    end
    local taskinfo_ = self.tasks_[self.curSelectDay_][self.selectManualCfg.TargetId]
    local targetInfo_ = self.vm.GetTaskTargetConfig(self.selectManualCfg.Target)
    if taskinfo_ and targetInfo_ then
      do
        local showComplete_ = taskinfo_.award == self.vm.AwardState.hasGet
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.img_complete, showComplete_)
        local showGetBtn_ = taskinfo_.award == self.vm.AwardState.canGet or taskinfo_.award == self.vm.AwardState.notFinish and self.selectManualCfg.QuickJumpType == ""
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.btn_get, showGetBtn_)
        self.uiBinder.node_handbook.btn_get:RemoveAllListeners()
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.btn_get_red, taskinfo_.award == self.vm.AwardState.canGet)
        if taskinfo_.award == self.vm.AwardState.canGet then
          self:AddAsyncClick(self.uiBinder.node_handbook.btn_get, function()
            self:getTaskAward(self.selectManualCfg.TargetId)
          end)
        end
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.node_rimg_horizontal, not showVertical)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.node_rimg_vertical, showVertical)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.rimg_figure_grey_horizontal, taskinfo_.award ~= self.vm.AwardState.hasGet)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.rimg_figure_grey_vertical, taskinfo_.award ~= self.vm.AwardState.hasGet)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.rimg_figure_horizontal, taskinfo_.award == self.vm.AwardState.hasGet)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.rimg_figure_vertical, taskinfo_.award == self.vm.AwardState.hasGet)
        local showQuickJumpBtn_ = taskinfo_.award == self.vm.AwardState.notFinish and self.selectManualCfg.QuickJumpType > 0
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.btn_quickjump, showQuickJumpBtn_)
        self.uiBinder.node_handbook.Ref:SetVisible(self.uiBinder.node_handbook.img_ing, not showQuickJumpBtn_ and not showGetBtn_ and not showComplete_)
        if not showVertical then
          self.uiBinder.node_handbook.rimg_figure_horizontal:SetImage(self.selectManualCfg.PicHor)
          self.uiBinder.node_handbook.rimg_figure_grey_horizontal:SetImage(self.selectManualCfg.PicHor)
        else
          self.uiBinder.node_handbook.rimg_figure_vertical:SetImage(self.selectManualCfg.PicVer)
          self.uiBinder.node_handbook.rimg_figure_grey_vertical:SetImage(self.selectManualCfg.PicVer)
        end
        self:onAnimCardShow(taskinfo_.award == self.vm.AwardState.hasGet, showVertical, isClick)
        self:setTaskProgressText(taskinfo_.targetNum, targetInfo_.Num)
        self.uiBinder.node_handbook.lan_content_01.text = Z.Placeholder.Placeholder(targetInfo_.Describe, {
          val = targetInfo_.Num
        })
        self.uiBinder.node_handbook.lan_content_02.text = self.selectManualCfg.AddDesc
        self:AddClick(self.uiBinder.node_handbook.btn_quickjump, function()
          self:quickJumpManualQuest()
        end)
        local awardList_ = self.awardPreviewVm.GetAllAwardPreListByIds(self.selectManualCfg.AwardId)
        for _, v in ipairs(self.manualAwardItemBinderUIList) do
          self:RemoveUiUnit(v)
        end
        self.manualAwardItemBinderUIList = {}
        Z.CoroUtil.create_coro_xpcall(function()
          for i = 1, #awardList_ do
            local unitName_ = "awardItem_" .. awardList_[i].awardId
            local item_ = self:AsyncLoadUiUnit(GetLoadAssetPath("BackPack_Item_Unit_Addr1_8_New"), unitName_, self.uiBinder.node_handbook.content)
            table.insert(self.manualAwardItemBinderUIList, unitName_)
            local itemData = {
              uiBinder = item_,
              configId = awardList_[i].awardId,
              isShowReceive = taskinfo_.award == self.vm.AwardState.hasGet,
              isSquareItem = true,
              PrevDropType = awardList_[i].PrevDropType
            }
            itemData.labType, itemData.lab = self.awardPreviewVm.GetPreviewShowNum(awardList_[i])
            local itemBinder_ = self.manualAwardItemBinderList[i]
            if itemBinder_ == nil then
              itemBinder_ = itemBinder.new(self)
              table.insert(self.manualAwardItemBinderList, itemBinder_)
            end
            itemBinder_:Init(itemData)
          end
        end)()
      end
    end
  else
    logError("\230\156\170\233\128\137\228\184\173\231\155\174\230\160\135")
  end
end

function Sevendaystarget_mainView:quickJumpManualQuest()
  if self.selectManualCfg and self.selectManualCfg.QuickJumpType > 0 then
    Z.DataMgr.Get("season_quest_sub_data"):SetShowDay(self.curSelectDay_)
    local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
    quickJumpVm.DoJumpByConfigParam(self.selectManualCfg.QuickJumpType, self.selectManualCfg.QuickJumpParam)
  end
end

function Sevendaystarget_mainView:setTaskProgressText(targetNum, Num)
  local targetNumShow = targetNum
  if Num < targetNum then
    targetNumShow = Num
  end
  self.uiBinder.node_handbook.lab_figure_01.text = targetNumShow
  self.uiBinder.node_handbook.lab_figure_02.text = Num
end

function Sevendaystarget_mainView:refreshTitlePageUI()
  self:resetPageItemBinder()
  local taskCfgs = self.vm.GetAllTaskConfig()
  for _, cfg in pairs(taskCfgs) do
    if cfg.tab == E.SevenDayStargetType.TitlePage and self.tasks_[cfg.OpenDay] and self.tasks_[cfg.OpenDay][cfg.TargetId] then
      local taskData = self.tasks_[cfg.OpenDay][cfg.TargetId]
      self:refreshTitlePageDayUI(self.titlePageList_[cfg.OpenDay], cfg, taskData)
    end
  end
end

function Sevendaystarget_mainView:refreshFuncPreviewUI()
  if self.funcPreview_ then
    local vd
    if self.previewFuncId_ then
      vd = {
        funcId = self.previewFuncId_
      }
    end
    self.funcPreview_:Active(vd, self.uiBinder.node_preview)
  end
end

function Sevendaystarget_mainView:refreshTitlePageDayUI(dayBinder, cfg, taskData)
  self:refreshTitlePageAwardItem(cfg.AwardId, taskData, cfg.OpenDay, dayBinder.item_binder)
  dayBinder.Ref:SetVisible(dayBinder.img_complete, taskData.award == self.vm.AwardState.hasGet)
  dayBinder.Ref:SetVisible(dayBinder.lab_claimable, taskData.award == self.vm.AwardState.canGet)
  dayBinder.Ref:SetVisible(dayBinder.lab_clock, taskData.award == self.vm.AwardState.notFinish or taskData.award == self.vm.AwardState.notOpen)
  dayBinder.Ref:SetVisible(dayBinder.rimg_bg_off, taskData.award ~= self.vm.AwardState.canGet)
  dayBinder.Ref:SetVisible(dayBinder.rimg_bg_on, taskData.award == self.vm.AwardState.canGet)
  dayBinder.Ref:SetVisible(dayBinder.img_mark, taskData.award == self.vm.AwardState.hasGet)
  dayBinder.btn_self:RemoveAllListeners()
  dayBinder.lab_day.color = taskData.award == self.vm.AwardState.canGet and self.colorBlack_ or self.colorWhite_
  if taskData.award == self.vm.AwardState.canGet then
    self:AddAsyncClick(dayBinder.btn_self, function()
      self:getTaskAward(taskData.id)
    end)
  end
  sevendaysRed_.LoadTitlePageBtnItem(cfg.OpenDay, self, dayBinder.Trans)
end

function Sevendaystarget_mainView:getTaskAward(id)
  local success_ = self.vm.AsyncGetTaskAward(id, self.cancelSource)
  if success_ then
    local cfg_ = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetRow(id)
    local rewardIds = self.awardPreviewVm.GetAllAwardPreListByIds(cfg_.AwardId)
    local data = {}
    for _, value in ipairs(rewardIds) do
      data[#data + 1] = {
        configId = value.awardId,
        count = value.awardNum
      }
    end
    Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
  end
end

function Sevendaystarget_mainView:refreshTitlePageAwardItem(id, taskData, openDay, itemBinder)
  local awardList_ = self.awardPreviewVm.GetAllAwardPreListByIds(id)
  if awardList_ and 0 < #awardList_ then
    local itemData = {
      uiBinder = itemBinder,
      configId = awardList_[1].awardId,
      isShowReceive = taskData.award == self.vm.AwardState.hasGet,
      isSquareItem = true,
      PrevDropType = awardList_[1].PrevDropType
    }
    itemData.labType, itemData.lab = self.awardPreviewVm.GetPreviewShowNum(awardList_[1])
    if taskData.award == self.vm.AwardState.canGet then
      function itemData.clickCallFunc()
        self:getTaskAward(taskData.id)
      end
    end
    self.titlePageItemList_[openDay]:Init(itemData)
  else
    logError("\228\184\131\230\151\165\231\153\187\229\189\149\229\165\150\229\138\177\233\133\141\231\189\174\233\148\153\232\175\175,awardid: " .. id)
  end
end

function Sevendaystarget_mainView:refreshByDay()
  if self.curSelectDay_ > self.vm.GetCurDay() then
    self:refreshUI()
  end
  self.timerMgr:Clear()
  self.endTime_ = self.vm.GetDayEndTime()
  self.timerMgr:StartTimer(function()
    self:refreshByDay()
  end, self.endTime_, 1)
end

function Sevendaystarget_mainView:changeDay(day)
  if self.curSelectDay_ == day then
    return
  end
  self.selectManualCfg = nil
  self.curSelectDay_ = day
  self:refreshManualUI()
  self.uiBinder.node_handbook.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function Sevendaystarget_mainView:GetCacheData()
  local viewData = self.viewData or {}
  viewData.showType = self.showType_
  viewData.selectDay_ = self.curSelectDay_
  viewData.selectManualCfg = self.selectManualCfg
  return viewData
end

function Sevendaystarget_mainView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Sevendaystarget_mainView:onStarthandbookClickAnimShow()
  self.uiBinder.node_handbook.anim:Restart(Z.DOTweenAnimType.Open)
end

function Sevendaystarget_mainView:onAnimCardShow(isget, showV, isClick)
  if isClick then
    self.uiBinder.node_handbook.anim:Pause()
    self.uiBinder.node_handbook.anim:Restart(Z.DOTweenAnimType.Tween_1)
  end
end

return Sevendaystarget_mainView
