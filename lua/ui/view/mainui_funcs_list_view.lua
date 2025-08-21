local UI = Z.UI
local super = require("ui.ui_view_base")
local Mainui_funcs_listView = class("Mainui_funcs_listView", super)
local loopListView = require("ui.component.loop_list_view")
local escItem = require("ui/component/mainui/esc_loop_item")
local escBannerItem = require("ui/component/mainui/esc_banner_item")
local PANDORA_DEFINE = require("ui.model.pandora_define")

function Mainui_funcs_listView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mainui_funcs_list", "main/main_funcs_list_window", true)
  self.mainUIFuncsListVM_ = Z.VMMgr.GetVM("mainui_funcs_list")
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.mainUiVM_ = Z.VMMgr.GetVM("mainui")
  self.funcPreviewVM_ = Z.VMMgr.GetVM("function_preview")
  self.gotoVM_ = Z.VMMgr.GetVM("gotofunc")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
end

function Mainui_funcs_listView:OnActive()
  Z.AudioMgr:Play("UI_Event_SystemMenu_Open")
  self:AddClick(self.uiBinder.cont_btn_return, function()
    self.mainUIFuncsListVM_.CloseView()
  end)
  self:AddClick(self.uiBinder.btn_banner_left, function()
    self:clearBannerLoopTimer()
    self:switchBannerItem(true)
    self:createBannerLoopTimer()
  end)
  self:AddClick(self.uiBinder.btn_banner_right, function()
    self:clearBannerLoopTimer()
    self:switchBannerItem(false)
    self:createBannerLoopTimer()
  end)
  self:AddAsyncClick(self.uiBinder.btn_detach, function()
    local playerVM = Z.VMMgr.GetVM("player")
    playerVM:OpenUnstuckTip()
  end)
  self:AddAsyncClick(self.uiBinder.btn_exit, function()
    local accountModuleVM = Z.VMMgr.GetVM("accountmodule")
    accountModuleVM.Logout()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_service, self.userSupportVM_.CheckValid(E.UserSupportType.MainFunc))
  local serviceIcon = self.userSupportVM_.GetUserSupportIcon(E.UserSupportType.MainFunc)
  if serviceIcon and serviceIcon ~= "" then
    self.uiBinder.img_service:SetImage(serviceIcon)
  end
  self:AddClick(self.uiBinder.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.MainFunc)
  end)
  local isDetachStuckFuncOpen = self.gotoVM_.CheckFuncCanUse(E.FunctionID.DetachStuck, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_detach, isDetachStuckFuncOpen)
  self.hadSendRefreshPandora_ = false
  self:bindEvents()
  self:initLoopComp()
  self:refreshFuncItem()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
end

function Mainui_funcs_listView:OnDeActive()
  self:closeAllUnLockEffect()
  self:unBindEvents()
  self:unInitLoopComp()
  self:clearFuncItem()
  self:clearBannerLoopTimer()
  self:clearBannerDotItem()
  self.mainUiVM_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
end

function Mainui_funcs_listView:OnRefresh()
  self.mainUiVM_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
end

function Mainui_funcs_listView:OnShow()
  self:refreshFeaturePreview()
end

function Mainui_funcs_listView:OnHide()
  self:clearBannerLoopTimer()
end

function Mainui_funcs_listView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.refreshFuncItem, self)
  Z.EventMgr:Add(Z.ConstValue.QuestionnaireInfosRefresh, self.refreshFuncItem, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.refreshFuncItem, self)
  Z.EventMgr:Add(Z.ConstValue.ShowMainFeatureUnLockEffect, self.onShowUnLockEffect, self)
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Add(PANDORA_DEFINE.EventName.ResourceReady, self.onPandoraResourceReady, self)
  
  function self.refreshSeasonHandbookBtnFunc_()
    self:refreshFuncItem()
  end
  
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:RegWatcher(self.refreshSeasonHandbookBtnFunc_)
end

function Mainui_funcs_listView:unBindEvents()
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:UnregWatcher(self.refreshSeasonHandbookBtnFunc_)
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionIcon, self.refreshFuncItem, self)
  Z.EventMgr:Remove(Z.ConstValue.QuestionnaireInfosRefresh, self.refreshFuncItem, self)
  Z.EventMgr:Remove(Z.ConstValue.RoleLevelUp, self.refreshFuncItem, self)
  Z.EventMgr:Remove(Z.ConstValue.ShowMainFeatureUnLockEffect, self.onShowUnLockEffect, self)
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  Z.EventMgr:Remove(PANDORA_DEFINE.EventName.ResourceReady, self.onPandoraResourceReady, self)
end

function Mainui_funcs_listView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self.mainUIFuncsListVM_.CloseView()
  end
end

function Mainui_funcs_listView:refreshFuncItem()
  Z.CoroUtil.create_coro_xpcall(function()
    local mainItemList, rightItemList = self:getFuncItemInfo()
    self:SetUIVisible(self.uiBinder.canvas_group_main, false)
    self:clearFuncItem()
    self:createFuncItem(mainItemList)
    self:refreshRightItemList(rightItemList)
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    self.uiBinder.layout_content:SetLayoutGroup()
    self:SetUIVisible(self.uiBinder.canvas_group_main, true)
  end)()
end

function Mainui_funcs_listView:createFuncItem(mainItemList)
  self.grayList_ = self.mainUiVM_.GetUnclickableFuncsInScene()
  local totalCount = #mainItemList
  local unitParent = self.uiBinder.node_content
  for index, info in ipairs(mainItemList) do
    local groupId = info.groupId
    for index, row in ipairs(info.funcList) do
      local iconName
      if Z.IsPCUI then
        iconName = row.PCEnlargeIcon and "long_btn" or "btn"
      else
        iconName = row.EnlargeIcon and "long_btn" or "btn"
      end
      local unitPath = self:GetPrefabCacheDataNew(self.uiBinder.prefab_root, iconName)
      local unitName = row.Id
      local unitToken = self.cancelSource:CreateToken()
      self.itemUnitTokenDict_[unitName] = unitToken
      local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
      self.itemUnitDict_[unitName] = unitItem
      self:setItemStyle(unitItem, row)
    end
    if index < totalCount then
      local lineUnitPath = self:GetPrefabCacheDataNew(self.uiBinder.prefab_root, "line")
      local lineUnitName = "line_" .. groupId
      local lineUnitToken = self.cancelSource:CreateToken()
      self.itemUnitTokenDict_[lineUnitName] = lineUnitToken
      local lineUnitItem = self:AsyncLoadUiUnit(lineUnitPath, lineUnitName, unitParent, lineUnitToken)
      self.itemUnitDict_[lineUnitName] = lineUnitItem
    end
  end
end

function Mainui_funcs_listView:setItemStyle(item, row)
  local isLock = self.grayList_[row.Id] ~= nil
  local alpha = isLock and 0.3 or 1
  item.Ref:SetVisible(item.node_root, true)
  local imgPath = Z.IsPCUI and row.PCIcon or row.Icon
  item.img_icon:SetImage(imgPath)
  item.group_btn.alpha = alpha
  item.btn.IsDisabled = isLock
  item.Ref:SetVisible(item.img_select, false)
  item.btn_audio:AddAudioEvent(row.Path, 3)
  item.btn:AddListener(function()
    if not isLock then
      self.gotoVM_.TraceOrSwitchFunc(row.Id)
      Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvent, string.zconcat(E.SteerGuideEventType.SelectedMainFunction, "=", row.Id))
    else
      Z.TipsVM.ShowTips(1001604)
    end
  end)
  local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(row.Id)
  if funcRow then
    item.lab_content.text = funcRow.Name
  end
  Z.GuideMgr:SetSteerIdByComp(item.mainicon_btn_tpl, E.DynamicSteerType.FunctionId, row.Id)
  Z.RedPointMgr.LoadRedDotItem(row.Id, self, item.Trans)
end

function Mainui_funcs_listView:clearFuncItem()
  if self.itemUnitTokenDict_ then
    for unitName, unitToken in pairs(self.itemUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.itemUnitTokenDict_ = {}
  if self.itemUnitDict_ then
    for unitName, unitItem in pairs(self.itemUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.itemUnitDict_ = {}
end

function Mainui_funcs_listView:initLoopComp()
  local btnPath = Z.IsPCUI and "main_sys_esc_btn_tpl_pc" or "main_sys_esc_btn_tpl"
  self.loopRightItemListView_ = loopListView.new(self, self.uiBinder.loop_right_item, escItem, btnPath)
  self.loopRightItemListView_:Init({})
  self.loopBannerList_ = loopListView.new(self, self.uiBinder.loop_banner, escBannerItem, "main_themeact_item_tpl")
  self.loopBannerList_:Init({})
  self.loopBannerList_:SetSnapFinishCallback(function(loopComp, loopItem)
    self:OnBannerSnapFinish(loopItem)
  end)
  self.loopBannerList_:SetBeginDragAction(function()
    self:clearBannerLoopTimer()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_left, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_right, false)
  end)
end

function Mainui_funcs_listView:refreshRightItemList(rightItemList)
  self.loopRightItemListView_:RefreshListView(rightItemList, true)
end

function Mainui_funcs_listView:unInitLoopComp()
  self.loopRightItemListView_:UnInit()
  self.loopRightItemListView_ = nil
  self.loopBannerList_:SetSnapFinishCallback(nil)
  self.loopBannerList_:SetBeginDragAction(nil)
  self.loopBannerList_:UnInit()
  self.loopBannerList_ = nil
end

function Mainui_funcs_listView:sortRowList(rowList)
  table.sort(rowList, function(a, b)
    local aSortId = Z.IsPCUI and a.PCSortId or a.SortId
    local bSortId = Z.IsPCUI and b.PCSortId or b.SortId
    if aSortId == bSortId then
      return a.Id < b.Id
    else
      return aSortId < bSortId
    end
  end)
end

function Mainui_funcs_listView:getFuncItemInfo()
  local mainItemDict = {}
  local mainItemList = {}
  local rightItemList = {}
  local switchVM = Z.VMMgr.GetVM("switch")
  local configDict = Z.TableMgr.GetTable("MainIconTableMgr").GetDatas()
  for funcId, row in pairs(configDict) do
    local placeRow = Z.IsPCUI and row.PCSystemPlace or row.SystemPlace
    local groupId = Z.IsPCUI and row.GroupId or row.MobileGroupId
    if table.zcontains(placeRow, E.MainUIPlaceType.Esc) and 0 < groupId and switchVM.CheckFuncSwitch(funcId) and self:isFunctionShow(funcId) then
      if mainItemDict[groupId] == nil then
        mainItemDict[groupId] = {}
      end
      table.insert(mainItemDict[groupId], row)
    end
    if table.zcontains(placeRow, E.MainUIPlaceType.EscRight) and switchVM.CheckFuncSwitch(funcId) and self:isFunctionShow(funcId) then
      table.insert(rightItemList, row)
    end
  end
  for groupId, rowList in pairs(mainItemDict) do
    self:sortRowList(rowList)
    local maxColumnCount = 5
    local tempCount = 0
    for i = 1, #rowList do
      local row = rowList[i]
      if Z.IsPCUI then
        tempCount = row.PCEnlargeIcon and tempCount + 2 or tempCount + 1
      else
        tempCount = row.EnlargeIcon and tempCount + 2 or tempCount + 1
      end
      if maxColumnCount < tempCount and i < #rowList then
        local tempRow = rowList[i + 1]
        rowList[i + 1] = rowList[i]
        rowList[i] = tempRow
      elseif tempCount == maxColumnCount then
        tempCount = 0
      end
    end
    table.insert(mainItemList, {groupId = groupId, funcList = rowList})
  end
  table.sort(mainItemList, function(a, b)
    return a.groupId < b.groupId
  end)
  self:sortRowList(rightItemList)
  return mainItemList, rightItemList
end

function Mainui_funcs_listView:refreshFeaturePreview()
  local isShowBanner = false
  local allBannerList = self.mainUIFuncsListVM_:GetBannerList()
  local count = #allBannerList
  isShowBanner = 0 < count
  self.curBannerIndex_ = 1
  self.loopBannerList_:RefreshListView(allBannerList, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_banner, isShowBanner)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_left, 1 < count)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_right, 1 < count)
  self:refreshBannerDotItem(count)
  self:createBannerLoopTimer()
  if Z.IsPCUI then
    if isShowBanner then
      self.uiBinder.loop_menu:SetOffsetMax(-118, -200)
      self.uiBinder.loop_menu:SetOffsetMin(-618, 30)
    else
      self.uiBinder.loop_menu:SetOffsetMax(-118, -110)
      self.uiBinder.loop_menu:SetOffsetMin(-618, 30)
    end
  elseif isShowBanner then
    self.uiBinder.loop_menu:SetOffsetMax(-146, -256)
    self.uiBinder.loop_menu:SetOffsetMin(-546, 30)
  else
    self.uiBinder.loop_menu:SetOffsetMax(-146, -135)
    self.uiBinder.loop_menu:SetOffsetMin(-546, 30)
  end
  return isShowBanner
end

function Mainui_funcs_listView:OnBannerSnapFinish(loopItem)
  self.curBannerIndex_ = loopItem.ItemIndex + 1
  self:refreshBannerDotItemUI()
  self:createBannerLoopTimer()
  local allData = self.loopBannerList_:GetData()
  local count = #allData
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_left, 1 < count)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_banner_right, 1 < count)
end

function Mainui_funcs_listView:createBannerLoopTimer()
  self:clearBannerLoopTimer()
  self.bannerLoopTimer_ = self.timerMgr:StartTimer(function()
    self:switchBannerItem(false)
  end, 2, -1)
end

function Mainui_funcs_listView:clearBannerLoopTimer()
  if self.bannerLoopTimer_ then
    self.bannerLoopTimer_:Stop()
    self.bannerLoopTimer_ = nil
  end
end

function Mainui_funcs_listView:switchBannerItem(isReverse)
  local allData = self.loopBannerList_:GetData()
  local allCount = #allData
  if allCount <= 1 then
    return
  end
  if isReverse then
    if self.curBannerIndex_ == 1 then
      self.loopBannerList_:MovePanelToItemIndex(allCount, 0)
    else
      self.loopBannerList_:MovePanelToItemIndex(self.curBannerIndex_ - 1, 0)
    end
  elseif self.curBannerIndex_ == allCount then
    self.loopBannerList_:MovePanelToItemIndex(1, 0)
  else
    self.loopBannerList_:MovePanelToItemIndex(self.curBannerIndex_ + 1, 0)
  end
end

function Mainui_funcs_listView:refreshBannerDotItem(count)
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearBannerDotItem()
    if 0 < count then
      self:createBannerDotItem(count)
    end
  end)()
end

function Mainui_funcs_listView:createBannerDotItem(count)
  local unitPath = self:GetPrefabCacheDataNew(self.uiBinder.prefab_root, "banner_dot")
  for i = 1, count do
    local unitName = "banner_dot_" .. i
    local unitToken = self.cancelSource:CreateToken()
    self.bannerDotUnitTokenDict_[unitName] = unitToken
    local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.layout_dot, unitToken)
    self.bannerDotUnitDict_[unitName] = unitItem
    self.bannerDotUnitList_[i] = unitItem
  end
  self:refreshBannerDotItemUI()
end

function Mainui_funcs_listView:clearBannerDotItem()
  if self.bannerDotUnitTokenDict_ then
    for unitName, unitToken in pairs(self.bannerDotUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.bannerDotUnitTokenDict_ = {}
  if self.bannerDotUnitDict_ then
    for unitName, unitItem in pairs(self.bannerDotUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.bannerDotUnitDict_ = {}
  self.bannerDotUnitList_ = {}
end

function Mainui_funcs_listView:refreshBannerDotItemUI()
  if self.bannerDotUnitList_ == nil then
    return
  end
  local centerNum = #self.bannerDotUnitList_ * 0.5 + 0.5
  for i, item in ipairs(self.bannerDotUnitList_) do
    item.Ref:SetVisible(item.img_on, self.curBannerIndex_ == i)
    item.Ref:SetVisible(item.img_off, self.curBannerIndex_ ~= i)
    local posX = (i - centerNum) * 25
    item.Trans:SetAnchorPosition(posX, 0)
  end
end

function Mainui_funcs_listView:onShowUnLockEffect(id)
  local item = self.itemUnitDict_[id]
  if item and item.effect then
    item.effect:SetEffectGoVisible(true)
  end
end

function Mainui_funcs_listView:closeAllUnLockEffect()
  for _, item in pairs(self.itemUnitDict_) do
    if item.effect then
      item.effect:SetEffectGoVisible(false)
    end
  end
end

function Mainui_funcs_listView:onPandoraResourceReady(name)
  local pandoraData = Z.DataMgr.Get("pandora_data")
  local appName = pandoraData:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Announce)
  if name and name == appName then
    self:refreshFuncItem()
  end
end

function Mainui_funcs_listView:isFunctionShow(functionId)
  local isShow = true
  if functionId == E.FunctionID.Questionnaire then
    isShow = Z.VMMgr.GetVM("questionnaire").IsHaveMainIconAndRedDot()
  elseif functionId == E.FunctionID.SeasonHandbook then
    isShow = Z.VMMgr.GetVM("season_quest_sub").CheckHasSevenDayShow()
  elseif functionId == E.FunctionID.Announcement then
    local pandoraVM = Z.VMMgr.GetVM("pandora")
    isShow = pandoraVM:IsResourceReady()
    if isShow and not self.hadSendRefreshPandora_ then
      self.hadSendRefreshPandora_ = true
      pandoraVM:RefreshPandoraAnnounce()
    end
  elseif functionId == E.FunctionID.HaoPlayAnnouncement or functionId == E.FunctionID.APJAnnouncement then
    local sdkVM = Z.VMMgr.GetVM("sdk")
    local httpNoticeUrl = sdkVM.GetHttpNoticeUrl()
    isShow = httpNoticeUrl ~= ""
  end
  return isShow
end

return Mainui_funcs_listView
