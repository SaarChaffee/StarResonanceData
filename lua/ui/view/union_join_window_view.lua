local UI = Z.UI
local loopScrollRect = require("ui.component.loopscrollrect")
local unionListItem = require("ui.component.union.union_list_item")
local unionListDetailItem = require("ui.component.union.union_list_detail_item")
local super = require("ui.ui_view_base")
local Union_join_windowView = class("Union_join_windowView", super)
local TabType = {List = 1, Collection = 2}
local ListType = {Detail = 1, Simple = 2}

function Union_join_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_join_window")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.detailItemList_ = {
    unionListDetailItem.new(),
    unionListDetailItem.new(),
    unionListDetailItem.new()
  }
  self.unionTabFunctionIdDict_ = {
    [TabType.List] = E.UnionFuncId.UnionList,
    [TabType.Collection] = E.UnionFuncId.Collection
  }
end

function Union_join_windowView:initComponent()
  self:startAnimatedShow()
  self.unionTabBinderDict_ = {
    [TabType.List] = self.uiBinder.binder_tab_list,
    [TabType.Collection] = self.uiBinder.binder_tab_collection
  }
  self.scrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_list, self, unionListItem)
  for index, item in ipairs(self.detailItemList_) do
    item:Init(self.uiBinder["binder_detail_" .. index], self, index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_search_close, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_loading, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_empty, true)
  local isHaveUnion = self.unionVM_:GetPlayerUnionId() ~= 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_ask, isHaveUnion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_guide, not isHaveUnion)
  self:AddClick(self.uiBinder.btn_close, function()
    self:onReturnBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onHelpTipsBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_guide, function()
    self:onGuideBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_create, function()
    self:onCreateBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_join, function()
    self:onOneKeyJoinBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_search, function()
    self:onSearchBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_search_close, function()
    self:onSearchCloseBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_layout, function()
    self:onLayoutBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_find, function()
    self:onFindBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_refresh, function()
    self:AsyncGetUnionList(true)
  end)
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self:onLeftArrowBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self:onRightArrowBtnClick()
  end)
  self.uiBinder.input_name:AddListener(function(text)
    self:onInputChanged(text)
  end)
  self.uiBinder.input_name:AddSubmitListener(function(text)
    self:onInputSubmit(text)
  end)
  self:initToggle()
end

function Union_join_windowView:initData()
  self.queryCD_ = Z.Global.UnionListCD
  self.curUnionListData_ = {}
  self.curUnionListDataPage_ = 1
  self.allUnionListData_ = {}
  self.allUnionDictData_ = {}
  self.isSearchFlag_ = false
  self.searchUnionListData_ = {}
  self.searchCD_ = Z.Global.UnionSearchCD
  self.lastSearchTime_ = 0
  self.curTabType_ = nil
  self.curListType_ = ListType.Detail
  self.filterData_ = {
    TagDict = {},
    HideFullUnion = Z.Global.UnionListSiftMax ~= 0
  }
  self.collectLimitNum_ = Z.Global.UnionCollectMax
end

function Union_join_windowView:updateUnionDictData()
  self.allUnionDictData_ = {}
  for i, v in ipairs(self.allUnionListData_) do
    self.allUnionDictData_[v.baseInfo.Id] = v
  end
end

function Union_join_windowView:initToggle()
  for k, v in pairs(self.unionTabBinderDict_) do
    v.tog_tab_select.group = self.uiBinder.tog_group_tab
    v.tog_tab_select:AddListener(function(isOn)
      if isOn then
        self.commonVM_.CommonPlayTogAnim(v.anim_tog, self.cancelSource:CreateToken())
        self:switchTab(k, true)
      end
    end)
    v.tog_tab_select.OnPointClickEvent:AddListener(function()
      local subFuncId = self.unionTabFunctionIdDict_[k]
      local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId)
      v.tog_tab_select.IsToggleCanSwitch = isFuncOpen
    end)
  end
end

function Union_join_windowView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_join_windowView:switchOnOpen()
  self:refreshCollectionTab()
  local subType = TabType.List
  local binder = self.unionTabBinderDict_[subType]
  if binder.tog_tab_select.isOn then
    self:switchTab(subType)
  else
    binder.tog_tab_select.isOn = true
  end
end

function Union_join_windowView:switchTab(tabType, playAnim)
  if self.curTabType_ and self.curTabType_ == tabType then
    return
  end
  self.curTabType_ = tabType
  self.curUnionListData_ = {}
  local subFuncId = self.unionTabFunctionIdDict_[tabType]
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig({
    E.UnionFuncId.Union,
    subFuncId
  })
  if tabType == TabType.List then
    self.allUnionListData_ = self.unionData_.CacheUnionList
    self:refreshListData()
    self:refreshListUI(true)
    self:refreshListTab()
  else
    self.allUnionListData_ = self.unionData_:GetCollectUnionList()
    self:refreshListData()
    self:refreshListUI(true)
    self:refreshCollectionTab()
  end
  if playAnim then
    self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Tween_0)
  end
end

function Union_join_windowView:onReturnBtnClick()
  Z.UIMgr:CloseView("union_join_window")
end

function Union_join_windowView:onHelpTipsBtnClick()
  self.helpsysVM_.OpenFullScreenTipsView(30003)
end

function Union_join_windowView:onGuideBtnClick()
  self.helpsysVM_.OpenMulHelpSysView(7000)
end

function Union_join_windowView:onCreateBtnClick()
  self.unionVM_:OpenUnionCreateView()
end

function Union_join_windowView:onOneKeyJoinBtnClick()
  local unionIds = {}
  local oneKeyJoinMaxCount = Z.Global.UnionApplyMaxLimit
  if #self.allUnionListData_ == 0 then
    Z.TipsVM.ShowTips(1000544)
    return
  end
  if #self.curUnionListData_ == 0 then
    Z.TipsVM.ShowTips(1000508)
    return
  end
  for i = 1, #self.curUnionListData_ do
    local isNotFull = self.curUnionListData_[i].baseInfo.num < self.curUnionListData_[i].baseInfo.maxNum
    if self.curUnionListData_[i].isReq == false and isNotFull then
      unionIds[#unionIds + 1] = self.curUnionListData_[i].baseInfo.Id
      if oneKeyJoinMaxCount <= #unionIds then
        break
      end
    end
  end
  if #unionIds == 0 then
    Z.TipsVM.ShowTips(1000586)
    return
  end
  local reply = self.unionVM_:AsyncReqJoinUnions(unionIds, true, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    self:onReqJoinUnionsReply(reply.unionsRet)
  end
end

function Union_join_windowView:onRequestJoinBtnClick(unionId)
  local reply = self.unionVM_:AsyncReqJoinUnions({unionId}, false, self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    self:onReqJoinUnionsReply(reply.unionsRet)
  end
end

function Union_join_windowView:onChatBtnClick(presidentId)
  self.unionVM_:CloseJoinWindow()
  self.unionVM_:CloseUnionMainView()
  Z.VMMgr.GetVM("friends_main").OpenPrivateChat(presidentId)
end

function Union_join_windowView:onHideFullUnionTogClick(isOn)
  self:refreshListData()
  self:refreshListUI(true)
end

function Union_join_windowView:onSearchBtnClick()
  self:searchUnion(self.uiBinder.input_name.text)
end

function Union_join_windowView:onSearchCloseBtnClick()
  self:resetSearchState()
end

function Union_join_windowView:onLayoutBtnClick()
  self.curListType_ = self.curListType_ == ListType.Simple and ListType.Detail or ListType.Simple
  self:refreshListUI(true)
end

function Union_join_windowView:onFindBtnClick()
  local data = {
    TagDict = {},
    HideFullUnion = self.filterData_.HideFullUnion
  }
  for k, v in pairs(self.filterData_.TagDict) do
    data.TagDict[k] = v
  end
  local viewData = {
    filterData = data,
    worldPosition = self.uiBinder.trans_tips_pos.position,
    callback = function(filterData)
      self.filterData_ = filterData
      self:refreshListData()
      self:refreshListUI(false)
    end
  }
  self.unionVM_:OpenFilterTipsView(viewData)
end

function Union_join_windowView:onLeftArrowBtnClick()
  if self.curUnionListDataPage_ > 1 then
    self.curUnionListDataPage_ = self.curUnionListDataPage_ - 1
    self:refreshListUI(false)
  end
end

function Union_join_windowView:onRightArrowBtnClick()
  if self.curUnionListDataPage_ * 3 < #self.curUnionListData_ then
    self.curUnionListDataPage_ = self.curUnionListDataPage_ + 1
    self:refreshListUI(false)
  end
end

function Union_join_windowView:onInputChanged(content)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_search_close, content ~= "")
end

function Union_join_windowView:onInputSubmit(content)
  self:searchUnion(content)
end

function Union_join_windowView:refreshListTab()
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncGetUnionList()
  end)()
  local noUnion = self.unionVM_:GetPlayerUnionId() == 0
  local isCreateUnionUnlock = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.UnionFuncId.Create, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_create, noUnion and isCreateUnionUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_join, noUnion)
end

function Union_join_windowView:refreshCollectionTab()
  Z.CoroUtil.create_coro_xpcall(function()
    self:AsyncGetCacheUnionList()
  end)()
end

function Union_join_windowView:refreshListData()
  self:updateUnionDictData()
  local curListData
  if self.isSearchFlag_ then
    curListData = self.searchUnionListData_
  else
    curListData = self.allUnionListData_
  end
  self.curUnionListDataPage_ = 1
  self.curUnionListData_ = self:getUnionListDataAfterFilter(curListData)
end

function Union_join_windowView:getUnionListDataAfterFilter(unionListData)
  local resultList = {}
  for i = 1, #unionListData do
    local isEnougthFliter = true
    if self.filterData_.HideFullUnion and unionListData[i].baseInfo.num >= unionListData[i].baseInfo.maxNum then
      isEnougthFliter = false
    end
    if next(self.filterData_.TagDict) ~= nil then
      for id, value in pairs(self.filterData_.TagDict) do
        local isInclude = false
        for i, tagId in ipairs(unionListData[i].baseInfo.tags) do
          if id == tagId then
            isInclude = true
            break
          end
        end
        if not isInclude then
          isEnougthFliter = false
          break
        end
      end
    end
    if isEnougthFliter then
      table.insert(resultList, unionListData[i])
    end
  end
  return resultList
end

function Union_join_windowView:refreshListUI(resetIndex)
  local totalCount = #self.curUnionListData_
  local hasItem = 0 < totalCount
  local isCollection = self.curTabType_ == TabType.Collection
  local isShowDetailItem = self.curListType_ == ListType.Detail
  if hasItem == false then
    self:showEmptyUI()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_list_root, not isShowDetailItem)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loopscroll_list, hasItem and not isShowDetailItem)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_detail_root, hasItem and isShowDetailItem)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_empty, not hasItem)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_left, self.curUnionListDataPage_ > 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_arrow_right, totalCount > self.curUnionListDataPage_ * 3)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_btns_root, not isCollection)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_refresh, not isCollection)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_find, not isCollection)
  if not hasItem then
    return
  end
  if isShowDetailItem then
    self:refreshDetailList(resetIndex)
  else
    self:refreshSimpleList()
  end
end

function Union_join_windowView:refreshDetailList(resetIndex)
  if resetIndex then
    self.curUnionListDataPage_ = 1
  end
  local startIndex = (self.curUnionListDataPage_ - 1) * 3
  local vaildCount = 0
  for index, item in ipairs(self.detailItemList_) do
    local unionListData = self.curUnionListData_[startIndex + index]
    item:Refresh(unionListData)
    if unionListData then
      vaildCount = vaildCount + 1
    end
  end
  local totalCount = #self.curUnionListData_
  local curPage = self.curUnionListDataPage_
  local totalPage = math.ceil(totalCount / 3)
  self.uiBinder.lab_pages_digit.text = string.zconcat(curPage, "/", totalPage)
  if self.curTabType_ == TabType.Collection then
    local collectionList = self.unionData_:GetCollectUnionList()
    self.uiBinder.lab_limit_digit.text = string.zconcat(#collectionList, "/", self.collectLimitNum_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_limit, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.trans_limit, false)
  end
end

function Union_join_windowView:refreshSimpleList()
  self.scrollRect_:ClearCells()
  self.scrollRect_:SetData(self.curUnionListData_)
end

function Union_join_windowView:onUnionListReply(reply)
  if reply.errCode == 0 then
    self.unionData_:SetLastServerQueryTime(E.UnionServerQueryTimeKey.UnionList)
    self.unionData_.CacheUnionList = reply.unionList
  end
  self.allUnionListData_ = self.unionData_.CacheUnionList
  self:refreshListData()
  self:refreshListUI(false)
end

function Union_join_windowView:onReqJoinUnionsReply(unionsRetList)
  local success = false
  for i = 1, #unionsRetList do
    if unionsRetList[i].errCode == 0 then
      success = true
      local unionId = unionsRetList[i].unionId
      if self.allUnionDictData_[unionId] then
        self.allUnionDictData_[unionId].isReq = true
      end
      for i, v in ipairs(self.searchUnionListData_) do
        if v.baseInfo.Id == unionId then
          v.isReq = true
          break
        end
      end
    elseif unionsRetList[i].errCode == Z.PbErrCode("ErrUnionFull") then
      local unionId = unionsRetList[i].unionId
      if self.allUnionDictData_[unionId] then
        self.allUnionDictData_[unionId].baseInfo.num = self.allUnionDictData_[unionId].baseInfo.maxNum
      end
      for i, v in ipairs(self.searchUnionListData_) do
        if v.baseInfo.Id == unionId then
          v.baseInfo.num = self.allUnionDictData_[unionId].baseInfo.maxNum
          break
        end
      end
    end
  end
  if 1 < #unionsRetList then
    if success then
      Z.TipsVM.ShowTips(1000507)
    else
      Z.TipsVM.ShowTips(1000508)
    end
  end
  self:refreshListUI(false)
end

function Union_join_windowView:onJoinUnionNotify()
  if not self.unionVM_:IsPlayerUnionPresident() then
    local param = {
      guild = {
        name = self.unionVM_:GetPlayerUnionName()
      }
    }
    Z.TipsVM.ShowTipsLang(1000519, param)
    Z.UIMgr:GotoMainView()
    Z.UIMgr:OpenView("union_main")
  end
end

function Union_join_windowView:onOpenPrivateChat()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Union_join_windowView:resetSearchState()
  self.isSearchFlag_ = false
  self.uiBinder.input_name.text = ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_search_close, false)
  self:refreshListData()
  self:refreshListUI(true)
end

function Union_join_windowView:searchUnion(content)
  if content == "" then
    self:resetSearchState()
    return
  end
  if self.curTabType_ == TabType.Collection then
    self.isSearchFlag_ = true
    self.searchUnionListData_ = {}
    for i, v in ipairs(self.allUnionListData_) do
      if v.baseInfo.Name == content or v.baseInfo.Id == tonumber(content) then
        table.insert(self.searchUnionListData_, v)
      end
    end
    if #self.searchUnionListData_ == 0 then
      self:showEmptyUI()
    end
    self:refreshListData()
    self:refreshListUI(true)
    return
  end
  local duration = os.time() - self.lastSearchTime_
  if duration < self.searchCD_ then
    Z.TipsVM.ShowTipsLang(100000)
    return
  end
  local charNum = string.zlenNormalize(content)
  local searchMinLimit = Z.Global.UnionSearchMinLimit
  local searchMaxLimit = Z.Global.UnionSearchMaxLimit
  if charNum < searchMinLimit or charNum > searchMaxLimit then
    self.isSearchFlag_ = false
    Z.TipsVM.ShowTipsLang(1000505)
    return false
  end
  self.isSearchFlag_ = true
  self.lastSearchTime_ = os.time()
  Z.CoroUtil.create_coro_xpcall(function()
    self:showSearchingUI(true)
    local reply = self.unionVM_:AsyncSearchUnionList(content, self.cancelSource:CreateToken())
    self:showSearchingUI(false)
    if reply.errCode ~= 0 then
      self.searchUnionListData_ = {}
      self:showEmptyUI()
    elseif reply.unionList == nil or #reply.unionList == 0 then
      Z.TipsVM.ShowTipsLang(1000506)
      self.searchUnionListData_ = {}
      self:showEmptyUI()
    else
      self.searchUnionListData_ = reply.unionList
      self.filterData_ = {
        TagDict = {},
        HideFullUnion = false
      }
    end
    self:refreshListData()
    self:refreshListUI(true)
  end)()
end

function Union_join_windowView:showSearchingUI(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_loading, isShow)
end

function Union_join_windowView:showEmptyUI()
  if self.isSearchFlag_ then
    self.uiBinder.lab_empty.text = Lang("UnionSearchEmpty")
  elseif self.curTabType_ == TabType.List then
    self.uiBinder.lab_empty.text = Lang("UnionListEmpty")
  else
    self.uiBinder.lab_empty.text = Lang("UnionCollectionEmpty")
  end
end

function Union_join_windowView:AsyncGetUnionList(isRefresh)
  if self.isSearchFlag_ then
    return
  end
  if not self:checkQueryTime(E.UnionServerQueryTimeKey.UnionList, isRefresh) then
    return
  end
  local reply = self.unionVM_:AsyncReqUnionList(self.cancelSource:CreateToken())
  if reply.errCode == 0 then
    self.unionData_:SetLastServerQueryTime(E.UnionServerQueryTimeKey.UnionList)
    self.unionData_.CacheUnionList = reply.unionList
  end
  self.allUnionListData_ = self.unionData_.CacheUnionList
  self:refreshListData()
  self:refreshListUI(false)
end

function Union_join_windowView:AsyncGetCacheUnionList()
  if not self:checkQueryTime(E.UnionServerQueryTimeKey.UnionCollection) then
    return
  end
  local reply = self.unionVM_:AsyncGetCollectUnionList(self.cancelSource:CreateToken())
  if reply.errCode and reply.errCode == 0 then
    self.unionData_:SetLastServerQueryTime(E.UnionServerQueryTimeKey.UnionCollection)
  end
  if self.curTabType_ ~= TabType.Collection then
    return
  end
  self.allUnionListData_ = self.unionData_:GetCollectUnionList()
  self:refreshListData()
  self:refreshListUI(false)
end

function Union_join_windowView:checkQueryTime(queryKey, isShowTips)
  local curServerTime = Z.ServerTime:GetServerTime()
  local lastServerQueryTime = self.unionData_:GetLastServerQueryTime(queryKey)
  if curServerTime - lastServerQueryTime < self.queryCD_ * 1000 then
    if isShowTips then
      Z.TipsVM.ShowTips(1000545)
    end
    return false
  end
  return true
end

function Union_join_windowView:onCollectionUnionChange()
  if self.curTabType_ ~= TabType.Collection then
    return
  end
  self:resetSearchState()
end

function Union_join_windowView:OnActive()
  self:bindEvents()
  self:initComponent()
  self:initData()
  self:switchOnOpen()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Union_join_windowView:OnDeActive()
  self:unbindEvents()
  for k, v in pairs(self.unionTabBinderDict_) do
    v.tog_tab_select:RemoveAllListeners()
  end
  self.unionTabBinderDict_ = nil
  for index, item in ipairs(self.detailItemList_) do
    item:UnInit()
  end
  self.scrollRect_:ClearCells()
  self.scrollRect_ = nil
  self.uiBinder.input_name.text = ""
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Union_join_windowView:OnRefresh()
end

function Union_join_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.CollectionUnionChange, self.onCollectionUnionChange, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.ApplyJoinUnionBack, self.onReqJoinUnionsReply, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnionNotify, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_join_windowView:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.CollectionUnionChange, self.onCollectionUnionChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.ApplyJoinUnionBack, self.onReqJoinUnionsReply, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.JoinUnion, self.onJoinUnionNotify, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

return Union_join_windowView
